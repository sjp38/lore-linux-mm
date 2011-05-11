Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 62521900001
	for <linux-mm@kvack.org>; Wed, 11 May 2011 18:30:25 -0400 (EDT)
Date: Wed, 11 May 2011 17:30:14 -0500
From: Russ Anderson <rja@sgi.com>
Subject: [bug] mm: hugepages can cause negative commitlimit
Message-ID: <20110511223013.GA8231@sgi.com>
Reply-To: Russ Anderson <rja@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Russ Anderson <rja@sgi.com>

If the total size of hugepages allocated on a system is
over half of the total memory size, commitlimit becomes
a negative number.

What happens in fs/proc/meminfo.c is this calculation:

        allowed = ((totalram_pages - hugetlb_total_pages())
                * sysctl_overcommit_ratio / 100) + total_swap_pages;

The problem is that hugetlb_total_pages() is larger than
totalram_pages resulting in a negative number.  Since
allowed is an unsigned long the negative shows up as a
big number.

A similar calculation occurs in __vm_enough_memory() in mm/mmap.c.

A symptom of this problem is that /proc/meminfo prints a
very large CommitLimit number.

CommitLimit:    737869762947802600 kB

To reproduce the problem reserve over half of memory as hugepages.
For example "default_hugepagesz=1G hugepagesz=1G hugepages=64
Then look at /proc/meminfo .

uv1-sys:~ # cat /proc/meminfo
MemTotal:       32395508 kB
MemFree:        32029276 kB
Buffers:            8656 kB
Cached:            89548 kB
SwapCached:            0 kB
Active:            55336 kB
Inactive:          73916 kB
Active(anon):      31220 kB
Inactive(anon):       36 kB
Active(file):      24116 kB
Inactive(file):    73880 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:              1692 kB
Writeback:             0 kB
AnonPages:         31132 kB
Mapped:            15668 kB
Shmem:               152 kB
Slab:              70256 kB
SReclaimable:      17148 kB
SUnreclaim:        53108 kB
KernelStack:        6536 kB
PageTables:         3704 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    737869762947802600 kB
Committed_AS:     394044 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      713960 kB
VmallocChunk:   34325764204 kB
HardwareCorrupted:     0 kB
HugePages_Total:      32
HugePages_Free:       32
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
DirectMap4k:       16384 kB
DirectMap2M:     2064384 kB
DirectMap1G:    65011712 kB


-- 
Russ Anderson, OS RAS/Partitioning Project Lead  
SGI - Silicon Graphics Inc          rja@sgi.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
