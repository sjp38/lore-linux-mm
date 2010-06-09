Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B78DC6B01DD
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 02:49:19 -0400 (EDT)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id o596nFcK023670
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:15 -0700
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by kpbe15.cbf.corp.google.com with ESMTP id o596nDMp008509
	for <linux-mm@kvack.org>; Tue, 8 Jun 2010 23:49:14 -0700
Received: by pzk33 with SMTP id 33so5683219pzk.17
        for <linux-mm@kvack.org>; Tue, 08 Jun 2010 23:49:13 -0700 (PDT)
Date: Tue, 8 Jun 2010 23:49:10 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/4] slub: use is_kmalloc_cache in dma_kmalloc_cache
In-Reply-To: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1006082348310.30606@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006082347440.30606@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

dma_kmalloc_cache() can use the new is_kmalloc_cache() helper function.

Also removes an unnecessary assignment to local variable `s'.

Cc: Christoph Lameter <cl@linux.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/slub.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2649,13 +2649,12 @@ static noinline struct kmem_cache *dma_kmalloc_cache(int index, gfp_t flags)
 	text = kasprintf(flags & ~SLUB_DMA, "kmalloc_dma-%d",
 			 (unsigned int)realsize);
 
-	s = NULL;
 	for (i = 0; i < KMALLOC_CACHES; i++)
 		if (!kmalloc_caches[i].size)
 			break;
 
-	BUG_ON(i >= KMALLOC_CACHES);
 	s = kmalloc_caches + i;
+	BUG_ON(!is_kmalloc_cache(s));
 
 	/*
 	 * Must defer sysfs creation to a workqueue because we don't know

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
