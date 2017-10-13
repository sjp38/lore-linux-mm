Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3C466B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:31:59 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id p186so6850745ioe.9
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 10:31:59 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id t23si1008011ioe.229.2017.10.13.10.31.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Oct 2017 10:31:58 -0700 (PDT)
Date: Fri, 13 Oct 2017 11:31:45 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Message-ID: <20171013173145.GA18702@obsidianresearch.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012142319.GA11254@lst.de>
 <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
 <20171013065716.GB26461@lst.de>
 <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com>
 <20171013163822.GA17411@obsidianresearch.com>
 <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 13, 2017 at 10:01:04AM -0700, Dan Williams wrote:
> On Fri, Oct 13, 2017 at 9:38 AM, Jason Gunthorpe
> <jgunthorpe@obsidianresearch.com> wrote:
> > On Fri, Oct 13, 2017 at 08:14:55AM -0700, Dan Williams wrote:
> >
> >> scheme specific to RDMA which seems like a waste to me when we can
> >> generically signal an event on the fd for any event that effects any
> >> of the vma's on the file. The FL_LAYOUT lease impacts the entire file,
> >> so as far as I can see delaying the notification until MR-init is too
> >> late, too granular, and too RDMA specific.
> >
> > But for RDMA a FD is not what we care about - we want the MR handle so
> > the app knows which MR needs fixing.
> 
> I'd rather put the onus on userspace to remember where it used a
> MAP_DIRECT mapping and be aware that all the mappings of that file are
> subject to a lease break. Sure, we could build up a pile of kernel
> infrastructure to notify on a per-MR basis, but I think that would
> only be worth it if leases were range based. As it is, the entire file
> is covered by a lease instance and all MRs that might reference that
> file get one notification. That said, we can always arrange for a
> per-driver callback at lease-break time so that it can do something
> above and beyond the default notification.

I don't think that really represents how lots of apps actually use
RDMA.

RDMA is often buried down in the software stack (eg in a MPI), and by
the time a mapping gets used for RDMA transfer the link between the
FD, mmap and the MR is totally opaque.

Having a MR specific notification means the low level RDMA libraries
have a chance to deal with everything for the app.

Eg consider a HPC app using MPI that uses some DAX aware library to
get DAX backed mmap's. It then passes memory in those mmaps to the
MPI library to do transfers. The MPI creates the MR on demand.

So, who should be responsible for MR coherency? Today we say the MPI
is responsible. But we can't really expect the MPI
to hook SIGIO and somehow try to reverse engineer what MRs are
impacted from a FD that may not even still be open.

I think, if you want to build a uAPI for notification of MR lease
break, then you need show how it fits into the above software model:
 - How it can be hidden in a RDMA specific library
 - How lease break can be done hitlessly, so the library user never
   needs to know it is happening or see failed/missed transfers
 - Whatever fast path checking is needed does not kill performance

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
