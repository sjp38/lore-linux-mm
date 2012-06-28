Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 8CC666B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 20:52:52 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2579289dak.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 17:52:51 -0700 (PDT)
Date: Wed, 27 Jun 2012 17:52:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: excessive CPU utilization by isolate_freepages?
In-Reply-To: <4FEBA520.4030205@redhat.com>
Message-ID: <alpine.DEB.2.00.1206271745170.9552@chino.kir.corp.google.com>
References: <4FEB8237.6030402@sandia.gov> <4FEB9E73.5040709@kernel.org> <4FEBA520.4030205@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>

On Wed, 27 Jun 2012, Rik van Riel wrote:

> > I doubt compaction try to migrate continuously although we have no free
> > memory.
> > Could you apply this patch and retest?
> > 
> > https://lkml.org/lkml/2012/6/21/30
> 

Not sure if Jim is using memcg; if not, then this won't be helpful.

> Another possibility is that compaction is succeeding every time,
> but since we always start scanning all the way at the beginning
> and end of each zone, we waste a lot of CPU time rescanning the
> same pages (that we just filled up with moved pages) to see if
> any are free.
> 
> In short, due to the way compaction behaves right now,
> compaction + isolate_freepages are essentially quadratic.
> 
> What we need to do is remember where we left off after a
> successful compaction, so we can continue the search there
> at the next invocation.
> 

So when the free and migration scanners meet and compact_finished() == 
COMPACT_CONTINUE, loop around to the start of the zone and continue until 
you reach the pfn that it was started at?  Seems appropriate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
