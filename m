Date: Thu, 2 Aug 2007 15:09:05 +0100
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-ID: <20070802140904.GA16940@skynet.ie>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On (25/07/07 12:31), Christoph Lameter didst pronounce:

> > Here is the patch just to handle policies with ZONE_MOVABLE. The highest
> > zone still gets treated as it does today but allocations using ZONE_MOVABLE
> > will still be policied. It has been boot-tested and a basic compile job run
> > on a x86_64 NUMA machine (elm3b6 on test.kernel.org). Is there a
> > standard test for regression testing policies?
> 
> There is a test in the numactl package by Andi Kleen.
> 

This was a whole pile of fun. I tried to use the regression test from numactl
0.9.10 and found it failed on a number of kernels - 2.6.23-rc1, 2.6.22,
2.6.21, 2.6.20 etc with an x86_64. Was this known or did it just work for
other people? Whether this test is buggy or not is a matter of definition.

The regression tests depend on reading a numastat file from /sys before and
after running a program that consumes memory called memhog. The tests both
numactl and the numa APIs. The values in numastat are checked before and
after memhog runs to make sure the values are as expected.

This is all great and grand until you realise those counters are not guaranteed
to be up-to-date. They are per-cpu variables were are refreshed every second
by default. This means when the regression test reads them immediately after
memhog exits, it may read a stale value and "fail". If it had waited a few
seconds and tried again, it would have got the right value and passed.

Hence the regression test is dependant on timing. The question is if the values
should always be up-to-date when read from userspace. I put together one patch
that would refresh the counters when numastat or vmstat was being read but it
requires a per-cpu function to be called. This may be undesirable as it would
be punishing on large systems running tools that frequently read /proc/vmstat
for example. Was it done this way on purpose? The comments around the stats
code would led me to believe this lag is on purpose to avoid per-cpu calls.

The alternative was to apply this patch to numactl so that the
regression test waits on the timers to update. With this patch, the
regression tests passed on a 4-node x86_64 machine.

Signed-off-by: Mel Gorman <mel.csn.ul.ie>

---
 regress |    8 ++++++++
 1 file changed, 8 insertions(+)

diff -ru numactl-0.9.10-orig/test/regress numactl-0.9.10/test/regress
--- numactl-0.9.10-orig/test/regress	2007-08-01 19:56:07.000000000 +0100
+++ numactl-0.9.10/test/regress	2007-08-02 14:49:16.000000000 +0100
@@ -7,11 +7,18 @@
 SIZE=$[30 * $MB]
 DEMOSIZE=$[10 * $MB]
 VALGRIND=${VALGRIND:-}
+STAT_INTERVAL=5
 
 numactl() { 
 	$VALGRIND ../numactl "$@"
 }
 
+# Get the interval vm statistics refresh at
+if [ -e /proc/sys/vm/stat_interval ]; then
+	STAT_INTERVAL=`cat /proc/sys/vm/stat_interval`
+	STAT_INTERVAL=`expr $STAT_INTERVAL \* 2`
+fi
+
 BASE=`pwd`/..
 export LD_LIBRARY_PATH=$BASE
 export PATH=$BASE:$PATH
@@ -40,6 +47,7 @@
 
 # args: statname node
 nstat() { 
+    sleep $STAT_INTERVAL
     declare -a fields
     numastat | grep $1 | while read -a fields ; do	
 	echo ${fields[$[1 + $2]]}
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
