Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 53D076B005A
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 08:55:40 -0400 (EDT)
Received: by dadi14 with SMTP id i14so1182271dad.14
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 05:55:39 -0700 (PDT)
Date: Thu, 6 Sep 2012 20:55:26 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/2]compaction: check migrated page number
Message-ID: <20120906125526.GA1025@kernel.org>
References: <20120906104404.GA12718@kernel.org>
 <20120906121725.GQ11266@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120906121725.GQ11266@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, aarcange@redhat.com

On Thu, Sep 06, 2012 at 01:17:25PM +0100, Mel Gorman wrote:
> On Thu, Sep 06, 2012 at 06:44:04PM +0800, Shaohua Li wrote:
> > 
> > isolate_migratepages_range() might isolate none pages, for example, when
> > zone->lru_lock is contended and compaction is async. In this case, we should
> > abort compaction, otherwise, compact_zone will run a useless loop and make
> > zone->lru_lock is even contended.
> > 
> 
> It might also isolate no pages because the range was 100% allocated and
> there were no free pages to isolate. This is perfectly normal and I suspect
> this patch effectively disables compaction. What problem did you observe
> that this patch is aimed at?

I'm running a random swapin/out workload. When memory is fragmented enough, I
saw 100% cpu usage. perf shows zone->lru_lock is heavily contended in
isolate_migratepages_range. I'm using slub(I didn't see the problem with slab),
the allocation is for radix_tree_node slab, which needs 4 pages. Even If I just
apply the second patch, the system is still in 100% cpu usage. The
spin_is_contended check can't cure the problem completely. Trace shows
compact_zone will run a useless loop and each loop contend the lru_lock. With
this patch, the cpu usage becomes normal (about 20% utilization).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
