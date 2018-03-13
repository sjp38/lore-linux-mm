Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id ACE436B0008
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:54:43 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id j28so11662874wrd.17
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:54:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 36si100630edk.185.2018.03.13.05.54.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 05:54:42 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DCsen0085413
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:54:41 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2gpeu6rnt7-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:54:40 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 12:54:27 -0000
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH 2/8] mm: Prefix vma_ to vaddr_to_offset() and offset_to_vaddr()
Date: Tue, 13 Mar 2018 18:25:57 +0530
In-Reply-To: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180313125603.19819-3-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

No functionality changes.

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
---
 include/linux/mm.h      |  4 ++--
 kernel/events/uprobes.c | 14 +++++++-------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 95909f2..d7ee526 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2275,13 +2275,13 @@ struct vm_unmapped_area_info {
 }
 
 static inline unsigned long
-offset_to_vaddr(struct vm_area_struct *vma, loff_t offset)
+vma_offset_to_vaddr(struct vm_area_struct *vma, loff_t offset)
 {
 	return vma->vm_start + offset - ((loff_t)vma->vm_pgoff << PAGE_SHIFT);
 }
 
 static inline loff_t
-vaddr_to_offset(struct vm_area_struct *vma, unsigned long vaddr)
+vma_vaddr_to_offset(struct vm_area_struct *vma, unsigned long vaddr)
 {
 	return ((loff_t)vma->vm_pgoff << PAGE_SHIFT) + (vaddr - vma->vm_start);
 }
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index bd6f230..535fd39 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -748,7 +748,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
 		curr = info;
 
 		info->mm = vma->vm_mm;
-		info->vaddr = offset_to_vaddr(vma, offset);
+		info->vaddr = vma_offset_to_vaddr(vma, offset);
 	}
 	i_mmap_unlock_read(mapping);
 
@@ -807,7 +807,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
 			goto unlock;
 
 		if (vma->vm_start > info->vaddr ||
-		    vaddr_to_offset(vma, info->vaddr) != uprobe->offset)
+		    vma_vaddr_to_offset(vma, info->vaddr) != uprobe->offset)
 			goto unlock;
 
 		if (is_register) {
@@ -977,7 +977,7 @@ static int unapply_uprobe(struct uprobe *uprobe, struct mm_struct *mm)
 		    uprobe->offset >= offset + vma->vm_end - vma->vm_start)
 			continue;
 
-		vaddr = offset_to_vaddr(vma, uprobe->offset);
+		vaddr = vma_offset_to_vaddr(vma, uprobe->offset);
 		err |= remove_breakpoint(uprobe, mm, vaddr);
 	}
 	up_read(&mm->mmap_sem);
@@ -1023,7 +1023,7 @@ static void build_probe_list(struct inode *inode,
 	struct uprobe *u;
 
 	INIT_LIST_HEAD(head);
-	min = vaddr_to_offset(vma, start);
+	min = vma_vaddr_to_offset(vma, start);
 	max = min + (end - start) - 1;
 
 	spin_lock(&uprobes_treelock);
@@ -1076,7 +1076,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	list_for_each_entry_safe(uprobe, u, &tmp_list, pending_list) {
 		if (!fatal_signal_pending(current) &&
 		    filter_chain(uprobe, UPROBE_FILTER_MMAP, vma->vm_mm)) {
-			unsigned long vaddr = offset_to_vaddr(vma, uprobe->offset);
+			unsigned long vaddr = vma_offset_to_vaddr(vma, uprobe->offset);
 			install_breakpoint(uprobe, vma->vm_mm, vma, vaddr);
 		}
 		put_uprobe(uprobe);
@@ -1095,7 +1095,7 @@ int uprobe_mmap(struct vm_area_struct *vma)
 
 	inode = file_inode(vma->vm_file);
 
-	min = vaddr_to_offset(vma, start);
+	min = vma_vaddr_to_offset(vma, start);
 	max = min + (end - start) - 1;
 
 	spin_lock(&uprobes_treelock);
@@ -1730,7 +1730,7 @@ static struct uprobe *find_active_uprobe(unsigned long bp_vaddr, int *is_swbp)
 	if (vma && vma->vm_start <= bp_vaddr) {
 		if (valid_vma(vma, false)) {
 			struct inode *inode = file_inode(vma->vm_file);
-			loff_t offset = vaddr_to_offset(vma, bp_vaddr);
+			loff_t offset = vma_vaddr_to_offset(vma, bp_vaddr);
 
 			uprobe = find_uprobe(inode, offset);
 		}
-- 
1.8.3.1
