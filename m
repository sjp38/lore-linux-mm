Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f174.google.com (mail-yw0-f174.google.com [209.85.161.174])
	by kanga.kvack.org (Postfix) with ESMTP id 527186B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 17:59:15 -0500 (EST)
Received: by mail-yw0-f174.google.com with SMTP id u200so52026810ywf.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:59:15 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id d71si4712499ybh.106.2016.02.11.14.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Feb 2016 14:59:14 -0800 (PST)
Received: by mail-yk0-x22f.google.com with SMTP id z7so27549584yka.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 14:59:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160211224616.GL19486@dastard>
References: <1455137336-28720-1-git-send-email-ross.zwisler@linux.intel.com>
	<1455137336-28720-3-git-send-email-ross.zwisler@linux.intel.com>
	<20160210220312.GP14668@dastard>
	<20160210224340.GA30938@linux.intel.com>
	<20160211125044.GJ21760@quack.suse.cz>
	<CAPcyv4g60iOTd-ShBCfsK+B7xArcc5pWXWktNop53otDbUW-3g@mail.gmail.com>
	<20160211204635.GI19486@dastard>
	<CAPcyv4h4u+LB5U5nm4Jo32r=33D02yv36k5QxmJoy3DRiHmQEQ@mail.gmail.com>
	<20160211224616.GL19486@dastard>
Date: Thu, 11 Feb 2016 14:59:14 -0800
Message-ID: <CAPcyv4hR60bahtQq68SgSG2uT9zP4H8u3zbUqtqndnx=ogwVtA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] dax: move writeback calls into the filesystems
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Alexander Viro <viro@zeniv.linux.org.uk>, Andreas Dilger <adilger.kernel@dilger.ca>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>, linux-ext4 <linux-ext4@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, XFS Developers <xfs@oss.sgi.com>

On Thu, Feb 11, 2016 at 2:46 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Thu, Feb 11, 2016 at 12:58:38PM -0800, Dan Williams wrote:
>> On Thu, Feb 11, 2016 at 12:46 PM, Dave Chinner <david@fromorbit.com> wrote:
>> [..]
>> >> It seems to me we need to modify the
>> >> metadata i/o paths to bypass the page cache,
>> >
>> > XFS doesn't use the block device page cache for it's metadata - it
>> > has it's own internal metadata cache structures and uses get_pages
>> > or heap memory to back it's metadata. But that doesn't make mixing
>> > DAX and pages in the block device mapping tree sane.
>> >
>> > What you are missing here is that the underlying architecture of
>> > journalling filesystems mean they can't use DAX for their metadata.
>> > Modifications have to be buffered, because they have to be written
>> > to the journal first before they are written back in place. IOWs, we
>> > need to buffer changes in volatile memory for some time, and that
>> > means we can't use DAX during transactional modifications.
>> >
>> > And to put the final nail in that coffin, metadata in XFS can be
>> > discontiguous multi-block objects - in those situations we vmap the
>> > underlying pages so they appear to the code to be a contiguous
>> > buffer, and that's something we can't do with DAX....
>>
>> Sorry, I wasn't clear when I said "bypass page cache" I meant a
>> solution similar to commit d1a5f2b4d8a1 "block: use DAX for partition
>> table reads".
>
> So there's already bandaids to prevent bad shit from happening in
> the block layer, let alone when we consider all the ways that
> userspace can screw this all up.
>
>> However, I suspect that is broken if the filesystem is not ready
>> to see a new page allocated for every I/O.  I assume one
>> thread will want to insert a page in the radix for another thread
>> to find/manipulate before metadata gets written back to storage.
>
> Right, you can't do that, especially as the struct page has a 1-1
> relationship with the bufferhead that is attached to it as the
> bufferhead carries the filesystem state for the given cached page.
>
>> >> or teach the fsync code how to flush populated data pages out
>> >> of the radix.
>> >
>> > That doesn't solve the problem. Filesystems free and reallocate
>> > filesystem blocks without intermediate block device mapping
>> > invalidation calls, so what is one minute a data block accessed
>> > by DAX may become a metadata block that accessed via buffered
>> > IO.  It all goes to crap very quickly....
>> >
>> > However, I'd say fsync is not the place to address this. This
>> > block device cache aliasing issue is supposed to be what
>> > unmap_underlying_metadata() solves, right?
>>
>> I'll take a look at this.  Right now I'm trying to implement the
>> "clear block-device-inode S_DAX on fs mount" approach.  My concern
>> though is that  we need to disable block device mmap while a
>> filesystem is mounted...
>
> /me chokes on his coffee.
>
> When did mmaping the block device behind the back of a mounted
> fileystem become a valid use case? It's not supported for normal
> block devices and for the same reasons it won't be supported for DAX
> enabled block devices, either. i.e. I'm going to tell anyone who has
> an application that does this to go and take a hike when (not if!)
> they report filesystem corruption problems.

Right, but we need to not confuse the fsync code regardless of how bad
of an idea this is ::-).

>> Maybe I don't need to worry because it's already the case that a
>> mmap of the raw device may not see the most up to date data for a
>> file that has dirty fs-page-cache data.
>
> It goes both ways. What happens if mkfs or fsck modifies the
> block device via mmap+DAX and then the filesystem mounts the block
> device and tries to read that metadata via the block device page
> cache?
>
> Quite frankly, DAX on the block device is a can of worms we really
> don't need to deal with right now. IMO it's a solution looking for a
> problem to solve,

Virtualization use cases want to give large ranges to guest-VMs, and
it is currently the only way to reliably get 1GiB mappings.

> the "default to on" policy is wrong (DAX is
> opt-in, not opt-out) and given this we should turn it off until
> we've solved the more important problems we need to solve. i.e. We
> need to concentrate on getting data integrity working correctly
> first, then address the cache aliasing issues, then address the
> "safe access" issues, and then we can re-introduce block device DAX
> access...

Agreed.

Note that the "default-on policy" came from commit bbab37ddc20b
"block: Add support for DAX reads/writes to block devices" way back in
4.2.  We're just now noticing.  Credit Ross for good sanity checking.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
