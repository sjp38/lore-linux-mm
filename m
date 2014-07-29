Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 518E16B0036
	for <linux-mm@kvack.org>; Tue, 29 Jul 2014 18:37:00 -0400 (EDT)
Received: by mail-ie0-f177.google.com with SMTP id at20so369130iec.36
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 15:37:00 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id d9si1477265igo.13.2014.07.29.15.36.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 29 Jul 2014 15:36:59 -0700 (PDT)
Received: by mail-ig0-f177.google.com with SMTP id hn18so1806942igb.16
        for <linux-mm@kvack.org>; Tue, 29 Jul 2014 15:36:59 -0700 (PDT)
Date: Tue, 29 Jul 2014 15:36:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: close race between do_fault_around() and
 fault_around_bytes_set()
In-Reply-To: <20140729142710.656A9E00A3@blue.fi.intel.com>
Message-ID: <alpine.DEB.2.02.1407291531080.20991@chino.kir.corp.google.com>
References: <1406633609-17586-1-git-send-email-kirill.shutemov@linux.intel.com> <1406633609-17586-2-git-send-email-kirill.shutemov@linux.intel.com> <53D7A251.7010509@samsung.com> <20140729142710.656A9E00A3@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Sasha Levin <sasha.levin@oracle.com>, linux-mm@kvack.org

On Tue, 29 Jul 2014, Kirill A. Shutemov wrote:

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
>  mm/memory.c | 17 +++++++++++------
>  1 file changed, 11 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 9d66bc66f338..7f4f0c41c9e9 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2772,12 +2772,12 @@ static unsigned long fault_around_bytes = rounddown_pow_of_two(65536);
>  
>  static inline unsigned long fault_around_pages(void)
>  {
> -	return fault_around_bytes >> PAGE_SHIFT;
> +	return ACCESS_ONCE(fault_around_bytes) >> PAGE_SHIFT;

Not sure why this is being added here, ACCESS_ONCE() would be needed 
depending on the context in which the return value is used, 
do_read_fault() won't need it.

>  }
>  
> -static inline unsigned long fault_around_mask(void)
> +static inline unsigned long fault_around_mask(unsigned long nr_pages)
>  {
> -	return ~(fault_around_bytes - 1) & PAGE_MASK;
> +	return ~(nr_pages * PAGE_SIZE - 1) & PAGE_MASK;
>  }
>  
>  

This patch is corrupted because of the newline here that doesn't exist in 
linux-next.

> @@ -2844,12 +2844,17 @@ late_initcall(fault_around_debugfs);
>  static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
>  		pte_t *pte, pgoff_t pgoff, unsigned int flags)
>  {
> -	unsigned long start_addr;
> +	unsigned long start_addr, nr_pages;
>  	pgoff_t max_pgoff;
>  	struct vm_fault vmf;
>  	int off;
>  
> -	start_addr = max(address & fault_around_mask(), vma->vm_start);
> +	nr_pages = fault_around_pages();
> +	/* race with fault_around_bytes_set() */
> +	if (unlikely(nr_pages <= 1))
> +		return;

Why exactly is this unlikely if fault_around_bytes is tunable via debugfs 
to equal PAGE_SIZE?  I assume we're expecting nobody is going to be doing 
that, otherwise we'll hit the unlikely() branch here every time.  So 
either the unlikely or the tunable should be removed.

The problem is that fault_around_bytes isn't documented so we don't even 
know the min value without looking at the source code.

I also don't see how nr_pages can be < 1.

> +
> +	start_addr = max(address & fault_around_mask(nr_pages), vma->vm_start);
>  	off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
>  	pte -= off;
>  	pgoff -= off;
> @@ -2861,7 +2866,7 @@ static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
>  	max_pgoff = pgoff - ((start_addr >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)) +
>  		PTRS_PER_PTE - 1;
>  	max_pgoff = min3(max_pgoff, vma_pages(vma) + vma->vm_pgoff - 1,
> -			pgoff + fault_around_pages() - 1);
> +			pgoff + nr_pages - 1);
>  
>  	/* Check if it makes any sense to call ->map_pages */
>  	while (!pte_none(*pte)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
