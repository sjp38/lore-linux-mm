Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECDBB6B0261
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 02:09:10 -0500 (EST)
Received: by mail-pa0-f71.google.com with SMTP id bi5so83411439pad.0
        for <linux-mm@kvack.org>; Sun, 13 Nov 2016 23:09:10 -0800 (PST)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20078.outbound.protection.outlook.com. [40.107.2.78])
        by mx.google.com with ESMTPS id 127si21104111pgi.128.2016.11.13.23.09.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sun, 13 Nov 2016 23:09:10 -0800 (PST)
From: Huang Shijie <shijie.huang@arm.com>
Subject: [PATCH v2 4/6] mm: mempolicy: intruduce a helper huge_nodemask()
Date: Mon, 14 Nov 2016 15:07:37 +0800
Message-ID: <1479107259-2011-5-git-send-email-shijie.huang@arm.com>
In-Reply-To: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
References: <1479107259-2011-1-git-send-email-shijie.huang@arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, catalin.marinas@arm.com
Cc: n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org, Huang Shijie <shijie.huang@arm.com>

This patch intruduces a new helper huge_nodemask(),
we can use it to get the node mask.

This idea of the function is from the huge_zonelist().

Signed-off-by: Huang Shijie <shijie.huang@arm.com>
---
 include/linux/mempolicy.h |  8 ++++++++
 mm/mempolicy.c            | 20 ++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5e5b296..01173c6 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -145,6 +145,8 @@ extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 				enum mpol_rebind_step step);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
 
+extern nodemask_t *huge_nodemask(struct vm_area_struct *vma,
+				unsigned long addr);
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask);
@@ -261,6 +263,12 @@ static inline void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 {
 }
 
+static inline nodemask_t *huge_nodemask(struct vm_area_struct *vma,
+				unsigned long addr)
+{
+	return NULL;
+}
+
 static inline struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
 				struct mempolicy **mpol, nodemask_t **nodemask)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 6d3639e..4830dd6 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1800,6 +1800,26 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 
 #ifdef CONFIG_HUGETLBFS
 /*
+ * huge_nodemask(@vma, @addr)
+ * @vma: virtual memory area whose policy is sought
+ * @addr: address in @vma for shared policy lookup and interleave policy
+ *
+ * If the effective policy is BIND, returns a pointer to the mempolicy's
+ * @nodemask.
+ */
+nodemask_t *huge_nodemask(struct vm_area_struct *vma, unsigned long addr)
+{
+	nodemask_t *nodes_mask = NULL;
+	struct mempolicy *mpol = get_vma_policy(vma, addr);
+
+	if (mpol->mode == MPOL_BIND)
+		nodes_mask = &mpol->v.nodes;
+	mpol_cond_put(mpol);
+
+	return nodes_mask;
+}
+
+/*
  * huge_zonelist(@vma, @addr, @gfp_flags, @mpol)
  * @vma: virtual memory area whose policy is sought
  * @addr: address in @vma for shared policy lookup and interleave policy
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
