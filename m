Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id A1A28440905
	for <linux-mm@kvack.org>; Fri, 14 Jul 2017 05:27:50 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g46so10835114wrd.3
        for <linux-mm@kvack.org>; Fri, 14 Jul 2017 02:27:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x73si1817680wma.0.2017.07.14.02.27.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Jul 2017 02:27:49 -0700 (PDT)
Date: Fri, 14 Jul 2017 10:27:47 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: Potential race in TLB flush batching?
Message-ID: <20170714092747.ebytils6c65zporo@suse.de>
References: <E37E0D40-821A-4C82-B924-F1CE6DF97719@gmail.com>
 <20170711132023.wdfpjxwtbqpi3wp2@suse.de>
 <CALCETrUOYwpJZAAVF8g+_U9fo5cXmGhYrM-ix+X=bbfid+j-Cw@mail.gmail.com>
 <20170711155312.637eyzpqeghcgqzp@suse.de>
 <CALCETrWjER+vLfDryhOHbJAF5D5YxjN7e9Z0kyhbrmuQ-CuVbA@mail.gmail.com>
 <20170711191823.qthrmdgqcd3rygjk@suse.de>
 <CALCETrXvkF3rxLijtou3ndSxG9vu62hrqh1ZXkaWgWbL-wd+cg@mail.gmail.com>
 <1500015641.2865.81.camel@kernel.crashing.org>
 <20170714083114.zhaz3pszrklnrn52@suse.de>
 <1500022977.2865.88.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1500022977.2865.88.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

On Fri, Jul 14, 2017 at 07:02:57PM +1000, Benjamin Herrenschmidt wrote:
> On Fri, 2017-07-14 at 09:31 +0100, Mel Gorman wrote:
> > It may also be only a gain on a limited number of architectures depending
> > on exactly how an architecture handles flushing. At the time, batching
> > this for x86 in the worse-case scenario where all pages being reclaimed
> > were mapped from multiple threads knocked 24.4% off elapsed run time and
> > 29% off system CPU but only on multi-socket NUMA machines. On UMA, it was
> > barely noticable. For some workloads where only a few pages are mapped or
> > the mapped pages on the LRU are relatively sparese, it'll make no difference.
> > 
> > The worst-case situation is extremely IPI intensive on x86 where many
> > IPIs were being sent for each unmap. It's only worth even considering if
> > you see that the time spent sending IPIs for flushes is a large portion
> > of reclaim.
> 
> Ok, it would be interesting to see how that compares to powerpc with
> its HW tlb invalidation broadcasts. We tend to hate them and prefer
> IPIs in most cases but maybe not *this* case .. (mostly we find that
> IPI + local inval is better for large scale invals, such as full mm on
> exit/fork etc...).
> 
> In the meantime I found the original commits, we'll dig and see if it's
> useful for us.
> 

I would suggest that it is based on top of Andy's work that is currently in
Linus' tree for 4.13-rc1 as the core/arch boundary is a lot clearer. While
there is other work pending on top related to mm and generation counters,
that is primarily important for addressing the race which ppc64 may not
need if you always flush to clear the accessed bit (or equivalent). The
main thing to watch for is that if an accessed or young bit is being set
for the first time that the arch check the underlying PTE and trap if it's
invalid. If that holds and there is a flush when the young bit is cleared
then you probably do not need the arch hook that closes the race.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
