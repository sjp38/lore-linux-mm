Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EF6866B0169
	for <linux-mm@kvack.org>; Mon, 11 Nov 2013 02:43:46 -0500 (EST)
Received: by mail-pd0-f170.google.com with SMTP id q10so1554077pdj.29
        for <linux-mm@kvack.org>; Sun, 10 Nov 2013 23:43:46 -0800 (PST)
Received: from psmtp.com ([74.125.245.201])
        by mx.google.com with SMTP id w7si14976704pbg.262.2013.11.10.23.43.44
        for <linux-mm@kvack.org>;
        Sun, 10 Nov 2013 23:43:45 -0800 (PST)
Received: by mail-qa0-f54.google.com with SMTP id j7so1553149qaq.20
        for <linux-mm@kvack.org>; Sun, 10 Nov 2013 23:43:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1384143129.6940.32.camel@buesod1.americas.hpqcorp.net>
References: <1383337039.2653.18.camel@buesod1.americas.hpqcorp.net>
	<CA+55aFwrtOaFtwGc6xyZH6-1j3f--AG1JS-iZM8-pZPnwRHBow@mail.gmail.com>
	<1383537862.2373.14.camel@buesod1.americas.hpqcorp.net>
	<20131104073640.GF13030@gmail.com>
	<1384143129.6940.32.camel@buesod1.americas.hpqcorp.net>
Date: Sun, 10 Nov 2013 23:43:43 -0800
Message-ID: <CANN689Eauq+DHQrn8Wr=VU-PFGDOELz6HTabGDGERdDfeOK_UQ@mail.gmail.com>
Subject: Re: [PATCH] mm: cache largest vma
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Guan Xuetao <gxt@mprc.pku.edu.cn>, "Chandramouleeswaran, Aswin" <aswin@hp.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, Nov 10, 2013 at 8:12 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> 2) Oracle Data mining (4K pages)
> +------------------------+----------+------------------+---------+
> |    mmap_cache type     | hit-rate | cycles (billion) | stddev  |
> +------------------------+----------+------------------+---------+
> | no mmap_cache          | -        | 63.35            | 0.20207 |
> | current mmap_cache     | 65.66%   | 19.55            | 0.35019 |
> | mmap_cache+largest VMA | 71.53%   | 15.84            | 0.26764 |
> | 4 element hash table   | 70.75%   | 15.90            | 0.25586 |
> | per-thread mmap_cache  | 86.42%   | 11.57            | 0.29462 |
> +------------------------+----------+------------------+---------+
>
> This workload sure makes the point of how much we can benefit of caching
> the vma, otherwise find_vma() can cost more than 220% extra cycles. We
> clearly win here by having a per-thread cache instead of per address
> space. I also tried the same workload with 2Mb hugepages and the results
> are much more closer to the kernel build, but with the per-thread vma
> still winning over the rest of the alternatives.
>
> All in all I think that we should probably have a per-thread vma cache.
> Please let me know if there is some other workload you'd like me to try
> out. If folks agree then I can cleanup the patch and send it out.

Per thread cache sounds interesting - with per-mm caches there is a
real risk that some modern threaded apps pay the cost of cache updates
without seeing much of the benefit. However, how do you cheaply handle
invalidations for the per thread cache ?

If you have a nice simple scheme for invalidations, I could see per
thread LRU cache working well.

That said, the difficulty with this kind of measurements
(instrumenting code to fish out the cost of a particular function) is
that it would be easy to lose somewhere else - for example for keeping
the cache up to date - and miss that on the instrumented measurement.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
