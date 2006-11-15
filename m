Subject: Re: [PATCH] mm: call into direct reclaim without PF_MEMALLOC set
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20061115132340.3cbf4008.akpm@osdl.org>
References: <1163618703.5968.50.camel@twins>
	 <20061115124228.db0b42a6.akpm@osdl.org> <1163625058.5968.64.camel@twins>
	 <20061115132340.3cbf4008.akpm@osdl.org>
Content-Type: text/plain
Date: Wed, 15 Nov 2006 22:32:58 +0100
Message-Id: <1163626378.5968.74.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2006-11-15 at 13:23 -0800, Andrew Morton wrote:

> spose so.  It assume that current->reclaim_state is NULL if !PF_MEMALLOC
> which I guess is true.
> 
> But do we need to set current->reclaim_state at all in here?

I did a quick grep before sending this out, and thought code assumed
current->reclaim_state was !NULL, however on closer inspection this
seems not so.

*sigh* another version - almost hitting the DaveJ barrier:
  revisions > LOC

---

PF_MEMALLOC is also used to prevent recursion of direct reclaim.
However this invocation does not set PF_MEMALLOC nor checks it and
hence a can make it nest a single time. Either by reaching this
spot from reclaim and then calling it again or entering here and 
encountering a __GFP_WAIT alloc from within.

So check for PF_MEMALLOC and avoid a second invocation and otherwise
set PF_MEMALLOC.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 fs/buffer.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

Index: linux-2.6-git/fs/buffer.c
===================================================================
--- linux-2.6-git.orig/fs/buffer.c	2006-11-15 20:32:14.000000000 +0100
+++ linux-2.6-git/fs/buffer.c	2006-11-15 22:28:43.000000000 +0100
@@ -360,8 +360,11 @@ static void free_more_memory(void)
 
 	for_each_online_pgdat(pgdat) {
 		zones = pgdat->node_zonelists[gfp_zone(GFP_NOFS)].zones;
-		if (*zones)
+		if (*zones && !(current->flags & PF_MEMALLOC)) {
+			current->flags |= PF_MEMALLOC;
 			try_to_free_pages(zones, GFP_NOFS);
+			current->flags &= ~PF_MEMALLOC;
+		}
 	}
 }
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
