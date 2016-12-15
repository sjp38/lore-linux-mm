Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id A2BA26B0038
	for <linux-mm@kvack.org>; Thu, 15 Dec 2016 10:59:50 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id g187so30983969itc.2
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 07:59:50 -0800 (PST)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id 68si2597321iot.131.2016.12.15.07.59.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 07:59:49 -0800 (PST)
Received: by mail-it0-x241.google.com with SMTP id n68so4106236itn.3
        for <linux-mm@kvack.org>; Thu, 15 Dec 2016 07:59:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161215092841.2f7065b5@redhat.com>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <5850335F.6090000@gmail.com>
 <20161213.145333.514056260418695987.davem@davemloft.net> <58505535.1080908@gmail.com>
 <20161214103914.3a9ebbbf@redhat.com> <5851740A.2080806@gmail.com>
 <CAKgT0UfnBurxz9f+ceD81hAp3U0tGHEi_5MEtxk6PiehG=X8ag@mail.gmail.com>
 <20161214222927.587a8ac4@redhat.com> <CAKgT0UfckuW-qPOr3WAgwKJFGu0Ot0g2Ha3uRpyU3rpdZeFVpA@mail.gmail.com>
 <20161215092841.2f7065b5@redhat.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Thu, 15 Dec 2016 07:59:47 -0800
Message-ID: <CAKgT0UfbxhvwAQoW01hJktujDbuiFxGd1QRJSNNE-PboK4vZKg@mail.gmail.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: John Fastabend <john.fastabend@gmail.com>, David Miller <davem@davemloft.net>, Christoph Lameter <cl@linux.com>, rppt@linux.vnet.ibm.com, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, willemdebruijn.kernel@gmail.com, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, magnus.karlsson@intel.com, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, METH@il.ibm.com, Vlad Yasevich <vyasevich@gmail.com>

On Thu, Dec 15, 2016 at 12:28 AM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Wed, 14 Dec 2016 14:45:00 -0800
> Alexander Duyck <alexander.duyck@gmail.com> wrote:
>
>> On Wed, Dec 14, 2016 at 1:29 PM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > On Wed, 14 Dec 2016 08:45:08 -0800
>> > Alexander Duyck <alexander.duyck@gmail.com> wrote:
>> >
>> >> I agree.  This is a no-go from the performance perspective as well.
>> >> At a minimum you would have to be zeroing out the page between uses to
>> >> avoid leaking data, and that assumes that the program we are sending
>> >> the pages to is slightly well behaved.  If we think zeroing out an
>> >> sk_buff is expensive wait until we are trying to do an entire 4K page.
>> >
>> > Again, yes the page will be zero'ed out, but only when entering the
>> > page_pool. Because they are recycled they are not cleared on every use.
>> > Thus, performance does not suffer.
>>
>> So you are talking about recycling, but not clearing the page when it
>> is recycled.  That right there is my problem with this.  It is fine if
>> you assume the pages are used by the application only, but you are
>> talking about using them for both the application and for the regular
>> network path.  You can't do that.  If you are recycling you will have
>> to clear the page every time you put it back onto the Rx ring,
>> otherwise you can leak the recycled memory into user space and end up
>> with a user space program being able to snoop data out of the skb.
>>
>> > Besides clearing large mem area is not as bad as clearing small.
>> > Clearing an entire page does cost something, as mentioned before 143
>> > cycles, which is 28 bytes-per-cycle (4096/143).  And clearing 256 bytes
>> > cost 36 cycles which is only 7 bytes-per-cycle (256/36).
>>
>> What I am saying is that you are going to be clearing the 4K blocks
>> each time they are recycled.  You can't have the pages shared between
>> user-space and the network stack unless you have true isolation.  If
>> you are allowing network stack pages to be recycled back into the
>> user-space application you open up all sorts of leaks where the
>> application can snoop into data it shouldn't have access to.
>
> See later, the "Read-only packet page" mode should provide a mode where
> the netstack doesn't write into the page, and thus cannot leak kernel
> data. (CAP_NET_ADMIN already give it access to other applications data.)

I think you are kind of missing the point.  The device is writing to
the page on the kernel's behalf.  Therefore the page isn't "Read-only"
and you have an issue since you are talking about sharing a ring
between kernel and userspace.

>> >> I think we are stuck with having to use a HW filter to split off
>> >> application traffic to a specific ring, and then having to share the
>> >> memory between the application and the kernel on that ring only.  Any
>> >> other approach just opens us up to all sorts of security concerns
>> >> since it would be possible for the application to try to read and
>> >> possibly write any data it wants into the buffers.
>> >
>> > This is why I wrote a document[1], trying to outline how this is possible,
>> > going through all the combinations, and asking the community to find
>> > faults in my idea.  Inlining it again, as nobody really replied on the
>> > content of the doc.
>> >
>> > -
>> > Best regards,
>> >   Jesper Dangaard Brouer
>> >   MSc.CS, Principal Kernel Engineer at Red Hat
>> >   LinkedIn: http://www.linkedin.com/in/brouer
>> >
>> > [1] https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/memory_model_nic.html
>> >
>> > ===========================
>> > Memory Model for Networking
>> > ===========================
>> >
>> > This design describes how the page_pool change the memory model for
>> > networking in the NIC (Network Interface Card) drivers.
>> >
>> > .. Note:: The catch for driver developers is that, once an application
>> >           request zero-copy RX, then the driver must use a specific
>> >           SKB allocation mode and might have to reconfigure the
>> >           RX-ring.
>> >
>> >
>> > Design target
>> > =============
>> >
>> > Allow the NIC to function as a normal Linux NIC and be shared in a
>> > safe manor, between the kernel network stack and an accelerated
>> > userspace application using RX zero-copy delivery.
>> >
>> > Target is to provide the basis for building RX zero-copy solutions in
>> > a memory safe manor.  An efficient communication channel for userspace
>> > delivery is out of scope for this document, but OOM considerations are
>> > discussed below (`Userspace delivery and OOM`_).
>> >
>> > Background
>> > ==========
>> >
>> > The SKB or ``struct sk_buff`` is the fundamental meta-data structure
>> > for network packets in the Linux Kernel network stack.  It is a fairly
>> > complex object and can be constructed in several ways.
>> >
>> > From a memory perspective there are two ways depending on
>> > RX-buffer/page state:
>> >
>> > 1) Writable packet page
>> > 2) Read-only packet page
>> >
>> > To take full potential of the page_pool, the drivers must actually
>> > support handling both options depending on the configuration state of
>> > the page_pool.
>> >
>> > Writable packet page
>> > --------------------
>> >
>> > When the RX packet page is writable, the SKB setup is fairly straight
>> > forward.  The SKB->data (and skb->head) can point directly to the page
>> > data, adjusting the offset according to drivers headroom (for adding
>> > headers) and setting the length according to the DMA descriptor info.
>> >
>> > The page/data need to be writable, because the network stack need to
>> > adjust headers (like TimeToLive and checksum) or even add or remove
>> > headers for encapsulation purposes.
>> >
>> > A subtle catch, which also requires a writable page, is that the SKB
>> > also have an accompanying "shared info" data-structure ``struct
>> > skb_shared_info``.  This "skb_shared_info" is written into the
>> > skb->data memory area at the end (skb->end) of the (header) data.  The
>> > skb_shared_info contains semi-sensitive information, like kernel
>> > memory pointers to other pages (which might be pointers to more packet
>> > data).  This would be bad from a zero-copy point of view to leak this
>> > kind of information.
>>
>> This should be the default once we get things moved over to using the
>> DMA_ATTR_SKIP_CPU_SYNC DMA attribute.  It will be a little while more
>> before it gets fully into Linus's tree.  It looks like the swiotlb
>> bits have been accepted, just waiting on the ability to map a page w/
>> attributes and the remainder of the patches that are floating around
>> in mmotm and linux-next.
>
> I'm very happy that you are working on this.

Well it looks like the rest just got accepted into Linus's tree
yesterday.  There are still some documentation and rename patches
outstanding but I will probably start submitting driver updates for
enabling build_skb and the like in net-next in the next several weeks.

>> BTW, any ETA on when we might expect to start seeing code related to
>> the page_pool?  It is much easier to review code versus these kind of
>> blueprints.
>
> I've implemented a prove-of-concept of page_pool, but only the first
> stage, which is the ability to replace driver specific page-caches.  It
> works, but is not upstream ready, as e.g. it assumes it can get a page
> flag and cleanup-on-driver-unload code is missing.  Mel Gorman have
> reviewed it, but with the changes he requested I lost quite some
> performance, I'm still trying to figure out a way to regain that
> performance lost.  The zero-copy part is not implemented.

Well RFCs are always welcome.  It is just really hard to review things
when all you have is documentation that may or may not match up with
what ends up being implemented.

>
>> > Read-only packet page
>> > ---------------------
>> >
>> > When the RX packet page is read-only, the construction of the SKB is
>> > significantly more complicated and even involves one more memory
>> > allocation.
>> >
>> > 1) Allocate a new separate writable memory area, and point skb->data
>> >    here.  This is needed due to (above described) skb_shared_info.
>> >
>> > 2) Memcpy packet headers into this (skb->data) area.
>> >
>> > 3) Clear part of skb_shared_info struct in writable-area.
>> >
>> > 4) Setup pointer to packet-data in the page (in skb_shared_info->frags)
>> >    and adjust the page_offset to be past the headers just copied.
>> >
>> > It is useful (later) that the network stack have this notion that part
>> > of the packet and a page can be read-only.  This implies that the
>> > kernel will not "pollute" this memory with any sensitive information.
>> > This is good from a zero-copy point of view, but bad from a
>> > performance perspective.
>>
>> This will hopefully become a legacy approach.
>
> Hopefully, but this mode will have to be supported forever, and is the
> current default.

Maybe you need to rename this approach since it is clear there is some
confusion about what is going on here.  The page is not Read-only.  It
is left device mapped and is not writable by the CPU.  That doesn't
mean it isn't written to though.

>
>> > NIC RX Zero-Copy
>> > ================
>> >
>> > Doing NIC RX zero-copy involves mapping RX pages into userspace.  This
>> > involves costly mapping and unmapping operations in the address space
>> > of the userspace process.  Plus for doing this safely, the page memory
>> > need to be cleared before using it, to avoid leaking kernel
>> > information to userspace, also a costly operation.  The page_pool base
>> > "class" of optimization is moving these kind of operations out of the
>> > fastpath, by recycling and lifetime control.
>> >
>> > Once a NIC RX-queue's page_pool have been configured for zero-copy
>> > into userspace, then can packets still be allowed to travel the normal
>> > stack?
>> >
>> > Yes, this should be possible, because the driver can use the
>> > SKB-read-only mode, which avoids polluting the page data with
>> > kernel-side sensitive data.  This implies, when a driver RX-queue
>> > switch page_pool to RX-zero-copy mode it MUST also switch to
>> > SKB-read-only mode (for normal stack delivery for this RXq).
>>
>> This is the part that is wrong.  Once userspace has access to the
>> pages in an Rx ring that ring cannot be used for regular kernel-side
>> networking.  If it is, then sensitive kernel data may be leaked
>> because the application has full access to any page on the ring so it
>> could read the data at any time regardless of where the data is meant
>> to be delivered.
>
> Are you sure. Can you give me an example of kernel code that writes
> into the page when it is attached as a read-only page to the SKB?

You are completely overlooking the writes by the device.  The device
is writing to the page.  Therefore it is not a true "read-only" page.

> That would violate how we/drivers use the DMA API today (calling DMA
> unmap when packets are in-flight).

What I am talking about is the DMA so it doesn't violate things.

>> > XDP can be used for controlling which pages that gets RX zero-copied
>> > to userspace.  The page is still writable for the XDP program, but
>> > read-only for normal stack delivery.
>>
>> Making the page read-only doesn't get you anything.  You still have a
>> conflict since user-space can read any packet directly out of the
>> page.
>
> Giving the application CAP_NAT_ADMIN already gave it "tcpdump" read access
> to all other applications packet content from that NIC.

Now we are getting somewhere.  So in this scenario we are okay with
the application being able to read anything that is written to the
kernel.  That is actually the data I was concerned about.  So as long
as we are fine with the application reading any data that is going by
in the packets then we should be fine sharing the data this way.

It does lead to questions though on why there was the 1 page per
packet requirement.  As long as we are using pages in this "read-only"
format you could share as many pages as you wanted and have either
multiple packets per page or multiple pages per packet as long as you
honor the read-only aspect of things.

>> > Kernel safety
>> > -------------
>> >
>> > For the paranoid, how do we protect the kernel from a malicious
>> > userspace program.  Sure there will be a communication interface
>> > between kernel and userspace, that synchronize ownership of pages.
>> > But a userspace program can violate this interface, given pages are
>> > kept VMA mapped, the program can in principle access all the memory
>> > pages in the given page_pool.  This opens up for a malicious (or
>> > defect) program modifying memory pages concurrently with the kernel
>> > and DMA engine using them.
>> >
>> > An easy way to get around userspace modifying page data contents is
>> > simply to map pages read-only into userspace.
>> >
>> > .. Note:: The first implementation target is read-only zero-copy RX
>> >           page to userspace and require driver to use SKB-read-only
>> >           mode.
>>
>> This allows for Rx but what do we do about Tx?
>
> True, I've not covered Tx.  But I believe Tx is easier from a sharing
> PoV, as we don't have the early demux sharing problem, because an
> application/socket will be the starting point, and simply have
> associated a page_pool for TX, solving the VMA mapping overhead.
> Using the skb-read-only-page mode, this would in principle allow normal
> socket zero-copy TX and packet steering.
>
> For performance reasons, when you already know what NIC you want to TX
> on, you could extend this to allocate a separate queue for TX.  Which
> makes it look a lot like RDMA.
>
>
>> It sounds like Christoph's RDMA approach might be the way to go.
>
> I'm getting more and more fond of Christoph's RDMA approach.  I do
> think we will end-up with something close to that approach.  I just
> wanted to get review on my idea first.
>
> IMHO the major blocker for the RDMA approach is not HW filters
> themselves, but a common API that applications can call to register
> what goes into the HW queues in the driver.  I suspect it will be a
> long project agreeing between vendors.  And agreeing on semantics.

We really should end up doing a HW filtering approach for any
application most likely anyway.  I know the Intel parts have their
Flow Director which should allow for directing a flow to the correct
queue.  Really it sort of makes sense to look at going that route as
you can focus your software efforts on a queue that should mostly
contain the traffic you are looking for rather than one that will be
processing unrelated traffic.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
