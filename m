Received: by nf-out-0910.google.com with SMTP id c29so556627nfb
        for <linux-mm@kvack.org>; Fri, 09 Jun 2006 07:42:18 -0700 (PDT)
Message-ID: <4489898F.9080805@innova-card.com>
Date: Fri, 09 Jun 2006 16:45:35 +0200
Reply-To: Franck <vagabon.xyz@gmail.com>
MIME-Version: 1.0
Subject: [SPARSEMEM] confusing uses of SPARSEM_EXTREME
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
From: Franck Bui-Huu <fbh.work@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Is it me or the use of CONFIG_SPARSEMEM_EXTREME is really confusing in
mm/sparce.c ? Shouldn't we use CONFIG_SPARSEMEM_STATIC instead like
the following patch suggests ?

-- >8 --
Subject: [PATCH] Remove confusing uses of SPARSEMEM_EXTREME

CONFIG_SPARSEMEM_EXTREME is used in sparce.c whereas
CONFIG_SPARSEMEM_STATIC seems to be more appropriate.

Signed-off-by: Franck Bui-Huu <vagabon.xyz@gmail.com> 

---

include/linux/mmzone.h |    2 +-
mm/sparse.c            |    6 +++---
2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ebfc238..35f38b0 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -551,7 +551,7 @@ #define SECTION_NR_TO_ROOT(sec)	((sec) /
 #define NR_SECTION_ROOTS	(NR_MEM_SECTIONS / SECTIONS_PER_ROOT)
 #define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
 
-#ifdef CONFIG_SPARSEMEM_EXTREME
+#ifndef CONFIG_SPARSEMEM_STATIC
 extern struct mem_section *mem_section[NR_SECTION_ROOTS];
 #else
 extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
diff --git a/mm/sparse.c b/mm/sparse.c
index 0a51f36..341d935 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -16,7 +16,7 @@ #include <asm/dma.h>
  *
  * 1) mem_section	- memory sections, mem_map's for valid memory
  */
-#ifdef CONFIG_SPARSEMEM_EXTREME
+#ifndef CONFIG_SPARSEMEM_STATIC
 struct mem_section *mem_section[NR_SECTION_ROOTS]
 	____cacheline_internodealigned_in_smp;
 #else
@@ -25,7 +25,7 @@ struct mem_section mem_section[NR_SECTIO
 #endif
 EXPORT_SYMBOL(mem_section);
 
-#ifdef CONFIG_SPARSEMEM_EXTREME
+#ifndef CONFIG_SPARSEMEM_STATIC
 static struct mem_section *sparse_index_alloc(int nid)
 {
 	struct mem_section *section = NULL;
@@ -67,7 +67,7 @@ out:
 	spin_unlock(&index_init_lock);
 	return ret;
 }
-#else /* !SPARSEMEM_EXTREME */
+#else /* SPARSEMEM_STATIC */
 static inline int sparse_index_init(unsigned long section_nr, int nid)
 {
 	return 0;
-- 
1.3.3.g8701

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
