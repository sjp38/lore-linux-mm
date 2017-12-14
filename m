Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 298736B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 19:09:55 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id t92so2229888wrc.13
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 16:09:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l44si2262458wre.375.2017.12.13.16.09.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 16:09:54 -0800 (PST)
Date: Wed, 13 Dec 2017 16:09:51 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCHv4 09/12] x86/mm: Provide pmdp_establish() helper
Message-Id: <20171213160951.249071f2aecdccb38b6bb646@linux-foundation.org>
In-Reply-To: <20171213105756.69879-10-kirill.shutemov@linux.intel.com>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
	<20171213105756.69879-10-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, 13 Dec 2017 13:57:53 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:

> We need an atomic way to setup pmd page table entry, avoiding races with
> CPU setting dirty/accessed bits. This is required to implement
> pmdp_invalidate() that doesn't lose these bits.
> 
> On PAE we can avoid expensive cmpxchg8b for cases when new page table
> entry is not present. If it's present, fallback to cpmxchg loop.
> 
> ...
>
> --- a/arch/x86/include/asm/pgtable-3level.h
> +++ b/arch/x86/include/asm/pgtable-3level.h
> @@ -158,7 +158,6 @@ static inline pte_t native_ptep_get_and_clear(pte_t *ptep)
>  #define native_ptep_get_and_clear(xp) native_local_ptep_get_and_clear(xp)
>  #endif
>  
> -#ifdef CONFIG_SMP
>  union split_pmd {
>  	struct {
>  		u32 pmd_low;
> @@ -166,6 +165,8 @@ union split_pmd {
>  	};
>  	pmd_t pmd;
>  };
> +
> +#ifdef CONFIG_SMP
>  static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
>  {
>  	union split_pmd res, *orig = (union split_pmd *)pmdp;
> @@ -181,6 +182,40 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
>  #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
>  #endif
>  
> +#ifndef pmdp_establish
> +#define pmdp_establish pmdp_establish
> +static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
> +		unsigned long address, pmd_t *pmdp, pmd_t pmd)
> +{
> +	pmd_t old;
> +
> +	/*
> +	 * If pmd has present bit cleared we can get away without expensive
> +	 * cmpxchg64: we can update pmdp half-by-half without racing with
> +	 * anybody.
> +	 */
> +	if (!(pmd_val(pmd) & _PAGE_PRESENT)) {
> +		union split_pmd old, new, *ptr;
> +
> +		ptr = (union split_pmd *)pmdp;
> +
> +		new.pmd = pmd;
> +
> +		/* xchg acts as a barrier before setting of the high bits */
> +		old.pmd_low = xchg(&ptr->pmd_low, new.pmd_low);
> +		old.pmd_high = ptr->pmd_high;
> +		ptr->pmd_high = new.pmd_high;
> +		return old.pmd;
> +	}
> +
> +	{
> +		old = *pmdp;
> +	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);

um, what happened here?

> +	return old;
> +}
> +#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
