Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 50D0C6B000A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:30 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id e15so15080284wrj.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 21:33:30 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id a88si1406532edf.189.2018.04.16.21.33.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 21:33:29 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H4TuxA029667
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:27 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hd67y065d-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:33:27 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 05:33:24 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v3 1/9] Uprobe: Export vaddr <-> offset conversion functions
Date: Tue, 17 Apr 2018 10:02:36 +0530
In-Reply-To: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <20180417043244.7501-2-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.ibm.com>

From: Ravi Bangoria <ravi.bangoria@linux.ibm.com>

These are generic functions which operates on file offset
and virtual address. Make these functions available outside
of uprobe code so that other can use it as well.

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 include/linux/mm.h      | 12 ++++++++++++
 kernel/events/uprobes.c | 10 ----------
 2 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index ccac106..de0cc08 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2272,6 +2272,18 @@ struct vm_unmapped_area_info {
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
