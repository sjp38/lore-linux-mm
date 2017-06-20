Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFAD6B0292
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 01:53:36 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id a38so91803839ota.12
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 22:53:36 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d79si3105910oig.224.2017.06.19.22.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 22:53:35 -0700 (PDT)
Received: from mail-vk0-f47.google.com (mail-vk0-f47.google.com [209.85.213.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 4C79223A05
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 05:53:34 +0000 (UTC)
Received: by mail-vk0-f47.google.com with SMTP id p62so63711507vkp.0
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 22:53:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170620004653.GI17542@dastard>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard> <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 19 Jun 2017 22:53:12 -0700
Message-ID: <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 19, 2017 at 5:46 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Jun 19, 2017 at 08:22:10AM -0700, Andy Lutomirski wrote:
>> On Mon, Jun 19, 2017 at 6:21 AM, Dave Chinner <david@fromorbit.com> wrote:
>> > On Sat, Jun 17, 2017 at 10:05:45PM -0700, Andy Lutomirski wrote:
>> >> On Sat, Jun 17, 2017 at 8:15 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> >> > On Sat, Jun 17, 2017 at 4:50 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> >> >> My other objection is that the syscall intentionally leaks a reference
>> >> >> to the file.  This means it needs overflow protection and it probably
>> >> >> shouldn't ever be allowed to use it without privilege.
>> >> >
>> >> > We only hold the one reference while S_DAXFILE is set, so I think the
>> >> > protection is there, and per Dave's original proposal this requires
>> >> > CAP_LINUX_IMMUTABLE.
>> >> >
>> >> >> Why can't the underlying issue be easily fixed, though?  Could
>> >> >> .page_mkwrite just make sure that metadata is synced when the FS uses
>> >> >> DAX?
>> >> >
>> >> > Yes, it most definitely could and that idea has been floated.
>> >> >
>> >> >> On a DAX fs, syncing metadata should be extremely fast.
>> >
>> > <sigh>
>> >
>> > This again....
>> >
>> > Persistent memory means the *I/O* is fast. It does not mean that
>> > *complex filesystem operations* are fast.
>> >
>> > Don't forget that there's an shitload of CPU that gets burnt to make
>> > sure that the metadata is synced correctly. Do that /synchronously/
>> > on *every* write page fault (which, BTW, modify mtime, so will
>> > always have dirty metadata to sync) and now you have a serious
>> > performance problem with your "fast" DAX access method.
>>
>> I think the mtime issue can and should be solved separately.  But it'
>> s a fair point that there would be workloads for which this could be
>> excessively expensive.  In particular, simply creating a file,
>> mmapping a large range, and touching the pages one by one -- delalloc
>> would be completely defeated.
>>
>> But here's a strawman for solving both issues.  First, mtime.  I
>> consider it to be either a bug or a misfeature that .page_mkwrite
>> *ever* dirties an inode just to update mtime.  I have old patches to
>> fix this, and those patches could be updated and merged.  With them
>> applied, there's just a set_bit() in .page_mkwrite() to handle mtime.
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=mmap_mtime/patch_v4
>
> Yup, I remember that - it delays the update to data writeback time,
> IOWs the proposed MAP_SYNC page fault semantics result in the same
> (poor) behaviour because the sync operation will trigger mtime
> updates instead of the page fault.
>
> Unless, of course, you are implying that MAP_SYNC should not
> actually sync all known dirty metadata on an inode.
>
> <smacks head on desk>
>
>> Second: syncing extents.  Here's a straw man.  Forget the mmap() flag.
>> Instead add a new msync() operation:
>>
>> msync(start, length, MSYNC_PMEM_PREPARE_WRITE);
>
> How's this any different from the fallocate command I proposed to do
> this (apart from the fact that msync() is not intended to be abused
> as a file preallocation/zeroing interface)?

I must have missed that suggestion.

But it's different in a major way.  fallocate() takes an fd parameter,
which means that, if some flag gets set, it's set on the struct file.
The persistence property seems to me like it belongs on the vma, not
the file.  But it doesn't have to be msync() -- it could be madvise or
even a new mallocate().  (Although mallocate() is possible the worst
name ever.)

>
>> If this operation succeeds, it guarantees that all future writes
>> through this mapping on this range will hit actual storage and that
>> all the metadata operations needed to make this write persistent will
>> hit storage such that they are ordered before the user's writes.
>> As an implementation detail, this will flush out the extents if
>> needed.  In addition, if the FS has any mechanism that would cause
>> problems asyncronously later on (dedupe?  deallocated extents full
>> of zeros?  defrag?),
>
> Hole punch, truncate, reflink, dedupe, snapshots, scrubbing and
> other background filesystem maintenance operations, etc can all
> change the extent layout asynchronously if there's no mechanism to
> tell the fs not to modify the inode extent layout.

But that's my whole point.  The kernel doesn't really need to prevent
all these background maintenance operations -- it just needs to block
.page_mkwrite until they are synced.  I think that whatever new
mechanism we add for this should be sticky, but I see no reason why
the filesystem should have to block reflink on a DAX file entirely.

In fact, the daxctl() proposal seems actively problematic for some
usecases.  I think I should be able to mmap() a DAX file and then,
while it's still mapped, extend the file, mmap the new part (with the
appropriate flag, madvise(), msync(), fallocate(), whatever), and
write directly through that mapping and through the original mapping,
concurrently, with the full persistence guarantee.  This seems really
awkward to do using daxctl().

>
>> it may also need to set a flag on the VMA
>> that changes the behavior of future .page_mkwrite operations.
>>
>> (On x86, for example, this would permit the FS to do WC/streaming
>> writes without SFENCE if the FS were structured in a way that this
>> worked.)
>>
>> Now we have an API that should work going forward without
>> introducing baggage.  And XFS is free to implement this API by
>> making the entire file act like a swap file if XFS wants to do so,
>> but this doesn't force other filesystems (ext4? NOVA?) to do the
>> same thing.
>
> Sure, you are providing a simple programmatic API, but this does not
> provide a viable feature management strategy.
>
> i.e. the API you are now proposing requires the filesystem to ensure
> an inode's extent map cannot be modified ever again in the future
> (that "guarantees all future writes" bit).  This requires, at
> minimum, a persistent flag to be set on the inode so the VFS and
> filesystem implementations can use it to prevent anything that, for
> example, relies on copy-on-write semantics being done on those
> files. That means the proposed msync operation will need to check
> the filesystem can support this feature and *fail* if it can't.

No it doesn't.  A filesystem *could* implement it like that, but it
could also implement it using .page_mkwrite.  And yes, a filesystem
that can't can't guarantee durability with CLFLUSHOPT; SFENCE on a
mapping should fail this operation to indicate that it can't support
it.

>
> Further, administrators need to be aware of this application
> requirement so they can plan their backup and disaster recovery
> operations appropriately (e.g. reflink and/or snapshots cannot be
> used as part of thei backup strategy).

Or they could use a filesystem that will understand that the new
operation needs to break COW.

>
> Unsurprisingly, this is exactly what the "DAX immutable" inode flag
> I proposed provides.  It provides an explicit, standardised and
> *documented* management strategy that is common across all
> filesystems. It uses mechanisms that *already exist*, the VFS and
> filesystems already implement, and adminstrators are familiar with
> using to manage their systems (e.g. setting the "NODUMP" inode flag
> to exclude files from backups). This also avoids the management
> level fragmentation which would occur if filesystems each solve the
> "DAX userspace data sync" problem differently via different
> management tools, behaviours and semantics.

The DAX immutable flag is really nasty for my software that would like
to use DAX.  I have quite a few processes, all unprivileged, that
create files that they'd like to map using DAX and write to durably
without needing to fsync() (using CLFLUSHOPT; SFENCE or perhaps a WT
mapping).  If I were to use daxctl(), I'd have to have to write a
privileged daemon to manage it, and that would be rather nasty.

If, instead, we had a nice unprivileged per-vma or per-fd mechanism to
tell the filesystem that I want DAX durability, I could just use it
without any fuss.  If it worked on ext4 before it worked on xfs, then
I'd use ext4.  If it ended up being heavier weight on XFS than it was
on ext4 because XFS needed to lock down the extent map for the inode
whereas ext4 could manage it through .page_mkwrite(), then I'd
benchmark it and see which fs would win.  (For my particular use case,
I doubt it would matter, since I aggressively offload fs metadata
operations to a thread whose performance I don't really care about.)


--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
