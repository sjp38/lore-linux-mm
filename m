Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 2A95B6B0037
	for <linux-mm@kvack.org>; Tue, 27 May 2014 02:25:06 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rp16so8729127pbb.34
        for <linux-mm@kvack.org>; Mon, 26 May 2014 23:25:05 -0700 (PDT)
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com. [122.248.162.4])
        by mx.google.com with ESMTPS id yy5si3655051pbb.144.2014.05.26.23.25.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 May 2014 23:25:05 -0700 (PDT)
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <maddy@linux.vnet.ibm.com>;
	Tue, 27 May 2014 11:54:59 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 9904F125805B
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:54:03 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4R6PNPc7864642
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:55:24 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4R6OoDB026443
	for <linux-mm@kvack.org>; Tue, 27 May 2014 11:54:51 +0530
Message-ID: <53842FB1.7090909@linux.vnet.ibm.com>
Date: Tue, 27 May 2014 11:54:49 +0530
From: Madhavan Srinivasan <maddy@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH V4 0/2] mm: FAULT_AROUND_ORDER patchset performance data
 for powerpc
References: <1399541296-18810-1-git-send-email-maddy@linux.vnet.ibm.com> <537479E7.90806@linux.vnet.ibm.com> <alpine.LSU.2.11.1405151026540.4664@eggly.anvils> <87wqdik4n5.fsf@rustcorp.com.au> <53797511.1050409@linux.vnet.ibm.com> <alpine.LSU.2.11.1405191531150.1317@eggly.anvils> <20140519164301.eafd3dd288ccb88361ddcfc7@linux-foundation.org> <20140520004429.E660AE009B@blue.fi.intel.com> <87oaythsvk.fsf@rustcorp.com.au> <20140520102738.7F096E009B@blue.fi.intel.com>
In-Reply-To: <20140520102738.7F096E009B@blue.fi.intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org, benh@kernel.crashing.org, paulus@samba.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org, dave.hansen@intel.com

On Tuesday 20 May 2014 03:57 PM, Kirill A. Shutemov wrote:
> Rusty Russell wrote:
>> "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> writes:
>>> Andrew Morton wrote:
>>>> On Mon, 19 May 2014 16:23:07 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:
>>>>
>>>>> Shouldn't FAULT_AROUND_ORDER and fault_around_order be changed to be
>>>>> the order of the fault-around size in bytes, and fault_around_pages()
>>>>> use 1UL << (fault_around_order - PAGE_SHIFT)
>>>>
>>>> Yes.  And shame on me for missing it (this time!) at review.
>>>>
>>>> There's still time to fix this.  Patches, please.
>>>
>>> Here it is. Made at 3.30 AM, build tested only.
>>
>> Prefer on top of Maddy's patch which makes it always a variable, rather
>> than CONFIG_DEBUG_FS.  It's got enough hair as it is.
> 
> Something like this?
> 
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 20 May 2014 13:02:03 +0300
> Subject: [PATCH] mm: nominate faultaround area in bytes rather then page order
> 
> There are evidences that faultaround feature is less relevant on
> architectures with page size bigger then 4k. Which makes sense since
> page fault overhead per byte of mapped area should be less there.
> 
> Let's rework the feature to specify faultaround area in bytes instead of
> page order. It's 64 kilobytes for now.
> 
> The patch effectively disables faultaround on architectures with
> page size >= 64k (like ppc64).
> 
> It's possible that some other size of faultaround area is relevant for a
> platform. We can expose `fault_around_bytes' variable to arch-specific
> code once such platforms will be found.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  mm/memory.c | 62 +++++++++++++++++++++++--------------------------------------
>  1 file changed, 23 insertions(+), 39 deletions(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 037b812a9531..252b319e8cdf 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3402,63 +3402,47 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
>  	update_mmu_cache(vma, address, pte);
>  }
> 
> -#define FAULT_AROUND_ORDER 4
> +static unsigned long fault_around_bytes = 65536;
> +
> +static inline unsigned long fault_around_pages(void)
> +{
> +	return rounddown_pow_of_two(fault_around_bytes) / PAGE_SIZE;
> +}
> +
> +static inline unsigned long fault_around_mask(void)
> +{
> +	return ~(rounddown_pow_of_two(fault_around_bytes) - 1) & PAGE_MASK;
> +}
> 
> -#ifdef CONFIG_DEBUG_FS
> -static unsigned int fault_around_order = FAULT_AROUND_ORDER;
> 
> -static int fault_around_order_get(void *data, u64 *val)
> +#ifdef CONFIG_DEBUG_FS
> +static int fault_around_bytes_get(void *data, u64 *val)
>  {
> -	*val = fault_around_order;
> +	*val = fault_around_bytes;
>  	return 0;
>  }
> 
> -static int fault_around_order_set(void *data, u64 val)
> +static int fault_around_bytes_set(void *data, u64 val)
>  {

Kindly ignore the question if not relevant. Even though we need root
access to alter the value, will we be fine with
negative value?.

Regards
Maddy

> -	BUILD_BUG_ON((1UL << FAULT_AROUND_ORDER) > PTRS_PER_PTE);
> -	if (1UL << val > PTRS_PER_PTE)
> +	if (val / PAGE_SIZE > PTRS_PER_PTE)
>  		return -EINVAL;
> -	fault_around_order = val;
> +	fault_around_bytes = val;
>  	return 0;
>  }
> -DEFINE_SIMPLE_ATTRIBUTE(fault_around_order_fops,
> -		fault_around_order_get, fault_around_order_set, "%llu\n");
> +DEFINE_SIMPLE_ATTRIBUTE(fault_around_bytes_fops,
> +		fault_around_bytes_get, fault_around_bytes_set, "%llu\n");
> 
>  static int __init fault_around_debugfs(void)
>  {
>  	void *ret;
> 
> -	ret = debugfs_create_file("fault_around_order",	0644, NULL, NULL,
> -			&fault_around_order_fops);
> +	ret = debugfs_create_file("fault_around_bytes", 0644, NULL, NULL,
> +			&fault_around_bytes_fops);
>  	if (!ret)
> -		pr_warn("Failed to create fault_around_order in debugfs");
> +		pr_warn("Failed to create fault_around_bytes in debugfs");
>  	return 0;
>  }
>  late_initcall(fault_around_debugfs);
> -
> -static inline unsigned long fault_around_pages(void)
> -{
> -	return 1UL << fault_around_order;
> -}
> -
> -static inline unsigned long fault_around_mask(void)
> -{
> -	return ~((1UL << (PAGE_SHIFT + fault_around_order)) - 1);
> -}
> -#else
> -static inline unsigned long fault_around_pages(void)
> -{
> -	unsigned long nr_pages;
> -
> -	nr_pages = 1UL << FAULT_AROUND_ORDER;
> -	BUILD_BUG_ON(nr_pages > PTRS_PER_PTE);
> -	return nr_pages;
> -}
> -
> -static inline unsigned long fault_around_mask(void)
> -{
> -	return ~((1UL << (PAGE_SHIFT + FAULT_AROUND_ORDER)) - 1);
> -}
>  #endif
> 
>  static void do_fault_around(struct vm_area_struct *vma, unsigned long address,
> @@ -3515,7 +3499,7 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * if page by the offset is not ready to be mapped (cold cache or
>  	 * something).
>  	 */
> -	if (vma->vm_ops->map_pages) {
> +	if (vma->vm_ops->map_pages && fault_around_pages() > 1) {
>  		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>  		do_fault_around(vma, address, pte, pgoff, flags);
>  		if (!pte_same(*pte, orig_pte))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
