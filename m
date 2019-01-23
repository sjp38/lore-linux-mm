Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 890A48E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 18:05:03 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id t18so4499793qtj.3
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 15:05:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si2547370qvi.152.2019.01.23.15.05.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 15:05:02 -0800 (PST)
Date: Wed, 23 Jan 2019 18:04:47 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH v4 0/9] mmu notifier provide context informations
Message-ID: <20190123230447.GC1257@redhat.com>
References: <20190123222315.1122-1-jglisse@redhat.com>
 <CAPcyv4i9_T9779ZyaYt2T3b20-wQTaWA4P63+49TM=a=twtDVw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4i9_T9779ZyaYt2T3b20-wQTaWA4P63+49TM=a=twtDVw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, KVM list <kvm@vger.kernel.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-rdma <linux-rdma@vger.kernel.org>, John Hubbard <jhubbard@nvidia.com>, Felix Kuehling <Felix.Kuehling@amd.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Maling list - DRI developers <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@kernel.org>, Linux MM <linux-mm@kvack.org>, Jason Gunthorpe <jgg@mellanox.com>, Ross Zwisler <zwisler@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>

On Wed, Jan 23, 2019 at 02:54:40PM -0800, Dan Williams wrote:
> On Wed, Jan 23, 2019 at 2:23 PM <jglisse@redhat.com> wrote:
> >
> > From: Jérôme Glisse <jglisse@redhat.com>
> >
> > Hi Andrew, i see that you still have my event patch in you queue [1].
> > This patchset replace that single patch and is broken down in further
> > step so that it is easier to review and ascertain that no mistake were
> > made during mechanical changes. Here are the step:
> >
> >     Patch 1 - add the enum values
> >     Patch 2 - coccinelle semantic patch to convert all call site of
> >               mmu_notifier_range_init to default enum value and also
> >               to passing down the vma when it is available
> >     Patch 3 - update many call site to more accurate enum values
> >     Patch 4 - add the information to the mmu_notifier_range struct
> >     Patch 5 - helper to test if a range is updated to read only
> >
> > All the remaining patches are update to various driver to demonstrate
> > how this new information get use by device driver. I build tested
> > with make all and make all minus everything that enable mmu notifier
> > ie building with MMU_NOTIFIER=no. Also tested with some radeon,amd
> > gpu and intel gpu.
> >
> > If they are no objections i believe best plan would be to merge the
> > the first 5 patches (all mm changes) through your queue for 5.1 and
> > then to delay driver update to each individual driver tree for 5.2.
> > This will allow each individual device driver maintainer time to more
> > thouroughly test this more then my own testing.
> >
> > Note that i also intend to use this feature further in nouveau and
> > HMM down the road. I also expect that other user like KVM might be
> > interested into leveraging this new information to optimize some of
> > there secondary page table invalidation.
> 
> "Down the road" users should introduce the functionality they want to
> consume. The common concern with preemptively including
> forward-looking infrastructure is realizing later that the
> infrastructure is not needed, or needs changing. If it has no current
> consumer, leave it out.

This patchset already show that this is useful, what more can i do ?
I know i will use this information, in nouveau for memory policy we
allocate our own structure for every vma the GPU ever accessed or that
userspace hinted we should set a policy for. Right now with existing
mmu notifier i _must_ free those structure because i do not know if
the invalidation is an munmap or something else. So i am loosing
important informations and unecessarly free struct that i will have
to re-allocate just couple jiffies latter. That's one way i am using
this. The other way is to optimize GPU page table update just like i
am doing with all the patches to RDMA/ODP and various GPU drivers.


> > Here is an explaination on the rational for this patchset:
> >
> >
> > CPU page table update can happens for many reasons, not only as a result
> > of a syscall (munmap(), mprotect(), mremap(), madvise(), ...) but also
> > as a result of kernel activities (memory compression, reclaim, migration,
> > ...).
> >
> > This patch introduce a set of enums that can be associated with each of
> > the events triggering a mmu notifier. Latter patches take advantages of
> > those enum values.
> >
> > - UNMAP: munmap() or mremap()
> > - CLEAR: page table is cleared (migration, compaction, reclaim, ...)
> > - PROTECTION_VMA: change in access protections for the range
> > - PROTECTION_PAGE: change in access protections for page in the range
> > - SOFT_DIRTY: soft dirtyness tracking
> >
> > Being able to identify munmap() and mremap() from other reasons why the
> > page table is cleared is important to allow user of mmu notifier to
> > update their own internal tracking structure accordingly (on munmap or
> > mremap it is not longer needed to track range of virtual address as it
> > becomes invalid).
> 
> The only context information consumed in this patch set is
> MMU_NOTIFY_PROTECTION_VMA.
> 
> What is the practical benefit of these "optimize out the case when a
> range is updated to read only" optimizations? Any numbers to show this
> is worth the code thrash?

It depends on the workload for instance if you map to RDMA a file
read only like a log file for export, all write back that would
disrupt the RDMA mapping can be optimized out.

See above for more reasons why it is beneficial (knowing when it is
an munmap/mremap versus something else).

I would have not thought that passing down information as something
that controversial. Hopes this help you see the benefit of this.

Cheers,
Jérôme
