Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CD9DE6B004F
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 16:44:30 -0400 (EDT)
Received: from d06nrmr1806.portsmouth.uk.ibm.com (d06nrmr1806.portsmouth.uk.ibm.com [9.149.39.193])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id n9CKiMCH018951
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 20:44:22 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1806.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9CKiMZd3362860
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 21:44:22 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n9CKiLJp023687
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 21:44:22 +0100
From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: oomkiller over-ambitious after "vmscan: make mapped executable pages the first class citizen" (bisected)
Date: Mon, 12 Oct 2009 22:44:19 +0200
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_jU50KlCxuM9+xpn"
Message-Id: <200910122244.19666.borntraeger@de.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

--Boundary-00=_jU50KlCxuM9+xpn
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit

I have seen some OOM-killer action on my s390x system when using large amounts 
of anonymous memory:

[cborntra@t63lp34 ~]$ cat memeat.c
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

int main()
{
        char *start;
        char *a;
        start = mmap(NULL, 4300000000UL,
                    PROT_READ | PROT_WRITE,
                    MAP_SHARED | MAP_ANONYMOUS, -1 , 0);
        if (start == MAP_FAILED) {
                printf("cannot map guest memory\n");
                exit (1);
        }
        for (a = start; a < start + 4300000000UL; a += 4096)
            *a='a';
        exit(0);
}
[cborntra@t63lp34 ~]$ ./memeat
Connection to t63lp34 closed.


I attached the dmesg with the oom messages.

As you can see we are failing several order 0 allocations with gfpmask=0x201da. 

The application uses slightly more memory than is available. The thing is, that 
there is plenty of swap space to fullfill the (non-atomic) request:

[cborntra@t63lp34 ~]$ free
             total       used       free     shared    buffers     cached
Mem:       4166560     127148    4039412          0       2256      19752
-/+ buffers/cache:     105140    4061420
Swap:      9615904       8328    9607576

Since old kernels never showed OOM, I was able to bisect the first kernel that 
shows this behaviour:
commit 8cab4754d24a0f2e05920170c845bd84472814c6                                                                                                                             
Author: Wu Fengguang <fengguang.wu@intel.com>                                                                                                                               
    vmscan: make mapped executable pages the first class citizen

In fact, applying this patch makes the problem go away:
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -1345,22 +1345,8 @@ static void shrink_active_list(unsigned 
 
 		/* page_referenced clears PageReferenced */
 		if (page_mapping_inuse(page) &&
-		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags)) {
+		    page_referenced(page, 0, sc->mem_cgroup, &vm_flags))
 			nr_rotated++;
-			/*
-			 * Identify referenced, file-backed active pages and
-			 * give them one more trip around the active list. So
-			 * that executable code get better chances to stay in
-			 * memory under moderate memory pressure.  Anon pages
-			 * are not likely to be evicted by use-once streaming
-			 * IO, plus JVM can create lots of anon VM_EXEC pages,
-			 * so we ignore them here.
-			 */
-			if ((vm_flags & VM_EXEC) && !PageAnon(page)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
-		}
 
 		ClearPageActive(page);	/* we are de-activating */
 		list_add(&page->lru, &l_inactive);



the interesting part is, that s390x in the default configuration has no no-
execute feature, resulting in the following map 
c0000000-1c04cd000 rwxs 00000000 00:04 18517        /dev/zero (deleted)
As you can see, this area looks file mapped (/dev/zero) and executable. On the 
other hand, the !PageAnon clause should cover this case. I am lost.

Does anybody on the CC (taken from the original patch) has an idea what the 
problem is and how to fix this properly?

Christian

--Boundary-00=_jU50KlCxuM9+xpn
Content-Type: text/plain;
  charset="UTF-8";
  name="dmesg.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="dmesg.txt"

Linux version 2.6.32-rc3-selfgit-00000-rc3 (cborntra@t63lp34) (gcc version 4.3.3 20090123 (prerelease) (GCC) ) #208 SMP Mon Oct 12 21:27:22 CEST 2009
setup: Linux is running natively in 64-bit mode
setup: Address spaces switched, mvcos available
Zone PFN ranges:
  DMA      0x00000000 -> 0x00080000
  Normal   0x00080000 -> 0x00104000
Movable zone start PFN for each node
early_node_map[1] active PFN ranges
    0: 0x00000000 -> 0x00104000
On node 0 totalpages: 1064960
  DMA zone: 7168 pages used for memmap
  DMA zone: 0 pages reserved
  DMA zone: 517120 pages, LIFO batch:31
  Normal zone: 7392 pages used for memmap
  Normal zone: 533280 pages, LIFO batch:31
PERCPU: Embedded 12 pages/cpu @000000008442a000 s16896 r8192 d24064 u65536
pcpu-alloc: s16896 r8192 d24064 u65536 alloc=16*4096
pcpu-alloc: [0] 00 [0] 01 [0] 02 [0] 03 [0] 04 [0] 05 [0] 06 [0] 07 
pcpu-alloc: [0] 08 [0] 09 [0] 10 [0] 11 [0] 12 [0] 13 [0] 14 [0] 15 
pcpu-alloc: [0] 16 [0] 17 [0] 18 [0] 19 [0] 20 [0] 21 [0] 22 [0] 23 
pcpu-alloc: [0] 24 [0] 25 [0] 26 [0] 27 [0] 28 [0] 29 [0] 30 [0] 31 
pcpu-alloc: [0] 32 [0] 33 [0] 34 [0] 35 [0] 36 [0] 37 [0] 38 [0] 39 
pcpu-alloc: [0] 40 [0] 41 [0] 42 [0] 43 [0] 44 [0] 45 [0] 46 [0] 47 
pcpu-alloc: [0] 48 [0] 49 [0] 50 [0] 51 [0] 52 [0] 53 [0] 54 [0] 55 
pcpu-alloc: [0] 56 [0] 57 [0] 58 [0] 59 [0] 60 [0] 61 [0] 62 [0] 63 
Built 1 zonelists in Zone order, mobility grouping on.  Total pages: 1050400
Kernel command line: dasd=4b6c-4b6f,4f17,4f18,4fc2-4fc5    root=/dev/dasda1 ro noinitrd selinux=0 audit=0 audit_enable=0 switch_amode cio_ignore=all,!4b6c-4b6f,!4f17-4f18,!4fc2-4fc5,!f500-f502  BOOT_IMAGE=0
audit: disabled (until reboot)
PID hash table entries: 4096 (order: 3, 32768 bytes)
Dentry cache hash table entries: 1048576 (order: 11, 8388608 bytes)
Inode-cache hash table entries: 524288 (order: 10, 4194304 bytes)
Memory: 4165096k/4259840k available (5220k kernel code, 0k reserved, 3320k data, 260k init)
Write protected kernel read-only data: 0x100000 - 0x7fffff
Hierarchical RCU implementation.
Switched to high resolution mode on CPU 0
console [ttyS0] enabled
Calibrating delay loop (skipped)... 6868.00 BogoMIPS preset
Security Framework initialized
SELinux:  Disabled at boot.
Mount-cache hash table entries: 256
cpu: 8 configured CPUs, 0 standby CPUs
cpu: Processor 0 started, address 0, identification 24D09E
cpu: Processor 1 started, address 0, identification 24D09E
cpu: Processor 2 started, address 0, identification 24D09E
cpu: Processor 3 started, address 0, identification 24D09E
cpu: Processor 4 started, address 0, identification 24D09E
cpu: Processor 5 started, address 0, identification 24D09E
cpu: Processor 6 started, address 0, identification 24D09E
Switched to high resolution mode on CPU 4
Switched to high resolution mode on CPU 1
Switched to high resolution mode on CPU 2
Switched to high resolution mode on CPU 6
Switched to high resolution mode on CPU 5
Switched to high resolution mode on CPU 3
cpu: Processor 7 started, address 0, identification 24D09E
Brought up 8 CPUs
NET: Registered protocol family 16
bio: create slab <bio-0> at 0
Switched to high resolution mode on CPU 7
SCSI subsystem initialized
Switching to clocksource tod
NET: Registered protocol family 2
IP route cache hash table entries: 131072 (order: 8, 1048576 bytes)
TCP established hash table entries: 65536 (order: 8, 1048576 bytes)
TCP bind hash table entries: 65536 (order: 8, 1048576 bytes)
TCP: Hash tables configured (established 65536 bind 65536)
TCP reno registered
NET: Registered protocol family 1
HugeTLB registered 1 MB page size, pre-allocated 0 pages
VFS: Disk quotas dquot_6.5.2
Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
msgmni has been set to 8137
alg: No test for stdrng (krng)
Block layer SCSI generic (bsg) driver version 0.4 loaded (major 254)
io scheduler noop registered
io scheduler anticipatory registered
io scheduler deadline registered (default)
io scheduler cfq registered
hvc_iucv: The z/VM IUCV HVC device driver cannot be used without z/VM
cio: Channel measurement facility initialized using format extended (mode autodetected)
Discipline DIAG cannot be used without z/VM
dasd-eckd 0.0.4b6c: New DASD 3390/0C (CU 3990/01) with 6678 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4b6d: New DASD 3390/0C (CU 3990/01) with 6678 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4b6e: New DASD 3390/0C (CU 3990/01) with 6678 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4b6f: New DASD 3390/0C (CU 3990/01) with 6678 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4fc5: New DASD 3390/0A (CU 3990/01) with 3339 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4fc2: New DASD 3390/0A (CU 3990/01) with 3339 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4f18: New DASD 3390/0C (CU 3990/01) with 32760 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4fc3: New DASD 3390/0A (CU 3990/01) with 3339 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4f17: New DASD 3390/0C (CU 3990/01) with 32760 cylinders, 15 heads, 224 sectors
dasd-eckd 0.0.4fc2: DASD with 4 KB/block, 2404080 KB total size, 48 KB/track, compatible disk layout
 dasdg:VOL1/  CBORN5:
dasd-eckd 0.0.4fc4: New DASD 3390/0A (CU 3990/01) with 3339 cylinders, 15 heads, 224 sectors
 dasdg1
dasd-eckd 0.0.4f18: DASD with 4 KB/block, 23587200 KB total size, 48 KB/track, compatible disk layout
 dasdf:VOL1/  CBORN4: dasdf1
dasd-eckd 0.0.4b6c: DASD with 4 KB/block, 4808160 KB total size, 48 KB/track, compatible disk layout
 dasda:VOL1/  CBORN0: dasda1
dasd-eckd 0.0.4b6d: DASD with 4 KB/block, 4808160 KB total size, 48 KB/track, compatible disk layout
 dasdb:VOL1/  CBORN1: dasdb1
dasd-eckd 0.0.4b6e: DASD with 4 KB/block, 4808160 KB total size, 48 KB/track, compatible disk layout
 dasdc:VOL1/  CBORN2: dasdc1
dasd-eckd 0.0.4b6f: DASD with 4 KB/block, 4808160 KB total size, 48 KB/track, compatible disk layout
 dasdd:VOL1/  CBORN3: dasdd1
dasd-eckd 0.0.4fc5: DASD with 4 KB/block, 2404080 KB total size, 48 KB/track, compatible disk layout
 dasdj:VOL1/  0X4FC5: dasdj1
dasd-eckd 0.0.4fc3: DASD with 4 KB/block, 2404080 KB total size, 48 KB/track, compatible disk layout
 dasdh:VOL1/  CBORN6: dasdh1
dasd-eckd 0.0.4f17: DASD with 4 KB/block, 23587200 KB total size, 48 KB/track, compatible disk layout
 dasde:VOL1/  CBORN8: dasde1
dasd-eckd 0.0.4fc4: DASD with 4 KB/block, 2404080 KB total size, 48 KB/track, compatible disk layout
 dasdi:VOL1/  CBORN7: dasdi1
TCP cubic registered
NET: Registered protocol family 17
registered taskstats version 1
md: Waiting for all devices to be available before autodetect
md: If you don't use raid, use raid=noautodetect
md: Autodetecting RAID arrays.
md: Scanned 0 and added 0 devices.
md: autorun ...
md: ... autorun DONE.
EXT3-fs: dasda1: couldn't mount because of unsupported optional features (240).
EXT2-fs: dasda1: couldn't mount because of unsupported optional features (240).
EXT4-fs (dasda1): mounted filesystem with ordered data mode
VFS: Mounted root (ext4 filesystem) readonly on device 94:1.
Freeing unused kernel memory: 260k freed
qeth: loading core functions
device-mapper: uevent: version 1.0.3
device-mapper: ioctl: 4.15.0-ioctl (2009-04-01) initialised: dm-devel@redhat.com
EXT4-fs (dasda1): warning: maximal mount count reached, running e2fsck is recommended
EXT4-fs (dm-50): mounted filesystem with ordered data mode
EXT4-fs (dm-51): mounted filesystem with ordered data mode
EXT4-fs (dm-52): mounted filesystem with ordered data mode
EXT4-fs (dm-0): mounted filesystem with ordered data mode
hypfs: Hypervisor filesystem mounted
Adding 2403976k swap on /dev/dasdg1.  Priority:1 extents:1 across:2403976k 
Adding 2403976k swap on /dev/dasdh1.  Priority:1 extents:1 across:2403976k 
Adding 2403976k swap on /dev/dasdi1.  Priority:1 extents:1 across:2403976k 
Adding 2403976k swap on /dev/dasdj1.  Priority:1 extents:1 across:2403976k 
qeth: register layer 2 discipline
qdio: 0.0.f502 OSA on SC 247c using AI:1 QEBSM:0 PCI:1 TDD:1 SIGA: W AOP
qeth 0.0.f500: MAC address 02:00:00:af:1b:19 successfully registered on device eth0
qeth 0.0.f500: Device is a OSD Express card (level: 0892)
with link type OSD_1000 (portname: OSAPORT)
NET: Registered protocol family 10
lo: Disabled Privacy Extensions
qeth 0.0.f500: MAC address 02:63:34:00:76:01 successfully registered on device eth0
RPC: Registered udp transport module.
RPC: Registered tcp transport module.
RPC: Registered tcp NFSv4.1 backchannel transport module.
warning: `dbus-daemon' uses deprecated v2 capabilities in a way that may be insecure.
device-mapper: multipath: version 1.1.0 loaded
Bridge firewalling registered
tun: Universal TUN/TAP device driver, 1.6
tun: (C) 1999-2004 Max Krasnyansky <maxk@qualcomm.com>
device tap1 entered promiscuous mode
device tap2 entered promiscuous mode
device tap3 entered promiscuous mode
device tap4 entered promiscuous mode
device tap5 entered promiscuous mode
device tap6 entered promiscuous mode
device tap7 entered promiscuous mode
device tap8 entered promiscuous mode
device tap9 entered promiscuous mode
device tap10 entered promiscuous mode
device tap11 entered promiscuous mode
device tap12 entered promiscuous mode
virt0: port 12(tap12) entering learning state
virt0: port 11(tap11) entering learning state
virt0: port 10(tap10) entering learning state
virt0: port 9(tap9) entering learning state
virt0: port 8(tap8) entering learning state
virt0: port 7(tap7) entering learning state
virt0: port 6(tap6) entering learning state
virt0: port 5(tap5) entering learning state
virt0: port 4(tap4) entering learning state
virt0: port 3(tap3) entering learning state
virt0: port 2(tap2) entering learning state
virt0: port 1(tap1) entering learning state
device tap13 entered promiscuous mode
virt0: port 13(tap13) entering learning state
device tap14 entered promiscuous mode
virt0: port 14(tap14) entering learning state
device tap15 entered promiscuous mode
virt0: port 15(tap15) entering learning state
device tap16 entered promiscuous mode
virt0: port 16(tap16) entering learning state
device tap17 entered promiscuous mode
virt0: port 17(tap17) entering learning state
device tap18 entered promiscuous mode
virt0: port 18(tap18) entering learning state
device tap19 entered promiscuous mode
virt0: port 19(tap19) entering learning state
device tap20 entered promiscuous mode
virt0: port 20(tap20) entering learning state
device tap21 entered promiscuous mode
virt0: port 21(tap21) entering learning state
device tap22 entered promiscuous mode
virt0: port 22(tap22) entering learning state
device tap23 entered promiscuous mode
virt0: port 23(tap23) entering learning state
device tap24 entered promiscuous mode
virt0: port 24(tap24) entering learning state
device tap25 entered promiscuous mode
virt0: port 25(tap25) entering learning state
device tap26 entered promiscuous mode
virt0: port 26(tap26) entering learning state
device tap27 entered promiscuous mode
virt0: port 27(tap27) entering learning state
device tap28 entered promiscuous mode
virt0: port 28(tap28) entering learning state
device tap29 entered promiscuous mode
virt0: port 29(tap29) entering learning state
eth0: no IPv6 routers present
tap6: no IPv6 routers present
tap13: no IPv6 routers present
tap11: no IPv6 routers present
tap29: no IPv6 routers present
tap1: no IPv6 routers present
tap16: no IPv6 routers present
tap26: no IPv6 routers present
tap2: no IPv6 routers present
tap23: no IPv6 routers present
tap12: no IPv6 routers present
tap18: no IPv6 routers present
tap4: no IPv6 routers present
tap19: no IPv6 routers present
tap24: no IPv6 routers present
virt0: no IPv6 routers present
tap3: no IPv6 routers present
tap22: no IPv6 routers present
tap15: no IPv6 routers present
tap9: no IPv6 routers present
tap5: no IPv6 routers present
tap25: no IPv6 routers present
tap27: no IPv6 routers present
tap8: no IPv6 routers present
tap7: no IPv6 routers present
tap10: no IPv6 routers present
tap20: no IPv6 routers present
tap21: no IPv6 routers present
tap14: no IPv6 routers present
tap17: no IPv6 routers present
tap28: no IPv6 routers present
virt0: port 12(tap12) entering forwarding state
virt0: port 11(tap11) entering forwarding state
virt0: port 10(tap10) entering forwarding state
virt0: port 9(tap9) entering forwarding state
virt0: port 8(tap8) entering forwarding state
virt0: port 7(tap7) entering forwarding state
virt0: port 6(tap6) entering forwarding state
virt0: port 5(tap5) entering forwarding state
virt0: port 4(tap4) entering forwarding state
virt0: port 3(tap3) entering forwarding state
virt0: port 2(tap2) entering forwarding state
virt0: port 1(tap1) entering forwarding state
virt0: port 13(tap13) entering forwarding state
virt0: port 14(tap14) entering forwarding state
virt0: port 15(tap15) entering forwarding state
virt0: port 16(tap16) entering forwarding state
virt0: port 17(tap17) entering forwarding state
virt0: port 18(tap18) entering forwarding state
virt0: port 19(tap19) entering forwarding state
virt0: port 20(tap20) entering forwarding state
virt0: port 21(tap21) entering forwarding state
virt0: port 22(tap22) entering forwarding state
virt0: port 23(tap23) entering forwarding state
virt0: port 24(tap24) entering forwarding state
virt0: port 25(tap25) entering forwarding state
virt0: port 26(tap26) entering forwarding state
virt0: port 27(tap27) entering forwarding state
virt0: port 28(tap28) entering forwarding state
virt0: port 29(tap29) entering forwarding state
memeat invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
CPU: 7 Not tainted 2.6.32-rc3-selfgit-00000-rc3 #208
Process memeat (pid: 2066, task: 00000000fd16b040, ksp: 00000000fc5e77f8)
0000000000000000 00000000fc5e7988 0000000000000002 0000000000000000 
       00000000fc5e7a28 00000000fc5e79a0 00000000fc5e79a0 0000000000511bca 
       0000000000000000 0000000000000000 000000000084f300 0000000000000000 
       000000000000000d 0000000000000000 00000000fc5e79f0 000000000000000e 
       0000000000528888 00000000001057fa 00000000fc5e7988 00000000fc5e79d0 
Call Trace:
([<000000000010570a>] show_trace+0xe6/0x134)
 [<00000000001c375c>] oom_kill_process+0xd0/0x2ac
 [<00000000001c3f96>] __out_of_memory+0x132/0x1bc
 [<00000000001c40b4>] out_of_memory+0x94/0x118
 [<00000000001c8d6c>] __alloc_pages_nodemask+0x67c/0x690
 [<00000000001d23fe>] shmem_getpage+0x1ee/0xa78
 [<00000000001d2cfe>] shmem_fault+0x76/0xa8
 [<00000000001dfc32>] __do_fault+0x76/0x5a8
 [<00000000001e3d80>] handle_mm_fault+0x4dc/0x958
 [<000000000051571a>] do_dat_exception+0x2ca/0x3b8
 [<0000000000118804>] sysc_return+0x0/0x8
 [<000000008000068c>] 0x8000068c
Mem-Info:
DMA per-cpu:
CPU    0: hi:  186, btch:  31 usd: 141
CPU    1: hi:  186, btch:  31 usd:  15
CPU    2: hi:  186, btch:  31 usd:  26
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:  13
CPU    5: hi:  186, btch:  31 usd:  65
CPU    6: hi:  186, btch:  31 usd:  47
CPU    7: hi:  186, btch:  31 usd:   2
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 157
CPU    1: hi:  186, btch:  31 usd:  59
CPU    2: hi:  186, btch:  31 usd: 181
CPU    3: hi:  186, btch:  31 usd: 155
CPU    4: hi:  186, btch:  31 usd: 192
CPU    5: hi:  186, btch:  31 usd: 176
CPU    6: hi:  186, btch:  31 usd: 178
CPU    7: hi:  186, btch:  31 usd: 185
active_anon:1004426 inactive_anon:0 isolated_anon:0
 active_file:101 inactive_file:52 isolated_file:0
 unevictable:986 dirty:0 writeback:0 unstable:0 buffer:67
 free:4075 slab_reclaimable:4155 slab_unreclaimable:6913
 mapped:1002757 shmem:1001906 pagetables:4171 bounce:0
DMA free:12232kB min:4032kB low:5040kB high:6048kB active_anon:2057908kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2068480kB mlocked:0kB dirty:0kB writeback:0kB mapped:2057916kB shmem:2057908kB slab_reclaimable:4668kB slab_unreclaimable:324kB kernel_stack:0kB pagetables:8036kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:47584 all_unreclaimable? no
lowmem_reserve[]: 0 2083 2083
Normal free:4068kB min:4160kB low:5200kB high:6240kB active_anon:1959796kB inactive_anon:0kB active_file:404kB inactive_file:208kB unevictable:3944kB isolated(anon):0kB isolated(file):0kB present:2133120kB mlocked:3944kB dirty:0kB writeback:0kB mapped:1953112kB shmem:1949716kB slab_reclaimable:11952kB slab_unreclaimable:27328kB kernel_stack:2416kB pagetables:8648kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2516 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 2*8kB 3*16kB 0*32kB 2*64kB 2*128kB 2*256kB 0*512kB 11*1024kB = 12232kB
Normal: 376*4kB 4*8kB 12*16kB 11*32kB 1*64kB 0*128kB 0*256kB 0*512kB 2*1024kB = 4192kB
1005208 total pagecache pages
2552 pages in swap cache
Swap cache stats: add 2552, delete 0, find 0/0
Free swap  = 9605696kB
Total swap = 9615904kB
1064960 pages RAM
23318 pages reserved
1005668 pages shared
30764 pages non-shared
Out of memory: kill process 2066 (memeat) score 1050267 or a child
Killed process 2066 (memeat)
rsyslogd invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0
CPU: 0 Not tainted 2.6.32-rc3-selfgit-00000-rc3 #208
Process rsyslogd (pid: 1247, task: 00000001032ed040, ksp: 00000001032a7790)
0000000000000000 00000001032a7920 0000000000000002 0000000000000000 
       00000001032a79c0 00000001032a7938 00000001032a7938 0000000000511bca 
       0000000000000000 0000000000000000 000000000084f300 0000000000000000 
       000000000000000d 0000000000000000 00000001032a7988 000000000000000e 
       0000000000528888 00000000001057fa 00000001032a7920 00000001032a7968 
Call Trace:
([<000000000010570a>] show_trace+0xe6/0x134)
 [<00000000001c375c>] oom_kill_process+0xd0/0x2ac
 [<00000000001c3f96>] __out_of_memory+0x132/0x1bc
 [<00000000001c40b4>] out_of_memory+0x94/0x118
 [<00000000001c8d6c>] __alloc_pages_nodemask+0x67c/0x690
 [<00000000001cb21e>] __do_page_cache_readahead+0x10a/0x2ac
 [<00000000001cb400>] ra_submit+0x40/0x54
 [<00000000001c1524>] filemap_fault+0x41c/0x428
 [<00000000001dfc32>] __do_fault+0x76/0x5a8
 [<00000000001e3d80>] handle_mm_fault+0x4dc/0x958
 [<000000000051571a>] do_dat_exception+0x2ca/0x3b8
 [<0000000000118804>] sysc_return+0x0/0x8
 [<0000020000015a3e>] 0x20000015a3e
Mem-Info:
DMA per-cpu:
CPU    0: hi:  186, btch:  31 usd: 141
CPU    1: hi:  186, btch:  31 usd:  15
CPU    2: hi:  186, btch:  31 usd:  26
CPU    3: hi:  186, btch:  31 usd:   0
CPU    4: hi:  186, btch:  31 usd:  13
CPU    5: hi:  186, btch:  31 usd:  65
CPU    6: hi:  186, btch:  31 usd:  47
CPU    7: hi:  186, btch:  31 usd:   2
Normal per-cpu:
CPU    0: hi:  186, btch:  31 usd: 157
CPU    1: hi:  186, btch:  31 usd:  59
CPU    2: hi:  186, btch:  31 usd: 182
CPU    3: hi:  186, btch:  31 usd: 155
CPU    4: hi:  186, btch:  31 usd: 192
CPU    5: hi:  186, btch:  31 usd: 176
CPU    6: hi:  186, btch:  31 usd: 178
CPU    7: hi:  186, btch:  31 usd: 166
active_anon:1004426 inactive_anon:0 isolated_anon:0
 active_file:101 inactive_file:52 isolated_file:0
 unevictable:986 dirty:0 writeback:0 unstable:0 buffer:67
 free:4075 slab_reclaimable:4155 slab_unreclaimable:6913
 mapped:975163 shmem:1001906 pagetables:4171 bounce:0
DMA free:12232kB min:4032kB low:5040kB high:6048kB active_anon:2057908kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:2068480kB mlocked:0kB dirty:0kB writeback:0kB mapped:2057916kB shmem:2057908kB slab_reclaimable:4668kB slab_unreclaimable:324kB kernel_stack:0kB pagetables:8036kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:48416 all_unreclaimable? no
lowmem_reserve[]: 0 2083 2083
Normal free:4068kB min:4160kB low:5200kB high:6240kB active_anon:1959796kB inactive_anon:0kB active_file:404kB inactive_file:208kB unevictable:3944kB isolated(anon):0kB isolated(file):0kB present:2133120kB mlocked:3944kB dirty:0kB writeback:0kB mapped:1842736kB shmem:1949716kB slab_reclaimable:11952kB slab_unreclaimable:27328kB kernel_stack:2416kB pagetables:8648kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:288 all_unreclaimable? no
lowmem_reserve[]: 0 0 0
DMA: 2*4kB 2*8kB 3*16kB 0*32kB 2*64kB 2*128kB 2*256kB 0*512kB 11*1024kB = 12232kB
Normal: 385*4kB 13*8kB 13*16kB 11*32kB 1*64kB 0*128kB 0*256kB 0*512kB 2*1024kB = 4316kB
1005208 total pagecache pages
2536 pages in swap cache
Swap cache stats: add 2552, delete 16, find 4/4
Free swap  = 9605760kB
Total swap = 9615904kB
1064960 pages RAM
23318 pages reserved
895711 pages shared
140642 pages non-shared
Out of memory: kill process 1998 (sshd) score 3771 or a child
Killed process 2003 (bash)

--Boundary-00=_jU50KlCxuM9+xpn--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
