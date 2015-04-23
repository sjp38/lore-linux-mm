Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id A427D6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 11:56:13 -0400 (EDT)
Received: by wiun10 with SMTP id n10so97577260wiu.1
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 08:56:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ge8si32667964wib.104.2015.04.23.08.56.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 08:56:12 -0700 (PDT)
Date: Thu, 23 Apr 2015 16:56:07 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 07/13] mm: meminit: Initialise a subset of struct pages
 if CONFIG_DEFERRED_STRUCT_PAGE_INIT is set
Message-ID: <20150423155607.GA2449@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
 <1429785196-7668-8-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1429785196-7668-8-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Apr 23, 2015 at 11:33:10AM +0100, Mel Gorman wrote:
> This patch initalises all low memory struct pages and 2G of the highest zone
> on each node during memory initialisation if CONFIG_DEFERRED_STRUCT_PAGE_INIT
> is set. That config option cannot be set but will be available in a later
> patch.  Parallel initialisation of struct page depends on some features
> from memory hotplug and it is necessary to alter alter section annotations.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

I belatedly noticed that this causes section warnings. It'll be harmless
for testing but the next (hopefully last) version will have this on top

diff --git a/drivers/base/node.c b/drivers/base/node.c
index d03e976b4431..97ab2c4dd39e 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -361,14 +361,14 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 #ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
 #define page_initialized(page)  (page->lru.next)
 
-static int get_nid_for_pfn(struct pglist_data *pgdat, unsigned long pfn)
+static int __init_refok get_nid_for_pfn(unsigned long pfn)
 {
 	struct page *page;
 
 	if (!pfn_valid_within(pfn))
 		return -1;
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
-	if (pgdat && pfn >= pgdat->first_deferred_pfn)
+	if (system_state == SYSTEM_BOOTING)
 		return early_pfn_to_nid(pfn);
 #endif
 	page = pfn_to_page(pfn);
@@ -382,7 +382,6 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 {
 	int ret;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
-	struct pglist_data *pgdat = NODE_DATA(nid);
 
 	if (!mem_blk)
 		return -EFAULT;
@@ -395,7 +394,7 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, int nid)
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int page_nid;
 
-		page_nid = get_nid_for_pfn(pgdat, pfn);
+		page_nid = get_nid_for_pfn(pfn);
 		if (page_nid < 0)
 			continue;
 		if (page_nid != nid)
@@ -434,7 +433,7 @@ int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
 		int nid;
 
-		nid = get_nid_for_pfn(NULL, pfn);
+		nid = get_nid_for_pfn(pfn);
 		if (nid < 0)
 			continue;
 		if (!node_online(nid))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
