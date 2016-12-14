Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 85AD96B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 17:45:03 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id 3so6323259ioc.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 14:45:03 -0800 (PST)
Received: from mail-it0-x242.google.com (mail-it0-x242.google.com. [2607:f8b0:4001:c0b::242])
        by mx.google.com with ESMTPS id k81si28054561ioo.119.2016.12.14.14.45.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 14:45:02 -0800 (PST)
Received: by mail-it0-x242.google.com with SMTP id c20so1636413itb.0
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 14:45:02 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161214222927.587a8ac4@redhat.com>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <5850335F.6090000@gmail.com>
 <20161213.145333.514056260418695987.davem@davemloft.net> <58505535.1080908@gmail.com>
 <20161214103914.3a9ebbbf@redhat.com> <5851740A.2080806@gmail.com>
 <CAKgT0UfnBurxz9f+ceD81hAp3U0tGHEi_5MEtxk6PiehG=X8ag@mail.gmail.com> <20161214222927.587a8ac4@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 14 Dec 2016 14:45:00 -0800
Message-ID: <CAKgT0UfckuW-qPOr3WAgwKJFGu0Ot0g2Ha3uRpyU3rpdZeFVpA@mail.gmail.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: John Fastabend <john.fastabend@gmail.com>, David Miller <davem@davemloft.net>, Christoph Lameter <cl@linux.com>, rppt@linux.vnet.ibm.com, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, willemdebruijn.kernel@gmail.com, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, magnus.karlsson@intel.com, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, METH@il.ibm.com, Vlad Yasevich <vyasevich@gmail.com>

On Wed, Dec 14, 2016 at 1:29 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 14 Dec 2016 08:45:08 -0800
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> I agree.  This is a no-go from the performance perspective as well.
>> At a minimum you would have to be zeroing out the page between uses to
>> avoid leaking data, and that assumes that the program we are sending
>> the pages to is slightly well behaved.  If we think zeroing out an
>> sk_buff is expensive wait until we are trying to do an entire 4K page.
>
> Again, yes the page will be zero'ed out, but only when entering the
> page_pool. Because they are recycled they are not cleared on every use.
> Thus, performance does not suffer.

So you are talking about recycling, but not clearing the page when it
is recycled.  That right there is my problem with this.  It is fine if
you assume the pages are used by the application only, but you are
talking about using them for both the application and for the regular
network path.  You can't do that.  If you are recycling you will have
to clear the page every time you put it back onto the Rx ring,
otherwise you can leak the recycled memory into user space and end up
with a user space program being able to snoop data out of the skb.

> Besides clearing large mem area is not as bad as clearing small.
> Clearing an entire page does cost something, as mentioned before 143
> cycles, which is 28 bytes-per-cycle (4096/143).  And clearing 256 bytes
> cost 36 cycles which is only 7 bytes-per-cycle (256/36).

What I am saying is that you are going to be clearing the 4K blocks
each time they are recycled.  You can't have the pages shared between
user-space and the network stack unless you have true isolation.  If
you are allowing network stack pages to be recycled back into the
user-space application you open up all sorts of leaks where the
application can snoop into data it shouldn't have access to.

>> I think we are stuck with having to use a HW filter to split off
>> application traffic to a specific ring, and then having to share the
>> memory between the application and the kernel on that ring only.  Any
>> other approach just opens us up to all sorts of security concerns
>> since it would be possible for the application to try to read and
>> possibly write any data it wants into the buffers.
>
> This is why I wrote a document[1], trying to outline how this is possible,
> going through all the combinations, and asking the community to find
> faults in my idea.  Inlining it again, as nobody really replied on the
> content of the doc.
>
> -
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
>
> [1] https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html
>
> ===========================
> Memory Model for Networking
> ===========================
>
> This design describes how the page_pool change the memory model for
> networking in the NIC (Network Interface Card) drivers.
>
> .. Note:: The catch for driver developers is that, once an application
>           request zero-copy RX, then the driver must use a specific
>           SKB allocation mode and might have to reconfigure the
>           RX-ring.
>
>
> Design target
> =============
>
> Allow the NIC to function as a normal Linux NIC and be shared in a
> safe manor, between the kernel network stack and an accelerated
> userspace application using RX zero-copy delivery.
>
> Target is to provide the basis for building RX zero-copy solutions in
> a memory safe manor.  An efficient communication channel for userspace
> delivery is out of scope for this document, but OOM considerations are
> discussed below (`Userspace delivery and OOM`_).
>
> Background
> ==========
>
> The SKB or ``struct sk_buff`` is the fundamental meta-data structure
> for network packets in the Linux Kernel network stack.  It is a fairly
> complex object and can be constructed in several ways.
>
> From a memory perspective there are two ways depending on
> RX-buffer/page state:
>
> 1) Writable packet page
> 2) Read-only packet page
>
> To take full potential of the page_pool, the drivers must actually
> support handling both options depending on the configuration state of
> the page_pool.
>
> Writable packet page
> --------------------
>
> When the RX packet page is writable, the SKB setup is fairly straight
> forward.  The SKB->data (and skb->head) can point directly to the page
> data, adjusting the offset according to drivers headroom (for adding
> headers) and setting the length according to the DMA descriptor info.
>
> The page/data need to be writable, because the network stack need to
> adjust headers (like TimeToLive and checksum) or even add or remove
> headers for encapsulation purposes.
>
> A subtle catch, which also requires a writable page, is that the SKB
> also have an accompanying "shared info" data-structure ``struct
> skb_shared_info``.  This "skb_shared_info" is written into the
> skb->data memory area at the end (skb->end) of the (header) data.  The
> skb_shared_info contains semi-sensitive information, like kernel
> memory pointers to other pages (which might be pointers to more packet
> data).  This would be bad from a zero-copy point of view to leak this
> kind of information.

This should be the default once we get things moved over to using the
DMA_ATTR_SKIP_CPU_SYNC DMA attribute.  It will be a little while more
before it gets fully into Linus's tree.  It looks like the swiotlb
bits have been accepted, just waiting on the ability to map a page w/
attributes and the remainder of the patches that are floating around
in mmotm and linux-next.

BTW, any ETA on when we might expect to start seeing code related to
the page_pool?  It is much easier to review code versus these kind of
blueprints.

> Read-only packet page
> ---------------------
>
> When the RX packet page is read-only, the construction of the SKB is
> significantly more complicated and even involves one more memory
> allocation.
>
> 1) Allocate a new separate writable memory area, and point skb->data
>    here.  This is needed due to (above described) skb_shared_info.
>
> 2) Memcpy packet headers into this (skb->data) area.
>
> 3) Clear part of skb_shared_info struct in writable-area.
>
> 4) Setup pointer to packet-data in the page (in skb_shared_info->frags)
>    and adjust the page_offset to be past the headers just copied.
>
> It is useful (later) that the network stack have this notion that part
> of the packet and a page can be read-only.  This implies that the
> kernel will not "pollute" this memory with any sensitive information.
> This is good from a zero-copy point of view, but bad from a
> performance perspective.

This will hopefully become a legacy approach.

>
> NIC RX Zero-Copy
> ================
>
> Doing NIC RX zero-copy involves mapping RX pages into userspace.  This
> involves costly mapping and unmapping operations in the address space
> of the userspace process.  Plus for doing this safely, the page memory
> need to be cleared before using it, to avoid leaking kernel
> information to userspace, also a costly operation.  The page_pool base
> "class" of optimization is moving these kind of operations out of the
> fastpath, by recycling and lifetime control.
>
> Once a NIC RX-queue's page_pool have been configured for zero-copy
> into userspace, then can packets still be allowed to travel the normal
> stack?
>
> Yes, this should be possible, because the driver can use the
> SKB-read-only mode, which avoids polluting the page data with
> kernel-side sensitive data.  This implies, when a driver RX-queue
> switch page_pool to RX-zero-copy mode it MUST also switch to
> SKB-read-only mode (for normal stack delivery for this RXq).

This is the part that is wrong.  Once userspace has access to the
pages in an Rx ring that ring cannot be used for regular kernel-side
networking.  If it is, then sensitive kernel data may be leaked
because the application has full access to any page on the ring so it
could read the data at any time regardless of where the data is meant
to be delivered.

> XDP can be used for controlling which pages that gets RX zero-copied
> to userspace.  The page is still writable for the XDP program, but
> read-only for normal stack delivery.

Making the page read-only doesn't get you anything.  You still have a
conflict since user-space can read any packet directly out of the
page.

> Kernel safety
> -------------
>
> For the paranoid, how do we protect the kernel from a malicious
> userspace program.  Sure there will be a communication interface
> between kernel and userspace, that synchronize ownership of pages.
> But a userspace program can violate this interface, given pages are
> kept VMA mapped, the program can in principle access all the memory
> pages in the given page_pool.  This opens up for a malicious (or
> defect) program modifying memory pages concurrently with the kernel
> and DMA engine using them.
>
> An easy way to get around userspace modifying page data contents is
> simply to map pages read-only into userspace.
>
> .. Note:: The first implementation target is read-only zero-copy RX
>           page to userspace and require driver to use SKB-read-only
>           mode.

This allows for Rx but what do we do about Tx?  It sounds like
Christoph's RDMA approach might be the way to go.

> Advanced: Allowing userspace write access?
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>
> What if userspace need write access? Flipping the page permissions per
> transfer will likely kill performance (as this likely affects the
> TLB-cache).
>
> I will argue that giving userspace write access is still possible,
> without risking a kernel crash.  This is related to the SKB-read-only
> mode that copies the packet headers (in to another memory area,
> inaccessible to userspace).  The attack angle is to modify packet
> headers after they passed some kernel network stack validation step
> (as once headers are copied they are out of "reach").
>
> Situation classes where memory page can be modified concurrently:
>
> 1) When DMA engine owns the page.  Not a problem, as DMA engine will
>    simply overwrite data.
>
> 2) Just after DMA engine finish writing.  Not a problem, the packet
>    will go through netstack validation and be rejected.
>
> 3) While XDP reads data. This can lead to XDP/eBPF program goes into a
>    wrong code branch, but the eBPF virtual machine should not be able
>    to crash the kernel. The worst outcome is a wrong or invalid XDP
>    return code.
>
> 4) Before SKB with read-only page is constructed. Not a problem, the
>    packet will go through netstack validation and be rejected.
>
> 5) After SKB with read-only page has been constructed.  Remember the
>    packet headers were copied into a separate memory area, and the
>    page data is pointed to with an offset passed the copied headers.
>    Thus, userspace cannot modify the headers used for netstack
>    validation.  It can only modify packet data contents, which is less
>    critical as it cannot crash the kernel, and eventually this will be
>    caught by packet checksum validation.
>
> 6) After netstack delivered packet to another userspace process. Not a
>    problem, as it cannot crash the kernel.  It might corrupt
>    packet-data being read by another userspace process, which one
>    argument for requiring elevated privileges to get write access
>    (like NET_CAP_ADMIN).

If userspace has access to a ring we shouldn't be using SKBs on it
really anyway.  We should probably expect XDP to be handling all the
packaging so items 4-6 can probably be dropped.

>
> Userspace delivery and OOM
> --------------------------
>
> These RX pages are likely mapped to userspace via mmap(), so-far so
> good.  It is key to performance to get an efficient way of signaling
> between kernel and userspace, e.g what page are ready for consumption,
> and when userspace are done with the page.
>
> It is outside the scope of page_pool to provide such a queuing
> structure, but the page_pool can offer some means of protecting the
> system resource usage.  It is a classical problem that resources
> (e.g. the page) must be returned in a timely manor, else the system,
> in this case, will run out of memory.  Any system/design with
> unbounded memory allocation can lead to Out-Of-Memory (OOM)
> situations.
>
> Communication between kernel and userspace is likely going to be some
> kind of queue.  Given transferring packets individually will have too
> much scheduling overhead.  A queue can implicitly function as a
> bulking interface, and offers a natural way to split the workload
> across CPU cores.
>
> This essentially boils down-to a two queue system, with the RX-ring
> queue and the userspace delivery queue.
>
> Two bad situations exists for the userspace queue:
>
> 1) Userspace is not consuming objects fast-enough. This should simply
>    result in packets getting dropped when enqueueing to a full
>    userspace queue (as queue *must* implement some limit). Open
>    question is; should this be reported or communicated to userspace.
>
> 2) Userspace is consuming objects fast, but not returning them in a
>    timely manor.  This is a bad situation, because it threatens the
>    system stability as it can lead to OOM.
>
> The page_pool should somehow protect the system in case 2.  The
> page_pool can detect the situation as it is able to track the number
> of outstanding pages, due to the recycle feedback loop.  Thus, the
> page_pool can have some configurable limit of allowed outstanding
> pages, which can protect the system against OOM.
>
> Note, the `Fbufs paper`_ propose to solve case 2 by allowing these
> pages to be "pageable", i.e. swap-able, but that is not an option for
> the page_pool as these pages are DMA mapped.
>
> .. _`Fbufs paper`:
>    http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.52.9688
>
> Effect of blocking allocation
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>
> The effect of page_pool, in case 2, that denies more allocations
> essentially result-in the RX-ring queue cannot be refilled and HW
> starts dropping packets due to "out-of-buffers".  For NICs with
> several HW RX-queues, this can be limited to a subset of queues (and
> admin can control which RX queue with HW filters).
>
> The question is if the page_pool can do something smarter in this
> case, to signal the consumers of these pages, before the maximum limit
> is hit (of allowed outstanding packets).  The MM-subsystem already
> have a concept of emergency PFMEMALLOC reserves and associate
> page-flags (e.g. page_is_pfmemalloc).  And the network stack already
> handle and react to this.  Could the same PFMEMALLOC system be used
> for marking pages when limit is close?
>
> This requires further analysis. One can imagine; this could be used at
> RX by XDP to mitigate the situation by dropping less-important frames.
> Given XDP choose which pages are being send to userspace it might have
> appropriate knowledge of what it relevant to drop(?).
>
> .. Note:: An alternative idea is using a data-structure that blocks
>           userspace from getting new pages before returning some.
>           (out of scope for the page_pool)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
