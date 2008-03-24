Received: by wa-out-1112.google.com with SMTP id m33so2963926wag.8
        for <linux-mm@kvack.org>; Mon, 24 Mar 2008 08:09:05 -0700 (PDT)
From: Nitin Gupta <nitingupta910@gmail.com>
Reply-To: nitingupta910@gmail.com
Subject: [PATCH 3/6] compcache: TLSF Allocator interface
Date: Mon, 24 Mar 2008 20:34:24 +0530
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200803242034.24264.nitingupta910@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Two Level Segregate Fit (TLSF) Allocator is used to allocate memory for
variable size compressed pages. Its fast and gives low fragmentation.
Following links give details on this allocator:
 - http://rtportal.upv.es/rtmalloc/files/tlsf_paper_spe_2007.pdf
 - http://code.google.com/p/compcache/wiki/TLSFAllocator

This kernel port of TLSF (v2.3.2) introduces several changes but underlying
algorithm remains the same.

Changelog TLSF v2.3.2 vs this kernel port
 - Pool now dynamically expands/shrinks.
   It is collection of contiguous memory regions.
 - Changes to pool create interface as a result of above change.
 - Collect and export stats (/proc/tlsfinfo)
 - Cleanups: kernel coding style, added comments, macros -> static inline, etc.

Signed-off-by: Nitin Gupta <nitingupta910 at gmail dot com>
---

 include/linux/tlsf.h |   93 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 93 insertions(+), 0 deletions(-)

diff --git a/include/linux/tlsf.h b/include/linux/tlsf.h
new file mode 100644
index 0000000..ef8092c
--- /dev/null
+++ b/include/linux/tlsf.h
@@ -0,0 +1,93 @@
+/*
+ * Two Levels Segregate Fit memory allocator (TLSF)
+ * Version 2.3.2
+ *
+ * Written by Miguel Masmano Tello <mimastel@doctor.upv.es>
+ *
+ * Thanks to Ismael Ripoll for his suggestions and reviews
+ *
+ * Copyright (C) 2007, 2006, 2005, 2004
+ *
+ * This code is released using a dual license strategy: GPL/LGPL
+ * You can choose the licence that better fits your requirements.
+ *
+ * Released under the terms of the GNU General Public License Version 2.0
+ * Released under the terms of the GNU Lesser General Public License Version 2.1
+ *
+ * This is kernel port of TLSF allocator.
+ * Original code can be found at: http://rtportal.upv.es/rtmalloc/
+ * 	- Nitin Gupta (nitingupta910 at gmail dot com)
+ */
+
+#ifndef _TLSF_H_
+#define _TLSF_H_
+
+typedef void* (get_memory)(size_t bytes);
+typedef void (put_memory)(void *ptr);
+
+/**
+ * tlsf_create_memory_pool - create dynamic memory pool
+ * @name: name of the pool
+ * @get_mem: callback function used to expand pool
+ * @put_mem: callback function used to shrink pool
+ * @init_size: inital pool size (in bytes)
+ * @max_size: maximum pool size (in bytes) - set this as 0 for no limit
+ * @grow_size: amount of memory (in bytes) added to pool whenever required
+ *
+ * All size values are rounded up to next page boundary.
+ */
+extern void *tlsf_create_memory_pool(const char *name,
+					get_memory get_mem,
+					put_memory put_mem,
+					size_t init_size,
+					size_t max_size,
+					size_t grow_size);
+/**
+ * tlsf_destory_memory_pool - cleanup given pool
+ * @mem_pool: Pool to be destroyed
+ *
+ * Data structures associated with pool are freed.
+ * All memory allocated from pool must be freed before
+ * destorying it.
+ */
+extern void tlsf_destroy_memory_pool(void *mem_pool);
+
+/**
+ * tlsf_malloc - allocate memory from given pool
+ * @size: no. of bytes
+ * @mem_pool: pool to allocate from
+ */
+extern void *tlsf_malloc(size_t size, void *mem_pool);
+
+/**
+ * tlsf_calloc - allocate and zero-out memory from given pool
+ * @size: no. of bytes
+ * @mem_pool: pool to allocate from
+ */
+extern void *tlsf_calloc(size_t nelem, size_t elem_size, void *mem_pool);
+
+/**
+ * tlsf_free - free memory from given pool
+ * @ptr: address of memory to be freed
+ * @mem_pool: pool to free from
+ */
+extern void tlsf_free(void *ptr, void *mem_pool);
+
+/**
+ * tlsf_get_used_size - get memory currently used by given pool
+ *
+ * Used memory includes stored data + metadata + internal fragmentation
+ */
+extern size_t tlsf_get_used_size(void *mem_pool);
+
+/**
+ * tlsf_get_total_size - get total memory currently allocated for given pool
+ *
+ * This is the total memory currently allocated for this pool which includes
+ * used size + free size.
+ *
+ * (Total - Used) is good indicator of memory efficiency of allocator.
+ */
+extern size_t tlsf_get_total_size(void *mem_pool);
+
+#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
