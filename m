Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A12E96B0471
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 18:45:03 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id d185so42318108pgc.2
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 15:45:03 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d2si8382879pli.286.2017.02.16.15.45.01
        for <linux-mm@kvack.org>;
        Thu, 16 Feb 2017 15:45:02 -0800 (PST)
Date: Fri, 17 Feb 2017 08:45:00 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: swap_cluster_info lockdep splat
Message-ID: <20170216234500.GA30275@bbox>
References: <20170216052218.GA13908@bbox>
 <87o9y2a5ji.fsf@yhuang-dev.intel.com>
 <alpine.LSU.2.11.1702161050540.21773@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1702161050540.21773@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Tim Chen <tim.c.chen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi Huang and Hugh,

Thanks for the quick reponse!

On Thu, Feb 16, 2017 at 11:00:00AM -0800, Hugh Dickins wrote:
> On Thu, 16 Feb 2017, Huang, Ying wrote:
> 
> > Hi, Minchan,
> > 
> > Minchan Kim <minchan@kernel.org> writes:
> > 
> > > Hi Huang,
> > >
> > > With changing from bit lock to spinlock of swap_cluster_info, my zram
> > > test failed with below message. It seems nested lock problem so need to
> > > play with lockdep.
> > 
> > Sorry, I could not reproduce the warning in my tests.  Could you try the
> > patches as below?   And could you share your test case?

It's a simple kernel build test in small memory system.
4-core and 750M memory with zram-4G swap.

> > 
> > Best Regards,
> > Huang, Ying
> > 
> > ------------------------------------------------------------->
> > From 2b9e2f78a6e389442f308c4f9e8d5ac40fe6aa2f Mon Sep 17 00:00:00 2001
> > From: Huang Ying <ying.huang@intel.com>
> > Date: Thu, 16 Feb 2017 16:38:17 +0800
> > Subject: [PATCH] mm, swap: Annotate nested locking for cluster lock
> > 
> > There is a nested locking in cluster_list_add_tail() for cluster lock,
> > which caused lockdep to complain as below.  The nested locking is safe
> > because both cluster locks are only acquired when we held the
> > swap_info_struct->lock.  Annotated the nested locking via
> > spin_lock_nested() to fix the complain of lockdep.
> > 
> > =============================================
> > [ INFO: possible recursive locking detected ]
> > 4.10.0-rc8-next-20170214-zram #24 Not tainted
> > ---------------------------------------------
> > as/6557 is trying to acquire lock:
> >  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811ddd03>] cluster_list_add_tail.part.31+0x33/0x70
> > 
> > but task is already holding lock:
> >  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811df2bb>] swapcache_free_entries+0x9b/0x330
> > 
> > other info that might help us debug this:
> >  Possible unsafe locking scenario:
> > 
> >        CPU0
> >        ----
> >   lock(&(&((cluster_info + ci)->lock))->rlock);
> >   lock(&(&((cluster_info + ci)->lock))->rlock);
> > 
> >  *** DEADLOCK ***
> > 
> >  May be due to missing lock nesting notation
> > 
> > 3 locks held by as/6557:
> >  #0:  (&(&cache->free_lock)->rlock){......}, at: [<ffffffff811c206b>] free_swap_slot+0x8b/0x110
> >  #1:  (&(&p->lock)->rlock){+.+.-.}, at: [<ffffffff811df295>] swapcache_free_entries+0x75/0x330
> >  #2:  (&(&((cluster_info + ci)->lock))->rlock){+.+.-.}, at: [<ffffffff811df2bb>] swapcache_free_entries+0x9b/0x330
> > 
> > stack backtrace:
> > CPU: 3 PID: 6557 Comm: as Not tainted 4.10.0-rc8-next-20170214-zram #24
> > Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> > Call Trace:
> >  dump_stack+0x85/0xc2
> >  __lock_acquire+0x15ea/0x1640
> >  lock_acquire+0x100/0x1f0
> >  ? cluster_list_add_tail.part.31+0x33/0x70
> >  _raw_spin_lock+0x38/0x50
> >  ? cluster_list_add_tail.part.31+0x33/0x70
> >  cluster_list_add_tail.part.31+0x33/0x70
> >  swapcache_free_entries+0x2f9/0x330
> >  free_swap_slot+0xf8/0x110
> >  swapcache_free+0x36/0x40
> >  delete_from_swap_cache+0x5f/0xa0
> >  try_to_free_swap+0x6e/0xa0
> >  free_pages_and_swap_cache+0x7d/0xb0
> >  tlb_flush_mmu_free+0x36/0x60
> >  tlb_finish_mmu+0x1c/0x50
> >  exit_mmap+0xc7/0x150
> >  mmput+0x51/0x110
> >  do_exit+0x2b2/0xc30
> >  ? trace_hardirqs_on_caller+0x129/0x1b0
> >  do_group_exit+0x50/0xd0
> >  SyS_exit_group+0x14/0x20
> >  entry_SYSCALL_64_fastpath+0x23/0xc6
> > RIP: 0033:0x2b9a2dbdf309
> > RSP: 002b:00007ffe71887528 EFLAGS: 00000246 ORIG_RAX: 00000000000000e7
> > RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 00002b9a2dbdf309
> > RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000000000000
> > RBP: 00002b9a2ded8858 R08: 000000000000003c R09: 00000000000000e7
> > R10: ffffffffffffff60 R11: 0000000000000246 R12: 00002b9a2ded8858
> > R13: 00002b9a2dedde80 R14: 000000000255f770 R15: 0000000000000001
> > 
> > Reported-by: Minchan Kim <minchan@kernel.org>
> > Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> > ---
> >  include/linux/swap.h | 6 ++++++
> >  mm/swapfile.c        | 8 +++++++-
> >  2 files changed, 13 insertions(+), 1 deletion(-)
> > 
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 4d12b381821f..ef044ea8fe79 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -166,6 +166,12 @@ enum {
> >  #define COUNT_CONTINUED	0x80	/* See swap_map continuation for full count */
> >  #define SWAP_MAP_SHMEM	0xbf	/* Owned by shmem/tmpfs, in first swap_map */
> >  
> > +enum swap_cluster_lock_class
> > +{
> > +	SWAP_CLUSTER_LOCK_NORMAL,  /* implicitly used by plain spin_lock() APIs. */
> > +	SWAP_CLUSTER_LOCK_NESTED,
> > +};
> > +
> >  /*
> >   * We use this to track usage of a cluster. A cluster is a block of swap disk
> >   * space with SWAPFILE_CLUSTER pages long and naturally aligns in disk. All
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 5ac2cb40dbd3..0a52e9b2f843 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -263,6 +263,12 @@ static inline void __lock_cluster(struct swap_cluster_info *ci)
> >  	spin_lock(&ci->lock);
> >  }
> >  
> > +static inline void __lock_cluster_nested(struct swap_cluster_info *ci,
> > +					 unsigned subclass)
> > +{
> > +	spin_lock_nested(&ci->lock, subclass);
> > +}
> > +
> >  static inline struct swap_cluster_info *lock_cluster(struct swap_info_struct *si,
> >  						     unsigned long offset)
> >  {
> > @@ -336,7 +342,7 @@ static void cluster_list_add_tail(struct swap_cluster_list *list,
> >  		 * only acquired when we held swap_info_struct->lock
> >  		 */
> >  		ci_tail = ci + tail;
> > -		__lock_cluster(ci_tail);
> > +		__lock_cluster_nested(ci_tail, SWAP_CLUSTER_LOCK_NESTED);
> >  		cluster_set_next(ci_tail, idx);
> >  		unlock_cluster(ci_tail);
> >  		cluster_set_next_flag(&list->tail, idx, 0);
> > -- 
> > 2.11.0
> 
> I do not understand your zest for putting wrappers around every little
> thing, making it all harder to follow than it need be.  Here's the patch
> I've been running with (but you have a leak somewhere, and I don't have
> time to search out and fix it: please try sustained swapping and swapoff).
> 
> [PATCH] mm, swap: Annotate nested locking for cluster lock
> 
> Fix swap cluster lockdep warnings.
> 
> Reported-by: Minchan Kim <minchan@kernel.org>
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acutually, before the reporting, I tested below hunk and confirmed it doesn't
make lockdep warn any more. But I doubted it's okay for non-nested case
(i.e., setup_swap_map_and_extends) for lockdep subclass working.
I guess it's no problem but not sure so I just reported it without fixing
by myself. :)
If it's no problem, I'm sure both patches from you guys would work well
but I prefer Hugh's patch which makes it simple/clear.

Thanks.

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 5ac2cb4..348b9c5 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -263,6 +263,11 @@ static inline void __lock_cluster(struct swap_cluster_info *ci)
 	spin_lock(&ci->lock);
 }
 
+static inline void __lock_cluster_nested(struct swap_cluster_info *ci)
+{
+	spin_lock_nested(&ci->lock, SINGLE_DEPTH_NESTING);
+}
+
 static inline struct swap_cluster_info *lock_cluster(struct swap_info_struct *si,
 						     unsigned long offset)
 {
@@ -336,7 +341,7 @@ static void cluster_list_add_tail(struct swap_cluster_list *list,
 		 * only acquired when we held swap_info_struct->lock
 		 */
 		ci_tail = ci + tail;
-		__lock_cluster(ci_tail);
+		__lock_cluster_nested(ci_tail);
 		cluster_set_next(ci_tail, idx);
 		unlock_cluster(ci_tail);
 		cluster_set_next_flag(&list->tail, idx, 0);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
