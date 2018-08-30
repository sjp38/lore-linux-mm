Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C1E176B5217
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:25:26 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id v9-v6so5038559pff.4
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:25:26 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y5-v6si6165821pll.89.2018.08.30.09.25.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 09:25:25 -0700 (PDT)
Message-ID: <1535646055.26689.10.camel@intel.com>
Subject: Re: [RFC PATCH v3 18/24] x86/cet/shstk: User-mode shadow stack
 support
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 30 Aug 2018 09:20:55 -0700
In-Reply-To: <CAG48ez0d8+E_O-9u6ZHZ6dQO55Ui2ydV_kia-EEhyYeB_w4r2g@mail.gmail.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-19-yu-cheng.yu@intel.com>
	 <CAG48ez0d8+E_O-9u6ZHZ6dQO55Ui2ydV_kia-EEhyYeB_w4r2g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, 2018-08-30 at 18:10 +0200, Jann Horn wrote:
> On Thu, Aug 30, 2018 at 4:44 PM Yu-cheng Yu <yu-cheng.yu@intel.com>
> wrote:
> > 
> > 
> > This patch adds basic shadow stack enabling/disabling routines.
> > A task's shadow stack is allocated from memory with VM_SHSTK
> > flag set and read-only protection.A A The shadow stack is
> > allocated to a fixed size of RLIMIT_STACK.
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> [...]
> > 
> > +static int set_shstk_ptr(unsigned long addr)
> > +{
> > +A A A A A A A u64 r;
> > +
> > +A A A A A A A if (!cpu_feature_enabled(X86_FEATURE_SHSTK))
> > +A A A A A A A A A A A A A A A return -1;
> > +
> > +A A A A A A A if ((addr >= TASK_SIZE_MAX) || (!IS_ALIGNED(addr, 4)))
> > +A A A A A A A A A A A A A A A return -1;
> > +
> > +A A A A A A A rdmsrl(MSR_IA32_U_CET, r);
> > +A A A A A A A wrmsrl(MSR_IA32_PL3_SSP, addr);
> > +A A A A A A A wrmsrl(MSR_IA32_U_CET, r | MSR_IA32_CET_SHSTK_EN);
> > +A A A A A A A return 0;
> > +}
> Here's a really stupid question: Where is the logic for switching
> those MSRs on task switch? MSR_IA32_PL3_SSP contains a userspace
> pointer, so it has to be switched on task switch, right? I'm sure
> I'm
> missing something obvious, but grepping for places that set
> MSR_IA32_PL3_SSP to nonzero values through the entire patchset, I
> only
> see set_shstk_ptr(), which is called from:
> 
> A - cet_setup_shstk() (called from arch_setup_features(), which is
> called from load_elf_binary())
> A - cet_restore_signal() (called on signal handler return)
> A - cet_setup_signal() (called from signal handling code)

The MSR is in the XSAVES buffer and switched by XSAVES/XRSTORS.

Yu-cheng
