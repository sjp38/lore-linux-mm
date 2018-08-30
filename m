Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 282976B533A
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 16:27:57 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id h4-v6so4515525pls.17
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:27:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id bg5-v6si7129590plb.368.2018.08.30.13.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 13:27:56 -0700 (PDT)
Message-ID: <1535660615.28258.37.camel@intel.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Date: Thu, 30 Aug 2018 13:23:35 -0700
In-Reply-To: <9879c17a-24da-d84a-5a7c-30bcbb473914@infradead.org>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
	 <20180830143904.3168-13-yu-cheng.yu@intel.com>
	 <9879c17a-24da-d84a-5a7c-30bcbb473914@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Randy Dunlap <rdunlap@infradead.org>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On Thu, 2018-08-30 at 12:59 -0700, Randy Dunlap wrote:
> On 08/30/2018 07:38 AM, Yu-cheng Yu wrote:
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
> > A 				A A A A A A unsigned long addr, pte_t
> > *ptep)
> > A {
> > +	pte_t pte;
> > +
> > A 	clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
> > +	pte = *ptep;
> > +
> > +	/*
> > +	A * Some processors can start a write, but ending up
> > seeing
> 	A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A but end up seeing
> 
> > 
> > +	A * a read-only PTE by the time they get to the Dirty bit.
> > +	A * In this case, they will set the Dirty bit, leaving a
> > +	A * read-only, Dirty PTE which looks like a Shadow Stack
> > PTE.
> > +	A *
> > +	A * However, this behavior has been improved and will not
> > occur
> > +	A * on processors supporting Shadow Stacks.A A Without this
> > +	A * guarantee, a transition to a non-present PTE and flush
> > the
> > +	A * TLB would be needed.
> > +	A *
> > +	A * When change a writable PTE to read-only and if the PTE
> > has
> 	A A A A A A A A changing
> 
> > 
> > +	A * _PAGE_DIRTY_HW set, we move that bit to _PAGE_DIRTY_SW
> > so
> > +	A * that the PTE is not a valid Shadow Stack PTE.
> > +	A */
> > +	pte = pte_move_flags(pte, _PAGE_DIRTY_HW,
> > _PAGE_DIRTY_SW);
> > +	set_pte_at(mm, addr, ptep, pte);
> > A }
> > A 
> > A #define flush_tlb_fix_spurious_fault(vma, address) do { } while
> > (0)
> > @@ -1266,7 +1287,28 @@ static inline pud_t
> > pudp_huge_get_and_clear(struct mm_struct *mm,
> > A static inline void pmdp_set_wrprotect(struct mm_struct *mm,
> > A 				A A A A A A unsigned long addr, pmd_t
> > *pmdp)
> > A {
> > +	pmd_t pmd;
> > +
> > A 	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
> > +	pmd = *pmdp;
> > +
> > +	/*
> > +	A * Some processors can start a write, but ending up
> > seeing
> 	A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A but end up seeing
> 
> > 
> > +	A * a read-only PTE by the time they get to the Dirty bit.
> > +	A * In this case, they will set the Dirty bit, leaving a
> > +	A * read-only, Dirty PTE which looks like a Shadow Stack
> > PTE.
> > +	A *
> > +	A * However, this behavior has been improved and will not
> > occur
> > +	A * on processors supporting Shadow Stacks.A A Without this
> > +	A * guarantee, a transition to a non-present PTE and flush
> > the
> > +	A * TLB would be needed.
> > +	A *
> > +	A * When change a writable PTE to read-only and if the PTE
> > has
> 	A A A A A A A A changing
> 
> > 
> > +	A * _PAGE_DIRTY_HW set, we move that bit to _PAGE_DIRTY_SW
> > so
> > +	A * that the PTE is not a valid Shadow Stack PTE.
> > +	A */
> > +	pmd = pmd_move_flags(pmd, _PAGE_DIRTY_HW,
> > _PAGE_DIRTY_SW);
> > +	set_pmd_at(mm, addr, pmdp, pmd);
> > A }
> > A 
> > A #define pud_write pud_write
> > 
> 

Thanks, I will fix it!
