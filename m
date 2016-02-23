Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 2384A6B0009
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 18:31:39 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id c10so1059636pfc.2
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 15:31:39 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id 17si288318pfr.69.2016.02.23.15.31.37
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 15:31:38 -0800 (PST)
Date: Wed, 24 Feb 2016 10:28:13 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160223232813.GI14668@dastard>
References: <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
 <20160223095225.GB32294@infradead.org>
 <7168B635-938B-44A0-BECD-C0774207B36D@intel.com>
 <20160223120644.GL25832@dastard>
 <20160223171059.GB15877@linux.intel.com>
 <20160223214729.GH14668@dastard>
 <56CCDA06.6000005@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CCDA06.6000005@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Feb 24, 2016 at 12:15:34AM +0200, Boaz Harrosh wrote:
> On 02/23/2016 11:47 PM, Dave Chinner wrote:
> <>
> > 
> > i.e. what we've implemented right now is a basic, slow,
> > easy-to-make-work-correctly brute force solution. That doesn't mean
> > we always need to implement it this way, or that we are bound by the
> > way dax_clear_sectors() currently flushes cachelines before it
> > returns. It's just a simple implementation that provides the
> > ordering the *filesystem requires* to provide the correct data
> > integrity semantics to userspace.
> > 
> 
> Or it can be written properly with movnt instructions and be even
> faster the a simple memset, and no need for any cl_flushing let alone
> any radix-tree locking.

Precisely my point - semantics of persistent memory durability are
going to change from kernel to kernel, architecture to architecture,
and hardware to hardware.

Assuming applications are going to handle all these wacky
differences to provide their users with robust data integrity is a
recipe for disaster. If applications writers can't even use fsync
properly, I can guarantee you they are going to completely fuck up
data integrity when targeting pmem.

> That said your suggestion above is 25%-100% slower than current code
> because the cl_flushes will be needed eventually, and the atomics of a
> lock takes 25% the time of a full page copy.

So what? We can optimise for performance later, once we've provided
correct and resilient infrastructure. We've been fighting against
premature optimisation for performance from teh start with DAX -
we've repeatedly had to undo stuff that was fast but broken, and
were not doing that any more. Correctness comes first, then we can
address the performance issues via iterative improvement, like we do
with everything else.

> You are forgetting we are
> talking about memory and not harddisk. the rules are different.

That's bullshit, Boaz. I'm sick and tired of people saying "but pmem
is different" as justification for not providing correct, reliable
data integrity behaviour. Filesytems on PMEM have to follow all the
same rules as any other type of persistent storage we put
filesystems on.

Yes, the speed of the storage may expose the fact that am
unoptimised correct implementation is a lot more expensive than
ignoring correctness, but that does not mean we can ignore
correctness. Nor does it mean that a correct implementation will be
slow - it just means we haven't optimised for speed yet because
getting it correct is a hard problem and our primary focus.

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
