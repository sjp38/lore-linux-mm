Date: Tue, 18 Mar 2008 07:42:43 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [git pull] slub fallback fix
In-Reply-To: <Pine.LNX.4.64.0803171135420.8746@schroedinger.engr.sgi.com>
Message-ID: <alpine.LFD.1.00.0803180737350.3020@woody.linux-foundation.org>
References: <Pine.LNX.4.64.0803171135420.8746@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>


On Mon, 17 Mar 2008, Christoph Lameter wrote:
>
> We need to reenable interrupts before calling the page allocator from the
> fallback path for kmalloc. Used to be okay with the alternate fastpath 
> which shifted interrupt enable/disable to the fastpath. But the slowpath
> is always called with interrupts disabled now. So we need this fix.

I think this fix is bogus and inefficient.

The proper fix would seem to be to just not disable the irq's 
unnecessarily!

We don't care what the return state of the interrupts are, since the 
caller will restore the _true_ interrupt state (which we don't even know 
about, so we can't do it). 

So why isn't the patch just doing something like the appended instead of 
disabling and enabling interrupts unnecessarily?

		Linus
---
 mm/slub.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 96d63eb..a082390 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1511,10 +1511,10 @@ new_slab:
 
 	new = new_slab(s, gfpflags, node);
 
-	if (gfpflags & __GFP_WAIT)
-		local_irq_disable();
-
 	if (new) {
+		if (gfpflags & __GFP_WAIT)
+			local_irq_disable();
+
 		c = get_cpu_slab(s, smp_processor_id());
 		stat(c, ALLOC_SLAB);
 		if (c->page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
