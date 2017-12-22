Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C3E366B025F
	for <linux-mm@kvack.org>; Fri, 22 Dec 2017 03:51:29 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id l99so10425946wrc.18
        for <linux-mm@kvack.org>; Fri, 22 Dec 2017 00:51:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l25si16224587wra.368.2017.12.22.00.51.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 22 Dec 2017 00:51:28 -0800 (PST)
Date: Fri, 22 Dec 2017 09:51:25 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH 14/15] dax: associate mappings with inodes, and warn if
 dma collides with truncate
Message-ID: <20171222085125.GB5320@quack2.suse.cz>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150949217152.24061.9869502311102659784.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171110090818.GE4895@lst.de>
 <CAPcyv4irj_+pJdX1SO6MjsxURcKm8--i_QvyudgHTZE2w4w-sA@mail.gmail.com>
 <20171220143822.GB31584@quack2.suse.cz>
 <CAPcyv4jfvkSSMvruQSFqa5N2zmPmnkDbxCzwvgQAqMQOkT8Xgg@mail.gmail.com>
 <20171221121414.GI31584@quack2.suse.cz>
 <CAPcyv4ifiiD3iOR6nFV=JyQ+tb8B=mWF=Vzm497WYnpypjgn7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4ifiiD3iOR6nFV=JyQ+tb8B=mWF=Vzm497WYnpypjgn7A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu 21-12-17 09:31:50, Dan Williams wrote:
> On Thu, Dec 21, 2017 at 4:14 AM, Jan Kara <jack@suse.cz> wrote:
> > On Wed 20-12-17 14:41:14, Dan Williams wrote:
> >> On Wed, Dec 20, 2017 at 6:38 AM, Jan Kara <jack@suse.cz> wrote:
> >> > On Tue 19-12-17 17:11:38, Dan Williams wrote:
> >> >> On Fri, Nov 10, 2017 at 1:08 AM, Christoph Hellwig <hch@lst.de> wrote:
> >> >> >> +             struct {
> >> >> >> +                     /*
> >> >> >> +                      * ZONE_DEVICE pages are never on an lru or handled by
> >> >> >> +                      * a slab allocator, this points to the hosting device
> >> >> >> +                      * page map.
> >> >> >> +                      */
> >> >> >> +                     struct dev_pagemap *pgmap;
> >> >> >> +                     /*
> >> >> >> +                      * inode association for MEMORY_DEVICE_FS_DAX page-idle
> >> >> >> +                      * callbacks. Note that we don't use ->mapping since
> >> >> >> +                      * that has hard coded page-cache assumptions in
> >> >> >> +                      * several paths.
> >> >> >> +                      */
> >> >> >
> >> >> > What assumptions?  I'd much rather fix those up than having two fields
> >> >> > that have the same functionality.
> >> >>
> >> >> [ Reviving this old thread where you asked why I introduce page->inode
> >> >> instead of reusing page->mapping ]
> >> >>
> >> >> For example, xfs_vm_set_page_dirty() assumes that page->mapping being
> >> >> non-NULL indicates a typical page cache page, this is a false
> >> >> assumption for DAX. My guess at a fix for this is to add
> >> >> pagecache_page() checks to locations like this, but I worry about how
> >> >> to find them all. Where pagecache_page() is:
> >> >>
> >> >> bool pagecache_page(struct page *page)
> >> >> {
> >> >>         if (!page->mapping)
> >> >>                 return false;
> >> >>         if (!IS_DAX(page->mapping->host))
> >> >>                 return false;
> >> >>         return true;
> >> >> }
> >> >>
> >> >> Otherwise we go off the rails:
> >> >>
> >> >>  WARNING: CPU: 27 PID: 1783 at fs/xfs/xfs_aops.c:1468
> >> >> xfs_vm_set_page_dirty+0xf3/0x1b0 [xfs]
> >> >
> >> > But this just shows that mapping->a_ops are wrong for this mapping, doesn't
> >> > it? ->set_page_dirty handler for DAX mapping should just properly handle
> >> > DAX pages... (and only those)
> >>
> >> Ah, yes. Now that I change ->mapping to be non-NULL for DAX pages I
> >> enable all the address_space_operations to start firing. However,
> >> instead of adding DAX specific address_space_operations it appears
> >> ->mapping should never be set for DAX pages, because DAX pages are
> >> disconnected from the page-writeback machinery.
> >
> > page->mapping is not only about page-writeback machinery. It is generally
> > about page <-> inode relation and that still exists for DAX pages. We even
> > reuse the mapping->page_tree to store DAX pages. Also requiring proper
> > address_space_operations for DAX inodes is IMO not a bad thing as such.
> >
> > That being said I'm not 100% convinced we should really set page->mapping
> > for DAX pages. After all they are not page cache pages but rather a
> > physical storage for the data, don't ever get to LRU, etc. But if you need
> > page->inode relation somewhere, that is a good indication to me that it
> > might be just easier to set page->mapping and provide aops that do the
> > right thing (i.e. usually not much) for them.
> >
> > BTW: the ->set_page_dirty() in particular actually *does* need to do
> > something for DAX pages - corresponding radix tree entries should be
> > marked dirty so that caches can get flushed when needed.
> 
> For this specific concern, the get_user_pages() path will have
> triggered mkwrite, so the dax dirty tracking in the radix will have
> already happened by the time we call ->set_page_dirty(). So, it's not
> yet clear to me that we need that particular op.

Right, but it would still be nice to at least verify in ->set_page_dirty()
that the DAX page is marked as dirty in the radix tree (that may be
slightly expensive to keep forever but probably still worth it at least for
some time).

BTW: You just made me realize get_user_pages() is likely the path I have
been looking for for about an year which can indeed dirty a mapped page
from a different path than page fault (I'm now speaking about non-DAX case
but it translates to DAX as well). I have been getting sporadical reports
of filesystems (ext4 and xfs) crashing because a page was dirty but
filesystem was not prepared for that (which happens in ->page_mkwrite or
->write_begin). What I think could happen is that someone used mmaped file
as a buffer for DIO or something like that, that triggered GUP, which
triggered fault and dirtied a page. Then kswapd came, wrote the page,
writeprotected it in page tables, and reclaimed buffers from the page. It
could not free the page itself because DIO still held reference to it.
And then DIO eventually called bio_set_pages_dirty() which marked pages
dirty and filesystem eventually barfed on these... I'll talk to MM people
about this and how could it be possibly fixed - but probably after
Christmas so I'm writing it here so that I don't forget :).

> >> In other words never
> >> setting ->mapping bypasses all the possible broken assumptions and
> >> code paths that take page-cache specific actions before calling an
> >> address_space_operation.
> >
> > If there are any assumptions left after aops are set properly, then we can
> > reconsider this but for now setting ->mapping and proper aops looks cleaner
> > to me...
> 
> I'll try an address_space_operation with a nop ->set_page_dirty() and
> see if anything else falls out.

There are also other aops which would be good to NOPify. readpage and
writepage should probably directly BUG, write_begin and write_end as well
as we expect iomap to be used with DAX. Ditto for invalidatepage,
releasepage, freepage, launder_page, is_dirty_writeback, isolate_page as we
don't expect page reclaim for our pages. Other functions in there would
need some thought...

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
