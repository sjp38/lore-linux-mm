Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3489E6B0069
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 15:32:17 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s207so87435918oie.0
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 12:32:17 -0700 (PDT)
Received: from resqmta-ch2-05v.sys.comcast.net (resqmta-ch2-05v.sys.comcast.net. [2001:558:fe21:29:69:252:207:37])
        by mx.google.com with ESMTPS id v93si767024ioi.2.2016.08.30.12.32.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 12:32:02 -0700 (PDT)
Date: Tue, 30 Aug 2016 14:32:00 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: what is the purpose of SLAB and SLUB (was: Re: [PATCH v3] mm/slab:
 Improve performance of gathering slabinfo) stats
In-Reply-To: <20160830093955.GV2693@suse.de>
Message-ID: <alpine.DEB.2.20.1608301425020.4627@east.gentwo.org>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com> <20160818115218.GJ30162@dhcp22.suse.cz> <20160823021303.GB17039@js1304-P5Q-DELUXE> <20160823153807.GN23577@dhcp22.suse.cz> <20160824082057.GT2693@suse.de>
 <alpine.DEB.2.20.1608242240460.1837@east.gentwo.org> <20160825100707.GU2693@suse.de> <alpine.DEB.2.20.1608251451070.10766@east.gentwo.org> <20160830093955.GV2693@suse.de>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>

On Tue, 30 Aug 2016, Mel Gorman wrote:

> > Userspace mapped pages can be hugepages as well as giant pages and that
> > has been there for a long time. Intermediate sizes would be useful too in
> > order to avoid having to keep lists of 4k pages around and continually
> > scan them.
> >
>
> Userspace pages cannot always be mapped as huge or giant. mprotect on a
> 4K boundary is an obvious example.

Well if the pages are bigger then the boundaries will also be different.
The problem is that we are trying to keep the 4k illustion alive. This
causes churn in various subsystems. Implementation of a file cache
with arbitrary page order is rather straightforward. See
https://lkml.org/lkml/2007/4/19/261

There we run again against the problem of defragmentation. Avoiding decent
garbage collection in the kernel causes no end of additional trouble. I
think we need to face the issue and solve it. Then a lot of other
workaround and complex things are no longer necesary.

> > > Dirty tracking of pages on a 4K boundary will always be required to avoid IO
> > > multiplier effects that cannot be side-stepped by increasing the fundamental
> > > unit of allocation.
> >
> > Huge pages cannot be dirtied?
>
> I didn't say that, I said they are required to avoid IO multiplier
> effects. If a file is mapped as 2M or 1G then even a 1 byte write requires
> 2M or 1G of IO to writeback.

There are numerous use cases that I know of where this would be
acceptable. Some tuning would be required of course like a mininum period
until writeback occurs.

> > This is an issue of hardware support. On
> > x867 you only have one size. I am pretty such that even intel would
> > support other sizes if needed. The case has been repeatedly made that 64k
> > pages f.e. would be useful to have on x86.
> >
>
> 64K pages are not a universal win even on the arches that do support them.

There are always corner cases that regress with any kernel "enhancement".
64k page size was a signicant improvement for many of the loads when I
worked at SGI on Altix.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
