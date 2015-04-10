Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2AFEA6B0038
	for <linux-mm@kvack.org>; Fri, 10 Apr 2015 17:10:49 -0400 (EDT)
Received: by igblo3 with SMTP id lo3so8147876igb.1
        for <linux-mm@kvack.org>; Fri, 10 Apr 2015 14:10:49 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id mk7si3079927icb.23.2015.04.10.14.10.48
        for <linux-mm@kvack.org>;
        Fri, 10 Apr 2015 14:10:48 -0700 (PDT)
Date: Fri, 10 Apr 2015 18:10:49 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 3/9] perf kmem: Analyze page allocator events also
Message-ID: <20150410211049.GA17496@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-4-git-send-email-namhyung@kernel.org>
 <20150410210629.GF4521@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150410210629.GF4521@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Em Fri, Apr 10, 2015 at 06:06:29PM -0300, Arnaldo Carvalho de Melo escreveu:
> Em Mon, Apr 06, 2015 at 02:36:10PM +0900, Namhyung Kim escreveu:
> > The perf kmem command records and analyze kernel memory allocation
> > only for SLAB objects.  This patch implement a simple page allocator
> > analyzer using kmem:mm_page_alloc and kmem:mm_page_free events.
> > 
> > It adds two new options of --slab and --page.  The --slab option is
> > for analyzing SLAB allocator and that's what perf kmem currently does.
> > 
> > The new --page option enables page allocator events and analyze kernel
> > memory usage in page unit.  Currently, 'stat --alloc' subcommand is
> > implemented only.
> > 
> > If none of these --slab nor --page is specified, --slab is implied.
> > 
> >   # perf kmem stat --page --alloc --line 10
> 
> Hi, applied the first patch, the kernel one, reboot with that kernel:

<SNIP>

> [root@ssdandy ~]#
> 
> What am I missing?

Argh, I was expecting to read just what is in that cset and be able to
reproduce the results, had to go back to the [PATCH 0/0] cover letter to
figure out that I need to run:

perf kmem record --page sleep 5

With that I get:

[root@ssdandy ~]# perf kmem stat --page --alloc --line 20

--------------------------------------------------------------------------------
 PFN              | Total alloc (KB) | Hits      | Order | Mig.type | GFP flags
--------------------------------------------------------------------------------
          3487838 |               12 |         3 |     0 | UNMOVABL |  00020010
          3493414 |                8 |         2 |     0 | UNMOVABL |  000284d0
          3487761 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3487764 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3487982 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3487991 |                4 |         1 |     0 | UNMOVABL |  000284d0
          3488046 |                4 |         1 |     0 | UNMOVABL |  002284d0
          3488057 |                4 |         1 |     0 | UNMOVABL |  000200d0
          3488191 |                4 |         1 |     0 | UNMOVABL |  002284d0
          3488203 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488206 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488210 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488211 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488213 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488215 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488298 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488325 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488326 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488327 |                4 |         1 |     0 | UNMOVABL |  000202d0
          3488329 |                4 |         1 |     0 | UNMOVABL |  000202d0
 ...              | ...              | ...       | ...   | ...      | ...     
--------------------------------------------------------------------------------

SUMMARY (page allocator)
========================
Total allocation requests     :              166   [              664 KB ]
Total free requests           :              239   [              956 KB ]

Total alloc+freed requests    :               49   [              196 KB ]
Total alloc-only requests     :              117   [              468 KB ]
Total free-only requests      :              190   [              760 KB ]

Total allocation failures     :                0   [                0 KB ]

Order     Unmovable   Reclaimable       Movable      Reserved  CMA/Isolated
-----  ------------  ------------  ------------  ------------  ------------
    0           143             .            23             .             .
    1             .             .             .             .             .
    2             .             .             .             .             .
    3             .             .             .             .             .
    4             .             .             .             .             .
    5             .             .             .             .             .
    6             .             .             .             .             .
    7             .             .             .             .             .
    8             .             .             .             .             .
    9             .             .             .             .             .
   10             .             .             .             .             .
[root@ssdandy ~]#

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
