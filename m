Message-ID: <3C830598.E2FB5E1A@zip.com.au>
Date: Sun, 03 Mar 2002 21:26:48 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] radix-tree pagecache for 2.4.19-pre2-ac2
References: <20020303210346.A8329@caldera.de>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@caldera.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Hellwig wrote:
> 
> I have uploaded an updated version of the radix-tree pagecache patch
> against 2.4.19-pre2-ac2.  News in this release:
> 
> * fix a deadlock when vmtruncate takes i_shared_lock twice by introducing
>   a new mapping->page_lock that mutexes mapping->page_tree. (akpm)
> * move setting of page->flags back out of move_to/from_swap_cache. (akpm)
> * put back lost page state settings in shmem_unuse_inode. (akpm)
> * get rid of remove_page_from_inode_queue - there was only one caller. (me)
> * replace add_page_to_inode_queue with ___add_to_page_cache. (me)
> 
> Please give it some serious beating while I try to get 2.5 working and
> port the patch over 8)

One of my reasons for absorbing ratcache into my current stuff is
just that - to give it a serious beating.  The fact that I found a
hitherto-undiscovered BUG() and a deadlock in the first 30 minutes
just shows what a mean beat I have :)

I haven't yet even looked at lib/rat.c, but based on testing, I
believe radix-tree pagecache is ready for 2.5.   It would be good
if the other Christoph could check over the shmem.c changes.

As far as I know, the sole remaining "issue" is that block_flushpage()
is being called under spinlock.  Well, there's nothing new here.
The kernel is *already* calling block_flushpage() under spinlock
it at least three places.  But it just so happens that there are
never (?) any locked buffers against the page from those call sites.

So I don't see the block_flushpage() thing as a blocker for this
patch - it's just general ickiness which needs sorting out separately.
I looked at block_flushpage() a month or so back.  I ended up 
concluding that we should just create block_flushpage_atomic() and
make it go BUG() if the page has locked buffers.  Then call the atomic
version from under spinlock, and leave it at that.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
