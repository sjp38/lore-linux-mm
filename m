Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB3516B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 02:11:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 87-v6so5189672pfq.8
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 23:11:32 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id g66-v6si11900585pfk.53.2018.09.30.23.11.30
        for <linux-mm@kvack.org>;
        Sun, 30 Sep 2018 23:11:31 -0700 (PDT)
Date: Mon, 1 Oct 2018 16:11:27 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 0/4] get_user_pages*() and RDMA: first steps
Message-ID: <20181001061127.GQ31060@dastard>
References: <20180928053949.5381-1-jhubbard@nvidia.com>
 <20180928152958.GA3321@redhat.com>
 <4c884529-e2ff-3808-9763-eb0e71f5a616@nvidia.com>
 <20180928214934.GA3265@redhat.com>
 <dfa6aaef-b97e-ebd4-6cc8-c907a7b3f9bb@nvidia.com>
 <20180929084608.GA3188@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180929084608.GA3188@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Christopher Lameter <cl@linux.com>, Jason Gunthorpe <jgg@ziepe.ca>, Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-rdma <linux-rdma@vger.kernel.org>, linux-fsdevel@vger.kernel.org, Christian Benvenuti <benve@cisco.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>

On Sat, Sep 29, 2018 at 04:46:09AM -0400, Jerome Glisse wrote:
> On Fri, Sep 28, 2018 at 07:28:16PM -0700, John Hubbard wrote:
> > On 9/28/18 2:49 PM, Jerome Glisse wrote:
> > > On Fri, Sep 28, 2018 at 12:06:12PM -0700, John Hubbard wrote:
> > >> use a non-CPU device to read and write to "pinned" memory, especially when
> > >> that memory is backed by a file system.

"backed by a filesystem" is the biggest problem here.

> > >> I recall there were objections to just narrowly fixing the set_page_dirty()
> > >> bug, because the underlying problem is large and serious. So here we are.
> > > 
> > > Except that you can not solve that issue without proper hardware. GPU are
> > > fine. RDMA are broken except the mellanox5 hardware which can invalidate
> > > at anytime its page table thus allowing to write protect the page at any
> > > time.
> > 
> > Today, people are out there using RDMA without page-fault-capable hardware.
> > And they are hitting problems, as we've seen. From the discussions so far,
> > I don't think it's impossible to solve the problems, even for "lesser", 
> > non-fault-capable hardware.

This reminds me so much of Linux mmap() in the mid-2000s - mmap()
worked for ext3 without being aware of page faults, so most mm/
developers at the time were of the opinion that all the other
filesystems should work just fine without being aware of page
faults.

But some loud-mouthed idiot at SGI kept complaining that mmap()
could never be fixed for XFS without write fault notification
because of delayed allocation, unwritten extents and ENOSPC had to
be handled before mapped writes could be posted.  Eventually
Christoph Lameter got ->page_mkwrite into the page fault path and
the loud mouthed idiot finally got mmap() to work correctly on XFS:

commit 4f57dbc6b5bae5a3978d429f45ac597ca7a3b8c6
Author: David Chinner <dgc@sgi.com>
Date:   Thu Jul 19 16:28:17 2007 +1000

    [XFS] Implement ->page_mkwrite in XFS.
    
    Hook XFS up to ->page_mkwrite to ensure that we know about mmap pages
    being written to. This allows use to do correct delayed allocation and
    ENOSPC checking as well as remap unwritten extents so that they get
    converted correctly during writeback. This is done via the generic
    block_page_mkwrite code.
    
    SGI-PV: 940392
    SGI-Modid: xfs-linux-melb:xfs-kern:29149a
    
    Signed-off-by: David Chinner <dgc@sgi.com>
    Signed-off-by: Christoph Hellwig <hch@infradead.org>
    Signed-off-by: Tim Shimmin <tes@sgi.com>

Nowdays, ->page_mkwrite is fundamental filesystem functionality -
copy-on-write filesystems like btrfs simply don't work if they can't
trigger COW on mapped write accesses. These days all the main linux
filesystems depend on write fault notifications in some way or
another for correct operation.

The way RDMA uses GUP to take references to file backed pages to
'stop them going away' is reminiscent of mmap() back before
->page_mkwrite(). i.e. it assumes that an initial read of the page
will populate the page state correctly for all future operations,
including set_page_dirty() after write accesses.

This is not a valid assumption - filesystems can have different
private clean vs dirty page state, and may need to perform
operations to take a page from clean to dirty.  Hence calling
set_page_dirty() on a file backed mapped page without first having
called ->page_mkwrite() is a bug.

RDMA does not call ->page_mkwrite on clean file backed pages before it
writes to them and calls set_page_dirty(), and hence RDMA to file
backed pages is completely unreliable. I'm not sure this can be
solved without having page fault capable RDMA hardware....

> > > With the solution put forward here you can potentialy wait _forever_ for
> > > the driver that holds a pin to drop it. This was the point i was trying to
> > > get accross during LSF/MM. 

Right, but pinning via GUP is not an option for file backed pages
because the filesystem is completely unaware of these references.
i.e. waiting forever isn't an issue here because the filesystem
never waits on them. Instead, they are a filesystem corruption
vector because the filesystem can invalidate those mappings and free
the backing store while they are still in use by RDMA.

Hence for DAX filesystems, this leaves the RDMA app with direct
access to the physical storage even though the filesystem has freed
the space it is accessing. This is a use after free of the physical
storage that the filesystem cannot control, and why DAX+RDMA is
disabled right now.

We could address these use-after-free situations via forcing RDMA to
use file layout leases and revoke the lease when we need to modify
the backing store on leased files. However, this doesn't solve the
need for filesystems to receive write fault notifications via
->page_mkwrite.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
