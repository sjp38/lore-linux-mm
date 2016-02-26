Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 29AE06B0009
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 23:02:51 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id x21so54447622oix.2
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 20:02:51 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id h8si9243647oej.49.2016.02.25.20.02.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 20:02:49 -0800 (PST)
Received: by mail-ob0-x233.google.com with SMTP id s6so18039804obg.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 20:02:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160225222705.GD30721@dastard>
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
	<20160225222705.GD30721@dastard>
Date: Thu, 25 Feb 2016 20:02:49 -0800
Message-ID: <CAPcyv4jYXN0qJdvgv1yP+Wi6W+=RRk2QP225okHtqnXAMWihFQ@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, madthanu@cs.wisc.edu

[ adding Thanu ]

On Thu, Feb 25, 2016 at 2:27 PM, Dave Chinner <david@fromorbit.com> wrote:
> On Thu, Feb 25, 2016 at 03:57:14PM -0500, Jeff Moyer wrote:
>> Good morning, Dave,
>>
>> Dave Chinner <david@fromorbit.com> writes:
>>
>> > On Thu, Feb 25, 2016 at 02:11:49PM -0500, Jeff Moyer wrote:
>> >> Jeff Moyer <jmoyer@redhat.com> writes:
>> >>
>> >> >> The big issue we have right now is that we haven't made the DAX/pmem
>> >> >> infrastructure work correctly and reliably for general use.  Hence
>> >> >> adding new APIs to workaround cases where we haven't yet provided
>> >> >> correct behaviour, let alone optimised for performance is, quite
>> >> >> frankly, a clear case premature optimisation.
>> >> >
>> >> > Again, I see the two things as separate issues.  You need both.
>> >> > Implementing MAP_SYNC doesn't mean we don't have to solve the bigger
>> >> > issue of making existing applications work safely.
>> >>
>> >> I want to add one more thing to this discussion, just for the sake of
>> >> clarity.  When I talk about existing applications and pmem, I mean
>> >> applications that already know how to detect and recover from torn
>> >> sectors.  Any application that assumes hardware does not tear sectors
>> >> should be run on a file system layered on top of the btt.
>> >
>> > Which turns off DAX, and hence makes this a moot discussion because
>>
>> You're missing the point.  You can't take applications that don't know
>> how to deal with torn sectors and put them on a block device that does
>> not provide power fail write atomicity of a single sector.
>
> Very few applications actually care about atomic sector writes.
> Databases are probably the only class of application that really do
> care about both single sector and multi-sector atomic write
> behaviour, and many of them can be configured to assume single
> sector writes can be torn.
>
> Torn user data writes have always been possible, and so pmem does
> not introduce any new semantics that applications have to handle.
>
>> > Keep in mind that existing storage technologies tear fileystem data
>> > writes, too, because user data writes are filesystem block sized and
>> > not atomic at the device level (i.e.  typical is 512 byte sector, 4k
>> > filesystem block size, so there are 7 points in a single write where
>> > a tear can occur on a crash).
>>
>> You are conflating torn pages (pages being a generic term for anything
>> greater than a sector) and torn sectors.
>
> No, I'm not. I'm pointing out that applications that really care
> about data integrity already have the capability to recovery from
> torn sectors in the event of a crash. pmem+DAX does not introduce
> any new way of corrupting user data for these applications.
>
>> > IOWs existing storage already has the capability of tearing user
>> > data on crash and has been doing so for a least they last 30 years.
>>
>> And yet applications assume that this doesn't happen.  Have a look at
>> this:
>>   https://www.sqlite.org/psow.html
>
> Quote:
>
> "All versions of SQLite up to and including version 3.7.9 assume
> that the filesystem does not provide powersafe overwrite. [...]
>
> Hence it seems reasonable to assume powersafe overwrite for modern
> disks. [...] Caution is advised though. As Roger Binns noted on the
> SQLite developers mailing list: "'poorly written' should be the main
> assumption about drive firmware."
>
> IOWs, SQLite used to always assume that single sector overwrites can
> be torn, and now that it is optional it recommends that users should
> assume this is the way their storage behaves in order to be safe. In
> this config, it uses the write ahead log even for single sector
> writes, and hence can recover from torn sector writes without having
> to detect that the write was torn.
>
> Quote:
>
> "SQLite never assumes that database page writes are atomic,
>  regardless of the PSOW setting.(1) And hence SQLite is always able
>  to automatically recover from torn pages induced by a crash."
>
> This is Because multi-sector writes are always staged through the
> write ahead log and hence are cleanly recoverable after a crash
> without having to detect whether a torn write occurred or not.
>
> IOWs, you've just pointed to an application that demonstrates
> pmem-safe behaviour - just configure the database files with
> "file:somefile.db?psow=0" and it will assume that individual sector
> writes can be torn, and it will always recover.
>
> Hence I'm not sure exactly what point you are trying to make with
> this example.

I met Thanu today at USENIX Fast'16 today and his research [1] has
found other applications that assume sector atomicity.  Also, here's a
thread he pointed to about the sector atomicity dependencies of LMDB
[2].

BTT is needed because existing software assumes sectors are not torn
and may not yet have settings like "psow=0" to workaround that
assumption.  Jeff's right, we would be mistaken not to recommend BTT
by default.  In that respect applications running on top of raw pmem,
sans BTT, are already making a "I know what I am doing" decision in
this respect.

[1]: http://research.cs.wisc.edu/wind/Publications/alice-osdi14.pdf
[2]: http://www.openldap.org/lists/openldap-devel/201410/msg00004.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
