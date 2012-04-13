Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id F2B146B0083
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 18:38:44 -0400 (EDT)
Received: by faas16 with SMTP id s16so175628faa.2
        for <linux-mm@kvack.org>; Fri, 13 Apr 2012 15:38:43 -0700 (PDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] kvm: don't call mmu_shrinker w/o used_mmu_pages
Date: Fri, 13 Apr 2012 15:38:41 -0700
Message-Id: <1334356721-9009-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org

The mmu_shrink() is heavy by itself by iterating all kvms and holding
the kvm_lock. spotted the code w/ Rik during LSF, and it turns out we
don't need to call the shrinker if nothing to shrink.

Signed-off-by: Ying Han <yinghan@google.com>
---
 arch/x86/kvm/mmu.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/arch/x86/kvm/mmu.c b/arch/x86/kvm/mmu.c
index 4cb1642..7025736 100644
--- a/arch/x86/kvm/mmu.c
+++ b/arch/x86/kvm/mmu.c
@@ -188,6 +188,11 @@ static u64 __read_mostly shadow_mmio_mask;
 
 static void mmu_spte_set(u64 *sptep, u64 spte);
 
+static inline int get_kvm_total_used_mmu_pages()
+{
+	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
+}
+
 void kvm_mmu_set_mmio_spte_mask(u64 mmio_mask)
 {
 	shadow_mmio_mask = mmio_mask;
@@ -3900,6 +3905,9 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
 	if (nr_to_scan == 0)
 		goto out;
 
+	if (!get_kvm_total_used_mmu_pages())
+		return 0;
+
 	raw_spin_lock(&kvm_lock);
 
 	list_for_each_entry(kvm, &vm_list, vm_list) {
@@ -3926,7 +3934,7 @@ static int mmu_shrink(struct shrinker *shrink, struct shrink_control *sc)
 	raw_spin_unlock(&kvm_lock);
 
 out:
-	return percpu_counter_read_positive(&kvm_total_used_mmu_pages);
+	return get_kvm_total_used_mmu_pages();
 }
 
 static struct shrinker mmu_shrinker = {
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
