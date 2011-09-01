Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 637856B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 10:20:32 -0400 (EDT)
Date: Thu, 1 Sep 2011 15:20:27 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 3/3] compaction accouting fix
Message-ID: <20110901142027.GI14369@suse.de>
References: <cover.1321112552.git.minchan.kim@gmail.com>
 <282a4531f23c5e35cfddf089f93559130b4bb660.1321112552.git.minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <282a4531f23c5e35cfddf089f93559130b4bb660.1321112552.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>

On Sun, Nov 13, 2011 at 01:37:43AM +0900, Minchan Kim wrote:
> I saw the following accouting of compaction during test of the series.

s/accouting/accounting/ both here and in the subject. A nicer name the
patch would have been

"mm: compaction: Only update compact_blocks_moved if compaction was successful"

> 
> compact_blocks_moved 251
> compact_pages_moved 44
> 
> It's very awkward to me although it's possbile because it means we try to compact 251 blocks
> but it just migrated 44 pages. As further investigation, I found isolate_migratepages doesn't
> isolate any pages but it returns ISOLATE_SUCCESS and then, it just increases compact_blocks_moved
> but doesn't increased compact_pages_moved.
> 
> This patch makes accouting of compaction works only in case of success of isolation.
> 

compact_blocks_moved exists to indicate the rate compaction is
scanning pageblocks. If compact_blocks_moved and compact_pages_moved
are increasing at a similar rate for example, it could imply that
compaction is doing a lot of scanning but is not necessarily useful
work. It's not necessarily reflected by compact_fail because that
counter is only updated for pages that were isolated from the LRU.

I now recognise of course that "compact_blocks_moved" was an *awful*
choice of name for this stat.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
