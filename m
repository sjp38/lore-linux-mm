Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 106BA6B03BA
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:21:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p4so102548856pfk.15
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:21:33 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id x10si7684343pfj.256.2017.06.19.06.21.31
        for <linux-mm@kvack.org>;
        Mon, 19 Jun 2017 06:21:32 -0700 (PDT)
Date: Mon, 19 Jun 2017 23:21:07 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170619132107.GG11993@dastard>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Sat, Jun 17, 2017 at 10:05:45PM -0700, Andy Lutomirski wrote:
> On Sat, Jun 17, 2017 at 8:15 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> > On Sat, Jun 17, 2017 at 4:50 PM, Andy Lutomirski <luto@kernel.org> wrote:
> >> My other objection is that the syscall intentionally leaks a reference
> >> to the file.  This means it needs overflow protection and it probably
> >> shouldn't ever be allowed to use it without privilege.
> >
> > We only hold the one reference while S_DAXFILE is set, so I think the
> > protection is there, and per Dave's original proposal this requires
> > CAP_LINUX_IMMUTABLE.
> >
> >> Why can't the underlying issue be easily fixed, though?  Could
> >> .page_mkwrite just make sure that metadata is synced when the FS uses
> >> DAX?
> >
> > Yes, it most definitely could and that idea has been floated.
> >
> >> On a DAX fs, syncing metadata should be extremely fast.

<sigh>

This again....

Persistent memory means the *I/O* is fast. It does not mean that
*complex filesystem operations* are fast.

Don't forget that there's an shitload of CPU that gets burnt to make
sure that the metadata is synced correctly. Do that /synchronously/
on *every* write page fault (which, BTW, modify mtime, so will
always have dirty metadata to sync) and now you have a serious
performance problem with your "fast" DAX access method.

And that's before we even consider all the problems with running
sync operations in page fault context....

> >> This
> >> could be conditioned on an madvise or mmap flag if performance might
> >> be an issue.  As far as I know, this change alone should be
> >> sufficient.
> >
> > The hang up is that it requires per-fs enabling as it needs to be
> > careful to manage mmap_sem vs fs journal locks for example. I know the
> > in-development NOVA [1] filesystem is planning to support this out of
> > the gate. ext4 would be open to implementing it, but I think xfs is
> > cold on the idea. Christoph originally proposed it here [2], before
> > Dave went on to propose immutable semantics.
> 
> Hmm.  Given a choice between a very clean API that works without
> privilege but is awkward to implement on XFS and an awkward-to-use
> API, I'd personally choose the former.

Yup, you have the choice of a clean kernel API that will be
substantially slower than the existing "dirty page" tracking and
having the app run fsync() when necessary, or having to do a little
more work in a library routine that preallocates a file and sets a
flag on it?

The apps will use the library API, not the kernel API, so who really
cares if there's a few steps to setting up the file state
appropriately?

> Dave, even with the lock ordering issue, couldn't XFS implement
> MAP_PMEM_AWARE by having .page_mkwrite work roughly like this:
> 
> if (metadata is dirty) {
>   up_write(&mmap_sem);
>   sync the metadata;
>   down_write(&mmap_sem);
>   return 0;  /* retry the fault */
> } else {
>   return whatever success code;
> }

How do you know that there is dependent filesystem metadata that
needs syncing at a level that you can safely manipulate the
mmap_sem? And how, exactly, do you do this without races? It'd be
trivial to DOS such retryable DAX faults simply by touching the file
in a tight loop in a separate process...

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
