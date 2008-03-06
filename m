Date: Thu, 6 Mar 2008 11:55:07 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [BUG] in 2.6.25-rc3 with 64k page size and SLUB_DEBUG_ON
In-Reply-To: <200803061447.05797.Jens.Osterkamp@gmx.de>
Message-ID: <Pine.LNX.4.64.0803061151590.14140@schroedinger.engr.sgi.com>
References: <200803061447.05797.Jens.Osterkamp@gmx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jens Osterkamp <Jens.Osterkamp@gmx.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 6 Mar 2008, Jens Osterkamp wrote:

> BUG: scheduling while atomic: kthreadd/2/0x00056ef8

Hmmmm... Fallback?

> Call Trace:
> [c00000003c187b68] [c00000000000f140] .show_stack+0x70/0x1bc (unreliable)
> [c00000003c187c18] [c000000000052d0c] .__schedule_bug+0x64/0x80
> [c00000003c187ca8] [c00000000036fa84] .schedule+0xc4/0x6b0
> [c00000003c187d98] [c0000000003702d0] .schedule_timeout+0x3c/0xe8
> [c00000003c187e68] [c00000000036f82c] .wait_for_common+0x150/0x22c
> [c00000003c187f28] [c000000000074868] .kthreadd+0x12c/0x1f0
> [c00000003c187fd8] [c000000000024864] .kernel_thread+0x4c/0x68

But nothing slub wise here...

> With slub_debug=- on the kernel command line, the problem is gone.
> With 4k page size the problem also does not occur.

> Any ideas on why this occurs and how to debug this further ?

Could be the result of fallback under debug?? Looks like there is a hole 
in the fallback logic. But this could be something completely different.

If this is slub related then we may not be reenabling interrupt somewhere 
if debug is on.

diff --git a/mm/slub.c b/mm/slub.c
index 96d63eb..6d0a103 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1536,8 +1536,14 @@ new_slab:
 	 * That is only possible if certain conditions are met that are being
 	 * checked when a slab is created.
 	 */
-	if (!(gfpflags & __GFP_NORETRY) && (s->flags & __PAGE_ALLOC_FALLBACK))
-		return kmalloc_large(s->objsize, gfpflags);
+	if (!(gfpflags & __GFP_NORETRY) && (s->flags & __PAGE_ALLOC_FALLBACK)) {
+		if (gfpflags & __GFP_WAIT)
+			local_irq_enable();
+		object =  kmalloc_large(s->objsize, gfpflags);
+		if (gfpflags & __GFP_WAIT)
+			local_irq_disable();
+		return object;
+	}
 
 	return NULL;
 debug:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
