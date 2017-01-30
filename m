Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 603E86B0274
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 204so441476540pge.5
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:38:29 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u67si11371107pfd.124.2017.01.29.19.38.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:38:28 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YNKC062657
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:28 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 289td6d5dj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:27 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:38:25 +1000
Received: from d23relay06.au.ibm.com (d23relay06.au.ibm.com [9.185.63.219])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 297C22CE8057
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:22 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3cEGp22020332
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:22 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3bnll020854
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:37:49 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC V2 09/12] mm: Exclude CDM marked VMAs from auto NUMA
Date: Mon, 30 Jan 2017 09:05:50 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-10-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Kernel cannot track device memory accesses behind VMAs containing CDM
memory. Hence all the VM_CDM marked VMAs should not be part of the auto
NUMA migration scheme. This patch also adds a new function is_cdm_vma()
to detect any VMA marked with flag VM_CDM.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mempolicy.h | 14 ++++++++++++++
 kernel/sched/fair.c       |  3 ++-
 2 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5f4d828..ff0c6bc 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -172,6 +172,20 @@ extern int mpol_parse_str(char *str, struct mempolicy **mpol);
 
 extern void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
 
+#ifdef CONFIG_COHERENT_DEVICE
+static inline bool is_cdm_vma(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_CDM)
+		return true;
+	return false;
+}
+#else
+static inline bool is_cdm_vma(struct vm_area_struct *vma)
+{
+	return false;
+}
+#endif
+
 /* Check if a vma is migratable */
 static inline bool vma_migratable(struct vm_area_struct *vma)
 {
diff --git a/kernel/sched/fair.c b/kernel/sched/fair.c
index 6559d19..523508c 100644
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -2482,7 +2482,8 @@ void task_numa_work(struct callback_head *work)
 	}
 	for (; vma; vma = vma->vm_next) {
 		if (!vma_migratable(vma) || !vma_policy_mof(vma) ||
-			is_vm_hugetlb_page(vma) || (vma->vm_flags & VM_MIXEDMAP)) {
+			is_vm_hugetlb_page(vma) || is_cdm_vma(vma) ||
+					(vma->vm_flags & VM_MIXEDMAP)) {
 			continue;
 		}
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
