Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B3E546B004D
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:40:17 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <636843ec-b290-4ea9-b629-1d364f3b1112@default>
Date: Mon, 22 Jun 2009 13:41:19 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <20090622132702.6638d841@skybase>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, jeremy@goop.org, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

> > Tmem has some similarity to IBM's Collaborative Memory Management,
> > but creates more of a partnership between the kernel and the
> > "privileged entity" and is not very invasive.  Tmem may be
> > applicable for KVM and containers; there is some disagreement on
> > the extent of its value. Tmem is highly complementary to ballooning
> > (aka page granularity hot plug) and memory deduplication (aka
> > transparent content-based page sharing) but still has value
> > when neither are present.

Hi Martin --

Thanks much for taking the time to reply!

> The basic idea seems to be that you reduce the amount of memory
> available to the guest and as a compensation give the guest some
> tmem, no?

That's mostly right.  Tmem's primary role is to help
with guests that have had their available memory reduced
(via ballooning or hotplug or some future mechanism).
However tmem additionally provides a way of providing otherwise
unused-by-the-hypervisor ("fallow") memory to a guest,
essentially expanding a guest kernel's page cache if
no other guest is using the RAM anyway.

And "as a compensation GIVE the guest some tmem" is misleading,
because tmem (at least ephemeral tmem) is never "given"
to a guest.  A better word might be "loaned" or "rented".
The guest gets to use some tmem for awhile but if it
doesn't use it effectively, the memory is "repossessed"
(or the guest is "evicted" from using that memory)
transparently so that it can be used more effectively
elsewhere.

> If that is the case then the effect of tmem is somewhat
> comparable to the volatile page cache pages.

There is definitely some similarity in that both are providing
useful information to the hypervisor.  In CMM's case, the
guest is passively providing info; in tmem's case it is
actively providing info and making use of the info within
the kernel, not just in the hypervsior, which is why I described it
as "more of a partnership".

> The big advantage of this approach is its simplicity, but there
> are down sides as well:
> 1) You need to copy the data between the tmem pool and the page
> cache. At least temporarily there are two copies of the same
> page around. That increases the total amount of used memory.

Certainly this is theoretically true, but I think the increase
is small and transient.  The kernel only puts the page into
precache when it has decided to use that page for another
purpose (due to memory pressure).  Until it actually
"reprovisions" the page, the data is briefly duplicated.

On the other hand, copying eliminates the need for fancy
games with virtual mappings and TLB entries.  Copying appears
to be getting much faster on recent CPUs; I'm not sure
if this is also true of TLB operations.

> 2) The guest has a smaller memory size. Either the memory is
> large enough for the working set size in which case tmem is
> ineffective...

Yes, if the kernel has memory to "waste" (e.g. never refaults and
never swaps), tmem is ineffective.  The goal of tmem is to optimize
memory usage across an environment where there is contention
among multiple users (guests) for a limited resource (RAM).
If your environment always has enough RAM for every guest
and there's never any contention, you don't want tmem... but
I'd assert you've wasted money in your data center by buying
too much RAM!

> or the working set does not fit which increases
> the memory pressure and the cpu cycles spent in the mm code.

True, this is where preswap is useful.  Without tmem/preswap,
"does not fit" means swap-to-disk or refaulting is required.
Preswap alleviates the memory pressure by using tmem to
essentially swap to "magic memory" and precache reduces the
need for refaulting.

> 3) There is an additional turning knob, the size of the tmem pool
> for the guest. I see the need for a clever algorithm to determine
> the size for the different tmem pools.

Yes, some policy in the hypervisor is still required, essentially
a "memory scheduler".  The working implementation (in Xen)
uses FIFO, but modified by admin-configurable "weight" values
to allow QoS and avoid DoS.=20

> Overall I would say its worthwhile to investigate the performance
> impacts of the approach.

Thanks.  I'd appreciate any thoughts or experience you have
in this area (onlist or offlist) as I don't think there are
any adequate benchmarks that aren't either myopic for a complex
environment or contrived (and thus misleading) to prove an
isolated point.

I would also guess that tmem is more beneficial on recent
multi-core processors, and more costly on older chips.

Thanks again,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
