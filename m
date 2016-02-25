Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f181.google.com (mail-qk0-f181.google.com [209.85.220.181])
	by kanga.kvack.org (Postfix) with ESMTP id 219416B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 15:57:19 -0500 (EST)
Received: by mail-qk0-f181.google.com with SMTP id o6so24638518qkc.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 12:57:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x76si9761516qhx.79.2016.02.25.12.57.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 12:57:18 -0800 (PST)
From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
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
	<20160225201517.GA30721@dastard>
Date: Thu, 25 Feb 2016 15:57:14 -0500
In-Reply-To: <20160225201517.GA30721@dastard> (Dave Chinner's message of "Fri,
	26 Feb 2016 07:15:17 +1100")
Message-ID: <x49io1cik45.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Good morning, Dave,

Dave Chinner <david@fromorbit.com> writes:

> On Thu, Feb 25, 2016 at 02:11:49PM -0500, Jeff Moyer wrote:
>> Jeff Moyer <jmoyer@redhat.com> writes:
>> 
>> >> The big issue we have right now is that we haven't made the DAX/pmem
>> >> infrastructure work correctly and reliably for general use.  Hence
>> >> adding new APIs to workaround cases where we haven't yet provided
>> >> correct behaviour, let alone optimised for performance is, quite
>> >> frankly, a clear case premature optimisation.
>> >
>> > Again, I see the two things as separate issues.  You need both.
>> > Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
>> > issue of making existing applications work safely.
>> 
>> I want to add one more thing to this discussion, just for the sake of
>> clarity.  When I talk about existing applications and pmem, I mean
>> applications that already know how to detect and recover from torn
>> sectors.  Any application that assumes hardware does not tear sectors
>> should be run on a file system layered on top of the btt.
>
> Which turns off DAX, and hence makes this a moot discussion because

You're missing the point.  You can't take applications that don't know
how to deal with torn sectors and put them on a block device that does
not provide power fail write atomicity of a single sector.  That said,
there are two classes of applications that /can/ make use of file
systems layered on top of /dev/pmem devices:

1) applications that know how to deal with torn sectors
2) these new-fangled applications written for persistent memory

Thus, it's not a moot point.  There are existing applications that can
make use of the msync/fsync code we've been discussing.  And then there
are these other applications that want to take care of the persistence
all on their own.

> Keep in mind that existing storage technologies tear fileystem data
> writes, too, because user data writes are filesystem block sized and
> not atomic at the device level (i.e.  typical is 512 byte sector, 4k
> filesystem block size, so there are 7 points in a single write where
> a tear can occur on a crash).

You are conflating torn pages (pages being a generic term for anything
greater than a sector) and torn sectors.  That point aside, you can do
O_DIRECT I/O on a sector granularity, even on a file system that has a
block size larger than the device logical block size.  Thus,
applications can control the blast radius of a write.

> IOWs existing storage already has the capability of tearing user
> data on crash and has been doing so for a least they last 30 years.

And yet applications assume that this doesn't happen.  Have a look at
this:
  https://www.sqlite.org/psow.html

> Hence I really don't see any fundamental difference here with
> pmem+DAX - the only difference is that the tear granuarlity is
> smaller (CPU cacheline rather than sector).

Like it or not, applications have been assuming that they get power fail
write atomicity of a single sector, and they have (mostly) been right.
With persistent memory, I am certain there will be torn writes.  We've
already seen it in testing.  This is why I don't see file systems on a
pmem device as general purpose.

Irrespective of what storage systems do today, I think it's good
practice to not leave landmines for applications that will use
persistent memory.  Let's be very clear on what is expected to work and
what isn't.  I hope I've made my stance clear.

Cheers,
Jeff

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
