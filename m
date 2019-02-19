Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE21DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 22:40:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4DD632147A
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 22:40:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amarulasolutions.com header.i=@amarulasolutions.com header.b="n0IDXJLK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4DD632147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=amarulasolutions.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6DCE8E0003; Tue, 19 Feb 2019 17:40:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D476A8E0002; Tue, 19 Feb 2019 17:40:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C33488E0003; Tue, 19 Feb 2019 17:40:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5A0168E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 17:40:58 -0500 (EST)
Received: by mail-wr1-f70.google.com with SMTP id m7so9738542wrn.15
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 14:40:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=oYrZRH7vmI0qzivYIlXDqOjRqLiHNfBbq7RJC/89DBQ=;
        b=fYnTlnC7rrNKDTeLxeuejy6TMoyr9j5WBk2yIhuCCDyR7B51Ff+x4xin9NEhh9WneG
         MyinNHkqXePVHsMHNScGpbAJXH+keuAcVq9m07ApCMPhqE5kaN8tEvwnN6JDjyhXyJmv
         MkPBgJlcsFkjCreSK6eLC9CBBrS0X0v5dNv5u3uNsDEihtWo/KqsP4ao7nXMbgP/eRyz
         CSpESBuwLT+IVbuTzonfJFOfJKF1dqtu/nX+TE7siO3haVQHRJq/C8lws+DKROr9m45a
         3E/vXCqchxCk2u1GDG5N001d2RReFlgTz7SbqUX+bOA01dnPFf2Riutr46tYbCwIijbH
         CJHw==
X-Gm-Message-State: AHQUAuYv8kUfmn64uLqdRfQYZ61nfLiNLvA7IuhcWVZW69w+yzLil6HR
	2f+CL89k+owEA17b+BpSsWtuyL+u7uIdUriHcEX+HeZjdRAePbVk/Ur2X15K3igdOhm7MVTMppX
	WPWTBq4l+TjaL4AnYZZKzDw48oQkjYOMPrM0qm6eXFb6VlfuNsaQ+0F1pLX6T27sz6F+Nj3NGom
	AxKsYkT8JrAL948WwkfuQ6TdO+Z0uPdyVTsvp7TsdGkdVSSjhLB3ySn19kmfcmZZxdx5TWrVw/3
	nFDW3Bq/zsjfwfem456d3FHgFIVeQCgYlzFMLjDh6WTjv8CLC3J8IrRJ+5KfukRiHYm22+y8U9b
	2upOcaxwC+91Net7BGxRieXBZPlH7mv1y8VmeQtKoEy+34pIUzWT9ltVQedgJDVZlpvwSGMka84
	4
X-Received: by 2002:a5d:668b:: with SMTP id l11mr21659439wru.116.1550616057837;
        Tue, 19 Feb 2019 14:40:57 -0800 (PST)
X-Received: by 2002:a5d:668b:: with SMTP id l11mr21659395wru.116.1550616056387;
        Tue, 19 Feb 2019 14:40:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550616056; cv=none;
        d=google.com; s=arc-20160816;
        b=wPIytIu2fqAXshLLZASARncMv+Y0hFbwm3Ji4HdzylQ9TPTbPDjuKDXPuQG4ZxeWhC
         aTPQ2LlvUVwD9Bi+Ab9wbgyygpK+y6YzIL5BoGfdvtydBB7yujDiQtAHhBXI5h0gnmLF
         5SAqhI6+eHd+dLZRfE5mRictgskAEMQj0IkKAKL/gCmzpDDlhyWrGYDaGXAsOQrozvM8
         fTdUKaem9SNacgf784wh+HsbFswqeniha8A5PK44rBNVv9Dprg0Fn9xCnVKaU3mH6u8y
         ICesQOiPIktsVObqTYF2d50tyADCkUCIaxxZgyA3o5kypsE+aDlFZc16g4O0GVfFAP2J
         hNTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=oYrZRH7vmI0qzivYIlXDqOjRqLiHNfBbq7RJC/89DBQ=;
        b=xOGibc45uakgW1giK7k6+rBDP8DPfFtnetZrxazILgZX3GovH6CRlsU5yh5b9YXgN2
         0cgt4Ausj/HYethxCgXfG2z/S3NyGeKO2i0ANcF0GP3WenHgiSFvQ4tKit1B6vx+0LtW
         0lTWY4jtUsJrJ1/GU6QPQMFazg7qpVj7K2fXh4FIicQT/MiwlvB0HuVVCQ3aWnJ9KNwH
         6hhi6Ryunf+cFuLNLzoa8UxHGCU434ea6rRi3+i6YLi8l3VVCOKJ42BX6VBAGUYiLFEE
         /yEWyvtB8mGAPgW8eWoRDGxl1VofP8qJPu8NXBqZCbksJwF0VFN3gCD3vznXXDwTlmZj
         oLiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=n0IDXJLK;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d4sor2527718wmf.22.2019.02.19.14.40.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Feb 2019 14:40:56 -0800 (PST)
Received-SPF: pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amarulasolutions.com header.s=google header.b=n0IDXJLK;
       spf=pass (google.com: domain of andrea.parri@amarulasolutions.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andrea.parri@amarulasolutions.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=amarulasolutions.com; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=oYrZRH7vmI0qzivYIlXDqOjRqLiHNfBbq7RJC/89DBQ=;
        b=n0IDXJLKEdhZXu5EHNKrdIoJO22oA9tijO3Aiy1R0Jtyuxy1fGl3dK9JJNebTgld9j
         C6qWj0Wo3ooqk9EX5X8OY3RDXhZypXVCkEOZiHAwjSvCAesTXFfUB+HxtrfR3amiZt7s
         GqlaTtu/M1FppfhuLRCv3NjR+SU6pG2SURdWs=
X-Google-Smtp-Source: AHgI3Iagz7S1ugpWM7JilxPV18h7OIhH/EJmdH7CcS+wmHdBoMw44PebHxqqP9J9wsrVQjZdvGIGag==
X-Received: by 2002:a1c:ca01:: with SMTP id a1mr4630352wmg.143.1550616055515;
        Tue, 19 Feb 2019 14:40:55 -0800 (PST)
Received: from andrea ([89.22.71.151])
        by smtp.gmail.com with ESMTPSA id x6sm5903541wmg.0.2019.02.19.14.40.51
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 14:40:54 -0800 (PST)
Date: Tue, 19 Feb 2019 23:40:46 +0100
From: Andrea Parri <andrea.parri@amarulasolutions.com>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	"Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
	Minchan Kim <minchan@kernel.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Chen <tim.c.chen@linux.intel.com>,
	Mel Gorman <mgorman@techsingularity.net>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>,
	Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm -V8] mm, swap: fix race between swapoff and some swap
 operations
Message-ID: <20190219224046.GA2759@andrea>
References: <20190218070142.5105-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190218070142.5105-1-ying.huang@intel.com>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 03:01:42PM +0800, Huang, Ying wrote:
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

Reviewed-by: Andrea Parri <andrea.parri@amarulasolutions.com>

  Andrea


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
> -- 
> 2.20.1
> 

