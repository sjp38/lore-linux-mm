Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66CE06B03B5
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:48:24 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u62so22917304lfg.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 05:48:24 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id 199si5406171lfz.370.2017.06.19.05.48.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 05:48:23 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id o28so10273088lfk.1
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 05:48:22 -0700 (PDT)
Date: Mon, 19 Jun 2017 15:48:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 1/3] x86/mm: Provide pmdp_establish() helper
Message-ID: <20170619124819.tlbprgi7tima6rzl@node.shutemov.name>
References: <20170615145224.66200-1-kirill.shutemov@linux.intel.com>
 <20170615145224.66200-2-kirill.shutemov@linux.intel.com>
 <20170619074801.18fa2a16@mschwideX1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170619074801.18fa2a16@mschwideX1>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Ralf Baechle <ralf@linux-mips.org>, "David S. Miller" <davem@davemloft.net>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Mon, Jun 19, 2017 at 07:48:01AM +0200, Martin Schwidefsky wrote:
> On Thu, 15 Jun 2017 17:52:22 +0300
> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
> 
> > We need an atomic way to setup pmd page table entry, avoiding races with
> > CPU setting dirty/accessed bits. This is required to implement
> > pmdp_invalidate() that doesn't loose these bits.
> > 
> > On PAE we have to use cmpxchg8b as we cannot assume what is value of new pmd and
> > setting it up half-by-half can expose broken corrupted entry to CPU.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Cc: Ingo Molnar <mingo@kernel.org>
> > Cc: H. Peter Anvin <hpa@zytor.com>
> > Cc: Thomas Gleixner <tglx@linutronix.de>
> > ---
> >  arch/x86/include/asm/pgtable-3level.h | 18 ++++++++++++++++++
> >  arch/x86/include/asm/pgtable.h        | 14 ++++++++++++++
> >  2 files changed, 32 insertions(+)
> > 
> > diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
> > index f5af95a0c6b8..a924fc6a96b9 100644
> > --- a/arch/x86/include/asm/pgtable.h
> > +++ b/arch/x86/include/asm/pgtable.h
> > @@ -1092,6 +1092,20 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
> >  	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
> >  }
> > 
> > +#ifndef pmdp_establish
> > +#define pmdp_establish pmdp_establish
> > +static inline pmd_t pmdp_establish(pmd_t *pmdp, pmd_t pmd)
> > +{
> > +	if (IS_ENABLED(CONFIG_SMP)) {
> > +		return xchg(pmdp, pmd);
> > +	} else {
> > +		pmd_t old = *pmdp;
> > +		*pmdp = pmd;
> > +		return old;
> > +	}
> > +}
> > +#endif
> > +
> >  /*
> >   * clone_pgd_range(pgd_t *dst, pgd_t *src, int count);
> >   *
> 
> For the s390 version of the pmdp_establish function we need the mm to be able
> to do the TLB flush correctly. Can we please add a "struct vm_area_struct *vma"
> argument to pmdp_establish analog to pmdp_invalidate?
> 
> The s390 patch would then look like this:
> --
> From 4d4641249d5e826c21c522d149553e89d73fcd4f Mon Sep 17 00:00:00 2001
> From: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Date: Mon, 19 Jun 2017 07:40:11 +0200
> Subject: [PATCH] s390/mm: add pmdp_establish
> 
> Define the pmdp_establish function to replace a pmd entry with a new
> one and return the old value.
> 
> Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
> ---
>  arch/s390/include/asm/pgtable.h | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
> index bb59a0aa3249..dedeecd5455c 100644
> --- a/arch/s390/include/asm/pgtable.h
> +++ b/arch/s390/include/asm/pgtable.h
> @@ -1511,6 +1511,13 @@ static inline void pmdp_invalidate(struct vm_area_struct *vma,
>  	pmdp_xchg_direct(vma->vm_mm, addr, pmdp, __pmd(_SEGMENT_ENTRY_EMPTY));
>  }
>  
> +static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
> +				   pmd_t *pmdp, pmd_t pmd)
> +{
> +	return pmdp_xchg_direct(vma->vm_mm, addr, pmdp, pmd);

I guess, you need address too :-P.

I'll change prototype of pmdp_establish() and apply your patch.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
