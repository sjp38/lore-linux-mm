Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 6FB376B0256
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 17:28:01 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id x65so40068827pfb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 14:28:01 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id 70si15072742pfk.205.2016.02.25.14.27.59
        for <linux-mm@kvack.org>;
        Thu, 25 Feb 2016 14:28:00 -0800 (PST)
Date: Fri, 26 Feb 2016 09:27:06 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Message-ID: <20160225222705.GD30721@dastard>
References: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
 <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com>
 <20160224225623.GL14668@dastard>
 <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com>
 <x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
 <20160225201517.GA30721@dastard>
 <x49io1cik45.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49io1cik45.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 25, 2016 at 03:57:14PM -0500, Jeff Moyer wrote:
> Good morning, Dave,
> 
> Dave Chinner <david@fromorbit.com> writes:
> 
> > On Thu, Feb 25, 2016 at 02:11:49PM -0500, Jeff Moyer wrote:
> >> Jeff Moyer <jmoyer@redhat.com> writes:
> >> 
> >> >> The big issue we have right now is that we haven't made the DAX/pmem
> >> >> infrastructure work correctly and reliably for general use.  Hence
> >> >> adding new APIs to workaround cases where we haven't yet provided
> >> >> correct behaviour, let alone optimised for performance is, quite
> >> >> frankly, a clear case premature optimisation.
> >> >
> >> > Again, I see the two things as separate issues.  You need both.
> >> > Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
> >> > issue of making existing applications work safely.
> >> 
> >> I want to add one more thing to this discussion, just for the sake of
> >> clarity.  When I talk about existing applications and pmem, I mean
> >> applications that already know how to detect and recover from torn
> >> sectors.  Any application that assumes hardware does not tear sectors
> >> should be run on a file system layered on top of the btt.
> >
> > Which turns off DAX, and hence makes this a moot discussion because
> 
> You're missing the point.  You can't take applications that don't know
> how to deal with torn sectors and put them on a block device that does
> not provide power fail write atomicity of a single sector.

Very few applications actually care about atomic sector writes.
Databases are probably the only class of application that really do
care about both single sector and multi-sector atomic write
behaviour, and many of them can be configured to assume single
sector writes can be torn.

Torn user data writes have always been possible, and so pmem does
not introduce any new semantics that applications have to handle.

> > Keep in mind that existing storage technologies tear fileystem data
> > writes, too, because user data writes are filesystem block sized and
> > not atomic at the device level (i.e.  typical is 512 byte sector, 4k
> > filesystem block size, so there are 7 points in a single write where
> > a tear can occur on a crash).
> 
> You are conflating torn pages (pages being a generic term for anything
> greater than a sector) and torn sectors.

No, I'm not. I'm pointing out that applications that really care
about data integrity already have the capability to recovery from
torn sectors in the event of a crash. pmem+DAX does not introduce
any new way of corrupting user data for these applications.

> > IOWs existing storage already has the capability of tearing user
> > data on crash and has been doing so for a least they last 30 years.
> 
> And yet applications assume that this doesn't happen.  Have a look at
> this:
>   https://www.sqlite.org/psow.html

Quote:

"All versions of SQLite up to and including version 3.7.9 assume
that the filesystem does not provide powersafe overwrite. [...]

Hence it seems reasonable to assume powersafe overwrite for modern
disks. [...] Caution is advised though. As Roger Binns noted on the
SQLite developers mailing list: "'poorly written' should be the main
assumption about drive firmware."

IOWs, SQLite used to always assume that single sector overwrites can
be torn, and now that it is optional it recommends that users should
assume this is the way their storage behaves in order to be safe. In
this config, it uses the write ahead log even for single sector
writes, and hence can recover from torn sector writes without having
to detect that the write was torn.

Quote:

"SQLite never assumes that database page writes are atomic,
 regardless of the PSOW setting.(1) And hence SQLite is always able
 to automatically recover from torn pages induced by a crash."

This is Because multi-sector writes are always staged through the
write ahead log and hence are cleanly recoverable after a crash
without having to detect whether a torn write occurred or not.

IOWs, you've just pointed to an application that demonstrates
pmem-safe behaviour - just configure the database files with
"file:somefile.db?psow=0" and it will assume that individual sector
writes can be torn, and it will always recover.

Hence I'm not sure exactly what point you are trying to make with
this example.

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
