Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E94286B0495
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 19:03:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e9so32748159pga.5
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 16:03:02 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id c66si4531152pfb.46.2017.07.24.16.03.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 16:03:01 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH v2 23/23] percpu: update header to contain bitmap allocator explanation.
Date: Mon, 24 Jul 2017 19:02:20 -0400
Message-ID: <20170724230220.21774-24-dennisz@fb.com>
In-Reply-To: <20170724230220.21774-1-dennisz@fb.com>
References: <20170724230220.21774-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Josef Bacik <josef@toxicpanda.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, Dennis Zhou <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

The other patches contain a lot of information, so adding this
information in a separate patch. It adds my copyright and a brief
explanation of how the bitmap allocator works. There is a minor typo as
well in the prior explanation so that is fixed.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 mm/percpu.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index ffa9da7..a4dd0c8 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -4,6 +4,9 @@
  * Copyright (C) 2009		SUSE Linux Products GmbH
  * Copyright (C) 2009		Tejun Heo <tj@kernel.org>
  *
+ * Copyright (C) 2017		Facebook Inc.
+ * Copyright (C) 2017		Dennis Zhou <dennisszhou@gmail.com>
+ *
  * This file is released under the GPLv2 license.
  *
  * The percpu allocator handles both static and dynamic areas.  Percpu
@@ -25,7 +28,7 @@
  *
  * There is special consideration for the first chunk which must handle
  * the static percpu variables in the kernel image as allocation services
- * are not online yet.  In short, the first chunk is structure like so:
+ * are not online yet.  In short, the first chunk is structured like so:
  *
  *                  <Static | [Reserved] | Dynamic>
  *
@@ -34,19 +37,20 @@
  * percpu variables from kernel modules.  Finally, the dynamic section
  * takes care of normal allocations.
  *
- * Allocation state in each chunk is kept using an array of integers
- * on chunk->map.  A positive value in the map represents a free
- * region and negative allocated.  Allocation inside a chunk is done
- * by scanning this map sequentially and serving the first matching
- * entry.  This is mostly copied from the percpu_modalloc() allocator.
- * Chunks can be determined from the address using the index field
- * in the page struct. The index field contains a pointer to the chunk.
- *
- * These chunks are organized into lists according to free_size and
- * tries to allocate from the fullest chunk first. Each chunk maintains
- * a maximum contiguous area size hint which is guaranteed to be equal
- * to or larger than the maximum contiguous area in the chunk. This
- * helps prevent the allocator from iterating over chunks unnecessarily.
+ * The allocator organizes chunks into lists according to free size and
+ * tries to allocate from the fullest chunk first.  Each chunk is managed
+ * by a bitmap with metadata blocks.  The allocation map is updated on
+ * every allocation and free to reflect the current state while the boundary
+ * map is only updated on allocation.  Each metadata block contains
+ * information to help mitigate the need to iterate over large portions
+ * of the bitmap.  The reverse mapping from page to chunk is stored in
+ * the page's index.  Lastly, units are lazily backed and grow in unison.
+ *
+ * There is a unique conversion that goes on here between bytes and bits.
+ * Each bit represents a fragment of size PCPU_MIN_ALLOC_SIZE.  The chunk
+ * tracks the number of pages it is responsible for in nr_pages.  Helper
+ * functions are used to convert from between the bytes, bits, and blocks.
+ * All hints are managed in bits unless explicitly stated.
  *
  * To use this allocator, arch code should do the following:
  *
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
