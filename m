Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EF1DC10F0B
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:49:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2EA620684
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 06:49:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2EA620684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5282A8E0003; Tue, 26 Feb 2019 01:49:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4D9018E0002; Tue, 26 Feb 2019 01:49:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3C7C78E0003; Tue, 26 Feb 2019 01:49:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E28E68E0002
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 01:49:11 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id k10so9785777pfi.5
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 22:49:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version:content-transfer-encoding;
        bh=TREPXbHUIJP1ya86Erf88SaPjpxZDAB6xa3+6w6uDTM=;
        b=GnMgalwmEI23L7e2aPdDw0FBHlpwxP/9kvAGSRB5rwNXFDuElJEm+8Ed3kMQfG6eQR
         ClfcLLKoZufQgjHBdvBOwL6MucgyNKsX6+1EEIrzbug0x3vZbcz7/qmsDuyco+E6NW1c
         U1u6hIWirqcCOrDhTPp5+hv4XPrachHXQ/Qyuw715IHK06C1c8etelyCZAl0ytnVz8lm
         ceSVfOJ2qzi1kPCn5Q0r8LVePlMIkHCQ0KK1pax/QebrXDaN9kr+LxBmZCt/c1yH9Iad
         jrqlHb/gJn8r1O1kyXXS+5ImPleX79GVY2La3s9BYUhQpd/k/ly2WrxdYkVFNqltkRxX
         tsmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAua0dT2+X2niY6lizBjGw5qYoylEaC+bedph6YkLBjtavEs+BOCm
	SDB6nNMD+21tkLBMtfF/LXAy6UWDIBSWOetUcWjNajAWxPGqslp+jWdgl55HZoumOfFZJDrb/Vt
	JoB1v/nOi6ygF+QgwygKw0YaLfRx4WOFf9d+hdCmIoZnsyo0Oo8s+dXNEIh2IrsvxRA==
X-Received: by 2002:a63:6bc1:: with SMTP id g184mr19378302pgc.25.1551163751522;
        Mon, 25 Feb 2019 22:49:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbCEzZt6yjcY2KdJI6dNJMgbbcBlXz5GNRlcbPb6qOaxdHo+D5JPgjOab/04e4PQf45abva
X-Received: by 2002:a63:6bc1:: with SMTP id g184mr19378238pgc.25.1551163750164;
        Mon, 25 Feb 2019 22:49:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551163750; cv=none;
        d=google.com; s=arc-20160816;
        b=i3Emz0DuCwErQEvbXUCOOOMyjRAeU0Wzb29gi0adY7PWDdgW09oyb/gamK71DuC3Jt
         fPYsMQFgckRsAyI4PqaXRJq/0cJxNaD8xHV2H3aJhrv+IscOfjX92Fb1ncffr6YmVlFR
         xEiQ2uYA2146giCzCUpM8D5MXbHip54b8/3HHcyWmhudNAugwZAkJuWWN0MFwZ23KecL
         3oPOt/lMaoYKw97BgyPFqZbUJimOOhTqoIbkMAuYKo3ty/n157LrwDqInIP9sJKko00G
         9sDvRZ4Re+HZVVQTfNhnXU+nbHaZOZkY13tMkCNfy+RelyhJ8EYDnMOcSsV9VoHI1olf
         SA8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id
         :in-reply-to:date:references:subject:cc:cc:to:from;
        bh=TREPXbHUIJP1ya86Erf88SaPjpxZDAB6xa3+6w6uDTM=;
        b=O/OD17E9VBvgKeRcCmaj3Mju073wlr9aybJrdsvpq0zONPpLvFQVc3mHhGqDmIfVOI
         5pZ5TAOebdAPjc3Kizm/KixU2rWsVhs1CfE4pj5sAJjBLG/2Xyu75TJEwL4+eUM//a5C
         4JMa4FzEJx3LCJQlyUqsPqAkXe2XcXhsxoZmA6Q8PijfD2orRh+YXnrrv59qKIh9KVdU
         Ym0MrsGAYzbZnHxEGCWR4/wSYHCVe12eos6hdFgqmGfm/eKywVOYWqsfda2jA7j/i0YA
         pGqMrcfG4ZdfZcJR8kaVcjc8wk9sQL/FvhIuQIPqkDQNFf4OowSBxXy8aTSgWGOmoa1y
         5m/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id l94si12087942plb.209.2019.02.25.22.49.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 22:49:10 -0800 (PST)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Feb 2019 22:49:09 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,414,1544515200"; 
   d="scan'208";a="146574445"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.151])
  by fmsmga002.fm.intel.com with ESMTP; 25 Feb 2019 22:49:05 -0800
From: "Huang\, Ying" <ying.huang@intel.com>
To: Daniel Jordan <daniel.m.jordan@oracle.com>,  Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Hugh Dickins
 <hughd@google.com>,  "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
  Minchan Kim <minchan@kernel.org>,  "Johannes Weiner"
 <hannes@cmpxchg.org>,  Tim Chen <tim.c.chen@linux.intel.com>,  "Mel
 Gorman" <mgorman@techsingularity.net>,  =?utf-8?B?SsOpcsO0bWU=?= Glisse
 <jglisse@redhat.com>,  Michal Hocko <mhocko@suse.com>,  David Rientjes
 <rientjes@google.com>,  Rik van Riel <riel@redhat.com>,  Jan Kara
 <jack@suse.cz>,  Dave Jiang <dave.jiang@intel.com>,  Aaron Lu
 <aaron.lu@intel.com>,  Andrea Parri <andrea.parri@amarulasolutions.com>
Subject: Re: [PATCH -mm -V8] mm, swap: fix race between swapoff and some swap operations
References: <20190218070142.5105-1-ying.huang@intel.com>
Date: Tue, 26 Feb 2019 14:49:05 +0800
In-Reply-To: <20190218070142.5105-1-ying.huang@intel.com> (Ying Huang's
	message of "Mon, 18 Feb 2019 15:01:42 +0800")
Message-ID: <87mumjt57i.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Daniel and Andrea,

"Huang, Ying" <ying.huang@intel.com> writes:

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
> Because swapoff() is very rare code path, to make the normal path runs
> as fast as possible, rcu_read_lock/unlock() and synchronize_rcu()
> instead of reference count is used to implement get/put_swap_device().
> From get_swap_device() to put_swap_device(), RCU reader side is
> locked, so synchronize_rcu() in swapoff() will wait until
> put_swap_device() is called.
>
> In addition to swap_map, cluster_info, etc. data structure in the struct
> swap_info_struct, the swap cache radix tree will be freed after swapoff,
> so this patch fixes the race between swap cache looking up and swapoff
> too.
>
> Races between some other swap cache usages and swapoff are fixed too
> via calling synchronize_rcu() between clearing PageSwapCache() and
> freeing swap cache data structure.
>
> Fixes: 235b62176712 ("mm/swap: add cluster lock")
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
> Cc: Aaron Lu <aaron.lu@intel.com>
> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
> Cc: Andrea Parri <andrea.parri@amarulasolutions.com>
>
> Changelog:
>
> v8:
>
> - Use swp_swap_info() to cleanup the code per Daniel's comments
>
> - Use rcu_read_lock/unlock and synchronize_rcu() per Andrea
>   Arcangeli's comments
>
> - Added Fixes tag per Michal Hocko's comments

Do you have time to take a look at this patch?

Best Regards,
Huang, Ying

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
>  mm/swapfile.c        | 148 +++++++++++++++++++++++++++++++++----------
>  4 files changed, 140 insertions(+), 39 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 649529be91f2..f2ddaf299e15 100644
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
> +	rcu_read_unlock();
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
> index cca8420b12db..8ec80209a726 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -1078,12 +1078,11 @@ swp_entry_t get_swap_page_of_type(int type)
>  static struct swap_info_struct *__swap_info_get(swp_entry_t entry)
>  {
>  	struct swap_info_struct *p;
> -	unsigned long offset, type;
> +	unsigned long offset;
>  
>  	if (!entry.val)
>  		goto out;
> -	type = swp_type(entry);
> -	p = swap_type_to_swap_info(type);
> +	p = swp_swap_info(entry);
>  	if (!p)
>  		goto bad_nofile;
>  	if (!(p->flags & SWP_USED))
> @@ -1186,6 +1185,63 @@ static unsigned char __swap_entry_free_locked(struct swap_info_struct *p,
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
> + * rcu_read_lock() in get_swap_device() or after the rcu_read_unlock()
> + * in put_swap_device() if there isn't any other way to prevent
> + * swapoff, such as page lock, page table lock, etc.  The caller must
> + * be prepared for that.  For example, the following situation is
> + * possible.
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
> +	unsigned long offset;
> +
> +	if (!entry.val)
> +		goto out;
> +	si = swp_swap_info(entry);
> +	if (!si)
> +		goto bad_nofile;
> +
> +	rcu_read_lock();
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
> +	rcu_read_unlock();
> +	return NULL;
> +}
> +
>  static unsigned char __swap_entry_free(struct swap_info_struct *p,
>  				       swp_entry_t entry, unsigned char usage)
>  {
> @@ -1357,11 +1413,18 @@ int page_swapcount(struct page *page)
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
> @@ -1386,9 +1449,11 @@ int __swp_swapcount(swp_entry_t entry)
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
> @@ -2332,9 +2397,9 @@ static int swap_node(struct swap_info_struct *p)
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
> @@ -2359,7 +2424,11 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
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
> @@ -2386,7 +2455,17 @@ static void enable_swap_info(struct swap_info_struct *p, int prio,
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
> +	synchronize_rcu();
> +	spin_lock(&swap_lock);
> +	spin_lock(&p->lock);
> +	_enable_swap_info(p);
>  	spin_unlock(&p->lock);
>  	spin_unlock(&swap_lock);
>  }
> @@ -2395,7 +2474,8 @@ static void reinsert_swap_info(struct swap_info_struct *p)
>  {
>  	spin_lock(&swap_lock);
>  	spin_lock(&p->lock);
> -	_enable_swap_info(p, p->prio, p->swap_map, p->cluster_info);
> +	setup_swap_info(p, p->prio, p->swap_map, p->cluster_info);
> +	_enable_swap_info(p);
>  	spin_unlock(&p->lock);
>  	spin_unlock(&swap_lock);
>  }
> @@ -2498,6 +2578,17 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
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
> +	synchronize_rcu();
> +
>  	flush_work(&p->discard_work);
>  
>  	destroy_swap_extents(p);
> @@ -3263,17 +3354,11 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
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
> @@ -3319,11 +3404,9 @@ static int __swap_duplicate(swp_entry_t entry, unsigned char usage)
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
> @@ -3415,6 +3498,7 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
>  	struct page *list_page;
>  	pgoff_t offset;
>  	unsigned char count;
> +	int ret = 0;
>  
>  	/*
>  	 * When debugging, it's easier to use __GFP_ZERO here; but it's better
> @@ -3422,15 +3506,15 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
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
> @@ -3448,9 +3532,8 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
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
> @@ -3502,10 +3585,11 @@ int add_swap_count_continuation(swp_entry_t entry, gfp_t gfp_mask)
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

