Date: Thu, 4 May 2006 10:37:08 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: assert/crash in __rmqueue() when enabling CONFIG_NUMA
Message-ID: <20060504083708.GA30853@elte.hu>
References: <20060419112130.GA22648@elte.hu> <p73aca07whs.fsf@bragg.suse.de> <20060502070618.GA10749@elte.hu> <200605020905.29400.ak@suse.de> <44576688.6050607@mbligh.org> <44576BF5.8070903@yahoo.com.au> <20060504013239.GG19859@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060504013239.GG19859@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bob Picco <bob.picco@hp.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

* Bob Picco <bob.picco@hp.com> wrote:

> The patch below isn't compile tested or correct for those cases where 
> alloc_remap is called or where arch code has allocated node_mem_map 
> for CONFIG_FLAT_NODE_MEM_MAP. It's just conveying what I believe the 
> issue is.

thx. One pair of parentheses were missing i think - see the delta fix 
below. I'll try it.

	Ingo

Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -2296,7 +2296,7 @@ static void __init alloc_node_mem_map(st
 		 */
 		start = pgdat->node_start_pfn & ~((1 << (MAX_ORDER - 1)) - 1);
 		end = start + pgdat->node_spanned_pages;
-		end = (end + ((1 << (MAX_ORDER - 1)) - 1) &
+		end = (end + ((1 << (MAX_ORDER - 1)) - 1)) &
 			~((1 << (MAX_ORDER - 1)) - 1);
 		size =  (end - start) * sizeof(struct page);
 		map = alloc_remap(pgdat->node_id, size);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
