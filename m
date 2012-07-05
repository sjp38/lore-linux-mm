Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 7133A6B0073
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 12:56:36 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <svaidy@linux.vnet.ibm.com>;
	Thu, 5 Jul 2012 16:45:16 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q65GmYqk49152082
	for <linux-mm@kvack.org>; Fri, 6 Jul 2012 02:48:34 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q65GuQZZ018064
	for <linux-mm@kvack.org>; Fri, 6 Jul 2012 02:56:27 +1000
Date: Thu, 5 Jul 2012 22:26:06 +0530
From: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
Message-ID: <20120705165606.GA11296@dirshya.in.ibm.com>
Reply-To: svaidy@linux.vnet.ibm.com
References: <1340895238.28750.49.camel@twins>
 <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
 <20120629125517.GD32637@gmail.com>
 <4FEDDD0C.60609@redhat.com>
 <1340995260.28750.103.camel@twins>
 <4FEDF81C.1010401@redhat.com>
 <1340996224.28750.116.camel@twins>
 <1340996586.28750.122.camel@twins>
 <4FEDFFB5.3010401@redhat.com>
 <20120702165714.GA10952@dirshya.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120702165714.GA10952@dirshya.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

* Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com> [2012-07-02 22:27:15]:

> * Rik van Riel <riel@redhat.com> [2012-06-29 15:19:17]:
> 
> > On 06/29/2012 03:03 PM, Peter Zijlstra wrote:
> > >On Fri, 2012-06-29 at 20:57 +0200, Peter Zijlstra wrote:
> > >>On Fri, 2012-06-29 at 14:46 -0400, Rik van Riel wrote:
> > >>>
> > >>>I am not convinced all architectures that have CONFIG_NUMA
> > >>>need to be a requirement, since some of them (eg. Alpha)
> > >>>seem to be lacking a maintainer nowadays.
> > >>
> > >>Still, this NUMA balancing stuff is not a small tweak to load-balancing.
> > >>Its a very significant change is how you schedule. Having such great
> > >>differences over architectures isn't something I look forward to.
> > 
> > I am not too worried about the performance of architectures
> > that are essentially orphaned :)
> > 
> > >Also, Andrea keeps insisting arch support is trivial, so I don't see the
> > >problem.
> > 
> > Getting it implemented in one or two additional architectures
> > would be good, to get a template out there that can be used by
> > other architecture maintainers.
> 
> I am currently porting the framework over to powerpc.  I will share
> the initial patches in couple of days.

Here is the rough set of changes that are required to get the autonuma
framework working on powerpc.  This patch applies on autonuma19
branch.  Still work-in-progress, my goal is to evaluate the
implementation overheads and benefits on powerpc architecture.

--Vaidy

commit ede91b0af6c56d0ef5d1b07d195d7b59c3a324d0
Author: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>
Date:   Thu Jul 5 20:48:43 2012 +0530

    Basic changes to port Andrea's autonuma patches to powerpc.
    
    * PMD flaging is not required in powerpc since large pages
      are tracked in ptes.
    * Yet to be tested with large pages
    * This is an initial patch that partially works
    * knuma_scand and numa hinting page faults works
    * Page migration is yet to be observed/verified
    
    Signed-off-by: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>

diff --git a/arch/powerpc/include/asm/pgtable.h b/arch/powerpc/include/asm/pgtable.h
index 2e0e411..279d283 100644
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
+static inline pte_t pte_mknotnuma(pte_t pte)
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
+static inline pmd_t pmd_mknotnuma(pmd_t pmd)
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
index b6edbb3..45afa9a 100644
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
@@ -1043,7 +1044,7 @@ void __init do_init_bootmem(void)
 		 * all reserved areas marked.
 		 */
 		NODE_DATA(nid) = careful_zallocation(nid,
-					sizeof(struct pglist_data),
+					autonuma_pglist_data_size(),
 					SMP_CACHE_BYTES, end_pfn);
 
   		dbg("node %d\n", nid);
diff --git a/mm/Kconfig b/mm/Kconfig
index 330dd51..6fb6f25 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -210,7 +210,7 @@ config MIGRATION
 config AUTONUMA
 	bool "Auto NUMA"
 	select MIGRATION
-	depends on NUMA && X86
+	depends on NUMA && (X86 || PPC64)
 	help
 	  Automatic NUMA CPU scheduling and memory migration.
 
diff --git a/mm/autonuma.c b/mm/autonuma.c
index 1873a7b..58fa785 100644
--- a/mm/autonuma.c
+++ b/mm/autonuma.c
@@ -26,7 +26,7 @@ unsigned long autonuma_flags __read_mostly =
 #ifdef CONFIG_AUTONUMA_DEFAULT_ENABLED
 	(1<<AUTONUMA_FLAG)|
 #endif
-	(1<<AUTONUMA_SCAN_PMD_FLAG);
+	(0<<AUTONUMA_SCAN_PMD_FLAG);
 
 static DEFINE_MUTEX(knumad_mm_mutex);
 
diff --git a/mm/page_autonuma.c b/mm/page_autonuma.c
index b629074..96c2e26 100644
--- a/mm/page_autonuma.c
+++ b/mm/page_autonuma.c
@@ -1,5 +1,6 @@
 #include <linux/mm.h>
 #include <linux/memory.h>
+#include <linux/vmalloc.h>
 #include <linux/autonuma.h>
 #include <linux/page_autonuma.h>
 #include <linux/bootmem.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
