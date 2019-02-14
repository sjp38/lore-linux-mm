Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 81C03C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:33:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12BC22229F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 14:33:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12BC22229F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DE968E0002; Thu, 14 Feb 2019 09:33:23 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78F8B8E0001; Thu, 14 Feb 2019 09:33:23 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67E6C8E0002; Thu, 14 Feb 2019 09:33:23 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC9F88E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:33:22 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id y91so2566069edy.21
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 06:33:22 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=dgGEohDB4oz1F2sRFASbv26pYHzsnWxbEkxE6kn1Ujw=;
        b=gn6CMIIf8TCpPP1o+Zj0ipmqQ/ptpw3XWZn59nCuIwrA6DM0Xg3ep5H/9/6mKfkiK3
         pkQLGtBDp0CeNuyl7GZaXxuNAR0NspZkf4ea0AVFQaUEy4LP/olCU72ZN++h0K8HqHcX
         Q0qC1w6xURioU+WvagKlpA2Hbf1DxIki2mCCARJU/p1wCkGYKUIpBWzKq3h7dQAS2Kj0
         9DRVQRTIUIHXwmoIZf3FAKffJlWxcXEYSaLlvo+V8+Za1djjRxIDZ3WkX8D/S/osjyQv
         zfinMnYIf6bcQmtBl9XJL7uPC8jDh7pmzkr/JrlCyA5yUV6VRkTInv88uWqsNXcfa696
         HALA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuZW5mK50ydOBEkcQdqj895p3Rg++Wpfd8IKoD1aWEWFJpngW6s1
	npQx3oWUERCfLr7t3ELV1bLXa5jIg+eSHP+ZZzUrwbGv9vRci0BI5b5GrOgbh3APZR2CwlYpUCL
	4o/KWQiXtF4wX9LWOAYmdsreJNCf/3vn8ToGk6ZREPfscwu6IYtCSFaHFbiFTV20=
X-Received: by 2002:a05:6402:1482:: with SMTP id e2mr3247786edv.59.1550154802355;
        Thu, 14 Feb 2019 06:33:22 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9DOtKBFOxChi/o+beKuEuTQ3cxRspc83mW3/2ecJbAQaW+tKAFSNf3lp55nb9wsK83A58
X-Received: by 2002:a05:6402:1482:: with SMTP id e2mr3247693edv.59.1550154800953;
        Thu, 14 Feb 2019 06:33:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550154800; cv=none;
        d=google.com; s=arc-20160816;
        b=uNL2Ddu/xZzWlbyED7eErvcGMczo7wLGncN9eETMQey+eVNFr0EvefUB2pJd/W4r1w
         9KTOYFhrW6B5bHxsSV08znrwukIlbCQnEpugEFvNXNqLxBHeNcEvdARwbiJMJNI7cbmy
         BLXonvO3a43UWG1MfFVgL2SxseJZIecyLCsCWAgaSqPFfCJ9oEITKClODnJ57JjIHTFR
         penQ6OBEo81PDvK5PQnSbQqGHe1COpPp4xh7nrqDXTL0Og+QBkY0fu2+qp8LqN1cMfDb
         +3tBnh0vbaGtwIuBLzd4Xe2b7Nnzzbx+7sSAUaS0rHsi+QuxuT8l+gN+lZkpe490xbIC
         R3JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=dgGEohDB4oz1F2sRFASbv26pYHzsnWxbEkxE6kn1Ujw=;
        b=rRJKaNVuaUK/Ghl6BEeOuSV0ehpdApGwI9GAV0Lirjb7OLkfoVF/FJzs8M0dYtyMh7
         y7DyLWFxSQUZG4o59jpVr8V5ROT3UR404p4kGPF8Q+53hJwvUmuwHu8GPg+nHwO4ihub
         wyQTUGIoEgYXRGFKHFXmx2rqvMM5h45zL1BYGc4jX8LXPxnZztnbRoodOwUuXhrTSUER
         6Mmt/QkfLoWToTq/CRWnoFf3orDmEUhGyvXI7ft3E60i9z/bV5WtuGl+1qPeDsvIlaVp
         BSrIsPF/2YThW4I3n8cGC8P5QWJvcTvzSZxJZ1UAnnRofzHhm/N0c7esLTinszPAK8ex
         aNdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hk7si381972ejb.286.2019.02.14.06.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 06:33:20 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2506CB145;
	Thu, 14 Feb 2019 14:33:20 +0000 (UTC)
Date: Thu, 14 Feb 2019 15:33:18 +0100
From: Michal Hocko <mhocko@kernel.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V7] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190214143318.GJ4525@dhcp22.suse.cz>
References: <20190211083846.18888-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190211083846.18888-1-ying.huang@intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 11-02-19 16:38:46, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> When swapin is performed, after getting the swap entry information from
> the page table, system will swap in the swap entry, without any lock held
> to prevent the swap device from being swapoff.  This may cause the race
> like below,
> 
> CPU 1				CPU 2
> -----				-----
> 				do_swap_page
> 				  swapin_readahead
> 				    __read_swap_cache_async
> swapoff				      swapcache_prepare
>   p->swap_map = NULL		        __swap_duplicate
> 					  p->swap_map[?] /* !!! NULL pointer access */
> 
> Because swapoff is usually done when system shutdown only, the race may
> not hit many people in practice.  But it is still a race need to be fixed.
> 
> To fix the race, get_swap_device() is added to check whether the specified
> swap entry is valid in its swap device.  If so, it will keep the swap
> entry valid via preventing the swap device from being swapoff, until
> put_swap_device() is called.
> 
> Because swapoff() is very rare code path, to make the normal path runs as
> fast as possible, disabling preemption + stop_machine() instead of
> reference count is used to implement get/put_swap_device().  From
> get_swap_device() to put_swap_device(), the preemption is disabled, so
> stop_machine() in swapoff() will wait until put_swap_device() is called.
> 
> In addition to swap_map, cluster_info, etc.  data structure in the struct
> swap_info_struct, the swap cache radix tree will be freed after swapoff,
> so this patch fixes the race between swap cache looking up and swapoff
> too.
> 
> Races between some other swap cache usages protected via disabling
> preemption and swapoff are fixed too via calling stop_machine() between
> clearing PageSwapCache() and freeing swap cache data structure.
> 
> Alternative implementation could be replacing disable preemption with
> rcu_read_lock_sched and stop_machine() with synchronize_sched().

using stop_machine is generally discouraged. It is a gross
synchronization.

Besides that, since when do we have this problem?

> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> Not-Nacked-by: Hugh Dickins <hughd@google.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: Dave Jiang <dave.jiang@intel.com>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
> 
> Changelog:
> 
> v7:
> 
> - Rebased on patch: "mm, swap: bounds check swap_info accesses to avoid NULL derefs"
> 
> v6:
> 
> - Add more comments to get_swap_device() to make it more clear about
>   possible swapoff or swapoff+swapon.
> 
> v5:
> 
> - Replace RCU with stop_machine()
> 
> v4:
> 
> - Use synchronize_rcu() in enable_swap_info() to reduce overhead of
>   normal paths further.
> 
> v3:
> 
> - Re-implemented with RCU to reduce the overhead of normal paths
> 
> v2:
> 
> - Re-implemented with SRCU to reduce the overhead of normal paths.
> 
> - Avoid to check whether the swap device has been swapoff in
>   get_swap_device().  Because we can check the origin of the swap
>   entry to make sure the swap device hasn't bee swapoff.
> ---
>  include/linux/swap.h |  13 +++-
>  mm/memory.c          |   2 +-
>  mm/swap_state.c      |  16 ++++-
>  mm/swapfile.c        | 150 ++++++++++++++++++++++++++++++++++---------
>  4 files changed, 145 insertions(+), 36 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 649529be91f2..aecd1430d0a9 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -175,8 +175,9 @@ enum {
>  	SWP_PAGE_DISCARD = (1 << 10),	/* freed swap page-cluster discards */
>  	SWP_STABLE_WRITES = (1 << 11),	/* no overwrite PG_writeback pages */
>  	SWP_SYNCHRONOUS_IO = (1 << 12),	/* synchronous IO is efficient */
> +	SWP_VALID	= (1 << 13),	/* swap is valid to be operated on? */
>  					/* add others here before... */
> -	SWP_SCANNING	= (1 << 13),	/* refcount in scan_swap_map */
> +	SWP_SCANNING	= (1 << 14),	/* refcount in scan_swap_map */
>  };
>  
>  #define SWAP_CLUSTER_MAX 32UL
> @@ -460,7 +461,7 @@ extern unsigned int count_swap_pages(int, int);
>  extern sector_t map_swap_page(struct page *, struct block_device **);
>  extern sector_t swapdev_block(int, pgoff_t);
>  extern int page_swapcount(struct page *);
> -extern int __swap_count(struct swap_info_struct *si, swp_entry_t entry);
> +extern int __swap_count(swp_entry_t entry);
>  extern int __swp_swapcount(swp_entry_t entry);
>  extern int swp_swapcount(swp_entry_t entry);
>  extern struct swap_info_struct *page_swap_info(struct page *);
> @@ -470,6 +471,12 @@ extern int try_to_free_swap(struct page *);
>  struct backing_dev_info;
>  extern int init_swap_address_space(unsigned int type, unsigned long nr_pages);
>  extern void exit_swap_address_space(unsigned int type);
> +extern struct swap_info_struct *get_swap_device(swp_entry_t entry);
> +
> +static inline void put_swap_device(struct swap_info_struct *si)
> +{
> +	preempt_enable();
> +}
>  
>  #else /* CONFIG_SWAP */
>  
> @@ -576,7 +583,7 @@ static inline int page_swapcount(struct page *page)
>  	return 0;
>  }
>  
> -static inline int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
> +static inline int __swap_count(swp_entry_t entry)
>  {
>  	return 0;
>  }
> diff --git a/mm/memory.c b/mm/memory.c
> index 34ced1369883..9c0743c17c6c 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2719,7 +2719,7 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>  		struct swap_info_struct *si = swp_swap_info(entry);
>  
>  		if (si->flags & SWP_SYNCHRONOUS_IO &&
> -				__swap_count(si, entry) == 1) {
> +				__swap_count(entry) == 1) {
>  			/* skip swapcache */
>  			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
>  							vmf->address);
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 85245fdec8d9..61453f1faf72 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -310,8 +310,13 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>  			       unsigned long addr)
>  {
>  	struct page *page;
> +	struct swap_info_struct *si;
>  
> +	si = get_swap_device(entry);
> +	if (!si)
> +		return NULL;
>  	page = find_get_page(swap_address_space(entry), swp_offset(entry));
> +	put_swap_device(si);
>  
>  	INC_CACHE_INFO(find_total);
>  	if (page) {
> @@ -354,8 +359,8 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  			struct vm_area_struct *vma, unsigned long addr,
>  			bool *new_page_allocated)
>  {
> -	struct page *found_page, *new_page = NULL;
> -	struct address_space *swapper_space = swap_address_space(entry);
> +	struct page *found_page = NULL, *new_page = NULL;
> +	struct swap_info_struct *si;
>  	int err;
>  	*new_page_allocated = false;
>  
> @@ -365,7 +370,12 @@ struct page *__read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
>  		 * called after lookup_swap_cache() failed, re-calling
>  		 * that would confuse statistics.
>  		 */
> -		found_page = find_get_page(swapper_space, swp_offset(entry));
> +		si = get_swap_device(entry);
> +		if (!si)
> +			break;
> +		found_page = find_get_page(swap_address_space(entry),
> +					   swp_offset(entry));
> +		put_swap_device(si);
>  		if (found_page)
>  			break;
>  
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index cca8420b12db..8f92f36814fb 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -38,6 +38,7 @@
>  #include <linux/export.h>
>  #include <linux/swap_slots.h>
>  #include <linux/sort.h>
> +#include <linux/stop_machine.h>
>  
>  #include <asm/pgtable.h>
>  #include <asm/tlbflush.h>
> @@ -1186,6 +1187,64 @@ static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
>  	return usage;
>  }
>  
> +/*
> + * Check whether swap entry is valid in the swap device.  If so,
> + * return pointer to swap_info_struct, and keep the swap entry valid
> + * via preventing the swap device from being swapoff, until
> + * put_swap_device() is called.  Otherwise return NULL.
> + *
> + * Notice that swapoff or swapoff+swapon can still happen before the
> + * preempt_disable() in get_swap_device() or after the
> + * preempt_enable() in put_swap_device() if there isn't any other way
> + * to prevent swapoff, such as page lock, page table lock, etc.  The
> + * caller must be prepared for that.  For example, the following
> + * situation is possible.
> + *
> + *   CPU1				CPU2
> + *   do_swap_page()
> + *     ...				swapoff+swapon
> + *     __read_swap_cache_async()
> + *       swapcache_prepare()
> + *         __swap_duplicate()
> + *           // check swap_map
> + *     // verify PTE not changed
> + *
> + * In __swap_duplicate(), the swap_map need to be checked before
> + * changing partly because the specified swap entry may be for another
> + * swap device which has been swapoff.  And in do_swap_page(), after
> + * the page is read from the swap device, the PTE is verified not
> + * changed with the page table locked to check whether the swap device
> + * has been swapoff or swapoff+swapon.
> + */
> +struct swap_info_struct *get_swap_device(swp_entry_t entry)
> +{
> +	struct swap_info_struct *si;
> +	unsigned long type, offset;
> +
> +	if (!entry.val)
> +		goto out;
> +	type = swp_type(entry);
> +	si = swap_type_to_swap_info(type);
> +	if (!si)
> +		goto bad_nofile;
> +
> +	preempt_disable();
> +	if (!(si->flags & SWP_VALID))
> +		goto unlock_out;
> +	offset = swp_offset(entry);
> +	if (offset >= si->max)
> +		goto unlock_out;
> +
> +	return si;
> +bad_nofile:
> +	pr_err("%s: %s%08lx\n", __func__, Bad_file, entry.val);
> +out:
> +	return NULL;
> +unlock_out:
> +	preempt_enable();
> +	return NULL;
> +}
> +
>  static unsigned char __swap_entry_free(struct swap_info_struct *p,
>  				       swp_entry_t entry, unsigned char usage)
>  {
> @@ -1357,11 +1416,18 @@ int page_swapcount(struct page *page)
>  	return count;
>  }
>  
> -int __swap_count(struct swap_info_struct *si, swp_entry_t entry)
> +int __swap_count(swp_entry_t entry)
>  {
> +	struct swap_info_struct *si;
>  	pgoff_t offset = swp_offset(entry);
> +	int count = 0;
>  
> -	return swap_count(si->swap_map[offset]);
> +	si = get_swap_device(entry);
> +	if (si) {
> +		count = swap_count(si->swap_map[offset]);
> +		put_swap_device(si);
> +	}
> +	return count;
>  }
>  
>  static int swap_swapcount(struct swap_info_struct *si, swp_entry_t entry)
> @@ -1386,9 +1452,11 @@ int __swp_swapcount(swp_entry_t entry)
>  	int count = 0;
>  	struct swap_info_struct *si;
>  
> -	si = __swap_info_get(entry);
> -	if (si)
> +	si = get_swap_device(entry);
> +	if (si) {
>  		count = swap_swapcount(si, entry);
> +		put_swap_device(si);
> +	}
>  	return count;
>  }
>  
> @@ -2332,9 +2400,9 @@ static int swap_node(struct swap_info_struct *p)
>  	return bdev ? bdev->bd_disk->node_id : NUMA_NO_NODE;
>  }
>  
> -static void _enable_swap_info(struct swap_info_struct *p, int prio,
> -				unsigned char *swap_map,
> -				struct swap_cluster_info *cluster_info)
> +static void setup_swap_info(struct swap_info_struct *p, int prio,
> +			    unsigned char *swap_map,
> +			    struct swap_cluster_info *cluster_info)
>  {
>  	int i;
>  
> @@ -2359,7 +2427,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
>  	}
>  	p->swap_map = swap_map;
>  	p->cluster_info = cluster_info;
> -	p->flags |= SWP_WRITEOK;
> +}
> +
> +static void _enable_swap_info(struct swap_info_struct *p)
> +{
> +	p->flags |= SWP_WRITEOK | SWP_VALID;
>  	atomic_long_add(p->pages, &nr_swap_pages);
>  	total_swap_pages += p->pages;
>  
> @@ -2378,6 +2450,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
>  	add_to_avail_list(p);
>  }
>  
> +static int swap_onoff_stop(void *arg)
> +{
> +	return 0;
> +}
> +
>  static void enable_swap_info(struct swap_info_struct *p, int prio,
>  				unsigned char *swap_map,
>  				struct swap_cluster_info *cluster_info,
> @@ -2386,7 +2463,17 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
>  	frontswap_init(p->type, frontswap_map);
>  	spin_lock(&swap_lock);
>  	spin_lock(&p->lock);
> -	 _enable_swap_info(p, prio, swap_map, cluster_info);
> +	setup_swap_info(p, prio, swap_map, cluster_info);
> +	spin_unlock(&p->lock);
> +	spin_unlock(&swap_lock);
> +	/*
> +	 * Guarantee swap_map, cluster_info, etc. fields are used
> +	 * between get/put_swap_device() only if SWP_VALID bit is set
> +	 */
> +	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
> +	spin_lock(&swap_lock);
> +	spin_lock(&p->lock);
> +	_enable_swap_info(p);
>  	spin_unlock(&p->lock);
>  	spin_unlock(&swap_lock);
>  }
> @@ -2395,7 +2482,8 @@ static void reinsert_swap_info(struct swap_info_struct *p)
>  {
>  	spin_lock(&swap_lock);
>  	spin_lock(&p->lock);
> -	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info);
> +	setup_swap_info(p, p->prio, p->swap_map, p->cluster_info);
> +	_enable_swap_info(p);
>  	spin_unlock(&p->lock);
>  	spin_unlock(&swap_lock);
>  }
> @@ -2498,6 +2586,17 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
>  
>  	reenable_swap_slots_cache_unlock();
>  
> +	spin_lock(&swap_lock);
> +	spin_lock(&p->lock);
> +	p->flags &= ~SWP_VALID;		/* mark swap device as invalid */
> +	spin_unlock(&p->lock);
> +	spin_unlock(&swap_lock);
> +	/*
> +	 * wait for swap operations protected by get/put_swap_device()
> +	 * to complete
> +	 */
> +	stop_machine(swap_onoff_stop, NULL, cpu_online_mask);
> +
>  	flush_work(&p->discard_work);
>  
>  	destroy_swap_extents(p);
> @@ -3263,17 +3362,11 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>  	unsigned char has_cache;
>  	int err = -EINVAL;
>  
> -	if (non_swap_entry(entry))
> -		goto out;
> -
> -	p = swp_swap_info(entry);
> +	p = get_swap_device(entry);
>  	if (!p)
> -		goto bad_file;
> -
> -	offset = swp_offset(entry);
> -	if (unlikely(offset >= p->max))
>  		goto out;
>  
> +	offset = swp_offset(entry);
>  	ci = lock_cluster_or_swap_info(p, offset);
>  
>  	count = p->swap_map[offset];
> @@ -3319,11 +3412,9 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
>  unlock_out:
>  	unlock_cluster_or_swap_info(p, ci);
>  out:
> +	if (p)
> +		put_swap_device(p);
>  	return err;
> -
> -bad_file:
> -	pr_err("swap_dup: %s%08lx\n", Bad_file, entry.val);
> -	goto out;
>  }
>  
>  /*
> @@ -3415,6 +3506,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
>  	struct page *list_page;
>  	pgoff_t offset;
>  	unsigned char count;
> +	int ret = 0;
>  
>  	/*
>  	 * When debugging, it's easier to use __GFP_ZERO here; but it's better
> @@ -3422,15 +3514,15 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
>  	 */
>  	page = alloc_page(gfp_mask | __GFP_HIGHMEM);
>  
> -	si = swap_info_get(entry);
> +	si = get_swap_device(entry);
>  	if (!si) {
>  		/*
>  		 * An acceptable race has occurred since the failing
> -		 * __swap_duplicate(): the swap entry has been freed,
> -		 * perhaps even the whole swap_map cleared for swapoff.
> +		 * __swap_duplicate(): the swap device may be swapoff
>  		 */
>  		goto outer;
>  	}
> +	spin_lock(&si->lock);
>  
>  	offset = swp_offset(entry);
>  
> @@ -3448,9 +3540,8 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
>  	}
>  
>  	if (!page) {
> -		unlock_cluster(ci);
> -		spin_unlock(&si->lock);
> -		return -ENOMEM;
> +		ret = -ENOMEM;
> +		goto out;
>  	}
>  
>  	/*
> @@ -3502,10 +3593,11 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
>  out:
>  	unlock_cluster(ci);
>  	spin_unlock(&si->lock);
> +	put_swap_device(si);
>  outer:
>  	if (page)
>  		__free_page(page);
> -	return 0;
> +	return ret;
>  }
>  
>  /*
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

