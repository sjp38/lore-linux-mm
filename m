Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id E8F1E6B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 12:25:26 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id fy10so113391368pac.1
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 09:25:26 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id uk9si18869493pac.166.2016.02.23.09.25.25
        for <linux-mm@kvack.org>;
        Tue, 23 Feb 2016 09:25:26 -0800 (PST)
Date: Tue, 23 Feb 2016 10:25:12 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160223172512.GC15877@linux.intel.com>
References: <56CA1CE7.6050309@plexistor.com>
 <CAPcyv4hpxab=c1g83ARJvrnk_5HFkqS-t3sXpwaRBiXzehFwWQ@mail.gmail.com>
 <56CA2AC9.7030905@plexistor.com>
 <CAPcyv4gQV9Oh9OpHTGuGfTJ_s1C_L7J-VGyto3JMdAcgqyVeAw@mail.gmail.com>
 <20160221223157.GC25832@dastard>
 <x49fuwk7o8a.fsf@segfault.boston.devel.redhat.com>
 <20160222174426.GA30110@infradead.org>
 <257B23E37BCB93459F4D566B5EBAEAC550098A32@FMSMSX106.amr.corp.intel.com>
 <20160223095225.GB32294@infradead.org>
 <56CC686A.9040909@plexistor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56CC686A.9040909@plexistor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Boaz Harrosh <boaz@plexistor.com>
Cc: Christoph Hellwig <hch@infradead.org>, "Rudoff, Andy" <andy.rudoff@intel.com>, Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, Feb 23, 2016 at 04:10:50PM +0200, Boaz Harrosh wrote:
> On 02/23/2016 11:52 AM, Christoph Hellwig wrote:
> <>
> > 
> > And this is BS.  Using msync or fsync might not perform as well as not
> > actually using them, but without them you do not get persistence.  If
> > you use your pmem as a throw away cache that's fine, but for most people
> > that is not the case.
> > 
> 
> Hi Christoph
> 
> So is exactly my suggestion. My approach is *not* the we do not call
> m/fsync to let the FS clean up.
> 
> In my model we still do that, only we eliminate the m/fsync slowness
> and the all page faults overhead by being instructed by the application
> that we do not need to track the data modified cachelines. Since the
> application is telling us that it will do so.
> 
> In my model the job is split:
>  App will take care of data persistence by instructing a MAP_PMEM_AWARE,
>  and doing its own cl_flushing / movnt.
>  Which is the heavy cost
> 
>  The FS will keep track of the Meta-Data persistence as it already does, via the
>  call to m/fsync. Which is marginal performance compared to the above heavy
>  IO.
> 
> Note that the FS is still free to move blocks around, as Dave said:
> lockout pagefaultes, unmap from user space, let app fault again on a new
> block. this will still work as before, already in COW we flush the old
> block so there will be no persistence lost.
> 
> So this all thread started with my patches, and my patches do not say
> "no m/fsync" they say, make this 3-8 times faster than today if the app
> is participating in the heavy lifting.
> 
> Please tell me what you find wrong with my approach?

It seems like we are trying to solve a couple of different problems:

1) Make page faults faster by skipping any radix tree insertions, tag updates,
etc.

2) Make fsync/msync faster by not flushing data that the application says it
is already making durable from userspace.

I agree that your approach seems to improve both of these problems, but I
would argue that it is an incomplete solution for problem #2 because a
fsync/msync from the PMEM aware application would still flush any radix tree
entries from *other* threads that were writing to the same file.

It seems like a more direct solution for #2 above would be to have a
metadata-only equivalent of fsync/fdatasync, say "fmetasync", which says "I'll
make the writes I do to my mmaps durable from userspace, but I need you to
sync all filesystem metadata for me, please".

This would allow a complete separation of data synchronization in userspace
from metadata synchronization in kernel space by the filesystem code.

By itself a fmetasync() type solution of course would do nothing for issue #1
- if that was a compelling issue you'd need something like the mmap tag you're
proposing to skip work on page faults.

All that being said, though, I agree with others in the thread that we should
still be focused on correctness, as we have a lot of correctness issues
remaining.  When we eventually get to the place where we are trying to do
performance optimizations, those optimizations should be measurement driven.

- Ross

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
