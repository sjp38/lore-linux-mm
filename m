Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 231406B0159
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 07:04:28 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so1047688pad.10
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 04:04:27 -0800 (PST)
Received: from psmtp.com ([74.125.245.137])
        by mx.google.com with SMTP id do4si8567428pbc.107.2013.11.11.04.04.25
        for <linux-mm@kvack.org>;
        Mon, 11 Nov 2013 04:04:26 -0800 (PST)
Received: by mail-ea0-f173.google.com with SMTP id g10so2703601eak.18
        for <linux-mm@kvack.org>; Mon, 11 Nov 2013 04:04:23 -0800 (PST)
Date: Mon, 11 Nov 2013 13:04:21 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm: cache largest vma
Message-ID: <20131111120421.GB21291@gmail.com>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
 <CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
 <1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
 <20131104073640.GF13030@gmail.com>
 <1384143129.6940.32.camel@buesod1.americas.hpqcorp.net>
 <CANN689Eauq+DHQrn8Wr=VU-PFGDOELz6HTabGDGERdDfeOK_UQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANN689Eauq+DHQrn8Wr=VU-PFGDOELz6HTabGDGERdDfeOK_UQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>


* Michel Lespinasse <walken@google.com> wrote:

> On Sun, Nov 10, 2013 at 8:12 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> > 2) Oracle Data mining (4K pages)
> > +------------------------+----------+------------------+---------+
> > |    mmap_cache type     | hit-rate | cycles (billion) | stddev  |
> > +------------------------+----------+------------------+---------+
> > | no mmap_cache          | -        | 63.35            | 0.20207 |
> > | current mmap_cache     | 65.66%   | 19.55            | 0.35019 |
> > | mmap_cache+largest VMA | 71.53%   | 15.84            | 0.26764 |
> > | 4 element hash table   | 70.75%   | 15.90            | 0.25586 |
> > | per-thread mmap_cache  | 86.42%   | 11.57            | 0.29462 |
> > +------------------------+----------+------------------+---------+
> >
> > This workload sure makes the point of how much we can benefit of 
> > caching the vma, otherwise find_vma() can cost more than 220% extra 
> > cycles. We clearly win here by having a per-thread cache instead of 
> > per address space. I also tried the same workload with 2Mb hugepages 
> > and the results are much more closer to the kernel build, but with the 
> > per-thread vma still winning over the rest of the alternatives.
> >
> > All in all I think that we should probably have a per-thread vma 
> > cache. Please let me know if there is some other workload you'd like 
> > me to try out. If folks agree then I can cleanup the patch and send it 
> > out.
> 
> Per thread cache sounds interesting - with per-mm caches there is a real 
> risk that some modern threaded apps pay the cost of cache updates 
> without seeing much of the benefit. However, how do you cheaply handle 
> invalidations for the per thread cache ?

The cheapest way to handle that would be to have a generation counter for 
the mm and to couple cache validity to a specific value of that. 
'Invalidation' is then the free side effect of bumping the generation 
counter when a vma is removed/moved.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
