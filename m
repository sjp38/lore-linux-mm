Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id E15296B0038
	for <linux-mm@kvack.org>; Fri,  1 May 2015 05:20:39 -0400 (EDT)
Received: by wgin8 with SMTP id n8so86143673wgi.0
        for <linux-mm@kvack.org>; Fri, 01 May 2015 02:20:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i15si7022946wiv.82.2015.05.01.02.20.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 01 May 2015 02:20:37 -0700 (PDT)
Date: Fri, 1 May 2015 10:20:31 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] mm: page_alloc: pass PFN to __free_pages_bootmem -fix
Message-ID: <20150501092031.GB2449@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
 <1430231830-7702-5-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1430231830-7702-5-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Stephen Rothwell reported the following

	Today's linux-next build (sparc defconfig) failed like this:

	mm/bootmem.c: In function 'free_all_bootmem_core':
	mm/bootmem.c:237:32: error: 'cur' undeclared (first use in this function)
	   __free_pages_bootmem(page++, cur++, 0);
                                ^
	Caused by commit "mm: page_alloc: pass PFN to __free_pages_bootmem".

He also merged a fix. The only difference in this version is one line is
moved so the final diff context is clearer. This is a fix to the mmotm
patch mm-page_alloc-pass-pfn-to-__free_pages_bootmem.patch

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/bootmem.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/bootmem.c b/mm/bootmem.c
index daf956bb4782..a23dd1934654 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -172,7 +172,7 @@ void __init free_bootmem_late(unsigned long physaddr, unsigned long size)
 static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 {
 	struct page *page;
-	unsigned long *map, start, end, pages, count = 0;
+	unsigned long *map, start, end, pages, cur, count = 0;
 
 	if (!bdata->node_bootmem_map)
 		return 0;
@@ -214,7 +214,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 			count += BITS_PER_LONG;
 			start += BITS_PER_LONG;
 		} else {
-			unsigned long cur = start;
+			cur = start;
 
 			start = ALIGN(start + 1, BITS_PER_LONG);
 			while (vec && cur != start) {
@@ -229,6 +229,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
 		}
 	}
 
+	cur = bdata->node_min_pfn;
 	page = virt_to_page(bdata->node_bootmem_map);
 	pages = bdata->node_low_pfn - bdata->node_min_pfn;
 	pages = bootmem_bootmap_pages(pages);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
