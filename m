Received: by wa-out-1112.google.com with SMTP id m33so823438wag.8
        for <linux-mm@kvack.org>; Thu, 14 Feb 2008 09:48:53 -0800 (PST)
Message-ID: <469958e00802140948j162cc8baqae0b55cd6fb1cd22@mail.gmail.com>
Date: Thu, 14 Feb 2008 09:48:52 -0800
From: "Caitlin Bestler" <caitlin.bestler@gmail.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
In-Reply-To: <47B46AFB.9070009@opengridcomputing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <adazlu5vlub.fsf@cisco.com>
	 <8A71B368A89016469F72CD08050AD334026D5C23@maui.asicdesigners.com>
	 <47B45994.7010805@opengridcomputing.com>
	 <20080214155333.GA1029@sgi.com>
	 <47B46AFB.9070009@opengridcomputing.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steve Wise <swise@opengridcomputing.com>
Cc: Robin Holt <holt@sgi.com>, Rik van Riel <riel@redhat.com>, steiner@sgi.com, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, linux-kernel@vger.kernel.org, avi@qumranet.com, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, daniel.blueman@quadrics.com, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 14, 2008 at 8:23 AM, Steve Wise <swise@opengridcomputing.com> wrote:
> Robin Holt wrote:
>  > On Thu, Feb 14, 2008 at 09:09:08AM -0600, Steve Wise wrote:
>  >> Note that for T3, this involves suspending _all_ rdma connections that are
>  >> in the same PD as the MR being remapped.  This is because the driver
>  >> doesn't know who the application advertised the rkey/stag to.  So without
>  >
>  > Is there a reason the driver can not track these.
>  >
>
>  Because advertising of a MR (ie telling the peer about your rkey/stag,
>  offset and length) is application-specific and can be done out of band,
>  or in band as simple SEND/RECV payload. Either way, the driver has no
>  way of tracking this because the protocol used is application-specific.
>
>

I fully agree. If there is one important thing about RDMA and other fastpath
solutions that must be understood is that the driver does not see the
payload. This is a fundamental strength, but it means that you have
to identify what if any intercept points there are in advance.

You also raise a good point on the scope of any suspend/resume API.
Device reporting of this capability would not be a simple boolean, but
more of a suspend/resume scope. A minimal scope would be any
connection that actually attempts to use the suspended MR. Slightly
wider would be any connection *allowed* to use the MR, which could
expand all the way to any connection under the same PD. Convievably
I could imagine an RDMA device reporting that it could support suspend/
resume, but only at the scope of the entire device.

But even at such a wide scope, suspend/resume could be useful to
a Memory Manager. The pages could be fully migrated to the new
location, and the only work that was still required during the critical
suspend/resume region was to actually shift to the new map. That
might be short enough that not accepting *any* incoming RDMA
packet would be acceptable.

And if the goal is to replace a memory card the alternative might
be migrating the applications to other physical servers, which would
mean a much longer period of not accepting incoming RDMA packets.

But the broader question is what the goal is here. Allowing memory to
be shuffled is valuable, and perhaps even ultimately a requirement for
high availability systems. RDMA and other direct-access APIs should
be evolving their interfaces to accommodate these needs.

Oversubscribing memory is a totally different matter. If an application
is working with memory that is oversubscribed by a factor of 2 or more
can it really benefit from zero-copy direct placement? At first glance I
can't see what RDMA could be bringing of value when the overhead of
swapping is going to be that large.

If it really does make sense, then explicitly registering the portion of
memory that should be enabled to receive incoming traffic while the
application is swapped out actually makes sense.

Current Memory Registration methods force applications to either
register too much or too often. They register too much when the cost
of registration is high, and the application responds by registering its
entire buffer pool permanently. This is a problem when it overstates
the amount of memory that the application needs to have resident,
or when the device imposes limits on the size of memory maps that
it can know. The alternative is to register too often, that is on a
per-operation basis.

To me that suggests the solutions lie in making it more reasonable
to register more memory, or in making it practical to register memory
on-the-fly on a per-operation basis with low enough overhead that
applications don't feel the need to build elaborate registration caching
schemes.

As has been pointed out a few times in this thread, the RDMA and
transport layers simply do not have enough information to know which
portion of registered memory *really* had to be registered. So any
back-pressure scheme where the Memory Manager is asking for
pinned memory to be "given back" would have to go all the way to
the application. Only the application knows what it is "really" using.

I also suspect that most applications that are interested in using
RDMA would rather be told they can allocate 200M indefinitely
(and with real memory backing it) than be given 1GB of virtual
memory that is backed by 200-300M of physical memory,
especially if it meant dealing with memory pressure upcalls.

>  >> Point being, it will stop probably all connections that an application is
>  >> using (assuming the application uses a single PD).
>  >
>  > It seems like the need to not stop all would be a compelling enough reason
>  > to modify the driver to track which processes have received the rkey/stag.
>  >
>
>  Yes, _if_ the driver could track this.
>
>  And _if_ the rdma API and paradigm was such that the kernel/driver could
>  keep track, then remote revokations of MR tags could be supported.
>
>  Stevo
>
>
> _______________________________________________
>  general mailing list
>  general@lists.openfabrics.org
>  http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general
>
>  To unsubscribe, please visit http://openib.org/mailman/listinfo/openib-general
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
