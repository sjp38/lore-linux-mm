Date: Wed, 3 Nov 2004 08:23:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Numa Node Swapping
In-Reply-To: <20041103132852.GC5203@linuxtx.org>
Message-ID: <Pine.LNX.4.58.0411030819050.17315@schroedinger.engr.sgi.com>
References: <20041103132852.GC5203@linuxtx.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Justin M. Forbes" <jmforbes@linuxtx.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Nov 2004, Justin M. Forbes wrote:

> I am interested in the numa node swapping patches you have been working
> with, and what test code you were running.  What size was the anonymous
> allocation you are doing in relationship to the amount of memory per node?

Here is the script that I ran:

----------------------------------------------------------------------------------
echo "Off Node memory allocation test"
echo "-------------------------------"
uname -a
echo "Initial state:"
echo "--------------"
cat /sys/devices/system/node/node{2,3}/{meminfo,numastat}
echo
time taskset 20 dd if=/mnt/1gb of=/dev/null
echo
echo "State after copying 1gb file"
echo "----------------------------"
cat /sys/devices/system/node/node{2,3}/{meminfo,numastat}
time taskset 20 ./fatmem
echo "State after running 500Mb memalloc program"
echo "------------------------------------------"
cat /sys/devices/system/node/node{2,3}/{meminfo,numastat}
------------------------------------------------------------------------------------

fatmem allocates large section of memory and touches every page.

The output of a test run with /proc/sys/vm/node_swap set to 3:

Off Node memory allocation test
-------------------------------
Linux margin 2.6.10-rc1-ptoss #3 SMP Thu Oct 28 10:18:36 PDT 2004 ia64 ia64 ia64 GNU/Linux
Initial state:
--------------

Node 2 MemTotal:       933888 kB
Node 2 MemFree:        899840 kB
Node 2 MemUsed:         34048 kB
Node 2 Active:           5376 kB
Node 2 Inactive:         3712 kB
Node 2 HighTotal:           0 kB
Node 2 HighFree:            0 kB
Node 2 LowTotal:       933888 kB
Node 2 LowFree:        899840 kB
Node 2 HugePages_Total:     0
Node 2 HugePages_Free:      0
numa_hit 108398
numa_miss 0
numa_foreign 0
interleave_hit 85023
local_node 43887
other_node 64511

Node 3 MemTotal:       915696 kB
Node 3 MemFree:        883072 kB
Node 3 MemUsed:         32624 kB
Node 3 Active:           5904 kB
Node 3 Inactive:         3200 kB
Node 3 HighTotal:           0 kB
Node 3 HighFree:            0 kB
Node 3 LowTotal:       915696 kB
Node 3 LowFree:        883072 kB
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
numa_hit 143416
numa_miss 0
numa_foreign 0
interleave_hit 125500
local_node 48305
other_node 95111


State after copying 1gb file
----------------------------

Node 2 MemTotal:       933888 kB
Node 2 MemFree:          2816 kB
Node 2 MemUsed:        931072 kB
Node 2 Active:           1744 kB
Node 2 Inactive:       903536 kB
Node 2 HighTotal:           0 kB
Node 2 HighFree:            0 kB
Node 2 LowTotal:       933888 kB
Node 2 LowFree:          2816 kB
Node 2 HugePages_Total:     0
Node 2 HugePages_Free:      0
numa_hit 170992
numa_miss 0
numa_foreign 0
interleave_hit 85024
local_node 106480
other_node 64512

Node 3 MemTotal:       915696 kB
Node 3 MemFree:        883072 kB
Node 3 MemUsed:         32624 kB
Node 3 Active:           5904 kB
Node 3 Inactive:         3200 kB
Node 3 HighTotal:           0 kB
Node 3 HighFree:            0 kB
Node 3 LowTotal:       915696 kB
Node 3 LowFree:        883072 kB
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
numa_hit 143434
numa_miss 0
numa_foreign 0
interleave_hit 125502
local_node 48321
other_node 95113
State after running 500Mb memalloc program
------------------------------------------

Node 2 MemTotal:       933888 kB
Node 2 MemFree:        488160 kB
Node 2 MemUsed:        445728 kB
Node 2 Active:           1824 kB
Node 2 Inactive:       418048 kB
Node 2 HighTotal:           0 kB
Node 2 HighFree:            0 kB
Node 2 LowTotal:       933888 kB
Node 2 LowFree:        488160 kB
Node 2 HugePages_Total:     0
Node 2 HugePages_Free:      0
numa_hit 201401
numa_miss 0
numa_foreign 2429
interleave_hit 85024
local_node 136889
other_node 64512

Node 3 MemTotal:       915696 kB
Node 3 MemFree:        883136 kB
Node 3 MemUsed:         32560 kB
Node 3 Active:           5872 kB
Node 3 Inactive:         3200 kB
Node 3 HighTotal:           0 kB
Node 3 HighFree:            0 kB
Node 3 LowTotal:       915696 kB
Node 3 LowFree:        883136 kB
Node 3 HugePages_Total:     0
Node 3 HugePages_Free:      0
numa_hit 143434
numa_miss 2429
numa_foreign 0
interleave_hit 125502
local_node 48321
other_node 97542
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
