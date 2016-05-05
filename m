Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id A944B6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 12:24:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d62so194309145iof.1
        for <linux-mm@kvack.org>; Thu, 05 May 2016 09:24:21 -0700 (PDT)
Received: from mail-oi0-x232.google.com (mail-oi0-x232.google.com. [2607:f8b0:4003:c06::232])
        by mx.google.com with ESMTPS id d184si4966675oig.163.2016.05.05.09.24.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 May 2016 09:24:20 -0700 (PDT)
Received: by mail-oi0-x232.google.com with SMTP id x19so108383346oix.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 09:24:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160505152230.GA3994@infradead.org>
References: <1461878218-3844-1-git-send-email-vishal.l.verma@intel.com>
	<1461878218-3844-6-git-send-email-vishal.l.verma@intel.com>
	<5727753F.6090104@plexistor.com>
	<20160505142433.GA4557@infradead.org>
	<CAPcyv4gdmo5m=Arf5sp5izJfNaaAkaaMbOzud8KRcBEC8RRu1Q@mail.gmail.com>
	<20160505152230.GA3994@infradead.org>
Date: Thu, 5 May 2016 09:24:20 -0700
Message-ID: <CAPcyv4i1wRv56C=0uAz83ANZL=zv-LpbTuSPnMFo7baZXwWSLg@mail.gmail.com>
Subject: Re: [PATCH v4 5/7] fs: prioritize and separate direct_io from dax_io
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Boaz Harrosh <boaz@plexistor.com>, linux-block@vger.kernel.org, linux-ext4 <linux-ext4@vger.kernel.org>, Jan Kara <jack@suse.cz>, Matthew Wilcox <matthew@wil.cx>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, XFS Developers <xfs@oss.sgi.com>, Jens Axboe <axboe@fb.com>, Linux MM <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-nvdimm <linux-nvdimm@ml01.01.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On Thu, May 5, 2016 at 8:22 AM, Christoph Hellwig <hch@infradead.org> wrote:
> On Thu, May 05, 2016 at 08:15:32AM -0700, Dan Williams wrote:
>> > Agreed - makig O_DIRECT less direct than not having it is plain stupid,
>> > and I somehow missed this initially.
>>
>> Of course I disagree because like Dave argues in the msync case we
>> should do the correct thing first and make it fast later, but also
>> like Dave this arguing in circles is getting tiresome.
>
> We should do the right thing first, and make it fast later.  But this
> proposal is not getting it right - it still does not handle errors
> for the fast path, but magically makes it work for direct I/O by
> in general using a less optional path for O_DIRECT.  It's getting the
> worst of all choices.
>
> As far as I can tell the only sensible option is to:
>
>  - always try dax-like I/O first
>  - have a custom get_user_pages + rw_bytes fallback handles bad blocks
>    when hitting EIO

If you're on board with more special fallbacks for dax-capable block
devices that indeed opens up the thinking.  The O_DIRECT approach was
meant to keep the error clearing model close to the traditional block
device case, but yes that does constrain the implementation in
sub-optimal ways.

However, we still have the alignment problem in the rw_bytes case, how
do we communicate to the application that only writes with a certain
size/alignment will clear errors?  That forced alignment assumption
was the other appeal of O_DIRECT.  Perhaps we can at least start with
hole punching and block reallocation as the error clearing method
while we think more about the write-to-clear case?

> And then we need to sort out the concurrent write synchronization.
> Again there I think we absolutely have to obey Posix for the !O_DIRECT
> case and can avoid it for O_DIRECT, similar to the existing non-DAX
> semantics.  If we want any special additional semantics we _will_ need
> a special O_DAX flag.

Ok, makes sense.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
