Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5C19C6B0038
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 18:31:11 -0400 (EDT)
Date: Thu, 6 Jun 2013 15:31:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v11 22/25] shrinker: convert remaining shrinkers to
 count/scan API
Message-Id: <20130606153109.cd042659b133c607e612d927@linux-foundation.org>
In-Reply-To: <1370550898-26711-23-git-send-email-glommer@openvz.org>
References: <1370550898-26711-1-git-send-email-glommer@openvz.org>
	<1370550898-26711-23-git-send-email-glommer@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@openvz.org>
Cc: linux-fsdevel@vger.kernel.org, mgorman@suse.de, david@fromorbit.com, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suze.cz, hannes@cmpxchg.org, hughd@google.com, gthelen@google.com, Dave Chinner <dchinner@redhat.com>, Marcelo Tosatti <mtosatti@redhat.com>, Gleb Natapov <gleb@redhat.com>, Chuck Lever <chuck.lever@oracle.com>, "J. Bruce Fields" <bfields@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>

On Fri,  7 Jun 2013 00:34:55 +0400 Glauber Costa <glommer@openvz.org> wrote:

> From: Dave Chinner <dchinner@redhat.com>
> 
> Convert the remaining couple of random shrinkers in the tree to the
> new API.
> 
> @@ -4247,24 +4246,35 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
>  		idx = srcu_read_lock(&kvm->srcu);
>  		spin_lock(&kvm->mmu_lock);
>  
> -		prepare_zap_oldest_mmu_page(kvm, &invalid_list);
> +		freed += prepare_zap_oldest_mmu_page(kvm, &invalid_list);

prepare_zap_oldest_mmu_page() returns bool.  Adding it to a scalar is
weird.  I did this:


From: Andrew Morton <akpm@linux-foundation.org>
Subject: shrinker-convert-remaining-shrinkers-to-count-scan-api-fix

fix warnings

Cc: Dave Chinner <dchinner@redhat.com>
Cc: Glauber Costa <glommer@openvz.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 arch/x86/kvm/mmu.c |    9 +++++----
 net/sunrpc/auth.c  |    6 +++---
 2 files changed, 8 insertions(+), 7 deletions(-)

diff -puN arch/x86/kvm/mmu.c~shrinker-convert-remaining-shrinkers-to-count-scan-api-fix arch/x86/kvm/mmu.c
--- a/arch/x86/kvm/mmu.c~shrinker-convert-remaining-shrinkers-to-count-scan-api-fix
+++ a/arch/x86/kvm/mmu.c
@@ -4213,12 +4213,12 @@ restart:
 	spin_unlock(&kvm->mmu_lock);
 }
 
-static long
+static unsigned long
 mmu_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 {
 	struct kvm *kvm;
 	int nr_to_scan = sc->nr_to_scan;
-	long freed = 0;
+	unsigned long freed = 0;
 
 	raw_spin_lock(&kvm_lock);
 
@@ -4246,7 +4246,8 @@ mmu_shrink_scan(struct shrinker *shrink,
 		idx = srcu_read_lock(&kvm->srcu);
 		spin_lock(&kvm->mmu_lock);
 
-		freed += prepare_zap_oldest_mmu_page(kvm, &invalid_list);
+		if (prepare_zap_oldest_mmu_page(kvm, &invalid_list))
+			freed++;
 		kvm_mmu_commit_zap_page(kvm, &invalid_list);
 
 		spin_unlock(&kvm->mmu_lock);
@@ -4266,7 +4267,7 @@ mmu_shrink_scan(struct shrinker *shrink,
 
 }
 
-static long
+static unsigned long
 mmu_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 {
 	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
diff -puN net/sunrpc/auth.c~shrinker-convert-remaining-shrinkers-to-count-scan-api-fix net/sunrpc/auth.c
--- a/net/sunrpc/auth.c~shrinker-convert-remaining-shrinkers-to-count-scan-api-fix
+++ a/net/sunrpc/auth.c
@@ -454,12 +454,12 @@ rpcauth_prune_expired(struct list_head *
 /*
  * Run memory cache shrinker.
  */
-static long
+static unsigned long
 rpcauth_cache_shrink_scan(struct shrinker *shrink, struct shrink_control *sc)
 
 {
 	LIST_HEAD(free);
-	long freed;
+	unsigned long freed;
 
 	if ((sc->gfp_mask & GFP_KERNEL) != GFP_KERNEL)
 		return SHRINK_STOP;
@@ -476,7 +476,7 @@ rpcauth_cache_shrink_scan(struct shrinke
 	return freed;
 }
 
-static long
+static unsigned long
 rpcauth_cache_shrink_count(struct shrinker *shrink, struct shrink_control *sc)
 
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
