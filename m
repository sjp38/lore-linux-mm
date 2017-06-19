Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 316F96B0279
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 12:18:49 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id 40so38419879uah.9
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:18:49 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k184si4594101vka.170.2017.06.19.09.18.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 09:18:48 -0700 (PDT)
Date: Mon, 19 Jun 2017 09:18:06 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Subject: Re: [RFC PATCH 1/2] mm: introduce bmap_walk()
Message-ID: <20170619161806.GA4732@birch.djwong.org>
References: <149766212410.22552.15957843500156182524.stgit@dwillia2-desk3.amr.corp.intel.com>
 <149766212976.22552.11210067224152823950.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170617052212.GA8246@lst.de>
 <CAPcyv4g=x+Af1C8_q=+euwNw_Fwk3Wwe45XibtYR5=kbOcmgfg@mail.gmail.com>
 <20170618075152.GA25871@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170618075152.GA25871@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-api@vger.kernel.org, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Sun, Jun 18, 2017 at 09:51:52AM +0200, Christoph Hellwig wrote:
> On Sat, Jun 17, 2017 at 05:29:23AM -0700, Dan Williams wrote:
> > On Fri, Jun 16, 2017 at 10:22 PM, Christoph Hellwig <hch@lst.de> wrote:
> > > On Fri, Jun 16, 2017 at 06:15:29PM -0700, Dan Williams wrote:
> > >> Refactor the core of generic_swapfile_activate() into bmap_walk() so
> > >> that it can be used by a new daxfile_activate() helper (to be added).
> > >
> > > No way in hell!  generic_swapfile_activate needs to day and no new users
> > > of ->bmap over my dead body.  It's a guaranteed to fuck up your data left,
> > > right and center.
> > 
> > Certainly you're not saying that existing swapfiles are broken, so I
> > wonder what bugs you're talking about?
> 
> They are somewhat broken, but we manage to paper over the fact.
> 
> And in fact if you plan to use a method marked:
> 
> 	/* Unfortunately this kludge is needed for FIBMAP. Don't use it */
> 	sector_t (*bmap)(struct address_space *, sector_t);
> 
> I'd expect a little research.
> 
> By it's signature alone ->bmap can't do a whole lot - it can try to
> translate the _current_ mapping of a relative block number to a physical
> one, and do extremely crude error reporting.
> 
> Notice what it can't do:
> 
>  a) provide any guaranteed that the block mapping doesn't change any time
>     after it returned
>  b) deal with the fact that there might be anything like a physical block
>  c) put the physical block into any sort of context, that is explain what
>     device it actually is relative to
> 
> So yes, swap files are broken.  They sort of work by:
> 
>  a) ensuring that ->bmap is not implemented for anything fancy (btrfs), or
>     living  with it doing I/O into random places (XFS RT subvolumes, *cough*)

Ye $deities, it really /doesn't/ check XFS_IS_REALTIME_INODE(ip)!  AIEEEE!

Uh... patch soon.

>  b) doing extremely heavy handed locking to ensure things don't change at all
>     (S_SWAPFILE).  This might kinda sorta work for swapfiles which are
>     part of the system and require privilegues, but an absolute no-go
>     for anything else
>  c) simply not using this brain-haired systems - see the swap over NFS
>     support, or the WIP swap over btrfs patches.
> 
> > Unless you had plans to go remove bmap() I don't see how this gets in
> > your way at all.
> 
> I'm not talking about getting in my way.  I'm talking about you doing
> something incredibly stupid.  Don't do that.
> 
> > That said, I think "please don't add a new bmap()
> > user, use iomap instead" is a fair comment. You know me well enough to
> > know that would be all it takes to redirect my work, I can do without
> > the bluster.
> 
> But that's not the point.  The point is that ->bmap() semantics simplify
> do not work in practice because they don't make sense.

Seconded, bmap doesn't coordinate with the filesystem in any way to
guarantee that the mappings are stable, nor does it seem to care about
delayed alloc reservations.  Granted I suspect the dax usage model is
"all the blocks were already allocated" so there are no da reservations,
but still, ugh, bmap. :)

--D

> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
