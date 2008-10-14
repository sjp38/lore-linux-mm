Message-ID: <48F506CE.60701@inria.fr>
Date: Tue, 14 Oct 2008 22:53:34 +0200
From: Brice Goglin <Brice.Goglin@inria.fr>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] mm: rework sys_move_pages() to avoid vmalloc and
 reduce the overhead
References: <48F3AD47.1050301@inria.fr>
In-Reply-To: <48F3AD47.1050301@inria.fr>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

By the way, this patchset replaces
mm-use-a-radix-tree-to-make-do_move_pages-complexity-linear-checkpatch-fixes
(currently in -mm).

Brice



Brice Goglin wrote:
> Hello,
>
> Here's the first patchset reworking sys_move_pages() as discussed earlier.
> It removes the possibly large vmalloc by using multiple chunks when migrating
> large buffers. It also dramatically increases the throughput for large buffers
> since the lookup in new_page_node() is now limited to a single chunk, causing
> the quadratic complexity to have a much slower impact. There is no need to use
> any radix-tree-like structure to improve this lookup.
>
> sys_move_pages() duration on a 4-quadcore-opteron 2347HE (1.9Gz), migrating
> between nodes #2 and #3:
> 	length		move_pages (us)		move_pages+patch (us)
> 	4kB		126			98
> 	40kB		198			168
> 	400kB		963			937
> 	4MB		12503			11930
> 	40MB		246867			11848
>
> Patches #1 and #4 are the important ones:
> 1) stop returning -ENOENT from sys_move_pages() if nothing got migrated
> 2) don't vmalloc a huge page_to_node array for do_pages_stat()
> 3) extract do_pages_move() out of sys_move_pages()
> 4) rework do_pages_move() to work on page_sized chunks
> 5) move_pages: no need to set pp->page to ZERO_PAGE(0) by default
>
> thanks,
> Brice
>
>
>
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
