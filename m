Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id ADA636B0031
	for <linux-mm@kvack.org>; Thu, 10 Apr 2014 08:15:58 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so2964519eek.2
        for <linux-mm@kvack.org>; Thu, 10 Apr 2014 05:15:57 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v2si5754816eel.226.2014.04.10.05.15.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 10 Apr 2014 05:15:56 -0700 (PDT)
Date: Thu, 10 Apr 2014 14:15:54 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [RFC] Helper to abstract vma handling in media layer
Message-ID: <20140410121554.GC28404@quack.suse.cz>
References: <1395085776-8626-1-git-send-email-jack@suse.cz>
 <53466C4A.2030107@samsung.com>
 <20140410103220.GB28404@quack.suse.cz>
 <53467B7E.5060408@xs4all.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53467B7E.5060408@xs4all.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hans Verkuil <hverkuil@xs4all.nl>
Cc: Jan Kara <jack@suse.cz>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-media@vger.kernel.org, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, 'Tomasz Stanislawski' <t.stanislaws@samsung.com>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>

On Thu 10-04-14 13:07:42, Hans Verkuil wrote:
> On 04/10/14 12:32, Jan Kara wrote:
> >   Hello,
> > 
> > On Thu 10-04-14 12:02:50, Marek Szyprowski wrote:
> >> On 2014-03-17 20:49, Jan Kara wrote:
> >>>   The following patch series is my first stab at abstracting vma handling
> >> >from the various media drivers. After this patch set drivers have to know
> >>> much less details about vmas, their types, and locking. My motivation for
> >>> the series is that I want to change get_user_pages() locking and I want
> >>> to handle subtle locking details in as few places as possible.
> >>>
> >>> The core of the series is the new helper get_vaddr_pfns() which is given a
> >>> virtual address and it fills in PFNs into provided array. If PFNs correspond to
> >>> normal pages it also grabs references to these pages. The difference from
> >>> get_user_pages() is that this function can also deal with pfnmap, mixed, and io
> >>> mappings which is what the media drivers need.
> >>>
> >>> The patches are just compile tested (since I don't have any of the hardware
> >>> I'm afraid I won't be able to do any more testing anyway) so please handle
> >>> with care. I'm grateful for any comments.
> >>
> >> Thanks for posting this series! I will check if it works with our
> >> hardware soon.  This is something I wanted to introduce some time ago to
> >> simplify buffer handling in dma-buf, but I had no time to start working.
> >   Thanks for having a look in the series.
> > 
> >> However I would like to go even further with integration of your pfn
> >> vector idea.  This structure looks like a best solution for a compact
> >> representation of the memory buffer, which should be considered by the
> >> hardware as contiguous (either contiguous in physical memory or mapped
> >> contiguously into dma address space by the respective iommu). As you
> >> already noticed it is widely used by graphics and video drivers.
> >>
> >> I would also like to add support for pfn vector directly to the
> >> dma-mapping subsystem. This can be done quite easily (even with a
> >> fallback for architectures which don't provide method for it). I will try
> >> to prepare rfc soon.  This will finally remove the need for hacks in
> >> media/v4l2-core/videobuf2-dma-contig.c
> >   That would be a worthwhile thing to do. When I was reading the code this
> > seemed like something which could be done but I delibrately avoided doing
> > more unification than necessary for my purposes as I don't have any
> > hardware to test and don't know all the subtleties in the code... BTW, is
> > there some way to test the drivers without the physical video HW?
> 
> You can use the vivi driver (drivers/media/platform/vivi) for this.
> However, while the vivi driver can import dma buffers it cannot export
> them. If you want that, then you have to use this tree:
> 
> http://git.linuxtv.org/cgit.cgi/hverkuil/media_tree.git/log/?h=vb2-part4
  Thanks for the pointer that looks good. I've also found
drivers/media/platform/mem2mem_testdev.c which seems to do even more
testing of the area I made changes to. So now I have to find some userspace
tool which can issue proper ioctls to setup and use the buffers and I can
start testing what I wrote :)

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
