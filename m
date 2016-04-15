Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id D87BD6B0005
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 13:57:28 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id th5so39236495obc.1
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:57:28 -0700 (PDT)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id kh7si4661595obb.29.2016.04.15.10.57.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Apr 2016 10:57:28 -0700 (PDT)
Received: by mail-ob0-x22a.google.com with SMTP id j9so68245532obd.3
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 10:57:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1460741821.3012.11.camel@intel.com>
References: <1459303190-20072-1-git-send-email-vishal.l.verma@intel.com>
	<1459303190-20072-6-git-send-email-vishal.l.verma@intel.com>
	<x49twj26edj.fsf@segfault.boston.devel.redhat.com>
	<1460739288.3012.3.camel@intel.com>
	<x49potq6bm2.fsf@segfault.boston.devel.redhat.com>
	<1460741821.3012.11.camel@intel.com>
Date: Fri, 15 Apr 2016 10:57:27 -0700
Message-ID: <CAPcyv4hemNM4uQYCPBXyH+DWTOLvyBNBeMYstKbPdad_Cw48HQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] dax: handle media errors in dax_do_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Verma, Vishal L" <vishal.l.verma@intel.com>
Cc: "jmoyer@redhat.com" <jmoyer@redhat.com>, "hch@infradead.org" <hch@infradead.org>, "jack@suse.cz" <jack@suse.cz>, "axboe@fb.com" <axboe@fb.com>, "linux-nvdimm@ml01.01.org" <linux-nvdimm@ml01.01.org>, "david@fromorbit.com" <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-block@vger.kernel.org" <linux-block@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "viro@zeniv.linux.org.uk" <viro@zeniv.linux.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>

On Fri, Apr 15, 2016 at 10:37 AM, Verma, Vishal L
<vishal.l.verma@intel.com> wrote:
> On Fri, 2016-04-15 at 13:11 -0400, Jeff Moyer wrote:
[..]
>> >
>> > But, how does _EIOCBQUEUED work? Maybe we need an exception for it?
>> For async direct I/O, only the setup phase of the I/O is performed
>> and
>> then we return to the caller.  -EIOCBQUEUED signifies this.
>>
>> You're heading towards code that looks like this:
>>
>>         if (IS_DAX(inode)) {
>>                 ret = dax_do_io(iocb, inode, iter, offset,
>> blkdev_get_block,
>>                                 NULL, DIO_SKIP_DIO_COUNT);
>>                 if (ret == -EIO && (iov_iter_rw(iter) == WRITE))
>>                         ret_saved = ret;
>>                 else
>>                         return ret;
>>         }
>>
>>         ret = __blockdev_direct_IO(iocb, inode, I_BDEV(inode), iter,
>> offset,
>>                                     blkdev_get_block, NULL, NULL,
>>                                     DIO_SKIP_DIO_COUNT);
>>         if (ret < 0 && ret != -EIOCBQUEUED && ret_saved)
>>                 return ret_saved;
>>
>> There's a lot of special casing here, so you might consider adding
>> comments.
>
> Correct - maybe we should reconsider wrapper-izing this? :)

Another option is just to skip dax_do_io() and this special casing
fallback entirely if errors are present.  I.e. only attempt dax_do_io
when: IS_DAX() && gendisk->bb && bb->count == 0.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
