Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 93F396B029E
	for <linux-mm@kvack.org>; Wed,  5 May 2010 10:49:32 -0400 (EDT)
Date: Wed, 5 May 2010 16:48:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix count_vm_event preempt in memory compaction direct
 reclaim
Message-ID: <20100505144813.GI5835@random.random>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
 <1271797276-31358-13-git-send-email-mel@csn.ul.ie>
 <20100505121908.GA5835@random.random>
 <20100505125156.GM20979@csn.ul.ie>
 <20100505131112.GB5835@random.random>
 <20100505135537.GO20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100505135537.GO20979@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 02:55:38PM +0100, Mel Gorman wrote:
> I haven't seen this problem. The testing I'd have been doing with compaction
> were stress tests allocating huge pages but not from the fault path.

That explains it! But anything can call alloc_pages(order>0) with some
semaphore held.

> It's not mandatory but the LRU lists should be drained so they can be properly
> isolated. It'd make a slight difference to success rates as there will be
> pages that cannot be isolated because they are on some pagevec.

Yes success rate will be slightly worse but this also applies to all
regular vmscan paths that don't send IPI but they only flush the local
queue with lru_add_drain, simply pages won't be freed until there will
be some other cpu holding the refcount on them, it is not specific to
compaction.c but it applies to vmscan.c and vmscan likely not wanting
to send an IPI flood because it could too if it wanted.

But I guess I should at least use lru_add_drain() in replacement of
migrate_prep...

> While true, is compaction density that high under normal workloads? I guess
> it would be if a scanner was constantly trying to promote pages.  If the
> IPI load is out of hand, I'm ok with disabling in some cases. For example,
> I'd be ok with it being skipped if it was part of a daemon doing speculative
> promotion but I'd prefer it to still be used if the static hugetlbfs pool
> was being resized if that was possible.

I don't know if IPI is measurable, but it usually is...

> > -----
> > Subject: disable migrate_prep()
> > 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > I get trouble from lockdep if I leave it enabled:
> > 
> > =======================================================
> > [ INFO: possible circular locking dependency detected ]
> > 2.6.34-rc3 #50
> > -------------------------------------------------------
> > largepages/4965 is trying to acquire lock:
> >  (events){+.+.+.}, at: [<ffffffff8105b788>] flush_work+0x38/0x130
> > 
> >  but task is already holding lock:
> >   (&mm->mmap_sem){++++++}, at: [<ffffffff8141b022>] do_page_fault+0xd2/0x430
> > 
> 
> Hmm, I'm not seeing where in the fault path flush_work is getting called
> from. Can you point it out to me please?

lru_add_drain_all->schedule_on_each_cpu->flush_work

> We already do some IPI work in the page allocator although it happens after
> direct reclaim and only for high-order pages. What happens there and what
> happens in migrate_prep are very similar so if there was a problem with IPI
> and fault paths, I'd have expected to see it from hugetlbfs at some stage.

Where? I never triggered other issues in the page allocator with
lockdep, just this one pops up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
