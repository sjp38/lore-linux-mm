Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 53A976B0032
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:05:10 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so97705294pdb.0
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 00:05:10 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id f7si14547454pdk.95.2015.04.13.00.05.07
        for <linux-mm@kvack.org>;
        Mon, 13 Apr 2015 00:05:09 -0700 (PDT)
Date: Mon, 13 Apr 2015 15:59:24 +0900
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH 3/9] perf kmem: Analyze page allocator events also
Message-ID: <20150413065924.GH23913@sejong>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-4-git-send-email-namhyung@kernel.org>
 <20150410210629.GF4521@kernel.org>
 <20150410211049.GA17496@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150410211049.GA17496@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Hi Arnaldo,

On Fri, Apr 10, 2015 at 06:10:49PM -0300, Arnaldo Carvalho de Melo wrote:
> Em Fri, Apr 10, 2015 at 06:06:29PM -0300, Arnaldo Carvalho de Melo escreveu:
> > Em Mon, Apr 06, 2015 at 02:36:10PM +0900, Namhyung Kim escreveu:
> > > The perf kmem command records and analyze kernel memory allocation
> > > only for SLAB objects.  This patch implement a simple page allocator
> > > analyzer using kmem:mm_page_alloc and kmem:mm_page_free events.
> > > 
> > > It adds two new options of --slab and --page.  The --slab option is
> > > for analyzing SLAB allocator and that's what perf kmem currently does.
> > > 
> > > The new --page option enables page allocator events and analyze kernel
> > > memory usage in page unit.  Currently, 'stat --alloc' subcommand is
> > > implemented only.
> > > 
> > > If none of these --slab nor --page is specified, --slab is implied.
> > > 
> > >   # perf kmem stat --page --alloc --line 10
> > 
> > Hi, applied the first patch, the kernel one, reboot with that kernel:
> 
> <SNIP>
> 
> > [root@ssdandy ~]#
> > 
> > What am I missing?
> 
> Argh, I was expecting to read just what is in that cset and be able to
> reproduce the results, had to go back to the [PATCH 0/0] cover letter to
> figure out that I need to run:
> 
> perf kmem record --page sleep 5

Right.  Maybe I need to change to print warning if no events found
with option.


> 
> With that I get:
> 
> [root@ssdandy ~]# perf kmem stat --page --alloc --line 20
> 
> --------------------------------------------------------------------------------
>  PFN              | Total alloc (KB) | Hits      | Order | Mig.type | GFP flags
> --------------------------------------------------------------------------------
>           3487838 |               12 |         3 |     0 | UNMOVABL |  00020010
>           3493414 |                8 |         2 |     0 | UNMOVABL |  000284d0
>           3487761 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3487764 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3487982 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3487991 |                4 |         1 |     0 | UNMOVABL |  000284d0
>           3488046 |                4 |         1 |     0 | UNMOVABL |  002284d0
>           3488057 |                4 |         1 |     0 | UNMOVABL |  000200d0
>           3488191 |                4 |         1 |     0 | UNMOVABL |  002284d0
>           3488203 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488206 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488210 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488211 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488213 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488215 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488298 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488325 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488326 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488327 |                4 |         1 |     0 | UNMOVABL |  000202d0
>           3488329 |                4 |         1 |     0 | UNMOVABL |  000202d0
>  ...              | ...              | ...       | ...   | ...      | ...     
> --------------------------------------------------------------------------------

Hmm.. looks like you ran some old version.  Please check v6! :)

Thanks,
Namhyung


> 
> SUMMARY (page allocator)
> ========================
> Total allocation requests     :              166   [              664 KB ]
> Total free requests           :              239   [              956 KB ]
> 
> Total alloc+freed requests    :               49   [              196 KB ]
> Total alloc-only requests     :              117   [              468 KB ]
> Total free-only requests      :              190   [              760 KB ]
> 
> Total allocation failures     :                0   [                0 KB ]
> 
> Order     Unmovable   Reclaimable       Movable      Reserved  CMA/Isolated
> -----  ------------  ------------  ------------  ------------  ------------
>     0           143             .            23             .             .
>     1             .             .             .             .             .
>     2             .             .             .             .             .
>     3             .             .             .             .             .
>     4             .             .             .             .             .
>     5             .             .             .             .             .
>     6             .             .             .             .             .
>     7             .             .             .             .             .
>     8             .             .             .             .             .
>     9             .             .             .             .             .
>    10             .             .             .             .             .
> [root@ssdandy ~]#
> 
> - Arnaldo
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
