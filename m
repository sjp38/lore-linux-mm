Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 37E0C6B0273
	for <linux-mm@kvack.org>; Mon, 22 Oct 2018 16:45:20 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n79-v6so18801030pfg.13
        for <linux-mm@kvack.org>; Mon, 22 Oct 2018 13:45:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5-v6sor3408992pgl.8.2018.10.22.13.45.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Oct 2018 13:45:18 -0700 (PDT)
Date: Mon, 22 Oct 2018 13:45:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: thp:  relax __GFP_THISNODE for MADV_HUGEPAGE
 mappings
In-Reply-To: <20181015225743.GB30832@redhat.com>
Message-ID: <alpine.DEB.2.21.1810221337270.120157@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810051320270.202739@chino.kir.corp.google.com> <20181005232155.GA2298@redhat.com> <alpine.DEB.2.21.1810081303060.221006@chino.kir.corp.google.com> <20181009094825.GC6931@suse.de> <20181009122745.GN8528@dhcp22.suse.cz>
 <20181009130034.GD6931@suse.de> <20181009142510.GU8528@dhcp22.suse.cz> <20181009230352.GE9307@redhat.com> <alpine.DEB.2.21.1810101410530.53455@chino.kir.corp.google.com> <alpine.DEB.2.21.1810151525460.247641@chino.kir.corp.google.com>
 <20181015225743.GB30832@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Argangeli <andrea@kernel.org>, Zi Yan <zi.yan@cs.rutgers.edu>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On Mon, 15 Oct 2018, Andrea Arcangeli wrote:

> > At the risk of beating a dead horse that has already been beaten, what are 
> > the plans for this patch when the merge window opens?  It would be rather 
> > unfortunate for us to start incurring a 14% increase in access latency and 
> > 40% increase in fault latency.  Would it be possible to test with my 
> > patch[*] that does not try reclaim to address the thrashing issue?  If 
> > that is satisfactory, I don't have a strong preference if it is done with 
> > a hardcoded pageblock_order and __GFP_NORETRY check or a new 
> > __GFP_COMPACT_ONLY flag.
> 
> I don't like the pageblock size hardcoding inside the page
> allocator. __GFP_COMPACT_ONLY is fully runtime equivalent, but it at
> least let the caller choose the behavior, so it looks more flexible.
> 

I'm not sure that I understand why the user would ever want to thrash 
their zone(s) for allocations of this order.  The problem here is 
specifically related to an entire pageblock becoming freeable and the 
unlikeliness that reclaiming/swapping/thrashing will assist memory 
compaction in making that happen.  For this reason, I think the 
order >= pageblock_order check is reasonable because it depends on the 
implementation of memory compaction.

Why do we need another gfp flag for thp allocations when they are made to 
be __GFP_NORETRY by default and it is very unlikely that reclaiming once 
and then retrying compaction is going to make an entire pageblock free?

I'd like to know (1) how continuous reclaim activity can make entire 
pageblocks freeable without thrashing and (2) the metrics that we can use 
to determine when it is worthwhile vs harmful.  I don't believe (1) is 
ever helpful based on the implementation of memory compaction and we lack 
(2) since reclaim is not targeted to memory that compaction can use.

> As long as compaction returns COMPACT_SKIPPED it's ok to keep doing
> reclaim and keep doing compaction, as long as compaction succeeds.
> 

Compaction will operate on 32 pages at a time and declare success each 
time and then pick up where it left off the next time it is called in the 
hope that it "succeeds" 512/32=16 times in a row while constantly 
reclaiming memory.  Even a single slab page in that pageblock will make 
all of this work useless.  Reclaimed memory not accessible by the freeing 
scanner will make its work useless.  We lack the ability to determine when 
compaction is successful in freeing a full pageblock.
