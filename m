Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6239F6B002D
	for <linux-mm@kvack.org>; Sun, 30 Oct 2011 07:05:00 -0400 (EDT)
Date: Sun, 30 Oct 2011 11:04:56 +0000
From: Richard Davies <richard.davies@elastichosts.com>
Subject: Understanding memory (over?)use
Message-ID: <20111030110456.GA5026@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi all,

I'd appreciate your help understanding some machines we have which are using
a lot of kernel(?) memory which we can't account for.

As you can see below, this machine has about 1.5GB more memory use in "free"
than the sum of process memory (18,138,572 kB vs 16,558,608 kB).

We can't find this in kernel (e.g. Slab + PageTables in cat /proc/meminfo is
much smaller).

Please can someone tell us where to look?

Ideally, I'd like to understand a "bottom-up" processes + kernel sum which
comes to the same answer as the "top-up" number from "free".

Thanks,

Richard.


Here's the data for a machine with a 2.6.39.2 kernel and KSM enabled, running
several qemu-kvm VMs and little else:

# swapoff -a

# echo 3 > /proc/sys/vm/drop_caches

# free -k -t
             total       used       free     shared    buffers     cached
Mem:      33015884   18138572   14877312          0       8944       6068
-/+ buffers/cache:   18123560   14892324
Swap:            0          0          0
Total:    33015884   18138572   14877312

# ps auxf | awk 'BEGIN {a = 0} /[0-9]/ {a = a + $5} END { print a }'
16558608

# cat /proc/meminfo
MemTotal:       33015884 kB
MemFree:        14870240 kB
Buffers:           13208 kB
Cached:             7036 kB
SwapCached:            0 kB
Active:         15215524 kB
Inactive:        2001364 kB
Active(anon):   15206612 kB
Inactive(anon):  1986976 kB
Active(file):       8912 kB
Inactive(file):    14388 kB
Unevictable:       10112 kB
Mlocked:           10112 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:              5816 kB
Writeback:             0 kB
AnonPages:      13233548 kB
Mapped:             6416 kB
Shmem:               168 kB
Slab:             594360 kB
SReclaimable:       7852 kB
SUnreclaim:       586508 kB
KernelStack:        2696 kB
PageTables:        32140 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    16507940 kB
Committed_AS:   15540924 kB
VmallocTotal:   34359738367 kB
VmallocUsed:       99100 kB
VmallocChunk:   34359418288 kB
HardwareCorrupted:     0 kB
AnonHugePages:     65536 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:        5440 kB
DirectMap2M:    33548288 kB

# for i in /sys/kernel/mm/ksm/* ; do echo -n "$i: " ; cat $i ; done
/sys/kernel/mm/ksm/full_scans: 4240
/sys/kernel/mm/ksm/pages_shared: 273541
/sys/kernel/mm/ksm/pages_sharing: 444652
/sys/kernel/mm/ksm/pages_to_scan: 100
/sys/kernel/mm/ksm/pages_unshared: 2651880
/sys/kernel/mm/ksm/pages_volatile: 282107
/sys/kernel/mm/ksm/run: 1
/sys/kernel/mm/ksm/sleep_millisecs: 20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
