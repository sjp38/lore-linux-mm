Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A046C6B024D
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 15:12:14 -0400 (EDT)
Message-Id: <20100709190706.938177313@quilx.com>
Date: Fri, 09 Jul 2010 14:07:06 -0500
From: Christoph Lameter <cl@linux-foundation.org>
Subject: [S+Q2 00/19] SLUB with queueing (V2) beats SLAB netperf TCP_RR
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nick Piggin <npiggin@suse.de>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

The following patchset cleans some pieces up and then equips SLUB with
per cpu queues that work similar to SLABs queues. With that approach
SLUB wins significantly in hackbench and improves also on tcp_rr.

Hackbench test script: 

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

Dell Dual Quad Penryn on Linux 2.6.35-rc3
Time measurements: Smaller is better:

Procs	NR		SLAB	SLUB	SLUB+Queuing     %
-------------------------------------------------------------
100	200000		2741.3	2764.7	2231.9		-18
100	20000		279.3	270.3	219.0		-27
100	20000		278.0	273.1	219.2		-26
100	20000		279.0	271.7	218.8		-27
10 	20000		34.0	35.6	28.8		-18
10	20000		30.3	35.2	28.4		-6
10	20000		32.9	34.6	28.4		-15
1	20000		6.4	6.7	6.5		+1
1	20000		6.3	6.8	6.5		+3
1	20000		6.4	6.9	6.4		0


SLUB+Q also wins against SLAB in netperf:

Script:

#!/bin/bash

TIME=60  # seconds
HOSTNAME=localhost       # netserver

NR_CPUS=$(grep ^processor /proc/cpuinfo | wc -l)
echo NR_CPUS=$NR_CPUS

run_netperf() {
for i in $(seq 1 $1); do
netperf -H $HOSTNAME -t TCP_RR -l $TIME &
done
}

ITERATIONS=0
while [ $ITERATIONS -lt 12 ]; do
RATE=0
ITERATIONS=$[$ITERATIONS + 1]   
THREADS=$[$NR_CPUS * $ITERATIONS]
RESULTS=$(run_netperf $THREADS | grep -v '[a-zA-Z]' | awk '{ print $6 }')

for j in $RESULTS; do
RATE=$[$RATE + ${j/.*}]
done
echo threads=$THREADS rate=$RATE
done


Dell Dual Quad Penryn on Linux 2.6.35-rc4

Loop counts: Larger is better.

Threads		SLAB		SLUB+Q		%
 8		690869		714788		+ 3.4
16		680295		711771		+ 4.6
24		672677		703014		+ 4.5
32		676780		703914		+ 4.0
40		668458		699806		+ 4.6
48		667017		698908		+ 4.7
56		671227		696034		+ 3.6
64		667956		696913		+ 4.3
72		668332		694931		+ 3.9
80		667073		695658		+ 4.2
88		682866		697077		+ 2.0
96		668089		694719		+ 3.9


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

The queueing patches are likely still be a bit rough around corner cases
and special features and need to see some more widespread testing.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
