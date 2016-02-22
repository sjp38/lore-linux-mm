Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5C682F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 13:03:53 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id q63so96315196pfb.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 10:03:53 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id ze7si36639793pac.34.2016.02.22.10.03.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 10:03:52 -0800 (PST)
Date: Mon, 22 Feb 2016 10:03:50 -0800
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160222180350.GA9866@infradead.org>
References: <56C9EDCF.8010007@plexistor.com>
 <CAPcyv4iqAXryz0-WAtvnYf6_Q=ha8F5b-fCUt7DDhYasX=YRUA@mail.gmail.com>
 <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <x49y4ac630l.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49y4ac630l.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Feb 22, 2016 at 12:58:18PM -0500, Jeff Moyer wrote:
> Sorry for being dense, but why, exactly?  If the file system is making
> changes without the application's involvement, then the file system
> should be responsible for ensuring its own consistency, irrespective of
> whether the application issues an fsync.  Clearly I'm missing some key
> point here.

The simplest example is a copy on write file system (or simply a copy on
write file, which can exist with ocfs2 and will with xfs very soon),
where each write will allocate a new block, which will require metadata
updates.

We've built the whole I/O model around the concept that by default our
I/O will required fsync/msync.  For read/write-style I/O you can opt out
using O_DSYNC.  There currently is no way to opt out for memory mapped
I/O, mostly because it's

  a) useless without something like DAX, and
  b) much harder to implement

So a MAP_SYNC option might not be entirely off the table, but I think
it would be a lot of hard work and I'm not even sure it's possible
to handle it in the general case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
