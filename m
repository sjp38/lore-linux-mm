Date: Sat, 26 Apr 2008 16:04:06 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [PATCH 01 of 12] Core of mmu notifiers
Message-ID: <20080426140406.GH9514@duo.random>
References: <20080422223545.GP24536@duo.random> <20080422230727.GR30298@sgi.com> <20080423002848.GA32618@sgi.com> <20080423163713.GC24536@duo.random> <20080423221928.GV24536@duo.random> <20080424064753.GH24536@duo.random> <20080424095112.GC30298@sgi.com> <20080424153943.GJ24536@duo.random> <20080424174145.GM24536@duo.random> <20080426131734.GB19717@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080426131734.GB19717@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>, Christoph Lameter <clameter@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

On Sat, Apr 26, 2008 at 08:17:34AM -0500, Robin Holt wrote:
> Since this include and the one for mm_types.h both are build breakages
> for ia64, I think you need to apply your ia64_cpumask and the following
> (possibly as a single patch) first or in your patch 1.  Without that,
> ia64 doing a git-bisect could hit a build failure.

Agreed, so it doesn't risk to break ia64 compilation, thanks for the
great XPMEM feedback!

Also note, I figured out that mmu_notifier_release can actually run
concurrently against other mmu notifiers in case there's a vmtruncate
(->release could already run concurrently if invoked by _unregister,
the only guarantee is that ->release will be called one time and only
one time and that no mmu notifier will ever run after _unregister
returns).

In short I can't keep the list_del_init in _release and I need a
list_del_init_rcu instead to fix this minor issue. So this won't
really make much difference after all.

I'll release #v14 with all this after a bit of kvm testing with it...

diff --git a/include/linux/list.h b/include/linux/list.h
--- a/include/linux/list.h
+++ b/include/linux/list.h
@@ -755,6 +755,14 @@ static inline void hlist_del_init(struct
 	}
 }
 
+static inline void hlist_del_init_rcu(struct hlist_node *n)
+{
+	if (!hlist_unhashed(n)) {
+		__hlist_del(n);
+		n->pprev = NULL;
+	}
+}
+
 /**
  * hlist_replace_rcu - replace old entry by new one
  * @old : the element to be replaced
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -22,7 +22,10 @@ struct mmu_notifier_ops {
 	/*
 	 * Called either by mmu_notifier_unregister or when the mm is
 	 * being destroyed by exit_mmap, always before all pages are
-	 * freed. It's mandatory to implement this method.
+	 * freed. It's mandatory to implement this method. This can
+	 * run concurrently to other mmu notifier methods and it
+	 * should teardown all secondary mmu mappings and freeze the
+	 * secondary mmu.
 	 */
 	void (*release)(struct mmu_notifier *mn,
 			struct mm_struct *mm);
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -19,12 +19,13 @@
 
 /*
  * This function can't run concurrently against mmu_notifier_register
- * or any other mmu notifier method. mmu_notifier_register can only
- * run with mm->mm_users > 0 (and exit_mmap runs only when mm_users is
- * zero). All other tasks of this mm already quit so they can't invoke
- * mmu notifiers anymore. This can run concurrently only against
- * mmu_notifier_unregister and it serializes against it with the
- * mmu_notifier_mm->lock in addition to RCU. struct mmu_notifier_mm
+ * because mm->mm_users > 0 during mmu_notifier_register and exit_mmap
+ * runs with mm_users == 0. Other tasks may still invoke mmu notifiers
+ * in parallel despite there's no task using this mm anymore, through
+ * the vmas outside of the exit_mmap context, like with
+ * vmtruncate. This serializes against mmu_notifier_unregister with
+ * the mmu_notifier_mm->lock in addition to SRCU and it serializes
+ * against the other mmu notifiers with SRCU. struct mmu_notifier_mm
  * can't go away from under us as exit_mmap holds a mm_count pin
  * itself.
  */
@@ -44,7 +45,7 @@ void __mmu_notifier_release(struct mm_st
 		 * to wait ->release to finish and
 		 * mmu_notifier_unregister to return.
 		 */
-		hlist_del_init(&mn->hlist);
+		hlist_del_init_rcu(&mn->hlist);
 		/*
 		 * SRCU here will block mmu_notifier_unregister until
 		 * ->release returns.
@@ -185,6 +186,8 @@ int mmu_notifier_register(struct mmu_not
 	 * side note: mmu_notifier_release can't run concurrently with
 	 * us because we hold the mm_users pin (either implicitly as
 	 * current->mm or explicitly with get_task_mm() or similar).
+	 * We can't race against any other mmu notifiers either thanks
+	 * to mm_lock().
 	 */
 	spin_lock(&mm->mmu_notifier_mm->lock);
 	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
