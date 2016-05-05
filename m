Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 092006B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 11:15:34 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id t140so158549651oie.0
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:15:34 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id h77si4570007oib.116.2016.05.05.08.15.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 08:15:33 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id x19so105922451oix.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 08:15:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160505142433.GA4557@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	<1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	<5727753F.6090104@plexistor.com>
	<20160505142433.GA4557@infradead.org>
Date: Thu, 5 May 2016 08:15:32 -0700
Message-ID: <CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Boaz Harrosh <boaz@plexistor.com>, linux-block@vger.kernel.org, linux-ext4 <linux-ext4@vger.kernel.org>, Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>, Jens Axboe <axboe@fb.com>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 5, 2016 at 7:24 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, May 02, 2016 at 06:41:51PM +0300, Boaz Harrosh wrote:
>> > All IO in a dax filesystem used to go through dax_do_io, which cannot
>> > handle media errors, and thus cannot provide a recovery path that can
>> > send a write through the driver to clear errors.
>> >
>> > Add a new iocb flag for DAX, and set it only for DAX mounts. In the IO
>> > path for DAX filesystems, use the same direct_IO path for both DAX and
>> > direct_io iocbs, but use the flags to identify when we are in O_DIRECT
>> > mode vs non O_DIRECT with DAX, and for O_DIRECT, use the conventional
>> > direct_IO path instead of DAX.
>> >
>>
>> Really? What are your thinking here?
>>
>> What about all the current users of O_DIRECT, you have just made them
>> 4 times slower and "less concurrent*" then "buffred io" users. Since
>> direct_IO path will queue an IO request and all.
>> (And if it is not so slow then why do we need dax_do_io at all? [Rhetorical])
>>
>> I hate it that you overload the semantics of a known and expected
>> O_DIRECT flag, for special pmem quirks. This is an incompatible
>> and unrelated overload of the semantics of O_DIRECT.
>
> Agreed - makig O_DIRECT less direct than not having it is plain stupid,
> and I somehow missed this initially.

Of course I disagree because like Dave argues in the msync case we
should do the correct thing first and make it fast later, but also
like Dave this arguing in circles is getting tiresome.

> This whole DAX story turns into a major nightmare, and I fear all our
> hodge podge tweaks to the semantics aren't helping it.
>
> It seems like we simply need an explicit O_DAX for the read/write
> bypass if can't sort out the semantics (error, writer synchronization)
> just as we need a special flag for MMAP.

I don't see how O_DAX makes this situation better if the goal is to
accelerate unmodified applications...

Vishal, at least the "delete a file with a badblock" model will still
work for implicitly clearing errors with your changes to stop doing
block clearing in fs/dax.c.  This combined with a new -EBADBLOCK (as
Dave suggests) and explicit logging of I/Os that fail for this reason
at least gives a chance to communicate errors in files to suitably
aware applications / environments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
