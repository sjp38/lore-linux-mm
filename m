Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65E156B0260
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 17:41:16 -0500 (EST)
Received: by mail-ot0-f198.google.com with SMTP id z7so5362814otz.18
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 14:41:16 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u40sor2815257otc.125.2017.12.20.14.41.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Dec 2017 14:41:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171220143822.GB31584@quack2.suse.cz>
References: <150949209290.24061.6283157778959640151.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150949217152.24061.9869502311102659784.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171110090818.GE4895@lst.de> <CAPcyv4irj_+pJdX1SO6MjsxURcKm8--i_QvyudgHTZE2w4w-sA@mail.gmail.com>
 <20171220143822.GB31584@quack2.suse.cz>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 20 Dec 2017 14:41:14 -0800
Message-ID: <CAPcyv4jfvkSSMvruQSFqa5N2zmPmnkDbxCzwvgQAqMQOkT8Xgg@mail.gmail.com>
Subject: Re: [PATCH 14/15] dax: associate mappings with inodes, and warn if
 dma collides with truncate
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Matthew Wilcox <mawilcox@microsoft.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs <linux-xfs@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Wed, Dec 20, 2017 at 6:38 AM, Jan Kara <jack@suse.cz> wrote:
> On Tue 19-12-17 17:11:38, Dan Williams wrote:
>> On Fri, Nov 10, 2017 at 1:08 AM, Christoph Hellwig <hch@lst.de> wrote:
>> >> +             struct {
>> >> +                     /*
>> >> +                      * ZONE_DEVICE pages are never on an lru or handled by
>> >> +                      * a slab allocator, this points to the hosting device
>> >> +                      * page map.
>> >> +                      */
>> >> +                     struct dev_pagemap *pgmap;
>> >> +                     /*
>> >> +                      * inode association for MEMORY_DEVICE_FS_DAX page-idle
>> >> +                      * callbacks. Note that we don't use ->mapping since
>> >> +                      * that has hard coded page-cache assumptions in
>> >> +                      * several paths.
>> >> +                      */
>> >
>> > What assumptions?  I'd much rather fix those up than having two fields
>> > that have the same functionality.
>>
>> [ Reviving this old thread where you asked why I introduce page->inode
>> instead of reusing page->mapping ]
>>
>> For example, xfs_vm_set_page_dirty() assumes that page->mapping being
>> non-NULL indicates a typical page cache page, this is a false
>> assumption for DAX. My guess at a fix for this is to add
>> pagecache_page() checks to locations like this, but I worry about how
>> to find them all. Where pagecache_page() is:
>>
>> bool pagecache_page(struct page *page)
>> {
>>         if (!page->mapping)
>>                 return false;
>>         if (!IS_DAX(page->mapping->host))
>>                 return false;
>>         return true;
>> }
>>
>> Otherwise we go off the rails:
>>
>>  WARNING: CPU: 27 PID: 1783 at fs/xfs/xfs_aops.c:1468
>> xfs_vm_set_page_dirty+0xf3/0x1b0 [xfs]
>
> But this just shows that mapping->a_ops are wrong for this mapping, doesn't
> it? ->set_page_dirty handler for DAX mapping should just properly handle
> DAX pages... (and only those)

Ah, yes. Now that I change ->mapping to be non-NULL for DAX pages I
enable all the address_space_operations to start firing. However,
instead of adding DAX specific address_space_operations it appears
->mapping should never be set for DAX pages, because DAX pages are
disconnected from the page-writeback machinery. In other words never
setting ->mapping bypasses all the possible broken assumptions and
code paths that take page-cache specific actions before calling an
address_space_operation.

>
>>  [..]
>>  CPU: 27 PID: 1783 Comm: dma-collision Tainted: G           O
>> 4.15.0-rc2+ #984
>>  [..]
>>  Call Trace:
>>   set_page_dirty_lock+0x40/0x60
>>   bio_set_pages_dirty+0x37/0x50
>>   iomap_dio_actor+0x2b7/0x3b0
>>   ? iomap_dio_zero+0x110/0x110
>>   iomap_apply+0xa4/0x110
>>   iomap_dio_rw+0x29e/0x3b0
>>   ? iomap_dio_zero+0x110/0x110
>>   ? xfs_file_dio_aio_read+0x7c/0x1a0 [xfs]
>>   xfs_file_dio_aio_read+0x7c/0x1a0 [xfs]
>>   xfs_file_read_iter+0xa0/0xc0 [xfs]
>>   __vfs_read+0xf9/0x170
>>   vfs_read+0xa6/0x150
>>   SyS_pread64+0x93/0xb0
>>   entry_SYSCALL_64_fastpath+0x1f/0x96
>
>                                                                 Honza
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
