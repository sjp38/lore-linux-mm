Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E3DEB6B0261
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n18so6382517pfe.7
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id zx17si384740pab.11.2016.10.23.21.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:29 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4T0rP034134
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:28 -0400
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com [125.16.236.8])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2694e04grh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:28 -0400
Received: from localhost
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:25 +0530
Received: from d28relay10.in.ibm.com (d28relay10.in.ibm.com [9.184.220.161])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 9496E3940068
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:22 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay10.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4W21f35455032
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:02 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WJ9c020988
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:21 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 6/8] mm: Make VM_CDM marked VMAs non migratable
Date: Mon, 24 Oct 2016 10:01:55 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-7-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

Auto NUMA does migratability check on any given VMA before scanning it for
marking purpose. For now if the coherent device memory has been faulted in
or migrated into a process VMA, it should not be part of the auto NUMA
migration scheme. The check is based on VM_CDM flag.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 include/linux/mempolicy.h | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5e5b296..09d4b70 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -171,9 +171,26 @@ extern int mpol_parse_str(char *str, struct mempolicy **mpol);
 
 extern void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol);
 
+#ifdef CONFIG_COHERENT_DEVICE
+static bool is_cdm_vma(struct vm_area_struct *vma)
+{
+	if (vma->vm_flags & VM_CDM)
+		return true;
+	return false;
+}
+#else
+static bool is_cdm_vma(struct vm_area_struct *vma)
+{
+	return false;
+}
+#endif
+
 /* Check if a vma is migratable */
 static inline bool vma_migratable(struct vm_area_struct *vma)
 {
+	if (is_cdm_vma(vma))
+		return false;
+
 	if (vma->vm_flags & (VM_IO | VM_PFNMAP))
 		return false;
 
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
