Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3218B8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 12:05:14 -0400 (EDT)
Date: Mon, 25 Apr 2011 18:04:50 +0200
From: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning,
 regression?
Message-ID: <20110425180450.1ede0845@neptune.home>
In-Reply-To: <BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
References: <20110424202158.45578f31@neptune.home>
	<20110424235928.71af51e0@neptune.home>
	<20110425114429.266A.A69D9226@jp.fujitsu.com>
	<BANLkTinVQtLbmBknBZeY=7w7AOyQk61Pew@mail.gmail.com>
	<20110425111705.786ef0c5@neptune.home>
	<BANLkTi=d0UHrYXyTK0CBZYCSK-ax8+wuWQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/+ZFWHyVo1h54d_R45Q9G9iQ"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mike Frysinger <vapier.adi@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Paul E. McKenney" <paul.mckenney@linaro.org>, Pekka Enberg <penberg@kernel.org>

--MP_/+ZFWHyVo1h54d_R45Q9G9iQ
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Mon, 25 April 2011 Linus Torvalds wrote:
> On Mon, Apr 25, 2011 at 2:17 AM, Bruno Pr=C3=A9mont wrote:
> >
> > Here it seems to happened when I run 2 intensive tasks in parallel, e.g.
> > (re)emerging gimp and running revdep-rebuild -pi in another terminal.
> > This produces a fork rate of about 100-300 per second.
> >
> > Suddenly kmalloc-128 slabs stop being freed and things degrade.
>=20
> So everything seems to imply some kind of filesystem/vfs thing, but
> let's try to gather a bit more information about exactly what it is.
>=20
> Some of it also points to RCU freeing, but that "kmalloc-128" doesn't
> really match my expectations. According to your slabinfo, it's not the
> dentries.
>
> One thing I'd ask you to do is to boot with the "slub_nomerge" kernel
> command  line switch. The SLUB "merge slab caches" thing may save some
> memory, but it has been a disaster from every other standpoint - every
> time there's a memory leak, it ends up making it very confusing to try
> to figure things out.
>=20
> For example, your traces seem to imply that the kmalloc-128 allocation
> is actually the "filp" cache, but it has gotten merged with the
> kmalloc-128 cache, so slabinfo doesn't actually show the right user.

Redone with slub_nomerge cmdline switch.
Attached (for easy diffing):

slabinfo-2, meminfo-2: when memory use starts manifesting itself
                       (work triggering it being SIGSTOPped)

slabinfo-4, meminfo-4: info gathered again after sync && echo 2 > /proc/sys=
/vm/drop_caches

kmemleak reports 86681 new leaks between shortly after boot and -2 state.
(and 2348 additional ones between -2 and -4).

> (Pekka? This is a real _problem_. The whole "confused debugging" is
> wasting a lot of peoples time. Can we please try to get slabinfo
> statistics work right for the merged state. Or perhaps decide to just
> not merge at all?)
>=20
> As to why it has started to happen now: with the whole RCU lookup
> thing, many more filesystem objects are RCU-free'd (dentries have been
> for a long time, but now we have inodes and filp's too), and that may
> end up delaying allocations sufficiently that you end up seeing
> something that used to be borderline become a major problem.
>=20
> Also, what's your kernel config, in particular wrt RCU? The RCU
> freeing _should_ be self-limiting (if I recall correctly) and not let
> infinite amounts of RCU work (ie pending freeing) accumulate, but
> maybe something is broken. Do you have a UP kernel with TINY_RCU, for
> example?

Config was in first message of thread (but unfortunately not properly
labeled), attaching again (to include change for debugging features)

Yes, it's uni-processor system, so SMP=3Dn.
TINY_RCU=3Dy, PREEMPT_VOLUNTARY=3Dy (whole /proc/config.gz attached keeping
compression)

Bruno


> Or maybe I'm just confused, and there's never any RCU throttling at
> all. Paul?
>=20
>                                Linus

--MP_/+ZFWHyVo1h54d_R45Q9G9iQ
Content-Type: application/x-gzip
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=config.gz

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
mAzPsIEnhm6q/wcry6Lxqw0BAA==

--MP_/+ZFWHyVo1h54d_R45Q9G9iQ
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=meminfo-2

MemTotal:         480644 kB
MemFree:            8236 kB
Buffers:           31740 kB
Cached:           139864 kB
SwapCached:            0 kB
Active:           109392 kB
Inactive:         130728 kB
Active(anon):      30960 kB
Inactive(anon):    37364 kB
Active(file):      78432 kB
Inactive(file):    93364 kB
Unevictable:          32 kB
Mlocked:              32 kB
SwapTotal:        524284 kB
SwapFree:         524284 kB
Dirty:                56 kB
Writeback:             0 kB
AnonPages:         68132 kB
Mapped:             8260 kB
Shmem:               240 kB
Slab:             205832 kB
SReclaimable:      15448 kB
SUnreclaim:       190384 kB
KernelStack:       20792 kB
PageTables:          800 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      764604 kB
Committed_AS:     122864 kB
VmallocTotal:     548548 kB
VmallocUsed:        8368 kB
VmallocChunk:     534836 kB
AnonHugePages:         0 kB
DirectMap4k:       16320 kB
DirectMap4M:      475136 kB

--MP_/+ZFWHyVo1h54d_R45Q9G9iQ
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=meminfo-4

MemTotal:         480644 kB
MemFree:           89376 kB
Buffers:           31964 kB
Cached:            12816 kB
SwapCached:            0 kB
Active:            66512 kB
Inactive:          46780 kB
Active(anon):      30964 kB
Inactive(anon):    37356 kB
Active(file):      35548 kB
Inactive(file):     9424 kB
Unevictable:          32 kB
Mlocked:              32 kB
SwapTotal:        524284 kB
SwapFree:         524284 kB
Dirty:                56 kB
Writeback:             0 kB
AnonPages:         68128 kB
Mapped:             8268 kB
Shmem:               240 kB
Slab:             251592 kB
SReclaimable:      15824 kB
SUnreclaim:       235768 kB
KernelStack:       20960 kB
PageTables:          804 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:      764604 kB
Committed_AS:     122864 kB
VmallocTotal:     548548 kB
VmallocUsed:        8368 kB
VmallocChunk:     534836 kB
AnonHugePages:         0 kB
DirectMap4k:       16320 kB
DirectMap4M:      475136 kB

--MP_/+ZFWHyVo1h54d_R45Q9G9iQ
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=slabinfo-2

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
squashfs_inode_cache   1900   1900    384   10    1 : tunables    0    0    0 : slabdata    190    190      0
nfs_direct_cache       0      0     72   56    1 : tunables    0    0    0 : slabdata      0      0      0
nfs_write_data        36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
nfs_read_data         36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
nfs_inode_cache       70     70    568   14    2 : tunables    0    0    0 : slabdata      5      5      0
nfs_page              64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_buffers           16     16   2048    8    4 : tunables    0    0    0 : slabdata      2      2      0
rpc_tasks             32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_inode_cache       36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
fib6_nodes           128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
ip6_dst_cache         29     42    192   21    1 : tunables    0    0    0 : slabdata      2      2      0
ndisc_cache           21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAWv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
UDPLITEv6              0      0    672   12    2 : tunables    0    0    0 : slabdata      0      0      0
UDPv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCPv6          0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
request_sock_TCPv6     32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
TCPv6                 12     12   1312   12    4 : tunables    0    0    0 : slabdata      1      1      0
aoe_bufs               0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
scsi_sense_cache      42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_cmd_cache        25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
sd_ext_cdb           128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
cfq_io_context       128    128     64   64    1 : tunables    0    0    0 : slabdata      2      2      0
cfq_queue             47     52    152   26    1 : tunables    0    0    0 : slabdata      2      2      0
mqueue_inode_cache      8      8    480    8    1 : tunables    0    0    0 : slabdata      1      1      0
xfs_buf                0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
fstrm_item             0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_mru_cache_elem      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ili                0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_inode              0      0    608   13    2 : tunables    0    0    0 : slabdata      0      0      0
xfs_efi_item           0      0    288   14    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_efd_item           0      0    288   14    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_buf_item           0      0    176   23    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_item_desc      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_trans              0      0    224   18    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ifork              0      0     56   73    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_dabuf              0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_da_state           0      0    336   12    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_btree_cur          0      0    152   26    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_bmap_free_item      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_ticket         0      0    176   23    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ioend             64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
reiser_inode_cache  14180  14180    392   10    1 : tunables    0    0    0 : slabdata   1418   1418      0
configfs_dir_cache     73     73     56   73    1 : tunables    0    0    0 : slabdata      1      1      0
kioctx                 0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
kiocb                  0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
inotify_event_private_data    256    256     16  256    1 : tunables    0    0    0 : slabdata      1      1      0
inotify_inode_mark     56     56     72   56    1 : tunables    0    0    0 : slabdata      1      1      0
fasync_cache           0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
khugepaged_mm_slot      0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
nsproxy                0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
posix_timers_cache      0      0    120   34    1 : tunables    0    0    0 : slabdata      0      0      0
uid_cache             64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
UNIX                  35     38    416   19    2 : tunables    0    0    0 : slabdata      2      2      0
UDP-Lite               0      0    512    8    1 : tunables    0    0    0 : slabdata      0      0      0
tcp_bind_bucket      128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
inet_peer_cache       25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_trie          128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_alias         170    170     24  170    1 : tunables    0    0    0 : slabdata      1      1      0
ip_dst_cache          25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
arp_cache             21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAW                    8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
UDP                   15     16    512    8    1 : tunables    0    0    0 : slabdata      2      2      0
tw_sock_TCP           32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
request_sock_TCP      42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
TCP                   13     13   1184   13    4 : tunables    0    0    0 : slabdata      1      1      0
eventpoll_pwq          0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
eventpoll_epi          0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
sgpool-128            12     12   2560   12    8 : tunables    0    0    0 : slabdata      1      1      0
sgpool-64             12     12   1280   12    4 : tunables    0    0    0 : slabdata      1      1      0
sgpool-32             12     12    640   12    2 : tunables    0    0    0 : slabdata      1      1      0
sgpool-16             12     12    320   12    1 : tunables    0    0    0 : slabdata      1      1      0
sgpool-8              25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_data_buffer       0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
blkdev_queue          17     17    920   17    4 : tunables    0    0    0 : slabdata      1      1      0
blkdev_requests       19     19    208   19    1 : tunables    0    0    0 : slabdata      1      1      0
blkdev_ioc           102    102     40  102    1 : tunables    0    0    0 : slabdata      1      1      0
fsnotify_event_holder      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
fsnotify_event        64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
bio-0                 34     64    128   32    1 : tunables    0    0    0 : slabdata      2      2      0
biovec-256            10     10   3072   10    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128             0      0   1536   10    4 : tunables    0    0    0 : slabdata      0      0      0
biovec-64             10     10    768   10    2 : tunables    0    0    0 : slabdata      1      1      0
biovec-16             21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
sock_inode_cache      70     77    352   11    1 : tunables    0    0    0 : slabdata      7      7      0
skbuff_fclone_cache     11     11    352   11    1 : tunables    0    0    0 : slabdata      1      1      0
skbuff_head_cache    517    525    192   21    1 : tunables    0    0    0 : slabdata     25     25      0
file_lock_cache       39     39    104   39    1 : tunables    0    0    0 : slabdata      1      1      0
shmem_inode_cache    897    910    400   10    1 : tunables    0    0    0 : slabdata     91     91      0
Acpi-Operand         932    935     48   85    1 : tunables    0    0    0 : slabdata     11     11      0
Acpi-ParseExt         85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Parse           128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-State            85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Namespace       680    680     24  170    1 : tunables    0    0    0 : slabdata      4      4      0
proc_inode_cache    1908   1908    336   12    1 : tunables    0    0    0 : slabdata    159    159      0
sigqueue              28     28    144   28    1 : tunables    0    0    0 : slabdata      1      1      0
bdev_cache            13     18    448    9    1 : tunables    0    0    0 : slabdata      2      2      0
sysfs_dir_cache    13770  13770     48   85    1 : tunables    0    0    0 : slabdata    162    162      0
mnt_cache             50     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
filp               49408  49408    128   32    1 : tunables    0    0    0 : slabdata   1544   1544      0
inode_cache         3936   3939    312   13    1 : tunables    0    0    0 : slabdata    303    303      0
dentry             28892  28896    128   32    1 : tunables    0    0    0 : slabdata    903    903      0
names_cache            8      8   4096    8    8 : tunables    0    0    0 : slabdata      1      1      0
buffer_head        31609  35551     56   73    1 : tunables    0    0    0 : slabdata    487    487      0
vm_area_struct      1584   1656     88   46    1 : tunables    0    0    0 : slabdata     36     36      0
mm_struct             54     57    416   19    2 : tunables    0    0    0 : slabdata      3      3      0
fs_cache             128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
files_cache         1323   1323    192   21    1 : tunables    0    0    0 : slabdata     63     63      0
signal_cache        2592   2592    512    8    1 : tunables    0    0    0 : slabdata    324    324      0
sighand_cache         77     84   1312   12    4 : tunables    0    0    0 : slabdata      7      7      0
task_xstate          240    240    512    8    1 : tunables    0    0    0 : slabdata     30     30      0
task_struct         2603   2603    832   19    4 : tunables    0    0    0 : slabdata    137    137      0
cred_jar           11718  11718     96   42    1 : tunables    0    0    0 : slabdata    279    279      0
anon_vma_chain      1667   1870     24  170    1 : tunables    0    0    0 : slabdata     11     11      0
anon_vma            1051   1190     24  170    1 : tunables    0    0    0 : slabdata      7      7      0
pid                 2624   2624     64   64    1 : tunables    0    0    0 : slabdata     41     41      0
kmemleak_scan_area    256    256     16  256    1 : tunables    0    0    0 : slabdata      1      1      0
kmemleak_object   1030632 1030632    168   24    1 : tunables    0    0    0 : slabdata  42943  42943      0
radix_tree_node     4888   4888    304   13    1 : tunables    0    0    0 : slabdata    376    376      0
idr_layer_cache      258    260    152   26    1 : tunables    0    0    0 : slabdata     10     10      0
dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-2048       0      0   2048    8    4 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-1024       0      0   1024    8    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-512        0      0    512    8    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-256        0      0    256   16    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-128        0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-192        0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
kmalloc-8192          12     12   8192    4    8 : tunables    0    0    0 : slabdata      3      3      0
kmalloc-4096         272    272   4096    8    8 : tunables    0    0    0 : slabdata     34     34      0
kmalloc-2048         546    552   2048    8    4 : tunables    0    0    0 : slabdata     69     69      0
kmalloc-1024        1456   1456   1024    8    2 : tunables    0    0    0 : slabdata    182    182      0
kmalloc-512          415    416    512    8    1 : tunables    0    0    0 : slabdata     52     52      0
kmalloc-256           46     48    256   16    1 : tunables    0    0    0 : slabdata      3      3      0
kmalloc-128          320    320    128   32    1 : tunables    0    0    0 : slabdata     10     10      0
kmalloc-64          2304   2304     64   64    1 : tunables    0    0    0 : slabdata     36     36      0
kmalloc-32          3072   3072     32  128    1 : tunables    0    0    0 : slabdata     24     24      0
kmalloc-16          2467   7168     16  256    1 : tunables    0    0    0 : slabdata     28     28      0
kmalloc-8           3580   3584      8  512    1 : tunables    0    0    0 : slabdata      7      7      0
kmalloc-192          147    147    192   21    1 : tunables    0    0    0 : slabdata      7      7      0
kmalloc-96          1008   1008     96   42    1 : tunables    0    0    0 : slabdata     24     24      0
kmem_cache            32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      256    256     32  128    1 : tunables    0    0    0 : slabdata      2      2      0

--MP_/+ZFWHyVo1h54d_R45Q9G9iQ
Content-Type: text/plain
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename=slabinfo-4

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
squashfs_inode_cache   1900   1900    384   10    1 : tunables    0    0    0 : slabdata    190    190      0
nfs_direct_cache       0      0     72   56    1 : tunables    0    0    0 : slabdata      0      0      0
nfs_write_data        36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
nfs_read_data         36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
nfs_inode_cache       70     70    568   14    2 : tunables    0    0    0 : slabdata      5      5      0
nfs_page              64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_buffers           16     16   2048    8    4 : tunables    0    0    0 : slabdata      2      2      0
rpc_tasks             32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
rpc_inode_cache       36     36    448    9    1 : tunables    0    0    0 : slabdata      4      4      0
fib6_nodes           128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
ip6_dst_cache         29     42    192   21    1 : tunables    0    0    0 : slabdata      2      2      0
ndisc_cache           21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAWv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
UDPLITEv6              0      0    672   12    2 : tunables    0    0    0 : slabdata      0      0      0
UDPv6                 12     12    672   12    2 : tunables    0    0    0 : slabdata      1      1      0
tw_sock_TCPv6          0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
request_sock_TCPv6     32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
TCPv6                 12     12   1312   12    4 : tunables    0    0    0 : slabdata      1      1      0
aoe_bufs               0      0     48   85    1 : tunables    0    0    0 : slabdata      0      0      0
scsi_sense_cache      42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_cmd_cache        25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
sd_ext_cdb           128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
cfq_io_context       128    128     64   64    1 : tunables    0    0    0 : slabdata      2      2      0
cfq_queue             46     52    152   26    1 : tunables    0    0    0 : slabdata      2      2      0
mqueue_inode_cache      8      8    480    8    1 : tunables    0    0    0 : slabdata      1      1      0
xfs_buf                0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
fstrm_item             0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_mru_cache_elem      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ili                0      0    160   25    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_inode              0      0    608   13    2 : tunables    0    0    0 : slabdata      0      0      0
xfs_efi_item           0      0    288   14    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_efd_item           0      0    288   14    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_buf_item           0      0    176   23    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_item_desc      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_trans              0      0    224   18    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ifork              0      0     56   73    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_dabuf              0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_da_state           0      0    336   12    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_btree_cur          0      0    152   26    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_bmap_free_item      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_log_ticket         0      0    176   23    1 : tunables    0    0    0 : slabdata      0      0      0
xfs_ioend             64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
reiser_inode_cache  14220  14220    392   10    1 : tunables    0    0    0 : slabdata   1422   1422      0
configfs_dir_cache     73     73     56   73    1 : tunables    0    0    0 : slabdata      1      1      0
kioctx                 0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
kiocb                  0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
inotify_event_private_data    256    256     16  256    1 : tunables    0    0    0 : slabdata      1      1      0
inotify_inode_mark     56     56     72   56    1 : tunables    0    0    0 : slabdata      1      1      0
fasync_cache           0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
khugepaged_mm_slot      0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
nsproxy                0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
posix_timers_cache      0      0    120   34    1 : tunables    0    0    0 : slabdata      0      0      0
uid_cache             64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
UNIX                  35     38    416   19    2 : tunables    0    0    0 : slabdata      2      2      0
UDP-Lite               0      0    512    8    1 : tunables    0    0    0 : slabdata      0      0      0
tcp_bind_bucket      128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
inet_peer_cache       25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_trie          128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
ip_fib_alias         170    170     24  170    1 : tunables    0    0    0 : slabdata      1      1      0
ip_dst_cache          25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
arp_cache             21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
RAW                    8      8    512    8    1 : tunables    0    0    0 : slabdata      1      1      0
UDP                   15     16    512    8    1 : tunables    0    0    0 : slabdata      2      2      0
tw_sock_TCP           32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
request_sock_TCP      42     42     96   42    1 : tunables    0    0    0 : slabdata      1      1      0
TCP                   13     13   1184   13    4 : tunables    0    0    0 : slabdata      1      1      0
eventpoll_pwq          0      0     40  102    1 : tunables    0    0    0 : slabdata      0      0      0
eventpoll_epi          0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
sgpool-128            12     12   2560   12    8 : tunables    0    0    0 : slabdata      1      1      0
sgpool-64             12     12   1280   12    4 : tunables    0    0    0 : slabdata      1      1      0
sgpool-32             12     12    640   12    2 : tunables    0    0    0 : slabdata      1      1      0
sgpool-16             12     12    320   12    1 : tunables    0    0    0 : slabdata      1      1      0
sgpool-8              25     25    160   25    1 : tunables    0    0    0 : slabdata      1      1      0
scsi_data_buffer       0      0     24  170    1 : tunables    0    0    0 : slabdata      0      0      0
blkdev_queue          17     17    920   17    4 : tunables    0    0    0 : slabdata      1      1      0
blkdev_requests       19     19    208   19    1 : tunables    0    0    0 : slabdata      1      1      0
blkdev_ioc           102    102     40  102    1 : tunables    0    0    0 : slabdata      1      1      0
fsnotify_event_holder      0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
fsnotify_event        64     64     64   64    1 : tunables    0    0    0 : slabdata      1      1      0
bio-0                 34     64    128   32    1 : tunables    0    0    0 : slabdata      2      2      0
biovec-256            10     10   3072   10    8 : tunables    0    0    0 : slabdata      1      1      0
biovec-128             0      0   1536   10    4 : tunables    0    0    0 : slabdata      0      0      0
biovec-64             10     10    768   10    2 : tunables    0    0    0 : slabdata      1      1      0
biovec-16             21     21    192   21    1 : tunables    0    0    0 : slabdata      1      1      0
sock_inode_cache      70     77    352   11    1 : tunables    0    0    0 : slabdata      7      7      0
skbuff_fclone_cache     11     11    352   11    1 : tunables    0    0    0 : slabdata      1      1      0
skbuff_head_cache    518    546    192   21    1 : tunables    0    0    0 : slabdata     26     26      0
file_lock_cache       39     39    104   39    1 : tunables    0    0    0 : slabdata      1      1      0
shmem_inode_cache    909    910    400   10    1 : tunables    0    0    0 : slabdata     91     91      0
Acpi-Operand         932    935     48   85    1 : tunables    0    0    0 : slabdata     11     11      0
Acpi-ParseExt         85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Parse           128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-State            85     85     48   85    1 : tunables    0    0    0 : slabdata      1      1      0
Acpi-Namespace       680    680     24  170    1 : tunables    0    0    0 : slabdata      4      4      0
proc_inode_cache    3480   3480    336   12    1 : tunables    0    0    0 : slabdata    290    290      0
sigqueue              28     28    144   28    1 : tunables    0    0    0 : slabdata      1      1      0
bdev_cache            13     18    448    9    1 : tunables    0    0    0 : slabdata      2      2      0
sysfs_dir_cache    13770  13770     48   85    1 : tunables    0    0    0 : slabdata    162    162      0
mnt_cache             50     50    160   25    1 : tunables    0    0    0 : slabdata      2      2      0
filp               67744  67744    128   32    1 : tunables    0    0    0 : slabdata   2117   2117      0
inode_cache         3990   3991    312   13    1 : tunables    0    0    0 : slabdata    307    307      0
dentry             30620  30624    128   32    1 : tunables    0    0    0 : slabdata    957    957      0
names_cache            8      8   4096    8    8 : tunables    0    0    0 : slabdata      1      1      0
buffer_head        11030  28324     56   73    1 : tunables    0    0    0 : slabdata    388    388      0
vm_area_struct      1599   1656     88   46    1 : tunables    0    0    0 : slabdata     36     36      0
mm_struct             54     57    416   19    2 : tunables    0    0    0 : slabdata      3      3      0
fs_cache             128    128     32  128    1 : tunables    0    0    0 : slabdata      1      1      0
files_cache         1323   1323    192   21    1 : tunables    0    0    0 : slabdata     63     63      0
signal_cache        2616   2616    512    8    1 : tunables    0    0    0 : slabdata    327    327      0
sighand_cache         76     84   1312   12    4 : tunables    0    0    0 : slabdata      7      7      0
task_xstate          248    248    512    8    1 : tunables    0    0    0 : slabdata     31     31      0
task_struct         2622   2622    832   19    4 : tunables    0    0    0 : slabdata    138    138      0
cred_jar           11886  11886     96   42    1 : tunables    0    0    0 : slabdata    283    283      0
anon_vma_chain      1667   1870     24  170    1 : tunables    0    0    0 : slabdata     11     11      0
anon_vma            1051   1190     24  170    1 : tunables    0    0    0 : slabdata      7      7      0
pid                 2624   2624     64   64    1 : tunables    0    0    0 : slabdata     41     41      0
kmemleak_scan_area    256    256     16  256    1 : tunables    0    0    0 : slabdata      1      1      0
kmemleak_object   1290696 1290696    168   24    1 : tunables    0    0    0 : slabdata  53779  53779      0
radix_tree_node     4888   4888    304   13    1 : tunables    0    0    0 : slabdata    376    376      0
idr_layer_cache      257    260    152   26    1 : tunables    0    0    0 : slabdata     10     10      0
dma-kmalloc-8192       0      0   8192    4    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-4096       0      0   4096    8    8 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-2048       0      0   2048    8    4 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-1024       0      0   1024    8    2 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-512        0      0    512    8    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-256        0      0    256   16    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-128        0      0    128   32    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-64         0      0     64   64    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-32         0      0     32  128    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-16         0      0     16  256    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-8          0      0      8  512    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-192        0      0    192   21    1 : tunables    0    0    0 : slabdata      0      0      0
dma-kmalloc-96         0      0     96   42    1 : tunables    0    0    0 : slabdata      0      0      0
kmalloc-8192          12     12   8192    4    8 : tunables    0    0    0 : slabdata      3      3      0
kmalloc-4096         277    280   4096    8    8 : tunables    0    0    0 : slabdata     35     35      0
kmalloc-2048         544    592   2048    8    4 : tunables    0    0    0 : slabdata     74     74      0
kmalloc-1024        1462   1464   1024    8    2 : tunables    0    0    0 : slabdata    183    183      0
kmalloc-512          415    416    512    8    1 : tunables    0    0    0 : slabdata     52     52      0
kmalloc-256           46     48    256   16    1 : tunables    0    0    0 : slabdata      3      3      0
kmalloc-128          320    320    128   32    1 : tunables    0    0    0 : slabdata     10     10      0
kmalloc-64          2301   2304     64   64    1 : tunables    0    0    0 : slabdata     36     36      0
kmalloc-32          3186   3200     32  128    1 : tunables    0    0    0 : slabdata     25     25      0
kmalloc-16          2466   7168     16  256    1 : tunables    0    0    0 : slabdata     28     28      0
kmalloc-8           3580   3584      8  512    1 : tunables    0    0    0 : slabdata      7      7      0
kmalloc-192          168    168    192   21    1 : tunables    0    0    0 : slabdata      8      8      0
kmalloc-96          1050   1050     96   42    1 : tunables    0    0    0 : slabdata     25     25      0
kmem_cache            32     32    128   32    1 : tunables    0    0    0 : slabdata      1      1      0
kmem_cache_node      256    256     32  128    1 : tunables    0    0    0 : slabdata      2      2      0

--MP_/+ZFWHyVo1h54d_R45Q9G9iQ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
