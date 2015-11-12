Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4DCF36B0254
	for <linux-mm@kvack.org>; Thu, 12 Nov 2015 12:11:25 -0500 (EST)
Received: by igvg19 with SMTP id g19so18738843igv.1
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 09:11:25 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.180.66])
        by mx.google.com with ESMTP id f133si19154340ioe.30.2015.11.12.09.11.24
        for <linux-mm@kvack.org>;
        Thu, 12 Nov 2015 09:11:24 -0800 (PST)
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: [RFC] mempolicy: convert the shared_policy lock to a rwlock
Date: Thu, 12 Nov 2015 11:11:03 -0600
Message-Id: <1447348263-131817-1-git-send-email-nzimmer@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Nathan Zimmer <nzimmer@sgi.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

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

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Nathan Zimmer <nzimmer@sgi.com>
---
 include/linux/mempolicy.h |  2 +-
 mm/mempolicy.c            | 16 ++++++++--------
 2 files changed, 9 insertions(+), 9 deletions(-)

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
index 87a1779..ebf82a3 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
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
