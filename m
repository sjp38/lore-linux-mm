Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7646F6B005C
	for <linux-mm@kvack.org>; Wed,  7 May 2014 17:28:42 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so1507247pdj.22
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:28:42 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ci3si14458130pad.4.2014.05.07.14.28.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 07 May 2014 14:28:41 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so1712081pab.29
        for <linux-mm@kvack.org>; Wed, 07 May 2014 14:28:41 -0700 (PDT)
Date: Wed, 7 May 2014 14:28:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v3 6/6] mm, compaction: terminate async compaction when
 rescheduling
In-Reply-To: <20140507142033.1ec148fe35059121db547f25@linux-foundation.org>
Message-ID: <alpine.DEB.2.02.1405071421580.8454@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com> <alpine.DEB.2.02.1405061922220.18635@chino.kir.corp.google.com>
 <20140507142033.1ec148fe35059121db547f25@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014, Andrew Morton wrote:

> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -500,8 +500,13 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
> >  			return 0;
> >  	}
> >  
> > +	if (cond_resched()) {
> > +		/* Async terminates prematurely on need_resched() */
> > +		if (cc->mode == MIGRATE_ASYNC)
> > +			return 0;
> > +	}
> 
> Comment comments the obvious.  What is less obvious is *why* we do this.
> 

Async compaction is most prevalent for thp pagefaults and without 
zone->lru_lock contention we have no other termination criteria.  Without 
this, we would scan a potentially very long zone (zones 64GB in length in 
my testing) and it would be very expensive for pagefault.  Async is best 
effort, so if it is becoming too expensive then it's better to just 
fallback to PAGE_SIZE pages instead and rely on khugepaged to collapse 
later.

> Someone please remind my why sync and async compaction use different
> scanning cursors?
> 

It's introduced in this patchset.  Async compaction does not consider 
pageblocks unless it is MIGRATE_MOVABLE since it is best effort, sync 
compaction considers all pageblocks.  In the past, we only updated the 
cursor for sync compaction since it would be wrong to update it for async 
compaction if it can skip certain pageblocks.  Unfortunately, if async 
compaction is relied upon solely for certain allocations (such as thp 
pagefaults), it is possible to scan an enormous amount of a 64GB zone, for 
example, pointlessly every time if none of the memory can be isolated.

The result is that sync compaction always updates both scanners and async 
compaction only updates its own scanner.  Either scanner is only updated 
if the new cursor is "beyond" the previous cursor.  ("Beyond" is _after_ 
the previous migration scanner pfn and _before_ the previous free scanner 
pfn.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
