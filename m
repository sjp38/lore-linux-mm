Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 10B786B02C3
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 12:14:48 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id x57so59645465otd.8
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:14:48 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q5si5875886otc.280.2017.06.20.09.14.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jun 2017 09:14:46 -0700 (PDT)
Received: from mail-ua0-f169.google.com (mail-ua0-f169.google.com [209.85.217.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id EA0EB239BA
	for <linux-mm@kvack.org>; Tue, 20 Jun 2017 16:14:45 +0000 (UTC)
Received: by mail-ua0-f169.google.com with SMTP id 70so20853748uau.0
        for <linux-mm@kvack.org>; Tue, 20 Jun 2017 09:14:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170620101145.GJ17542@dastard>
References: <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com>
 <20170619132107.GG11993@dastard> <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
 <20170620004653.GI17542@dastard> <CALCETrVuoPDRuuhc9X8eVCYiFUzWLSTRkcjbD6jas_2J2GixNQ@mail.gmail.com>
 <20170620101145.GJ17542@dastard>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 20 Jun 2017 09:14:24 -0700
Message-ID: <CALCETrVCJkm5SCxAtNMW36eONHsFw1s0dkVnDAs4vAXvEKMsPw@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Tue, Jun 20, 2017 at 3:11 AM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Jun 19, 2017 at 10:53:12PM -0700, Andy Lutomirski wrote:
>> On Mon, Jun 19, 2017 at 5:46 PM, Dave Chinner <david@fromorbit.com> wrote:
>> > On Mon, Jun 19, 2017 at 08:22:10AM -0700, Andy Lutomirski wrote:
>> >> Second: syncing extents.  Here's a straw man.  Forget the mmap() flag.
>> >> Instead add a new msync() operation:
>> >>
>> >> msync(start, length, MSYNC_PMEM_PREPARE_WRITE);
>> >
>> > How's this any different from the fallocate command I proposed to do
>> > this (apart from the fact that msync() is not intended to be abused
>> > as a file preallocation/zeroing interface)?
>>
>> I must have missed that suggestion.
>>
>> But it's different in a major way.  fallocate() takes an fd parameter,
>> which means that, if some flag gets set, it's set on the struct file.
>
> DAX is a property of the inode, not the VMA or struct file as it
> needs to be consistent across all VMAs and struct files that
> reference that inode. Also, fallocate() manipulates state and
> metadata hidden behind the struct inode, not the struct file, so it
> seems to me like the right API to use.

I'm not sure I see why.  I can think of a few different scenarios:

 - Reflink while a DAX-using program is running.  It would be nice for
performance, but not critical for functionality, if trying to reflink
a file that's mapped for DAX would copy instead of COWing.  But
breaking COW on the next page_mkwrite would work, too.  A per-inode
count of the number of live DAX mappings or of the number of struct
file instances that have requested DAX would work here.

 - Trying to use DAX on a file that is already reflinked.  The order
of operations doesn't matter hugely, except that breaking COW for the
entire range in question all at once would be faster and result in
better allocation.

 - Checksumming filesystems.  I think it's basically impossible to do
DAX writes to a file like this.  A filesystem could skip checksumming
on extents that are actively mapped for DAX, but something like chattr
to tell, say, btrfs that a given file is intended for DAX is probably
better.  (But, if so, it should presumably be persistent like chattr
and not something that's purely in memory like daxctl().)

 - Defrag and such on an otherwise simple filesystem.  Defragging a
file while it's not actively mapped for DAX should be allowed.
Defragging a file while it is actively mapped for DAX may be slow, but
it a filesystem could certainly make it work.

 - RAID.  Not going to work.

>
> And, as mmap() requires a fd to set up the mapping and fallocate()
> would have to be run *before* mmap() is used to access the data
> directly, I don't see why using fallocate would be a problem here...

Fair enough.  But ISTM fallocate() has no business setting up
important state in the struct file.  It's an operation on inodes.

Looking at the above scenarios, it seems to may that two or three
separate mechanisms may be ideal here.

1. The most important: some way to tell the kernel that an open file
description or an mmap or some subrange thereof is going to be used
for DAX writes and for the kernel to respond by saying "yes, okay" or
"no, not okay".  This should be 100% reliable, which means that all
the corner cases have to work.  This means that, if one task says
"make this file work for DAX" and another task extends the file using
truncate (without calling fallocate), then whatever the kernel
promised to the first task should remain true.

2. Some way to tell filesystems like btrfs to make a file that will be
DAX-able.  chattr +C might already fit the bill.  Without this, I'd
expect the normal incantation to DAX-map a file on btrfs to return an
error.

3. (Not strictly related to DAX.) A way to tell the kernel "I have
this file mmapped for write.  Please go out of your way to avoid
future page faults."  I've wanted this for ordinary files on ext4.
The kernel could, but presently does not, use hardware dirty tracking
instead of software dirty tracking to decide when to write the page
back.  The kernel could also, in principle, write back dirty pages
without ever write protecting them.  For DAX, this might change
behavior to prevent any operation that would relocate blocks or to
have the kernel go out of its way to only do such operations when
absolutely necessary and to immediately update and unwriteprotect the
relevant pages.

(3) is optional and could be delayed to the distant future.  It's not
needed for correctness.

I really don't want to see a scenario where DAX works if you use some
fancy special-purpose library exactly as intended but occasionally
eats your data if you don't use the library exactly as intended.
Getting a valid DAX mapping, writing to it, and doing
CLFLUSHOPT;SFENCE must make that write durable no matter what (unless
the underlying hardware actually fails).

> The MAP_SYNC proposal is effectively "run the metadata side of
> fdatasync() on every page fault". If the inode is not metadata
> dirty, then it will do nothing, otherwise it will do what it needs
> to stabilise the inode for userspace to be able to sync the data and
> it will block until it is done.
>
> Prediction for the MAP_SYNC future: frequent bug reports about huge,
> unpredictable page fault latencies on DAX files because every so
> often a page fault is required to sync tens of thousands of
> unrelated dirty objects because of filesystem journal ordering
> constraints....

Is this really so bad?  Someone might ask for relaxed journal ordering
or they might switch to a different filesystem.  IIRC some filesystems
(ZFS?) have explicit support for this use case.  I suspect that users
saying "your filesystem is slower than I'd like for such-and-such use
case" isn't all that rare.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
