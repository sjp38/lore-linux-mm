Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B9DED8E0047
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 00:36:57 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so5314331qtr.7
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 21:36:57 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m2si156684qtd.356.2019.01.23.21.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 21:36:57 -0800 (PST)
Date: Thu, 24 Jan 2019 13:36:47 +0800
From: Peter Xu <peterx@redhat.com>
Subject: Re: [PATCH RFC 20/24] userfaultfd: wp: don't wake up when doing
 write protect
Message-ID: <20190124053647.GG18231@xz-x1>
References: <20190121075722.7945-1-peterx@redhat.com>
 <20190121075722.7945-21-peterx@redhat.com>
 <20190121111039.GB26461@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190121111039.GB26461@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Mike Kravetz <mike.kravetz@oracle.com>, Marty McFadden <mcfadden8@llnl.gov>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, "Dr . David Alan Gilbert" <dgilbert@redhat.com>

On Mon, Jan 21, 2019 at 01:10:39PM +0200, Mike Rapoport wrote:
> On Mon, Jan 21, 2019 at 03:57:18PM +0800, Peter Xu wrote:
> > It does not make sense to try to wake up any waiting thread when we're
> > write-protecting a memory region.  Only wake up when resolving a write
> > protected page fault.
> 
> Probably it would be better to make it default to wake up only when
> requested explicitly?

Yes, I think that's what this series does?

Now when we do UFFDIO_WRITEPROTECT with !WP and !DONTWAKE then we'll
first resolve the page fault, then wake up the process properly.  And
we request that explicity using !WP and DONTWAKE.

Or did I misunderstood the question?

> Then we can simply disallow _DONTWAKE for uffd_wp and only use
> UFFDIO_WRITEPROTECT_MODE_WP as possible mode.

I'd admit I don't know the major usage of DONTWAKE (and I'd be glad to
know...), however since we have this flag for both UFFDIO_COPY and
UFFDIO_ZEROCOPY, then it seems sane to have DONTWAKE for WRITEPROTECT
too?  Or is there any other explicit reason to omit it?

Thanks!

-- 
Peter Xu
