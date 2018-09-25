Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4434E8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 17:04:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e6-v6so3286364pge.5
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 14:04:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id x63-v6si3111559pfb.299.2018.09.25.14.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 25 Sep 2018 14:04:20 -0700 (PDT)
Date: Tue, 25 Sep 2018 14:04:18 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: block: DMA alignment of IO buffer allocated from slab
Message-ID: <20180925210418.GA9854@bombadil.infradead.org>
References: <CACVXFVOBq3L_EjSTCoiqUL1PH=HMR5EuNNQV0hNndFpGxmUK6g@mail.gmail.com>
 <20180920063129.GB12913@lst.de>
 <87h8ij0zot.fsf@vitty.brq.redhat.com>
 <20180921130504.GA22551@lst.de>
 <010001660c54fb65-b9d3a770-6678-40d0-8088-4db20af32280-000000@email.amazonses.com>
 <1f88f59a-2cac-e899-4c2e-402e919b1034@kernel.dk>
 <010001660cbd51ea-56e96208-564d-4f5d-a5fb-119a938762a9-000000@email.amazonses.com>
 <1a5b255f-682e-783a-7f99-9d02e39c4af2@kernel.dk>
 <20180925074910.GB31060@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180925074910.GB31060@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jens Axboe <axboe@kernel.dk>, Christopher Lameter <cl@linux.com>, Christoph Hellwig <hch@lst.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Ming Lei <tom.leiming@gmail.com>, linux-block <linux-block@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, "open list:XFS FILESYSTEM" <linux-xfs@vger.kernel.org>, Dave Chinner <dchinner@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ming Lei <ming.lei@redhat.com>

On Tue, Sep 25, 2018 at 05:49:10PM +1000, Dave Chinner wrote:
> On Mon, Sep 24, 2018 at 12:09:37PM -0600, Jens Axboe wrote:
> > On 9/24/18 12:00 PM, Christopher Lameter wrote:
> > > On Mon, 24 Sep 2018, Jens Axboe wrote:
> > > 
> > >> The situation is making me a little uncomfortable, though. If we export
> > >> such a setting, we really should be honoring it...
> 
> That's what I said up front, but you replied to this with:
> 
> | I think this is all crazy talk. We've never done this, [...]
> 
> Now I'm not sure what you are saying we should do....
> 
> > > Various subsystems create custom slab arrays with their particular
> > > alignment requirement for these allocations.
> > 
> > Oh yeah, I think the solution is basic enough for XFS, for instance.
> > They just have to error on the side of being cautious, by going full
> > sector alignment for memory...
> 
> How does the filesystem find out about hardware alignment
> requirements? Isn't probing through the block device to find out
> about the request queue configurations considered a layering
> violation?
> 
> What if sector alignment is not sufficient?  And how would this work
> if we start supporting sector sizes larger than page size? (which the
> XFS buffer cache supports just fine, even if nothing else in
> Linux does).

I've never quite understood the O_DIRECT sector size alignment
restriction.  The sector size has literally nothing to do with the
limitations of the controller that's doing the DMA.  OK, NVMe smooshes the
two components into one, but back in the SCSI era, the DMA abilities were
the HBA's responsibility and the sector size was a property of the LUN!

Heck, with a sufficiently advanced HBA (eg supporting scatterlists with
bitbuckets), you could even ask for sub-sector-*sized* IOs.  Not terribly
useful since the bytes still had to be transferred over the SCSI cable,
but you'd save transferring them across the PCI bus.

Anyway, why would we require *larger* than 512 byte alignment for
in-kernel users?  I doubt there are any remaining HBAs that can't do
8-byte aligned I/Os (for the record, NVMe requires controllers to be
able to do 4-byte aligned I/Os).
