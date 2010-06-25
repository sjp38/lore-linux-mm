Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 853DF6B01AD
	for <linux-mm@kvack.org>; Fri, 25 Jun 2010 17:24:22 -0400 (EDT)
Message-Id: <20100625212026.810557229@quilx.com>
Date: Fri, 25 Jun 2010 16:20:26 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q 00/16] SLUB with Queueing beats SLAB in hackbench
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

The following patchset cleans some pieces up and then equips SLUB with
per cpu queues that work similar to SLABs queues. With that approach
SLUB wins in hackbench:

#!/bin/bash 
uname -a
echo "./hackbench 100 process 200000"
./hackbench 100 process 200000
echo "./hackbench 100 process 20000"
./hackbench 100 process 20000
echo "./hackbench 100 process 20000"
./hackbench 100 process 20000
echo "./hackbench 100 process 20000"
./hackbench 100 process 20000
echo "./hackbench 10 process 20000"
./hackbench 10 process 20000
echo "./hackbench 10 process 20000"
./hackbench 10 process 20000
echo "./hackbench 10 process 20000"
./hackbench 10 process 20000
echo "./hackbench 1 process 20000"
./hackbench 1 process 20000
echo "./hackbench 1 process 20000"
./hackbench 1 process 20000
echo "./hackbench 1 process 20000"
./hackbench 1 process 20000

Procs	NR		SLAB	SLUB	SLUB+Queuing
----------------------------------------------------
100	200000		2741.3	2764.7	2231.9
100	20000		279.3	270.3	219.0
100	20000		278.0	273.1	219.2
100	20000		279.0	271.7	218.8
10 	20000		34.0	35.6	28.8
10	20000		30.3	35.2	28.4
10	20000		32.9	34.6	28.4
1	20000		6.4	6.7	6.5
1	20000		6.3	6.8	6.5
1	20000		6.4	6.9	6.4


SLUB+Q is a merging of SLUB with some queuing concepts from SLAB and a
new way of managing objects in the slabs using bitmaps. It uses a percpu
queue so that free operations can be properly buffered and a bitmap for
managing the free/allocated state in the slabs. It is slightly more
inefficient than SLUB (due to the need to place large bitmaps --sized
a few words--in some slab pages if there are more than BITS_PER_LONG
objects in a slab) but in general does not increase space use too much.

The SLAB scheme of not touching the object during management is adopted.
SLUB+Q can efficiently free and allocate cache cold objects without
causing cache misses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
