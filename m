Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0E916B0009
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:18:09 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id r204so5454171ywb.11
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:18:09 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id 65-v6si1592870ybq.515.2018.03.23.10.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:18:08 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 3/3] mm/mmu_notifier: keep track of ranges being invalidated
Date: Fri, 23 Mar 2018 13:17:48 -0400
Message-Id: <20180323171748.20359-4-jglisse@redhat.com>
In-Reply-To: <20180323171748.20359-1-jglisse@redhat.com>
References: <20180323171748.20359-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, David Rientjes <rientjes@google.com>, Joerg Roedel <joro@8bytes.org>, Dan Williams <dan.j.williams@intel.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Paolo Bonzini <pbonzini@redhat.com>, Michal Hocko <mhocko@suse.com>, Leon Romanovsky <leonro@mellanox.com>, Artemy Kovalyov <artemyko@mellanox.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Alex Deucher <alexander.deucher@amd.com>, Sudeep Dutt <sudeep.dutt@intel.com>, Ashutosh Dixit <ashutosh.dixit@intel.com>, Dimitri Sivanich <sivanich@sgi.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This keep a list of all virtual address range being invalidated (ie inside
a mmu_notifier_invalidate_range_start/end section). Also add an helper to
check if a range is under going such invalidation. With this it easy for a
concurrent thread to ignore invalidation that do not affect the virtual
address range it is working on.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Christian KA?nig <christian.koenig@amd.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Leon Romanovsky <leonro@mellanox.com>
Cc: Artemy Kovalyov <artemyko@mellanox.com>
Cc: Evgeny Baskakov <ebaskakov@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Mike Marciniszyn <mike.marciniszyn@intel.com>
Cc: Dennis Dalessandro <dennis.dalessandro@intel.com>
Cc: Alex Deucher <alexander.deucher@amd.com>
Cc: Sudeep Dutt <sudeep.dutt@intel.com>
Cc: Ashutosh Dixit <ashutosh.dixit@intel.com>
Cc: Dimitri Sivanich <sivanich@sgi.com>
---
 include/linux/mmu_notifier.h | 38 ++++++++++++++++++++++++++++++++++++++
 mm/mmu_notifier.c            | 28 ++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index e59db7a1e86d..4bda68499f43 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -47,16 +47,20 @@ struct mmu_notifier_mm {
 	struct hlist_head list;
 	/* to serialize the list modifications and hlist_unhashed */
 	spinlock_t lock;
+	/* list of all active invalidation range */
+	struct list_head ranges;
 };
 
 /*
  * struct mmu_notifier_range - range being invalidated with range_start/end
+ * @list: use to track list of active invalidation
  * @mm: mm_struct invalidation is against
  * @start: start address of range (inclusive)
  * @end: end address of range (exclusive)
  * @event: type of invalidation (see enum mmu_notifier_event)
  */
 struct mmu_notifier_range {
+	struct list_head list;
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
@@ -268,6 +272,9 @@ extern void __mmu_notifier_invalidate_range_end(
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end);
 extern bool mm_has_blockable_invalidate_notifiers(struct mm_struct *mm);
+extern bool __mmu_notifier_range_valid(struct mm_struct *mm,
+				       unsigned long start,
+				       unsigned long end);
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
 {
@@ -275,6 +282,24 @@ static inline void mmu_notifier_release(struct mm_struct *mm)
 		__mmu_notifier_release(mm);
 }
 
+static inline bool mmu_notifier_range_valid(struct mm_struct *mm,
+					    unsigned long start,
+					    unsigned long end)
+{
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_range_valid(mm, start, end);
+	return false;
+}
+
+static inline bool mmu_notifier_addr_valid(struct mm_struct *mm,
+					   unsigned long addr)
+{
+	addr &= PAGE_MASK;
+	if (mm_has_notifiers(mm))
+		return __mmu_notifier_range_valid(mm, addr, addr + PAGE_SIZE);
+	return false;
+}
+
 static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long start,
 					  unsigned long end)
@@ -487,6 +512,19 @@ static inline void mmu_notifier_release(struct mm_struct *mm)
 {
 }
 
+static inline bool mmu_notifier_range_valid(struct mm_struct *mm,
+					    unsigned long start,
+					    unsigned long end)
+{
+	return true;
+}
+
+static inline bool mmu_notifier_addr_valid(struct mm_struct *mm,
+					   unsigned long addr)
+{
+	return true;
+}
+
 static inline int mmu_notifier_clear_flush_young(struct mm_struct *mm,
 					  unsigned long start,
 					  unsigned long end)
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 91a614b9636e..d7c46eaa5d42 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -180,6 +180,10 @@ void __mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 	struct mmu_notifier *mn;
 	int id;
 
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	list_add_rcu(&range->list, &mm->mmu_notifier_mm->ranges);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
+
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start)
@@ -218,6 +222,10 @@ void __mmu_notifier_invalidate_range_end(struct mmu_notifier_range *range,
 			mn->ops->invalidate_range_end(mn, range);
 	}
 	srcu_read_unlock(&srcu, id);
+
+	spin_lock(&mm->mmu_notifier_mm->lock);
+	list_del_rcu(&range->list);
+	spin_unlock(&mm->mmu_notifier_mm->lock);
 }
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
 
@@ -288,6 +296,7 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 		goto out_clean;
 
 	if (!mm_has_notifiers(mm)) {
+		INIT_LIST_HEAD(&mmu_notifier_mm->ranges);
 		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
 		spin_lock_init(&mmu_notifier_mm->lock);
 
@@ -424,3 +433,22 @@ void mmu_notifier_unregister_no_release(struct mmu_notifier *mn,
 	mmdrop(mm);
 }
 EXPORT_SYMBOL_GPL(mmu_notifier_unregister_no_release);
+
+bool __mmu_notifier_range_valid(struct mm_struct *mm,
+				unsigned long start,
+				unsigned long end)
+{
+	struct mmu_notifier_range *range;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(range, &mm->mmu_notifier_mm->ranges, list) {
+		if (end < range->start || start >= range->end)
+			continue;
+		rcu_read_unlock();
+		return false;
+	}
+	rcu_read_unlock();
+
+	return true;
+}
+EXPORT_SYMBOL_GPL(__mmu_notifier_range_valid);
-- 
2.14.3
