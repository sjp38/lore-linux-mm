Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f182.google.com (mail-yk0-f182.google.com [209.85.160.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2843B4402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 17:16:11 -0500 (EST)
Received: by mail-yk0-f182.google.com with SMTP id x184so37104392yka.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 14:16:11 -0800 (PST)
Received: from mail-yk0-x233.google.com (mail-yk0-x233.google.com. [2607:f8b0:4002:c07::233])
        by mx.google.com with ESMTPS id m187si9484991ywm.338.2015.12.17.14.16.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 14:16:10 -0800 (PST)
Received: by mail-yk0-x233.google.com with SMTP id x184so37104078yka.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 14:16:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151217220057.GA17702@linux.intel.com>
References: <20151210023731.30368.7209.stgit@dwillia2-desk3.jf.intel.com>
	<20151211181108.19091.50770.stgit@dwillia2-desk3.jf.intel.com>
	<20151217220057.GA17702@linux.intel.com>
Date: Thu, 17 Dec 2015 14:16:09 -0800
Message-ID: <CAPcyv4j1NUpaA2yzCSTS+qfBnGguiNzDRTa5uN=PGdbHAbw_iw@mail.gmail.com>
Subject: Re: [-mm PATCH v3 04/25] dax: fix lifetime of in-kernel dax mappings
 with dax_map_atomic()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@fb.com>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Jan Kara <jack@suse.com>, Matthew Wilcox <willy@linux.intel.com>

On Thu, Dec 17, 2015 at 2:00 PM, Ross Zwisler
<ross.zwisler@linux.intel.com> wrote:
> On Fri, Dec 11, 2015 at 10:11:53AM -0800, Dan Williams wrote:
>> The DAX implementation needs to protect new calls to ->direct_access()
>> and usage of its return value against the driver for the underlying
>> block device being disabled.  Use blk_queue_enter()/blk_queue_exit() to
>> hold off blk_cleanup_queue() from proceeding, or otherwise fail new
>> mapping requests if the request_queue is being torn down.
>>
>> This also introduces blk_dax_ctl to simplify the interface from fs/dax.c
>> through dax_map_atomic() to bdev_direct_access().
>>
>> Cc: Jan Kara <jack@suse.com>
>> Cc: Jens Axboe <axboe@fb.com>
>> Cc: Dave Chinner <david@fromorbit.com>
>> Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
>> Cc: Matthew Wilcox <willy@linux.intel.com>
>> [willy: fix read() of a hole]
>> Reviewed-by: Jeff Moyer <jmoyer@redhat.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> <>
>> @@ -308,20 +351,18 @@ static int dax_insert_mapping(struct inode *inode, struct buffer_head *bh,
>>               goto out;
>>       }
>>
>> -     error = bdev_direct_access(bh->b_bdev, sector, &addr, &pfn, bh->b_size);
>> -     if (error < 0)
>> -             goto out;
>> -     if (error < PAGE_SIZE) {
>> -             error = -EIO;
>> +     if (dax_map_atomic(bdev, &dax) < 0) {
>> +             error = PTR_ERR(dax.addr);
>>               goto out;
>>       }
>>
>>       if (buffer_unwritten(bh) || buffer_new(bh)) {
>> -             clear_pmem(addr, PAGE_SIZE);
>> +             clear_pmem(dax.addr, PAGE_SIZE);
>>               wmb_pmem();
>>       }
>> +     dax_unmap_atomic(bdev, &dax);
>>
>> -     error = vm_insert_mixed(vma, vaddr, pfn);
>> +     error = vm_insert_mixed(vma, vaddr, dax.pfn);
>
> Since we're still using the contents of the struct blk_dax_ctl as an argument
> to vm_insert_mixed(), shouldn't dax_unmap_atomic() be after this call?
>
> Unless there is some reason to protect dax.addr with a blk queue reference,
> but not dax.pfn?

dax_map_atomic only protects dax.addr which is valid only while the
driver is active.  dax.pfn is always valid as long as the memory
physically exists or is known to reference the same sector of the
device.

After the block_device is torn down the pfn may no longer be valid
(think brd with dynamically allocated pages, or hot remove of pmem).
This is the rationale for this other pending patch series [1] to go
shoot down all mappings to a pfn at del_gendisk() time.  It relies on
dax_map_atomic() to prevent any new mapping requests from succeeding
after the shoot down has taken place.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-December/003065.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
