Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 0CF966B002B
	for <linux-mm@kvack.org>; Sat, 10 Nov 2012 21:03:27 -0500 (EST)
From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/1] mm: Export a function to read vm_committed_as
Date: Sat, 10 Nov 2012 18:25:28 -0800
Message-Id: <1352600728-17766-1-git-send-email-kys@microsoft.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com
Cc: "K. Y. Srinivasan" <kys@microsoft.com>

It may be useful to be able to access vm_committed_as from device
drivers. On the Hyper-V platform, the host has a policy engine to balance
the available physical memory amongst all competing virtual machines
hosted on a given node. This policy engine is driven by a number of metrics
including the memory pressure reported by the guests. The balloon driver
for Linux on Hyper-V uses this function to report memory pressure back to
the host.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 include/linux/mman.h |    2 ++
 mm/mmap.c            |   11 +++++++++++
 mm/nommu.c           |   11 +++++++++++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/include/linux/mman.h b/include/linux/mman.h
index d09dde1..d53dc3d 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -11,6 +11,8 @@ extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern struct percpu_counter vm_committed_as;
 
+unsigned long read_vm_committed_as(void);
+
 static inline void vm_acct_memory(long pages)
 {
 	percpu_counter_add(&vm_committed_as, pages);
diff --git a/mm/mmap.c b/mm/mmap.c
index 2d94235..e527239 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -89,6 +89,17 @@ int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
 
 /*
+ * A wrapper to read vm_committed_as that can be used by external modules.
+ */
+
+unsigned long read_vm_committed_as(void)
+{
+	return percpu_counter_read_positive(&vm_committed_as);
+}
+
+EXPORT_SYMBOL_GPL(read_vm_committed_as);
+
+/*
  * Check that a process has enough memory to allocate a new virtual
  * mapping. 0 means there is enough memory for the allocation to
  * succeed and -ENOMEM implies there is not.
diff --git a/mm/nommu.c b/mm/nommu.c
index 45131b4..dbbd0aa 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -66,6 +66,17 @@ int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
 
+/*
+ * A wrapper to read vm_committed_as that can be used by external modules.
+ */
+
+unsigned long read_vm_committed_as(void)
+{
+	return percpu_counter_read_positive(&vm_committed_as);
+}
+
+EXPORT_SYMBOL_GPL(read_vm_committed_as);
+
 EXPORT_SYMBOL(mem_map);
 EXPORT_SYMBOL(num_physpages);
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
