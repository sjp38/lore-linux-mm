Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F02F6B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:35:06 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id l9so11725546qtp.23
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 21:35:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z61si8193870qtd.125.2018.04.16.21.35.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 21:35:05 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H4Y0cN094664
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:34:02 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hd3vbd3a9-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:34:01 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 05:33:43 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v3 4/9] Uprobe: Rename map_info to uprobe_map_info
Date: Tue, 17 Apr 2018 10:02:39 +0530
In-Reply-To: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <20180417043244.7501-5-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.ibm.com>

From: Ravi Bangoria <ravi.bangoria@linux.ibm.com>

map_info is very generic name, rename it to uprobe_map_info.
Renaming will help to export this structure outside of the
file.

Also rename free_map_info() to uprobe_free_map_info() and
build_map_info() to uprobe_build_map_info().

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
Reviewed-by: JA(C)rA'me Glisse <jglisse@redhat.com>
---
 kernel/events/uprobes.c | 30 ++++++++++++++++--------------
 1 file changed, 16 insertions(+), 14 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 1d439c7..477dc42 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -695,28 +695,30 @@ static void delete_uprobe(struct uprobe *uprobe)
 	put_uprobe(uprobe);
 }
 
-struct map_info {
-	struct map_info *next;
+struct uprobe_map_info {
+	struct uprobe_map_info *next;
 	struct mm_struct *mm;
 	unsigned long vaddr;
 };
 
-static inline struct map_info *free_map_info(struct map_info *info)
+static inline struct uprobe_map_info *
+uprobe_free_map_info(struct uprobe_map_info *info)
 {
-	struct map_info *next = info->next;
+	struct uprobe_map_info *next = info->next;
 	mmput(info->mm);
 	kfree(info);
 	return next;
 }
 
-static struct map_info *
-build_map_info(struct address_space *mapping, loff_t offset, bool is_register)
+static struct uprobe_map_info *
+uprobe_build_map_info(struct address_space *mapping, loff_t offset,
+		      bool is_register)
 {
 	unsigned long pgoff = offset >> PAGE_SHIFT;
 	struct vm_area_struct *vma;
-	struct map_info *curr = NULL;
-	struct map_info *prev = NULL;
-	struct map_info *info;
+	struct uprobe_map_info *curr = NULL;
+	struct uprobe_map_info *prev = NULL;
+	struct uprobe_map_info *info;
 	int more = 0;
 
  again:
@@ -730,7 +732,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
 			 * Needs GFP_NOWAIT to avoid i_mmap_rwsem recursion through
 			 * reclaim. This is optimistic, no harm done if it fails.
 			 */
-			prev = kmalloc(sizeof(struct map_info),
+			prev = kmalloc(sizeof(struct uprobe_map_info),
 					GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN);
 			if (prev)
 				prev->next = NULL;
@@ -763,7 +765,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
 	}
 
 	do {
-		info = kmalloc(sizeof(struct map_info), GFP_KERNEL);
+		info = kmalloc(sizeof(struct uprobe_map_info), GFP_KERNEL);
 		if (!info) {
 			curr = ERR_PTR(-ENOMEM);
 			goto out;
@@ -786,11 +788,11 @@ static inline struct map_info *free_map_info(struct map_info *info)
 register_for_each_vma(struct uprobe *uprobe, struct uprobe_consumer *new)
 {
 	bool is_register = !!new;
-	struct map_info *info;
+	struct uprobe_map_info *info;
 	int err = 0;
 
 	percpu_down_write(&dup_mmap_sem);
-	info = build_map_info(uprobe->inode->i_mapping,
+	info = uprobe_build_map_info(uprobe->inode->i_mapping,
 					uprobe->offset, is_register);
 	if (IS_ERR(info)) {
 		err = PTR_ERR(info);
@@ -828,7 +830,7 @@ static inline struct map_info *free_map_info(struct map_info *info)
  unlock:
 		up_write(&mm->mmap_sem);
  free:
-		info = free_map_info(info);
+		info = uprobe_free_map_info(info);
 	}
  out:
 	percpu_up_write(&dup_mmap_sem);
-- 
1.8.3.1
