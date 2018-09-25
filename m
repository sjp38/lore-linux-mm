Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF798E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 03:49:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d132-v6so9325387pgc.22
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 00:49:15 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id 14-v6si1698899pgm.488.2018.09.25.00.49.12
        for <linux-mm@kvack.org>;
        Tue, 25 Sep 2018 00:49:13 -0700 (PDT)
Date: Tue, 25 Sep 2018 17:49:10 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180925074910.GB31060@dastard>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de>
 <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180921130504.GA22551@lst.de>
 <010001660c54fb65-b9d3a770-6678-40d0-8088-4db20af32280-000000@email.amazonses.com>
 <1f88f59a-2cac-e899-4c2e-402e919b1034@kernel.dk>
 <010001660cbd51ea-56e96208-564d-4f5d-a5fb-119a938762a9-000000@email.amazonses.com>
 <1a5b255f-682e-783a-7f99-9d02e39c4af2@kernel.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1a5b255f-682e-783a-7f99-9d02e39c4af2@kernel.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@kernel.dk>
Cc: Christopher Lameter <cl@linux.com>, Christoph Hellwig <hch@lst.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ming Lei <ming.lei@redhat.com>

On Mon, Sep 24, 2018 at 12:09:37PM -0600, Jens Axboe wrote:
> On 9/24/18 12:00 PM, Christopher Lameter wrote:
> > On Mon, 24 Sep 2018, Jens Axboe wrote:
> > 
> >> The situation is making me a little uncomfortable, though. If we export
> >> such a setting, we really should be honoring it...

That's what I said up front, but you replied to this with:

| I think this is all crazy talk. We've never done this, [...]

Now I'm not sure what you are saying we should do....

> > Various subsystems create custom slab arrays with their particular
> > alignment requirement for these allocations.
> 
> Oh yeah, I think the solution is basic enough for XFS, for instance.
> They just have to error on the side of being cautious, by going full
> sector alignment for memory...

How does the filesystem find out about hardware alignment
requirements? Isn't probing through the block device to find out
about the request queue configurations considered a layering
violation?

What if sector alignment is not sufficient?  And how would this work
if we start supporting sector sizes larger than page size? (which the
XFS buffer cache supports just fine, even if nothing else in
Linux does).

But even ignoring sector size > page size, implementing this
requires a bunch of new slab caches, especially for 64k page
machines because XFS supports sector sizes up to 32k.  And every
other filesystem that uses sector sized buffers (e.g. HFS) would
have to do the same thing. Seems somewhat wasteful to require
everyone to implement their own aligned sector slab cache...

Perhaps we should take the filesystem out of this completely - maybe
the block layer could provide a generic "sector heap" and have all
filesystems that use sector sized buffers allocate from it. e.g.
something like

	mem = bdev_alloc_sector_buffer(bdev, sector_size)

That way we don't have to rely on filesystems knowing anything about
the alignment limitations of the devices or assumptions about DMA
to work correctly...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
