Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D67C56B0568
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:54:39 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id 66-v6so15344541itz.9
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:54:39 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id f55-v6si1371529jal.44.2018.11.07.12.54.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Nov 2018 12:54:38 -0800 (PST)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed,  7 Nov 2018 13:54:33 -0700
Message-Id: <20181107205433.3875-3-logang@deltatee.com>
In-Reply-To: <20181107205433.3875-1-logang@deltatee.com>
References: <20181107205433.3875-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v2 2/2] mm/sparse: add common helper to mark all memblocks present
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Logan Gunthorpe <logang@deltatee.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>

Presently the arches arm64, arm and sh have a function which loops through
each memblock and calls memory present. riscv will require a similar
function.

Introduce a common memblocks_present() function that can be used by
all the arches. Subsequent patches will cleanup the arches that
make use of this.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Acked-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Oscar Salvador <osalvador@suse.de>
---
 include/linux/mmzone.h |  6 ++++++
 mm/sparse.c            | 16 ++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 847705a6d0ec..db023a92f3a4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -783,6 +783,12 @@ void memory_present(int nid, unsigned long start, unsigned long end);
 static inline void memory_present(int nid, unsigned long start, unsigned long end) {}
 #endif
 
+#if defined(CONFIG_SPARSEMEM)
+void memblocks_present(void);
+#else
+static inline void memblocks_present(void) {}
+#endif
+
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
 int local_memory_node(int node_id);
 #else
diff --git a/mm/sparse.c b/mm/sparse.c
index 33307fc05c4d..3abc8cc50201 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -239,6 +239,22 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 	}
 }
 
+/*
+ * Mark all memblocks as present using memory_present(). This is a
+ * convienence function that is useful for a number of arches
+ * to mark all of the systems memory as present during initialization.
+ */
+void __init memblocks_present(void)
+{
+	struct memblock_region *reg;
+
+	for_each_memblock(memory, reg) {
+		memory_present(memblock_get_region_node(reg),
+			       memblock_region_memory_base_pfn(reg),
+			       memblock_region_memory_end_pfn(reg));
+	}
+}
+
 /*
  * Subtle, we encode the real pfn into the mem_map such that
  * the identity pfn - section_mem_map will return the actual
-- 
2.19.0
