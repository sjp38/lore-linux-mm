Date: Thu, 17 May 2001 20:39:33 +0200
From: =?iso-8859-1?Q?Ragnar_Kj=F8rstad?= <kernel@ragnark.vestdata.no>
Subject: SMP/highmem problem
Message-ID: <20010517203933.F6360@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: tlan@stud.ntnu.no
List-ID: <linux-mm.kvack.org>

I've run into a performance issue.

I'm testing SMP performance on a 4 CPU Xeon box with 8 GB RAM. 
No swap. Standard linux 2.4.4, configured with CONFIG_HIGHMEM64G
enabled.

I use a single process, bonnie++, that creates 16 1 GB files.
However, after a while, the machine gets really unresponsive (ls -l
/root takes literally several minutes when /root is not in the
cache) and the load gets really high. According to top, all CPU 
power is spent in the kernel, mainly on kswapd, bdflush and 
kupdated.

  7:19pm  up  2:11,  6 users,  load average: 8.58, 9.34, 7.34
48 processes: 42 sleeping, 5 running, 1 zombie, 0 stopped
CPU0 states:  0.1% user, 99.10% system,  0.0% nice,  0.0% idle
CPU1 states:  0.0% user, 100.0% system,  0.0% nice,  0.0% idle
CPU2 states:  0.0% user, 100.0% system,  0.0% nice,  0.0% idle
CPU3 states:  0.1% user, 99.10% system,  0.0% nice,  0.0% idle
Mem:  7721928K av, 7719308K used,    2620K free,       0K shrd,    3612K buff
Swap:       0K av,       0K used,       0K free                 7597616K cached

  PID USER     PRI  NI  SIZE  RSS SHARE STAT %CPU %MEM   TIME COMMAND
    3 root      14   0     0    0     0 SW   99.9  0.0  56:36 kswapd
    5 root      14   0     0    0     0 RW   99.9  0.0  56:50 bdflush
    6 root      14   0     0    0     0 RW   99.9  0.0  54:44 kupdated
 1712 nobody    15   0   192  192    44 R    99.9  0.0   9:12 bonnie++
 1825 root      11   0  1064 1064   864 R     0.2  0.0   7:02 top


/proc/meminfo:
        total:    used:    free:  shared: buffers:  cached:
Mem:  3612286976 3609559040  2727936        0  3461120 3490426880
Swap:        0        0        0
MemTotal:      7721928 kB
MemFree:          2664 kB
MemShared:           0 kB
Buffers:          3380 kB
Cached:        7602924 kB
Active:          56604 kB
Inact_dirty:   3251412 kB
Inact_clean:   4298285 kB
Inact_target:    51752 kB
HighTotal:     6946808 kB
HighFree:         1048 kB
LowTotal:       775120 kB
LowFree:          1616 kB
SwapTotal:           0 kB
SwapFree:            0 kB


There are messages in the log about the kernel running out of
bounce-buffers. 

It seems related to swapping / pageing algorithms?

We've tried both 2.4.4ac6, 2.4.4ac9 and 2.4.5pre1 + Andreia's
highmem-patches. Possible the newer kernels work a little better, but
it's hard to tell because we don't have a way of actually messuring
this.

Any hints about what can be done to fix this?

This is not a production server - we're just running theese tests to see
how well linux will scale on this hardware - so, if you have any patches
you want us to try out please let us know. If you want to play around
with the machine, we can probably provide an account. Let us know.


Thanks

(please CC - I'm not subscribed to the list)



-- 
Ragnar Kjorstad
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
