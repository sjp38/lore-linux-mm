Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id B849A6B0266
	for <linux-mm@kvack.org>; Thu,  3 Mar 2016 12:45:08 -0500 (EST)
Received: by mail-lb0-f177.google.com with SMTP id cf7so16276687lbb.1
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 09:45:08 -0800 (PST)
Received: from plane.gmane.org (plane.gmane.org. [80.91.229.3])
        by mx.google.com with ESMTPS id d191si9254131lfg.204.2016.03.03.09.45.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Mar 2016 09:45:06 -0800 (PST)
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1abXJB-0001ni-EC
	for linux-mm@kvack.org; Thu, 03 Mar 2016 18:45:05 +0100
Received: from 178.167.174.162.threembb.ie ([178.167.174.162])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 18:45:05 +0100
Received: from hyc by 178.167.174.162.threembb.ie with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 03 Mar 2016 18:45:05 +0100
From: Howard Chu <hyc@symas.com>
Subject: Re: [RFC 0/2] New =?utf-8?b?TUFQX1BNRU1fQVdBUkU=?= mmap flag
Date: Thu, 3 Mar 2016 17:38:57 +0000 (UTC)
Message-ID: <loom.20160303T183139-827@post.gmane.org>
References: <x49egc3c8gf.fsf@segfault.boston.devel.redhat.com> <CAPcyv4jUkMikW_x1EOTHXH4GC5DkPieL=sGd0-ajZqmG6C7DEg@mail.gmail.com> <x49a8mrc7rn.fsf@segfault.boston.devel.redhat.com> <CAPcyv4hMJ_+o2hYU7xnKEWUcKpcPVd66e2KChwL96Qxxk2R8iQ@mail.gmail.com> <x49a8mqgni5.fsf@segfault.boston.devel.redhat.com> <20160224225623.GL14668@dastard> <x49y4a8iwpy.fsf@segfault.boston.devel.redhat.com> <x49twkwiozu.fsf@segfault.boston.devel.redhat.com> <20160225201517.GA30721@dastard> <x49io1cik45.fsf@segfault.boston.devel.redhat.com> <20160225222705.GD30721@dastard> <CAPcyv4jYXN0qJdvgv1yP+Wi6W+=RRk2QP225okHtqnXAMWihFQ@mail.gmail.com> <CAJ6LpRrVpHjPuRMRA2VuQLDQabQZfVAyUitaYM7hg0b11u1KVg@mail.gmail.com> <56D2C92C.4060903@plexistor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Boaz Harrosh <boaz <at> plexistor.com> writes:

> 
> On 02/26/2016 12:04 PM, Thanumalayan Sankaranarayana Pillai wrote:
> > On Thu, Feb 25, 2016 at 10:02 PM, Dan Williams <dan.j.williams <at>
intel.com> wrote:
> >> [ adding Thanu ]
> >>
> >>> Very few applications actually care about atomic sector writes.
> >>> Databases are probably the only class of application that really do
> >>> care about both single sector and multi-sector atomic write
> >>> behaviour, and many of them can be configured to assume single
> >>> sector writes can be torn.
> >>>
> >>> Torn user data writes have always been possible, and so pmem does
> >>> not introduce any new semantics that applications have to handle.
> >>>
> > 
> > I know about BTT and DAX only at a conceptual level and hence do not
understand
> > this mailing thread fully. But I can provide examples of important
applications
> > expecting atomicity at a 512B or a smaller granularity. Here is a list:
> > 
> > (1) LMDB [1] that Dan mentioned, which expects "linear writes" (i.e., don't
> > need atomicity, but need the first byte to be written before the second
byte)
> > 
> > (2) PostgreSQL expects atomicity [2]
> > 
> > (3) SQLite depends on linear writes [3] (we were unable to find these
> > dependencies during our testing, however). Also, PSOW in SQLite is not
relevant
> > to this discussion as I understand it; PSOW deals with corruption of data
> > *around* the actual written bytes.
> > 
> > (4) We found that ZooKeeper depends on atomicity during our testing, but
we did
> > not contact the ZooKeeper developers about this. Some details in our
paper [4].
> > 
> > It is tempting to assume that applications do not use the concept of disk
> > sectors and deal with only file-system blocks (which are not atomic in
> > practice), and take measures to deal with the non-atomic file-system blocks.
> > But, in reality, applications seem to assume that 512B (more or less)
sectors
> > are atomic or linear, and build their consistency mechanisms around that.
> > 
> 
> This all discussion is a shock to me. where were these guys hiding, under
a rock?
> 
> In the NFS world you can get not torn sectors but torn words. You may have
> reorder of writes, you may have data holes the all deal. Until you get back
> a successful sync nothing is guarantied. It is not only a client
> crash but also a network breach, and so on. So you never know what can happen.
> 
> So are you saying all these applications do not run on NFS?

Speaking for LMDB: LMDB is entirely dependent on mmap, and the coherence of
a unified buffer cache. None of this is supported on NFS, so NFS has never
been a concern for us. We explicitly document that LMDB cannot be used over NFS.

Speaking more generally, you're talking nonsense. NFS by default transmits
*pages* over UDP - datagrams are all-or-nothing, you can't get torn words.
Likewise, NFS over TCP means individual pages are transmitted with
individual bytes in order within a page.

> Thanks
> Boaz
> 
> > [1] http://www.openldap.org/list~s/openldap-devel/201410/msg00004.html
> > [2] http://www.postgresql.org/docs/9.5/static/wal-internals.html , "To deal
> > with the case where pg_control is corrupt" ...
> > [3] https://www.sqlite.org/atomiccommit.html , "SQLite does always
assume that
> > a sector write is linear" ...
> > [4] http://research.cs.wisc.edu/wind/Publications/alice-osdi14.pdf
> > 
> > Regards,
> > Thanu
> > _______________________________________________
> > Linux-nvdimm mailing list
> > Linux-nvdimm <at> lists.01.org
> > https://lists.01.org/mailman/listinfo/linux-nvdimm
> > 
--
  -- Howard Chu
  CTO, Symas Corp.           http://www.symas.com
  Director, Highland Sun     http://highlandsun.com/hyc/
  Chief Architect, OpenLDAP  http://www.openldap.org/project/



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
