Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 308896B00A1
	for <linux-mm@kvack.org>; Wed, 22 Aug 2012 11:00:19 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 33/36] autonuma: powerpc port
Date: Wed, 22 Aug 2012 16:59:17 +0200
Message-Id: <1345647560-30387-34-git-send-email-aarcange@redhat.com>
In-Reply-To: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>

    * PMD flaging is not required in powerpc since large pages
      are tracked in ptes.
    * Yet to be tested with large pages
    * This is an initial patch that partially works
    * knuma_scand and numa hinting page faults works
    * Page migration is yet to be observed/verified

Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/powerpc/include/asm/pgtable.h        |   48 ++++++++++++++++++++++++++++-
 arch/powerpc/include/asm/pte-hash64-64k.h |    4 ++-
 arch/powerpc/mm/numa.c                    |    3 +-
 mm/autonuma.c                             |    2 +-
 4 files changed, 53 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 2e0e411..5f03079 100644
--- a/arch/powerpc/include/asm/pgtable.h
+++ b/arch/powerpc/include/asm/pgtable.h
@@ -33,10 +33,56 @@ static inline int pte_dirty(pte_t pte)		{ return pte_val(pte) & _PAGE_DIRTY; }
 static inline int pte_young(pte_t pte)		{ return pte_val(pte) & _PAGE_ACCESSED; }
 static inline int pte_file(pte_t pte)		{ return pte_val(pte) & _PAGE_FILE; }
 static inline int pte_special(pte_t pte)	{ return pte_val(pte) & _PAGE_SPECIAL; }
-static inline int pte_present(pte_t pte)	{ return pte_val(pte) & _PAGE_PRESENT; }
+static inline int pte_present(pte_t pte)	{ return pte_val(pte) &
+							(_PAGE_PRESENT|_PAGE_NUMA_PTE); }
 static inline int pte_none(pte_t pte)		{ return (pte_val(pte) & ~_PTE_NONE_MASK) == 0; }
 static inline pgprot_t pte_pgprot(pte_t pte)	{ return __pgprot(pte_val(pte) & PAGE_PROT_BITS); }
 
+#ifdef CONFIG_AUTONUMA
+static inline int pte_numa(pte_t pte)
+{
+       return (pte_val(pte) &
+               (_PAGE_NUMA_PTE|_PAGE_PRESENT)) == _PAGE_NUMA_PTE;
+}
+
+#endif
+
+static inline pte_t pte_mknonnuma(pte_t pte)
+{
+       pte_val(pte) &= ~_PAGE_NUMA_PTE;
+       pte_val(pte) |= (_PAGE_PRESENT|_PAGE_ACCESSED);
+
+       return pte;
+}
+
+static inline pte_t pte_mknuma(pte_t pte)
+{
+       pte_val(pte) |= _PAGE_NUMA_PTE;
+       pte_val(pte) &= ~_PAGE_PRESENT;
+       return pte;
+}
+
+static inline int pmd_numa(pmd_t pmd)
+{
+       /* PMD tracking not implemented */
+       return 0;
+}
+
+static inline pmd_t pmd_mknonnuma(pmd_t pmd)
+{
+	BUG();
+	return pmd;
+}
+
+static inline pmd_t pmd_mknuma(pmd_t pmd)
+{
+	BUG();
+	return pmd;
+}
+
+/* No pmd flags on powerpc */
+#define set_pmd_at(mm, addr, pmdp, pmd)  do { } while (0)
+
 /* Conversion functions: convert a page and protection to a page entry,
  * and a page entry and page directory to the page they refer to.
  *
diff --git a/arch/powerpc/include/asm/pte-hash64-64k.h b/arch/powerpc/include/asm/pte-hash64-64k.h
index 59247e8..f7e1468 100644
--- a/arch/powerpc/include/asm/pte-hash64-64k.h
+++ b/arch/powerpc/include/asm/pte-hash64-64k.h
@@ -7,6 +7,8 @@
 #define _PAGE_COMBO	0x10000000 /* this is a combo 4k page */
 #define _PAGE_4K_PFN	0x20000000 /* PFN is for a single 4k page */
 
+#define _PAGE_NUMA_PTE 0x40000000 /* Adjust PTE_RPN_SHIFT below */
+
 /* For 64K page, we don't have a separate _PAGE_HASHPTE bit. Instead,
  * we set that to be the whole sub-bits mask. The C code will only
  * test this, so a multi-bit mask will work. For combo pages, this
@@ -36,7 +38,7 @@
  * That gives us a max RPN of 34 bits, which means a max of 50 bits
  * of addressable physical space, or 46 bits for the special 4k PFNs.
  */
-#define PTE_RPN_SHIFT	(30)
+#define PTE_RPN_SHIFT	(31)
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 39b1597..80af41e 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -22,6 +22,7 @@
 #include <linux/pfn.h>
 #include <linux/cpuset.h>
 #include <linux/node.h>
+#include <linux/page_autonuma.h>
 #include <asm/sparsemem.h>
 #include <asm/prom.h>
 #include <asm/smp.h>
@@ -1045,7 +1046,7 @@ void __init do_init_bootmem(void)
 		 * all reserved areas marked.
 		 */
 		NODE_DATA(nid) = careful_zallocation(nid,
-					sizeof(struct pglist_data),
+					autonuma_pglist_data_size(),
 					SMP_CACHE_BYTES, end_pfn);
 
   		dbg("node %d\n", nid);
diff --git a/mm/autonuma.c b/mm/autonuma.c
index ada6c57..a4da3f3 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -25,7 +25,7 @@ unsigned long autonuma_flags __read_mostly =
 #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
 	|(1<<AUTONUMA_ENABLED_FLAG)
 #endif
-	|(1<<AUTONUMA_SCAN_PMD_FLAG);
+	|(0<<AUTONUMA_SCAN_PMD_FLAG);
 
 static DEFINE_MUTEX(knumad_mm_mutex);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
