Date: Thu, 14 Feb 2008 01:56:54 +0100
From: Andrea Arcangeli <andrea@qumranet.com>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080214005653.GE14146@v2.random>
References: <Pine.LNX.4.64.0802131452410.22542@schroedinger.engr.sgi.com> <866658.37093.qm@web32510.mail.mud.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <866658.37093.qm@web32510.mail.mud.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Christoph Lameter <clameter@sgi.com>, Christian Bell <christian.bell@qlogic.com>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Rik van Riel <riel@redhat.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi Kanoj,

On Wed, Feb 13, 2008 at 03:43:17PM -0800, Kanoj Sarcar wrote:
> Oh ok, yes, I did see the discussion on this; sorry I
> missed it. I do see what notifiers bring to the table
> now (without endorsing it :-)).

I'm not really livelocks are really the big issue here.

I'm running N 1G VM on a 1G ram system, with N-1G swapped
out. Combining this with auto-ballooning, rss limiting, and ksm ram
sharing, provides really advanced and lowlevel virtualization VM
capabilities to the linux kernel while at the same time guaranteeing
no oom failures as long as the guest pages are lower than ram+swap
(just slower runtime if too many pages are unshared or if the balloons
are deflated etc..).

Swapping the virtual machine in the host may be more efficient than
having the guest swapping over a virtual swap paravirt storage for
example. As more management features are added admins will gain more
experience in handling those new features and they'll find what's best
for them. mmu notifiers and real reliable swapping are the enabler for
those more advanced VM features.

oom livelocks wouldn't happen anyway with KVM as long as the maximimal
number of guest physical is lower than RAM.

> An orthogonal question is this: is IB/rdma the only
> "culprit" that elevates page refcounts? Are there no
> other subsystems which do a similar thing?
> 
> The example I am thinking about is rawio (Oracle's
> mlock'ed SHM regions are handed to rawio, isn't it?).
> My understanding of how rawio works in Linux is quite
> dated though ...

rawio in flight I/O shall be limited. As long as each task can't pin
more than X ram, and the ram is released when the task is oom killed,
and the first get_user_pages/alloc_pages/slab_alloc that returns
-ENOMEM takes an oom fail path that returns failure to userland,
everything is ok.

Even with IB deadlock could only happen if IB would allow unlimited
memory to be pinned down by unprivileged users.

If IB is insecure and DoSable without mmu notifiers, then I'm not sure
how enabling swapping of the IB memory could be enough to fix the
DoS. Keep in mind that even tmpfs can't be safe allowing all ram+swap
to be allocated in a tmpfs file (despite the tmpfs file storage
includes swap and not only ram). Pinning the whole ram+swap with tmpfs
livelocks the same way of pinning the whole ram with ramfs. So if you
add mmu notifier support to IB, you only need to RDMA an area as large
as ram+swap to livelock again as before... no difference at all.

I don't think livelocks have anything to do with mmu notifiers (other
than to deferring the livelock to the "swap+ram" point of no return
instead of the current "ram" point of no return). Livelocks have to be
solved the usual way: handling alloc_pages/get_user_pages/slab
allocation failures with a fail path that returns to userland and
allows the ram to be released if the task was selected for
oom-killage.

The real benefit of the mmu notifiers for IB would be to allow the
rdma region to be larger than RAM without triggering the oom
killer (or without triggering a livelock if it's DoSable but then the
livelock would need fixing to be converted in a regular oom-killing by
some other mean not related to the mmu-notifier, it's really an
orthogonal problem).

So suppose you've a MPI simulation that requires a 10G array and
you've only 1G of ram, then you can rdma over 10G like if you had 10G
of ram. Things will preform ok only if there's some huge locality of
the computations. For virtualization it's orders of magnitude more
useful than for computer clusters but certain simulations really swaps
so I don't exclude certain RDMA apps will also need this (dunno about
IB).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
