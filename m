Message-ID: <007501bfd233$288827c0$0a1e17ac@local>
From: "Manfred Spraul" <manfred@colorfullife.com>
References: <Pine.LNX.4.21.0006091207360.31358-100000@duckman.distro.conectiva>
Subject: Re: journaling & VM  (was: Re: reiserfs being part of the kernel: it'snot just the code)
Date: Fri, 9 Jun 2000 18:52:46 +0200
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>
> This is exactly what one global LRU will achieve, at less
> cost and with better readable code.
>
You are right, but what will you do with pinned pages once they reach the
end of the LRU? Will you drop them from the LRU, or will you add them to the
beginning?
AFAICS a few global LRU lists [your inactive, active, scavenge (sp?) lists]
should work, but I don't understand yet how you want to prevent that one
grep over the kernel tree will push everyone else into swap.

Is the active list also a LRU list? AFAICS we don't have the reverse
mapping "struct page ->all pte's", so we cannot push a page once it reaches
the end of the LRU. AFAIK BSD has that reverse mapping (Please correct me if
I'm wrong). IMHO an LRU won't help us.

--
    Manfred

P.S.: You could ignore the rest of the mail, just a few random thoughts.


Level 1 (your active list): the page users such as
* mmapped pages, annon pages, mapped shm pages: they are unmapped by
mm/vmscan.c. vma->swapout() should add them to the level 2 list.

* a tiny hotlist for the page & buffer cache, otherwise we have
"spin_lock();list_del(page);list_add(page,list_head);spin_unlock()" during
every operation. Clock algorithm with a referenced bit.

Level 2: (your inactive list)
* unmapped pages LRU list 1 [pages can be dirty or clean]. At the end of
this list, page->a_ops->?? is called, and the page is dropped from the list.
The memory owner adds it to the level 3 list once it's clean.

Level 3: (your scavenge list)
* LRU list of clean pages, ready for immediate reclamation. gfp(GFP_WAIT)
takes the oldest entry from this list.

Level 4:
free pages in the buddy. for GFP_ATOMIC allocations, and for multi page
allocations.

Pages in Level 2 and 3 are never "in use", i.e. never reachable from user
space, or read/written by generic_file_{read,write}. The page owner can
still reclaim them if a soft pagefault occurs. File pages are still in the
page cache hash table, shm & anon pages are reachable through the swap
cache.

Level 2 could be split in 2 halfs, clean pages are added in the middle.
[reduces IO]

The selection between the Level 1 page holders could be made on their
"reanimate rate": if one owner often request pages from Level 2 or 3 back,
then we reap him too often.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
