Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id CD3ED6B02FA
	for <linux-mm@kvack.org>; Sun, 18 Jun 2017 03:51:54 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id d184so8479911wmd.15
        for <linux-mm@kvack.org>; Sun, 18 Jun 2017 00:51:54 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t126si7609025wmg.54.2017.06.18.00.51.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Jun 2017 00:51:53 -0700 (PDT)
Date: Sun, 18 Jun 2017 09:51:52 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [RFC PATCH 1/2] mm: introduce bmap_walk()
Message-ID: <20170618075152.GA25871@lst.de>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com> <149766212976.22552.11210067224152823950.stgit@dwillia2-desk3.amr.corp.intel.com> <20170617052212.GA8246@lst.de> <CAPcyv4g=x+Af1C8_q=+euwNw_Fwk3Wwe45XibtYR5=kbOcmgfg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4g=x+Af1C8_q=+euwNw_Fwk3Wwe45XibtYR5=kbOcmgfg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sat, Jun 17, 2017 at 05:29:23AM -0700, Dan Williams wrote:
> On Fri, Jun 16, 2017 at 10:22 PM, Christoph Hellwig <hch@lst.de> wrote:
> > On Fri, Jun 16, 2017 at 06:15:29PM -0700, Dan Williams wrote:
> >> Refactor the core of generic_swapfile_activate() into bmap_walk() so
> >> that it can be used by a new daxfile_activate() helper (to be added).
> >
> > No way in hell!  generic_swapfile_activate needs to day and no new users
> > of ->bmap over my dead body.  It's a guaranteed to fuck up your data left,
> > right and center.
> 
> Certainly you're not saying that existing swapfiles are broken, so I
> wonder what bugs you're talking about?

They are somewhat broken, but we manage to paper over the fact.

And in fact if you plan to use a method marked:

	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
	sector_t (*bmap)(struct address_space *, sector_t);

I'd expect a little research.

By it's signature alone ->bmap can't do a whole lot - it can try to
translate the _current_ mapping of a relative block number to a physical
one, and do extremely crude error reporting.

Notice what it can't do:

 a) provide any guaranteed that the block mapping doesn't change any time
    after it returned
 b) deal with the fact that there might be anything like a physical block
 c) put the physical block into any sort of context, that is explain what
    device it actually is relative to

So yes, swap files are broken.  They sort of work by:

 a) ensuring that ->bmap is not implemented for anything fancy (btrfs), or
    living  with it doing I/O into random places (XFS RT subvolumes, *cough*)
 b) doing extremely heavy handed locking to ensure things don't change at all
    (S_SWAPFILE).  This might kinda sorta work for swapfiles which are
    part of the system and require privilegues, but an absolute no-go
    for anything else
 c) simply not using this brain-haired systems - see the swap over NFS
    support, or the WIP swap over btrfs patches.

> Unless you had plans to go remove bmap() I don't see how this gets in
> your way at all.

I'm not talking about getting in my way.  I'm talking about you doing
something incredibly stupid.  Don't do that.

> That said, I think "please don't add a new bmap()
> user, use iomap instead" is a fair comment. You know me well enough to
> know that would be all it takes to redirect my work, I can do without
> the bluster.

But that's not the point.  The point is that ->bmap() semantics simplify
do not work in practice because they don't make sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
