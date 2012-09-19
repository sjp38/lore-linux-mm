Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 8DA766B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 23:46:00 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so545707qcs.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2012 20:45:59 -0700 (PDT)
Date: Tue, 18 Sep 2012 20:45:21 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: blk, mm: lockdep irq lock inversion in linux-next
In-Reply-To: <alpine.LSU.2.00.1209171634560.6827@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1209182027280.11632@eggly.anvils>
References: <5054878F.1030908@gmail.com> <20120917162248.d998afe3.akpm@linux-foundation.org> <alpine.LSU.2.00.1209171634560.6827@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Jens Axboe <axboe@kernel.dk>, Tejun Heo <tj@kernel.org>, Dave Jones <davej@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 17 Sep 2012, Hugh Dickins wrote:
> On Mon, 17 Sep 2012, Andrew Morton wrote:
> > On Sat, 15 Sep 2012 15:50:07 +0200
> > Sasha Levin <levinsasha928@gmail.com> wrote:
> > 
> > > Hi all,
> > > 
> > > While fuzzing with trinity within a KVM tools guest on a linux-next kernel, I
> > > got the lockdep warning at the bottom of this mail.
> > > 
> > > I've tried figuring out where it was introduced, but haven't found any sign that
> > > any of the code in that area changed recently, so I'm probably missing something...
> > > 
> > > 
> > > [ 157.966399] =========================================================
> > > [ 157.968523] [ INFO: possible irq lock inversion dependency detected ]
> > > [ 157.970029] 3.6.0-rc5-next-20120914-sasha-00001-g802bf6c-dirty #340 Tainted: G W
> > > [ 157.970029] ---------------------------------------------------------
> > > [ 157.970029] trinity-child38/6642 just changed the state of lock:
> > > [ 157.970029] (&(&mapping->tree_lock)->rlock){+.+...}, at: [<ffffffff8120cafc>]
> > > invalidate_inode_pages2_range+0x20c/0x3c0
> > > [ 157.970029] but this lock was taken by another, SOFTIRQ-safe lock in the past:
> > > [ 157.970029] (&(&new->queue_lock)->rlock){..-...}
> > > 
> > > [snippage]
> > 
> > gack, what a mess.  Thanks for the report.  AFAICT, what has happened is:
> > 
> > invalidate_complete_page2()
> > ->spin_lock_irq(&mapping->tree_lock)
> > ->clear_page_mlock()
> >   __clear_page_mlock()
> >   ->isolate_lru_page()
> >     ->spin_lock_irq(&zone->lru_lock)
> >     ->spin_unlock_irq(&zone->lru_lock)
> > 
> > whoops.  isolate_lru_page() just enabled local interrupts while we're
> > holding ->tree_lock, which is supposed to be an irq-save lock.  And in
> > a rather obscure way, lockdep caught it.
> 
> Congratulations on deciphering the lockdep report, I soon gave up.
> 
> But it looks like a bigger problem than your patch addresses:
> both filemap.c and rmap.c document tree_lock as nesting within
> lru_lock; and although it's possible that time has changed that,
> I doubt it.
> 
> I think invalidate_complete_page2() is simply wrong to be calling
> clear_page_mlock() while holding mapping->tree_lock (other callsites
> avoid doing so).  Maybe it should do a preliminary PageDirty test,
> then clear_page_mlock(), then take mapping->tree_lock, then repeat
> PageDirty test, without worrying about the odd case when it might
> clear mlock but then decide to back off the page.
> 
> Oh, hold on, that reminds me: a few months ago I was putting together
> a tidy-up patch near there, and it seemed to me inappropriate to be
> clearing mlock down in truncate/invalidate, that belongs better to
> when unmapping the page, doesn't it?
> 
> I'll look that out and try to finish it off.

I've completed that now, will send you a patchset of 4 in a moment.

The tidy-ups went rather beyond what we'd want to put in 3.6 or Cc stable
for this, so 1/4 is a one-liner to move up the offending clear_page_mlock(),
(which I think should replace your "mm: isolate_lru_page(): don't enable
local interrupts"), then the rest go on to make more sense of it.
Against 3.6-rc6: just the last gives a trivial reject on mmotm.

[PATCH 1/4] mm: fix invalidate_complete_page2 lock ordering
[PATCH 2/4] mm: remove vma arg from page_evictable
[PATCH 3/4] mm: clear_page_mlock in page_remove_rmap
[PATCH 4/4] mm: remove free_page_mlock

 Documentation/vm/unevictable-lru.txt |   10 ++-------
 include/linux/swap.h                 |    2 -
 include/linux/vm_event_item.h        |    2 -
 mm/internal.h                        |   12 ++---------
 mm/ksm.c                             |    2 -
 mm/memory.c                          |   10 ++++-----
 mm/mlock.c                           |   16 ++------------
 mm/page_alloc.c                      |   17 ---------------
 mm/rmap.c                            |    6 ++++-
 mm/swap.c                            |    2 -
 mm/truncate.c                        |    3 --
 mm/vmscan.c                          |   27 ++++++++-----------------
 mm/vmstat.c                          |    2 -
 13 files changed, 33 insertions(+), 78 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
