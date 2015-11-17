Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 5867D6B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 11:18:12 -0500 (EST)
Received: by igvg19 with SMTP id g19so99068881igv.1
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 08:18:12 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id v2si30685040igh.21.2015.11.17.08.18.11
        for <linux-mm@kvack.org>;
        Tue, 17 Nov 2015 08:18:11 -0800 (PST)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [PATCH] mempolicy: convert the shared_policy lock to a rwlock
Date: Tue, 17 Nov 2015 10:17:58 -0600
Message-Id: <1447777078-135492-1-git-send-email-nzimmer@sgi.com>
In-Reply-To: <alpine.DEB.2.10.1511121301490.10324@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1511121301490.10324@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

When running the SPECint_rate gcc on some very large boxes it was noticed
that the system was spending lots of time in mpol_shared_policy_lookup.
The gamess benchmark can also show it and is what I mostly used to chase
down the issue since the setup for that I found a easier.

To be clear the binaries were on tmpfs because of disk I/O reqruirements.
We then used text replication to avoid icache misses and having all the
copies banging on the memory where the instruction code resides.
This results in us hitting a bottle neck in mpol_shared_policy_lookup
since lookup is serialised by the shared_policy lock.

I have only reproduced this on very large (3k+ cores) boxes.  The problem
starts showing up at just a few hundred ranks getting worse until it
threatens to livelock once it gets large enough.
For example on the gamess benchmark at 128 ranks this area consumes only
~1% of time, at 512 ranks it consumes nearly 13%, and at 2k ranks it is
over 90%.

To alleviate the contention on this area I converted the spinslock to a
rwlock.  This allows the large number of lookups to happen simultaneously.
The results were quite good reducing this to consumtion at max ranks to
around 2%.

Acked-by: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
---
 fs/hugetlbfs/inode.c      |  2 +-
 include/linux/mempolicy.h |  2 +-
 mm/mempolicy.c            | 20 ++++++++++----------
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 316adb9..ab7b155 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -739,7 +739,7 @@ static struct inode *hugetlbfs_get_inode(struct super_block *sb,
 		/*
 		 * The policy is initialized here even if we are creating a
 		 * private inode because initialization simply creates an
-		 * an empty rb tree and calls spin_lock_init(), later when we
+		 * an empty rb tree and calls rwlock_init(), later when we
 		 * call mpol_free_shared_policy() it will just return because
 		 * the rb tree will still be empty.
 		 */
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 3d385c8..2696c1f 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -122,7 +122,7 @@ struct sp_node {
 
 struct shared_policy {
 	struct rb_root root;
-	spinlock_t lock;
+	rwlock_t lock;
 };
 
 int vma_dup_policy(struct vm_area_struct *src, struct vm_area_struct *dst);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 87a1779..197d917 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2142,7 +2142,7 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
  *
  * Remember policies even when nobody has shared memory mapped.
  * The policies are kept in Red-Black tree linked from the inode.
- * They are protected by the sp->lock spinlock, which should be held
+ * They are protected by the sp->lock rwlock, which should be held
  * for any accesses to the tree.
  */
 
@@ -2179,7 +2179,7 @@ sp_lookup(struct shared_policy *sp, unsigned long start, unsigned long end)
 }
 
 /* Insert a new shared policy into the list. */
-/* Caller holds sp->lock */
+/* Caller holds the write of sp->lock */
 static void sp_insert(struct shared_policy *sp, struct sp_node *new)
 {
 	struct rb_node **p = &sp->root.rb_node;
@@ -2211,13 +2211,13 @@ mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
 
 	if (!sp->root.rb_node)
 		return NULL;
-	spin_lock(&sp->lock);
+	read_lock(&sp->lock);
 	sn = sp_lookup(sp, idx, idx+1);
 	if (sn) {
 		mpol_get(sn->policy);
 		pol = sn->policy;
 	}
-	spin_unlock(&sp->lock);
+	read_unlock(&sp->lock);
 	return pol;
 }
 
@@ -2360,7 +2360,7 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 	int ret = 0;
 
 restart:
-	spin_lock(&sp->lock);
+	write_lock(&sp->lock);
 	n = sp_lookup(sp, start, end);
 	/* Take care of old policies in the same range. */
 	while (n && n->start < end) {
@@ -2393,7 +2393,7 @@ restart:
 	}
 	if (new)
 		sp_insert(sp, new);
-	spin_unlock(&sp->lock);
+	write_unlock(&sp->lock);
 	ret = 0;
 
 err_out:
@@ -2405,7 +2405,7 @@ err_out:
 	return ret;
 
 alloc_new:
-	spin_unlock(&sp->lock);
+	write_unlock(&sp->lock);
 	ret = -ENOMEM;
 	n_new = kmem_cache_alloc(sn_cache, GFP_KERNEL);
 	if (!n_new)
@@ -2431,7 +2431,7 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 	int ret;
 
 	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
-	spin_lock_init(&sp->lock);
+	rwlock_init(&sp->lock);
 
 	if (mpol) {
 		struct vm_area_struct pvma;
@@ -2497,14 +2497,14 @@ void mpol_free_shared_policy(struct shared_policy *p)
 
 	if (!p->root.rb_node)
 		return;
-	spin_lock(&p->lock);
+	write_lock(&p->lock);
 	next = rb_first(&p->root);
 	while (next) {
 		n = rb_entry(next, struct sp_node, nd);
 		next = rb_next(&n->nd);
 		sp_delete(p, n);
 	}
-	spin_unlock(&p->lock);
+	write_unlock(&p->lock);
 }
 
 #ifdef CONFIG_NUMA_BALANCING
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
