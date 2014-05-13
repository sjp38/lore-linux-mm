Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7DCE76B0055
	for <linux-mm@kvack.org>; Mon, 12 May 2014 21:13:52 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id fa1so5378324pad.39
        for <linux-mm@kvack.org>; Mon, 12 May 2014 18:13:52 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id hk10si11583079pac.55.2014.05.12.18.13.50
        for <linux-mm@kvack.org>;
        Mon, 12 May 2014 18:13:51 -0700 (PDT)
Date: Tue, 13 May 2014 10:15:55 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/2] mm/compaction: avoid rescanning pageblocks in
 isolate_freepages
Message-ID: <20140513011555.GC23803@js1304-P5Q-DELUXE>
References: <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
 <1399464550-26447-1-git-send-email-vbabka@suse.cz>
 <1399464550-26447-2-git-send-email-vbabka@suse.cz>
 <20140508052845.GB9161@js1304-P5Q-DELUXE>
 <53708FC5.4000100@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53708FC5.4000100@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Mon, May 12, 2014 at 11:09:25AM +0200, Vlastimil Babka wrote:
> On 05/08/2014 07:28 AM, Joonsoo Kim wrote:
> >On Wed, May 07, 2014 at 02:09:10PM +0200, Vlastimil Babka wrote:
> >>The compaction free scanner in isolate_freepages() currently remembers PFN of
> >>the highest pageblock where it successfully isolates, to be used as the
> >>starting pageblock for the next invocation. The rationale behind this is that
> >>page migration might return free pages to the allocator when migration fails
> >>and we don't want to skip them if the compaction continues.
> >>
> >>Since migration now returns free pages back to compaction code where they can
> >>be reused, this is no longer a concern. This patch changes isolate_freepages()
> >>so that the PFN for restarting is updated with each pageblock where isolation
> >>is attempted. Using stress-highalloc from mmtests, this resulted in 10%
> >>reduction of the pages scanned by the free scanner.
> >
> >Hello,
> >
> >Although this patch could reduce page scanned, it is possible to skip
> >scanning fresh pageblock. If there is zone lock contention and we are on
> >asyn compaction, we stop scanning this pageblock immediately. And
> >then, we will continue to scan next pageblock. With this patch,
> >next_free_pfn is updated in this case, so we never come back again to this
> >pageblock. Possibly this makes compaction success rate low, doesn't
> >it?
> 
> Hm, you're right and thanks for catching that, but I think this is a
> sign of a worse and older issue than skipping a pageblock?
> When isolate_freepages_block() breaks loop due to lock contention,
> then isolate_freepages() (which called it) should also immediately
> quit its loop. Trying another pageblock in the same zone with the
> same zone->lock makes no sense here? If this is fixed, then the
> issue you're pointing out will also be fixed as next_free_pfn will
> still point to the pageblock where the break occured.
> 

Yes. It can be fixed by your approach. :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
