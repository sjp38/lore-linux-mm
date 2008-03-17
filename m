Date: Mon, 17 Mar 2008 11:43:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: [git pull] slub fallback fix
Message-ID: <Pine.LNX.4.64.0803171135420.8746@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

We need to reenable interrupts before calling the page allocator from the
fallback path for kmalloc. Used to be okay with the alternate fastpath 
which shifted interrupt enable/disable to the fastpath. But the slowpath
is always called with interrupts disabled now. So we need this fix.


  git://git.kernel.org/pub/scm/linux/kernel/git/christoph/vm.git slab-linus

Christoph Lameter (1):
      slub page alloc fallback: Enable interrupts for GFP_WAIT.

 mm/slub.c |   12 +++++++++---
 1 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 96d63eb..ca71d5b 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1536,9 +1536,15 @@ new_slab:
         * That is only possible if certain conditions are met that are 
being
         * checked when a slab is created.
         */
-       if (!(gfpflags & __GFP_NORETRY) && (s->flags & 
__PAGE_ALLOC_FALLBACK))
-               return kmalloc_large(s->objsize, gfpflags);
-
+       if (!(gfpflags & __GFP_NORETRY) &&
+                               (s->flags & __PAGE_ALLOC_FALLBACK)) {
+               if (gfpflags & __GFP_WAIT)
+                       local_irq_enable();
+               object = kmalloc_large(s->objsize, gfpflags);
+               if (gfpflags & __GFP_WAIT)
+                       local_irq_disable();
+               return object;
+       }
        return NULL;
 debug:
        if (!alloc_debug_processing(s, c->page, object, addr))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
