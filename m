Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 9F66C6B0194
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:33:29 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so64231794qkg.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:29 -0700 (PDT)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id j81si1863216qkh.72.2015.05.21.12.33.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:33:28 -0700 (PDT)
Received: by qkgv12 with SMTP id v12so64231306qkg.0
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:33:28 -0700 (PDT)
From: j.glisse@gmail.com
Subject: [PATCH 04/36] mmu_notifier: allow range invalidation to exclude a specific mmu_notifier
Date: Thu, 21 May 2015 15:31:13 -0400
Message-Id: <1432236705-4209-5-git-send-email-j.glisse@gmail.com>
In-Reply-To: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
References: <1432236705-4209-1-git-send-email-j.glisse@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, joro@8bytes.org, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

This patch allow to invalidate a range while excluding call to a specific
mmu_notifier which allow for a subsystem to invalidate a range for everyone
but itself.

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/mmu_notifier.h | 60 +++++++++++++++++++++++++++++++++++++++-----
 mm/mmu_notifier.c            | 16 +++++++++---
 2 files changed, 67 insertions(+), 9 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 283ad26..867ca06 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -294,11 +294,15 @@ extern void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 					  struct page *page,
 					  enum mmu_event event);
 extern void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-						  struct mmu_notifier_range *range);
+						  struct mmu_notifier_range *range,
+						  const struct mmu_notifier *exclude);
 extern void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-						struct mmu_notifier_range *range);
+						struct mmu_notifier_range *range,
+						const struct mmu_notifier *exclude);
 extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
-				  unsigned long start, unsigned long end);
+					    unsigned long start,
+					    unsigned long end,
+					    const struct mmu_notifier *exclude);
 extern bool mmu_notifier_range_is_valid(struct mm_struct *mm,
 					unsigned long start,
 					unsigned long end);
@@ -351,21 +355,46 @@ static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 						       struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_start(mm, range);
+		__mmu_notifier_invalidate_range_start(mm, range, NULL);
 }
 
 static inline void mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 						     struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range_end(mm, range);
+		__mmu_notifier_invalidate_range_end(mm, range, NULL);
 }
 
 static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 				  unsigned long start, unsigned long end)
 {
 	if (mm_has_notifiers(mm))
-		__mmu_notifier_invalidate_range(mm, start, end);
+		__mmu_notifier_invalidate_range(mm, start, end, NULL);
+}
+
+static inline void mmu_notifier_invalidate_range_start_excluding(struct mm_struct *mm,
+						struct mmu_notifier_range *range,
+						const struct mmu_notifier *exclude)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_start(mm, range, exclude);
+}
+
+static inline void mmu_notifier_invalidate_range_end_excluding(struct mm_struct *mm,
+							struct mmu_notifier_range *range,
+							const struct mmu_notifier *exclude)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range_end(mm, range, exclude);
+}
+
+static inline void mmu_notifier_invalidate_range_excluding(struct mm_struct *mm,
+						unsigned long start,
+						unsigned long end,
+						const struct mmu_notifier *exclude)
+{
+	if (mm_has_notifiers(mm))
+		__mmu_notifier_invalidate_range(mm, start, end, exclude);
 }
 
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
@@ -515,6 +544,25 @@ static inline void mmu_notifier_invalidate_range(struct mm_struct *mm,
 {
 }
 
+static inline void mmu_notifier_invalidate_range_start_excluding(struct mm_struct *mm,
+						struct mmu_notifier_range *range,
+						const struct mmu_notifier *exclude)
+{
+}
+
+static inline void mmu_notifier_invalidate_range_end_excluding(struct mm_struct *mm,
+							struct mmu_notifier_range *range,
+							const struct mmu_notifier *exclude)
+{
+}
+
+static inline void mmu_notifier_invalidate_range_excluding(struct mm_struct *mm,
+						unsigned long start,
+						unsigned long end,
+						const struct mmu_notifier *exclude)
+{
+}
+
 static inline void mmu_notifier_mm_init(struct mm_struct *mm)
 {
 }
diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 2ff6d43..43172c6 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -175,7 +175,8 @@ void __mmu_notifier_invalidate_page(struct mm_struct *mm,
 }
 
 void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
-					   struct mmu_notifier_range *range)
+					   struct mmu_notifier_range *range,
+					   const struct mmu_notifier *exclude)
 
 {
 	struct mmu_notifier *mn;
@@ -188,6 +189,8 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn == exclude)
+			continue;
 		if (mn->ops->invalidate_range_start)
 			mn->ops->invalidate_range_start(mn, mm, range);
 	}
@@ -196,13 +199,16 @@ void __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start);
 
 void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
-					 struct mmu_notifier_range *range)
+					 struct mmu_notifier_range *range,
+					 const struct mmu_notifier *exclude)
 {
 	struct mmu_notifier *mn;
 	int id;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn == exclude)
+			continue;
 		/*
 		 * Call invalidate_range here too to avoid the need for the
 		 * subsystem of having to register an invalidate_range_end
@@ -233,13 +239,17 @@ void __mmu_notifier_invalidate_range_end(struct mm_struct *mm,
 EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_end);
 
 void __mmu_notifier_invalidate_range(struct mm_struct *mm,
-				  unsigned long start, unsigned long end)
+				     unsigned long start,
+				     unsigned long end,
+				     const struct mmu_notifier *exclude)
 {
 	struct mmu_notifier *mn;
 	int id;
 
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
+		if (mn == exclude)
+			continue;
 		if (mn->ops->invalidate_range)
 			mn->ops->invalidate_range(mn, mm, start, end);
 	}
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
