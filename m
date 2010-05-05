Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A8971620089
	for <linux-mm@kvack.org>; Wed,  5 May 2010 09:11:46 -0400 (EDT)
Date: Wed, 5 May 2010 15:11:12 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] fix count_vm_event preempt in memory compaction direct
 reclaim
Message-ID: <20100505131112.GB5835@random.random>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
 <1271797276-31358-13-git-send-email-mel@csn.ul.ie>
 <20100505121908.GA5835@random.random>
 <20100505125156.GM20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100505125156.GM20979@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 05, 2010 at 01:51:56PM +0100, Mel Gorman wrote:
> On Wed, May 05, 2010 at 02:19:08PM +0200, Andrea Arcangeli wrote:
> > On Tue, Apr 20, 2010 at 10:01:14PM +0100, Mel Gorman wrote:
> > > +		if (page) {
> > > +			__count_vm_event(COMPACTSUCCESS);
> > > +			return page;
> > 
> > ==
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > Preempt is enabled so it must use count_vm_event.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> Reviewed-by: Mel Gorman <mel@csn.ul.ie>
> 
> Andrew, this is a fix to the patch
> mmcompaction-direct-compact-when-a-high-order-allocation-fails.patch

for Andrew: I'll generate a trivial reject to the exponential backoff.

> Thanks Andrea, well spotted.

You're welcome.

I updated current aa.git origin/master and origin/anon_vma_chain
branches (post THP-23*).

There's also another patch I've in my tree that you didn't picked up
and I wonder what's the issue here. This less a bugfix because it
seems to only affect lockdep, I don't know why lockdep forbids to call
migrate_prep with any lock held (in this case the mmap_sem). migrate.c
is careful to comply with it, compaction.c isn't. It's not mandatory
to succeed for compaction, so in doubt I just commented it out. It'll
also decrease the IPI load so I wasn't very concerned to re-enable it.

-----
Subject: disable migrate_prep()

From: Andrea Arcangeli <aarcange@redhat.com>

I get trouble from lockdep if I leave it enabled:

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.34-rc3 #50
-------------------------------------------------------
largepages/4965 is trying to acquire lock:
 (events){+.+.+.}, at: [<ffffffff8105b788>] flush_work+0x38/0x130

 but task is already holding lock:
  (&mm->mmap_sem){++++++}, at: [<ffffffff8141b022>] do_page_fault+0xd2/0x430


flush_work apparently wants to run free from lock and it bugs in:

	lock_map_acquire(&cwq->wq->lockdep_map);

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/compaction.c b/mm/compaction.c
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -383,7 +383,9 @@ static int compact_zone(struct zone *zon
 	cc->free_pfn = cc->migrate_pfn + zone->spanned_pages;
 	cc->free_pfn &= ~(pageblock_nr_pages-1);
 
+#if 0
 	migrate_prep();
+#endif
 
 	while ((ret = compact_finished(zone, cc)) == COMPACT_CONTINUE) {
 		unsigned long nr_migrate, nr_remaining;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
