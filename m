Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9ED6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 16:47:35 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id 9so3183753iom.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 13:47:35 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id b4si1312219igf.22.2016.02.23.13.47.33
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 13:47:34 -0800 (PST)
Date: Wed, 24 Feb 2016 08:47:29 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160223214729.GH14668@dastard>
References: <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
 <20160223095225.GB32294@infradead.org>
 <7168B635-938B-44A0-BECD-C0774207B36D@intel.com>
 <20160223120644.GL25832@dastard>
 <20160223171059.GB15877@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223171059.GB15877@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: "Rudoff, Andy" <andy.rudoff@intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 10:10:59AM -0700, Ross Zwisler wrote:
> On Tue, Feb 23, 2016 at 11:06:44PM +1100, Dave Chinner wrote:
> > On Tue, Feb 23, 2016 at 10:07:07AM +0000, Rudoff, Andy wrote:
> > Not to mention that the filesystem will convert and zero much
> > more than just a single cacheline (whole pages at minimum, could
> > be 2MB extents for large pages, etc) so the filesystem may
> > require CPU cache flushes over a much wider range of cachelines
> > that the application realises are dirty and require flushing for
> > data integrity purposes. The filesytem knows about these dirty
> > cache lines, userspace doesn't.
> 
> With the current code at least dax_zero_page_range() doesn't rely

dax_clear_sectors(), actually.

> on fsync/msync from userspace to make the zeroes that it writes
> persistent.  It does all the necessary flushing and wmb_pmem()
> calls itself. 

Yes, that's the current implementation. We don't actually depend on
those semantics, though, and assuming we do is a demonstration of
the problems we're having right now. We could get rid of all the
synchronous cache flushes and just mark the range dirty in the
mapping radix tree and ensure that the cache flushes occur before
the conversion transaction is made durable. And to make my point
even clearer, that "flush data then transactions" ordering is
exactly how fsync is implemented.

i.e. what we've implemented right now is a basic, slow,
easy-to-make-work-correctly brute force solution. That doesn't mean
we always need to implement it this way, or that we are bound by the
way dax_clear_sectors() currently flushes cachelines before it
returns. It's just a simple implementation that provides the
ordering the *filesystem requires* to provide the correct data
integrity semantics to userspace.

pmem cache flushing is a durability mechanism, it's not a data
integrity solution. We have to flush CPU caches to provide
durability, but that alone is not sufficient to guarantee that
application data is complete and accessible after a crash.

> I agree that this does not address your concern
> about metadata being in sync, though.

Right, and msync/fsync is the only way to guarantee that.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
