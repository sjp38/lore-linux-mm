From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199906151551.IAA74604@google.engr.sgi.com>
Subject: Re: filecache/swapcache questions
Date: Tue, 15 Jun 1999 08:51:35 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.05.9906150930310.13631-100000@humbolt.nl.linux.org> from "Rik van Riel" at Jun 15, 99 09:32:19 am
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: linux-mm@kvack.org, sct@redhat.com
List-ID: <linux-mm.kvack.org>

> 
> On Tue, 15 Jun 1999, Kanoj Sarcar wrote:

Hmm, I am either misunderstanding your explanation, or I couldn't
make the crux of my questions clear in the first posting.

> 
> > Q1. Is it really needed to put all the swap pages in the swapper_inode
> > i_pages?
> 
> Yes, see below.

I understand that it is beneficial for performance reasons to have
a list of swapped pages which are clean wrt their disk copies in 
the swapcache, which is implemented as a file cache on swapper_inode.
What I am trying to find out is if it is enough to put these pages
in the hash queue for swapper_inode, without really also putting
them in the inode queue for swapper_inode. Its not like we ever 
"truncate" swapper_inode, that we will need to go thru its i_pages
list ...

> 
> > How will it be possible for a page to be in the swapcache, for its
> > reference count to be 1 (which has been checked just before), and for
> > its swap_count(page->offset) to also be 1? I can see this being
> > possible only if an unmap/exit path might lazily leave a anonymous
> > page in the swap cache, but I don't believe that happens.
> 
> It does happen. We use a 'two-stage' reclamation process instead
> of page aging. It seems to work wonderfully -- nice page aging
> properties without the overhead. Plus, it automatically balances
> swap and cache memory since the same reclamation routine passes
> over both types of pages.
>

I still can't see how this can happen. Note that try_to_swap_out
either does a get_swap_page/swap_duplicate on the swaphandle, which
gets the swap_count up to 2, or if it sees a page already in the
swapcache, it just does a swap_duplicate. Either way, if the only 
reference on the physical page is from the swapcache, there will be 
at least one more reference on the swap page other than due to the 
swapcache. What am I missing?

Thanks.

Kanoj
kanoj@engr.sgi.com

PS: Q4: who uses rw_swap_page_nolock, and what is shmfs? Note that
rw_swap_page_nolock is the only caller that passes in non PageSwapCache
pages into rw_swap_page_base(), which otherwise could assume that
all pages passed into it are PageSwapCache, which would eliminate
the need for a seperate PG_swap_unlock_after bit.
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
