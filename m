From: Johannes Weiner <hannes@saeurebad.de>
Subject: bootmem: Double freeing a PFN on nodes spanning other nodes
Date: Sat, 17 May 2008 00:30:55 +0200
Message-ID: <87skwhyj8g.fsf@saeurebad.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

When memory nodes overlap each other, the bootmem allocator is not aware
of this and might pass the same page twice to __free_pages_bootmem().

As I traced the code, this should result in bad_page() calls on every
boot but noone has yet reported something like this and I am wondering
why.

__free_pages_bootmem() boils down to either free_hot_cold_page() or
__free_one_page().  Either path should lead to setting the page private
or buddy:

free_hot_cold_page() sets ->private to the page block's migratetype (and
sets PG_private).

__free_one_page sets ->private to the page's order (and sets PG_private
and PG_buddy).

If a page is passed in twice, free_pages_check() should now warn (via
bad_page()) on the flags set above.

Am I missing something?  Thanks in advance.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
