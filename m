From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <16416.62172.489558.39126@laputa.namesys.com>
Date: Wed, 4 Feb 2004 16:25:48 +0300
Subject: Re: [PATCH 0/5] mm improvements
In-Reply-To: <4020BDCB.8030707@cyberone.com.au>
References: <4020BDCB.8030707@cyberone.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin writes:
 > Patches against 2.6.2-rc3-mm1.
 > Please test / review / comment.

Hello, Nick,

I composed a new patch that may be worth trying:

ftp://ftp.namesys.com/pub/misc-patches/unsupported/extra/2004.02.04/p12-dont-unmap-on-pageout.patch

It avoids (if possible) unmapping dirty page before calling
->writepage(). Intention is to avoid minor page faults for the pages
under write-back.

To this end new function mm/rmap.c:page_is_dirty() is added that scans
page's ptes and transfers their dirtiness to the struct page
itself. page_is_dirty() is called by shrink_list() and page is unmapped
only if page_is_dirty() found all ptes clean.

Few points:

1. I only gave it light testing (compared with other patches in the
"extra" series).

2. dont-unmap-on-pageout logically depends on check-pte-dirty, and
textually on skip-writepage patches.

3. for some unimportant reasons patches were produces with "diff -b",
and may, hence, require "patch -l" to apply.

4. I found that shmem_writepage() has BUG_ON(page_mapped(page))
check. Its removal had no effect, and I am not sure why the check was
there at all.

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
