Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EE616B0006
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 16:57:12 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 31-v6so15692744plf.19
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 13:57:12 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id i15-v6si21258658pfk.146.2018.07.11.13.57.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 13:57:10 -0700 (PDT)
Message-ID: <1531342404.15351.35.camel@intel.com>
Subject: Re: [RFC PATCH v2 20/27] x86/cet/shstk: ELF header parsing of CET
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Wed, 11 Jul 2018 13:53:24 -0700
In-Reply-To: <CAG48ez3DYQtgk_WfOwbFFeuWJmzwZhH-DkDT1UKYVZaYi6V_Pg@mail.gmail.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-21-yu-cheng.yu@intel.com>
	 <CAG48ez3DYQtgk_WfOwbFFeuWJmzwZhH-DkDT1UKYVZaYi6V_Pg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Wed, 2018-07-11 at 12:37 -0700, Jann Horn wrote:
> On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com>
> wrote:
> > 
> > 
> > Look in .note.gnu.property of an ELF file and check if shadow stack
> > needs
> > to be enabled for the task.
> > 
> > Signed-off-by: H.J. Lu <hjl.tools@gmail.com>
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> [...]
> > 
> > diff --git a/arch/x86/kernel/elf.c b/arch/x86/kernel/elf.c
> > new file mode 100644
> > index 000000000000..233f6dad9c1f
> > --- /dev/null
> > +++ b/arch/x86/kernel/elf.c
> [...]
> > 
> > +#define NOTE_SIZE_BAD(n, align, max) \
> > +A A A A A A A ((n->n_descsz < 8) || ((n->n_descsz % align) != 0) || \
> > +A A A A A A A A (((u8 *)(n + 1) + 4 + n->n_descsz) > (max)))
> Please do not compute out-of-bounds pointers and then compare them
> against an expected maximum pointer. Computing an out-of-bounds
> pointer is undefined behavior according to the C99 specification,
> section "6.5.6 Additive operators", paragraph 8; and in this case,
> n->n_descsz is 32 bits wide, which means that even if the compiler
> isn't doing anything funny, if you're operating on addresses in the
> last 4GiB of virtual memory and the pointer wraps around, this could
> break.
> In particular, if anyone ever uses this code in a 32-bit kernel, this
> is going to blow up.
> Please use size comparisons instead of pointer comparisons.

I will fix it.

> [...]
> > 
> > diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
> > index 0ac456b52bdd..3395f6a631d5 100644
> > --- a/fs/binfmt_elf.c
> > +++ b/fs/binfmt_elf.c
> > @@ -1081,6 +1081,22 @@ static int load_elf_binary(struct
> > linux_binprm *bprm)
> > A A A A A A A A A A A A A A A A goto out_free_dentry;
> > A A A A A A A A }
> > 
> > +#ifdef CONFIG_ARCH_HAS_PROGRAM_PROPERTIES
> > +
> > +A A A A A A A if (interpreter) {
> > +A A A A A A A A A A A A A A A retval = arch_setup_features(&loc->interp_elf_ex,
> > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A interp_elf_phdata,
> > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A interpreter, true);
> > +A A A A A A A } else {
> > +A A A A A A A A A A A A A A A retval = arch_setup_features(&loc->elf_ex,
> > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A elf_phdata,
> > +A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A bprm->file, false);
> > +A A A A A A A }
> So for non-static binaries, the ELF headers of ld.so determine
> whether
> CET will be on or off for the entire system, right? Is the intent
> here
> that ld.so should start with CET enabled, and then either use the
> compatibility bitmap or turn CET off at runtime if the executable or
> one of the libraries doesn't actually work with CET?


The kernel command-line options "no_cet_shstk" and "no_cet_ibt" turn
off CET features for the whole system. A The GLIBC tunable
"glibc.tune.hwcap=-SHSTK,-IBT" turns off CET features for the current
shell. A Another GLIBC tunable "glibc.tune.x86_shstk=<on, permissive>"
determines, in the current shell, how dlopen() deals with SHSTK legacy
lib's.

So, if ld.so's ELF header has SHSTK/IBT, and CET is enabled in the
current shell, it will run with CET enabled. A If the application
executable and all its dependent libraries have CET, ld.so runs the
application with CET enabled. A Otherwise ld.so turns off SHSTK (and/or
sets up legacy bitmap for IBT) before passing to the application.

Yu-cheng
