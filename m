Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id B7C8E6B0002
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 01:40:52 -0500 (EST)
Date: Thu, 14 Feb 2013 01:40:48 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: Try harder to allocate vmemmap blocks
Message-ID: <20130214064048.GB8372@cmpxchg.org>
References: <1360816468.5374.285.camel@deadeye.wl.decadent.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1360816468.5374.285.camel@deadeye.wl.decadent.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ben Hutchings <ben@decadent.org.uk>
Cc: linux-mm@kvack.org

On Thu, Feb 14, 2013 at 04:34:28AM +0000, Ben Hutchings wrote:
> Hot-adding memory on x86_64 normally requires huge page allocation.
> When this is done to a VM guest, it's usually because the system is
> already tight on memory, so the request tends to fail.  Try to avoid
> this by adding __GFP_REPEAT to the allocation flags.
> 
> Reported-and-tested-by: Bernhard Schmidt <Bernhard.Schmidt@lrz.de>
> Reference: http://bugs.debian.org/699913
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

> We could go even further and use __GFP_NOFAIL, but I'm not sure
> whether that would be a good idea.

If __GFP_REPEAT is not enough, I'd rather fall back to regular page
backing at this point:

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 2ead3c8..1f5301d 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -919,6 +919,7 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 {
 	unsigned long addr = (unsigned long)start_page;
 	unsigned long end = (unsigned long)(start_page + size);
+	int use_huge = cpu_has_pse;
 	unsigned long next;
 	pgd_t *pgd;
 	pud_t *pud;
@@ -934,8 +935,8 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 		pud = vmemmap_pud_populate(pgd, addr, node);
 		if (!pud)
 			return -ENOMEM;
-
-		if (!cpu_has_pse) {
+retry_pmd:
+		if (!use_huge) {
 			next = (addr + PAGE_SIZE) & PAGE_MASK;
 			pmd = vmemmap_pmd_populate(pud, addr, node);
 
@@ -957,8 +958,10 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 				pte_t entry;
 
 				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
-				if (!p)
-					return -ENOMEM;
+				if (!p) {
+					use_huge = 0;
+					goto retry_pmd;
+				}
 
 				entry = pfn_pte(__pa(p) >> PAGE_SHIFT,
 						PAGE_KERNEL_LARGE);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
