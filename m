Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 905B86B027D
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 21:41:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so24901990wmg.3
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 18:41:57 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o11si17255282wme.98.2016.09.27.18.41.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Sep 2016 18:41:56 -0700 (PDT)
Date: Tue, 27 Sep 2016 21:41:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Regression in mobility grouping?
Message-ID: <20160928014148.GA21007@cmpxchg.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="Kj7319i9nmIyA2yE"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <js1304@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi guys,

we noticed what looks like a regression in page mobility grouping
during an upgrade from 3.10 to 4.0. Identical machines, workloads, and
uptime, but /proc/pagetypeinfo on 3.10 looks like this:

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate 
Node 1, zone   Normal          815          433        31518            2            0 

and on 4.0 like this:

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate 
Node 1, zone   Normal         3880         3530        25356            2            0            0 

4.0 is either polluting pageblocks more aggressively at allocation, or
is not able to make pageblocks movable again when the reclaimable and
unmovable allocations are released. Invoking compaction manually
(/proc/sys/vm/compact_memory) is not bringing them back, either.

The problem we are debugging is that these machines have a very high
rate of order-3 allocations (fdtable during fork, network rx), and
after the upgrade allocstalls have increased dramatically. I'm not
entirely sure this is the same issue, since even order-0 allocations
are struggling, but the mobility grouping in itself looks problematic.

I'm still going through the changes relevant to mobility grouping in
that timeframe, but if this rings a bell for anyone, it would help. I
hate blaming random patches, but these caught my eye:

9c0415e mm: more aggressive page stealing for UNMOVABLE allocations
3a1086f mm: always steal split buddies in fallback allocations
99592d5 mm: when stealing freepages, also take pages created by splitting buddy page

The changelog states that by aggressively stealing split buddy pages
during a fallback allocation we avoid subsequent stealing. But since
there are generally more movable/reclaimable pages available, and so
less falling back and stealing freepages on behalf of movable, won't
this mean that we could expect exactly that result - growing numbers
of unmovable blocks, while rarely stealing them back in movable alloc
fallbacks? And the expansion of !MOVABLE blocks would over time make
compaction less and less effective too, seeing as it doesn't consider
anything !MOVABLE suitable migration targets?

Attached are the full /proc/pagetypeinfo and /proc/buddyinfo from both
kernels on machines with similar uptimes and directly after invoking
compaction. As you can see, the buddy lists are much more fragmented
on 4.0, with unmovable/reclaimable allocations polluting more blocks.

Any thoughts on this would be greatly appreciated. I can test patches.

Thanks!

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="buddyinfo-3.10.txt"

Node 0, zone      DMA      0      0      0      1      2      1      1      0      1      1      3 
Node 0, zone    DMA32   1062   1491   1641   1725    478     77      5      1      0      0      0 
Node 0, zone   Normal  10436  16239   5903    696    130    729   1298    550    109      0      0 
Node 1, zone   Normal   5956     15      5     28     11      8      2      0      0      0      0 

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="buddyinfo-4.0.txt"

Node 0, zone      DMA      1      1      0      1      1      1      1      0      0      1      3 
Node 0, zone    DMA32   9462   6148   2297     27      0      0      0      0      0      0      0 
Node 0, zone   Normal 130376  36589   3777     94      1      0      0      0      0      0      0 
Node 1, zone   Normal 190988  77269   3896    332      6      0      0      0      0      0      0 

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="pagetypeinfo-3.10.txt"

Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10 
Node    0, zone      DMA, type    Unmovable      0      0      0      1      2      1      1      0      1      0      0 
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      3 
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      1      0 
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type    Unmovable    488    221    286      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type  Reclaimable      1    725    741      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Movable    431   1735   1073    105      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Reserve      0      0      0     17      1      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type    Unmovable   1922     16      1     19      0      0      0      0      0      0      0 
Node    0, zone   Normal, type  Reclaimable   4549      0      0      1      0      0      0      0      0      0      0 
Node    0, zone   Normal, type      Movable      3      0      2      3      0      0      0      0      0      0      0 
Node    0, zone   Normal, type      Reserve      0      0      1     22      1      2      1      0      0      0      0 
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate 
Node 0, zone      DMA            1            0            6            1            0 
Node 0, zone    DMA32           96           21          898            1            0 
Node 0, zone   Normal         1105          497        30140            2            0 
Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10 
Node    1, zone   Normal, type    Unmovable   5746      3      0      0      0      0      0      0      0      0      0 
Node    1, zone   Normal, type  Reclaimable     53     10      0      0      0      0      0      0      0      0      0 
Node    1, zone   Normal, type      Movable      1   2919   1131      0      0      0      0      0      0      0      0 
Node    1, zone   Normal, type      Reserve      0      0      0      0      0      1      2      0      0      0      0 
Node    1, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve      Isolate 
Node 1, zone   Normal          868          433        31465            2            0 

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="pagetypeinfo-4.0.txt"

Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10 
Node    0, zone      DMA, type    Unmovable      1      1      0      1      1      1      1      0      0      0      0 
Node    0, zone      DMA, type  Reclaimable      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone      DMA, type      Movable      0      0      0      0      0      0      0      0      0      0      3 
Node    0, zone      DMA, type      Reserve      0      0      0      0      0      0      0      0      0      1      0 
Node    0, zone      DMA, type          CMA      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone      DMA, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type    Unmovable   2717   4401    895      1      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type  Reclaimable   6004   1784      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Movable      1      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Reserve      0      0      3      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type          CMA      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone    DMA32, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type    Unmovable 115050  40237   3785      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type  Reclaimable  51921  14109    659      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type      Movable      1  41954    984      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type      Reserve      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0 
Node    0, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate 
Node 0, zone      DMA            1            0            6            1            0            0 
Node 0, zone    DMA32          620          184          211            1            0            0 
Node 0, zone   Normal         6634         3757        21351            2            0            0 
Page block order: 9
Pages per block:  512

Free pages count per migrate type at order       0      1      2      3      4      5      6      7      8      9     10 
Node    1, zone   Normal, type    Unmovable  58723    366     15      6      0      0      0      0      0      0      0 
Node    1, zone   Normal, type  Reclaimable    163     74      5      1      0      0      0      0      0      0      0 
Node    1, zone   Normal, type      Movable   1217    283     10      0      0      0      0      0      0      0      0 
Node    1, zone   Normal, type      Reserve      0      0      0      3      0      0      0      0      0      0      0 
Node    1, zone   Normal, type          CMA      0      0      0      0      0      0      0      0      0      0      0 
Node    1, zone   Normal, type      Isolate      0      0      0      0      0      0      0      0      0      0      0 

Number of blocks type     Unmovable  Reclaimable      Movable      Reserve          CMA      Isolate 
Node 1, zone   Normal         3903         3518        25345            2            0            0 

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="extfrag-3.10.txt"

Node 0, zone      DMA -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 
Node 0, zone    DMA32 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.981 0.991 0.996 0.998 
Node 0, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.977 0.989 0.995 0.998 
Node 1, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.982 0.991 0.996 0.998 

--Kj7319i9nmIyA2yE
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="extfrag-4.0.txt"

Node 0, zone      DMA -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 
Node 0, zone    DMA32 -1.000 -1.000 -1.000 -1.000 0.868 0.934 0.967 0.984 0.992 0.996 0.998 
Node 0, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.972 0.986 0.993 0.997 0.999 
Node 1, zone   Normal -1.000 -1.000 -1.000 -1.000 -1.000 -1.000 0.972 0.986 0.993 0.997 0.999 

--Kj7319i9nmIyA2yE--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
