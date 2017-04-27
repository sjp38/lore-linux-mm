Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7247D6B02EE
	for <linux-mm@kvack.org>; Thu, 27 Apr 2017 09:37:24 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id n104so3099928wrb.20
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 06:37:24 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t17si3189568edf.304.2017.04.27.06.37.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 06:37:23 -0700 (PDT)
Date: Thu, 27 Apr 2017 09:37:09 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH -mm -v10 1/3] mm, THP, swap: Delay splitting THP during
 swap out
Message-ID: <20170427133709.GA13841@cmpxchg.org>
References: <20170425125658.28684-1-ying.huang@intel.com>
 <20170425125658.28684-2-ying.huang@intel.com>
 <20170427053141.GA1925@bbox>
 <87mvb21fz1.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mvb21fz1.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, cgroups@vger.kernel.org

On Thu, Apr 27, 2017 at 03:12:34PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> > On Tue, Apr 25, 2017 at 08:56:56PM +0800, Huang, Ying wrote:
> >> @@ -178,20 +192,12 @@ int add_to_swap(struct page *page, struct list_head *list)
> >>  	VM_BUG_ON_PAGE(!PageLocked(page), page);
> >>  	VM_BUG_ON_PAGE(!PageUptodate(page), page);
> >>  
> >> -	entry = get_swap_page();
> >> +retry:
> >> +	entry = get_swap_page(page);
> >>  	if (!entry.val)
> >> -		return 0;
> >> -
> >> -	if (mem_cgroup_try_charge_swap(page, entry)) {
> >> -		swapcache_free(entry);
> >> -		return 0;
> >> -	}
> >> -
> >> -	if (unlikely(PageTransHuge(page)))
> >> -		if (unlikely(split_huge_page_to_list(page, list))) {
> >> -			swapcache_free(entry);
> >> -			return 0;
> >> -		}
> >> +		goto fail;
> >
> > So, with non-SSD swap, THP page *always* get the fail to get swp_entry_t
> > and retry after split the page. However, it makes unncessary get_swap_pages
> > call which is not trivial. If there is no SSD swap, thp-swap out should
> > be void without adding any performance overhead.
> > Hmm, but I have no good idea to do it simple. :(
> 
> For HDD swap, the device raw throughput is so low (< 100M Bps
> typically), that the added overhead here will not be a big issue.  Do
> you agree?

I fully agree. If you swap to spinning rust, an extra function call
here is the least of your concern.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
