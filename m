Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9AF3A6B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 02:09:07 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p2so29410583pfk.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 23:09:07 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id 184si8296808pfg.115.2017.10.09.23.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 23:09:05 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, swap: Use page-cluster as max window of VMA based swap readahead
Date: Tue, 10 Oct 2017 14:08:55 +0800
Message-Id: <20171010060855.17798-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Fengguang Wu <fengguang.wu@intel.com>, Tim Chen <tim.c.chen@intel.com>, Dave Hansen <dave.hansen@intel.com>

From: Huang Ying <ying.huang@intel.com>

When the VMA based swap readahead was introduced, a new knob

  /sys/kernel/mm/swap/vma_ra_max_order

was added as the max window of VMA swap readahead.  This is to make it
possible to use different max window for VMA based readahead and
original physical readahead.  But Minchan Kim pointed out that this
will cause a regression because setting page-cluster sysctl to zero
cannot disable swap readahead with the change.

To fix the regression, the page-cluster sysctl is used as the max
window of both the VMA based swap readahead and original physical swap
readahead.  If more fine grained control is needed in the future, more
knobs can be added as the subordinate knobs of the page-cluster
sysctl.

The vma_ra_max_order knob is deleted.  Because the knob was
introduced in v4.14-rc1, and this patch is targeting being merged
before v4.14 releasing, there should be no existing users of this
newly added ABI.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Shaohua Li <shli@kernel.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Cc: Tim Chen <tim.c.chen@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Reported-by: Minchan Kim <minchan@kernel.org>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 Documentation/ABI/testing/sysfs-kernel-mm-swap | 10 ---------
 mm/swap_state.c                                | 31 ++------------------------
 2 files changed, 2 insertions(+), 39 deletions(-)

diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-swap b/Documentation/ABI/testing/sysfs-kernel-mm-swap
index 587db52084c7..94672016c268 100644
--- a/Documentation/ABI/testing/sysfs-kernel-mm-swap
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-swap
@@ -14,13 +14,3 @@ Description:	Enable/disable VMA based swap readahead.
 		still used for tmpfs etc. other users.  If set to
 		false, the global swap readahead algorithm will be
 		used for all swappable pages.
-
-What:		/sys/kernel/mm/swap/vma_ra_max_order
-Date:		August 2017
-Contact:	Linux memory management mailing list <linux-mm@kvack.org>
-Description:	The max readahead size in order for VMA based swap readahead
-
-		VMA based swap readahead algorithm will readahead at
-		most 1 << max_order pages for each readahead.  The
-		real readahead size for each readahead will be scaled
-		according to the estimation algorithm.
diff --git a/mm/swap_state.c b/mm/swap_state.c
index ed91091d1e68..4d01ecff62d9 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -39,10 +39,6 @@ struct address_space *swapper_spaces[MAX_SWAPFILES];
 static unsigned int nr_swapper_spaces[MAX_SWAPFILES];
 bool swap_vma_readahead = true;
 
-#define SWAP_RA_MAX_ORDER_DEFAULT	3
-
-static int swap_ra_max_order = SWAP_RA_MAX_ORDER_DEFAULT;
-
 #define SWAP_RA_WIN_SHIFT	(PAGE_SHIFT / 2)
 #define SWAP_RA_HITS_MASK	((1UL << SWAP_RA_WIN_SHIFT) - 1)
 #define SWAP_RA_HITS_MAX	SWAP_RA_HITS_MASK
@@ -672,7 +668,8 @@ struct page *swap_readahead_detect(struct vm_fault *vmf,
 	if (page)
 		return page;
 
-	max_win = 1 << READ_ONCE(swap_ra_max_order);
+	max_win = 1 << min_t(unsigned int, READ_ONCE(page_cluster),
+			     SWAP_RA_ORDER_CEILING);
 	if (max_win == 1) {
 		swap_ra->win = 1;
 		return NULL;
@@ -786,32 +783,8 @@ static struct kobj_attribute vma_ra_enabled_attr =
 	__ATTR(vma_ra_enabled, 0644, vma_ra_enabled_show,
 	       vma_ra_enabled_store);
 
-static ssize_t vma_ra_max_order_show(struct kobject *kobj,
-				     struct kobj_attribute *attr, char *buf)
-{
-	return sprintf(buf, "%d\n", swap_ra_max_order);
-}
-static ssize_t vma_ra_max_order_store(struct kobject *kobj,
-				      struct kobj_attribute *attr,
-				      const char *buf, size_t count)
-{
-	int err, v;
-
-	err = kstrtoint(buf, 10, &v);
-	if (err || v > SWAP_RA_ORDER_CEILING || v <= 0)
-		return -EINVAL;
-
-	swap_ra_max_order = v;
-
-	return count;
-}
-static struct kobj_attribute vma_ra_max_order_attr =
-	__ATTR(vma_ra_max_order, 0644, vma_ra_max_order_show,
-	       vma_ra_max_order_store);
-
 static struct attribute *swap_attrs[] = {
 	&vma_ra_enabled_attr.attr,
-	&vma_ra_max_order_attr.attr,
 	NULL,
 };
 
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
