Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id AC8CE6B0032
	for <linux-mm@kvack.org>; Thu,  7 May 2015 18:09:34 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so51470619pac.0
        for <linux-mm@kvack.org>; Thu, 07 May 2015 15:09:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ct3si4418306pbc.99.2015.05.07.15.09.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 May 2015 15:09:33 -0700 (PDT)
Date: Thu, 7 May 2015 15:09:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: meminit: Finish initialisation of struct pages
 before basic setup
Message-Id: <20150507150932.79e038167f70dd467c25d6ee@linux-foundation.org>
In-Reply-To: <20150507072518.GL2462@suse.de>
References: <1430231830-7702-1-git-send-email-mgorman@suse.de>
	<554030D1.8080509@hp.com>
	<5543F802.9090504@hp.com>
	<554415B1.2050702@hp.com>
	<20150504143046.9404c572486caf71bdef0676@linux-foundation.org>
	<20150505104514.GC2462@suse.de>
	<20150505130255.49ff76bbf0a3b32d884ab2ce@linux-foundation.org>
	<20150507072518.GL2462@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Waiman Long <waiman.long@hp.com>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 7 May 2015 08:25:18 +0100 Mel Gorman <mgorman@suse.de> wrote:

> Waiman Long reported that 24TB machines hit OOM during basic setup when
> struct page initialisation was deferred. One approach is to initialise memory
> on demand but it interferes with page allocator paths. This patch creates
> dedicated threads to initialise memory before basic setup. It then blocks
> on a rw_semaphore until completion as a wait_queue and counter is overkill.
> This may be slower to boot but it's simplier overall and also gets rid of a
> section mangling which existed so kswapd could do the initialisation.

Seems a reasonable compromise.  It makes a bit of a mess of the patch
sequencing.

Have some tweaklets:



From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix

include rwsem.h, use DECLARE_RWSEM, fix comment, remove unneeded cast

Cc: Daniel J Blueman <daniel@numascale.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Nathan Zimmer <nzimmer@sgi.com>
Cc: Scott Norton <scott.norton@hp.com>
Cc: Waiman Long <waiman.long@hp.com
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 mm/page_alloc.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff -puN mm/page_alloc.c~mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix mm/page_alloc.c
--- a/mm/page_alloc.c~mm-meminit-finish-initialisation-of-struct-pages-before-basic-setup-fix
+++ a/mm/page_alloc.c
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 #include <linux/swap.h>
 #include <linux/interrupt.h>
+#include <linux/rwsem.h>
 #include <linux/pagemap.h>
 #include <linux/jiffies.h>
 #include <linux/bootmem.h>
@@ -1075,12 +1076,12 @@ static void __init deferred_free_range(s
 		__free_pages_boot_core(page, pfn, 0);
 }
 
-static struct rw_semaphore __initdata pgdat_init_rwsem;
+static __initdata DECLARE_RWSEM(pgdat_init_rwsem);
 
 /* Initialise remaining memory on a node */
 static int __init deferred_init_memmap(void *data)
 {
-	pg_data_t *pgdat = (pg_data_t *)data;
+	pg_data_t *pgdat = data;
 	int nid = pgdat->node_id;
 	struct mminit_pfnnid_cache nid_init_state = { };
 	unsigned long start = jiffies;
@@ -1096,7 +1097,7 @@ static int __init deferred_init_memmap(v
 		return 0;
 	}
 
-	/* Bound memory initialisation to a local node if possible */
+	/* Bind memory initialisation thread to a local node if possible */
 	if (!cpumask_empty(cpumask))
 		set_cpus_allowed_ptr(current, cpumask);
 
@@ -1200,7 +1201,6 @@ void __init page_alloc_init_late(void)
 {
 	int nid;
 
-	init_rwsem(&pgdat_init_rwsem);
 	for_each_node_state(nid, N_MEMORY) {
 		down_read(&pgdat_init_rwsem);
 		kthread_run(deferred_init_memmap, NODE_DATA(nid), "pgdatinit%d", nid);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
