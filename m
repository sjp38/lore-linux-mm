Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4BDB56B0075
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 16:30:37 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Fri, 7 Dec 2012 16:30:35 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id ACF576E8047
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 16:30:32 -0500 (EST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qB7LUVMo254410
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 16:30:31 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qB7LURQI003934
	for <linux-mm@kvack.org>; Fri, 7 Dec 2012 14:30:27 -0700
Subject: [RFCv2][PATCH 3/3] make DEBUG_VIRTUAL work earlier in boot
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Fri, 07 Dec 2012 16:30:25 -0500
References: <20121207213023.AA3AFF11@kernel.stglabs.ibm.com>
In-Reply-To: <20121207213023.AA3AFF11@kernel.stglabs.ibm.com>
Message-Id: <20121207213025.53E4BD1B@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, Avi Kivity <avi@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>


The KVM code has some repeated bugs in it around use of __pa() on
per-cpu data.  Those data are not in an area on which __pa() is
valid.  However, they are also called early enough in boot that
__vmalloc_start_set is not set, and thus the CONFIG_DEBUG_VIRTUAL
debugging does not catch them.

This adds a check to also verify them against max_low_pfn, which
we can use earler in boot than is_vmalloc_addr().  However, if
we are super-early in boot, max_low_pfn=0 and this will trip
on every call, so also make sure that max_low_pfn is set.

With this patch applied, CONFIG_DEBUG_VIRTUAL will actually
catch the bug I was chasing.

I'd love to find a generic way so that any __pa() call on percpu
areas could do a BUG_ON(), but there don't appear to be any nice
and easy ways to check if an address is a percpu one.  Anybody
have ideas on a way to do this?

---

 linux-2.6.git-dave/arch/x86/mm/numa.c     |    2 +-
 linux-2.6.git-dave/arch/x86/mm/pat.c      |    4 ++--
 linux-2.6.git-dave/arch/x86/mm/physaddr.c |   10 ++++++++--
 3 files changed, 11 insertions(+), 5 deletions(-)

diff -puN arch/x86/mm/physaddr.c~make-DEBUG_VIRTUAL-work-earlier-in-boot arch/x86/mm/physaddr.c
--- linux-2.6.git/arch/x86/mm/physaddr.c~make-DEBUG_VIRTUAL-work-earlier-in-boot	2012-11-30 16:18:44.522847232 -0500
+++ linux-2.6.git-dave/arch/x86/mm/physaddr.c	2012-11-30 16:18:44.530847298 -0500
@@ -1,3 +1,4 @@
+#include <linux/bootmem.h>
 #include <linux/mmdebug.h>
 #include <linux/module.h>
 #include <linux/mm.h>
@@ -41,16 +42,21 @@ bool __virt_addr_valid(unsigned long x)
 	return pfn_valid(x >> PAGE_SHIFT);
 }
 EXPORT_SYMBOL(__virt_addr_valid);
-
 #else
 
 #ifdef CONFIG_DEBUG_VIRTUAL
 unsigned long __phys_addr(unsigned long x)
 {
+	unsigned long phys_addr = x - PAGE_OFFSET;
 	/* VMALLOC_* aren't constants  */
 	VIRTUAL_BUG_ON(x < PAGE_OFFSET);
 	VIRTUAL_BUG_ON(__vmalloc_start_set && is_vmalloc_addr((void *) x));
-	return x - PAGE_OFFSET;
+	/* max_low_pfn is set early, but not _that_ early */
+	if (max_low_pfn) {
+		VIRTUAL_BUG_ON((phys_addr >> PAGE_SHIFT) > max_low_pfn);
+		BUG_ON(slow_virt_to_phys((void *)x) != phys_addr);
+	}
+	return phys_addr;
 }
 EXPORT_SYMBOL(__phys_addr);
 #endif
diff -puN arch/x86/kernel/kvmclock.c~make-DEBUG_VIRTUAL-work-earlier-in-boot arch/x86/kernel/kvmclock.c
diff -L sr -puN /dev/null /dev/null
diff -puN arch/x86/include/asm/page_32.h~make-DEBUG_VIRTUAL-work-earlier-in-boot arch/x86/include/asm/page_32.h
diff -puN arch/x86/mm/numa.c~make-DEBUG_VIRTUAL-work-earlier-in-boot arch/x86/mm/numa.c
--- linux-2.6.git/arch/x86/mm/numa.c~make-DEBUG_VIRTUAL-work-earlier-in-boot	2012-11-30 16:18:44.526847265 -0500
+++ linux-2.6.git-dave/arch/x86/mm/numa.c	2012-11-30 16:18:44.534847331 -0500
@@ -219,7 +219,7 @@ static void __init setup_node_data(int n
 	 */
 	nd = alloc_remap(nid, nd_size);
 	if (nd) {
-		nd_pa = __pa(nd);
+		nd_pa = __phys_addr_nodebug(nd);
 		remapped = true;
 	} else {
 		nd_pa = memblock_alloc_nid(nd_size, SMP_CACHE_BYTES, nid);
diff -puN arch/x86/mm/pat.c~make-DEBUG_VIRTUAL-work-earlier-in-boot arch/x86/mm/pat.c
--- linux-2.6.git/arch/x86/mm/pat.c~make-DEBUG_VIRTUAL-work-earlier-in-boot	2012-11-30 16:19:34.371258739 -0500
+++ linux-2.6.git-dave/arch/x86/mm/pat.c	2012-11-30 16:22:38.528778740 -0500
@@ -560,10 +560,10 @@ int kernel_map_sync_memtype(u64 base, un
 {
 	unsigned long id_sz;
 
-	if (base >= __pa(high_memory))
+	if (base > __pa(high_memory-1))
 		return 0;
 
-	id_sz = (__pa(high_memory) < base + size) ?
+	id_sz = (__pa(high_memory-1) <= base + size) ?
 				__pa(high_memory) - base :
 				size;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
