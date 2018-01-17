Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA716B028C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 16:21:47 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id p20so5960064pfh.17
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 13:21:47 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 68si5175753pla.376.2018.01.17.13.21.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 17 Jan 2018 13:21:46 -0800 (PST)
Date: Wed, 17 Jan 2018 13:21:44 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [LSF/MM TOPIC] A high-performance userspace block driver
Message-ID: <20180117212144.GD25862@bombadil.infradead.org>
References: <20180116145240.GD30073@bombadil.infradead.org>
 <CACVXFVPqJ6xYq31Ve5tXCKiNne_S1ve8csA+j_wCPnnZCPahvg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACVXFVPqJ6xYq31Ve5tXCKiNne_S1ve8csA+j_wCPnnZCPahvg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ming Lei <tom.leiming@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>

On Wed, Jan 17, 2018 at 10:49:24AM +0800, Ming Lei wrote:
> Userfaultfd might be another choice:
> 
> 1) map the block LBA space into a range of process vm space

That would limit the size of a block device to ~200TB (with my laptop's
CPU).  That's probably OK for most users, but I suspect there are some
who would chafe at such a restriction (before the 57-bit CPUs arrive).

> 2) when READ/WRITE req comes, convert it to page fault on the
> mapped range, and let userland to take control of it, and meantime
> kernel req context is slept

You don't want to sleep the request; you want it to be able to submit
more I/O.  But we have infrastructure in place to inform the submitter
when I/Os have completed.

> 3) IO req context in kernel side is waken up after userspace completed
> the IO request via userfaultfd
> 
> 4) kernel side continue to complete the IO, such as copying page from
> storage range to req(bio) pages.
> 
> Seems READ should be fine since it is very similar with the use case
> of QEMU postcopy live migration, WRITE can be a bit different, and
> maybe need some change on userfaultfd.

I like this idea, and maybe extending UFFD is the way to solve this
problem.  Perhaps I should explain a little more what the requirements
are.  At the point the driver gets the I/O, pages to copy data into (for
a read) or copy data from (for a write) have already been allocated.
At all costs, we need to avoid playing VM tricks (because TLB flushes
are expensive).  So one copy is probably OK, but we'd like to avoid it
if reasonable.

Let's assume that the userspace program looks at the request metadata and
decides that it needs to send a network request.  Ideally, it would find
a way to have the data from the response land in the pre-allocated pages
(for a read) or send the data straight from the pages in the request
(for a write).  I'm not sure UFFD helps us with that part of the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
