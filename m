Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f51.google.com (mail-la0-f51.google.com [209.85.215.51])
	by kanga.kvack.org (Postfix) with ESMTP id 47F886B0069
	for <linux-mm@kvack.org>; Sun,  5 Oct 2014 07:20:36 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id ge10so2990132lab.24
        for <linux-mm@kvack.org>; Sun, 05 Oct 2014 04:20:35 -0700 (PDT)
Received: from hygieia.santi-shop.eu (hygieia.santi-shop.eu. [78.46.175.2])
        by mx.google.com with ESMTPS id m4si19150314lbd.106.2014.10.05.04.20.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Oct 2014 04:20:32 -0700 (PDT)
Date: Sun, 5 Oct 2014 13:20:28 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: x86_64 3.x kernels with SMP=n and up with incorrect dirty memory
 accounting
Message-ID: <20141005132028.7c0fab9a@neptune.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since about any 3.x kernel release (I don't know since what release
exactly) more or less randomly system starts to starve more or less
because of dirty memory.

When it happens I get /proc/meminfo looking as follows:
MemTotal:         508392 kB
MemFree:           24120 kB
MemAvailable:     322184 kB
Buffers:               0 kB
Cached:           229884 kB
SwapCached:         2380 kB
Active:           178616 kB
Inactive:         160760 kB
Active(anon):      51172 kB
Inactive(anon):    68860 kB
Active(file):     127444 kB
Inactive(file):    91900 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:        524284 kB
SwapFree:         502372 kB
Dirty:          18446744073709551408 kB
Writeback:             0 kB
AnonPages:        107816 kB
Mapped:            37096 kB
Shmem:             10540 kB
Slab:             105604 kB
SReclaimable:      89340 kB
SUnreclaim:        16264 kB
KernelStack:        2128 kB
PageTables:         4212 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      778480 kB
Committed_AS:     875200 kB
VmallocTotal:   34359738367 kB
VmallocUsed:        4452 kB
VmallocChunk:   34359704615 kB
AnonHugePages:         0 kB
DirectMap4k:       10228 kB
DirectMap2M:      514048 kB

As seen above Dirty is very large (looks like small negative
value interpreted as unsigned - too large compare to available
memory!).

System is running under kvm/qemu with a single CPU and 512MB of
RAM while making use of memory cgroup.

The userspace process triggering it and being mostly affected is
rrdcached (from rrdtool) as it's the one dirtying memory at regular
intervals and in reasonable amounts - it may very well be affected
by memory pressure in its cgroup (at least all the RRDs don't fit
in its soft/hard cgroup memory limit).

Probably most critical parts of the config are CONFIG_SMP=n in combination
with pretty tight memory availability.

As soon as it hits, wchan for rrdcached looks like this:
 grep . /proc/10045/task/*/wchan
 /proc/10045/task/10045/wchan:poll_schedule_timeout
 /proc/10045/task/10047/wchan:balance_dirty_pages_ratelimited
 /proc/10045/task/10048/wchan:balance_dirty_pages_ratelimited
 /proc/10045/task/10049/wchan:balance_dirty_pages_ratelimited
 /proc/10045/task/10050/wchan:balance_dirty_pages_ratelimited
 /proc/10045/task/10051/wchan:futex_wait_queue_me
 /proc/10045/task/10052/wchan:poll_schedule_timeout

I can kill rrdcached (but must use -KILL for it not to take an
eternity) to stop system thinking to be in permanent IO-wait
but when retarting rrdcached I pretty quickly get back into
original state. Only way I know to get out of this is to reboot.


How is dirty memory accounting happening, would it be possible for
the accounting to complain if dirty memory goes "negative" and
in such case reset accounting to 0 (or pause everything the time
needed to recalculate correct accounting value)?

Of all the systems I'm monitoring these x86_64 systems are the only
ones I've seen this issue on, though they are probably the only ones
running under such tight memory constraints.

Bruno

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
