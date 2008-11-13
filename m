Message-ID: <491C8A6F.3000404@goop.org>
Date: Thu, 13 Nov 2008 12:13:35 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: [PATCH 3/2] mm/remap_pfn_range: restore missing flush
References: <491C61B1.10005@goop.org> <20081113195341.GA8299@cmpxchg.org>
In-Reply-To: <20081113195341.GA8299@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "Pallipadi, Venkatesh" <venkatesh.pallipadi@intel.com>
List-ID: <linux-mm.kvack.org>

Restore the cache flush and BUG_ON removed in the conversion to using
apply_to_page_range().

Signed-off-by: Jeremy Fitzhardinge <jeremy.fitzhardinge@citix.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memory.c |    4 ++++
 1 file changed, 4 insertions(+)

===================================================================
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1484,6 +1484,8 @@
 	struct remap_data *rmd = data;
 	pte_t pte = pte_mkspecial(pfn_pte(rmd->pfn++, rmd->prot));
 
+	BUG_ON(!pte_none(*ptep));
+
 	set_pte_at(rmd->mm, addr, ptep, pte);
 
 	return 0;
@@ -1535,6 +1537,8 @@
 
 	BUG_ON(addr >= end);
 
+	flush_cache_range(vma, addr, end);
+
 	rmd.mm = mm;
 	rmd.pfn = pfn;
 	rmd.prot = prot;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
