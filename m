Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id EE7846B007E
	for <linux-mm@kvack.org>; Mon, 25 Apr 2016 13:21:45 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id k129so100203157iof.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 10:21:45 -0700 (PDT)
Received: from mail-oi0-x22a.google.com (mail-oi0-x22a.google.com. [2607:f8b0:4003:c06::22a])
        by mx.google.com with ESMTPS id w6si2974043otb.155.2016.04.25.10.21.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Apr 2016 10:21:45 -0700 (PDT)
Received: by mail-oi0-x22a.google.com with SMTP id r78so183828942oie.0
        for <linux-mm@kvack.org>; Mon, 25 Apr 2016 10:21:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1461604476.3106.12.camel@intel.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<20160420205923.GA24797@infradead.org>
	<1461434916.3695.7.camel@intel.com>
	<20160425083114.GA27556@infradead.org>
	<1461604476.3106.12.camel@intel.com>
Date: Mon, 25 Apr 2016 10:21:44 -0700
Message-ID: <CAPcyv4ijf=LDLytVRn_UptVVi5G=7r9bkTkkJHYgBF78tffh9w@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "hch@infradead.org" <hch@infradead.org>, "axboe@fb.com" <axboe@fb.com>, "jack@suse.cz" <jack@suse.cz>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>

On Mon, Apr 25, 2016 at 10:14 AM, Verma, Vishal L
<vishal.l.verma@intel.com> wrote:
> On Mon, 2016-04-25 at 01:31 -0700, hch@infradead.org wrote:
>> On Sat, Apr 23, 2016 at 06:08:37PM +0000, Verma, Vishal L wrote:
>> >
>> > direct_IO might fail with -EINVAL due to misalignment, or -ENOMEM
>> > due
>> > to some allocation failing, and I thought we should return the
>> > original
>> > -EIO in such cases so that the application doesn't lose the
>> > information
>> > that the bad block is actually causing the error.
>> EINVAL is a concern here.  Not due to the right error reported, but
>> because it means your current scheme is fundamentally broken - we
>> need to support I/O at any alignment for DAX I/O, and not fail due to
>> alignbment concernes for a highly specific degraded case.
>>
>> I think this whole series need to go back to the drawing board as I
>> don't think it can actually rely on using direct I/O as the EIO
>> fallback.
>>
> Agreed that DAX I/O can happen with any size/alignment, but how else do
> we send an IO through the driver without alignment restrictions? Also,
> the granularity at which we store badblocks is 512B sectors, so it
> seems natural that to clear such a sector, you'd expect to send a write
> to the whole sector.
>
> The expected usage flow is:
>
> - Application hits EIO doing dax_IO or load/store io
>
> - It checks badblocks and discovers it's files have lost data
>
> - It write()s those sectors (possibly converted to file offsets using
> fiemap)
>     * This triggers the fallback path, but if the application is doing
> this level of recovery, it will know the sector is bad, and write the
> entire sector
>
> - Or it replaces the entire file from backup also using write() (not
> mmap+stores)
>     * This just frees the fs block, and the next time the block is
> reallocated by the fs, it will likely be zeroed first, and that will be
> done through the driver and will clear errors
>
>
> I think if we want to keep allowing arbitrary alignments for the
> dax_do_io path, we'd need:
> 1. To represent badblocks at a finer granularity (likely cache lines)
> 2. To allow the driver to do IO to a *block device* at sub-sector
> granularity

3. Arrange for O_DIRECT to bypass dax_do_io(), and leave the
optimization only for the dax "buffered I/O" case.

4. Skip dax_do_io() entirely in the presence of errors

I think 3 is the most closely aligned with the typical block device
model.  In the typical case a buffered write may fail due to a
badblock read when filling the page cache, but an O_DIRECT write would
bypass the page cache and potentially clear the error / cause the
block to be reallocated internally to the drive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
