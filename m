Date: Tue, 29 Jun 2004 17:17:24 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: remap_pte_range
Message-ID: <65600000.1088554644@flay>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm mailing list <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I have no idea what remap_pte_range is trying to do here, but what it
is doing makes no sense (to me at least). 

If the pfn is not valid, we CANNOT safely call PageReserved on it - 
the *page returned from pfn_to_page is bullshit, and we crash deref'ing
it.

Perhaps this was what it was trying to do? Not sure.

diff -purN -X /home/mbligh/.diff.exclude virgin/mm/memory.c remap_pte_range/mm/memory.c
--- virgin/mm/memory.c	2004-06-16 10:22:15.000000000 -0700
+++ remap_pte_range/mm/memory.c	2004-06-29 17:15:35.000000000 -0700
@@ -908,7 +908,7 @@ static inline void remap_pte_range(pte_t
 	pfn = phys_addr >> PAGE_SHIFT;
 	do {
 		BUG_ON(!pte_none(*pte));
-		if (!pfn_valid(pfn) || PageReserved(pfn_to_page(pfn)))
+		if (pfn_valid(pfn) && !PageReserved(pfn_to_page(pfn)))
  			set_pte(pte, pfn_pte(pfn, prot));
 		address += PAGE_SIZE;
 		pfn++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
