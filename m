Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E36EF6B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 06:11:55 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id o62so138817517pga.0
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 03:11:55 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id z14si10135016pfg.281.2017.06.20.03.11.53
        for <linux-mm@kvack.org>;
        Tue, 20 Jun 2017 03:11:55 -0700 (PDT)
Date: Tue, 20 Jun 2017 20:11:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170620101145.GJ17542@dastard>
References: <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard>
 <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard>
 <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 19, 2017 at 10:53:12PM -0700, Andy Lutomirski wrote:
> On Mon, Jun 19, 2017 at 5:46 PM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, Jun 19, 2017 at 08:22:10AM -0700, Andy Lutomirski wrote:
> >> Second: syncing extents.  Here's a straw man.  Forget the mmap() flag.
> >> Instead add a new msync() operation:
> >>
> >> msync(start, length, MSYNC_PMEM_PREPARE_WRITE);
> >
> > How's this any different from the fallocate command I proposed to do
> > this (apart from the fact that msync() is not intended to be abused
> > as a file preallocation/zeroing interface)?
> 
> I must have missed that suggestion.
> 
> But it's different in a major way.  fallocate() takes an fd parameter,
> which means that, if some flag gets set, it's set on the struct file.

DAX is a property of the inode, not the VMA or struct file as it
needs to be consistent across all VMAs and struct files that
reference that inode. Also, fallocate() manipulates state and
metadata hidden behind the struct inode, not the struct file, so it
seems to me like the right API to use.

And, as mmap() requires a fd to set up the mapping and fallocate()
would have to be run *before* mmap() is used to access the data
directly, I don't see why using fallocate would be a problem here...

> >> If this operation succeeds, it guarantees that all future writes
> >> through this mapping on this range will hit actual storage and that
> >> all the metadata operations needed to make this write persistent will
> >> hit storage such that they are ordered before the user's writes.
> >> As an implementation detail, this will flush out the extents if
> >> needed.  In addition, if the FS has any mechanism that would cause
> >> problems asyncronously later on (dedupe?  deallocated extents full
> >> of zeros?  defrag?),
> >
> > Hole punch, truncate, reflink, dedupe, snapshots, scrubbing and
> > other background filesystem maintenance operations, etc can all
> > change the extent layout asynchronously if there's no mechanism to
> > tell the fs not to modify the inode extent layout.
> 
> But that's my whole point.  The kernel doesn't really need to prevent
> all these background maintenance operations -- it just needs to block
> .page_mkwrite until they are synced.  I think that whatever new
> mechanism we add for this should be sticky, but I see no reason why
> the filesystem should have to block reflink on a DAX file entirely.

I understand the problem quite well, thank you very much. Yes,
COW operations (and other things) can be handled by invalidating DAX
mappings and blocking new page faults.  I see little difference
between this and running the sync path after page-mkwrite has
triggered filesystem metadata changes (e.g.  block allocation). i.e.
If MAP_SYNC is going to be used, then all the things you are talking
about comes along for the ride via invalidations.

The MAP_SYNC proposal is effectively "run the metadata side of
fdatasync() on every page fault". If the inode is not metadata
dirty, then it will do nothing, otherwise it will do what it needs
to stabilise the inode for userspace to be able to sync the data and
it will block until it is done.

Prediction for the MAP_SYNC future: frequent bug reports about huge,
unpredictable page fault latencies on DAX files because every so
often a page fault is required to sync tens of thousands of
unrelated dirty objects because of filesystem journal ordering
constraints....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
