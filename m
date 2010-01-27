Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7539A6B009E
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 19:48:17 -0500 (EST)
Date: Wed, 27 Jan 2010 01:47:18 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 31] Transparent Hugepage support #7
Message-ID: <20100127004718.GG30452@random.random>
References: <patchbomb.1264513915@v2.random>
 <20100126175532.GA3359@redhat.com>
 <20100127000029.GC30452@random.random>
 <20100127003202.GF30452@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100127003202.GF30452@random.random>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, Christoph Hellwig <chellwig@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

and this incremental one too or address won't be just right...

--- a/mm/huge_memory.c	2010-01-27 01:41:16.565920344 +0100
+++ b/mm/huge_memory.c	2010-01-27 01:40:58.669471461 +0100
@@ -1526,6 +1524,7 @@
 	pte_t *pte, *_pte;
 	int ret = 0, referenced = 0;
 	struct page *page;
+	unsigned long _address;
 
 	VM_BUG_ON(address & ~HPAGE_PMD_MASK);
 
@@ -1542,14 +1541,15 @@
 		goto out;
 
 	pte = pte_offset_map(pmd, address);
-	for (_pte = pte; _pte < pte+HPAGE_PMD_NR; _pte++) {
+	for (_address = address, _pte = pte; _pte < pte+HPAGE_PMD_NR;
+	     _pte++, _address += PAGE_SIZE) {
 		pte_t pteval = *_pte;
 		barrier(); /* read from memory */
 		if (!pte_present(pteval) || !pte_write(pteval))
 			goto out_unmap;
 		if (pte_young(pteval))
 			referenced = 1;
-		page = vm_normal_page(vma, address, pteval);
+		page = vm_normal_page(vma, _address, pteval);
 		if (unlikely(!page))
 			goto out_unmap;
 		VM_BUG_ON(PageCompound(page));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
