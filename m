Date: Thu, 3 Jul 2008 09:44:27 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] Do not clobber pgdat->nr_zones during memory
 initialisation
In-Reply-To: <20080703163638.GC18055@csn.ul.ie>
Message-ID: <alpine.LFD.1.10.0807030942440.18105@woody.linux-foundation.org>
References: <20080701175855.GI32727@shadowen.org> <20080701190741.GB16501@csn.ul.ie> <1214944175.26855.18.camel@dwillia2-linux.ch.intel.com> <20080702051759.GA26338@csn.ul.ie> <1215049766.2840.43.camel@dwillia2-linux.ch.intel.com> <20080703042750.GB14614@csn.ul.ie>
 <alpine.LFD.1.10.0807022135360.18105@woody.linux-foundation.org> <20080703050036.GD14614@csn.ul.ie> <1215064455.15797.4.camel@dwillia2-linux.ch.intel.com> <486CD623.8030906@linux-foundation.org> <20080703163638.GC18055@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, NeilBrown <neilb@suse.de>, babydr@baby-dragons.com, lee.schermerhorn@hp.com, a.beregalov@gmail.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>


On Thu, 3 Jul 2008, Mel Gorman wrote:
> 
> Subject: [PATCH] Do not clobber pgdat->nr_zones during memory initialisation

Heh. I already applied it as ObviouslyCorrect(tm), but did the 
simplification I already pointed out (and which your second version 
already had) and rewrote your commit message a bit. So it's now committed 
as follows..

		Linus

---
commit 494de90098784b8e2797598cefdd34188884ec2e
Author: Mel Gorman <mel@csn.ul.ie>
Date:   Thu Jul 3 05:27:51 2008 +0100

    Do not overwrite nr_zones on !NUMA when initialising zlcache_ptr
    
    The non-NUMA case of build_zonelist_cache() would initialize the
    zlcache_ptr for both node_zonelists[] to NULL.
    
    Which is problematic, since non-NUMA only has a single node_zonelists[]
    entry, and trying to zero the non-existent second one just overwrote the
    nr_zones field instead.
    
    As kswapd uses this value to determine what reclaim work is necessary,
    the result is that kswapd never reclaims.  This causes processes to
    stall frequently in low-memory situations as they always direct reclaim.
    This patch initialises zlcache_ptr correctly.
    
    Signed-off-by: Mel Gorman <mel@csn.ul.ie>
    Tested-by: Dan Williams <dan.j.williams@intel.com>
    [ Simplified patch a bit ]
    Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
---
 mm/page_alloc.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2f55295..f32fae3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2328,7 +2328,6 @@ static void build_zonelists(pg_data_t *pgdat)
 static void build_zonelist_cache(pg_data_t *pgdat)
 {
 	pgdat->node_zonelists[0].zlcache_ptr = NULL;
-	pgdat->node_zonelists[1].zlcache_ptr = NULL;
 }
 
 #endif	/* CONFIG_NUMA */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
