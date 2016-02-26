Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2306B0009
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:04:56 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id l127so117108412iof.3
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 02:04:56 -0800 (PST)
Received: from sabe.cs.wisc.edu (sabe.cs.wisc.edu. [128.105.6.20])
        by mx.google.com with ESMTPS id w62si15952761iof.21.2016.02.26.02.04.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 02:04:55 -0800 (PST)
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	(authenticated bits=0)
	by sabe.cs.wisc.edu (8.14.7/8.14.1) with ESMTP id u1QA4s6l020907
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 04:04:54 -0600
Received: by mail-oi0-f51.google.com with SMTP id w80so2355367oiw.2
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 02:04:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jYXN0qJdvgv1yP+Wi6W+=RRk2QP225okHtqnXAMWihFQ@mail.gmail.com>
References: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com>
 <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com>
 <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com> <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com>
 <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com> <20160224225623.GL14668@dastard>
 <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com> <x49twkwiozu.fsf@segfault.boston.devel.redhat.com>
 <20160225201517.GA30721@dastard> <x49io1cik45.fsf@segfault.boston.devel.redhat.com>
 <20160225222705.GD30721@dastard> <CAPcyv4jYXN0qJdvgv1yP+Wi6W+=RRk2QP225okHtqnXAMWihFQ@mail.gmail.com>
From: Thanumalayan Sankaranarayana Pillai <madthanu@cs.wisc.edu>
Date: Fri, 26 Feb 2016 04:04:29 -0600
Message-ID: <CAJ6LpRrVpHjPuRMRA2VuQLDQabQZfVAyUitaYM7hg0b11u1KVg@mail.gmail.com>
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Chinner <david@fromorbit.com>, Jeff Moyer <jmoyer@redhat.com>, Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 25, 2016 at 10:02 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> [ adding Thanu ]
>
>> Very few applications actually care about atomic sector writes.
>> Databases are probably the only class of application that really do
>> care about both single sector and multi-sector atomic write
>> behaviour, and many of them can be configured to assume single
>> sector writes can be torn.
>>
>> Torn user data writes have always been possible, and so pmem does
>> not introduce any new semantics that applications have to handle.
>>

I know about BTT and DAX only at a conceptual level and hence do not understand
this mailing thread fully. But I can provide examples of important applications
expecting atomicity at a 512B or a smaller granularity. Here is a list:

(1) LMDB [1] that Dan mentioned, which expects "linear writes" (i.e., don't
need atomicity, but need the first byte to be written before the second byte)

(2) PostgreSQL expects atomicity [2]

(3) SQLite depends on linear writes [3] (we were unable to find these
dependencies during our testing, however). Also, PSOW in SQLite is not relevant
to this discussion as I understand it; PSOW deals with corruption of data
*around* the actual written bytes.

(4) We found that ZooKeeper depends on atomicity during our testing, but we did
not contact the ZooKeeper developers about this. Some details in our paper [4].

It is tempting to assume that applications do not use the concept of disk
sectors and deal with only file-system blocks (which are not atomic in
practice), and take measures to deal with the non-atomic file-system blocks.
But, in reality, applications seem to assume that 512B (more or less) sectors
are atomic or linear, and build their consistency mechanisms around that.

[1] http://www.openldap.org/list~s/openldap-devel/201410/msg00004.html
[2] http://www.postgresql.org/docs/9.5/static/wal-internals.html , "To deal
with the case where pg_control is corrupt" ...
[3] https://www.sqlite.org/atomiccommit.html , "SQLite does always assume that
a sector write is linear" ...
[4] http://research.cs.wisc.edu/wind/Publications/alice-osdi14.pdf

Regards,
Thanu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
