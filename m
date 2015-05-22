Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 034B26B00EF
	for <linux-mm@kvack.org>; Fri, 22 May 2015 02:01:41 -0400 (EDT)
Received: by wghq2 with SMTP id q2so7575241wgh.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 23:01:40 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id ez10si991217wjd.4.2015.05.21.23.01.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 23:01:39 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so36256322wic.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 23:01:38 -0700 (PDT)
Date: Fri, 22 May 2015 08:01:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Message-ID: <20150522060136.GB5109@dhcp22.suse.cz>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
 <555E0573.3000009@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <555E0573.3000009@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 21-05-15 09:18:59, Mike Kravetz wrote:
> On 05/21/2015 06:27 AM, Michal Hocko wrote:
> >hugetlb pages uses add_to_page_cache to track shared mappings. This
> >is OK from the data structure point of view but it is less so from the
> >NR_FILE_PAGES accounting:
> >	- huge pages are accounted as 4k which is clearly wrong
> >	- this counter is used as the amount of the reclaimable page
> >	  cache which is incorrect as well because hugetlb pages are
> >	  special and not reclaimable
> >	- the counter is then exported to userspace via /proc/meminfo
> >	  (in Cached:), /proc/vmstat and /proc/zoneinfo as
> >	  nr_file_pages which is confusing at least:
> >	  Cached:          8883504 kB
> >	  HugePages_Free:     8348
> >	  ...
> >	  Cached:          8916048 kB
> >	  HugePages_Free:      156
> >	  ...
> >	  thats 8192 huge pages allocated which is ~16G accounted as 32M
> >
> >There are usually not that many huge pages in the system for this to
> >make any visible difference e.g. by fooling __vm_enough_memory or
> >zone_pagecache_reclaimable.
> >
> >Fix this by special casing huge pages in both __delete_from_page_cache
> >and __add_to_page_cache_locked. replace_page_cache_page is currently
> >only used by fuse and that shouldn't touch hugetlb pages AFAICS but it
> >is more robust to check for special casing there as well.
> >
> >Hugetlb pages shouldn't get to any other paths where we do accounting:
> >	- migration - we have a special handling via
> >	  hugetlbfs_migrate_page
> >	- shmem - doesn't handle hugetlb pages directly even for
> >	  SHM_HUGETLB resp. MAP_HUGETLB
> >	- swapcache - hugetlb is not swapable
> >
> >This has a user visible effect but I believe it is reasonable because
> >the previously exported number is simply bogus.
> >
> >An alternative would be to account hugetlb pages with their real size
> >and treat them similar to shmem. But this has some drawbacks.
> >
> >First we would have to special case in kernel users of NR_FILE_PAGES and
> >considering how hugetlb is special we would have to do it everywhere. We
> >do not want Cached exported by /proc/meminfo to include it because the
> >value would be even more misleading.
> >__vm_enough_memory and zone_pagecache_reclaimable would have to do
> >the same thing because those pages are simply not reclaimable. The
> >correction is even not trivial because we would have to consider all
> >active hugetlb page sizes properly. Users of the counter outside of the
> >kernel would have to do the same.
> >So the question is why to account something that needs to be basically
> >excluded for each reasonable usage. This doesn't make much sense to me.
> >
> >It seems that this has been broken since hugetlb was introduced but I
> >haven't checked the whole history.
> >
> >Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Just for grins, I added this to my hugetlbfs fallocate stress testing
> which really exercises hugetlb add and delete from page cache.
> Everything is as expected.
> 
> Tested-by: Mike Kravetz <mike.kravetz@oracle.com>

Thanks for your testing!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
