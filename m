Message-ID: <3CE02EEB.89018FE1@zip.com.au>
Date: Mon, 13 May 2002 14:23:55 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] dcache and rmap
References: <200205052117.16268.tomlins@cam.org> <20020507125712.GM15756@holomorphy.com> <15583.40551.778094.604938@laputa.namesys.com> <200205130750.03668.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: Nikita Danilov <Nikita@Namesys.COM>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> Hi,
> 
> I did something similiar in the patch I posted under the subject:
> 
> [RFC][PATCH] cache shrinking via page age
> 
> Only I used the same method we now use to shrink caches but triggered them
> using page aging, and at the same time making the trigger cache specific.
> 
> Another though I had was to put the 'freeable' slab pages onto the inactive
> clean list and reclaim them when they reach the head of the list.  It gets a
> little tricky since slabs can contain multiple pages...   Before trying this
> I want to see how well what I have posted works.
> 

Using the VM would be better...

It means that you'll need to create an address_space (and
possibly, at this stage, an inode) to back the slab pages.

Probably there is no need to create a radix tree, nor to give
those pages an ->index.  Just bump page->count to indicate that
the page is "sort-of" in the pagecache.  The kernel presently
assumes, in __remove_inode_page() and __add_to_page_cache()
that these pages are in a radix-tree.  I don't think it needs
to.  Just set slab_space.page_tree to NULL and handle that in
the various places which go oops ;)

Probably there is no need to create a mapping per slab.
A global one should suffice.

There's no need to ever set those pages dirty, hence there's
no need for a ->writepage.

When pages are added to the slab you should put some slab
backpointer into page->private, set PG_private and
increment page->count.

Most of the work will be in slab_space->a_ops.releasepage().
In there you'll need to find the slab via page->private
and just start tossing away pages until you see the target
page come "free".  Then clear PG_private and drop page->count
and return success from ->releasepage().  The page is still
"in the pagecache" so it has an incremented ->count.  The
modified __remove_inode_page() will perform the final release.

That's all fairly straightforward.  The tricky bit is getting
the aging right.  These pages don't have referenced bits in the
pte's.  Possibly, running mark_page_accessed() inside kmem_cache_alloc
would be sufficient.  It would be more accurate to make every user of
a slab object "touch" that object's backing page but that's not
feasible.

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
