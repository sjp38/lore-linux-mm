Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 54B816B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 05:17:21 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id p65so34057650wmp.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 02:17:21 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id jf9si8785139wjb.86.2016.02.28.02.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Feb 2016 02:17:20 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id n186so11751225wmn.1
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 02:17:19 -0800 (PST)
Message-ID: <56D2C92C.4060903@plexistor.com>
Date: Sun, 28 Feb 2016 12:17:16 +0200
From: Boaz Harrosh <boaz@plexistor.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/2] New MAP_PMEM_AWARE mmap flag
References: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com> <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com> <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com> <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com> <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com> <20160224225623.GL14668@dastard> <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com> <x49twkwiozu.fsf@segfault.boston.devel.redhat.com> <20160225201517.GA30721@dastard> <x49io1cik45.fsf@segfault.boston.devel.redhat.com> <20160225222705.GD30721@dastard> <CAPcyv4jYXN0qJdvgv1yP+Wi6W+=RRk2QP225okHtqnXAMWihFQ@mail.gmail.com> <CAJ6LpRrVpHjPuRMRA2VuQLDQabQZfVAyUitaYM7hg0b11u1KVg@mail.gmail.com>
In-Reply-To: <CAJ6LpRrVpHjPuRMRA2VuQLDQabQZfVAyUitaYM7hg0b11u1KVg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thanumalayan Sankaranarayana Pillai <madthanu@cs.wisc.edu>, Dan Williams <dan.j.williams@intel.com>
Cc: Arnd Bergmann <arnd@arndb.de>, linux-nvdimm <linux-nvdimm@ml01.01.org>, Dave Chinner <david@fromorbit.com>, Oleg Nesterov <oleg@redhat.com>, Christoph Hellwig <hch@infradead.org>, linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, NFS list <linux-nfs@vger.kernel.org>

On 02/26/2016 12:04 PM, Thanumalayan Sankaranarayana Pillai wrote:
> On Thu, Feb 25, 2016 at 10:02 PM, Dan Williams <dan.j.williams@intel.com> wrote:
>> [ adding Thanu ]
>>
>>> Very few applications actually care about atomic sector writes.
>>> Databases are probably the only class of application that really do
>>> care about both single sector and multi-sector atomic write
>>> behaviour, and many of them can be configured to assume single
>>> sector writes can be torn.
>>>
>>> Torn user data writes have always been possible, and so pmem does
>>> not introduce any new semantics that applications have to handle.
>>>
> 
> I know about BTT and DAX only at a conceptual level and hence do not understand
> this mailing thread fully. But I can provide examples of important applications
> expecting atomicity at a 512B or a smaller granularity. Here is a list:
> 
> (1) LMDB [1] that Dan mentioned, which expects "linear writes" (i.e., don't
> need atomicity, but need the first byte to be written before the second byte)
> 
> (2) PostgreSQL expects atomicity [2]
> 
> (3) SQLite depends on linear writes [3] (we were unable to find these
> dependencies during our testing, however). Also, PSOW in SQLite is not relevant
> to this discussion as I understand it; PSOW deals with corruption of data
> *around* the actual written bytes.
> 
> (4) We found that ZooKeeper depends on atomicity during our testing, but we did
> not contact the ZooKeeper developers about this. Some details in our paper [4].
> 
> It is tempting to assume that applications do not use the concept of disk
> sectors and deal with only file-system blocks (which are not atomic in
> practice), and take measures to deal with the non-atomic file-system blocks.
> But, in reality, applications seem to assume that 512B (more or less) sectors
> are atomic or linear, and build their consistency mechanisms around that.
> 

This all discussion is a shock to me. where were these guys hiding, under a rock?

In the NFS world you can get not torn sectors but torn words. You may have
reorder of writes, you may have data holes the all deal. Until you get back
a successful sync nothing is guarantied. It is not only a client
crash but also a network breach, and so on. So you never know what can happen.

So are you saying all these applications do not run on NFS?

Thanks
Boaz

> [1] http://www.openldap.org/list~s/openldap-devel/201410/msg00004.html
> [2] http://www.postgresql.org/docs/9.5/static/wal-internals.html , "To deal
> with the case where pg_control is corrupt" ...
> [3] https://www.sqlite.org/atomiccommit.html , "SQLite does always assume that
> a sector write is linear" ...
> [4] http://research.cs.wisc.edu/wind/Publications/alice-osdi14.pdf
> 
> Regards,
> Thanu
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
