Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A7104900016
	for <linux-mm@kvack.org>; Tue,  3 Feb 2015 12:43:46 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so98796562pab.11
        for <linux-mm@kvack.org>; Tue, 03 Feb 2015 09:43:46 -0800 (PST)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id yt1si3323822pab.64.2015.02.03.09.43.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Tue, 03 Feb 2015 09:43:41 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NJ700IWCIRKXU50@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 03 Feb 2015 17:47:44 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v11 08/19] mm: slub: introduce
 metadata_access_enable()/metadata_access_disable()
Date: Tue, 03 Feb 2015 20:43:01 +0300
Message-id: <1422985392-28652-9-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

It's ok for slub to access memory that marked by kasan as inaccessible
(object's metadata). Kasan shouldn't print report in that case because
these accesses are valid. Disabling instrumentation of slub.c code is
not enough to achieve this because slub passes pointer to object's
metadata into external functions like memchr_inv().

We don't want to disable instrumentation for memchr_inv() because
this is quite generic function, and we don't want to miss bugs.

metadata_access_enable/metadata_access_disable used to tell
KASan where accesses to metadata starts/end, so we
could temporarily disable KASan reports.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slub.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 3eb73f5..390972f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -20,6 +20,7 @@
 #include <linux/proc_fs.h>
 #include <linux/notifier.h>
 #include <linux/seq_file.h>
+#include <linux/kasan.h>
 #include <linux/kmemcheck.h>
 #include <linux/cpu.h>
 #include <linux/cpuset.h>
@@ -468,12 +469,30 @@ static char *slub_debug_slabs;
 static int disable_higher_order_debug;
 
 /*
+ * slub is about to manipulate internal object metadata.  This memory lies
+ * outside the range of the allocated object, so accessing it would normally
+ * be reported by kasan as a bounds error.  metadata_access_enable() is used
+ * to tell kasan that these accesses are OK.
+ */
+static inline void metadata_access_enable(void)
+{
+	kasan_disable_current();
+}
+
+static inline void metadata_access_disable(void)
+{
+	kasan_enable_current();
+}
+
+/*
  * Object debugging
  */
 static void print_section(char *text, u8 *addr, unsigned int length)
 {
+	metadata_access_enable();
 	print_hex_dump(KERN_ERR, text, DUMP_PREFIX_ADDRESS, 16, 1, addr,
 			length, 1);
+	metadata_access_disable();
 }
 
 static struct track *get_track(struct kmem_cache *s, void *object,
@@ -503,7 +522,9 @@ static void set_track(struct kmem_cache *s, void *object,
 		trace.max_entries = TRACK_ADDRS_COUNT;
 		trace.entries = p->addrs;
 		trace.skip = 3;
+		metadata_access_enable();
 		save_stack_trace(&trace);
+		metadata_access_disable();
 
 		/* See rant in lockdep.c */
 		if (trace.nr_entries != 0 &&
@@ -677,7 +698,9 @@ static int check_bytes_and_report(struct kmem_cache *s, struct page *page,
 	u8 *fault;
 	u8 *end;
 
+	metadata_access_enable();
 	fault = memchr_inv(start, value, bytes);
+	metadata_access_disable();
 	if (!fault)
 		return 1;
 
@@ -770,7 +793,9 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 	if (!remainder)
 		return 1;
 
+	metadata_access_enable();
 	fault = memchr_inv(end - remainder, POISON_INUSE, remainder);
+	metadata_access_disable();
 	if (!fault)
 		return 1;
 	while (end > fault && end[-1] == POISON_INUSE)
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
