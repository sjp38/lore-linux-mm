Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id EEFDF6B00E8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 01:10:16 -0400 (EDT)
Received: by pabru16 with SMTP id ru16so10033481pab.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 22:10:16 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id lj8si1715108pbc.11.2015.05.21.22.10.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 May 2015 22:10:16 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
Date: Fri, 22 May 2015 05:09:34 +0000
Message-ID: <20150522050934.GA24376@hori1.linux.bs1.fc.nec.co.jp>
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
In-Reply-To: <1432214842-22730-1-git-send-email-mhocko@suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <CCCFAEB1E21EAA45827647CA8F057533@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, May 21, 2015 at 03:27:22PM +0200, Michal Hocko wrote:
> hugetlb pages uses add_to_page_cache to track shared mappings. This
> is OK from the data structure point of view but it is less so from the
> NR_FILE_PAGES accounting:
> 	- huge pages are accounted as 4k which is clearly wrong
> 	- this counter is used as the amount of the reclaimable page
> 	  cache which is incorrect as well because hugetlb pages are
> 	  special and not reclaimable
> 	- the counter is then exported to userspace via /proc/meminfo
> 	  (in Cached:), /proc/vmstat and /proc/zoneinfo as
> 	  nr_file_pages which is confusing at least:
> 	  Cached:          8883504 kB
> 	  HugePages_Free:     8348
> 	  ...
> 	  Cached:          8916048 kB
> 	  HugePages_Free:      156
> 	  ...
> 	  thats 8192 huge pages allocated which is ~16G accounted as 32M
>=20
> There are usually not that many huge pages in the system for this to
> make any visible difference e.g. by fooling __vm_enough_memory or
> zone_pagecache_reclaimable.
>=20
> Fix this by special casing huge pages in both __delete_from_page_cache
> and __add_to_page_cache_locked. replace_page_cache_page is currently
> only used by fuse and that shouldn't touch hugetlb pages AFAICS but it
> is more robust to check for special casing there as well.
>=20
> Hugetlb pages shouldn't get to any other paths where we do accounting:
> 	- migration - we have a special handling via
> 	  hugetlbfs_migrate_page
> 	- shmem - doesn't handle hugetlb pages directly even for
> 	  SHM_HUGETLB resp. MAP_HUGETLB
> 	- swapcache - hugetlb is not swapable
>=20
> This has a user visible effect but I believe it is reasonable because
> the previously exported number is simply bogus.
>=20
> An alternative would be to account hugetlb pages with their real size
> and treat them similar to shmem. But this has some drawbacks.
>=20
> First we would have to special case in kernel users of NR_FILE_PAGES and
> considering how hugetlb is special we would have to do it everywhere. We
> do not want Cached exported by /proc/meminfo to include it because the
> value would be even more misleading.
> __vm_enough_memory and zone_pagecache_reclaimable would have to do
> the same thing because those pages are simply not reclaimable. The
> correction is even not trivial because we would have to consider all
> active hugetlb page sizes properly. Users of the counter outside of the
> kernel would have to do the same.
> So the question is why to account something that needs to be basically
> excluded for each reasonable usage. This doesn't make much sense to me.
>=20
> It seems that this has been broken since hugetlb was introduced but I
> haven't checked the whole history.
>=20
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

looks good to me,

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
