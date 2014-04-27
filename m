From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: On a 3.14.1 system dirty count goes negative
Date: Sun, 27 Apr 2014 13:06:51 +0200
Message-ID: <20140427130651.07839e7f@neptune.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

On a 3.14 system (KVM virtual machine 512MB RAM, x86_64) I'm seeing
/proc/meminfo/Dirty getting extreemly large (u64 going "nevative").

Note, this is not the first time I'm seeing it.

The system is not doing too much but has a rather small amount of
memory.

MemTotal:         508512 kB
MemFree:           23076 kB
MemAvailable:     282092 kB
Buffers:               0 kB
Cached:           194548 kB
SwapCached:         1500 kB
Active:           168060 kB
Inactive:         203080 kB
Active(anon):      82300 kB
Inactive(anon):    95992 kB
Active(file):      85760 kB
Inactive(file):   107088 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:        524284 kB
SwapFree:         515820 kB
Dirty:          18446744073709550284 kB
Writeback:             4 kB
AnonPages:        175600 kB
Mapped:            28784 kB
Shmem:              1700 kB
Slab:              92244 kB
SReclaimable:      76812 kB
SUnreclaim:        15432 kB
KernelStack:        1128 kB
PageTables:         5588 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      778540 kB
Committed_AS:    1036592 kB
VmallocTotal:   34359738367 kB
VmallocUsed:        4440 kB
VmallocChunk:   34359711231 kB
AnonHugePages:         0 kB
DirectMap4k:       10228 kB
DirectMap2M:      514048 kB

Some tasks end up being stuck in balance_dirty_pages_ratelimited()
because of this.

I have no idea what triggers Dirty to go mad but it happens.
It might be facilitated by some heavier IO (rsync of some data)
while rrdcached (rrdtool) is touching RRDs or writing its data log.
rrdcached is the one getting stuck in balance_dirty_pages_ratelimited().

Is there a way to get the system rolling again (making
dirty pages temporarily unlimited) or a way to determine why/when
Dirty goes negative and possibly get a hint on the trigger?

Thanks,
Bruno
