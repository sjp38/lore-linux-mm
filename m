Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 674C16B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 14:06:47 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id o16-v6so2537226pgv.21
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 11:06:47 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id k9-v6si23814993pga.539.2018.07.13.11.06.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 11:06:46 -0700 (PDT)
Message-ID: <1531504984.11680.21.camel@intel.com>
Subject: Re: [RFC PATCH v2 17/27] x86/cet/shstk: User-mode shadow stack
 support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 13 Jul 2018 11:03:04 -0700
In-Reply-To: <A034EC34-13E7-4AEF-BB3C-FEF14143B601@amacapital.net>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
	 <20180710222639.8241-18-yu-cheng.yu@intel.com>
	 <CAG48ez1ytOfQyNZMNPFp7XqKcpd7_aRai9G5s7rx0V=8ZG+r2A@mail.gmail.com>
	 <6F5FEFFD-0A9A-4181-8D15-5FC323632BA6@amacapital.net>
	 <CAG48ez1OwQMmhQfHaauo+vneywsQ_ERKr4uVcQebC=GbdqZWtA@mail.gmail.com>
	 <A034EC34-13E7-4AEF-BB3C-FEF14143B601@amacapital.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, bsingharora@gmail.com, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Wed, 2018-07-11 at 15:21 -0700, Andy Lutomirski wrote:
> > 
> > On Jul 11, 2018, at 2:51 PM, Jann Horn <jannh@google.com> wrote:
> > 
> > On Wed, Jul 11, 2018 at 2:34 PM Andy Lutomirski <luto@amacapital.net> wrote:
> > > 
> > > > 
> > > > On Jul 11, 2018, at 2:10 PM, Jann Horn <jannh@google.com> wrote:
> > > > 
> > > > > 
> > > > > On Tue, Jul 10, 2018 at 3:31 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> > > > > 
> > > > > This patch adds basic shadow stack enabling/disabling routines.
> > > > > A task's shadow stack is allocated from memory with VM_SHSTK
> > > > > flag set and read-only protection.A A The shadow stack is
> > > > > allocated to a fixed size.
> > > > > 
> > > > > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > > > [...]
> > > > > 
> > > > > diff --git a/arch/x86/kernel/cet.c b/arch/x86/kernel/cet.c
> > > > > new file mode 100644
> > > > > index 000000000000..96bf69db7da7
> > > > > --- /dev/null
> > > > > +++ b/arch/x86/kernel/cet.c
> > > > [...]
> > > > > 
> > > > > +static unsigned long shstk_mmap(unsigned long addr, unsigned long len)
> > > > > +{
> > > > > +A A A A A A A struct mm_struct *mm = current->mm;
> > > > > +A A A A A A A unsigned long populate;
> > > > > +
> > > > > +A A A A A A A down_write(&mm->mmap_sem);
> > > > > +A A A A A A A addr = do_mmap(NULL, addr, len, PROT_READ,
> > > > > +A A A A A A A A A A A A A A A A A A A A A A MAP_ANONYMOUS | MAP_PRIVATE, VM_SHSTK,
> > > > > +A A A A A A A A A A A A A A A A A A A A A A 0, &populate, NULL);
> > > > > +A A A A A A A up_write(&mm->mmap_sem);
> > > > > +
> > > > > +A A A A A A A if (populate)
> > > > > +A A A A A A A A A A A A A A A mm_populate(addr, populate);
> > > > > +
> > > > > +A A A A A A A return addr;
> > > > > +}
> > [...]
> > > 
> > > > 
> > > > Should the kernel enforce that two shadow stacks must have a guard
> > > > page between them so that they can not be directly adjacent, so that
> > > > if you have too much recursion, you can't end up corrupting an
> > > > adjacent shadow stack?
> > > I think the answer is a qualified a??noa??. I would like to instead enforce a general guard page on all mmaps that dona??t use MAP_FORCE. We *might* need to exempt any mmap with an address hint for
> > > compatibility.
> > I like this idea a lot.
> > 
> > > 
> > > My commercial software has been manually adding guard pages on every single mmap done by tcmalloc for years, and it has caught a couple bugs and costs essentially nothing.
> > > 
> > > Hmm. Linux should maybe add something like Windowsa?? a??reserveda?? virtual memory. Ita??s basically a way to ask for a VA range that explicitly contains nothing and can be subsequently be turned into
> > > something useful with the equivalent of MAP_FORCE.
> > What's the benefit over creating an anonymous PROT_NONE region? That
> > the kernel won't have to scan through the corresponding PTEs when
> > tearing down the mapping?
> Make it more obvious whata??s happening and avoid accounting issues?A A What Ia??ve actually used is MAP_NORESERVE | PROT_NONE, but I think this still counts against the VA rlimit. But maybe thata??s
> actually the desired behavior.

We can put a NULL at both ends of a SHSTK to guard against corruption.

Yu-chengA 
