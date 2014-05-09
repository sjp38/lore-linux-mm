Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0AE5E6B0035
	for <linux-mm@kvack.org>; Fri,  9 May 2014 18:03:33 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id rd3so4934982pab.29
        for <linux-mm@kvack.org>; Fri, 09 May 2014 15:03:33 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id hb3si3085309pac.214.2014.05.09.15.03.32
        for <linux-mm@kvack.org>;
        Fri, 09 May 2014 15:03:33 -0700 (PDT)
Date: Fri, 9 May 2014 15:03:31 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v4 4/6] mm, compaction: embed migration mode in
 compact_control
Message-Id: <20140509150331.55f9b8b17c720baafa408e8f@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.02.1405070336200.16568@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405011434140.23898@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405061920470.18635@chino.kir.corp.google.com>
	<alpine.DEB.2.02.1405061921420.18635@chino.kir.corp.google.com>
	<536A030D.4070407@suse.cz>
	<alpine.DEB.2.02.1405070336200.16568@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 7 May 2014 03:36:46 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> We're going to want to manipulate the migration mode for compaction in the page 
> allocator, and currently compact_control's sync field is only a bool.  
> 
> Currently, we only do MIGRATE_ASYNC or MIGRATE_SYNC_LIGHT compaction depending 
> on the value of this bool.  Convert the bool to enum migrate_mode and pass the 
> migration mode in directly.  Later, we'll want to avoid MIGRATE_SYNC_LIGHT for 
> thp allocations in the pagefault patch to avoid unnecessary latency.
> 
> This also alters compaction triggered from sysfs, either for the entire system 
> or for a node, to force MIGRATE_SYNC.

mm/page_alloc.c: In function 'alloc_contig_range':
mm/page_alloc.c:6255: error: unknown field 'sync' specified in initializer

--- a/mm/page_alloc.c~mm-compaction-embed-migration-mode-in-compact_control-fix
+++ a/mm/page_alloc.c
@@ -6252,7 +6252,7 @@ int alloc_contig_range(unsigned long sta
 		.nr_migratepages = 0,
 		.order = -1,
 		.zone = page_zone(pfn_to_page(start)),
-		.sync = MIGRATE_SYNC_LIGHT,
+		.mode = MIGRATE_SYNC_LIGHT,
 		.ignore_skip_hint = true,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);


Please check that you sent the correct version of this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
