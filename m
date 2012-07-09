Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 28D8C6B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 17:10:37 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so12972727ghr.14
        for <linux-mm@kvack.org>; Mon, 09 Jul 2012 14:10:35 -0700 (PDT)
Date: Mon, 9 Jul 2012 14:10:32 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: don't invoke __alloc_pages_direct_compact when order
 0
In-Reply-To: <CAAmzW4P=Qf1u6spPZCN7o3TRqvwF-rZkZA3eFtAcnCdFg2CDBg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1207091408550.23926@chino.kir.corp.google.com>
References: <1341588521-17744-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1207070139510.10445@chino.kir.corp.google.com> <CAAmzW4PXdpQ2zSnkx8sSScAt1OY0j4+HXVmf=COvP7eMLqrEvQ@mail.gmail.com> <alpine.DEB.2.00.1207081547140.18461@chino.kir.corp.google.com>
 <CAAmzW4P=Qf1u6spPZCN7o3TRqvwF-rZkZA3eFtAcnCdFg2CDBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jul 2012, JoonSoo Kim wrote:

> I think __alloc_pages_direct_compact() can't be inlined by gcc,
> because it is so big and is invoked two times in __alloc_pages_nodemask().
> 

We could fix that by doing

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2057,7 +2057,7 @@ out:
 
 #ifdef CONFIG_COMPACTION
 /* Try memory compaction for high-order allocations before reclaim */
-static struct page *
+static __always_inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	struct zonelist *zonelist, enum zone_type high_zoneidx,
 	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,

but I'm not convinced that it's helpful for performance in the slowpath 
and there's no guarantee that it's called more often for order-0 
allocations since it is called as a fallback when should_alloc_retry() 
fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
