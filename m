Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f50.google.com (mail-pb0-f50.google.com [209.85.160.50])
	by kanga.kvack.org (Postfix) with ESMTP id 81B8C6B0035
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 12:41:39 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id md12so4188215pbc.37
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 09:41:39 -0700 (PDT)
Received: from smtp.gentoo.org (dev.gentoo.org. [2001:470:ea4a:1:214:c2ff:fe64:b2d3])
        by mx.google.com with ESMTPS id ic8si2516002pad.218.2014.04.10.09.41.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Apr 2014 09:41:38 -0700 (PDT)
From: Richard Yao <ryao@gentoo.org>
Subject: [PATCH] mm/vmalloc: Introduce DEBUG_VMALLOCINFO to reduce spinlock contention
Date: Thu, 10 Apr 2014 12:40:58 -0400
Message-Id: <1397148058-8737-1-git-send-email-ryao@gentoo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel@gentoo.org, Matthew Thode <mthode@mthode.org>, Richard Yao <ryao@gentoo.org>

Performance analysis of software compilation by Gentoo portage on an
Intel E5-2620 with 64GB of RAM revealed that a sizeable amount of time,
anywhere from 5% to 15%, was spent in get_vmalloc_info(), with at least
40% of that time spent in the _raw_spin_lock() invoked by it.

The spinlock call is done on vmap_area_lock to protect vmap_area_list,
but changes to vmap_area_list are made under RCU. The only consumer that
requires a spinlock on an RCU-ified list is /proc/vmallocinfo. That is
only intended for use by kernel developers doing debugging, but even few
kernel developers appear to use it. Introducing DEBUG_VMALLOCINFO allows
us to fully RCU-ify the list, which eliminates this list as a source of
contention.

This patch brings a substantial reduction in time spent in spinlocks on
my system. Flame graphs from my early analysis are available on my
developer space. They were created by profiling the system under
concurrent package builds done by emerge at a sample rate of 99Hz for 10
seconds and using Brendan Gregg's scripts to process the data:

http://dev.gentoo.org/~ryao/emerge.svg
http://dev.gentoo.org/~ryao/emerge-patched.svg

In this example, 6.64% of system time is spent in get_vmalloc_info()
with 2.59% spent in the spinlock. The patched version sees only 0.50% of
time spent in get_vmalloc_info() with neligible time spent in spin
locks. The low utilization of get_vmalloc_info() in this is partly
attributable to measurement error, but the reduction in time spent
spinning is clear.

Signed-off-by: Richard Yao <ryao@gentoo.org>
---
 lib/Kconfig.debug | 11 +++++++++++
 mm/vmalloc.c      | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+)

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index dd7f885..a3e6967 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -492,6 +492,17 @@ config DEBUG_STACK_USAGE
 
 	  This option will slow down process creation somewhat.
 
+config DEBUG_VMALLOCINFO
+	bool "Provide /proc/vmallocinfo"
+	depends on PROC_FS
+	help
+	  Provides a userland interface to view kernel virtual memory mappings.
+	  Enabling this places a RCU-ified list under spinlock protection. That
+	  hurts performance in concurrent workloads.
+
+	  If unsure, say N.
+
+
 config DEBUG_VM
 	bool "Debug VM"
 	depends on DEBUG_KERNEL
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index bf233b2..12ab34b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1988,8 +1988,13 @@ long vread(char *buf, char *addr, unsigned long count)
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 	spin_lock(&vmap_area_lock);
 	list_for_each_entry(va, &vmap_area_list, list) {
+#else
+	rcu_read_lock();
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+#endif
 		if (!count)
 			break;
 
@@ -2020,7 +2025,11 @@ long vread(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 	spin_unlock(&vmap_area_lock);
+#else
+	rcu_read_unlock();
+#endif
 
 	if (buf == buf_start)
 		return 0;
@@ -2070,8 +2079,13 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		count = -(unsigned long) addr;
 	buflen = count;
 
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 	spin_lock(&vmap_area_lock);
 	list_for_each_entry(va, &vmap_area_list, list) {
+#else
+	rcu_read_lock();
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+#endif
 		if (!count)
 			break;
 
@@ -2101,7 +2115,11 @@ long vwrite(char *buf, char *addr, unsigned long count)
 		count -= n;
 	}
 finished:
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 	spin_unlock(&vmap_area_lock);
+#else
+	rcu_read_unlock();
+#endif
 	if (!copied)
 		return 0;
 	return buflen;
@@ -2531,6 +2549,7 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 #endif	/* CONFIG_SMP */
 
 #ifdef CONFIG_PROC_FS
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 static void *s_start(struct seq_file *m, loff_t *pos)
 	__acquires(&vmap_area_lock)
 {
@@ -2677,6 +2696,7 @@ static int __init proc_vmalloc_init(void)
 	return 0;
 }
 module_init(proc_vmalloc_init);
+#endif
 
 void get_vmalloc_info(struct vmalloc_info *vmi)
 {
@@ -2689,14 +2709,22 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 
 	prev_end = VMALLOC_START;
 
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 	spin_lock(&vmap_area_lock);
+#else
+	rcu_read_lock();
+#endif
 
 	if (list_empty(&vmap_area_list)) {
 		vmi->largest_chunk = VMALLOC_TOTAL;
 		goto out;
 	}
 
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 	list_for_each_entry(va, &vmap_area_list, list) {
+#else
+	list_for_each_entry_rcu(va, &vmap_area_list, list) {
+#endif
 		unsigned long addr = va->va_start;
 
 		/*
@@ -2723,7 +2751,11 @@ void get_vmalloc_info(struct vmalloc_info *vmi)
 		vmi->largest_chunk = VMALLOC_END - prev_end;
 
 out:
+#ifdef CONFIG_DEBUG_VMALLOCINFO
 	spin_unlock(&vmap_area_lock);
+#else
+	rcu_read_unlock();
+#endif
 }
 #endif
 
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
