Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B5A4D800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 07:18:09 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id h38so6526491wrh.11
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 04:18:09 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f142sor1857908wme.40.2018.01.22.04.18.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 04:18:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180117212144.GD25862@bombadil.infradead.org>
References: <20180116145240.GD30073@bombadil.infradead.org>
 <CACVXFVPqJ6xYq31Ve5tXCKiNne_S1ve8csA+j_wCPnnZCPahvg@mail.gmail.com> <20180117212144.GD25862@bombadil.infradead.org>
From: Ming Lei <tom.leiming@gmail.com>
Date: Mon, 22 Jan 2018 20:18:06 +0800
Message-ID: <CACVXFVOF+vnha=-8-ahhib235iHq1ZCsBeF83Nu9zYWYYrStuA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] A high-performance userspace block driver
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>

On Thu, Jan 18, 2018 at 5:21 AM, Matthew Wilcox <willy@infradead.org> wrote:
> On Wed, Jan 17, 2018 at 10:49:24AM +0800, Ming Lei wrote:
>> Userfaultfd might be another choice:
>>
>> 1) map the block LBA space into a range of process vm space
>
> That would limit the size of a block device to ~200TB (with my laptop's
> CPU).  That's probably OK for most users, but I suspect there are some
> who would chafe at such a restriction (before the 57-bit CPUs arrive).

In theory, it won't be a issue, since the LBA space can be partitioned into
more than one process's vm space, so no matter what the size of block device
is, this way should work.

>
>> 2) when READ/WRITE req comes, convert it to page fault on the
>> mapped range, and let userland to take control of it, and meantime
>> kernel req context is slept
>
> You don't want to sleep the request; you want it to be able to submit
> more I/O.  But we have infrastructure in place to inform the submitter
> when I/Os have completed.

Yes, the current bio completion(.end_bio) model can be respected, and
this issue(where to sleep) may depend on UFFD's read/POLLIN protocol.

>
>> 3) IO req context in kernel side is waken up after userspace completed
>> the IO request via userfaultfd
>>
>> 4) kernel side continue to complete the IO, such as copying page from
>> storage range to req(bio) pages.
>>
>> Seems READ should be fine since it is very similar with the use case
>> of QEMU postcopy live migration, WRITE can be a bit different, and
>> maybe need some change on userfaultfd.
>
> I like this idea, and maybe extending UFFD is the way to solve this
> problem.  Perhaps I should explain a little more what the requirements
> are.  At the point the driver gets the I/O, pages to copy data into (for
> a read) or copy data from (for a write) have already been allocated.
> At all costs, we need to avoid playing VM tricks (because TLB flushes
> are expensive).  So one copy is probably OK, but we'd like to avoid it
> if reasonable.

I agree, and one time of page copy can be easier to implement.

>
> Let's assume that the userspace program looks at the request metadata and
> decides that it needs to send a network request.  Ideally, it would find
> a way to have the data from the response land in the pre-allocated pages
> (for a read) or send the data straight from the pages in the request
> (for a write).  I'm not sure UFFD helps us with that part of the problem.


-- 
Ming Lei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
