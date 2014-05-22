Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id E41116B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 05:24:27 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id b57so2448533eek.27
        for <linux-mm@kvack.org>; Thu, 22 May 2014 02:24:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w45si14085213eex.140.2014.05.22.02.24.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 22 May 2014 02:24:26 -0700 (PDT)
Message-ID: <537DC247.5020801@suse.cz>
Date: Thu, 22 May 2014 11:24:23 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 09/19] mm: page_alloc: Use word-based accesses for get/set
 pageblock bitmaps
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-10-git-send-email-mgorman@suse.de>
In-Reply-To: <1399974350-11089-10-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On 05/13/2014 11:45 AM, Mel Gorman wrote:
> The test_bit operations in get/set pageblock flags are expensive. This patch
> reads the bitmap on a word basis and use shifts and masks to isolate the bits
> of interest. Similarly masks are used to set a local copy of the bitmap and then
> use cmpxchg to update the bitmap if there have been no other changes made in
> parallel.
> 
> In a test running dd onto tmpfs the overhead of the pageblock-related
> functions went from 1.27% in profiles to 0.5%.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Hi, I've tested if this closes the race I've been previously trying to fix
with the series in http://marc.info/?l=linux-mm&m=139359694028925&w=2
And indeed with this patch I wasn't able to reproduce it in my stress test
(which adds lots of memory isolation calls) anymore. So thanks to Mel I can
dump my series in the trashcan :P

Therefore I believe something like below should be added to the changelog,
and put to stable as well.

Thanks,
Vlastimil

-----8<-----
In addition to the performance benefits, this patch closes races that are
possible between:

a) get_ and set_pageblock_migratetype(), where get_pageblock_migratetype()
   reads part of the bits before and other part of the bits after
   set_pageblock_migratetype() has updated them.

b) set_pageblock_migratetype() and set_pageblock_skip(), where the non-atomic
   read-modify-update set bit operation in set_pageblock_skip() will cause
   lost updates to some bits changed in the set_pageblock_migratetype().

Joonsoo Kim first reported the case a) via code inspection. Vlastimil Babka's
testing with a debug patch showed that either a) or b) occurs roughly once per
mmtests' stress-highalloc benchmark (although not necessarily in the same
pageblock). Furthermore during development of unrelated compaction patches,
it was observed that frequent calls to {start,undo}_isolate_page_range() the
race occurs several thousands of times and has resulted in NULL pointer
dereferences in move_freepages() and free_one_page() in places where
free_list[migratetype] is manipulated by e.g. list_move(). Further debugging
confirmed that migratetype had invalid value of 6, causing out of bounds access
to the free_list array. 

That confirmed that the race exist, although it may be extremely rare, and
currently only fatal where page isolation is performed due to memory hot remove.
Races on pageblocks being updated by set_pageblock_migratetype(), where both
old and new migratetype are lower MIGRATE_RESERVE, currently cannot result in an
invalid value being observed, although theoretically they may still lead to
unexpected creation or destruction of MIGRATE_RESERVE pageblocks. Furthermore,
things could get suddenly worse when memory isolation is used more, or when new
migratetypes are added.

After this patch, the race has no longer been observed in testing.

Reported-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Reported-and-tested-by: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
