Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6B245800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 07:03:00 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id e4so2188786qtb.14
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 04:03:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id j39si14474646qtk.37.2018.01.22.04.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 04:02:59 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0MBwftA146582
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 07:02:58 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2fnecwu4xc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 07:02:57 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 22 Jan 2018 12:02:54 -0000
Date: Mon, 22 Jan 2018 14:02:48 +0200
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [LSF/MM TOPIC] A high-performance userspace block driver
References: <20180116145240.GD30073@bombadil.infradead.org>
 <CACVXFVPqJ6xYq31Ve5tXCKiNne_S1ve8csA+j_wCPnnZCPahvg@mail.gmail.com>
 <20180117212144.GD25862@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117212144.GD25862@bombadil.infradead.org>
Message-Id: <20180122120248.GB7984@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ming Lei <tom.leiming@gmail.com>, lsf-pc@lists.linux-foundation.org, linux-mm <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, linux-block <linux-block@vger.kernel.org>

On Wed, Jan 17, 2018 at 01:21:44PM -0800, Matthew Wilcox wrote:
> On Wed, Jan 17, 2018 at 10:49:24AM +0800, Ming Lei wrote:
> > Userfaultfd might be another choice:
> > 
> > 1) map the block LBA space into a range of process vm space
> 
> That would limit the size of a block device to ~200TB (with my laptop's
> CPU).  That's probably OK for most users, but I suspect there are some
> who would chafe at such a restriction (before the 57-bit CPUs arrive).
> 
> > 2) when READ/WRITE req comes, convert it to page fault on the
> > mapped range, and let userland to take control of it, and meantime
> > kernel req context is slept
> 
> You don't want to sleep the request; you want it to be able to submit
> more I/O.  But we have infrastructure in place to inform the submitter
> when I/Os have completed.

It's possible to queue IO requests and have a kthread that will convert
those requests to page faults. The thread indeed will sleep on each page
fault, though.
 
> > 3) IO req context in kernel side is waken up after userspace completed
> > the IO request via userfaultfd
> > 
> > 4) kernel side continue to complete the IO, such as copying page from
> > storage range to req(bio) pages.
> > 
> > Seems READ should be fine since it is very similar with the use case
> > of QEMU postcopy live migration, WRITE can be a bit different, and
> > maybe need some change on userfaultfd.
> 
> I like this idea, and maybe extending UFFD is the way to solve this
> problem.  Perhaps I should explain a little more what the requirements
> are.  At the point the driver gets the I/O, pages to copy data into (for
> a read) or copy data from (for a write) have already been allocated.
> At all costs, we need to avoid playing VM tricks (because TLB flushes
> are expensive).  So one copy is probably OK, but we'd like to avoid it
> if reasonable.
> 
> Let's assume that the userspace program looks at the request metadata and
> decides that it needs to send a network request.  Ideally, it would find
> a way to have the data from the response land in the pre-allocated pages
> (for a read) or send the data straight from the pages in the request
> (for a write).  I'm not sure UFFD helps us with that part of the problem.

As of now it does not. UFFD allocates pages when userland asks to copy the
data into UFFD controlled VMA.
In your example, after the data had arrives from the network userland it
can be copied into a page UFFD will allocate.

Unrelated to block device, I've been thinking of implementing splice for
userfaultfd...

-- 
Sincerely yours,
Mike.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
