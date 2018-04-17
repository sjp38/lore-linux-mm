Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 230F96B0010
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:34:16 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id v187so11820032qka.5
        for <linux-mm@kvack.org>; Mon, 16 Apr 2018 21:34:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a184si17271758qke.59.2018.04.16.21.34.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Apr 2018 21:34:10 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3H4XwID054370
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:34:06 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hd5mfh4p7-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 00:34:06 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ravi.bangoria@linux.vnet.ibm.com>;
	Tue, 17 Apr 2018 05:34:01 +0100
From: Ravi Bangoria <ravi.bangoria@linux.vnet.ibm.com>
Subject: [PATCH v3 7/9] trace_uprobe/sdt: Fix multiple update of same reference counter
Date: Tue, 17 Apr 2018 10:02:42 +0530
In-Reply-To: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
References: <20180417043244.7501-1-ravi.bangoria@linux.vnet.ibm.com>
Message-Id: <20180417043244.7501-8-ravi.bangoria@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhiramat@kernel.org, oleg@redhat.com, peterz@infradead.org, srikar@linux.vnet.ibm.com, rostedt@goodmis.org
Cc: acme@kernel.org, ananth@linux.vnet.ibm.com, akpm@linux-foundation.org, alexander.shishkin@linux.intel.com, alexis.berlemont@gmail.com, corbet@lwn.net, dan.j.williams@intel.com, jolsa@redhat.com, kan.liang@intel.com, kjlx@templeofstupid.com, kstewart@linuxfoundation.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, milian.wolff@kdab.com, mingo@redhat.com, namhyung@kernel.org, naveen.n.rao@linux.vnet.ibm.com, pc@us.ibm.com, tglx@linutronix.de, yao.jin@linux.intel.com, fengguang.wu@intel.com, jglisse@redhat.com, Ravi Bangoria <ravi.bangoria@linux.ibm.com>

From: Ravi Bangoria <ravi.bangoria@linux.ibm.com>

When virtual memory map for binary/library is being prepared, there is
no direct one to one mapping between mmap() and virtual memory area. Ex,
when loader loads the library, it first calls mmap(size = total_size),
where total_size is addition of size of all elf sections that are going
to be mapped. Then it splits individual vmas with new mmap()/mprotect()
calls. Loader does this to ensure it gets continuous address range for
a library. load_elf_binary() also uses similar tricks while preparing
mappings of binary.

Ex for pyhton library,

  # strace -o out python
    mmap(NULL, 2738968, PROT_READ|PROT_EXEC, MAP_PRIVATE|MAP_DENYWRITE, 3, 0) = 0x7fff92460000
    mmap(0x7fff926a0000, 327680, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_DENYWRITE, 3, 0x230000) = 0x7fff926a0000
    mprotect(0x7fff926a0000, 65536, PROT_READ) = 0

Here, the first mmap() maps the whole library into one region. Second
mmap() and third mprotect() split out the whole region into smaller
vmas and sets appropriate protection flags.

Now, in this case, trace_uprobe_mmap_callback() update the reference
counter twice -- by second mmap() call and by third mprotect() call --
because both regions contain reference counter.

But while de-registration, reference counter will get decremented only
by once leaving reference counter > 0 even if no one is tracing on that
marker.

Example with python library before patch:

    # readelf -n /lib64/libpython2.7.so.1.0 | grep -A1 function__entry
      Name: function__entry
      ... Semaphore: 0x00000000002899d8

  Probe on a marker:
    # echo "p:sdt_python/function__entry /usr/lib64/libpython2.7.so.1.0:0x16a4d4(0x2799d8)" > uprobe_events

  Start tracing:
    # perf record -e sdt_python:function__entry -a

  Run python workload:
    # python
    # cat /proc/`pgrep python`/maps | grep libpython
      7fffadb00000-7fffadd40000 r-xp 00000000 08:05 403934  /usr/lib64/libpython2.7.so.1.0
      7fffadd40000-7fffadd50000 r--p 00230000 08:05 403934  /usr/lib64/libpython2.7.so.1.0
      7fffadd50000-7fffadd90000 rw-p 00240000 08:05 403934  /usr/lib64/libpython2.7.so.1.0

  Reference counter value has been incremented twice:
    # dd if=/proc/`pgrep python`/mem bs=1 count=1 skip=$(( 0x7fffadd899d8 )) 2>/dev/null | xxd
      0000000: 02                                       .

  Kill perf:
    #
      ^C[ perf record: Woken up 1 times to write data ]
      [ perf record: Captured and wrote 0.322 MB perf.data (1273 samples) ]

  Reference conter is still 1 even when no one is tracing on it:
    # dd if=/proc/`pgrep python`/mem bs=1 count=1 skip=$(( 0x7fffadd899d8 )) 2>/dev/null | xxd
      0000000: 01                                       .

Ensure increment and decrement happens in sync by keeping list of mms
in trace_uprobe. Check presence of mm in the list before incrementing
the reference counter. I.e. for each {trace_uprobe,mm} tuple, reference
counter must be incremented only by one. Note that we don't check the
presence of mm in the list at decrement time.

We consider only two case while incrementing the reference counter:
  1. Target binary is already running when we start tracing. In this
     case, find all mm which maps region of target binary containing
     reference counter. Loop over all mms and increment the counter
     if mm is not already present in the list.
  2. Tracer is already tracing before target binary starts execution.
     In this case, all mmap(vma) gets notified to trace_uprobe.
     Trace_uprobe will update reference counter if vma->vm_mm is not
     already present in the list.

  There is also a third case which we don't consider, a fork() case.
  When process with markers forks itself, we don't explicitly increment
  the reference counter in child process because it should be taken care
  by dup_mmap(). We also don't add the child mm in the list. This is
  fine because we don't check presence of mm in the list at decrement
  time.

After patch:

  Start perf record and then run python...
  Reference counter value has been incremented only once:
    # dd if=/proc/`pgrep python`/mem bs=1 count=1 skip=$(( 0x7fff9cbf99d8 )) 2>/dev/null | xxd
      0000000: 01                                       .

  Kill perf:
    #
      ^C[ perf record: Woken up 1 times to write data ]
      [ perf record: Captured and wrote 0.364 MB perf.data (1427 samples) ]

  Reference conter is reset to 0:
    # dd if=/proc/`pgrep python`/mem bs=1 count=1 skip=$(( 0x7fff9cbb99d8 )) 2>/dev/null | xxd
      0000000: 00                                       .

Signed-off-by: Ravi Bangoria <ravi.bangoria@linux.ibm.com>
---
 include/linux/uprobes.h     |   1 +
 kernel/events/uprobes.c     |   6 +++
 kernel/trace/trace_uprobe.c | 121 +++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 122 insertions(+), 6 deletions(-)

diff --git a/include/linux/uprobes.h b/include/linux/uprobes.h
index 2db3ed1..e447991 100644
--- a/include/linux/uprobes.h
+++ b/include/linux/uprobes.h
@@ -123,6 +123,7 @@ struct uprobe_map_info {
 };
 
 extern void (*uprobe_mmap_callback)(struct vm_area_struct *vma);
+extern void (*uprobe_clear_state_callback)(struct mm_struct *mm);
 
 extern int set_swbp(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
 extern int set_orig_insn(struct arch_uprobe *aup, struct mm_struct *mm, unsigned long vaddr);
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index e26ad83..e8005d2 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1231,6 +1231,9 @@ static struct xol_area *get_xol_area(void)
 	return area;
 }
 
+/* Rightnow the only user of this is trace_uprobe. */
+void (*uprobe_clear_state_callback)(struct mm_struct *mm);
+
 /*
  * uprobe_clear_state - Free the area allocated for slots.
  */
@@ -1238,6 +1241,9 @@ void uprobe_clear_state(struct mm_struct *mm)
 {
 	struct xol_area *area = mm->uprobes_state.xol_area;
 
+	if (uprobe_clear_state_callback)
+		uprobe_clear_state_callback(mm);
+
 	if (!area)
 		return;
 
diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index 1a48b04..7341042c 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -50,6 +50,11 @@ struct trace_uprobe_filter {
 	struct list_head	perf_events;
 };
 
+struct sdt_mm_list {
+	struct list_head list;
+	struct mm_struct *mm;
+};
+
 /*
  * uprobe event core functions
  */
@@ -61,6 +66,8 @@ struct trace_uprobe {
 	char				*filename;
 	unsigned long			offset;
 	unsigned long			ref_ctr_offset;
+	struct sdt_mm_list		sml;
+	struct mutex			sml_lock;
 	unsigned long			nhit;
 	struct trace_probe		tp;
 };
@@ -276,6 +283,8 @@ static inline bool is_ret_probe(struct trace_uprobe *tu)
 	if (is_ret)
 		tu->consumer.ret_handler = uretprobe_dispatcher;
 	init_trace_uprobe_filter(&tu->filter);
+	mutex_init(&tu->sml_lock);
+	INIT_LIST_HEAD(&(tu->sml.list));
 	return tu;
 
 error:
@@ -923,6 +932,43 @@ static void uretprobe_trace_func(struct trace_uprobe *tu, unsigned long func,
 	return trace_handle_return(s);
 }
 
+static bool sdt_check_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
+{
+	struct sdt_mm_list *sml;
+
+	list_for_each_entry(sml, &(tu->sml.list), list)
+		if (sml->mm == mm)
+			return true;
+
+	return false;
+}
+
+static int sdt_add_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
+{
+	struct sdt_mm_list *sml  = kzalloc(sizeof(*sml), GFP_KERNEL);
+
+	if (!sml)
+		return -ENOMEM;
+
+	sml->mm = mm;
+	list_add(&(sml->list), &(tu->sml.list));
+	return 0;
+}
+
+static void sdt_del_mm_list(struct trace_uprobe *tu, struct mm_struct *mm)
+{
+	struct list_head *pos, *q;
+	struct sdt_mm_list *sml;
+
+	list_for_each_safe(pos, q, &(tu->sml.list)) {
+		sml = list_entry(pos, struct sdt_mm_list, list);
+		if (sml->mm == mm) {
+			list_del(pos);
+			kfree(sml);
+		}
+	}
+}
+
 static bool sdt_valid_vma(struct trace_uprobe *tu,
 			  struct vm_area_struct *vma,
 			  unsigned long vaddr)
@@ -975,6 +1021,31 @@ static struct vm_area_struct *sdt_find_vma(struct trace_uprobe *tu,
 	return 0;
 }
 
+static void __sdt_increment_ref_ctr(struct trace_uprobe *tu,
+				    struct mm_struct *mm,
+				    unsigned long vaddr)
+{
+	int ret = 0;
+
+	ret = sdt_update_ref_ctr(mm, vaddr, 1);
+	if (unlikely(ret)) {
+		pr_info("Failed to increment ref_ctr. (%d)\n", ret);
+		return;
+	}
+
+	ret = sdt_add_mm_list(tu, mm);
+	if (unlikely(ret)) {
+		pr_info("Failed to add mm into list. (%d)\n", ret);
+		goto revert_ctr;
+	}
+	return;
+
+revert_ctr:
+	ret = sdt_update_ref_ctr(mm, vaddr, -1);
+	if (ret)
+		pr_info("Reverting ref_ctr update failed. (%d)\n", ret);
+}
+
 static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
 {
 	struct uprobe_map_info *info;
@@ -985,15 +1056,19 @@ static void sdt_increment_ref_ctr(struct trace_uprobe *tu)
 	if (IS_ERR(info))
 		goto out;
 
+	mutex_lock(&tu->sml_lock);
 	while (info) {
-		down_write(&info->mm->mmap_sem);
+		if (sdt_check_mm_list(tu, info->mm))
+			goto cont;
 
+		down_write(&info->mm->mmap_sem);
 		if (sdt_find_vma(tu, info->mm, info->vaddr))
-			sdt_update_ref_ctr(info->mm, info->vaddr, 1);
-
+			__sdt_increment_ref_ctr(tu, info->mm, info->vaddr);
 		up_write(&info->mm->mmap_sem);
+cont:
 		info = uprobe_free_map_info(info);
 	}
+	mutex_unlock(&tu->sml_lock);
 
 out:
 	uprobe_up_write_dup_mmap();
@@ -1017,14 +1092,28 @@ static void trace_uprobe_mmap(struct vm_area_struct *vma)
 		if (!sdt_valid_vma(tu, vma, vaddr))
 			continue;
 
-		sdt_update_ref_ctr(vma->vm_mm, vaddr, 1);
+		mutex_lock(&tu->sml_lock);
+		if (!sdt_check_mm_list(tu, vma->vm_mm))
+			__sdt_increment_ref_ctr(tu, vma->vm_mm, vaddr);
+		mutex_unlock(&tu->sml_lock);
 	}
 	mutex_unlock(&uprobe_lock);
 }
 
+/*
+ * We don't check presence of mm in tu->sml here. We just decrement
+ * the reference counter if we find vma holding the reference counter.
+ *
+ * For tiny binaries/libraries, different mmap regions point to the
+ * same file portion. In such cases, uprobe_build_map_info() returns
+ * same mm multiple times with different virtual address of one
+ * reference counter. But we don't decrement the reference counter
+ * multiple time because we check for VM_WRITE in sdt_valid_vma().
+ */
 static void sdt_decrement_ref_ctr(struct trace_uprobe *tu)
 {
 	struct uprobe_map_info *info;
+	int ret;
 
 	uprobe_down_write_dup_mmap();
 	info = uprobe_build_map_info(tu->inode->i_mapping,
@@ -1032,20 +1121,39 @@ static void sdt_decrement_ref_ctr(struct trace_uprobe *tu)
 	if (IS_ERR(info))
 		goto out;
 
+	mutex_lock(&tu->sml_lock);
 	while (info) {
 		down_write(&info->mm->mmap_sem);
 
-		if (sdt_find_vma(tu, info->mm, info->vaddr))
-			sdt_update_ref_ctr(info->mm, info->vaddr, -1);
+		if (sdt_find_vma(tu, info->mm, info->vaddr)) {
+			ret = sdt_update_ref_ctr(info->mm, info->vaddr, -1);
+			if (unlikely(ret))
+				pr_info("Failed to Decrement ref_ctr. (%d)\n", ret);
+		}
 
 		up_write(&info->mm->mmap_sem);
+		sdt_del_mm_list(tu, info->mm);
 		info = uprobe_free_map_info(info);
 	}
+	mutex_unlock(&tu->sml_lock);
 
 out:
 	uprobe_up_write_dup_mmap();
 }
 
+static void sdt_mm_release(struct mm_struct *mm)
+{
+	struct trace_uprobe *tu;
+
+	mutex_lock(&uprobe_lock);
+	list_for_each_entry(tu, &uprobe_list, list) {
+		mutex_lock(&tu->sml_lock);
+		sdt_del_mm_list(tu, mm);
+		mutex_unlock(&tu->sml_lock);
+	}
+	mutex_unlock(&uprobe_lock);
+}
+
 typedef bool (*filter_func_t)(struct uprobe_consumer *self,
 				enum uprobe_filter_ctx ctx,
 				struct mm_struct *mm);
@@ -1583,6 +1691,7 @@ static __init int init_uprobe_trace(void)
 				    NULL, &uprobe_profile_ops);
 
 	uprobe_mmap_callback = trace_uprobe_mmap;
+	uprobe_clear_state_callback = sdt_mm_release;
 	return 0;
 }
 
-- 
1.8.3.1
