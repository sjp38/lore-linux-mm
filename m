Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 236056B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 13:41:41 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p5HHfY7A025005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 10:41:39 -0700
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by kpbe11.cbf.corp.google.com with ESMTP id p5HHZ2jX010346
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 10:41:33 -0700
Received: by pzk5 with SMTP id 5so3042249pzk.17
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 10:41:33 -0700 (PDT)
Date: Fri, 17 Jun 2011 10:41:20 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
In-Reply-To: <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1106171040460.7018@sister.anvils>
References: <1308097798.17300.142.camel@schen9-DESK> <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins> <20110615161827.GA11769@tassilo.jf.intel.com> <1308156337.2171.23.camel@laptop> <1308163398.17300.147.camel@schen9-DESK>
 <1308169937.15315.88.camel@twins> <4DF91CB9.5080504@linux.intel.com> <1308172336.17300.177.camel@schen9-DESK> <1308173849.15315.91.camel@twins> <BANLkTim5TPKQ9RdLYRxy=mphOVKw5EXvTA@mail.gmail.com> <1308255972.17300.450.camel@schen9-DESK>
 <BANLkTinptaydNvK4ZvGvy0KVLnRmmza7tA@mail.gmail.com> <BANLkTi=GPtwjQ-bYDNUYCwzW5h--y86Law@mail.gmail.com> <BANLkTim-dBjva9w7AajqggKT3iUVYG2euQ@mail.gmail.com> <BANLkTimLV8aCZ7snXT_Do+f4vRY0EkoS4A@mail.gmail.com> <BANLkTinUBTYWxrF5TCuDSQuFUAyivXJXjQ@mail.gmail.com>
 <1308310080.2355.19.camel@twins> <BANLkTim2bmPfeRT1tS7hx2Z85QHjPHwU3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Fri, 17 Jun 2011, Linus Torvalds wrote:
> On Fri, Jun 17, 2011 at 4:28 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> >
> > Something like so? Compiles and runs the benchmark in question.
> 
> Yup.
> 
> Except I really think that test for a NULL anon_vma should go away.
> 
> If an avc entry has a NULL anon_vma, something is seriously wrong. The
> comment about anon_vma_fork failure is definitely just bogus: the
> anon_vma is allocated before the avc entry, so there's no way a avc
> can have a NULL anon_vma from there.
> 
> But yes, your patch is cleaner than the one I was playing around with
> (your "remove if not list empty" is prettier than what I was toying
> with - having a separate flag in the avc)
> 
> Tim, can you test Peter's (second - the cleaned up one) patch on top
> of mine, and see if that helps things further?
> 
> The only thing I don't love about the batching is that we now do hold
> the lock over some situations where we _could_ have allowed
> concurrency (notably some avc allocations), but I think it's a good
> trade-off. And walking the list twice at unlink_anon_vmas() should be
> basically free.

Applying load with those two patches applied (combined patch shown at
the bottom, in case you can tell me I misunderstood what to apply,
and have got the wrong combination on), lockdep very soon protested.

I've not given it _any_ thought, and won't be able to come back to
it for a couple of hours: chucked over the wall for your delectation.

Hugh

[   65.981291] =================================
[   65.981354] [ INFO: inconsistent lock state ]
[   65.981393] 3.0.0-rc3 #2
[   65.981418] ---------------------------------
[   65.981456] inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
[   65.981513] cp/1335 [HC0[0]:SC0[0]:HE1:SE1] takes:
[   65.981556]  (&anon_vma->mutex){+.+.?.}, at: [<781ba4b3>] page_lock_anon_vma+0xd6/0x130
[   65.981644] {RECLAIM_FS-ON-W} state was registered at:
[   65.981688]   [<7817954f>] mark_held_locks+0x46/0x67
[   65.981738]   [<78179a1c>] lockdep_trace_alloc+0x7d/0x96
[   65.981791]   [<781c8572>] kmem_cache_alloc+0x21/0xe1
[   65.981842]   [<781baae9>] anon_vma_clone+0x38/0x124
[   65.981892]   [<781babf7>] anon_vma_fork+0x22/0xf3
[   65.981940]   [<7814f971>] dup_mmap+0x1b7/0x302
[   65.981986]   [<78150063>] dup_mm+0xa5/0x150
[   65.982030]   [<7815075c>] copy_process+0x62e/0xbeb
[   65.982079]   [<78150e1d>] do_fork+0xd5/0x1fc
[   65.982123]   [<7812ca7c>] sys_clone+0x1c/0x21
[   65.982169]   [<78500c31>] ptregs_clone+0x15/0x24
[   65.982218] irq event stamp: 4625633
[   65.982251] hardirqs last  enabled at (4625633): [<784fe18a>] mutex_trylock+0xe7/0x118
[   65.982323] hardirqs last disabled at (4625632): [<784fe0f0>] mutex_trylock+0x4d/0x118
[   65.982394] softirqs last  enabled at (4624962): [<781568a6>] __do_softirq+0xf5/0x104
[   65.982467] softirqs last disabled at (4624835): [<78128007>] do_softirq+0x56/0xa7
[   65.982537] 
[   65.982538] other info that might help us debug this:
[   65.982595]  Possible unsafe locking scenario:
[   65.982596] 
[   65.982649]        CPU0
[   65.982672]        ----
[   65.982696]   lock(&anon_vma->mutex);
[   65.982738]   <Interrupt>
[   65.982762]     lock(&anon_vma->mutex);
[   65.982805] 
[   65.982806]  *** DEADLOCK ***
[   65.982807] 
[   65.982864] no locks held by cp/1335.
[   65.982896] 
[   65.982897] stack backtrace:
[   65.982939] Pid: 1335, comm: cp Not tainted 3.0.0-rc3 #2
[   65.984010] Call Trace:
[   65.984010]  [<784fd0d6>] ? printk+0xf/0x11
[   65.984010]  [<78177ef2>] print_usage_bug+0x152/0x15f
[   65.984010]  [<78177fa0>] mark_lock_irq+0xa1/0x1e9
[   65.984010]  [<78176c8d>] ? print_irq_inversion_bug+0x16e/0x16e
[   65.984010]  [<781782f3>] mark_lock+0x20b/0x2d9
[   65.984010]  [<781784bf>] mark_irqflags+0xfe/0x115
[   65.984010]  [<781789cb>] __lock_acquire+0x4f5/0x6ba
[   65.984010]  [<78178f72>] lock_acquire+0x4a/0x60
[   65.984010]  [<781ba4b3>] ? page_lock_anon_vma+0xd6/0x130
[   65.984010]  [<781ba4b3>] ? page_lock_anon_vma+0xd6/0x130
[   65.984010]  [<784feaf4>] mutex_lock_nested+0x45/0x297
[   65.984010]  [<781ba4b3>] ? page_lock_anon_vma+0xd6/0x130
[   65.984010]  [<781ba4b3>] page_lock_anon_vma+0xd6/0x130
[   65.984010]  [<781ba48f>] ? page_lock_anon_vma+0xb2/0x130
[   65.984010]  [<781ba6c0>] page_referenced_anon+0x12/0x189
[   65.984010]  [<781ba8ba>] page_referenced+0x83/0xaf
[   65.984010]  [<781a8301>] shrink_active_list+0x186/0x240
[   65.984010]  [<781a8e1f>] shrink_zone+0x158/0x1ce
[   65.984010]  [<781a949b>] shrink_zones+0x94/0xe4
[   65.984010]  [<781a9545>] do_try_to_free_pages+0x5a/0x1db
[   65.984010]  [<781a301d>] ? get_page_from_freelist+0x2c4/0x2e1
[   65.984010]  [<781a9865>] try_to_free_pages+0x6c/0x73
[   65.984010]  [<781a3526>] __alloc_pages_nodemask+0x3aa/0x563
[   65.984010]  [<781a4d03>] __do_page_cache_readahead+0xee/0x1cd
[   65.984010]  [<781a4fa4>] ra_submit+0x19/0x1b
[   65.984010]  [<781a51b4>] ondemand_readahead+0x20e/0x219
[   65.984010]  [<781a525b>] page_cache_sync_readahead+0x3e/0x4b
[   65.984010]  [<7819e0ad>] do_generic_file_read.clone.0+0xd1/0x420
[   65.984010]  [<78178c14>] ? lock_release_non_nested+0x84/0x243
[   65.984010]  [<7819ef25>] generic_file_aio_read+0x1c0/0x1f4
[   65.984010]  [<78178ed7>] ? __lock_release+0x104/0x10f
[   65.984010]  [<781b16d0>] ? might_fault+0x45/0x84
[   65.984010]  [<781d3650>] do_sync_read+0x91/0xc5
[   65.984010]  [<781d71a8>] ? cp_new_stat64+0xd8/0xed
[   65.984010]  [<781d3cac>] vfs_read+0x8d/0xf5
[   65.984010]  [<781d3d50>] sys_read+0x3c/0x63
[   65.984010]  [<78500b50>] sysenter_do_call+0x12/0x36

>From this combined patch applied to 3.0-rc3:

--- 3.0-rc3/mm/rmap.c	2011-05-29 18:42:37.465882779 -0700
+++ linux/mm/rmap.c	2011-06-17 10:19:10.592857382 -0700
@@ -200,6 +200,32 @@ int anon_vma_prepare(struct vm_area_stru
 	return -ENOMEM;
 }
 
+/*
+ * This is a useful helper function for locking the anon_vma root as
+ * we traverse the vma->anon_vma_chain, looping over anon_vma's that
+ * have the same vma.
+ *
+ * Such anon_vma's should have the same root, so you'd expect to see
+ * just a single mutex_lock for the whole traversal.
+ */
+static inline struct anon_vma *lock_anon_vma_root(struct anon_vma *root, struct anon_vma *anon_vma)
+{
+	struct anon_vma *new_root = anon_vma->root;
+	if (new_root != root) {
+		if (WARN_ON_ONCE(root))
+			mutex_unlock(&root->mutex);
+		root = new_root;
+		mutex_lock(&root->mutex);
+	}
+	return root;
+}
+
+static inline void unlock_anon_vma_root(struct anon_vma *root)
+{
+	if (root)
+		mutex_unlock(&root->mutex);
+}
+
 static void anon_vma_chain_link(struct vm_area_struct *vma,
 				struct anon_vma_chain *avc,
 				struct anon_vma *anon_vma)
@@ -208,13 +234,11 @@ static void anon_vma_chain_link(struct v
 	avc->anon_vma = anon_vma;
 	list_add(&avc->same_vma, &vma->anon_vma_chain);
 
-	anon_vma_lock(anon_vma);
 	/*
 	 * It's critical to add new vmas to the tail of the anon_vma,
 	 * see comment in huge_memory.c:__split_huge_page().
 	 */
 	list_add_tail(&avc->same_anon_vma, &anon_vma->head);
-	anon_vma_unlock(anon_vma);
 }
 
 /*
@@ -224,16 +248,23 @@ static void anon_vma_chain_link(struct v
 int anon_vma_clone(struct vm_area_struct *dst, struct vm_area_struct *src)
 {
 	struct anon_vma_chain *avc, *pavc;
+	struct anon_vma *root = NULL;
 
 	list_for_each_entry_reverse(pavc, &src->anon_vma_chain, same_vma) {
+		struct anon_vma *anon_vma;
+
 		avc = anon_vma_chain_alloc();
 		if (!avc)
 			goto enomem_failure;
-		anon_vma_chain_link(dst, avc, pavc->anon_vma);
+		anon_vma = pavc->anon_vma;
+		root = lock_anon_vma_root(root, anon_vma);
+		anon_vma_chain_link(dst, avc, anon_vma);
 	}
+	unlock_anon_vma_root(root);
 	return 0;
 
  enomem_failure:
+	unlock_anon_vma_root(root);
 	unlink_anon_vmas(dst);
 	return -ENOMEM;
 }
@@ -280,7 +311,9 @@ int anon_vma_fork(struct vm_area_struct
 	get_anon_vma(anon_vma->root);
 	/* Mark this anon_vma as the one where our new (COWed) pages go. */
 	vma->anon_vma = anon_vma;
+	anon_vma_lock(anon_vma);
 	anon_vma_chain_link(vma, avc, anon_vma);
+	anon_vma_unlock(anon_vma);
 
 	return 0;
 
@@ -291,36 +324,42 @@ int anon_vma_fork(struct vm_area_struct
 	return -ENOMEM;
 }
 
-static void anon_vma_unlink(struct anon_vma_chain *anon_vma_chain)
-{
-	struct anon_vma *anon_vma = anon_vma_chain->anon_vma;
-	int empty;
-
-	/* If anon_vma_fork fails, we can get an empty anon_vma_chain. */
-	if (!anon_vma)
-		return;
-
-	anon_vma_lock(anon_vma);
-	list_del(&anon_vma_chain->same_anon_vma);
-
-	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head);
-	anon_vma_unlock(anon_vma);
-
-	if (empty)
-		put_anon_vma(anon_vma);
-}
-
 void unlink_anon_vmas(struct vm_area_struct *vma)
 {
 	struct anon_vma_chain *avc, *next;
+	struct anon_vma *root = NULL;
 
 	/*
 	 * Unlink each anon_vma chained to the VMA.  This list is ordered
 	 * from newest to oldest, ensuring the root anon_vma gets freed last.
 	 */
 	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
-		anon_vma_unlink(avc);
+		struct anon_vma *anon_vma = avc->anon_vma;
+
+		/* If anon_vma_fork fails, we can get an empty anon_vma_chain. */
+		if (anon_vma) {
+			root = lock_anon_vma_root(root, anon_vma);
+			list_del(&avc->same_anon_vma);
+			/* Leave empty anon_vmas on the list. */
+			if (list_empty(&anon_vma->head))
+				continue;
+		}
+		list_del(&avc->same_vma);
+		anon_vma_chain_free(avc);
+	}
+	unlock_anon_vma_root(root);
+
+	/*
+	 * Iterate the list once more, it now only contains empty and unlinked
+	 * anon_vmas, destroy them. Could not do before due to __put_anon_vma()
+	 * needing to acquire the anon_vma->root->mutex.
+	 */
+	list_for_each_entry_safe(avc, next, &vma->anon_vma_chain, same_vma) {
+		struct anon_vma *anon_vma = avc->anon_vma;
+
+		if (anon_vma)
+			put_anon_vma(anon_vma);
+
 		list_del(&avc->same_vma);
 		anon_vma_chain_free(avc);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
