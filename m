Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id A36586B007B
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 18:02:41 -0400 (EDT)
Received: by mail-ig0-f169.google.com with SMTP id a13so2433411igq.2
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 15:02:41 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id qg5si12549576igb.7.2014.06.04.15.02.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 15:02:41 -0700 (PDT)
Received: by mail-ie0-f179.google.com with SMTP id rd18so135192iec.10
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 15:02:40 -0700 (PDT)
Date: Wed, 4 Jun 2014 15:02:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 3/3] mm, compaction: avoid compacting memory for thp
 if pageblock cannot become free
In-Reply-To: <20140604110411.GK10819@suse.de>
Message-ID: <alpine.DEB.2.02.1406041454070.13330@chino.kir.corp.google.com>
References: <1399904111-23520-1-git-send-email-vbabka@suse.cz> <1400233673-11477-1-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <537DB0E5.40602@suse.cz> <alpine.DEB.2.02.1405220127320.13630@chino.kir.corp.google.com>
 <537DE799.3040400@suse.cz> <alpine.DEB.2.02.1406031728390.5312@chino.kir.corp.google.com> <alpine.DEB.2.02.1406031729410.5312@chino.kir.corp.google.com> <20140604110411.GK10819@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>, Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>

On Wed, 4 Jun 2014, Mel Gorman wrote:

> > It's pointless to migrate pages within a pageblock if the entire pageblock will 
> > not become free for a thp allocation.
> > 
> > If we encounter a page that cannot be migrated and a direct compactor other than 
> > khugepaged is trying to allocate a hugepage for thp, then skip the entire 
> > pageblock and avoid migrating pages needlessly.
> > 
> 
> It's not completely pointless. A movable page may be placed within an
> unmovable pageblock due to insufficient free memory or a pageblock changed
> type. When this happens then partial migration moves the movable page
> of out of the unmovable block. Future unmovable allocations can then be
> placed with other unmovable pages instead of falling back to other blocks
> and degrading fragmentation over time.
> 

Sorry, this should say that it's pointless when doing a HPAGE_PMD_ORDER 
allocation and we're calling direct compaction for thp.  While the result 
may be that there will be less external fragmentation in the longrun, I 
don't think it's appropriate to do this at fault.

We keep a running tracker of how long it takes to fault 64MB of anonymous 
memory with thp enabled in one of our production cells.  For an instance 
that took 1.58225s in fault (not including the mmap() time or munmap() 
time), here are the compaction stats:

Before:
compact_blocks_moved 508932592
compact_pages_moved 93068626
compact_pagemigrate_failed 199708939
compact_stall 7014989
compact_fail 6977371
compact_success 37617

After:
compact_blocks_moved 508938635
compact_pages_moved 93068667
compact_pagemigrate_failed 199712677
compact_stall 7015029
compact_fail 6977411
compact_success 37617

Not one of the compaction stalls resulted in a thp page being allocated, 
probably because the number of pages actually migrated is very low.  The 
delta here is 6043 pageblocks scanned over 40 compaction calls, 41 pages 
_total_ being successfully migrated and 3738 pages total being isolated 
but unsuccessfully migrated.

Those statistics are horrible.  We scan approximately 151 pageblocks per 
compaction stall needlessly in this case and, on average, migrate a single 
page but isolate and fail to migrate 93 pages.

I believe my patch would reduce this pointless migration when an entire 
pageblock will not be freed in the thp fault path.  I do need to factor in 
Vlastimil's feedback concerning the PageBuddy order, but I think this is 
generally the right approach for thp fault.

Additionally, I need to figure out why those 3738 pages are isolated but 
fail to migrate and it doesn't seem to be because of any race.  Perhaps 
there will be a chance to do something similar to what I did in commit 
119d6d59dcc0 ("mm, compaction: avoid isolating pinned pages") to avoid 
even considering certain checks, but I'll have to identify the source(s) 
of these failures first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
