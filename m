Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3DB6B0270
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:47:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x5-v6so9542924edh.8
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:47:21 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m12-v6si1022184edq.379.2018.07.11.05.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 05:47:20 -0700 (PDT)
Date: Wed, 11 Jul 2018 14:47:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: hugetlb: don't zero 1GiB bootmem pages.
Message-ID: <20180711124711.GA20172@dhcp22.suse.cz>
References: <20180710184903.68239-1-cannonmatthews@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180710184903.68239-1-cannonmatthews@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cannon Matthews <cannonmatthews@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, andreslc@google.com, pfeiner@google.com, dmatlack@google.com, gthelen@google.com

On Tue 10-07-18 11:49:03, Cannon Matthews wrote:
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

The patch makes perfect sense to me. I wasn't even aware that it
zeroying memblock allocation. Thanks for spotting this and fixing it.

> Signed-off-by: Cannon Matthews <cannonmatthews@google.com>

I just do not think we need to to zero huge_bootmem_page portion of it.
It should be sufficient to INIT_LIST_HEAD before list_add. We do
initialize the rest explicitly already.

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
>  			m = addr;
>  			goto found;
>  		}
> --
> 2.18.0.203.gfac676dfb9-goog

-- 
Michal Hocko
SUSE Labs
