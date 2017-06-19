Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B86F6B02F4
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:28:48 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r70so115153201pfb.7
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:28:48 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 1si10086160plk.522.2017.06.19.16.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:28:47 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 2/4] percpu: migrate percpu data structures to internal header
Date: Mon, 19 Jun 2017 19:28:30 -0400
Message-ID: <20170619232832.27116-3-dennisz@fb.com>
In-Reply-To: <20170619232832.27116-1-dennisz@fb.com>
References: <20170619232832.27116-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Dennis Zhou <dennisz@fb.com>

Migrates pcpu_chunk definition and a few percpu static variables to an
internal header file from mm/percpu.c. These will be used with debugfs
to expose statistics about percpu memory improving visibility regarding
allocations and fragmentation.

Signed-off-by: Dennis Zhou <dennisz@fb.com>
---
 mm/percpu-internal.h | 33 +++++++++++++++++++++++++++++++++
 mm/percpu.c          | 30 +++++++-----------------------
 2 files changed, 40 insertions(+), 23 deletions(-)
 create mode 100644 mm/percpu-internal.h

diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
new file mode 100644
index 0000000..8b6cb2a
--- /dev/null
+++ b/mm/percpu-internal.h
@@ -0,0 +1,33 @@
+#ifndef _MM_PERCPU_INTERNAL_H
+#define _MM_PERCPU_INTERNAL_H
+
+#include <linux/types.h>
+#include <linux/percpu.h>
+
+struct pcpu_chunk {
+	struct list_head	list;		/* linked to pcpu_slot lists */
+	int			free_size;	/* free bytes in the chunk */
+	int			contig_hint;	/* max contiguous size hint */
+	void			*base_addr;	/* base address of this chunk */
+
+	int			map_used;	/* # of map entries used before the sentry */
+	int			map_alloc;	/* # of map entries allocated */
+	int			*map;		/* allocation map */
+	struct list_head	map_extend_list;/* on pcpu_map_extend_chunks */
+
+	void			*data;		/* chunk data */
+	int			first_free;	/* no free below this */
+	bool			immutable;	/* no [de]population allowed */
+	int			nr_populated;	/* # of populated pages */
+	unsigned long		populated[];	/* populated bitmap */
+};
+
+extern spinlock_t pcpu_lock;
+
+extern struct list_head *pcpu_slot __read_mostly;
+extern int pcpu_nr_slots __read_mostly;
+
+extern struct pcpu_chunk *pcpu_first_chunk;
+extern struct pcpu_chunk *pcpu_reserved_chunk;
+
+#endif
diff --git a/mm/percpu.c b/mm/percpu.c
index f94a5eb..5cf7d73 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -76,6 +76,8 @@
 #include <asm/tlbflush.h>
 #include <asm/io.h>
 
+#include "percpu-internal.h"
+
 #define PCPU_SLOT_BASE_SHIFT		5	/* 1-31 shares the same slot */
 #define PCPU_DFL_MAP_ALLOC		16	/* start a map with 16 ents */
 #define PCPU_ATOMIC_MAP_MARGIN_LOW	32
@@ -103,29 +105,11 @@
 #define __pcpu_ptr_to_addr(ptr)		(void __force *)(ptr)
 #endif	/* CONFIG_SMP */
 
-struct pcpu_chunk {
-	struct list_head	list;		/* linked to pcpu_slot lists */
-	int			free_size;	/* free bytes in the chunk */
-	int			contig_hint;	/* max contiguous size hint */
-	void			*base_addr;	/* base address of this chunk */
-
-	int			map_used;	/* # of map entries used before the sentry */
-	int			map_alloc;	/* # of map entries allocated */
-	int			*map;		/* allocation map */
-	struct list_head	map_extend_list;/* on pcpu_map_extend_chunks */
-
-	void			*data;		/* chunk data */
-	int			first_free;	/* no free below this */
-	bool			immutable;	/* no [de]population allowed */
-	int			nr_populated;	/* # of populated pages */
-	unsigned long		populated[];	/* populated bitmap */
-};
-
 static int pcpu_unit_pages __read_mostly;
 static int pcpu_unit_size __read_mostly;
 static int pcpu_nr_units __read_mostly;
 static int pcpu_atom_size __read_mostly;
-static int pcpu_nr_slots __read_mostly;
+int pcpu_nr_slots __read_mostly;
 static size_t pcpu_chunk_struct_size __read_mostly;
 
 /* cpus with the lowest and highest unit addresses */
@@ -149,7 +133,7 @@ static const size_t *pcpu_group_sizes __read_mostly;
  * chunks, this one can be allocated and mapped in several different
  * ways and thus often doesn't live in the vmalloc area.
  */
-static struct pcpu_chunk *pcpu_first_chunk;
+struct pcpu_chunk *pcpu_first_chunk;
 
 /*
  * Optional reserved chunk.  This chunk reserves part of the first
@@ -158,13 +142,13 @@ static struct pcpu_chunk *pcpu_first_chunk;
  * area doesn't exist, the following variables contain NULL and 0
  * respectively.
  */
-static struct pcpu_chunk *pcpu_reserved_chunk;
+struct pcpu_chunk *pcpu_reserved_chunk;
 static int pcpu_reserved_chunk_limit;
 
-static DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
+DEFINE_SPINLOCK(pcpu_lock);	/* all internal data structures */
 static DEFINE_MUTEX(pcpu_alloc_mutex);	/* chunk create/destroy, [de]pop, map ext */
 
-static struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
+struct list_head *pcpu_slot __read_mostly; /* chunk list slots */
 
 /* chunks which need their map areas extended, protected by pcpu_lock */
 static LIST_HEAD(pcpu_map_extend_chunks);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
