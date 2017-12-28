Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 50B7B6B0038
	for <linux-mm@kvack.org>; Thu, 28 Dec 2017 14:00:44 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 33so23852766pll.9
        for <linux-mm@kvack.org>; Thu, 28 Dec 2017 11:00:44 -0800 (PST)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id b77si26991497pfe.377.2017.12.28.11.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Dec 2017 11:00:42 -0800 (PST)
Message-ID: <1514487640.3040.21.camel@HansenPartnership.com>
Subject: Re: Hang with v4.15-rc trying to swap back in
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 28 Dec 2017 11:00:40 -0800
In-Reply-To: <1514482907.3040.15.camel@HansenPartnership.com>
References: <1514398340.3986.10.camel@HansenPartnership.com>
	 <1514407817.4169.4.camel@HansenPartnership.com>
	 <20171227232650.GA9702@bbox>
	 <1514417689.3083.1.camel@HansenPartnership.com>
	 <20171227235643.GA10532@bbox>
	 <1514482907.3040.15.camel@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Thorsten Leemhuis <regressions@leemhuis.info>

On Thu, 2017-12-28 at 09:41 -0800, James Bottomley wrote:
> I'd guess that since they're both in io_schedule, the problem is that
> the io_scheduler is taking far too long servicing the requests due to
> some priority issue you've introduced.

OK, so after some analysis, that turned out to be incorrect. A The
problem seems to be that we're exiting do_swap_page() with locked pages
that have been read in from swap.

Your changelogs are entirely unclear on why you changed the swapcache
setting logic in this patch:

commit 0bcac06f27d7528591c27ac2b093ccd71c5d0168
Author: Minchan Kim <minchan@kernel.org>
Date:A A A Wed Nov 15 17:33:07 2017 -0800

A A A A mm, swap: skip swapcache for swapin of synchronous device

But I think you're using swapcache == NULL as a signal the page came
from a synchronous device. A In which case the bug is that you've
forgotten we may already have picked up a page in
swap_readahead_detect() which you're wrongly keeping swapcache == NULL
for and the fix is this (it works on my system, although I'm still
getting an unaccountable shutdown delay).

I still think we should revert this series, because this may not be the
only bug lurking in the code, so it should go through a lot more
rigorous testing than it has.

James

---

diff --git a/mm/memory.c b/mm/memory.c
index ca5674cbaff2..31f9845c340e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2847,7 +2847,7 @@ EXPORT_SYMBOL(unmap_mapping_range);
 int do_swap_page(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
-	struct page *page = NULL, *swapcache = NULL;
+	struct page *page = NULL, *swapcache;
 	struct mem_cgroup *memcg;
 	struct vma_swap_readahead swap_ra;
 	swp_entry_t entry;
@@ -2892,6 +2892,7 @@ int do_swap_page(struct vm_fault *vmf)
 	if (!page)
 		page = lookup_swap_cache(entry, vma_readahead ? vma : NULL,
 					 vmf->address);
+	swapcache = page;
 	if (!page) {
 		struct swap_info_struct *si = swp_swap_info(entry);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
