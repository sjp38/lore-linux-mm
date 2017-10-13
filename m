Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9F76B0253
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 14:22:25 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id f66so6783089oib.4
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 11:22:25 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b3sor624983otb.186.2017.10.13.11.22.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 11:22:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171013173145.GA18702@obsidianresearch.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012142319.GA11254@lst.de> <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
 <20171013065716.GB26461@lst.de> <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com>
 <20171013163822.GA17411@obsidianresearch.com> <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com>
 <20171013173145.GA18702@obsidianresearch.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Oct 2017 11:22:21 -0700
Message-ID: <CAPcyv4jZJRto1jwmNU--pqH_6dOVMyj=68ZwEjAmmkgX=mRk7w@mail.gmail.com>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 13, 2017 at 10:31 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Fri, Oct 13, 2017 at 10:01:04AM -0700, Dan Williams wrote:
>> On Fri, Oct 13, 2017 at 9:38 AM, Jason Gunthorpe
>> <jgunthorpe@obsidianresearch.com> wrote:
>> > On Fri, Oct 13, 2017 at 08:14:55AM -0700, Dan Williams wrote:
>> >
>> >> scheme specific to RDMA which seems like a waste to me when we can
>> >> generically signal an event on the fd for any event that effects any
>> >> of the vma's on the file. The FL_LAYOUT lease impacts the entire file,
>> >> so as far as I can see delaying the notification until MR-init is too
>> >> late, too granular, and too RDMA specific.
>> >
>> > But for RDMA a FD is not what we care about - we want the MR handle so
>> > the app knows which MR needs fixing.
>>
>> I'd rather put the onus on userspace to remember where it used a
>> MAP_DIRECT mapping and be aware that all the mappings of that file are
>> subject to a lease break. Sure, we could build up a pile of kernel
>> infrastructure to notify on a per-MR basis, but I think that would
>> only be worth it if leases were range based. As it is, the entire file
>> is covered by a lease instance and all MRs that might reference that
>> file get one notification. That said, we can always arrange for a
>> per-driver callback at lease-break time so that it can do something
>> above and beyond the default notification.
>
> I don't think that really represents how lots of apps actually use
> RDMA.
>
> RDMA is often buried down in the software stack (eg in a MPI), and by
> the time a mapping gets used for RDMA transfer the link between the
> FD, mmap and the MR is totally opaque.
>
> Having a MR specific notification means the low level RDMA libraries
> have a chance to deal with everything for the app.
>
> Eg consider a HPC app using MPI that uses some DAX aware library to
> get DAX backed mmap's. It then passes memory in those mmaps to the
> MPI library to do transfers. The MPI creates the MR on demand.
>
> So, who should be responsible for MR coherency? Today we say the MPI
> is responsible. But we can't really expect the MPI
> to hook SIGIO and somehow try to reverse engineer what MRs are
> impacted from a FD that may not even still be open.

Ok, that's good insight that I didn't have. Userspace needs more help
than just an fd notification.

> I think, if you want to build a uAPI for notification of MR lease
> break, then you need show how it fits into the above software model:
>  - How it can be hidden in a RDMA specific library

So, here's a strawman can ibv_poll_cq() start returning ibv_wc_status
== IBV_WC_LOC_PROT_ERR when file coherency is lost. This would make
the solution generic across DAX and non-DAX. What's you're feeling for
how well applications are prepared to deal with that status return?

>  - How lease break can be done hitlessly, so the library user never
>    needs to know it is happening or see failed/missed transfers

iommu redirect should be hit less and behave like the page cache case
where RDMA targets pages that are no longer part of the file.

>  - Whatever fast path checking is needed does not kill performance

What do you consider a fast path? I was assuming that memory
registration is a slow path, and iommu operations are asynchronous so
should not impact performance of ongoing operations beyond typical
iommu overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
