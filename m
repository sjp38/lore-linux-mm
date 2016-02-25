Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 332AA6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:20:55 -0500 (EST)
Received: by mail-ig0-f182.google.com with SMTP id z8so21750448ige.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 12:20:55 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id m65si12326482ioa.163.2016.02.25.12.20.53
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 12:20:54 -0800 (PST)
Date: Fri, 26 Feb 2016 07:15:17 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160225201517.GA30721@dastard>
References: <56CCD54C.3010600@plexistor.com>
 <CAPcyv4iqO=Pzu_r8tV6K2G953c5HqJRdqCE1pymfDmURy8_ODw@mail.gmail.com>
 <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
 <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
 <20160224225623.GL14668@dastard>
 <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
 <x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 25, 2016 at 02:11:49PM -0500, Jeff Moyer wrote:
> Jeff Moyer <jmoyer@redhat.com> writes:
> 
> >> The big issue we have right now is that we haven't made the DAX/pmem
> >> infrastructure work correctly and reliably for general use.  Hence
> >> adding new APIs to workaround cases where we haven't yet provided
> >> correct behaviour, let alone optimised for performance is, quite
> >> frankly, a clear case premature optimisation.
> >
> > Again, I see the two things as separate issues.  You need both.
> > Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
> > issue of making existing applications work safely.
> 
> I want to add one more thing to this discussion, just for the sake of
> clarity.  When I talk about existing applications and pmem, I mean
> applications that already know how to detect and recover from torn
> sectors.  Any application that assumes hardware does not tear sectors
> should be run on a file system layered on top of the btt.

Which turns off DAX, and hence makes this a moot discussion because
mmap is then buffered through the page cache and hence applications
*must use msync/fsync* to provide data integrity. Which also makes
them safe to use with DAX if we have a working fsync.

Keep in mind that existing storage technologies tear fileystem data
writes, too, because user data writes are filesystem block sized and
not atomic at the device level (i.e.  typical is 512 byte sector, 4k
filesystem block size, so there are 7 points in a single write where
a tear can occur on a crash).

IOWs existing storage already has the capability of tearing user
data on crash and has been doing so for a least they last 30 years.
Hence I really don't see any fundamental difference here with
pmem+DAX - the only difference is that the tear granuarlity is
smaller (CPU cacheline rather than sector).

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
