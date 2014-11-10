Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 402D7280025
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 16:35:26 -0500 (EST)
Received: by mail-yk0-f173.google.com with SMTP id 20so4585014yks.4
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 13:35:25 -0800 (PST)
Received: from mail-yh0-x22d.google.com (mail-yh0-x22d.google.com. [2607:f8b0:4002:c01::22d])
        by mx.google.com with ESMTPS id y2si20103663yhc.167.2014.11.10.13.35.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 13:35:25 -0800 (PST)
Received: by mail-yh0-f45.google.com with SMTP id f73so1682771yha.4
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 13:35:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141110205814.GA4186@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
	<1415644096-3513-4-git-send-email-j.glisse@gmail.com>
	<CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
	<20141110205814.GA4186@gmail.com>
Date: Mon, 10 Nov 2014 13:35:24 -0800
Message-ID: <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page table
 (gpt) v2.
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 12:58 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> On Mon, Nov 10, 2014 at 12:22:03PM -0800, Linus Torvalds wrote:
>
> Also during Linux Plumber people working on IOMMU expressed there wish to
> see some generic "page table" code that can be share among IOMMU as most
> IOMMU use a page table directory hierarchy for mapping and it is not the
> same as the one use by the CPU.

If that is the case, why can't it just use the same format as the CPU anyway?

You can create page tables that have the same format as the CPU, they
just don't get loaded by the CPU.

Because quite frankly, I think that's where we want to end up in the
end anyway. You want to be able to have a "struct mm_struct" that just
happens to run on the GPU (or other accelerator). Then, the actual
hardware tables (or whatever) end up acting like just a TLB of that
tree. And in a perfect world, you can actually *share* the page
tables, so that you can have CLONE_VM threads that simply run on the
GPU, and if the CPU process exists, the normal ref-counting of the
"struct mm_struct" will keep the page tables around.

Because if you *don't* do it that way, you'll always have to have
these magical synchronization models between the two. Which is
obviously what you're adding (the whole invalidation callbacks), but
it really would be lovely if the "heterogeneous" memory model would
aim to be a bit more homogeneous...

> I am not sure to which locking you are refering to here. The design is
> to allow concurrent readers and faulters to operate at same time. For
> this i need reader to ignore newly faulted|created directory. So during
> table walk done there is a bit of trickery to achieve just that.

There's two different locking things I really don't like:

The USE_SPLIT_PTE_PTLOCKS thing is horrible for stuff like this. I
really wouldn't want random library code digging into core data
structures and random VM config options..

We do it for the VM, because we scale up to insane loads that do crazy
things, and it matters deeply, and the VM is really really core. I
have yet to see any reason to believe that the same kind of tricks are
needed or appropriate here.

And the "test_bit(i, wlock->locked)" kind of thing is also
unacceptable, because your "locks" aren't - you don't actually do the
lock acquire/release ordering for those things at all, and you test
them without any synchronization what-so-ever that I can see.

> Update to page directory are synchronize through the spinlock of each
> page backing a directory this is why i rely on that option. As explained
> above i am trying to adapt the design of CPU page table to other hw page
> table. The only difference is that the page directory entry and the page
> table entry are different from the CPU and vary from one hw to the other.

So quite frankly, I think it's wrong.

Either use the CPU page tables (just don't *load* them on the CPU), or
don't try to claim they are page tables. I really think you shouldn't
mix things up and confuse the issue. They aren't page tables. They
can't even match any particular piece of hardware, since the different
non-CPU "page tables" in the system are just basically random - the
mapping that a GPU uses may look very different from the mappings that
an IOMMU uses. So unlike the real VM page tables that the VM uses that
*try* to actually match the hardware if at all possible, a
device-specific page table very much will be still tied to the device.

Or am I reading something wrong? Because that's what it looks like
from my reading: your code is written for *some* things to be
dynamically configurable for the sizes of the levels (as 64-bit values
for the shift count? WTF? That's just psychedelic and seems insane)
but a lot seems to be tied to the VM page size and you use the lock in
the page for the page directories, so it doesn't seem like you can
actually ever do the same kind of "match and share the physical
memory" that we do with the VM page tables.

So it still looks like just a radix tree to me. With some
configuration options for the size of the elements, but not really to
share the actual page tables with any real hardware (iommu or gpu or
whatever).

Or do you actually have a setup where actual non-CPU hardware actually
walks the page tables you create and call "page tables"?

                               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
