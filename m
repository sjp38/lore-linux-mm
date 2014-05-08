Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 038A56B00C3
	for <linux-mm@kvack.org>; Thu,  8 May 2014 01:26:58 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id y10so2020719pdj.4
        for <linux-mm@kvack.org>; Wed, 07 May 2014 22:26:58 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id xf3si14922195pab.138.2014.05.07.22.26.56
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 22:26:58 -0700 (PDT)
Date: Thu, 8 May 2014 14:28:46 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in
 isolate_freepages
Message-ID: <20140508052845.GB9161@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
 <1399464550-26447-1-git-send-email-vbabka@suse.cz>
 <1399464550-26447-2-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1399464550-26447-2-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Wed, May 07, 2014 at 02:09:10PM +0200, Vlastimil Babka wrote:
> The compaction free scanner in isolate_freepages() currently remembers PFN of
> the highest pageblock where it successfully isolates, to be used as the
> starting pageblock for the next invocation. The rationale behind this is that
> page migration might return free pages to the allocator when migration fails
> and we don't want to skip them if the compaction continues.
> 
> Since migration now returns free pages back to compaction code where they can
> be reused, this is no longer a concern. This patch changes isolate_freepages()
> so that the PFN for restarting is updated with each pageblock where isolation
> is attempted. Using stress-highalloc from mmtests, this resulted in 10%
> reduction of the pages scanned by the free scanner.

Hello,

Although this patch could reduce page scanned, it is possible to skip
scanning fresh pageblock. If there is zone lock contention and we are on
asyn compaction, we stop scanning this pageblock immediately. And
then, we will continue to scan next pageblock. With this patch,
next_free_pfn is updated in this case, so we never come back again to this
pageblock. Possibly this makes compaction success rate low, doesn't
it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
