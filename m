Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7FA546B0088
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 05:49:30 -0500 (EST)
Date: Tue, 21 Dec 2010 10:49:08 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: migration: Use rcu_dereference_protected when
	dereferencing the radix tree slot during file page migration
Message-ID: <20101221104907.GT13914@csn.ul.ie>
References: <20101220152335.GR13914@csn.ul.ie> <20101220170146.GS13914@csn.ul.ie> <AANLkTiniXU9B5YpQ+hknOSF-mPig2z9UqqBWz-JwQjDL@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTiniXU9B5YpQ+hknOSF-mPig2z9UqqBWz-JwQjDL@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, gerald.schaefer@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org, Ted Ts'o <tytso@mit.edu>, Arun Bhanu <ab@arunbhanu.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 21, 2010 at 08:48:50AM +0900, Minchan Kim wrote:
> On Tue, Dec 21, 2010 at 2:01 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Mon, Dec 20, 2010 at 03:23:36PM +0000, Mel Gorman wrote:
> >> migrate_pages() -> unmap_and_move() only calls rcu_read_lock() for anonymous
> >> pages, as introduced by git commit 989f89c57e6361e7d16fbd9572b5da7d313b073d.
> >> The point of the RCU protection there is part of getting a stable reference
> >> to anon_vma and is only held for anon pages as file pages are locked
> >> which is sufficient protection against freeing.
> >>
> >> However, while a file page's mapping is being migrated, the radix
> >> tree is double checked to ensure it is the expected page. This uses
> >> radix_tree_deref_slot() -> rcu_dereference() without the RCU lock held
> >> triggering the following warning under CONFIG_PROVE_RCU.
> >>
> >> [  173.674290] ===================================================
> >> [  173.676016] [ INFO: suspicious rcu_dereference_check() usage. ]
> >> [  173.676016] ---------------------------------------------------
> >> [  173.676016] include/linux/radix-tree.h:145 invoked rcu_dereference_check() without protection!
> >> [  173.676016]
> >> [  173.676016] other info that might help us debug this:
> >> [  173.676016]
> >> [  173.676016]
> >> [  173.676016] rcu_scheduler_active = 1, debug_locks = 0
> >> [  173.676016] 1 lock held by hugeadm/2899:
> >> [  173.676016]  #0:  (&(&inode->i_data.tree_lock)->rlock){..-.-.}, at: [<c10e3d2b>] migrate_page_move_mapping+0x40/0x1ab
> >> [  173.676016]
> >> [  173.676016] stack backtrace:
> >> [  173.676016] Pid: 2899, comm: hugeadm Not tainted 2.6.37-rc5-autobuild
> >> [  173.676016] Call Trace:
> >> [  173.676016]  [<c128cc01>] ? printk+0x14/0x1b
> >> [  173.676016]  [<c1063502>] lockdep_rcu_dereference+0x7d/0x86
> >> [  173.676016]  [<c10e3db5>] migrate_page_move_mapping+0xca/0x1ab
> >> [  173.676016]  [<c10e41ad>] migrate_page+0x23/0x39
> >> [  173.676016]  [<c10e491b>] buffer_migrate_page+0x22/0x107
> >> [  173.676016]  [<c10e48f9>] ? buffer_migrate_page+0x0/0x107
> >> [  173.676016]  [<c10e425d>] move_to_new_page+0x9a/0x1ae
> >> [  173.676016]  [<c10e47e6>] migrate_pages+0x1e7/0x2fa
> >>
> >> This patch introduces radix_tree_deref_slot_protected() which calls
> >> rcu_dereference_protected(). Users of it must pass in the mapping->tree_lock
> >> that is protecting this dereference. Holding the tree lock protects against
> >> parallel updaters of the radix tree meaning that rcu_dereference_protected
> >> is allowable.
> >>
> >> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> >> ---
> >>  include/linux/radix-tree.h |   17 +++++++++++++++++
> >>  mm/migrate.c               |    4 ++--
> >>  2 files changed, 19 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
> >> index ab2baa5..a1f1672 100644
> >> --- a/include/linux/radix-tree.h
> >> +++ b/include/linux/radix-tree.h
> >> @@ -146,6 +146,23 @@ static inline void *radix_tree_deref_slot(void **pslot)
> >>  }
> >>
> >>  /**
> >> + * radix_tree_deref_slot_protected   - dereference a slot without RCU lock but with tree lock held
> >> + * @pslot:   pointer to slot, returned by radix_tree_lookup_slot
> >> + * Returns:  item that was stored in that slot with any direct pointer flag
> >> + *           removed.
> >> + *
> >> + * Similar to radix_tree_deref_slot but only used during migration when a pages
> >> + * mapping is being moved. The caller does not hold the RCU read lock but it
> >> + * must hold the tree lock to prevent parallel updates.
> >> + */
> >> +static inline void *radix_tree_deref_slot_protected(void **pslot,
> >> +                                                     spinlock_t *treelock)
> >> +{
> >> +     BUG_ON(rcu_read_lock_held());
> 
> Hmm.. Why did you add the check?
> If rcu_read_lock were already held, we wouldn't need this new API.
> 

Because our earlier discussions assumed that RCU read lock was not held
in this path. The check was added to ensure that assumption was correct,
it wasn't.

> >
> > This was a bad idea. After some extended testing, it was obvious that
> > this function can be called for swapcache pages with the RCU lock held.
> > Paul, is it still permissible to use rcu_dereference_protected() or must
> 
> I guess has no problem.
> 
> > the RCU read lock not be held?
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
