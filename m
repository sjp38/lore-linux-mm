Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 18D336B0031
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 05:06:21 -0400 (EDT)
Received: by mail-ie0-f170.google.com with SMTP id tr6so616066ieb.29
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:06:20 -0700 (PDT)
Received: from mail-ig0-x232.google.com (mail-ig0-x232.google.com [2607:f8b0:4001:c05::232])
        by mx.google.com with ESMTPS id bq3si32216631icc.41.2014.06.09.02.06.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 02:06:20 -0700 (PDT)
Received: by mail-ig0-f178.google.com with SMTP id hn18so1261571igb.11
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 02:06:19 -0700 (PDT)
Date: Mon, 9 Jun 2014 02:06:17 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 6/6] mm, compaction: don't migrate in blocks that
 cannot be fully compacted in async direct compaction
In-Reply-To: <53916EE7.9000806@suse.cz>
Message-ID: <alpine.DEB.2.02.1406090156340.24247@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-6-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041705140.22536@chino.kir.corp.google.com> <53908F10.4020603@suse.cz>
 <alpine.DEB.2.02.1406051431030.18119@chino.kir.corp.google.com> <53916EE7.9000806@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Fri, 6 Jun 2014, Vlastimil Babka wrote:

> > Agreed.  I was thinking higher than 1GB would be possible once we have 
> > your series that does the pageblock skip for thp, I think the expense 
> > would be constant because we won't needlessly be migrating pages unless it 
> > has a good chance at succeeding.
> 
> Looks like a counter of iterations actually done in scanners, maintained in
> compact_control, would work better than any memory size based limit? It could
> better reflect the actual work done and thus latency. Maybe increase the counter
> also for migrations, with a higher cost than for a scanner iteration.
> 

I'm not sure we can expose that to be configurable by userspace in any 
meaningful way.  We'll want to be able to tune this depending on the size 
of the machine if we are to truly remove the need_resched() heuristic and 
give it a sane default.  I was thinking it would be similar to 
khugepaged's pages_to_scan value that it uses on each wakeup.

> > This does beg the question about parallel direct compactors, though, that 
> > will be contending on the same coarse zone->lru_lock locks and immediately 
> > aborting and falling back to PAGE_SIZE pages for thp faults that will be 
> > more likely if your patch to grab the high-order page and return it to the 
> > page allocator is merged.
> 
> Hm can you explain how the page capturing makes this worse? I don't see it.
> 

I was expecting that your patch to capture the high-order page made a 
difference because the zone watermark check doesn't imply the high-order 
page will be allocatable after we return to the page allocator to allocate 
it.  In that case, we terminated compaction prematurely.  If that's true, 
then it seems like no parallel thp allocator will be able to allocate 
memory that another direct compactor has freed without entering compaction 
itself on a fragmented machine, and thus an increase in zone->lru_lock 
contention if there's migratable memory.

Having 32 cpus fault thp memory and all entering compaction and contending 
(and aborting because of contention, currently) on zone->lru_lock is a 
really bad situation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
