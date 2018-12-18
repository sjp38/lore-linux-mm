Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F1E838E0001
	for <linux-mm@kvack.org>; Tue, 18 Dec 2018 05:18:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id d41so11863219eda.12
        for <linux-mm@kvack.org>; Tue, 18 Dec 2018 02:18:38 -0800 (PST)
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id s37si5328575edb.340.2018.12.18.02.18.37
        for <linux-mm@kvack.org>;
        Tue, 18 Dec 2018 02:18:37 -0800 (PST)
Date: Tue, 18 Dec 2018 11:18:35 +0100
From: Oscar Salvador <osalvador@suse.de>
Subject: Re: [PATCH] mm: do not report isolation failures for CMA pages
Message-ID: <20181218101831.ma3j5llxcsthibop@d104.suse.de>
References: <20181218092802.31429-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181218092802.31429-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <OSalvador@suse.com>, Anshuman Khandual <anshuman.khandual@arm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 18, 2018 at 10:28:02AM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Heiko has complained that his log is swamped by warnings from has_unmovable_pages
> [   20.536664] page dumped because: has_unmovable_pages
> [   20.536792] page:000003d081ff4080 count:1 mapcount:0 mapping:000000008ff88600 index:0x0 compound_mapcount: 0
> [   20.536794] flags: 0x3fffe0000010200(slab|head)
> [   20.536795] raw: 03fffe0000010200 0000000000000100 0000000000000200 000000008ff88600
> [   20.536796] raw: 0000000000000000 0020004100000000 ffffffff00000001 0000000000000000
> [   20.536797] page dumped because: has_unmovable_pages
> [   20.536814] page:000003d0823b0000 count:1 mapcount:0 mapping:0000000000000000 index:0x0
> [   20.536815] flags: 0x7fffe0000000000()
> [   20.536817] raw: 07fffe0000000000 0000000000000100 0000000000000200 0000000000000000
> [   20.536818] raw: 0000000000000000 0000000000000000 ffffffff00000001 0000000000000000
> 
> which are not triggered by the memory hotplug but rather CMA allocator.
> The original idea behind dumping the page state for all call paths was
> that these messages will be helpful debugging failures. From the above
> it seems that this is not the case for the CMA path because we are
> lacking much more context. E.g the second reported page might be a CMA
> allocated page. It is still interesting to see a slab page in the CMA
> area but it is hard to tell whether this is bug from the above output
> alone.
> 
> Address this issue by dumping the page state only on request. Both
> start_isolate_page_range and has_unmovable_pages already have an
> argument to ignore hwpoison pages so make this argument more generic and
> turn it into flags and allow callers to combine non-default modes into a
> mask. While we are at it, has_unmovable_pages call from is_pageblock_removable_nolock
> (sysfs removable file) is questionable to report the failure so drop it
> from there as well.
> 
> Reported-by: Heiko Carstens <heiko.carstens@de.ibm.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me, and it makes sense to not spam other users.

Just one thing:

AFAICS alloc_contig_range() can also be called from hugetlb code.
Do we weant to specify that in the changelog too?
And possibly change the patch title to:

"Only report isolation failures from memhotplug code" ?

Although is_pageblock_removable_nolock will not report the failures
now, so I am not sure.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

-- 
Oscar Salvador
SUSE L3
