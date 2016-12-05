Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 49CCD6B0038
	for <linux-mm@kvack.org>; Mon,  5 Dec 2016 09:31:40 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id m67so265625229qkf.0
        for <linux-mm@kvack.org>; Mon, 05 Dec 2016 06:31:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h24si8992059qtf.266.2016.12.05.06.31.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Dec 2016 06:31:39 -0800 (PST)
Date: Mon, 5 Dec 2016 15:31:32 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Designing a safe RX-zero-copy Memory Model for Networking
Message-ID: <20161205153132.283fcb0e@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Cc: brouer@redhat.com, linux-mm <linux-mm@kvack.org>, John Fastabend <john.fastabend@gmail.com>, Willem de Bruijn <willemdebruijn.kernel@gmail.com>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>, "Karlsson, Magnus" <magnus.karlsson@intel.com>, Alexander Duyck <alexander.duyck@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Tom Herbert <tom@herbertland.com>, Brenden Blanco <bblanco@plumgrid.com>, Tariq Toukan <tariqt@mellanox.com>, Saeed Mahameed <saeedm@mellanox.com>, Jesse Brandeburg <jesse.brandeburg@intel.com>

Hi all,

This is my design for how to safely handle RX zero-copy in the network
stack, by using page_pool[1] and modifying NIC drivers.  Safely means
not leaking kernel info in pages mapped to userspace and resilience
so a malicious userspace app cannot crash the kernel.

It is only a design, and thus the purpose is for you to find any holes
in this design ;-)  Below text is also available as html see[2].

[1] https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/d=
esign.html
[2] https://prototype-kernel.readthedocs.io/en/latest/vm/page_pool/design/m=
emory_model_nic.html

=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
Memory Model for Networking
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D

This design describes how the page_pool change the memory model for
networking in the NIC (Network Interface Card) drivers.

.. Note:: The catch for driver developers is that, once an application
          request zero-copy RX, then the driver must use a specific
          SKB allocation mode and might have to reconfigure the
          RX-ring.

Design target
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Allow the NIC to function as a normal Linux NIC and be shared in a
safe manor, between the kernel network stack and an accelerated
userspace application using RX zero-copy delivery.

Target is to provide the basis for building RX zero-copy solutions in
a memory safe manor.  An efficient communication channel for userspace
delivery is out of scope for this document, but OOM considerations are
discussed below (`Userspace delivery and OOM`_).

Background
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

The SKB or ``struct sk_buff`` is the fundamental meta-data structure
for network packets in the Linux Kernel network stack.  It is a fairly
complex object and can be constructed in several ways.

=46rom a memory perspective there are two ways depending on
RX-buffer/page state:

1) Writable packet page
2) Read-only packet page

To take full potential of the page_pool, the drivers must actually
support handling both options depending on the configuration state of
the page_pool.

Writable packet page
--------------------

When the RX packet page is writable, the SKB setup is fairly straight
forward.  The SKB->data (and skb->head) can point directly to the page
data, adjusting the offset according to drivers headroom (for adding
headers) and setting the length according to the DMA descriptor info.

The page/data need to be writable, because the network stack need to
adjust headers (like TimeToLive and checksum) or even add or remove
headers for encapsulation purposes.

A subtle catch, which also requires a writable page, is that the SKB
also have an accompanying "shared info" data-structure ``struct
skb_shared_info``.  This "skb_shared_info" is written into the
skb->data memory area at the end (skb->end) of the (header) data.  The
skb_shared_info contains semi-sensitive information, like kernel
memory pointers to other pages (which might be pointers to more packet
data).  This would be bad from a zero-copy point of view to leak this
kind of information.

Read-only packet page
---------------------

When the RX packet page is read-only, the construction of the SKB is
significantly more complicated and even involves one more memory
allocation.

1) Allocate a new separate writable memory area, and point skb->data
   here.  This is needed due to (above described) skb_shared_info.

2) Memcpy packet headers into this (skb->data) area.

3) Clear part of skb_shared_info struct in writable-area.

4) Setup pointer to packet-data in the page (in skb_shared_info->frags)
   and adjust the page_offset to be past the headers just copied.

It is useful (later) that the network stack have this notion that part
of the packet and a page can be read-only.  This implies that the
kernel will not "pollute" this memory with any sensitive information.
This is good from a zero-copy point of view, but bad from a
performance perspective.


NIC RX Zero-Copy
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

Doing NIC RX zero-copy involves mapping RX pages into userspace.  This
involves costly mapping and unmapping operations in the address space
of the userspace process.  Plus for doing this safely, the page memory
need to be cleared before using it, to avoid leaking kernel
information to userspace, also a costly operation.  The page_pool base
"class" of optimization is moving these kind of operations out of the
fastpath, by recycling and lifetime control.

Once a NIC RX-queue's page_pool have been configured for zero-copy
into userspace, then can packets still be allowed to travel the normal
stack?

Yes, this should be possible, because the driver can use the
SKB-read-only mode, which avoids polluting the page data with
kernel-side sensitive data.  This implies, when a driver RX-queue
switch page_pool to RX-zero-copy mode it MUST also switch to
SKB-read-only mode (for normal stack delivery for this RXq).

XDP can be used for controlling which pages that gets RX zero-copied
to userspace.  The page is still writable for the XDP program, but
read-only for normal stack delivery.


Kernel safety
-------------

For the paranoid, how do we protect the kernel from a malicious
userspace program.  Sure there will be a communication interface
between kernel and userspace, that synchronize ownership of pages.
But a userspace program can violate this interface, given pages are
kept VMA mapped, the program can in principle access all the memory
pages in the given page_pool.  This opens up for a malicious (or
defect) program modifying memory pages concurrently with the kernel
and DMA engine using them.

An easy way to get around userspace modifying page data contents is
simply to map pages read-only into userspace.

.. Note:: The first implementation target is read-only zero-copy RX
          page to userspace and require driver to use SKB-read-only
          mode.

Advanced: Allowing userspace write access?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

What if userspace need write access? Flipping the page permissions per
transfer will likely kill performance (as this likely affects the
TLB-cache).

I will argue that giving userspace write access is still possible,
without risking a kernel crash.  This is related to the SKB-read-only
mode that copies the packet headers (in to another memory area,
inaccessible to userspace).  The attack angle is to modify packet
headers after they passed some kernel network stack validation step
(as once headers are copied they are out of "reach").

Situation classes where memory page can be modified concurrently:

1) When DMA engine owns the page.  Not a problem, as DMA engine will
   simply overwrite data.

2) Just after DMA engine finish writing.  Not a problem, the packet
   will go through netstack validation and be rejected.

3) While XDP reads data. This can lead to XDP/eBPF program goes into a
   wrong code branch, but the eBPF virtual machine should not be able
   to crash the kernel. The worst outcome is a wrong or invalid XDP
   return code.

4) Before SKB with read-only page is constructed. Not a problem, the
   packet will go through netstack validation and be rejected.

5) After SKB with read-only page has been constructed.  Remember the
   packet headers were copied into a separate memory area, and the
   page data is pointed to with an offset passed the copied headers.
   Thus, userspace cannot modify the headers used for netstack
   validation.  It can only modify packet data contents, which is less
   critical as it cannot crash the kernel, and eventually this will be
   caught by packet checksum validation.

6) After netstack delivered packet to another userspace process. Not a
   problem, as it cannot crash the kernel.  It might corrupt
   packet-data being read by another userspace process, which one
   argument for requiring elevated privileges to get write access
   (like NET_CAP_ADMIN).


Userspace delivery and OOM
--------------------------

These RX pages are likely mapped to userspace via mmap(), so-far so
good.  It is key to performance to get an efficient way of signaling
between kernel and userspace, e.g what page are ready for consumption,
and when userspace are done with the page.

It is outside the scope of page_pool to provide such a queuing
structure, but the page_pool can offer some means of protecting the
system resource usage.  It is a classical problem that resources
(e.g. the page) must be returned in a timely manor, else the system,
in this case, will run out of memory.  Any system/design with
unbounded memory allocation can lead to Out-Of-Memory (OOM)
situations.

Communication between kernel and userspace is likely going to be some
kind of queue.  Given transferring packets individually will have too
much scheduling overhead.  A queue can implicitly function as a
bulking interface, and offers a natural way to split the workload
across CPU cores.

This essentially boils down-to a two queue system, with the RX-ring
queue and the userspace delivery queue.

Two bad situations exists for the userspace queue:

1) Userspace is not consuming objects fast-enough. This should simply
   result in packets getting dropped when enqueueing to a full
   userspace queue (as queue *must* implement some limit). Open
   question is; should this be reported or communicated to userspace.

2) Userspace is consuming objects fast, but not returning them in a
   timely manor.  This is a bad situation, because it threatens the
   system stability as it can lead to OOM.

The page_pool should somehow protect the system in case 2.  The
page_pool can detect the situation as it is able to track the number
of outstanding pages, due to the recycle feedback loop.  Thus, the
page_pool can have some configurable limit of allowed outstanding
pages, which can protect the system against OOM.

Note, the `Fbufs paper`_ propose to solve case 2 by allowing these
pages to be "pageable", i.e. swap-able, but that is not an option for
the page_pool as these pages are DMA mapped.

.. _`Fbufs paper`:
   http://citeseer.ist.psu.edu/viewdoc/summary?doi=3D10.1.1.52.9688

Effect of blocking allocation
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The effect of page_pool, in case 2, that denies more allocations
essentially result-in the RX-ring queue cannot be refilled and HW
starts dropping packets due to "out-of-buffers".  For NICs with
several HW RX-queues, this can be limited to a subset of queues (and
admin can control which RX queue with HW filters).

The question is if the page_pool can do something smarter in this
case, to signal the consumers of these pages, before the maximum limit
is hit (of allowed outstanding packets).  The MM-subsystem already
have a concept of emergency PFMEMALLOC reserves and associate
page-flags (e.g. page_is_pfmemalloc).  And the network stack already
handle and react to this.  Could the same PFMEMALLOC system be used
for marking pages when limit is close?

This requires further analysis. One can imagine; this could be used at
RX by XDP to mitigate the situation by dropping less-important frames.
Given XDP choose which pages are being send to userspace it might have
appropriate knowledge of what it relevant to drop(?).

.. Note:: An alternative idea is using a data-structure that blocks
          userspace from getting new pages before returning some.
          (out of scope for the page_pool)

--
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

Above document is taken at GitHub commit 47fa7c844f48fab8b
 https://github.com/netoptimizer/prototype-kernel/commit/47fa7c844f48fab8b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
