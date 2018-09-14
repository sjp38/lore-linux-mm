Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7702B8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 16:43:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id v9-v6so5181515pff.4
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 13:43:34 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d6-v6si9272024pln.233.2018.09.14.13.43.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 13:43:33 -0700 (PDT)
Message-ID: <1536957543.12990.9.camel@intel.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Fri, 14 Sep 2018 13:39:03 -0700
In-Reply-To: <20180831162920.GQ24124@hirez.programming.kicks-ass.net>
References: <1535660494.28258.36.camel@intel.com>
	 <CAG48ez0yOuDhqxB779aO3Kss3gQ3cZTJL1VphDXQm+_M9jFPvQ@mail.gmail.com>
	 <1535662366.28781.6.camel@intel.com>
	 <CAG48ez0mkr95_TbLQnDGuGUd6G+eJVLZ-fEjDkwA6dSrm+9tLw@mail.gmail.com>
	 <CAG48ez3S3+DzAyo_SnoUW1GO0Cpd_x0A83MOx2p_MkogoAatLQ@mail.gmail.com>
	 <20180831095300.GF24124@hirez.programming.kicks-ass.net>
	 <1535726032.32537.0.camel@intel.com>
	 <f5a36e32-7c5f-91fe-9e98-fb44867fda11@linux.intel.com>
	 <1535730524.501.13.camel@intel.com>
	 <6d31bd30-6d5b-bbde-1e97-1d8255eff76d@linux.intel.com>
	 <20180831162920.GQ24124@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>
Cc: Jann Horn <jannh@google.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromium.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Fri, 2018-08-31 at 18:29 +0200, Peter Zijlstra wrote:
> On Fri, Aug 31, 2018 at 08:58:39AM -0700, Dave Hansen wrote:
> > 
> > On 08/31/2018 08:48 AM, Yu-cheng Yu wrote:
> > > 
> > > To trigger a race in ptep_set_wrprotect(), we need to fork from one of
> > > three pthread siblings.
> > > 
> > > Or do we measure only how much this affects fork?
> > > If there is no racing, the effect should be minimal.
> > We don't need a race.
> > 
> > I think the cmpxchg will be slower, even without a race, than the code
> > that was there before.A A The cmpxchg is a simple, straightforward
> > solution, but we're putting it in place of a plain memory write, which
> > is suboptimal.
> Note quite, the clear_bit() is LOCK prefixed.

With the updated ptep_set_wrprotect() below, I did MADV_WILLNEED to a shadow
stack of 8 MB, then 10,000 fork()'s, but could not prove it is more or less
efficient than the other. A So can we say this is probably fine in terms of
efficiency?

Yu-cheng




--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1203,7 +1203,36 @@ static inline pte_t ptep_get_and_clear_full(struct
mm_struct *mm,
A static inline void ptep_set_wrprotect(struct mm_struct *mm,
A 				A A A A A A unsigned long addr, pte_t *ptep)
A {
+#ifdef CONFIG_X86_INTEL_SHADOW_STACK_USER
+	pte_t new_pte, pte = READ_ONCE(*ptep);
+
+	/*
+	A * Some processors can start a write, but end up
+	A * seeing a read-only PTE by the time they get
+	A * to the Dirty bit.A A In this case, they will
+	A * set the Dirty bit, leaving a read-only, Dirty
+	A * PTE which looks like a Shadow Stack PTE.
+	A *
+	A * However, this behavior has been improved and
+	A * will not occur on processors supporting
+	A * Shadow Stacks.A A Without this guarantee, a
+	A * transition to a non-present PTE and flush the
+	A * TLB would be needed.
+	A *
+	A * When changing a writable PTE to read-only and
+	A * if the PTE has _PAGE_DIRTY_HW set, we move
+	A * that bit to _PAGE_DIRTY_SW so that the PTE is
+	A * not a valid Shadow Stack PTE.
+	A */
+	do {
+		new_pte = pte_wrprotect(pte);
+		new_pte.pte |= (new_pte.pte & _PAGE_DIRTY_HW) >>
+				_PAGE_BIT_DIRTY_HW << _PAGE_BIT_DIRTY_SW;
+		new_pte.pte &= ~_PAGE_DIRTY_HW;
+	} while (!try_cmpxchg(ptep, &pte, new_pte));
+#else
A 	clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
+#endif
A }
