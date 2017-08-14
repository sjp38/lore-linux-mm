Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 10ABB6B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 10:36:04 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c80so3844010oig.7
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:36:04 -0700 (PDT)
Received: from mail-io0-x234.google.com (mail-io0-x234.google.com. [2607:f8b0:4001:c06::234])
        by mx.google.com with ESMTPS id w134si4541833oie.269.2017.08.14.07.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 07:36:03 -0700 (PDT)
Received: by mail-io0-x234.google.com with SMTP id g71so38925564ioe.5
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 07:36:03 -0700 (PDT)
Subject: Re: [PATCH v1 2/6] fs: use on-stack-bio if backing device has
 BDI_CAP_SYNC capability
References: <1502175024-28338-3-git-send-email-minchan@kernel.org>
 <20170808124959.GB31390@bombadil.infradead.org>
 <20170808132904.GC31390@bombadil.infradead.org> <20170809015113.GB32338@bbox>
 <20170809023122.GF31390@bombadil.infradead.org> <20170809024150.GA32471@bbox>
 <20170810030433.GG31390@bombadil.infradead.org>
 <CAA9_cmekE9_PYmNnVmiOkyH2gq5o8=uvEKnAbMWw5nBX-zE69g@mail.gmail.com>
 <20170811104615.GA14397@lst.de>
 <20c5b30a-b787-1f46-f997-7542a87033f8@kernel.dk>
 <20170814085042.GG26913@bbox>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <51f7472a-977b-be69-2688-48f2a0fa6fb3@kernel.dk>
Date: Mon, 14 Aug 2017 08:36:00 -0600
MIME-Version: 1.0
In-Reply-To: <20170814085042.GG26913@bbox>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, "karam . lee" <karam.lee@lge.com>, seungho1.park@lge.com, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Vishal Verma <vishal.l.verma@intel.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, kernel-team <kernel-team@lge.com>

On 08/14/2017 02:50 AM, Minchan Kim wrote:
> Hi Jens,
> 
> On Fri, Aug 11, 2017 at 08:26:59AM -0600, Jens Axboe wrote:
>> On 08/11/2017 04:46 AM, Christoph Hellwig wrote:
>>> On Wed, Aug 09, 2017 at 08:06:24PM -0700, Dan Williams wrote:
>>>> I like it, but do you think we should switch to sbvec[<constant>] to
>>>> preclude pathological cases where nr_pages is large?
>>>
>>> Yes, please.
>>>
>>> Then I'd like to see that the on-stack bio even matters for
>>> mpage_readpage / mpage_writepage.  Compared to all the buffer head
>>> overhead the bio allocation should not actually matter in practice.
>>
>> I'm skeptical for that path, too. I also wonder how far we could go
>> with just doing a per-cpu bio recycling facility, to reduce the cost
>> of having to allocate a bio. The on-stack bio parts are fine for
>> simple use case, where simple means that the patch just special
>> cases the allocation, and doesn't have to change much else.
>>
>> I had a patch for bio recycling and batched freeing a year or two
>> ago, I'll see if I can find and resurrect it.
> 
> So, you want to go with per-cpu bio recycling approach to
> remove rw_page?
> 
> So, do you want me to hold this patchset?

I don't want to hold this series up, but I do think the recycling is
a cleaner approach since we don't need to special case anything. I
hope I'll get some time to dust it off, retest, and post soon.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
