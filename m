Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id A27186B000C
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 04:29:47 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c9so15145123qth.16
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 01:29:47 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p64si1163097qkd.123.2018.04.04.01.29.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 01:29:46 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w348TgqN064708
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 04:29:45 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h4rta66m8-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 04:29:44 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 09:29:05 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v2 4/9] Uprobe: Rename map_info to uprobe_map_info
Date: Wed,  4 Apr 2018 14:01:05 +0530
In-Reply-To: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Message-Id: <20180404083110.18647-5-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

map_info is very generic name, rename it to uprobe_map_info.
Renaming will help to export this structure outside of the
file.

Also rename free_map_info() to uprobe_free_map_info() and
build_map_info() to uprobe_build_map_info().

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
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
