Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 590256B0269
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 17:57:04 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id j4-v6so11463623vke.12
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 14:57:04 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 201-v6si3881705vkl.149.2018.07.11.14.57.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 14:57:03 -0700 (PDT)
Subject: Re: [PATCH v2] mm: hugetlb: don't zero 1GiB bootmem pages.
References: <20180711213313.92481-1-cannonmatthews@google.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <e04f64c8-37d3-bf81-29d2-c495844dd3a5@oracle.com>
Date: Wed, 11 Jul 2018 14:56:54 -0700
MIME-Version: 1.0
In-Reply-To: <20180711213313.92481-1-cannonmatthews@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>, Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com, mhocko@kernel.org

On 07/11/2018 02:33 PM, Cannon Matthews wrote:
> When using 1GiB pages during early boot, use the new
> memblock_virt_alloc_try_nid_raw() function to allocate memory without
> zeroing it.  Zeroing out hundreds or thousands of GiB in a single core
> memset() call is very slow, and can make early boot last upwards of
> 20-30 minutes on multi TiB machines.
> 
> The memory does not need to be zero'd as the hugetlb pages are always
> zero'd on page fault.
> 
> Tested: Booted with ~3800 1G pages, and it booted successfully in
> roughly the same amount of time as with 0, as opposed to the 25+
> minutes it would take before.
> 
> Signed-off-by: Cannon Matthews <cannonmatthews@google.com>

Thanks,

Acked-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

> ---
> v2: removed the memset of the huge_bootmem_page area and added
> INIT_LIST_HEAD instead.
> 
>  mm/hugetlb.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 3612fbb32e9d..488330f23f04 100644
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
> @@ -2119,6 +2119,7 @@ int __alloc_bootmem_huge_page(struct hstate *h)
>  found:
>  	BUG_ON(!IS_ALIGNED(virt_to_phys(m), huge_page_size(h)));
>  	/* Put them into a private list first because mem_map is not up yet */
> +	INIT_LIST_HEAD(&m->list);
>  	list_add(&m->list, &huge_boot_pages);
>  	m->hstate = h;
>  	return 1;
> --
> 2.18.0.203.gfac676dfb9-goog
> 
