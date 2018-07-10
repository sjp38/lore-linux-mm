Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id D79246B0003
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:47:06 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id j4-v6so10088216vke.12
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 13:47:06 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id j49-v6si7353079uaa.306.2018.07.10.13.47.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 13:47:04 -0700 (PDT)
Subject: Re: [PATCH] mm: hugetlb: don't zero 1GiB bootmem pages.
References: <20180710184903.68239-1-cannonmatthews@google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <ad083425-c861-1a77-069d-23b0aa1c84c6@oracle.com>
Date: Tue, 10 Jul 2018 13:46:57 -0700
MIME-Version: 1.0
In-Reply-To: <20180710184903.68239-1-cannonmatthews@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>, Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com

On 07/10/2018 11:49 AM, Cannon Matthews wrote:
> When using 1GiB pages during early boot, use the new
> memblock_virt_alloc_try_nid_raw() function to allocate memory without
> zeroing it.  Zeroing out hundreds or thousands of GiB in a single core
> memset() call is very slow, and can make early boot last upwards of
> 20-30 minutes on multi TiB machines.
> 
> To be safe, still zero the first sizeof(struct boomem_huge_page) bytes
> since this is used a temporary storage place for this info until
> gather_bootmem_prealloc() processes them later.
> 
> The rest of the memory does not need to be zero'd as the hugetlb pages
> are always zero'd on page fault.
> 
> Tested: Booted with ~3800 1G pages, and it booted successfully in
> roughly the same amount of time as with 0, as opposed to the 25+
> minutes it would take before.
> 

Nice improvement!

> Signed-off-by: Cannon Matthews <cannonmatthews@google.com>
> ---
>  mm/hugetlb.c | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3612fbb32e9d..c93a2c77e881 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2101,7 +2101,7 @@ int __alloc_bootmem_huge_page(struct hstate *h)
>  	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
>  		void *addr;
> 
> -		addr = memblock_virt_alloc_try_nid_nopanic(
> +		addr = memblock_virt_alloc_try_nid_raw(
>  				huge_page_size(h), huge_page_size(h),
>  				0, BOOTMEM_ALLOC_ACCESSIBLE, node);
>  		if (addr) {
> @@ -2109,7 +2109,12 @@ int __alloc_bootmem_huge_page(struct hstate *h)
>  			 * Use the beginning of the huge page to store the
>  			 * huge_bootmem_page struct (until gather_bootmem
>  			 * puts them into the mem_map).
> +			 *
> +			 * memblock_virt_alloc_try_nid_raw returns non-zero'd
> +			 * memory so zero out just enough for this struct, the
> +			 * rest will be zero'd on page fault.
>  			 */
> +			memset(addr, 0, sizeof(struct huge_bootmem_page));

This forced me to look at the usage of huge_bootmem_page.  It is defined as:
struct huge_bootmem_page {
	struct list_head list;
	struct hstate *hstate;
#ifdef CONFIG_HIGHMEM
	phys_addr_t phys;
#endif
};

The list and hstate fields are set immediately after allocating the memory
block here and elsewhere.  However, I can't find any code that sets phys.
Although, it is potentially used in gather_bootmem_prealloc().  It appears
powerpc used this field at one time, but no longer does.

Am I missing something?

Not an issue with this patch, rather existing code.  I'd prefer not to do
the memset() "just to be safe".  Unless I am missing something, I would
like to remove phys field and supporting code first.  Then, this patch
without the memset.

-- 
Mike Kravetz

>  			m = addr;
>  			goto found;
>  		}
> --
> 2.18.0.203.gfac676dfb9-goog
> 
