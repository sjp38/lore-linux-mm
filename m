Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 136FD6B0075
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 16:35:33 -0400 (EDT)
From: Glauber Costa <glommer@openvz.org>
Subject: [PATCH v11 22/25] shrinker: convert remaining shrinkers to count/scan API
Date: Fri,  7 Jun 2013 00:34:55 +0400
Message-Id: <1370550898-26711-23-git-send-email-glommer@openvz.org>
In-Reply-To: <1370550898-26711-1-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Glauber Costa <glommer@openvz.org>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Chuck Lever <chuck.lever@oracle.com>, "J. Bruce Fields" <bfields@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>

From: Dave Chinner <dchinner@redhat.com>

Convert the remaining couple of random shrinkers in the tree to the
new API.

[ v11: fix coding style ]
Signed-off-by: Dave Chinner <dchinner@redhat.com>
Signed-off-by: Glauber Costa <glommer@openvz.org>
CC: Marcelo Tosatti <mtosatti@redhat.com>
CC: Gleb Natapov <gleb@redhat.com>
CC: Chuck Lever <chuck.lever@oracle.com>
CC: J. Bruce Fields <bfields@redhat.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 arch/x86/kvm/mmu.c | 24 +++++++++++++++++-------
 net/sunrpc/auth.c  | 41 +++++++++++++++++++++++++++--------------
 2 files changed, 44 insertions(+), 21 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index f8ca2f3..422493d 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -4213,13 +4213,12 @@ restart:
 	spin_unlock(&kvm->mmu_lock);
 }
 
-static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
+static long
+mmu_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct kvm *kvm;
 	int nr_to_scan = sc->nr_to_scan;
-
-	if (nr_to_scan == 0)
-		goto out;
+	long freed = 0;
 
 	raw_spin_lock(&kvm_lock);
 
@@ -4247,24 +4246,35 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
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
+mmu_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
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
index ed2fdd2..fdc012d 100644
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
 
@@ -446,29 +448,39 @@ rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
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
+rpcauth_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
+
 {
 	LIST_HEAD(free);
-	int res;
-	int nr_to_scan = sc->nr_to_scan;
-	gfp_t gfp_mask = sc->gfp_mask;
+	long freed;
+
+	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
+		return SHRINK_STOP;
 
-	if ((gfp_mask & GFP_KERNEL) != GFP_KERNEL)
-		return (nr_to_scan == 0) ? 0 : -1;
+	/* nothing left, don't come back */
 	if (list_empty(&cred_unused))
-		return 0;
+		return SHRINK_STOP;
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
+rpcauth_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
+
+{
+	return (number_cred_unused / 100) * sysctl_vfs_cache_pressure;
 }
 
 /*
@@ -784,7 +796,8 @@ rpcauth_uptodatecred(struct rpc_task *task)
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
