Received: from localhost (hahn@localhost)
	by coffee.psychology.mcmaster.ca (8.9.3/8.9.3) with ESMTP id QAA27944
	for <linux-mm@kvack.org>; Sun, 8 Oct 2000 16:19:22 -0400
Date: Sun, 8 Oct 2000 16:19:22 -0400 (EDT)
From: Mark Hahn <hahn@coffee.psychology.mcmaster.ca>
Subject: too many context switches.
Message-ID: <Pine.LNX.4.10.10010081444380.26729-100000@coffee.psychology.mcmaster.ca>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

sorry about the width of this message!

I've noticed that spewing lots of data to a file causes 
an unreasonably large number of context switches on test9 SMP.
for instance, if I run bonnie/iozone/dd/etc to do lots of 
writes into a file, while running "vmstat 1", I see:

   procs                      memory    swap          io     system         cpu
 r  b  w   swpd   free   buff  cache  si  so    bi    bo   in    cs  us  sy  id
 0  0  0      0 114516    716   2100   0   0     2     0  105    17   0   0 100
 0  0  0      0 114516    716   2100   0   0     0     0  107    22   0   0 100
 0  1  1      0  50420    716  66104   0   0     0  4985  194 28075   0  26  74
 0  1  1      0  32464    716  84060   0   0     0  4282  244 16884   1  10  89
 1  0  1      0  19364    716  97364   0   0     0  3257  211 12114   0   8  92
 0  1  1      0   4708    712 111796   0   0     0  3708  242 12833   0  11  89
 0  1  1      0   1948    712 114556   0   0     0  4007  248 15605   0   9  91
 0  1  1      0   1948    712 114556   0   0     0  3557  226 13821   0   8  92
 0  1  1      0   1948    712 114548   0   0     0  4053  234 15641   0  11  89
 0  1  1      0   1948    712 114548   0   0     0  4017  237 15652   0  10  90
 0  1  1      0   1948    712 114548   0   0     0  3527  218 13703   0   7  93

the huge bursts of cs don't depend on buffer size, though if the IO is slow,
it's never triggered.  on UP, I see much smaller, but still unreasonable cs,
and it seems to depend on the size of writes:

8K writes:
 0  0  0   3260 101060   2404   5164   0   0     0     0  107    14   0   0 100
 0  0  0   3260 101060   2404   5164   0   0     0     0  106    15   0   0 100
 0  1  1   3260  38240   2404  67896   0   0     0  5786  193  7295   0  34  66
 0  1  1   3260  26068   2404  80068   0   0     0  2923  201  3242   0   6  94
 0  1  1   3260  14168   2404  91968   0   0     0  2885  200  3176   0   7  93
 1  0  1   3260   3172   2404 102964   0   0     0  2937  206  2951   0   9  91
 0  1  1   3260   1944   2404 104192   0   0     0  2855  199  2951   0   6  94
 0  1  1   3260   1944   2404 104192   0   0     0  2979  206  3218   0   8  92
 0  1  1   3260   1944   2404 104192   0   0     0  3100  204  3212   0   9  91

64K writes:
 0  0  0   3260 102504   2372   3752   0   0     0     0  105    14   0   0 100
 0  0  0   3260 102504   2372   3752   0   0     0     0  105    14   0   0 100
 0  1  1   3260  45976   2372  60192   0   0    24  3862  136   738   1  29  70
 0  1  1   3260  34956   2372  71212   0   0     0  2825  199   549   0   7  93
 0  1  1   3260  23056   2372  83112   0   0     0  2891  200   572   0   7  93
 0  1  1   3260  11140   2372  95028   0   0     0  2946  202   581   0   9  91
 0  1  1   3260   1944   2368 104228   0   0     0  2939  201   530   0   7  93

both machines are 128M, udma, and the files are much larger than ram.

I speculate that there's something broken in the VM wait/wake/scheduling stuff,
possibly involving pages entering the inactive_dirty list.  cs bursts seem to 
correspond to large increases in inactive_dirty reported in /proc/meminfo
with the following little script ("memstat" ala vmstat):

#!/usr/bin/perl
$interval = 1;
if (!$#ARGV) { $interval = $ARGV[0]; }

open(IN,"</proc/meminfo") || die("failed to open meminfo");
while (1) {
    seek(IN,0,SEEK_SET);
    while (<IN>) {
	if (/^MemFree:\s+(\d+)/)	{$mf=$1; next; }
	if (/^Buffers:\s+(\d+)/)	{$buf=$1; next; }
	if (/^Active:\s+(\d+)/)		{$act=$1; next; }
	if (/^Inact_dirty:\s+(\d+)/)	{$id=$1; next; }
	if (/^Inact_clean:\s+(\d+)/)	{$ic=$1; next; }
	if (/^Inact_target:\s+(\d+)/)	{$it=$1; next; }
	if (/^SwapTotal:\s+(\d+)/)	{$st=$1; next; }
	if (/^SwapFree:\s+(\d+)/)	{$sf=$1; next; }
    }

    (!($c++ % 20)) && printf(
" memfree      buf      act   idirty   iclean   target       sw\n");
    printf("% 8d % 8d % 8d % 8d % 8d % 8d % 8d\n",
	   $mf,$buf,$act,$id,$ic,$it,$st-$sf);
    sleep($interval);
}

-- 
operator may differ from spokesperson.	            hahn@coffee.mcmaster.ca
                                              http://java.mcmaster.ca/~hahn

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
