Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f197.google.com (mail-ob0-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 727036B0005
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 21:45:10 -0400 (EDT)
Received: by mail-ob0-f197.google.com with SMTP id fg3so1123772obb.3
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 18:45:10 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id s2si8806785oej.33.2016.04.25.18.45.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 18:45:09 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id x19so607094oix.2
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 18:45:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160426001157.GE18496@dastard>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com>
	<20160425232552.GD18496@dastard>
	<CAPcyv4i6iwm1iY2mQ5yRbYfRexQroUX_R0B-db4ROU837fratw@mail.gmail.com>
	<20160426001157.GE18496@dastard>
Date: Mon, 25 Apr 2016 18:45:08 -0700
Message-ID: <CAPcyv4i0qnCrzsTQT-v84OhnhjmVBFJ8gKoyu6XkuUwH0babfQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: "Verma, Vishal L" <vishal.l.verma@intel.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

On Mon, Apr 25, 2016 at 5:11 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Mon, Apr 25, 2016 at 04:43:14PM -0700, Dan Williams wrote:
[..]
>> Maybe I missed something, but all these assumptions are already
>> present for typical block devices, i.e. sectors may go bad and a write
>> may make the sector usable again.
>
> The assumption we make about sectors going bad on SSDs or SRDs is
> that the device is about to die and needs replacing ASAP.

Similar assumptions here.  Storage media is experiencing errors and
past a certain threshold it may be time to decommission the device.

You can see definitions for SMART / media health commands from various
vendors at these links, and yes, hopefully these are standardized /
unified at some point down the road:

http://pmem.io/documents/NVDIMM_DSM_Interface_Example.pdf
https://github.com/HewlettPackard/hpe-nvm/blob/master/Documentation/NFIT_DSM_DDR4_NVDIMM-N_v84s.pdf
https://msdn.microsoft.com/en-us/library/windows/hardware/mt604717(v=vs.85).aspx


> Then
> RAID takes care of the rebuild completely transparently. i.e.
> handling and correcting bad sectors is typically done completely
> transparently /below/ the filesytem like so:

Again, same for an NVDIMM.  Use the pmem block-device as a RAID-member device.

>> This patch series is extending that
>> out to the DAX-mmap case, but it's the same principle of "write to
>> clear error" that we live with in the block-I/O path.  What
>> clarification are you looking for beyond that point?
>
> I'm asking for an actual design document that explains how moving
> all the redundancy and bad sector correction stuff from the LBA
> layer up into application space is supposed to work when
> applications have no clue about LBA mappings, nor tend to keep
> redundant data around. i.e. you're proposing this:

These patches are not proposing *new* / general infrastructure for
moving redundancy and bad sector correction handling to userspace.  If
an existing app is somehow dealing with raw (without RAID) device
errors on disk storage media today it should not need to change to
handle errors on an NVDIMM.  My expectation is that very few if any
applications handle this today and just fail in the presence of media
errors.

> Application
> Application data redundancy/correction
> Filesystem
> Block
> [LBA mapping/redundancy/correction driver e.g. md/dm]
> driver
> hardware
>
> And somehow all the error information from the hardware layer needs
> to be propagated up to the application layer, along with all the
> mapping information from the filesystem and block layers for the
> application to make sense of the hardware reported errors.
>
> I see assumptions this this "just works" but we don't have any of
> the relevant APIs or infrastructure to enable the application to do
> the hardware error->file+offset namespace mapping (i.e. filesystem
> reverse mapping for for file offsets and directory paths, and
> reverse mapping for the the block layer remapping drivers).

If an application expects errors to be handled beneath the filesystem
then it should forgo DAX and arrange for the NVDIMM devices to be
RAIDed.  Otherwise, if an application wants to use DAX then it might
need to be prepared to handle media errors itself same as the
un-RAIDed disk case.  Yes, at an administrative level without
reverse-mapping support from a filesystem there's presently no way to
ask "which files on this fs are impacted by media errors", and we're
aware that reverse-mapping capabilities are nascent for current
DAX-aware filesystems.  The forward lookup path, as impractical as it
is for large numbers of files, is available if an application wanted
to know if a specific file was impacted.  We've discussed possibly
extending fiemap() to return bad blocks in a file rather than
consulting sysfs, or extending lseek() with something like SEEK_ERROR
to return offsets of bad areas in a file.

> I haven't seen any design/documentation for infrastructure at the
> application layer to handle redundant data and correctly
> transparently so I don't have any idea what the technical
> requirements this different IO stack places on filesystems may be.
> Hence I'm asking for some kind of architecture/design documentation
> that I can read to understand exactly what is being proposed here...

I think this is a discussion for a solution that would build on top of
this basic "here are the errors, re-write them with good data if you
can; otherwise, best of luck" foundation.  Something like a DAX-aware
device mapper layer that duplicates data tagged with REQ_META so at
least we have a recovery path when a sector error lands in critical
filesystem-metadata.  However, anything we come up with to make NVDIMM
errors more survivable should be directly applicable to traditional
disk storage as well.  Along these lines we had a BoF session at Vault
where drive vendors we're wondering if the sysfs bad sectors list
could help software recover from the loss of a disk-head, or other
errors that only take down part of the drive.  An I/O hint that flags
data that should be stored redundantly might be useful there as well.

By the way, your presence was sorely missed at LSF/MM!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
