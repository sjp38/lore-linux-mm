From: Jitendra Kolhe <jitendra.kolhe@hpe.com>
Subject: [RFC qemu 0/4] A PV solution for live migration optimization
Date: Fri,  4 Mar 2016 15:02:47 +0530
Message-ID: <1457083967-13681-1-git-send-email-jitendra.kolhe@hpe.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
To: liang.z.li@intel.com, dgilbert@redhat.com
Cc: ehabkost@redhat.com, kvm@vger.kernel.org, mst@redhat.com, quintela@redhat.com, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, linux-mm@kvack.org, amit.shah@redhat.com, pbonzini@redhat.com, akpm@linux-foundation.org, virtualization@lists.linux-foundation.org, rth@twiddle.net, mohan_parthasarathy@hpe.com, jitendra.kolhe@hpe.com, simhan@hpe.com
List-Id: linux-mm.kvack.org

> >
> > * Liang Li (liang.z.li@intel.com) wrote:
> > > The current QEMU live migration implementation mark the all the
> > > guest's RAM pages as dirtied in the ram bulk stage, all these pages
> > > will be processed and that takes quit a lot of CPU cycles.
> > >
> > > From guest's point of view, it doesn't care about the content in free
> > > pages. We can make use of this fact and skip processing the free pages
> > > in the ram bulk stage, it can save a lot CPU cycles and reduce the
> > > network traffic significantly while speed up the live migration
> > > process obviously.
> > >
> > > This patch set is the QEMU side implementation.
> > >
> > > The virtio-balloon is extended so that QEMU can get the free pages
> > > information from the guest through virtio.
> > >
> > > After getting the free pages information (a bitmap), QEMU can use it
> > > to filter out the guest's free pages in the ram bulk stage. This make
> > > the live migration process much more efficient.
> >
> > Hi,
> >   An interesting solution; I know a few different people have been looking at
> > how to speed up ballooned VM migration.
> >
>
> Ooh, different solutions for the same purpose, and both based on the balloon.

We were also tying to address similar problem, without actually needing to modify
the guest driver. Please find patch details under mail with subject.
migration: skip sending ram pages released by virtio-balloon driver

Thanks,
- Jitendra

>
> >   I wonder if it would be possible to avoid the kernel changes by parsing
> > /proc/self/pagemap - if that can be used to detect unmapped/zero mapped
> > pages in the guest ram, would it achieve the same result?
> >
>
> Only detect the unmapped/zero mapped pages is not enough. Consider the
> situation like case 2, it can't achieve the same result.
>
> > > This RFC version doesn't take the post-copy and RDMA into
> > > consideration, maybe both of them can benefit from this PV solution by
> > > with some extra modifications.
> >
> > For postcopy to be safe, you would still need to send a message to the
> > destination telling it that there were zero pages, otherwise the destination
> > can't tell if it's supposed to request the page from the source or treat the
> > page as zero.
> >
> > Dave
>
> I will consider this later, thanks, Dave.
>
> Liang
>
> >
> > >
> > > Performance data
> > > ================
> > >
> > > Test environment:
> > >
> > > CPU: Intel (R) Xeon(R) CPU ES-2699 v3 @ 2.30GHz Host RAM: 64GB
> > > Host Linux Kernel:  4.2.0           Host OS: CentOS 7.1
> > > Guest Linux Kernel:  4.5.rc6        Guest OS: CentOS 6.6
> > > Network:  X540-AT2 with 10 Gigabit connection Guest RAM: 8GB
> > >
> > > Case 1: Idle guest just boots:
> > > ============================================
> > >                     | original  |    pv
> > > -------------------------------------------
> > > total time(ms)      |    1894   |   421
> > > --------------------------------------------
> > > transferred ram(KB) |   398017  |  353242
> > > ============================================
> > >
> > >
> > > Case 2: The guest has ever run some memory consuming workload, the
> > > workload is terminated just before live migration.
> > > ============================================
> > >                     | original  |    pv
> > > -------------------------------------------
> > > total time(ms)      |   7436    |   552
> > > --------------------------------------------
> > > transferred ram(KB) |  8146291  |  361375
> > > ============================================
> > >
>
>
