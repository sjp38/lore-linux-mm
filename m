Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 049136B531E
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 15:59:41 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so5574546pgp.4
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:59:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x81-v6si8053418pgx.156.2018.08.30.12.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 30 Aug 2018 12:59:39 -0700 (PDT)
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
 <20180830143904.3168-13-yu-cheng.yu@intel.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <9879c17a-24da-d84a-5a7c-30bcbb473914@infradead.org>
Date: Thu, 30 Aug 2018 12:59:21 -0700
MIME-Version: 1.0
In-Reply-To: <20180830143904.3168-13-yu-cheng.yu@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 08/30/2018 07:38 AM, Yu-cheng Yu wrote:
> When Shadow Stack is enabled, the read-only and PAGE_DIRTY_HW PTE
> setting is reserved only for the Shadow Stack.  To track dirty of
> non-Shadow Stack read-only PTEs, we use PAGE_DIRTY_SW.
> 
> Update ptep_set_wrprotect() and pmdp_set_wrprotect().
> 
> Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
> ---
>  arch/x86/include/asm/pgtable.h | 42 ++++++++++++++++++++++++++++++++++
>  1 file changed, 42 insertions(+)
> 
> diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> index 4d50de77ea96..556ef258eeff 100644
> --- a/arch/x86/include/asm/pgtable.h
> +++ b/arch/x86/include/asm/pgtable.h
> @@ -1203,7 +1203,28 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
>  static inline void ptep_set_wrprotect(struct mm_struct *mm,
>  				      unsigned long addr, pte_t *ptep)
>  {
> +	pte_t pte;
> +
>  	clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
> +	pte = *ptep;
> +
> +	/*
> +	 * Some processors can start a write, but ending up seeing

	                                      but end up seeing

> +	 * a read-only PTE by the time they get to the Dirty bit.
> +	 * In this case, they will set the Dirty bit, leaving a
> +	 * read-only, Dirty PTE which looks like a Shadow Stack PTE.
> +	 *
> +	 * However, this behavior has been improved and will not occur
> +	 * on processors supporting Shadow Stacks.  Without this
> +	 * guarantee, a transition to a non-present PTE and flush the
> +	 * TLB would be needed.
> +	 *
> +	 * When change a writable PTE to read-only and if the PTE has

	        changing

> +	 * _PAGE_DIRTY_HW set, we move that bit to _PAGE_DIRTY_SW so
> +	 * that the PTE is not a valid Shadow Stack PTE.
> +	 */
> +	pte = pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
> +	set_pte_at(mm, addr, ptep, pte);
>  }
>  
>  #define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)
> @@ -1266,7 +1287,28 @@ static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
>  static inline void pmdp_set_wrprotect(struct mm_struct *mm,
>  				      unsigned long addr, pmd_t *pmdp)
>  {
> +	pmd_t pmd;
> +
>  	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
> +	pmd = *pmdp;
> +
> +	/*
> +	 * Some processors can start a write, but ending up seeing

	                                      but end up seeing

> +	 * a read-only PTE by the time they get to the Dirty bit.
> +	 * In this case, they will set the Dirty bit, leaving a
> +	 * read-only, Dirty PTE which looks like a Shadow Stack PTE.
> +	 *
> +	 * However, this behavior has been improved and will not occur
> +	 * on processors supporting Shadow Stacks.  Without this
> +	 * guarantee, a transition to a non-present PTE and flush the
> +	 * TLB would be needed.
> +	 *
> +	 * When change a writable PTE to read-only and if the PTE has

	        changing

> +	 * _PAGE_DIRTY_HW set, we move that bit to _PAGE_DIRTY_SW so
> +	 * that the PTE is not a valid Shadow Stack PTE.
> +	 */
> +	pmd = pmd_move_flags(pmd, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
> +	set_pmd_at(mm, addr, pmdp, pmd);
>  }
>  
>  #define pud_write pud_write
> 


-- 
~Randy
