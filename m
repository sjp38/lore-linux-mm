Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id B90B76B5143
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:06:20 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 90-v6so4138779pla.18
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:06:20 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b2-v6si7264778plm.202.2018.08.30.09.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 09:06:19 -0700 (PDT)
Message-ID: <1535644924.26689.7.camel@intel.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 30 Aug 2018 09:02:04 -0700
In-Reply-To: <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-13-yu-cheng.yu@intel.com>
	 <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On Thu, 2018-08-30 at 17:49 +0200, Jann Horn wrote:
> On Thu, Aug 30, 2018 at 4:43 PM Yu-cheng Yu <yu-cheng.yu@intel.com>
> wrote:
> > 
> > 
> > When Shadow Stack is enabled, the read-only and PAGE_DIRTY_HW PTE
> > setting is reserved only for the Shadow Stack.A A To track dirty of
> > non-Shadow Stack read-only PTEs, we use PAGE_DIRTY_SW.
> > 
> > Update ptep_set_wrprotect() and pmdp_set_wrprotect().
> > 
> > Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> > ---
> > A arch/x86/include/asm/pgtable.h | 42
> > ++++++++++++++++++++++++++++++++++
> > A 1 file changed, 42 insertions(+)
> > 
> > diff --git a/arch/x86/include/asm/pgtable.h
> > b/arch/x86/include/asm/pgtable.h
> > index 4d50de77ea96..556ef258eeff 100644
> > --- a/arch/x86/include/asm/pgtable.h
> > +++ b/arch/x86/include/asm/pgtable.h
> > @@ -1203,7 +1203,28 @@ static inline pte_t
> > ptep_get_and_clear_full(struct mm_struct *mm,
> > A static inline void ptep_set_wrprotect(struct mm_struct *mm,
> > A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A unsigned long addr, pte_t
> > *ptep)
> > A {
> > +A A A A A A A pte_t pte;
> > +
> > A A A A A A A A clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
> > +A A A A A A A pte = *ptep;
> > +
> > +A A A A A A A /*
> > +A A A A A A A A * Some processors can start a write, but ending up seeing
> > +A A A A A A A A * a read-only PTE by the time they get to the Dirty bit.
> > +A A A A A A A A * In this case, they will set the Dirty bit, leaving a
> > +A A A A A A A A * read-only, Dirty PTE which looks like a Shadow Stack
> > PTE.
> > +A A A A A A A A *
> > +A A A A A A A A * However, this behavior has been improved and will not
> > occur
> > +A A A A A A A A * on processors supporting Shadow Stacks.A A Without this
> > +A A A A A A A A * guarantee, a transition to a non-present PTE and flush
> > the
> > +A A A A A A A A * TLB would be needed.
> > +A A A A A A A A *
> > +A A A A A A A A * When change a writable PTE to read-only and if the PTE
> > has
> > +A A A A A A A A * _PAGE_DIRTY_HW set, we move that bit to _PAGE_DIRTY_SW
> > so
> > +A A A A A A A A * that the PTE is not a valid Shadow Stack PTE.
> > +A A A A A A A A */
> > +A A A A A A A pte = pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
> > +A A A A A A A set_pte_at(mm, addr, ptep, pte);
> > A }
> I don't understand why it's okay that you first atomically clear the
> RW bit, then atomically switch from DIRTY_HW to DIRTY_SW. Doesn't
> that
> mean that between the two atomic writes, another core can
> incorrectly
> see a shadow stack?

Yes, we had that concern earlier and checked.
On processors supporting Shadow Stacks, that will not happen.

Yu-cheng
