Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2F4CE829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 10:36:04 -0400 (EDT)
Received: by wibt6 with SMTP id t6so49432086wib.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:36:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cy4si447964wjb.76.2015.05.22.07.36.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 May 2015 07:36:02 -0700 (PDT)
Date: Fri, 22 May 2015 15:35:58 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Message-ID: <20150522143558.GA2462@suse.de>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
 <20150521170909.GA12800@cmpxchg.org>
 <20150522142143.GF5109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150522142143.GF5109@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, May 22, 2015 at 04:21:43PM +0200, Michal Hocko wrote:
> On Thu 21-05-15 13:09:09, Johannes Weiner wrote:
> > On Thu, May 21, 2015 at 03:27:22PM +0200, Michal Hocko wrote:
> > > hugetlb pages uses add_to_page_cache to track shared mappings. This
> > > is OK from the data structure point of view but it is less so from the
> > > NR_FILE_PAGES accounting:
> > > 	- huge pages are accounted as 4k which is clearly wrong
> > > 	- this counter is used as the amount of the reclaimable page
> > > 	  cache which is incorrect as well because hugetlb pages are
> > > 	  special and not reclaimable
> > > 	- the counter is then exported to userspace via /proc/meminfo
> > > 	  (in Cached:), /proc/vmstat and /proc/zoneinfo as
> > > 	  nr_file_pages which is confusing at least:
> > > 	  Cached:          8883504 kB
> > > 	  HugePages_Free:     8348
> > > 	  ...
> > > 	  Cached:          8916048 kB
> > > 	  HugePages_Free:      156
> > > 	  ...
> > > 	  thats 8192 huge pages allocated which is ~16G accounted as 32M
> > > 
> > > There are usually not that many huge pages in the system for this to
> > > make any visible difference e.g. by fooling __vm_enough_memory or
> > > zone_pagecache_reclaimable.
> > > 
> > > Fix this by special casing huge pages in both __delete_from_page_cache
> > > and __add_to_page_cache_locked. replace_page_cache_page is currently
> > > only used by fuse and that shouldn't touch hugetlb pages AFAICS but it
> > > is more robust to check for special casing there as well.
> > > 
> > > Hugetlb pages shouldn't get to any other paths where we do accounting:
> > > 	- migration - we have a special handling via
> > > 	  hugetlbfs_migrate_page
> > > 	- shmem - doesn't handle hugetlb pages directly even for
> > > 	  SHM_HUGETLB resp. MAP_HUGETLB
> > > 	- swapcache - hugetlb is not swapable
> > > 
> > > This has a user visible effect but I believe it is reasonable because
> > > the previously exported number is simply bogus.
> > > 
> > > An alternative would be to account hugetlb pages with their real size
> > > and treat them similar to shmem. But this has some drawbacks.
> > > 
> > > First we would have to special case in kernel users of NR_FILE_PAGES and
> > > considering how hugetlb is special we would have to do it everywhere. We
> > > do not want Cached exported by /proc/meminfo to include it because the
> > > value would be even more misleading.
> > > __vm_enough_memory and zone_pagecache_reclaimable would have to do
> > > the same thing because those pages are simply not reclaimable. The
> > > correction is even not trivial because we would have to consider all
> > > active hugetlb page sizes properly. Users of the counter outside of the
> > > kernel would have to do the same.
> > > So the question is why to account something that needs to be basically
> > > excluded for each reasonable usage. This doesn't make much sense to me.
> > > 
> > > It seems that this has been broken since hugetlb was introduced but I
> > > haven't checked the whole history.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> > 
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Thanks!
> 
> > This makes a lot of sense to me.  The only thing I worry about is the
> > proliferation of PageHuge(), a function call, in relatively hot paths.
> 
> I've tried that (see the patch below) but it enlarged the code by almost
> 1k
>    text    data     bss     dec     hex filename
>  510323   74273   44440  629036   9992c mm/built-in.o.before
>  511248   74273   44440  629961   99cc9 mm/built-in.o.after
> 
> I am not sure the code size increase is worth it. Maybe we can reduce
> the check to only PageCompound(page) as huge pages are no in the page
> cache (yet).
> 

That would be a more sensible route because it also avoids exposing the
hugetlbfs destructor unnecessarily.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
