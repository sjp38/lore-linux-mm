Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 98BD76B03D1
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 11:22:34 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id f20so80301302otd.9
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:22:34 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t3si2315038oie.298.2017.06.19.08.22.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 08:22:33 -0700 (PDT)
Received: from mail-ua0-f169.google.com (mail-ua0-f169.google.com [209.85.217.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6F2D82395D
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 15:22:32 +0000 (UTC)
Received: by mail-ua0-f169.google.com with SMTP id g40so61252001uaa.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 08:22:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170619132107.GG11993@dastard>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766213493.22552.4057048843646200083.stgit@dwillia2-desk3.amr.corp.intel.com>
 <CALCETrU1Hg=q4cdQDex--3nVBfwRC1o=9pC6Ss77Z8Lxg7ZJLg@mail.gmail.com>
 <CAPcyv4j4UEegViDJcLZjVv5AFGC18-DcvHFnhZatB0hH3BY85g@mail.gmail.com>
 <CALCETrUfv26pvmyQ1gOkKbzfSXK2DnmeBG6VmSWjFy1WBhknTw@mail.gmail.com>
 <CAPcyv4iPb69e+rE3fJUzm9U_P_dLfhantU9mvYmV-R0oQee4rA@mail.gmail.com>
 <CALCETrVY38h2ajpod2U_2pdHSp8zO4mG2p19h=OnnHmhGTairw@mail.gmail.com> <20170619132107.GG11993@dastard>
From: Andy Lutomirski <luto@kernel.org>
Date: Mon, 19 Jun 2017 08:22:10 -0700
Message-ID: <CALCETrUe0igzK0RZTSSondkCY3ApYQti89tOh00f0j_APrf_dQ@mail.gmail.com>
Subject: Re: [RFC PATCH 2/2] mm, fs: daxfile, an interface for
 byte-addressable updates to pmem
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, andy.rudoff@intel.com, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-nvdimm <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Christoph Hellwig <hch@lst.de>

On Mon, Jun 19, 2017 at 6:21 AM, Dave Chinner <david@fromorbit.com> wrote:
> On Sat, Jun 17, 2017 at 10:05:45PM -0700, Andy Lutomirski wrote:
>> On Sat, Jun 17, 2017 at 8:15 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> > On Sat, Jun 17, 2017 at 4:50 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> >> My other objection is that the syscall intentionally leaks a reference
>> >> to the file.  This means it needs overflow protection and it probably
>> >> shouldn't ever be allowed to use it without privilege.
>> >
>> > We only hold the one reference while S_DAXFILE is set, so I think the
>> > protection is there, and per Dave's original proposal this requires
>> > CAP_LINUX_IMMUTABLE.
>> >
>> >> Why can't the underlying issue be easily fixed, though?  Could
>> >> .page_mkwrite just make sure that metadata is synced when the FS uses
>> >> DAX?
>> >
>> > Yes, it most definitely could and that idea has been floated.
>> >
>> >> On a DAX fs, syncing metadata should be extremely fast.
>
> <sigh>
>
> This again....
>
> Persistent memory means the *I/O* is fast. It does not mean that
> *complex filesystem operations* are fast.
>
> Don't forget that there's an shitload of CPU that gets burnt to make
> sure that the metadata is synced correctly. Do that /synchronously/
> on *every* write page fault (which, BTW, modify mtime, so will
> always have dirty metadata to sync) and now you have a serious
> performance problem with your "fast" DAX access method.

I think the mtime issue can and should be solved separately.  But it'
s a fair point that there would be workloads for which this could be
excessively expensive.  In particular, simply creating a file,
mmapping a large range, and touching the pages one by one -- delalloc
would be completely defeated.

But here's a strawman for solving both issues.  First, mtime.  I
consider it to be either a bug or a misfeature that .page_mkwrite
*ever* dirties an inode just to update mtime.  I have old patches to
fix this, and those patches could be updated and merged.  With them
applied, there's just a set_bit() in .page_mkwrite() to handle mtime.

https://git.kernel.org/pub/scm/linux/kernel/git/luto/linux.git/log/?h=mmap_mtime/patch_v4

Second: syncing extents.  Here's a straw man.  Forget the mmap() flag.
Instead add a new msync() operation:

msync(start, length, MSYNC_PMEM_PREPARE_WRITE);

If this operation succeeds, it guarantees that all future writes
through this mapping on this range will hit actual storage and that
all the metadata operations needed to make this write persistent will
hit storage such that they are ordered before the user's writes.

As an implementation detail, this will flush out the extents if
needed.  In addition, if the FS has any mechanism that would cause
problems asyncronously later on (dedupe?  deallocated extents full of
zeros?  defrag?), it may also need to set a flag on the VMA that
changes the behavior of future .page_mkwrite operations.

(On x86, for example, this would permit the FS to do WC/streaming
writes without SFENCE if the FS were structured in a way that this
worked.)

Now we have an API that should work going forward without introducing
baggage.  And XFS is free to implement this API by making the entire
file act like a swap file if XFS wants to do so, but this doesn't
force other filesystems (ext4? NOVA?) to do the same thing.

>
> And that's before we even consider all the problems with running
> sync operations in page fault context....
>
>> >> This
>> >> could be conditioned on an madvise or mmap flag if performance might
>> >> be an issue.  As far as I know, this change alone should be
>> >> sufficient.
>> >
>> > The hang up is that it requires per-fs enabling as it needs to be
>> > careful to manage mmap_sem vs fs journal locks for example. I know the
>> > in-development NOVA [1] filesystem is planning to support this out of
>> > the gate. ext4 would be open to implementing it, but I think xfs is
>> > cold on the idea. Christoph originally proposed it here [2], before
>> > Dave went on to propose immutable semantics.
>>
>> Hmm.  Given a choice between a very clean API that works without
>> privilege but is awkward to implement on XFS and an awkward-to-use
>> API, I'd personally choose the former.
>
> Yup, you have the choice of a clean kernel API that will be
> substantially slower than the existing "dirty page" tracking and
> having the app run fsync() when necessary, or having to do a little
> more work in a library routine that preallocates a file and sets a
> flag on it?
>
> The apps will use the library API, not the kernel API, so who really
> cares if there's a few steps to setting up the file state
> appropriately?
>
>> Dave, even with the lock ordering issue, couldn't XFS implement
>> MAP_PMEM_AWARE by having .page_mkwrite work roughly like this:
>>
>> if (metadata is dirty) {
>>   up_write(&mmap_sem);
>>   sync the metadata;
>>   down_write(&mmap_sem);
>>   return 0;  /* retry the fault */
>> } else {
>>   return whatever success code;
>> }
>
> How do you know that there is dependent filesystem metadata that
> needs syncing at a level that you can safely manipulate the
> mmap_sem? And how, exactly, do you do this without races?

I have no idea, but I expect that all the locking issues are solvable.

> It'd be
> trivial to DOS such retryable DAX faults simply by touching the file
> in a tight loop in a separate process...

If the code were smart enough to only cause a retry when the extent
being touched is dirty, this problem wouldn't exist.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
