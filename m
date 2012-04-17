Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id C047A6B004A
	for <linux-mm@kvack.org>; Tue, 17 Apr 2012 11:55:04 -0400 (EDT)
Date: Tue, 17 Apr 2012 17:55:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Weirdness in __alloc_bootmem_node_high
Message-ID: <20120417155502.GE22687@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghai@kernel.org
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I just come across the following condition in __alloc_bootmem_node_high
which I have hard times to understand. I guess it is a bug and we need
something like the following. But, to be honest, I have no idea why we
care about those 128MB above MAX_DMA32_PFN.
---
 mm/bootmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index 0131170..5adb072 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -737,7 +737,7 @@ void * __init __alloc_bootmem_node_high(pg_data_t *pgdat, unsigned long size,
 	/* update goal according ...MAX_DMA32_PFN */
 	end_pfn = pgdat->node_start_pfn + pgdat->node_spanned_pages;
 
-	if (end_pfn > MAX_DMA32_PFN + (128 >> (20 - PAGE_SHIFT)) &&
+	if (end_pfn > MAX_DMA32_PFN + (128 << (20 - PAGE_SHIFT)) &&
 	    (goal >> PAGE_SHIFT) < MAX_DMA32_PFN) {
 		void *ptr;
 		unsigned long new_goal;
-- 
1.7.9.5

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
