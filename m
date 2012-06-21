Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id F10A76B009D
	for <linux-mm@kvack.org>; Thu, 21 Jun 2012 04:30:50 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2306542pbb.14
        for <linux-mm@kvack.org>; Thu, 21 Jun 2012 01:30:50 -0700 (PDT)
Date: Thu, 21 Jun 2012 01:30:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: abort compaction if migration page cannot be
 charged to memcg
In-Reply-To: <4FE2D73C.3060001@kernel.org>
Message-ID: <alpine.DEB.2.00.1206210124380.6635@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206202351030.28770@chino.kir.corp.google.com> <4FE2D73C.3060001@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 21 Jun 2012, Minchan Kim wrote:

> > If page migration cannot charge the new page to the memcg,
> > migrate_pages() will return -ENOMEM.  This isn't considered in memory
> > compaction however, and the loop continues to iterate over all pageblocks
> > trying in a futile attempt to continue migrations which are only bound to
> > fail.
> 
> 
> Hmm, it might be dumb question.
> I imagine that pages in next pageblock could be in another memcg so it could be successful.
> Why should we stop compaction once it fails to migrate pages in current pageblock/memcg?
> 

 [ You included the gmane.linux.kernel and gmane.linux.kernel.mm
   newsgroups in your reply, not sure why, so I removed them. ]

This was inspired by a system running with a single oom memcg running with 
thp that continuously tried migrating pages resulting in vmstats such as 
this:

compact_blocks_moved 59473599
compact_pages_moved 50041548
compact_pagemigrate_failed 1494277831
compact_stall 1013
compact_fail 573

Obviously not a good result.

We could certainly continue the iteration in cases like this, but I 
thought it would be better to fail and rely on direct reclaim to actually 
try to free some memory, especially if that oom memcg happens to include 
current.

It's possible that subsequent pageblocks would contain memory allocated 
from solely non-oom memcgs, but it's certainly not a guarantee and results 
in terrible performance as exhibited above.  Is there another good 
criteria to use when deciding when to stop isolating and attempting to 
migrate all of these pageblocks?

Other ideas?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
