Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1F76B0038
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 17:12:28 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so86379063wic.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 14:12:27 -0700 (PDT)
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com. [209.85.212.171])
        by mx.google.com with ESMTPS id hs10si719851wib.46.2015.10.09.14.12.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Oct 2015 14:12:27 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so84615682wic.0
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 14:12:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <5615A31D.60800@deltatee.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
	<20150923044206.36490.79829.stgit@dwillia2-desk3.jf.intel.com>
	<5615A31D.60800@deltatee.com>
Date: Fri, 9 Oct 2015 14:12:26 -0700
Message-ID: <CAPcyv4itVeM+9jkEN_wYHFWHLJEBbhm0M_L-MYOQfqJ1ta-TGw@mail.gmail.com>
Subject: Re: [PATCH 10/15] block, dax: fix lifetime of in-kernel dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Boaz Harrosh <boaz@plexistor.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Stephen Bates <Stephen.Bates@pmcs.com>

On Wed, Oct 7, 2015 at 3:56 PM, Logan Gunthorpe <logang@deltatee.com> wrote:
> Hi Dan,
>
> We've uncovered another issue during testing with these patches. We get a
> kernel panic sometimes just while using a DAX filesystem. I've traced the
> issue back to this patch. (There's a stack trace at the end of this email.)
>
> On 22/09/15 10:42 PM, Dan Williams wrote:
>>
>> +static void dax_unmap_bh(const struct buffer_head *bh, void __pmem *addr)
>> +{
>> +       struct block_device *bdev = bh->b_bdev;
>> +       struct request_queue *q = bdev->bd_queue;
>> +
>> +       if (IS_ERR(addr))
>> +               return;
>> +       blk_dax_put(q);
>>   }
>>
>> @@ -127,9 +159,8 @@ static ssize_t dax_io(struct inode *inode, struct
>> iov_iter *iter,
>>                         if (pos == bh_max) {
>>                                 bh->b_size = PAGE_ALIGN(end - pos);
>>                                 bh->b_state = 0;
>> -                               retval = get_block(inode, block, bh,
>> -                                                  iov_iter_rw(iter) ==
>> WRITE);
>> -                               if (retval)
>> +                               rc = get_block(inode, block, bh, rw ==
>> WRITE);
>> +                               if (rc)
>>                                         break;
>>                                 if (!buffer_size_valid(bh))
>>                                         bh->b_size = 1 << blkbits;
>> @@ -178,8 +213,9 @@ static ssize_t dax_io(struct inode *inode, struct
>> iov_iter *iter,
>>
>>         if (need_wmb)
>>                 wmb_pmem();
>> +       dax_unmap_bh(bh, kmap);
>>
>> -       return (pos == start) ? retval : pos - start;
>> +       return (pos == start) ? rc : pos - start;
>>   }
>
>
> The problem is if get_block fails and returns an error code, it will still
> call dax_unmap_bh which tries to dereference bh->b_bdev. However, seeing
> get_block failed, that pointer is NULL. Maybe a null check in dax_unmap_bh
> would be sufficient?

Thanks for the report, I have this fixed up in v2.  Will post shortly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
