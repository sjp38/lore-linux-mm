Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1CED36B000A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id j3so11550708wrb.18
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:55:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 28si82073edv.521.2018.03.13.05.55.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 05:55:01 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DCsr7f118266
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:00 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gpc6pyjfj-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:54:58 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 12:54:54 -0000
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH 4/8] Uprobe: Export uprobe_map_info along with uprobe_{build/free}_map_info()
Date: Tue, 13 Mar 2018 18:25:59 +0530
In-Reply-To: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180313125603.19819-5-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

These exported data structure and functions will be used by other
files in later patches.

No functionality changes.

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
---
 include/linux/uprobes.h |  9 +++++++++
 kernel/events/uprobes.c | 14 +++-----------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 0a294e9..7bd2760 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -109,12 +109,19 @@ enum rp_check {
 	RP_CHECK_RET,
 };
 
+struct address_space;
 struct xol_area;
 
 struct uprobes_state {
 	struct xol_area		*xol_area;
 };
 
+struct uprobe_map_info {
+	struct uprobe_map_info *next;
+	struct mm_struct *mm;
+	unsigned long vaddr;
+};
+
 extern int set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern int set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern bool is_swbp_insn(uprobe_opcode_t *insn);
@@ -149,6 +156,8 @@ struct uprobes_state {
 extern bool arch_uprobe_ignore(struct arch_uprobe *aup, struct pt_regs *regs);
 extern void arch_uprobe_copy_ixol(struct page *page, unsigned long vaddr,
 					 void *src, unsigned long len);
+extern struct uprobe_map_info *uprobe_free_map_info(struct uprobe_map_info *info);
+extern struct uprobe_map_info *uprobe_build_map_info(struct address_space *mapping, loff_t offset, bool is_register);
 #else /* !CONFIG_UPROBES */
 struct uprobes_state {
 };
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 081b88c1..e7830b8 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -695,23 +695,15 @@ static void delete_uprobe(struct uprobe *uprobe)
 	put_uprobe(uprobe);
 }
 
-struct uprobe_map_info {
-	struct uprobe_map_info *next;
-	struct mm_struct *mm;
-	unsigned long vaddr;
-};
-
-static inline struct uprobe_map_info *
-uprobe_free_map_info(struct uprobe_map_info *info)
+struct uprobe_map_info *uprobe_free_map_info(struct uprobe_map_info *info)
 {
 	struct uprobe_map_info *next = info->next;
 	kfree(info);
 	return next;
 }
 
-static struct uprobe_map_info *
-uprobe_build_map_info(struct address_space *mapping, loff_t offset,
-		      bool is_register)
+struct uprobe_map_info *uprobe_build_map_info(struct address_space *mapping,
+					      loff_t offset, bool is_register)
 {
 	unsigned long pgoff = offset >> PAGE_SHIFT;
 	struct vm_area_struct *vma;
-- 
1.8.3.1
