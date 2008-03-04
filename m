Date: Tue, 4 Mar 2008 22:01:09 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [BUG] 2.6.25-rc3-mm1 kernel panic while bootup on powerpc ()
In-Reply-To: <Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0803042200410.8545@sbz-30.cs.Helsinki.FI>
References: <20080304011928.e8c82c0c.akpm@linux-foundation.org>
 <47CD4AB3.3080409@linux.vnet.ibm.com>  <20080304103636.3e7b8fdd.akpm@linux-foundation.org>
  <47CDA081.7070503@cs.helsinki.fi> <20080304193532.GC9051@csn.ul.ie>
 <84144f020803041141x5bb55832r495d7fde92356e27@mail.gmail.com>
 <Pine.LNX.4.64.0803041151360.18160@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linuxppc-dev@ozlabs.org, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 4 Mar 2008, Christoph Lameter wrote:
> Slab allocations should never be passed these flags since the slabs do 
> their own thing there.
> 
> The following patch would clear these in slub:

Here's the same fix for SLAB:
 
diff --git a/mm/slab.c b/mm/slab.c
index 473e6c2..c6dbf7e 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1677,6 +1677,7 @@ static void *kmem_getpages(struct kmem_cache *cachep, gfp_t flags, int nodeid)
 	flags |= __GFP_COMP;
 #endif
 
+	flags &= ~GFP_MOVABLE_MASK;
 	flags |= cachep->gfpflags;
 	if (cachep->flags & SLAB_RECLAIM_ACCOUNT)
 		flags |= __GFP_RECLAIMABLE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
