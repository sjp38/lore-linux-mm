Date: Wed, 13 Feb 2008 18:23:08 -0500
From: Pete Wyckoff <pw@osc.edu>
Subject: Re: [ofa-general] Re: Demand paging for memory regions
Message-ID: <20080213232308.GB7597@osc.edu>
References: <Pine.LNX.4.64.0802091345490.12965@schroedinger.engr.sgi.com> <ada3arzxgkz.fsf_-_@cisco.com> <47B2174E.5000708@opengridcomputing.com> <Pine.LNX.4.64.0802121408150.9591@schroedinger.engr.sgi.com> <adazlu5vlub.fsf@cisco.com> <20080212232329.GC31435@obsidianresearch.com> <Pine.LNX.4.64.0802121657430.11628@schroedinger.engr.sgi.com> <20080213012638.GD31435@obsidianresearch.com> <Pine.LNX.4.64.0802121819530.12328@schroedinger.engr.sgi.com> <20080213040905.GQ29340@mv.qlogic.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080213040905.GQ29340@mv.qlogic.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Christian Bell <christian.bell@qlogic.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <andrea@qumranet.com>, a.p.zijlstra@chello.nl, izike@qumranet.com, Roland Dreier <rdreier@cisco.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, avi@qumranet.com, linux-mm@kvack.org, daniel.blueman@quadrics.com, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Andrew Morton <akpm@linux-foundation.org>, kvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

christian.bell@qlogic.com wrote on Tue, 12 Feb 2008 20:09 -0800:
> One other area that has not been brought up yet (I think) is the
> applicability of notifiers in letting users know when pinned memory
> is reclaimed by the kernel.  This is useful when a lower-level
> library employs lazy deregistration strategies on memory regions that
> are subsequently released to the kernel via the application's use of
> munmap or sbrk.  Ohio Supercomputing Center has work in this area but
> a generalized approach in the kernel would certainly be welcome.

The whole need for memory registration is a giant pain.  There is no
motivating application need for it---it is simply a hack around
virtual memory and the lack of full VM support in current hardware.
There are real hardware issues that interact poorly with virtual
memory, as discussed previously in this thread.

The way a messaging cycle goes in IB is:

    register buf
    post send from buf
    wait for completion
    deregister buf

This tends to get hidden via userspace software libraries into
a single call:

    MPI_send(buf)

Now if you actually do the reg/dereg every time, things are very
slow.  So userspace library writers came up with the idea of caching
registrations:

    if buf is not registered:
	register buf
    post send from buf
    wait for completion

The second time that the app happens to do a send from the same
buffer, it proceeds much faster.  Spatial locality applies here, and
this caching is generally worth it.  Some libraries have schemes to
limit the size of the registration cache too.

But there are plenty of ways to hurt yourself with such a scheme.
The first being a huge pool of unused but registered memory, as the
library doesn't know the app patterns, and it doesn't know the VM
pressure level in the kernel.

There are plenty of subtle ways that this breaks too.  If the
registered buf is removed from the address space via munmap() or
sbrk() or other ways, the mapping and registration are gone, but the
library has no way of knowing that the app just did this.  Sure the
physical page is still there and pinned, but the app cannot get at
it.  Later if new address space arrives at the same virtual address
but a different physical page, the library will mistakenly think it
already has it registered properly, and data is transferred from
this old now-unmapped physical page.

The whole situation is rather ridiculuous, but we are quite stuck
with it for current generation IB and iWarp hardware.  If we can't
have the kernel interact with the device directly, we could at least
manage state in these multiple userspace registration caches.  The
VM could ask for certain (or any) pages to be released, and the
library would respond if they are indeed not in use by the device.
The app itself does not know about pinned regions, and the library
is aware of exactly which regions are potentially in use.

Since the great majority of userspace messaging over IB goes through
middleware like MPI or PGAS languages, and they all have the same
approach to registration caching, this approach could fix the
problem for a big segment of use cases.

More text on the registration caching problem is here:

    http://www.osc.edu/~pw/papers/wyckoff-memreg-ccgrid05.pdf

with an approach using vm_ops open and close operations in a kernel
module here:

    http://www.osc.edu/~pw/dreg/

There is a place for VM notifiers in RDMA messaging, but not in
talking to devices, at least not the current set.  If you can define
a reasonable userspace interface for VM notifiers, libraries can
manage registration caches more efficiently, letting the kernel
unmap pinned pages as it likes.

		-- Pete

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
