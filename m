Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9556D6B0008
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 04:29:24 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id z19so5357070wmh.8
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 01:29:24 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h14si361030edh.7.2018.04.04.01.29.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 01:29:23 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w348TKVx093830
	for <linux-mm@kvack.org>; Wed, 4 Apr 2018 04:29:21 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h4s8en9jh-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Apr 2018 04:29:21 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Wed, 4 Apr 2018 09:29:15 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v2 6/9] trace_uprobe: Support SDT markers having reference count (semaphore)
Date: Wed,  4 Apr 2018 14:01:07 +0530
In-Reply-To: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180404083110.18647-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180404083110.18647-7-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>

Userspace Statically Defined Tracepoints[1] are dtrace style markers
inside userspace applications. These markers are added by developer at
important places in the code. Each marker source expands to a single
nop instruction in the compiled code but there may be additional
overhead for computing the marker arguments which expands to couple of
instructions. In case the overhead is more, execution of it can be
ommited by runtime if() condition when no one is tracing on the marker:

    if (reference_counter > 0) {
        Execute marker instructions;
    }

Default value of reference counter is 0. Tracer has to increment the
reference counter before tracing on a marker and decrement it when
done with the tracing.

Implement the reference counter logic in trace_uprobe, leaving core
uprobe infrastructure as is, except one new callback from uprobe_mmap()
to trace_uprobe.

trace_uprobe definition with reference counter will now be:

  <path>:<offset>[(ref_ctr_offset)]

There are two different cases while enabling the marker,
 1. Trace existing process. In this case, find all suitable processes
    and increment the reference counter in them.
 2. Enable trace before running target binary. In this case, all mmaps
    will get notified to trace_uprobe and trace_uprobe will increment
    the reference counter if corresponding uprobe is enabled.

At the time of disabling probes, decrement reference counter in all
existing target processes.

[1] https://sourceware.org/systemtap/wiki/UserSpaceProbeImplementation

Note: 'reference counter' is called as 'semaphore' in original Dtrace
(or Systemtap, bcc and even in ELF) documentation and code. But the
term 'semaphore' is misleading in this context. This is just a counter
used to hold number of tracers tracing on a marker. This is not really
used for any synchronization. So we are referring it as 'reference
counter' in kernel / perf code.

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
[Fengguang reported/fixed build failure in RFC patch]
---
 include/linux/uprobes.h     |  10 +++
 kernel/events/uprobes.c     |  16 +++++
 kernel/trace/trace_uprobe.c | 162 +++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 186 insertions(+), 2 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 7bd2760..2db3ed1 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -122,6 +122,8 @@ struct uprobe_map_info {
 	unsigned long vaddr;
 };
 
+extern void (*uprobe_mmap_callback)(struct vm_area_struct *vma);
+
 extern int set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern int set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern bool is_swbp_insn(uprobe_opcode_t *insn);
@@ -136,6 +138,8 @@ struct uprobe_map_info {
 extern void uprobe_munmap(struct vm_area_struct *vma, unsigned long start, unsigned long end);
 extern void uprobe_start_dup_mmap(void);
 extern void uprobe_end_dup_mmap(void);
+extern void uprobe_down_write_dup_mmap(void);
+extern void uprobe_up_write_dup_mmap(void);
 extern void uprobe_dup_mmap(struct mm_struct *oldmm, struct mm_struct *newmm);
 extern void uprobe_free_utask(struct task_struct *t);
 extern void uprobe_copy_process(struct task_struct *t, unsigned long flags);
@@ -192,6 +196,12 @@ static inline void uprobe_start_dup_mmap(void)
 static inline void uprobe_end_dup_mmap(void)
 {
 }
+static inline void uprobe_down_write_dup_mmap(void)
+{
+}
+static inline void uprobe_up_write_dup_mmap(void)
+{
+}
 static inline void
 uprobe_dup_mmap(struct mm_struct *oldmm, struct mm_struct *newmm)
 {
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 096d1e6..c691334 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1044,6 +1044,9 @@ static void build_probe_list(struct inode *inode,
 	spin_unlock(&uprobes_treelock);
 }
 
+/* Rightnow the only user of this is trace_uprobe. */
+void (*uprobe_mmap_callback)(struct vm_area_struct *vma);
+
 /*
  * Called from mmap_region/vma_adjust with mm->mmap_sem acquired.
  *
@@ -1056,6 +1059,9 @@ int uprobe_mmap(struct vm_area_struct *vma)
 	struct uprobe *uprobe, *u;
 	struct inode *inode;
 
+	if (uprobe_mmap_callback)
+		uprobe_mmap_callback(vma);
+
 	if (no_uprobe_events() || !valid_vma(vma, true))
 		return 0;
 
@@ -1247,6 +1253,16 @@ void uprobe_end_dup_mmap(void)
 	percpu_up_read(&dup_mmap_sem);
 }
 
+void uprobe_down_write_dup_mmap(void)
+{
+	percpu_down_write(&dup_mmap_sem);
+}
+
+void uprobe_up_write_dup_mmap(void)
+{
+	percpu_up_write(&dup_mmap_sem);
+}
+
 void uprobe_dup_mmap(struct mm_struct *oldmm, struct mm_struct *newmm)
 {
 	if (test_bit(MMF_HAS_UPROBES, &oldmm->flags)) {
diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index 2014f43..5582c2d 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -25,6 +25,8 @@
 #include <linux/namei.h>
 #include <linux/string.h>
 #include <linux/rculist.h>
+#include <linux/sched/mm.h>
+#include <linux/highmem.h>
 
 #include "trace_probe.h"
 
@@ -58,6 +60,7 @@ struct trace_uprobe {
 	struct inode			*inode;
 	char				*filename;
 	unsigned long			offset;
+	unsigned long			ref_ctr_offset;
 	unsigned long			nhit;
 	struct trace_probe		tp;
 };
@@ -362,10 +365,10 @@ static int create_trace_uprobe(int argc, char **argv)
 {
 	struct trace_uprobe *tu;
 	struct inode *inode;
-	char *arg, *event, *group, *filename;
+	char *arg, *event, *group, *filename, *rctr, *rctr_end;
 	char buf[MAX_EVENT_NAME_LEN];
 	struct path path;
-	unsigned long offset;
+	unsigned long offset, ref_ctr_offset;
 	bool is_delete, is_return;
 	int i, ret;
 
@@ -375,6 +378,7 @@ static int create_trace_uprobe(int argc, char **argv)
 	is_return = false;
 	event = NULL;
 	group = NULL;
+	ref_ctr_offset = 0;
 
 	/* argc must be >= 1 */
 	if (argv[0][0] == '-')
@@ -454,6 +458,26 @@ static int create_trace_uprobe(int argc, char **argv)
 		goto fail_address_parse;
 	}
 
+	/* Parse reference counter offset if specified. */
+	rctr = strchr(arg, '(');
+	if (rctr) {
+		rctr_end = strchr(rctr, ')');
+		if (rctr > rctr_end || *(rctr_end + 1) != 0) {
+			ret = -EINVAL;
+			pr_info("Invalid reference counter offset.\n");
+			goto fail_address_parse;
+		}
+
+		*rctr++ = '\0';
+		*rctr_end = '\0';
+		ret = kstrtoul(rctr, 0, &ref_ctr_offset);
+		if (ret) {
+			pr_info("Invalid reference counter offset.\n");
+			goto fail_address_parse;
+		}
+	}
+
+	/* Parse uprobe offset. */
 	ret = kstrtoul(arg, 0, &offset);
 	if (ret)
 		goto fail_address_parse;
@@ -488,6 +512,7 @@ static int create_trace_uprobe(int argc, char **argv)
 		goto fail_address_parse;
 	}
 	tu->offset = offset;
+	tu->ref_ctr_offset = ref_ctr_offset;
 	tu->inode = inode;
 	tu->filename = kstrdup(filename, GFP_KERNEL);
 
@@ -620,6 +645,8 @@ static int probes_seq_show(struct seq_file *m, void *v)
 			break;
 		}
 	}
+	if (tu->ref_ctr_offset)
+		seq_printf(m, "(0x%lx)", tu->ref_ctr_offset);
 
 	for (i = 0; i < tu->tp.nr_args; i++)
 		seq_printf(m, " %s=%s", tu->tp.args[i].name, tu->tp.args[i].comm);
@@ -894,6 +921,129 @@ static void uretprobe_trace_func(struct trace_uprobe *tu, unsigned long func,
 	return trace_handle_return(s);
 }
 
+static bool sdt_valid_vma(struct trace_uprobe *tu,
+			  struct vm_area_struct *vma,
+			  unsigned long vaddr)
+{
+	return tu->ref_ctr_offset &&
+		vma->vm_file &&
+		file_inode(vma->vm_file) == tu->inode &&
+		vma->vm_flags & VM_WRITE &&
+		vma->vm_start <= vaddr &&
+		vma->vm_end > vaddr;
+}
+
+static struct vm_area_struct *sdt_find_vma(struct trace_uprobe *tu,
+					   struct mm_struct *mm,
+					   unsigned long vaddr)
+{
+	struct vm_area_struct *vma = find_vma(mm, vaddr);
+
+	return (vma && sdt_valid_vma(tu, vma, vaddr)) ? vma : NULL;
+}
+
+/*
+ * Reference counter gate the invocation of probe. If present,
+ * by default reference counter is 0. One needs to increment
+ * it before tracing the probe and decrement it when done.
+ */
+static int
+sdt_update_ref_ctr(struct mm_struct *mm, unsigned long vaddr, short d)
+{
+	void *kaddr;
+	struct page *page;
+	struct vm_area_struct *vma;
+	int ret = 0;
+	unsigned short *ptr;
+
+	if (vaddr == 0)
+		return -EINVAL;
+
+	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
+		FOLL_FORCE | FOLL_WRITE, &page, &vma, NULL);
+	if (ret <= 0)
+		return ret;
+
+	kaddr = kmap_atomic(page);
+	ptr = kaddr + (vaddr & ~PAGE_MASK);
+	*ptr += d;
+	kunmap_atomic(kaddr);
+
+	put_page(page);
+	return 0;
+}
+
+static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
+{
+	struct uprobe_map_info *info;
+
+	uprobe_down_write_dup_mmap();
+	info = uprobe_build_map_info(tu->inode->i_mapping,
+				tu->ref_ctr_offset, false);
+	if (IS_ERR(info))
+		goto out;
+
+	while (info) {
+		down_write(&info->mm->mmap_sem);
+
+		if (sdt_find_vma(tu, info->mm, info->vaddr))
+			sdt_update_ref_ctr(info->mm, info->vaddr, 1);
+
+		up_write(&info->mm->mmap_sem);
+		info = uprobe_free_map_info(info);
+	}
+
+out:
+	uprobe_up_write_dup_mmap();
+}
+
+/* Called with down_write(&vma->vm_mm->mmap_sem) */
+void trace_uprobe_mmap(struct vm_area_struct *vma)
+{
+	struct trace_uprobe *tu;
+	unsigned long vaddr;
+
+	if (!(vma->vm_flags & VM_WRITE))
+		return;
+
+	mutex_lock(&uprobe_lock);
+	list_for_each_entry(tu, &uprobe_list, list) {
+		if (!trace_probe_is_enabled(&tu->tp))
+			continue;
+
+		vaddr = vma_offset_to_vaddr(vma, tu->ref_ctr_offset);
+		if (!sdt_valid_vma(tu, vma, vaddr))
+			continue;
+
+		sdt_update_ref_ctr(vma->vm_mm, vaddr, 1);
+	}
+	mutex_unlock(&uprobe_lock);
+}
+
+static void sdt_decrement_ref_ctr(struct trace_uprobe *tu)
+{
+	struct uprobe_map_info *info;
+
+	uprobe_down_write_dup_mmap();
+	info = uprobe_build_map_info(tu->inode->i_mapping,
+				tu->ref_ctr_offset, false);
+	if (IS_ERR(info))
+		goto out;
+
+	while (info) {
+		down_write(&info->mm->mmap_sem);
+
+		if (sdt_find_vma(tu, info->mm, info->vaddr))
+			sdt_update_ref_ctr(info->mm, info->vaddr, -1);
+
+		up_write(&info->mm->mmap_sem);
+		info = uprobe_free_map_info(info);
+	}
+
+out:
+	uprobe_up_write_dup_mmap();
+}
+
 typedef bool (*filter_func_t)(struct uprobe_consumer *self,
 				enum uprobe_filter_ctx ctx,
 				struct mm_struct *mm);
@@ -939,6 +1089,9 @@ typedef bool (*filter_func_t)(struct uprobe_consumer *self,
 	if (ret)
 		goto err_buffer;
 
+	if (tu->ref_ctr_offset)
+		sdt_increment_ref_ctr(tu);
+
 	return 0;
 
  err_buffer:
@@ -979,6 +1132,9 @@ typedef bool (*filter_func_t)(struct uprobe_consumer *self,
 
 	WARN_ON(!uprobe_filter_is_empty(&tu->filter));
 
+	if (tu->ref_ctr_offset)
+		sdt_decrement_ref_ctr(tu);
+
 	uprobe_unregister(tu->inode, tu->offset, &tu->consumer);
 	tu->tp.flags &= file ? ~TP_FLAG_TRACE : ~TP_FLAG_PROFILE;
 
@@ -1423,6 +1579,8 @@ static __init int init_uprobe_trace(void)
 	/* Profile interface */
 	trace_create_file("uprobe_profile", 0444, d_tracer,
 				    NULL, &uprobe_profile_ops);
+
+	uprobe_mmap_callback = trace_uprobe_mmap;
 	return 0;
 }
 
-- 
1.8.3.1
