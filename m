Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 855326B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 18:26:36 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so9361572pac.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:26:36 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id m2si32119281pdd.173.2015.09.01.15.26.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 15:26:35 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so9361303pac.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:26:35 -0700 (PDT)
Date: Tue, 1 Sep 2015 15:26:34 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Can we disable transparent hugepages for lack of a legitimate
 use case please?
In-Reply-To: <55DC3BD4.6020602@suse.cz>
Message-ID: <alpine.DEB.2.10.1509011522470.11913@chino.kir.corp.google.com>
References: <BLUPR02MB1698DD8F0D1550366489DF8CCD620@BLUPR02MB1698.namprd02.prod.outlook.com> <CALYGNiOg_Zq8Fz-VWskH7LVGdExuq=03+56dpCsDiZ6eAq2A4Q@mail.gmail.com> <55DC3BD4.6020602@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, James Hartshorn <jhartshorn@connexity.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Tue, 25 Aug 2015, Vlastimil Babka wrote:

> > THP works very well when system has a lot of free memory.
> > Probably default should be weakened to "only if we have tons of free
> > memory".
> > For example allocate THP pages atomically, only if buddy allocator already
> > has huge pages. Also them could be pre-zeroed in background.
> 
> I've been proposing series that try to move more THP allocation activity from
> the page faults into khugepaged, but no success yet.
> 
> Maybe we should just start with changing the default of
> /sys/kernel/mm/transparent_hugepage/defrag to "madvise".

I would need to revert this internally to avoid performance degradation, I 
believe others would report the same.

> This would remove the
> reclaim and compaction for page faults and quickly fallback to order-0 pages.
> The compaction is already crippled enough there with the GFP_TRANSHUGE
> specific decisions in __alloc_pages_slowpath(). I've noticed it failing
> miserably in the transhuge-stress recently, so it seems it's not worth to try
> at all. With changing the default we can kill those GFP_TRANSHUGE checks and
> assume that whoever uses the madvise does actually want to try harder.
> 

I think the work that is being done on moving compaction to khugepaged as 
well as periodic synchronous compaction of all memory is the way to go to 
avoid lengthy stalls during fault.

> Of course that does nothing about zeroing. I don't know how huge issue is that
> one?
> 

I don't believe it is an issue that cannot be worked around in userspace 
either with MADV_NOHUGEPAGE or PR_SET_THP_DISABLE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
