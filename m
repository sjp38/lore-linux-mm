Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 81E226B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 07:19:41 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.1/8.13.1) with ESMTP id n99BJbOr019226
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 11:19:37 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n99BJZIw3424334
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 13:19:37 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n99BJZBL009805
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 13:19:35 +0200
From: Ehrhardt Christian <ehrhardt@linux.vnet.ibm.com>
Subject: [PATCH] mm: make VM_MAX_READAHEAD configurable
Date: Fri,  9 Oct 2009 13:19:35 +0200
Message-Id: <1255087175-21200-1-git-send-email-ehrhardt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Jens Axboe <jens.axboe@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>

On one hand the define VM_MAX_READAHEAD in include/linux/mm.h is just a default
and can be configured per block device queue.
On the other hand a lot of admins do not use it, therefore it is reasonable to
set a wise default.

This path allows to configure the value via Kconfig mechanisms and therefore
allow the assignment of different defaults dependent on other Kconfig symbols.

Using this, the patch increases the default max readahead for s390 improving
sequential throughput in a lot of scenarios with almost no drawbacks (only
theoretical workloads with a lot concurrent sequential read patterns on a very
low memory system suffer due to page cache trashing as expected).

Signed-off-by: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
---

[diffstat]
 include/linux/mm.h |    2 +-
 mm/Kconfig         |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 1 deletion(-)

[diff]
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -1169,7 +1169,7 @@ int write_one_page(struct page *page, in
 void task_dirty_inc(struct task_struct *tsk);
 
 /* readahead.c */
-#define VM_MAX_READAHEAD	128	/* kbytes */
+#define VM_MAX_READAHEAD	CONFIG_VM_MAX_READAHEAD	/* kbytes */
 #define VM_MIN_READAHEAD	16	/* kbytes (includes current page) */
 
 int force_page_cache_readahead(struct address_space *mapping, struct file *filp,
Index: linux-2.6/mm/Kconfig
===================================================================
--- linux-2.6.orig/mm/Kconfig
+++ linux-2.6/mm/Kconfig
@@ -288,3 +288,22 @@ config NOMMU_INITIAL_TRIM_EXCESS
 	  of 1 says that all excess pages should be trimmed.
 
 	  See Documentation/nommu-mmap.txt for more information.
+
+config VM_MAX_READAHEAD
+	int "Default max vm readahead size (16-4096 kbytes)"
+	default "512" if S390
+	default "128"
+	range 16 4096
+	help
+	  This entry specifies the default max size used to read ahead
+	  sequential access patterns in kilobytes.
+
+	  The value can be configured per device queue in /dev, this setting
+	  just defines the default.
+
+	  The default is 128 which it used to be for years and should suit all
+	  kind of linux targets.
+
+	  Smaller values might be useful for very memory constrained systems
+	  like some embedded systems to avoid page cache trashing, while larger
+	  values can be beneficial to server installations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
