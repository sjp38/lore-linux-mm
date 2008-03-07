Date: Fri, 7 Mar 2008 20:47:28 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH] 3/4 combine RCU with seqlock to allow mmu notifier
	methods to sleep (#v9 was 1/4)
Message-ID: <20080307194728.GP24114@v2.random>
References: <20080304133020.GC5301@v2.random> <Pine.LNX.4.64.0803041059110.13957@schroedinger.engr.sgi.com> <20080304222030.GB8951@v2.random> <Pine.LNX.4.64.0803041422070.20821@schroedinger.engr.sgi.com> <20080307151722.GD24114@v2.random> <20080307152328.GE24114@v2.random> <1204908762.8514.114.camel@twins> <20080307175019.GK24114@v2.random> <1204912895.8514.120.camel@twins> <20080307184552.GL24114@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080307184552.GL24114@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, kvm-devel@lists.sourceforge.net, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 07, 2008 at 07:45:52PM +0100, Andrea Arcangeli wrote:
> On Fri, Mar 07, 2008 at 07:01:35PM +0100, Peter Zijlstra wrote:
> > The reason Christoph can do without RCU is because he doesn't allow
> > unregister, and as soon as you drop that you'll end up with something
> 
> Not sure to follow, what do you mean "he doesn't allow"? We'll also
> have to rip unregister regardless after you pointed out the ->release
> won't be called after calling my mmu_notifier_unregister in 3/4. If
> you figured out how to retain mmu_notifier_unregister I'm not seeing
> it anymore.

Given I don't see other (buggy ;) ways anymore to retain
mmu_notifier_unregister, I did like in EMM and I dropped the
unregister function.

To me it looks like this will be enough and equally efficient as the
expanded version in EMM that is not using the highlevel hlist_rcu
macros. If you can see any pitfall let me know! Thanks a lot for the
help.

------
This is a replacement for the previously posted 3/4, one of the pieces
to allow the mmu notifier methods to sleep.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -70,17 +70,6 @@ static inline int mm_has_notifiers(struc
  */
 extern void mmu_notifier_register(struct mmu_notifier *mn,
 				  struct mm_struct *mm);
-/*
- * Must hold the mmap_sem for write.
- *
- * RCU is used to traverse the list. A quiescent period needs to pass
- * before the "struct mmu_notifier" can be freed. Alternatively it
- * can be synchronously freed inside ->release when the list can't
- * change anymore and nobody could possibly walk it.
- */
-extern void mmu_notifier_unregister(struct mmu_notifier *mn,
-				    struct mm_struct *mm);
-
 extern void __mmu_notifier_release(struct mm_struct *mm);
 extern int __mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long address);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -43,12 +43,10 @@ int __mmu_notifier_clear_flush_young(str
 	struct hlist_node *n;
 	int young = 0;
 
-	rcu_read_lock();
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
 		if (mn->ops->clear_flush_young)
 			young |= mn->ops->clear_flush_young(mn, mm, address);
 	}
-	rcu_read_unlock();
 
 	return young;
 }
@@ -59,12 +57,10 @@ void __mmu_notifier_invalidate_page(stru
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
-	rcu_read_lock();
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
 		if (mn->ops->invalidate_page)
 			mn->ops->invalidate_page(mn, mm, address);
 	}
-	rcu_read_unlock();
 }
 
 void __mmu_notifier_invalidate_range_begin(struct mm_struct *mm,
@@ -73,12 +69,10 @@ void __mmu_notifier_invalidate_range_beg
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
-	rcu_read_lock();
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
 		if (mn->ops->invalidate_range_begin)
 			mn->ops->invalidate_range_begin(mn, mm, start, end);
 	}
-	rcu_read_unlock();
 }
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
@@ -87,12 +81,10 @@ void __mmu_notifier_invalidate_range_end
 	struct mmu_notifier *mn;
 	struct hlist_node *n;
 
-	rcu_read_lock();
 	hlist_for_each_entry_rcu(mn, n, &mm->mmu_notifier_list, hlist) {
 		if (mn->ops->invalidate_range_end)
 			mn->ops->invalidate_range_end(mn, mm, start, end);
 	}
-	rcu_read_unlock();
 }
 
 /*
@@ -106,9 +98,3 @@ void mmu_notifier_register(struct mmu_no
 	hlist_add_head_rcu(&mn->hlist, &mm->mmu_notifier_list);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_register);
-
-void mmu_notifier_unregister(struct mmu_notifier *mn, struct mm_struct *mm)
-{
-	hlist_del_rcu(&mn->hlist);
-}
-EXPORT_SYMBOL_GPL(mmu_notifier_unregister);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
