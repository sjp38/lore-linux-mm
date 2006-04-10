Date: Mon, 10 Apr 2006 19:54:01 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Page Migration: Make do_swap_page redo the fault
In-Reply-To: <Pine.LNX.4.64.0604090357350.5312@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0604101933400.26478@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0604032228150.24182@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604081312200.14441@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081058290.16914@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604082022170.12196@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0604081430280.17911@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0604090357350.5312@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 9 Apr 2006, Hugh Dickins wrote:
> On Sat, 8 Apr 2006, Christoph Lameter wrote:
> > 
> > Those two checks were added for migration together with the one we 
> > are removing now. Sounds like you think they additionally fix some other 
> > race conditions?
> 
> But I do have to worry then.  I'd missed the addition of those checks:
> if they really are necessary, then the rules have changed in two
> tricky areas I now need to re-understand.  It'll take me a while.

I have now checked through, and I'm relieved to conclude that neither
of those other two PageSwapCache rechecks are necessary; and the rules
are much as before.

In the try_to_unuse case, it's quite possible that !PageSwapCache there,
because of a racing delete_from_swap_cache; but that case is correctly
handled in the code that follows.

In the shmem_getpage case, info->lock is held to ensure that a racing
shmem_getpage or shmem_unuse_inode can't change it to !PageSwapCache.

In neither case can page migration interfere, because we're holding a
reference on the page: acquired within find_get_page's tree_lock (or
in the initial page allocation before add_to_swap_cache).

migrate_page_remove_references is careful to check page_count against
nr_refs within the tree_lock, and back out if page_count is raised.
If it didn't do so, most uses of find_get_page would be unsafe.

So I believe we can safely remove these other two
"Page migration has occured" blocks - can't we?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
