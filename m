Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9761A6B0006
	for <linux-mm@kvack.org>; Fri, 25 May 2018 06:05:34 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id q71-v6so1586897pgq.17
        for <linux-mm@kvack.org>; Fri, 25 May 2018 03:05:34 -0700 (PDT)
Received: from huawei.com ([45.249.212.32])
        by mx.google.com with ESMTPS id w127-v6si23428351pfd.313.2018.05.25.03.05.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 May 2018 03:05:33 -0700 (PDT)
Message-ID: <5B07DFE3.2030804@huawei.com>
Date: Fri, 25 May 2018 18:05:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [RFC] mm: why active file + inactive file is larger than cached +
 buffers?
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel
 Gorman <mgorman@techsingularity.net>, Andrea Arcangeli <aarcange@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, zhong jiang <zhongjiang@huawei.com>, Yisheng Xie <xieyisheng1@huawei.com>, "Liyong (Q)" <liyong1@huawei.com>

Hi, I find the active file + inactive file is larger than cached + buffers, about 5G,
and can not free it by "echo 3 > /proc/sys/vm/drop_caches"

The meminfo shows that the mapped is also very small, so maybe some get the page? (e.g. get_user_pages())
Then it will dec the count of NR_FILE_PAGES when delete from page cache, but because of the count,
the page can not delete from lru, so left active file + inactive file so large, right?

MemTotal:       61528660 kB
MemFree:        48678936 kB
MemAvailable:   53657348 kB
Buffers:           10832 kB
Cached:           640340 kB
SwapCached:            0 kB
Active:          5933664 kB
Inactive:         588968 kB
Active(anon):    1022200 kB
Inactive(anon):   533248 kB
Active(file):    4911464 kB
Inactive(file):    55720 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:             0 kB
SwapFree:              0 kB
Dirty:             10952 kB
Writeback:             0 kB
AnonPages:        980572 kB
Mapped:            85464 kB
Shmem:            581580 kB
Slab:             343480 kB
SReclaimable:     264632 kB
SUnreclaim:        78848 kB
KernelStack:        8368 kB
PageTables:        18012 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:    28667176 kB
Committed_AS:    4144064 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      265848 kB
VmallocChunk:   34359417096 kB
HardwareCorrupted:     0 kB
AnonHugePages:    688128 kB
HugePages_Total:       4
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:    1048576 kB
DirectMap4k:      182112 kB
DirectMap2M:    11294720 kB
DirectMap1G:    51380224 kB
