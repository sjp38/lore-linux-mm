Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4E5006B02F3
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 21:40:38 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e187so158177571pgc.7
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 18:40:38 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id p28si11796980pfi.89.2017.06.20.18.40.35
        for <linux-mm@kvack.org>;
        Tue, 20 Jun 2017 18:40:37 -0700 (PDT)
Date: Wed, 21 Jun 2017 11:40:32 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Message-ID: <20170621014032.GL17542@dastard>
References: <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard>
 <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard>
 <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620101145.GJ17542@dastard>
 <CALCETrVCJkm5SCxAtNMW36eONHsFw1s0dkVnDAs4vAXvEKMsPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVCJkm5SCxAtNMW36eONHsFw1s0dkVnDAs4vAXvEKMsPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Tue, Jun 20, 2017 at 09:14:24AM -0700, Andy Lutomirski wrote:
> On Tue, Jun 20, 2017 at 3:11 AM, Dave Chinner <david@fromorbit.com> wrote:
> > On Mon, Jun 19, 2017 at 10:53:12PM -0700, Andy Lutomirski wrote:
> >> On Mon, Jun 19, 2017 at 5:46 PM, Dave Chinner <david@fromorbit.com> wrote:
> >> > On Mon, Jun 19, 2017 at 08:22:10AM -0700, Andy Lutomirski wrote:
> >> >> Second: syncing extents.  Here's a straw man.  Forget the mmap() flag.
> >> >> Instead add a new msync() operation:
> >> >>
> >> >> msync(start, length, MSYNC_PMEM_PREPARE_WRITE);
> >> >
> >> > How's this any different from the fallocate command I proposed to do
> >> > this (apart from the fact that msync() is not intended to be abused
> >> > as a file preallocation/zeroing interface)?
> >>
> >> I must have missed that suggestion.
> >>
> >> But it's different in a major way.  fallocate() takes an fd parameter,
> >> which means that, if some flag gets set, it's set on the struct file.
> >
> > DAX is a property of the inode, not the VMA or struct file as it
> > needs to be consistent across all VMAs and struct files that
> > reference that inode. Also, fallocate() manipulates state and
> > metadata hidden behind the struct inode, not the struct file, so it
> > seems to me like the right API to use.
> 
> I'm not sure I see why.  I can think of a few different scenarios:
> 
>  - Reflink while a DAX-using program is running.  It would be nice for
> performance, but not critical for functionality, if trying to reflink
> a file that's mapped for DAX would copy instead of COWing.  But
> breaking COW on the next page_mkwrite would work, too. 

Your mangling terminology here. We don't "break COW" - we *use*
copy-on-write to break *extent sharing*. We can break extent sharing
in page_mkwrite - that's exactly what we do for normal pagecache
based mmap writes, and it's done in page_mkwrite.

It hasn't been enabled it for DAX yet because it simply hasn't been
robustly tested yet.

> A per-inode
> count of the number of live DAX mappings or of the number of struct
> file instances that have requested DAX would work here.

For what purpose does this serve? The reflink invalidates all the
existing mappings, so the next write access causes a fault and then
page_mkwrite is called and the shared extent will get COWed....

>  - Trying to use DAX on a file that is already reflinked.  The order
> of operations doesn't matter hugely, except that breaking COW for the
> entire range in question all at once would be faster and result in
> better allocation.

We have COW extent size hints for that. i.e. if you want to COW a
huge page at a time, set the COW extent size hint to the huge page
size...

>  - Checksumming filesystems.  I think it's basically impossible to do
> DAX writes to a file like this.

No shit, sherlock. See my previous comments about compression and
encryption. DAX cannot be used where in-place data manipulations
would be required by the IO path.

> A filesystem could skip checksumming
> on extents that are actively mapped for DAX, but something like chattr
> to tell, say, btrfs that a given file is intended for DAX is probably
> better.  (But, if so, it should presumably be persistent like chattr
> and not something that's purely in memory like daxctl().)

You can already do this on btrfs regardless of DAX. There's an inode
flag:

#define BTRFS_INODE_NODATASUM           (1 << 0)

And you set it by turning off copy-on-write when the file is empty.
i.e. just after creation, run:

	ioctl(FS_IOC_GETFLAGS, &flags).
	flags |= FS_NOCOW_FL;
	ioctl(FS_IOC_SETFLAGS, &flags).

You're talking about stuff that already exists - stop trying to tell
me about basic filesystem functionality and DAX requirements that I
understood years ago. Please start with the assumption that I know a
lot more about this than you do, and if there's something you write
that I don't understand I'll ask you to explain....

>  - Defrag and such on an otherwise simple filesystem.  Defragging a
> file while it's not actively mapped for DAX should be allowed.
> Defragging a file while it is actively mapped for DAX may be slow, but
> it a filesystem could certainly make it work.

FYI, XFS already does this - it skips mapped files altogether, so
DAX state simply doesn't matter here. We also have the FS_NODEFRAG
ioctl flag, so admins can choose to mark files that they want defrag
to skip...

> > And, as mmap() requires a fd to set up the mapping and fallocate()
> > would have to be run *before* mmap() is used to access the data
> > directly, I don't see why using fallocate would be a problem here...
> 
> Fair enough.  But ISTM fallocate() has no business setting up
> important state in the struct file.  It's an operation on inodes.

Yup, the state in question is kept in inode->i_flags rather than
duplicated into the struct file. Which leads to code like this in
the page fault handlers. e.g. in xfs_filemap_page_mkwrite():

	struct inode            *inode = file_inode(vma->vm_file);
	....
	if (IS_DAX(inode)) {
		.....

Yeah, the page fault behaviour is determined by state kept on the
inode, not the struct file or vma....

> Looking at the above scenarios, it seems to may that two or three
> separate mechanisms may be ideal here.
> 
> 1. The most important: some way to tell the kernel that an open file
> description or an mmap or some subrange thereof is going to be used
> for DAX writes and for the kernel to respond by saying "yes, okay" or
> "no, not okay". 

A file can only be accessed by DAX or through the page cache at a
point in time - it can't do both because the mapping infrastructure
(e.g. the radix tree) can only handle one or the other at any point
in time. So, you want to change the DAX access mode of an open file?
We have that on XFS. Turn on DAX:

	ioctl(FS_IOC_FSGETXATTR, &flags).
	flags |= FS_XFLAG_DAX;
	ioctl(FS_IOC_FSSETXATTR, &flags).

This will throw an error if the kernel and/or fs does not support
DAX. The fs will lock out page faults on the inode, invalidate all
the existing mappings, remove the cached pages and switch to DAX
mode.

Turn off DAX:

	ioctl(FS_IOC_FSGETXATTR, &flags).
	flags &= ~FS_XFLAG_DAX;
	ioctl(FS_IOC_FSSETXATTR, &flags).

And the filesystem will lock out page faults, invalidate all the DAX
mappings and switch to cached mode...

> 2. Some way to tell filesystems like btrfs to make a file that will be
> DAX-able.

See above.

> > Prediction for the MAP_SYNC future: frequent bug reports about
> > huge, unpredictable page fault latencies on DAX files because
> > every so often a page fault is required to sync tens of
> > thousands of unrelated dirty objects because of filesystem
> > journal ordering constraints....
> 
> Is this really so bad?

Apparently it is. There are people telling us that mtime
updates in page faults introduce too much unpredictable latency and
that screws over their low latency real time applications.

Those same people are telling use that dirty tracking in page faults
for msync/fsync on DAX is too heavyweight and calling msync is too
onerous and has unpredictable latencies because it might result in
having to sync tens of thousands of unrelated dirty objects. Hence
they want to use userspace data sync primitives to avoid this
overhead and so filesystems need to make it possible to provide this
userspace idata sync capability.

So, we came up with a method that removed all overhead and
unpredictability from the page fault path, and now we're being told
that calling fallocate() is too hard and difficult and the
restrictions that prevent all the page fault overhead (operations
which you won't want to be doing for low-latency apps in the first
place) are too onerous.

And so the proposed solution is an API that requires the filesystem
to *run fdatasync in every write page fault*?

Can you see the contradictions in the requirements here? On one hand
we're being told page faults have to be low overhead and have
predictable latency, but when presented with a solution we're told
you want page faults to be blocked arbitrarily and for unbound
lengths of time.

Put simply: I don't care what gets implemented. What I care about is
that everyone understands that we're being given contradictory
requirements and that neither of the proposed solutions solves both
sets of requirements.

> I suspect that users saying "your filesystem is slower than I'd
> like for such-and-such use case" isn't all that rare.

Except the people asking for userspace data sync are asking for it
for *performance reasons*. Making that explicit case *slower* is the
exact opposite of what we've been asked to provide....

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
