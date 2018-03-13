Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D2136B000C
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:28 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y9so14905042qti.3
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 05:55:28 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h129si153354qke.65.2018.03.13.05.55.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 05:55:26 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2DCsbcZ099667
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:25 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2gpeft9txh-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 08:55:25 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 13 Mar 2018 12:55:22 -0000
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH 6/8] trace_uprobe/sdt: Fix multiple update of same reference counter
Date: Tue, 13 Mar 2018 18:26:01 +0530
In-Reply-To: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180313125603.19819-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180313125603.19819-7-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, gregkh@linuxfoundation.org, huawei.libin@huawei.com, hughd@google.com, jack@suse.cz, jglisse@redhat.com, jolsa@redhat.com, kan.liang@intel.com, kirill.shutemov@linux.intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, pombredanne@nexb.com, rostedt@goodmis.org, tglx@linutronix.de, tmricht@linux.vnet.ibm.com, willy@infradead.org, yao.jin@linux.intel.com, fengguang.wu@intel.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

For tiny binaries/libraries, different mmap regions points to the
same file portion. In such cases, we may increment reference counter
multiple times. But while de-registration, reference counter will get
decremented only by once leaving reference counter > 0 even if no one
is tracing on that marker.

Ensure increment and decrement happens in sync by keeping list of
mms in trace_uprobe. Increment reference counter only if mm is not
present in the list and decrement only if mm is present in the list.

Example

  # echo "p:sdt_tick/loop2 /tmp/tick:0x6e4(0x10036)" > uprobe_events

Before patch:

  # perf stat -a -e sdt_tick:loop2
  # /tmp/tick
  # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
   0000000: 02                                       .

  # pkill perf
  # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
  0000000: 01                                       .

After patch:

  # perf stat -a -e sdt_tick:loop2
  # /tmp/tick
  # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
  0000000: 01                                       .

  # pkill perf
  # dd if=/proc/`pgrep tick`/mem bs=1 count=1 skip=$(( 0x10020036 )) 2>/dev/null | xxd
  0000000: 00                                       .

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
---
 kernel/trace/trace_uprobe.c | 105 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 103 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index b6c9b48..9bf3f7a 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -50,6 +50,11 @@ struct trace_uprobe_filter {
 	struct list_head	perf_events;
 };
 
+struct sdt_mm_list {
+	struct mm_struct *mm;
+	struct sdt_mm_list *next;
+};
+
 /*
  * uprobe event core functions
  */
@@ -61,6 +66,8 @@ struct trace_uprobe {
 	char				*filename;
 	unsigned long			offset;
 	unsigned long			ref_ctr_offset;
+	struct sdt_mm_list		*sml;
+	struct rw_semaphore		sml_rw_sem;
 	unsigned long			nhit;
 	struct trace_probe		tp;
 };
@@ -274,6 +281,7 @@ static inline bool is_ret_probe(struct trace_uprobe *tu)
 	if (is_ret)
 		tu->consumer.ret_handler = uretprobe_dispatcher;
 	init_trace_uprobe_filter(&tu->filter);
+	init_rwsem(&tu->sml_rw_sem);
 	return tu;
 
 error:
@@ -921,6 +929,74 @@ static void uretprobe_trace_func(struct trace_uprobe *tu, unsigned long func,
 	return trace_handle_return(s);
 }
 
+static bool sdt_check_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
+{
+	struct sdt_mm_list *tmp = tu->sml;
+
+	if (!tu->sml || !mm)
+		return false;
+
+	while (tmp) {
+		if (tmp->mm == mm)
+			return true;
+		tmp = tmp->next;
+	}
+
+	return false;
+}
+
+static void sdt_add_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
+{
+	struct sdt_mm_list *tmp;
+
+	tmp = kzalloc(sizeof(*tmp), GFP_KERNEL);
+	if (!tmp)
+		return;
+
+	tmp->mm = mm;
+	tmp->next = tu->sml;
+	tu->sml = tmp;
+}
+
+static void sdt_del_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
+{
+	struct sdt_mm_list *prev, *curr;
+
+	if (!tu->sml)
+		return;
+
+	if (tu->sml->mm == mm) {
+		curr = tu->sml;
+		tu->sml = tu->sml->next;
+		kfree(curr);
+		return;
+	}
+
+	prev = tu->sml;
+	curr = tu->sml->next;
+	while (curr) {
+		if (curr->mm == mm) {
+			prev->next = curr->next;
+			kfree(curr);
+			return;
+		}
+		prev = curr;
+		curr = curr->next;
+	}
+}
+
+static void sdt_flush_mm_list(struct trace_uprobe *tu)
+{
+	struct sdt_mm_list *next, *curr = tu->sml;
+
+	while (curr) {
+		next = curr->next;
+		kfree(curr);
+		curr = next;
+	}
+	tu->sml = NULL;
+}
+
 static bool sdt_valid_vma(struct trace_uprobe *tu, struct vm_area_struct *vma)
 {
 	unsigned long vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
@@ -989,17 +1065,25 @@ static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
 	if (IS_ERR(info))
 		goto out;
 
+	down_write(&tu->sml_rw_sem);
 	while (info) {
+		if (sdt_check_mm_list(tu, info->mm))
+			goto cont;
+
 		down_write(&info->mm->mmap_sem);
 
 		vma = sdt_find_vma(info->mm, tu);
 		vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
-		sdt_update_ref_ctr(info->mm, vaddr, 1);
+		if (!sdt_update_ref_ctr(info->mm, vaddr, 1))
+			sdt_add_mm_list(tu, info->mm);
 
 		up_write(&info->mm->mmap_sem);
+
+cont:
 		mmput(info->mm);
 		info = uprobe_free_map_info(info);
 	}
+	up_write(&tu->sml_rw_sem);
 
 out:
 	uprobe_end_dup_mmap();
@@ -1020,8 +1104,16 @@ void trace_uprobe_mmap_callback(struct vm_area_struct *vma)
 		    !trace_probe_is_enabled(&tu->tp))
 			continue;
 
+		down_write(&tu->sml_rw_sem);
+		if (sdt_check_mm_list(tu, vma->vm_mm))
+			goto cont;
+
 		vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
-		sdt_update_ref_ctr(vma->vm_mm, vaddr, 1);
+		if (!sdt_update_ref_ctr(vma->vm_mm, vaddr, 1))
+			sdt_add_mm_list(tu, vma->vm_mm);
+
+cont:
+		up_write(&tu->sml_rw_sem);
 	}
 	mutex_unlock(&uprobe_lock);
 }
@@ -1038,7 +1130,11 @@ static void sdt_decrement_ref_ctr(struct trace_uprobe *tu)
 	if (IS_ERR(info))
 		goto out;
 
+	down_write(&tu->sml_rw_sem);
 	while (info) {
+		if (!sdt_check_mm_list(tu, info->mm))
+			goto cont;
+
 		down_write(&info->mm->mmap_sem);
 
 		vma = sdt_find_vma(info->mm, tu);
@@ -1046,9 +1142,14 @@ static void sdt_decrement_ref_ctr(struct trace_uprobe *tu)
 		sdt_update_ref_ctr(info->mm, vaddr, -1);
 
 		up_write(&info->mm->mmap_sem);
+		sdt_del_mm_list(tu, info->mm);
+
+cont:
 		mmput(info->mm);
 		info = uprobe_free_map_info(info);
 	}
+	sdt_flush_mm_list(tu);
+	up_write(&tu->sml_rw_sem);
 
 out:
 	uprobe_end_dup_mmap();
-- 
1.8.3.1
