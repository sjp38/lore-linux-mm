Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B36B6B0006
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:54:20 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id v10so1252518wra.15
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:54:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h31si90751ede.397.2018.03.13.05.54.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 05:54:19 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DCnEDb032946
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:54:17 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gpcwkpjen-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:54:16 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 12:54:14 -0000
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH 1/8] Uprobe: Export vaddr <-> offset conversion functions
Date: Tue, 13 Mar 2018 18:25:56 +0530
In-Reply-To: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180313125603.19819-2-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

No functionality changes.

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
---
 include/linux/mm.h      | 12 ++++++++++++
 kernel/events/uprobes.c | 10 ----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ad06d42..95909f2 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2274,6 +2274,18 @@ struct vm_unmapped_area_info {
 		return unmapped_area(info);
 }
 
+static inline unsigned long
+offset_to_vaddr(struct vm_area_struct *vma, loff_t offset)
+{
+	return vma->vm_start + offset - ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
+}
+
+static inline loff_t
+vaddr_to_offset(struct vm_area_struct *vma, unsigned long vaddr)
+{
+	return ((loff_t)vma->vm_pgoff << PAGE_SHIFT) + (vaddr - vma->vm_start);
+}
+
 /* truncate.c */
 extern void truncate_inode_pages(struct address_space *, loff_t);
 extern void truncate_inode_pages_range(struct address_space *,
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index ce6848e..bd6f230 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -130,16 +130,6 @@ static bool valid_vma(struct vm_area_struct *vma, bool is_register)
 	return vma->vm_file && (vma->vm_flags & flags) == VM_MAYEXEC;
 }
 
-static unsigned long offset_to_vaddr(struct vm_area_struct *vma, loff_t offset)
-{
-	return vma->vm_start + offset - ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
-}
-
-static loff_t vaddr_to_offset(struct vm_area_struct *vma, unsigned long vaddr)
-{
-	return ((loff_t)vma->vm_pgoff << PAGE_SHIFT) + (vaddr - vma->vm_start);
-}
-
 /**
  * __replace_page - replace page in vma by new page.
  * based on replace_page in mm/ksm.c
-- 
1.8.3.1
