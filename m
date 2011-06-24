Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C20BF900194
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 02:54:47 -0400 (EDT)
Date: Fri, 24 Jun 2011 02:53:35 -0400
From: Chuck Ebbert <cebbert@redhat.com>
Subject: [PATCH] mm: fix unmap_atomic range checks
Message-ID: <20110624025335.21811fef@katamari>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>

Commit 3e4d3af501cccdc8a8cca41bdbe57d54ad7e7e73 ("mm: stack based
kmap_atomic()", in 2.6.37-rc1) had three places where range checking
logic was reversed.

Signed-off-by: Chuck Ebbert <cebbert@redhat.com>

--- a/arch/tile/mm/highmem.c
+++ b/arch/tile/mm/highmem.c
@@ -235,8 +235,8 @@ void __kunmap_atomic(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 
-	if (vaddr >= __fix_to_virt(FIX_KMAP_END) &&
-	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
+	if (vaddr >= __fix_to_virt(FIX_KMAP_BEGIN) &&
+	    vaddr <= __fix_to_virt(FIX_KMAP_END)) {
 		pte_t *pte = kmap_get_pte(vaddr);
 		pte_t pteval = *pte;
 		int idx, type;
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -70,8 +70,8 @@ void __kunmap_atomic(void *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 
-	if (vaddr >= __fix_to_virt(FIX_KMAP_END) &&
-	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
+	if (vaddr >= __fix_to_virt(FIX_KMAP_BEGIN) &&
+	    vaddr <= __fix_to_virt(FIX_KMAP_END)) {
 		int idx, type;
 
 		type = kmap_atomic_idx();
--- a/arch/x86/mm/iomap_32.c
+++ b/arch/x86/mm/iomap_32.c
@@ -94,8 +94,8 @@ iounmap_atomic(void __iomem *kvaddr)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 
-	if (vaddr >= __fix_to_virt(FIX_KMAP_END) &&
-	    vaddr <= __fix_to_virt(FIX_KMAP_BEGIN)) {
+	if (vaddr >= __fix_to_virt(FIX_KMAP_BEGIN) &&
+	    vaddr <= __fix_to_virt(FIX_KMAP_END)) {
 		int idx, type;
 
 		type = kmap_atomic_idx();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
