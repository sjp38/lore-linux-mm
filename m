Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id B0DCF6B0085
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 18:06:18 -0500 (EST)
Received: by mail-wi0-f175.google.com with SMTP id l15so4305617wiw.2
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 15:06:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id fj7si24981543wib.1.2015.01.05.15.06.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 15:06:18 -0800 (PST)
Date: Mon, 5 Jan 2015 18:05:59 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Dirty pages underflow on 3.14.23
Message-ID: <alpine.LRH.2.02.1501051744020.5119@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Leon Romanovsky <leon@leon.nu>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi

I would like to report a memory management bug where the dirty pages count 
underflowed.

It happened after some time that the Dirty pages count underflowed, as can 
be seen in /proc/meminfo. The underflow condition was persistent, 
/proc/meminfo was showing the big value even when the system was 
completely idle. The counter never returned to zero.

The system didn't crash, but it became very slow - because of the big 
value in the "Dirty" field, lazy writing was not working anymore, any 
process that created a dirty page triggered immediate writeback, which 
slowed down the system very much. The only fix was to reboot the machine.

The kernel version where this happened is 3.14.23. The kernel is compiled 
without SMP and with peemption. The system is single-core 32-bit x86.

The bug probably happened during git pull or apt-get update, though one 
can't be sure that these commands caused it.

I see that 3.14.24 containes some fix for underflow (commit 
6619741f17f541113a02c30f22a9ca22e32c9546, upstream commit 
abe5f972912d086c080be4bde67750630b6fb38b), but it doesn't seem that that 
commit fixes this condition. If you have a commit that could fix this, say 
it.

Mikulas


MemTotal:         253504 kB
MemFree:            6128 kB
MemAvailable:      54956 kB
Buffers:            1376 kB
Cached:            45284 kB
SwapCached:        40432 kB
Active:           105596 kB
Inactive:         111672 kB
Active(anon):      82772 kB
Inactive(anon):    88604 kB
Active(file):      22824 kB
Inactive(file):    23068 kB
Unevictable:           4 kB
Mlocked:               4 kB
SwapTotal:       4242896 kB
SwapFree:        4144248 kB
Dirty:          4294944344 kB
Writeback:             8 kB
AnonPages:        167484 kB
Mapped:             7808 kB
Shmem:               768 kB
Slab:              19072 kB
SReclaimable:      10448 kB
SUnreclaim:         8624 kB
KernelStack:        1136 kB
PageTables:         2032 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     4369648 kB
Committed_AS:     398032 kB
VmallocTotal:     778184 kB
VmallocUsed:       38316 kB
VmallocChunk:     707540 kB
AnonHugePages:         0 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       4096 kB
DirectMap4k:       20416 kB
DirectMap4M:      241664 kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
