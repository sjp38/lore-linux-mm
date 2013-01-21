Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id EFACF6B0012
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 12:53:00 -0500 (EST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 Jan 2013 10:53:00 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 34D7719D8048
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:55 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0LHqp0x167752
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:52 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0LHqkAU025212
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 10:52:47 -0700
Subject: [PATCH 1/5] make DEBUG_VIRTUAL work earlier in boot
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Mon, 21 Jan 2013 09:52:45 -0800
References: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
In-Reply-To: <20130121175244.E5839E06@kernel.stglabs.ibm.com>
Message-Id: <20130121175245.3081B2B1@kernel.stglabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Gleb Natapov <gleb@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>


The KVM code has some repeated bugs in it around use of __pa() on
per-cpu data.  Those data are not in an area on which using
__pa() is valid.  However, they are also called early enough in
boot that __vmalloc_start_set is not set, and thus the
CONFIG_DEBUG_VIRTUAL debugging does not catch them.

This adds a check to also verify __pa() calls against max_low_pfn,
which we can use earler in boot than is_vmalloc_addr().  However,
if we are super-early in boot, max_low_pfn=0 and this will trip
on every call, so also make sure that max_low_pfn is set before
we try to use it.

With this patch applied, CONFIG_DEBUG_VIRTUAL will actually
catch the bug I was chasing (and fix later in this series).

I'd love to find a generic way so that any __pa() call on percpu
areas could do a BUG_ON(), but there don't appear to be any nice
and easy ways to check if an address is a percpu one.  Anybody
have ideas on a way to do this?

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/arch/x86/mm/numa.c     |    2 +-
 linux-2.6.git-dave/arch/x86/mm/pat.c      |    4 ++--
 linux-2.6.git-dave/arch/x86/mm/physaddr.c |    9 ++++++++-
 3 files changed, 11 insertions(+), 4 deletions(-)

diff -puN arch/x86/mm/numa.c~make-DEBUG_VIRTUAL-work-earlier-in-boot arch/x86/mm/numa.c
--- linux-2.6.git/arch/x86/mm/numa.c~make-DEBUG_VIRTUAL-work-earlier-in-boot	2013-01-17 10:22:25.614425502 -0800
+++ linux-2.6.git-dave/arch/x86/mm/numa.c	2013-01-17 10:22:25.622425572 -0800
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
--- linux-2.6.git/arch/x86/mm/pat.c~make-DEBUG_VIRTUAL-work-earlier-in-boot	2013-01-17 10:22:25.614425502 -0800
+++ linux-2.6.git-dave/arch/x86/mm/pat.c	2013-01-17 10:22:25.622425572 -0800
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
 
diff -puN arch/x86/mm/physaddr.c~make-DEBUG_VIRTUAL-work-earlier-in-boot arch/x86/mm/physaddr.c
--- linux-2.6.git/arch/x86/mm/physaddr.c~make-DEBUG_VIRTUAL-work-earlier-in-boot	2013-01-17 10:22:25.618425536 -0800
+++ linux-2.6.git-dave/arch/x86/mm/physaddr.c	2013-01-17 10:22:25.622425572 -0800
@@ -1,3 +1,4 @@
+#include <linux/bootmem.h>
 #include <linux/mmdebug.h>
 #include <linux/module.h>
 #include <linux/mm.h>
@@ -47,10 +48,16 @@ EXPORT_SYMBOL(__virt_addr_valid);
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
