Date: Sun, 29 Oct 2006 00:05:13 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Slab panic on 2.6.19-rc3-git5 (-git4 was OK)
Message-Id: <20061029000513.de5af713.akpm@osdl.org>
In-Reply-To: <454442DC.9050703@google.com>
References: <454442DC.9050703@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@google.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Sat, 28 Oct 2006 22:57:48 -0700
"Martin J. Bligh" <mbligh@google.com> wrote:

> -git4 was fine. -git5 is broken (on PPC64 blade)
> 
> As -rc2-mm2 seemed fine on this box, I'm guessing it's something
> that didn't go via Andrew ;-( Looks like it might be something
> JFS or slab specific. Bigger PPC64 box with different config
> was OK though.
> 
> Full log is here: http://test.kernel.org/abat/59046/debug/console.log
> Good -git4 run: http://test.kernel.org/abat/58997/debug/console.log
> 
> kernel BUG in cache_grow at mm/slab.c:2705!

This?

--- a/mm/vmalloc.c~__vmalloc_area_node-fix
+++ a/mm/vmalloc.c
@@ -428,7 +428,8 @@ void *__vmalloc_area_node(struct vm_stru
 	area->nr_pages = nr_pages;
 	/* Please note that the recursion is strictly bounded. */
 	if (array_size > PAGE_SIZE) {
-		pages = __vmalloc_node(array_size, gfp_mask, PAGE_KERNEL, node);
+		pages = __vmalloc_node(array_size, gfp_mask & ~__GFP_HIGHMEM,
+					PAGE_KERNEL, node);
 		area->flags |= VM_VPAGES;
 	} else {
 		pages = kmalloc_node(array_size,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
