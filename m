Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0D1A76B0010
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 03:48:06 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id a22-v6so10953339eds.13
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 00:48:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u42-v6si3329661edm.404.2018.07.12.00.48.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 00:48:04 -0700 (PDT)
Date: Thu, 12 Jul 2018 09:48:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: hugetlb: don't zero 1GiB bootmem pages.
Message-ID: <20180712074803.GB32648@dhcp22.suse.cz>
References: <20180711213313.92481-1-cannonmatthews@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711213313.92481-1-cannonmatthews@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com

On Wed 11-07-18 14:33:13, Cannon Matthews wrote:
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

Thanks for the updated version.

Acked-by: Michal Hocko <mhocko@suse.com>

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

-- 
Michal Hocko
SUSE Labs
