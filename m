Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0EEEE6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 11:45:10 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id n68so4311535itn.4
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:45:10 -0800 (PST)
Received: from mail-it0-x243.google.com (mail-it0-x243.google.com. [2607:f8b0:4001:c0b::243])
        by mx.google.com with ESMTPS id 30si14311542ioj.77.2016.12.14.08.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 08:45:09 -0800 (PST)
Received: by mail-it0-x243.google.com with SMTP id 75so585606ite.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 08:45:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5851740A.2080806@gmail.com>
References: <alpine.DEB.2.20.1612121200280.13607@east.gentwo.org>
 <20161213171028.24dbf519@redhat.com> <5850335F.6090000@gmail.com>
 <20161213.145333.514056260418695987.davem@davemloft.net> <58505535.1080908@gmail.com>
 <20161214103914.3a9ebbbf@redhat.com> <5851740A.2080806@gmail.com>
From: Alexander Duyck <alexander.duyck@gmail.com>
Date: Wed, 14 Dec 2016 08:45:08 -0800
Message-ID: <CAKgT0UfnBurxz9f+ceD81hAp3U0tGHEi_5MEtxk6PiehG=X8ag@mail.gmail.com>
Subject: Re: Designing a safe RX-zero-copy Memory Model for Networking
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Fastabend <john.fastabend@gmail.com>
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, David Miller <davem@davemloft.net>, Christoph Lameter <cl@linux.com>, rppt@linux.vnet.ibm.com, Netdev <netdev@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, willemdebruijn.kernel@gmail.com, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, magnus.karlsson@intel.com, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, METH@il.ibm.com, Vlad Yasevich <vyasevich@gmail.com>

On Wed, Dec 14, 2016 at 8:32 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 16-12-14 01:39 AM, Jesper Dangaard Brouer wrote:
>> On Tue, 13 Dec 2016 12:08:21 -0800
>> John Fastabend <john.fastabend@gmail.com> wrote:
>>
>>> On 16-12-13 11:53 AM, David Miller wrote:
>>>> From: John Fastabend <john.fastabend@gmail.com>
>>>> Date: Tue, 13 Dec 2016 09:43:59 -0800
>>>>
>>>>> What does "zero-copy send packet-pages to the application/socket that
>>>>> requested this" mean? At the moment on x86 page-flipping appears to be
>>>>> more expensive than memcpy (I can post some data shortly) and shared
>>>>> memory was proposed and rejected for security reasons when we were
>>>>> working on bifurcated driver.
>>>>
>>>> The whole idea is that we map all the active RX ring pages into
>>>> userspace from the start.
>>>>
>>>> And just how Jesper's page pool work will avoid DMA map/unmap,
>>>> it will also avoid changing the userspace mapping of the pages
>>>> as well.
>>>>
>>>> Thus avoiding the TLB/VM overhead altogether.
>>>>
>>
>> Exactly.  It is worth mentioning that pages entering the page pool need
>> to be cleared (measured cost 143 cycles), in order to not leak any
>> kernel info.  The primary focus of this design is to make sure not to
>> leak kernel info to userspace, but with an "exclusive" mode also
>> support isolation between applications.
>>
>>
>>> I get this but it requires applications to be isolated. The pages from
>>> a queue can not be shared between multiple applications in different
>>> trust domains. And the application has to be cooperative meaning it
>>> can't "look" at data that has not been marked by the stack as OK. In
>>> these schemes we tend to end up with something like virtio/vhost or
>>> af_packet.
>>
>> I expect 3 modes, when enabling RX-zero-copy on a page_pool. The first
>> two would require CAP_NET_ADMIN privileges.  All modes have a trust
>> domain id, that need to match e.g. when page reach the socket.
>
> Even mode 3 should required cap_net_admin we don't want userspace to
> grab queues off the nic without it IMO.
>
>>
>> Mode-1 "Shared": Application choose lowest isolation level, allowing
>>  multiple application to mmap VMA area.
>
> My only point here is applications can read each others data and all
> applications need to cooperate for example one app could try to write
> continuously to read only pages causing faults and what not. This is
> all non standard and doesn't play well with cgroups and "normal"
> applications. It requires a new orchestration model.
>
> I'm a bit skeptical of the use case but I know of a handful of reasons
> to use this model. Maybe take a look at the ivshmem implementation in
> DPDK.
>
> Also this still requires a hardware filter to push "application" traffic
> onto reserved queues/pages as far as I can tell.
>
>>
>> Mode-2 "Single-user": Application request it want to be the only user
>>  of the RX queue.  This blocks other application to mmap VMA area.
>>
>
> Assuming data is read-only sharing with the stack is possibly OK :/. I
> guess you would need to pools of memory for data and skb so you don't
> leak skb into user space.
>
> The devils in the details here. There are lots of hooks in the kernel
> that can for example push the packet with a 'redirect' tc action for
> example. And letting an app "read" data or impact performance of an
> unrelated application is wrong IMO. Stacked devices also provide another
> set of details that are a bit difficult to track down see all the
> hardware offload efforts.
>
> I assume all these concerns are shared between mode-1 and mode-2
>
>> Mode-3 "Exclusive": Application request to own RX queue.  Packets are
>>  no longer allowed for normal netstack delivery.
>>
>
> I have patches for this mode already but haven't pushed them due to
> an alternative solution using VFIO.
>
>> Notice mode-2 still requires CAP_NET_ADMIN, because packets/pages are
>> still allowed to travel netstack and thus can contain packet data from
>> other normal applications.  This is part of the design, to share the
>> NIC between netstack and an accelerated userspace application using RX
>> zero-copy delivery.
>>
>
> I don't think this is acceptable to be honest. Letting an application
> potentially read/impact other arbitrary applications on the system
> seems like a non-starter even with CAP_NET_ADMIN. At least this was
> the conclusion from bifurcated driver work some time ago.

I agree.  This is a no-go from the performance perspective as well.
At a minimum you would have to be zeroing out the page between uses to
avoid leaking data, and that assumes that the program we are sending
the pages to is slightly well behaved.  If we think zeroing out an
sk_buff is expensive wait until we are trying to do an entire 4K page.

I think we are stuck with having to use a HW filter to split off
application traffic to a specific ring, and then having to share the
memory between the application and the kernel on that ring only.  Any
other approach just opens us up to all sorts of security concerns
since it would be possible for the application to try to read and
possibly write any data it wants into the buffers.

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
