Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 8120B28000A
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 17:50:43 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id q107so6229249qgd.17
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 14:50:43 -0800 (PST)
Received: from mail-qg0-x233.google.com (mail-qg0-x233.google.com. [2607:f8b0:400d:c04::233])
        by mx.google.com with ESMTPS id 1si33611166qau.114.2014.11.10.14.50.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Nov 2014 14:50:42 -0800 (PST)
Received: by mail-qg0-f51.google.com with SMTP id j5so6199544qga.24
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 14:50:42 -0800 (PST)
Date: Mon, 10 Nov 2014 17:50:37 -0500
From: Jerome Glisse <j.glisse@gmail.com>
Subject: Re: [PATCH 3/5] lib: lockless generic and arch independent page
 table (gpt) v2.
Message-ID: <20141110225036.GB4186@gmail.com>
References: <1415644096-3513-1-git-send-email-j.glisse@gmail.com>
 <1415644096-3513-4-git-send-email-j.glisse@gmail.com>
 <CA+55aFwHd4QYopHvd=H6hxoQeqDV3HT6=436LGU-FRb5A0p7Vg@mail.gmail.com>
 <20141110205814.GA4186@gmail.com>
 <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFwwKV_D5oWT6a97a70G7OnvsPD_j9LsuR+_e4MEdCOO9A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>, Mel Gorman <mgorman@suse.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Rik van Riel <riel@redhat.com>, Dave Airlie <airlied@redhat.com>, Brendan Conoboy <blc@redhat.com>, Joe Donohue <jdonohue@redhat.com>, Duncan Poole <dpoole@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Lucien Dunning <ldunning@nvidia.com>, Cameron Buschardt <cabuschardt@nvidia.com>, Arvind Gopalakrishnan <arvindg@nvidia.com>, Shachar Raindel <raindel@mellanox.com>, Liran Liss <liranl@mellanox.com>, Roland Dreier <roland@purestorage.com>, Ben Sander <ben.sander@amd.com>, Greg Stoner <Greg.Stoner@amd.com>, John Bridgman <John.Bridgman@amd.com>, Michael Mantor <Michael.Mantor@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Laurent Morichetti <Laurent.Morichetti@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, Oded Gabbay <Oded.Gabbay@amd.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>

On Mon, Nov 10, 2014 at 01:35:24PM -0800, Linus Torvalds wrote:
> On Mon, Nov 10, 2014 at 12:58 PM, Jerome Glisse <j.glisse@gmail.com> wrote:
> > On Mon, Nov 10, 2014 at 12:22:03PM -0800, Linus Torvalds wrote:
> >
> > Also during Linux Plumber people working on IOMMU expressed there wish to
> > see some generic "page table" code that can be share among IOMMU as most
> > IOMMU use a page table directory hierarchy for mapping and it is not the
> > same as the one use by the CPU.
> 
> If that is the case, why can't it just use the same format as the CPU anyway?

I wish i could but GPU or IOMMU do have different page table and page directory
entry format. Some fields only make sense on GPU. Even if you look at Intel or
AMD IOMMU they use different format. The intention of my patch is to provide
common infrastructure code share page table management for different hw each
having different entry format.

> 
> You can create page tables that have the same format as the CPU, they
> just don't get loaded by the CPU.
> 
> Because quite frankly, I think that's where we want to end up in the
> end anyway. You want to be able to have a "struct mm_struct" that just
> happens to run on the GPU (or other accelerator). Then, the actual
> hardware tables (or whatever) end up acting like just a TLB of that
> tree. And in a perfect world, you can actually *share* the page
> tables, so that you can have CLONE_VM threads that simply run on the
> GPU, and if the CPU process exists, the normal ref-counting of the
> "struct mm_struct" will keep the page tables around.
> 
> Because if you *don't* do it that way, you'll always have to have
> these magical synchronization models between the two. Which is
> obviously what you're adding (the whole invalidation callbacks), but
> it really would be lovely if the "heterogeneous" memory model would
> aim to be a bit more homogeneous...

Again that would be my wish but this is sadly far from being possible.

First unlike CPU, GPU are control through a command buffer queue. Inside
the command buffer queue you schedule program to run (address of program
code and number of threads to spawn as well as others arguments) but you
also schedule things GPU page table update for specific process (group
of threads). Thus inherently you have no idea on how long a GPU page
table update will take, unlike on a CPU with TLB flush and IPI. So
code/cmd updating page table on GPU run on a distinct engine than where
the code actually using those page table is runing.

So scheduling GPU page table update require a fair amount of driver
work and also allocation of a slot inside the GPU command buffer queue.
Doing all this along side CPU TLB flush inside atomic section sounds
insane to me. It could block the CPU for long time nor even mentioning
the fact that bug in driver would have more chance to cripple more
severly core kernel code path.

Second, as i explained the memory bandwidth gap btw CPU and GPU keeps
growing. So GPU will keep having discret memory and it will keep being
only accessible to the GPU.

Even Intel finaly understood that GPU are all about bandwidth and while
their solution is let add some special insanely big and fast cache sounds
like the right way to go, it is not unless you are ready to have a cache
that is several gigabytes in size all coupled with insane heuristic
implemented in the mmu silicon to decide what should be inside that fast
cache and what should not.

So to take advantages of GPU memory you need to migrate what is in system
memory to GPU memory and for this you need different page table btw the CPU
and the GPU. Things that are migrated inside the GPU memory will have entry
pointing to it inside the GPU page table but same address will have special
entry inside the CPU page table.


This are the two main motivations for having distinct page table that still
needs to be synchronize with each others.


> 
> > I am not sure to which locking you are refering to here. The design is
> > to allow concurrent readers and faulters to operate at same time. For
> > this i need reader to ignore newly faulted|created directory. So during
> > table walk done there is a bit of trickery to achieve just that.
> 
> There's two different locking things I really don't like:
> 
> The USE_SPLIT_PTE_PTLOCKS thing is horrible for stuff like this. I
> really wouldn't want random library code digging into core data
> structures and random VM config options..
> 
> We do it for the VM, because we scale up to insane loads that do crazy
> things, and it matters deeply, and the VM is really really core. I
> have yet to see any reason to believe that the same kind of tricks are
> needed or appropriate here.

Some update to this secondary hw page table will happen on the CPU inside
the same code path as the CPU page table update (hidden inside the mmu
notifier callback). Hence why i would like to have the same kind of
scalability where i do have a spinlock per directory allowing concurrent
updates to disjoint address range.

> 
> And the "test_bit(i, wlock->locked)" kind of thing is also
> unacceptable, because your "locks" aren't - you don't actually do the
> lock acquire/release ordering for those things at all, and you test
> them without any synchronization what-so-ever that I can see.

As explained the test_bit is not use for synchronization whatsoever, the
wlock name is missleading here. It is use as a flag : was this entry
modified by previous loop. All inside one CPU thread and never share
with other thread. This is not use as synchronization btw different
CPU thread at all. I understand that this code might be hard to read
and that name of the variable is somewhat missleading.

> 
> > Update to page directory are synchronize through the spinlock of each
> > page backing a directory this is why i rely on that option. As explained
> > above i am trying to adapt the design of CPU page table to other hw page
> > table. The only difference is that the page directory entry and the page
> > table entry are different from the CPU and vary from one hw to the other.
> 
> So quite frankly, I think it's wrong.
> 
> Either use the CPU page tables (just don't *load* them on the CPU), or
> don't try to claim they are page tables. I really think you shouldn't
> mix things up and confuse the issue. They aren't page tables. They
> can't even match any particular piece of hardware, since the different
> non-CPU "page tables" in the system are just basically random - the
> mapping that a GPU uses may look very different from the mappings that
> an IOMMU uses. So unlike the real VM page tables that the VM uses that
> *try* to actually match the hardware if at all possible, a
> device-specific page table very much will be still tied to the device.

As explained above i can not reuse the CPU page table first because the
entry format is hw dependant second because i want to have different
content btw the GPU and CPU page table for memory migration.

> 
> Or am I reading something wrong? Because that's what it looks like
> from my reading: your code is written for *some* things to be
> dynamically configurable for the sizes of the levels (as 64-bit values
> for the shift count? WTF? That's just psychedelic and seems insane)
> but a lot seems to be tied to the VM page size and you use the lock in
> the page for the page directories, so it doesn't seem like you can
> actually ever do the same kind of "match and share the physical
> memory" that we do with the VM page tables.

It is like to page size because page size on arch we care about is 4k
and GPU page table for all hw i care about is also using the magic 4k
value. This might very well be false on some future hw and it would then
need to be untie from the VM page size.

The whole magic shift things is because a 32bit arch might be pair with
a GPU that have 64bit entry. The whole point of this patch is to provide
common code to walk and update a hw page table from the CPU and allowing
concurrent update of that hw page table. So instead of having each single
device driver implement its own code for page table walk and management
and implement its own synchronization for update i try hear to provide a
framework with those 2 features that can be share no matter what is the
format of entry use by the hardware.

> 
> So it still looks like just a radix tree to me. With some
> configuration options for the size of the elements, but not really to
> share the actual page tables with any real hardware (iommu or gpu or
> whatever).

So as i said above i would want to update some of this page table from
CPU and thus i would like to be able share page table walk and locking
among different devices. And i believe IOMMU folks would like to do so
too, ie share page table walk and locking as common code and everything
else as hw specific code.

> 
> Or do you actually have a setup where actual non-CPU hardware actually
> walks the page tables you create and call "page tables"?

Yes that's my point, hw will walk those page table but CPU would manipulate
them. So the format of the entry is dictated by the hw but the way to
update those and to walk them on the CPU can be done through common code.

Cheers,
Jerome

> 
>                                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
