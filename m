Date: Tue, 26 Jun 2007 12:41:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 15/26] Slab defrag: Support generic defragmentation for
 inode slab caches
In-Reply-To: <20070626123709.211c67c4.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706261241130.20744@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com> <20070618095917.005535114@sgi.com>
 <20070626011836.f4abb4ff.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706261223110.20457@schroedinger.engr.sgi.com>
 <20070626123709.211c67c4.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Tue, 26 Jun 2007, Andrew Morton wrote:

> This is inverted: __GFP_FS is set if we may perform fs operations.

Sigh. 



Slab defragmentation: Only perform slab defrag if __GFP_FS is clear

Avoids slab defragmentation be triggered from filesystem operations.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/vmscan.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-2.6.22-rc4-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/vmscan.c	2007-06-26 12:25:28.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/vmscan.c	2007-06-26 12:40:44.000000000 -0700
@@ -233,8 +233,9 @@ unsigned long shrink_slab(unsigned long 
 		shrinker->nr += total_scan;
 	}
 	up_read(&shrinker_rwsem);
-	kmem_cache_defrag(sysctl_slab_defrag_ratio,
-		zone ? zone_to_nid(zone) : -1);
+	if (gfp_mask & __GFP_FS)
+		kmem_cache_defrag(sysctl_slab_defrag_ratio,
+			zone ? zone_to_nid(zone) : -1);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
