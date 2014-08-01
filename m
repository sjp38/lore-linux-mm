Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f46.google.com (mail-qa0-f46.google.com [209.85.216.46])
	by kanga.kvack.org (Postfix) with ESMTP id C18456B0044
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 17:37:01 -0400 (EDT)
Received: by mail-qa0-f46.google.com with SMTP id v10so4535654qac.5
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 14:37:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j8si17720218qab.100.2014.08.01.14.37.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Aug 2014 14:37:01 -0700 (PDT)
Date: Fri, 1 Aug 2014 17:36:54 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCHv2 1/2] mm: close race between do_fault_around() and
 fault_around_bytes_set()
Message-ID: <20140801213654.GA8692@nhori.bos.redhat.com>
References: <1406893869-32739-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1406893869-32739-2-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1406893869-32739-2-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Sasha Levin <sasha.levin@oracle.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

On Fri, Aug 01, 2014 at 02:51:08PM +0300, Kirill A. Shutemov wrote:
> Things can go wrong if fault_around_bytes will be changed under
> do_fault_around(): between fault_around_mask() and fault_around_pages().
> 
> Let's read fault_around_bytes only once during do_fault_around() and
> calculate mask based on the reading.
> 
> Note: fault_around_bytes can only be updated via debug interface. Also
> I've tried but was not able to trigger a bad behaviour without the
> patch. So I would not consider this patch as urgent.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/memory.c | 21 +++++++--------------
>  1 file changed, 7 insertions(+), 14 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 6ea15ed23ec4..be43fd9606db 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2770,16 +2770,6 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>  
>  static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
>  
> -static inline unsigned long fault_around_pages(void)
> -{
> -	return fault_around_bytes >> PAGE_SHIFT;
> -}
> -
> -static inline unsigned long fault_around_mask(void)
> -{
> -	return ~(fault_around_bytes - 1) & PAGE_MASK;
> -}
> -
>  #ifdef CONFIG_DEBUG_FS
>  static int fault_around_bytes_get(void *data, u64 *val)
>  {
> @@ -2844,12 +2834,15 @@ late_initcall(fault_around_debugfs);
>  static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
>  		pte_t *pte, pgoff_t pgoff, unsigned int flags)
>  {
> -	unsigned long start_addr;
> +	unsigned long start_addr, nr_pages, mask;
>  	pgoff_t max_pgoff;
>  	struct vm_fault vmf;
>  	int off;
>  
> -	start_addr = max(address & fault_around_mask(), vma->vm_start);
> +	nr_pages = ACCESS_ONCE(fault_around_bytes) >> PAGE_SHIFT;
> +	mask = ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;

If nr_pages never becomes 0, don't we need to do (& PAGE_MASK) ?

Thanks,
Naoya Horiguchi

> +
> +	start_addr = max(address & mask, vma->vm_start);
>  	off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
>  	pte -= off;
>  	pgoff -= off;
> @@ -2861,7 +2854,7 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
>  	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
>  		PTRS_PER_PTE - 1;
>  	max_pgoff = min3(max_pgoff, vma_pages(vma) + vma->vm_pgoff - 1,
> -			pgoff + fault_around_pages() - 1);
> +			pgoff + nr_pages - 1);
>  
>  	/* Check if it makes any sense to call ->map_pages */
>  	while (!pte_none(*pte)) {
> @@ -2896,7 +2889,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * something).
>  	 */
>  	if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
> -	    fault_around_pages() > 1) {
> +	    fault_around_bytes >> PAGE_SHIFT > 1) {
>  		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>  		do_fault_around(vma, address, pte, pgoff, flags);
>  		if (!pte_same(*pte, orig_pte))
> -- 
> 2.0.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
