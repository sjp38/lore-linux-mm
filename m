From: Neil Brown <neilb@suse.de>
Date: Tue, 26 Feb 2008 17:03:26 +1100
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18371.43950.150842.429997@notabene.brown>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: message from Andrew Morton on Saturday February 23
References: <20080220144610.548202000@chello.nl>
	<20080223000620.7fee8ff8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

On Saturday February 23, akpm@linux-foundation.org wrote:
> On Wed, 20 Feb 2008 15:46:10 +0100 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > Another posting of the full swap over NFS series. 
> 
> Well I looked.  There's rather a lot of it and I wouldn't pretend to
> understand it.

But pretending is fun :-)

> 
> What is the NFS and net people's take on all of this?

Well I'm only vaguely an NFS person, barely a net person, sporadically
an mm person, but I've had a look and it seems to mostly make sense.

We introduce a new "emergency" concept for page allocation.
The size of the emergency pool is set by various reservations by
different potential users.
If the number of free pages is below the "emergency" size, then only
users with a "MEMALLOC" flag get to allocate pages.  Further, those
pages get a "reserve" flag set which propagates into slab/slub so
kmalloc/kmemalloc only return memory from those pages to MEMALLOC
users. 
MEMALLOC users are those that set PF_MEMALLOC.  A socket can get
SOCK_MEMALLOC set which will cause certain pieces of code to
temporarily set PF_MEMALLOC while working on that socket.

The upshot is that providing any MEMALLOC user reserves an appropriate
amount of emergency space, returns the emergency memory promptly, and
sets PF_MEMALLOC whenever allocating memory, it's memory allocations
should never fail.

As memory is requested is small units, but allocated as pages, there
needs to be a conversion from small-units to pages.  One of the
patches does this and appears to err on the side of be over-generous,
which is the right thing to do.


Memory reservations are organised in a tree.  I really don't
understand the tree.  Is it just to make /proc/reserve_info look more
helpful?
Certainly all the individual reservations need to be recorded, and the
cumulative reservation needs also to be recorded (currently in the
root of the tree) but what are all the other levels used for?

Reservations are used for all the transient memory that might be used
by the network stack.  This particularly includes the route cache and
skbs for incoming messages.  I have no idea if there is anything else
that needs to be allowed for.

Filesystems can advertise (via address_space_operations) that files
may be used as swap file.  They then provide swapout/swapin methods
which are like writepage/readpage but may behave differently and have
a different way to get credentials from a 'struct file'.


So in general, the patch set looks to have the right sort of shape.  I
cannot be very authoritative on the details as there are a lot of
them, and they touch code that I'm not very familiar with.

Some specific comments on patches:


reserve-slub.patch

   Please avoid irrelevant reformatting in patches.  It makes them
   harder to read.  e.g.:

-static void setup_object(struct kmem_cache *s, struct page *page,
-				void *object)
+static void setup_object(struct kmem_cache *s, struct page *page, void *object)


mm-kmem_estimate_pages.patch

   This introduces
         kestimate
         kestimate_single
         kmem_estimate_pages

   The last obviously returns a number of pages.  The contrast seems
   to suggest the others don't.   But they do...
   I don't think the names are very good, but I concede that it is
   hard to choose good names here.  Maybe:
          kmalloc_estimate_variable
          kmalloc_estimate_fixed
          kmem_alloc_estimate
   ???

mm-reserve.patch

   I'm confused by __mem_reserve_add.

+	reserve = mem_reserve_root.pages;
+	__calc_reserve(res, pages, 0);
+	reserve = mem_reserve_root.pages - reserve;

   __calc_reserve will always add 'pages' to mem_reserve_root.pages.
   So this is a complex way of doing
        reserve = pages;
        __calc_reserve(res, pages, 0);

    And as you can calculate reserve before calling __calc_reserve
    (which seems odd when stated that way), the whole function looks
    like it could become:

           ret = adjust_memalloc_reserve(pages);
	   if (!ret)
		__calc_reserve(res, pages, limit);
	   return ret;

    What am I missing?

    Also, mem_reserve_disconnect really should be a "void" function.
    Just put a BUG_ON(ret) and don't return anything.

    Finally, I'll just repeat that the purpose of the tree structure
    eludes me.

net-sk_allocation.patch

    Why are the "GFP_KERNEL" call sites just changed to
    "sk->sk_allocation" rather than "sk_allocation(sk, GFP_KERNEL)" ??

    I assume there is a good reason, and seeing it in the change log
    would educate me and make the patch more obviously correct.

netvm-reserve.patch

    Function names again:

         sk_adjust_memalloc
         sk_set_memalloc

    sound similar.  Purpose is completely different.

mm-page_file_methods.patch

    This makes page_offset and others more expensive by adding a
    conditional jump to a function call that is not usually made.

    Why do swap pages have a different index to everyone else?

nfs-swap_ops.patch

    What happens if you have two swap files on the same NFS
    filesystem?
    I assume ->swapfile gets called twice.  But it hasn't been written
    to nest, so the first swapoff will disable swapping for both
    files??

That's all for now :-)

NeilBrown

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
