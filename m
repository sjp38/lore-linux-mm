Subject: Re: [PATCH 00/28] Swap over NFS -v16
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <18371.43950.150842.429997@notabene.brown>
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
Content-Type: text/plain
Date: Tue, 26 Feb 2008 11:50:42 +0100
Message-Id: <1204023042.6242.271.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Neil Brown <neilb@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

Hi Neil,


On Tue, 2008-02-26 at 17:03 +1100, Neil Brown wrote:
> On Saturday February 23, akpm@linux-foundation.org wrote:
 
> > What is the NFS and net people's take on all of this?
> 
> Well I'm only vaguely an NFS person, barely a net person, sporadically
> an mm person, but I've had a look and it seems to mostly make sense.

Thanks for taking a look, and giving such elaborate feedback. I'll try
and address these issues asap, but first let me reply to a few points
here.

> We introduce a new "emergency" concept for page allocation.
> The size of the emergency pool is set by various reservations by
> different potential users.
> If the number of free pages is below the "emergency" size, then only
> users with a "MEMALLOC" flag get to allocate pages.  Further, those
> pages get a "reserve" flag set which propagates into slab/slub so
> kmalloc/kmemalloc only return memory from those pages to MEMALLOC
> users. 
> MEMALLOC users are those that set PF_MEMALLOC.  A socket can get
> SOCK_MEMALLOC set which will cause certain pieces of code to
> temporarily set PF_MEMALLOC while working on that socket.

Small detail, there is also __GFP_MEMALLOC, this is used for single
allocations to avoid setting and unsetting PF_MEMALLOC - like in the skb
alloc once we have determined we otherwise fail and still have room.

> The upshot is that providing any MEMALLOC user reserves an appropriate
> amount of emergency space, returns the emergency memory promptly, and
> sets PF_MEMALLOC whenever allocating memory, it's memory allocations
> should never fail.
> 
> As memory is requested is small units, but allocated as pages, there
> needs to be a conversion from small-units to pages.  One of the
> patches does this and appears to err on the side of be over-generous,
> which is the right thing to do.
> 
> 
> Memory reservations are organised in a tree.  I really don't
> understand the tree.  Is it just to make /proc/reserve_info look more
> helpful?
> Certainly all the individual reservations need to be recorded, and the
> cumulative reservation needs also to be recorded (currently in the
> root of the tree) but what are all the other levels used for?

Ah, there is a little trick there, I hint at that in the reserve.c
description comment:

+ * As long as a subtree has the same usage unit, an aggregate node can be used
+ * to charge against, instead of the leaf nodes. However, do be consistent with
+ * who is charged, resource usage is not propagated up the tree (for
+ * performance reasons).

And I actually use that, if we show a little of the tree (which andrew
rightly dislikes for not being machine parseable - will fix):

+ * localhost ~ # cat /proc/reserve_info
+ * total reserve                  8156K (0/544817)
+ *   total network reserve          8156K (0/544817)
+ *     network TX reserve             196K (0/49)
+ *       protocol TX pages              196K (0/49)
+ *     network RX reserve             7960K (0/544768)
+ *       IPv6 route cache               1372K (0/4096)
+ *       IPv4 route cache               5468K (0/16384)
+ *       SKB data reserve               1120K (0/524288)
+ *         IPv6 fragment cache            560K (0/262144)
+ *         IPv4 fragment cache            560K (0/262144)

We see that the 'SKB data reserve' is build up of the IPv4 and IPv6
fragment cache reserves.

I use the 'SKB data reserve' to charge memory against and account usage,
but use its children to grow/shrink the actual reserve.

This allows you to see the individual reserves, but still use an
aggregate.

The tree form is the simplest structure that allowed such things,
another nice thing is that you can easily detach whole sub-trees to stop
actually reserving the memory, but continue tracking its potential
needs. 

This is done when there are no SOCK_MEMALLOC sockets around. The 'total
network reserve' is detached, reducing the 'total reserve' to 0
(assuming no other reserve trees) but the individual reserves are still
tracking their potential need for when it will be re-attached.

With only a single user this might seen a little too much, but I have
hopes for more users.

> Reservations are used for all the transient memory that might be used
> by the network stack.  This particularly includes the route cache and
> skbs for incoming messages.  I have no idea if there is anything else
> that needs to be allowed for.

This is something I'd like feedback on from the network guru's. In my
reading there weren't many other allocation sites, but hey, I'm not much
of a net person myself. (I did write some instrumentation to track
allocations, but I'm sure I didn't get full coverage of the stack with
my simple usage).

> Filesystems can advertise (via address_space_operations) that files
> may be used as swap file.  They then provide swapout/swapin methods
> which are like writepage/readpage but may behave differently and have
> a different way to get credentials from a 'struct file'.

Yes, the added benefit is that even regular blockdev filesystem swap
files could move to this interface and we'd finally be able to remove
->bmap().

> So in general, the patch set looks to have the right sort of shape.  I
> cannot be very authoritative on the details as there are a lot of
> them, and they touch code that I'm not very familiar with.
> 
> Some specific comments on patches:
> 
> 
> reserve-slub.patch
> 
>    Please avoid irrelevant reformatting in patches.  It makes them
>    harder to read.  e.g.:
> 
> -static void setup_object(struct kmem_cache *s, struct page *page,
> -				void *object)
> +static void setup_object(struct kmem_cache *s, struct page *page, void *object)

Right, I'll split out the cleanups and send those in separately.

> mm-kmem_estimate_pages.patch
> 
>    This introduces
>          kestimate
>          kestimate_single
>          kmem_estimate_pages
> 
>    The last obviously returns a number of pages.  The contrast seems
>    to suggest the others don't.   But they do...
>    I don't think the names are very good, but I concede that it is
>    hard to choose good names here.  Maybe:
>           kmalloc_estimate_variable
>           kmalloc_estimate_fixed
>           kmem_alloc_estimate
>    ???

You caught me here (and further on), I'm one of those who needs a little
help when it comes to names :-). I'll try and improve the ones you
pointed out.

> mm-reserve.patch
> 
>    I'm confused by __mem_reserve_add.
> 
> +	reserve = mem_reserve_root.pages;
> +	__calc_reserve(res, pages, 0);
> +	reserve = mem_reserve_root.pages - reserve;
> 
>    __calc_reserve will always add 'pages' to mem_reserve_root.pages.
>    So this is a complex way of doing
>         reserve = pages;
>         __calc_reserve(res, pages, 0);
> 
>     And as you can calculate reserve before calling __calc_reserve
>     (which seems odd when stated that way), the whole function looks
>     like it could become:
> 
>            ret = adjust_memalloc_reserve(pages);
> 	   if (!ret)
> 		__calc_reserve(res, pages, limit);
> 	   return ret;
> 
>     What am I missing?

Probably the horrible twist my brain has. Looking at it makes me doubt
my own sanity. I think you're right - it would also clean up
__calc_reserve() a little.

This is what review for :-)

>     Also, mem_reserve_disconnect really should be a "void" function.
>     Just put a BUG_ON(ret) and don't return anything.

Agreed, I was being over cautious here. I'll WARN_ON, as Andrew is
scared of BUGs :-)

>     Finally, I'll just repeat that the purpose of the tree structure
>     eludes me.

I hope to have cleared that up. It came from the desire of my users
(there are quite a few out there who use some form of this code) to see
what the reserve is made up of - to see what tunables to use, and their
effect.

The tree form was the easiest that allowed me to keep individual
reserves and work with aggregates. (Must confess, some nodes are purely
decoration).

> net-sk_allocation.patch
> 
>     Why are the "GFP_KERNEL" call sites just changed to
>     "sk->sk_allocation" rather than "sk_allocation(sk, GFP_KERNEL)" ??
> 
>     I assume there is a good reason, and seeing it in the change log
>     would educate me and make the patch more obviously correct.

Good point. I think because of legacy (with this patch-set) reasons. Its
not needed for my use of sk_allocation(), but that gives me no right to
deny other people more creative uses of this construct. I'll rectify
this.

> netvm-reserve.patch
> 
>     Function names again:
> 
>          sk_adjust_memalloc
>          sk_set_memalloc
> 
>     sound similar.  Purpose is completely different.

The naming thing,... I'll try and come up with better ones.

> mm-page_file_methods.patch
> 
>     This makes page_offset and others more expensive by adding a
>     conditional jump to a function call that is not usually made.
> 
>     Why do swap pages have a different index to everyone else?

Because the page->index of an anonymous page is related to its (anon)vma
so that it satisfies the constraints for vm_normal_page().

The index in the swap file it totally unrelated and quite random. Hence
the swap-cache uses page->private to store it in.

Moving these functions inline (esp __page_file_index seems doable)
results in a horrible include hell.

> nfs-swap_ops.patch
> 
>     What happens if you have two swap files on the same NFS
>     filesystem?
>     I assume ->swapfile gets called twice.  But it hasn't been written
>     to nest, so the first swapoff will disable swapping for both
>     files??

Hmm,.. you are quite right (again). I failed to consider this. Not sure
how to rectify this as xprt->swapper is but a single bit.

I'll think about this.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
