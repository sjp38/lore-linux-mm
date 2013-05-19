Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id D2E326B0078
	for <linux-mm@kvack.org>; Sun, 19 May 2013 16:08:12 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v7 21/34] shrinker: convert remaining shrinkers to count/scan API
Date: Mon, 20 May 2013 00:07:14 +0400
Message-Id: <1368994047-5997-22-git-send-email-glommer@openvz.org>
In-Reply-To: <1368994047-5997-1-git-send-email-glommer@openvz.org>
References: <1368994047-5997-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, Dave Chinner <david@fromorbit.com>, hughd@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Chuck Lever <chuck.lever@oracle.com>, "J. Bruce Fields" <bfields@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>

From: Dave Chinner <dchinner@redhat.com>

Convert the remaining couple of random shrinkers in the tree to the
new API.

Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
CC: Marcelo Tosatti <mtosatti@redhat.com>
CC: Gleb Natapov <gleb@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>
CC: J. Bruce Fields <bfields@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 arch/x86/kvm/mmu.c | 28 +++++++++++++++++++++-------
 net/sunrpc/auth.c  | 45 +++++++++++++++++++++++++++++++--------------
 2 files changed, 52 insertions(+), 21 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 004cc87..19b4edf 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -4212,13 +4212,14 @@ restart:
 	spin_unlock(&kvm->mmu_lock);
 }
 
-static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
+static long
+mmu_shrink_scan(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
 {
 	struct kvm *kvm;
 	int nr_to_scan = sc->nr_to_scan;
-
-	if (nr_to_scan == 0)
-		goto out;
+	long freed = 0;
 
 	raw_spin_lock(&kvm_lock);
 
@@ -4246,24 +4247,37 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
 		idx = srcu_read_lock(&kvm->srcu);
 		spin_lock(&kvm->mmu_lock);
 
-		prepare_zap_oldest_mmu_page(kvm, &invalid_list);
+		freed += prepare_zap_oldest_mmu_page(kvm, &invalid_list);
 		kvm_mmu_commit_zap_page(kvm, &invalid_list);
 
 		spin_unlock(&kvm->mmu_lock);
 		srcu_read_unlock(&kvm->srcu, idx);
 
+		/*
+		 * unfair on small ones
+		 * per-vm shrinkers cry out
+		 * sadness comes quickly
+		 */
 		list_move_tail(&kvm->vm_list, &vm_list);
 		break;
 	}
 
 	raw_spin_unlock(&kvm_lock);
+	return freed;
 
-out:
+}
+
+static long
+mmu_shrink_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+{
 	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
 }
 
 static struct shrinker mmu_shrinker = {
-	.shrink = mmu_shrink,
+	.count_objects = mmu_shrink_count,
+	.scan_objects = mmu_shrink_scan,
 	.seeks = DEFAULT_SEEKS * 10,
 };
 
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index ed2fdd2..9ce0976 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -413,12 +413,13 @@ EXPORT_SYMBOL_GPL(rpcauth_destroy_credcache);
 /*
  * Remove stale credentials. Avoid sleeping inside the loop.
  */
-static int
+static long
 rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 {
 	spinlock_t *cache_lock;
 	struct rpc_cred *cred, *next;
 	unsigned long expired = jiffies - RPC_AUTH_EXPIRY_MORATORIUM;
+	long freed = 0;
 
 	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
 
@@ -430,10 +431,11 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 		 */
 		if (time_in_range(cred->cr_expire, expired, jiffies) &&
 		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
-			return 0;
+			break;
 
 		list_del_init(&cred->cr_lru);
 		number_cred_unused--;
+		freed++;
 		if (atomic_read(&cred->cr_count) != 0)
 			continue;
 
@@ -446,29 +448,43 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 		}
 		spin_unlock(cache_lock);
 	}
-	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
+	return freed;
 }
 
 /*
  * Run memory cache shrinker.
  */
-static int
-rpcauth_cache_shrinker(struct shrinker *shrink, struct shrink_control *sc)
+static long
+rpcauth_cache_shrink_scan(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+
 {
 	LIST_HEAD(free);
-	int res;
-	int nr_to_scan = sc->nr_to_scan;
-	gfp_t gfp_mask = sc->gfp_mask;
+	long freed;
+
+	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		return -1;
 
-	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+	/* nothing left, don't come back */
 	if (list_empty(&cred_unused))
-		return 0;
+		return -1;
+
 	spin_lock(&rpc_credcache_lock);
-	res = rpcauth_prune_expired(&free, nr_to_scan);
+	freed = rpcauth_prune_expired(&free, sc->nr_to_scan);
 	spin_unlock(&rpc_credcache_lock);
 	rpcauth_destroy_credlist(&free);
-	return res;
+
+	return freed;
+}
+
+static long
+rpcauth_cache_shrink_count(
+	struct shrinker		*shrink,
+	struct shrink_control	*sc)
+
+{
+	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
 }
 
 /*
@@ -784,7 +800,8 @@ rpcauth_uptodatecred(struct rpc_task *task)
 }
 
 static struct shrinker rpc_cred_shrinker = {
-	.shrink = rpcauth_cache_shrinker,
+	.count_objects = rpcauth_cache_shrink_count,
+	.scan_objects = rpcauth_cache_shrink_scan,
 	.seeks = DEFAULT_SEEKS,
 };
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
