Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8529E6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 00:18:43 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id jl1so6824637obb.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 21:18:43 -0700 (PDT)
Received: from mail-oi0-x231.google.com (mail-oi0-x231.google.com. [2607:f8b0:4003:c06::231])
        by mx.google.com with ESMTPS id i64si988556oib.208.2016.04.25.21.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 21:18:42 -0700 (PDT)
Received: by mail-oi0-x231.google.com with SMTP id r78so3212176oie.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 21:18:42 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160426025645.GG18496@dastard>
References: <1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com>
	<20160425232552.GD18496@dastard>
	<CAPcyv4i6iwm1iY2mQ5yRbYfRexQroUX_R0B-db4ROU837fratw@mail.gmail.com>
	<20160426001157.GE18496@dastard>
	<CAPcyv4i0qnCrzsTQT-v84OhnhjmVBFJ8gKoyu6XkuUwH0babfQ@mail.gmail.com>
	<20160426025645.GG18496@dastard>
Date: Mon, 25 Apr 2016 21:18:42 -0700
Message-ID: <CAPcyv4hg6O3nvD7aXuFm_GAB-1GJxqfNn=RZswj47COa9bVygA@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

On Mon, Apr 25, 2016 at 7:56 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Apr 25, 2016 at 06:45:08PM -0700, Dan Williams wrote:
[..]
>> Otherwise, if an application wants to use DAX then it might
>> need to be prepared to handle media errors itself same as the
>> un-RAIDed disk case.  Yes, at an administrative level without
>> reverse-mapping support from a filesystem there's presently no way to
>> ask "which files on this fs are impacted by media errors", and we're
>> aware that reverse-mapping capabilities are nascent for current
>> DAX-aware filesystems.
>
> Precisely my point - suggestions are being proposed which assume
> use of infrastructure that *does not exist yet* and has not been
> discussed or documented. If we're expecting such infrastructure to
> be implemented in the filesystems and block device drivers, then we
> need to determine that the error model actually works first...

These patches only assume the clear-error-on write-model, and that
*maybe* the sysfs bad blocks list is useful if the filesystem has a
reverse-map, or if the application can compare the list against the
results of fiemap().  Beyond that, this is the same perennial "we
should really have better error coordination between block device and
filesystems" discussions that we have at LSF.

>
>> The forward lookup path, as impractical as it
>> is for large numbers of files, is available if an application wanted
>> to know if a specific file was impacted.  We've discussed possibly
>> extending fiemap() to return bad blocks in a file rather than
>> consulting sysfs, or extending lseek() with something like SEEK_ERROR
>> to return offsets of bad areas in a file.
>
> Via what infrastructure will the filesystem use for finding out
> whether a file has bad blocks in it? And if the file does have bad
> blocks, what are you expecting the filesystem to do with that
> information?

We currently have no expectation that the filesystem does anything
with the bad blocks list.  However, if a filesystem had btrfs-like
capabilities to recover data from a redundant location we'd be looking
to plug into that infrastructure.

>> > I haven't seen any design/documentation for infrastructure at the
>> > application layer to handle redundant data and correctly
>> > transparently so I don't have any idea what the technical
>> > requirements this different IO stack places on filesystems may be.
>> > Hence I'm asking for some kind of architecture/design documentation
>> > that I can read to understand exactly what is being proposed here...
>>
>> I think this is a discussion for a solution that would build on top of
>> this basic "here are the errors, re-write them with good data if you
>> can; otherwise, best of luck" foundation.  Something like a DAX-aware
>> device mapper layer that duplicates data tagged with REQ_META so at
>> least we have a recovery path when a sector error lands in critical
>> filesystem-metadata.
>
> Filesytsem metadata is not the topic of discussion here - it's
> user data that throws an error on a DAX load/store that is the
> issue.

Which is not a new problem since volatile DRAM in the non-DAX case can
throw the exact same error.  The current recovery model there is crash
the kernel (without MCE recovery), or crash the application and hope
the kernel maps out the page or the application knows how to restart
after SIGBUS.  Memory mirroring is meant to make this a bit less
harsh, but there's no mechanism to make this available outside the
kernel.

>> However, anything we come up with to make NVDIMM
>> errors more survivable should be directly applicable to traditional
>> disk storage as well.
>
> I'm not sure it does. DAX implies that traditional block layer RAID
> infrastructure is not possible, nor are data CRCs, nor are any other
> sort of data transformations that are needed for redundancy at the
> device layers. Anything that relies on copying/modifying/stable data to
> provide redundancies needs to do such work at a place where it can
> stall userspace page faults.
>
> This is where pmem native filesystem designs like NOVA take over
> from traditional block based filesystems - they are designed around
> the ability to do atomic page-based operations for data protection
> and recovery operations. It is this mechanism that allows stable
> pages to be committed to permanent storage and as such, allow
> redundancy operations such as mirroring to be performed before
> operations are marked as "stable".
>
> I'm missing the bigger picture that is being aimed at here - what's the
> point of DAX if we have to turn it off if we want any sort of
> failure protection? What's the big plan for fully enabling DAX with
> robust error correction? Where is this all supposed to be leading
> to?
>

NOVA and other solutions are free and encouraged to do a coherent
bottoms-up rethink of error handling on top of persistent memory
devices, in the meantime applications can only expect the legacy
SIGBUS and -EIO mechanisms are available.  So I'm still trying to
connect how the "What would NOVA do?" discussion is anything but
orthogonal to hooking up SIGBUS and -EIO for traditional-filesystem
DAX.  It's the only error model an application can expect because it's
the only one that currently exists.

>> Along these lines we had a BoF session at Vault
>> where drive vendors we're wondering if the sysfs bad sectors list
>> could help software recover from the loss of a disk-head, or other
>> errors that only take down part of the drive.
>
> Right, but as I've said elsewhere, loss of a disk head implies
> terabyte scale data loss. That is not something we can automatically
> recovery from at the filesystem level. Low level raid recovery could
> handle that sort of loss, but at the higher layers it's a disaster
> similar to multiple disk RAID failure.  It's a completely different
> scale to a single sector/page loss we are talking about here, and so
> I don't see there as being much (if any) overlap here.
>
>> An I/O hint that flags
>> data that should be stored redundantly might be useful there as well.
>
> DAX doesn't have an IO path to hint with... :/

...I was thinking traditional filesystem metadata operations through
the block layer.  NOVA could of course do something better since it
always indirects userspace access through a filesystem managed page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
