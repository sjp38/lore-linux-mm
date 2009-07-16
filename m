Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 251A56B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:44:45 -0400 (EDT)
Date: Thu, 16 Jul 2009 12:44:41 -0400 (EDT)
From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: Re: What to do with this message (2.6.30.1) ? (happened again)
In-Reply-To: <alpine.DEB.2.00.0907161113440.1116@p34.internal.lan>
Message-ID: <alpine.DEB.2.00.0907161239360.1116@p34.internal.lan>
References: <20090713134621.124aa18e.skraw@ithnet.com> <4807377b0907132240g6f74c9cbnf1302d354a0e0a72@mail.gmail.com> <alpine.DEB.2.00.0907132247001.8784@chino.kir.corp.google.com> <20090715084754.36ff73bf.skraw@ithnet.com> <alpine.DEB.2.00.0907150115190.14393@chino.kir.corp.google.com>
 <20090715113740.334309dd.skraw@ithnet.com> <alpine.DEB.2.00.0907151323170.22582@chino.kir.corp.google.com> <alpine.DEB.2.00.0907161113440.1116@p34.internal.lan>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Stephan von Krawczynski <skraw@ithnet.com>, Jesse Brandeburg <jesse.brandeburg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>
List-ID: <linux-mm.kvack.org>



On Thu, 16 Jul 2009, Justin Piszcz wrote:

>
>
> On Wed, 15 Jul 2009, David Rientjes wrote:
>
>> On Wed, 15 Jul 2009, Stephan von Krawczynski wrote:
>> 
> After talking to Stephan offline--
>
> I am also using the Intel e1000e for my primary network interface to the
> LAN, I suppose this is the culprit?  I have both options compiled in e1000
> and e1000e as I have Intel 1Gbps PCI nics as well.. I am thinking back now
> and before the introduction of e1000e I do not recall seeing any issues,
> perhaps this is it?
>
> Justin.
>
>
>
>

The dmesg output is at the bottom.

Lines of interest(?):
[113178.857208]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113178.857210]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0

I spoke too soon, here is the slabtop info, it just happened with 
2.6.30.1 (while rsyncing, as usual) -- but in this case, it is during
a migration (I am migrating chunk size on a RAID-6 array) and have the rebuild
priority set to the highest, just FYI:

This output is ~30min late after the problem happened, not sure if that
will be useful?

The rsync was going over an e1000e network connection to a 3ware raid6.

slabtop -o | col -bx > out2

  Active / Total Objects (% used)    : 1499611 / 1540287 (97.4%)
  Active / Total Slabs (% used)37G: 95759 / 95824 (99.9%)
  Active / Total Caches (% used)     : 99 / 165 (60.0%)
  Active / Total Size (% used)37G: 350504.68K / 361743.62K (96.9%)
  Minimum / Average / Maximum Object : 0.02K / 0.23K / 4096.00K

   OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME
84211 1084211 100%    0.10K  2930344G37    117212K buffer_head

193784 191887  99%    0.94K  4844610;43H4    193784K xfs_inode
107960  94964  87%    0.19K   539842G20     21592K dentry
  50939  42341  83%    0.54K   727712;43H7     29108K radix_tree_node
  29323  22319  76%    0.06K    49742G5950G1988K size-64
  15456  14746  95%    0.16K    67242G2350G2688K vm_area_struct
  13710  11665  85%    0.12K    45742G3050G1828K size-128
   6432   6318  98%    0.08K    13442G4851G536K sysfs_dir_cache
   4256   4152  97%    0.03K     3841G11251G152K size-32
   4020   3636  90%    0.19K    20142G2051G804K filp
   3888   3432  88%    0.02K     2741G14451G108K anon_vma
   3002   2431  80%    0.20K    15842G1951G632K xfs_ili
   2080   1813  87%    0.19K    10442G2051G416K size-192
   1785   1012  56%    0.25K    11942G1551G476K skbuff_head_cache
   1495   1492  99%    0.73K    29923;43H550G1196K shmem_inode_cache
   120    617  55%    0.09K     2842G4051G112K xfs_ioend79G24;1H?1049l

$ cat /proc/slabinfo

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
rpc_buffers            8      8   2048    2    1 : tunables   24   12    8 : slabdata      4      4      0
rpc_tasks              8     12    320   12    1 : tunables   54   27    8 : slabdata      1      1      0
rpc_inode_cache       13     15    768    5    1 : tunables   54   27    8 : slabdata      3      3      0
nf_conntrack_expect      0      0    208   19    1 : tunables  120   60    8 : slabdata      0      0      0
nf_conntrack         118    210    256   15    1 : tunables  120   60    8 : slabdata     14     14      0
uhci_urb_priv          4     67     56   67    1 : tunables  120   60    8 : slabdata      1      1      0
scsi_sense_cache     135    300    128   30    1 : tunables  120   60    8 : slabdata      9     10     24
scsi_cmd_cache       138    300    256   15    1 : tunables  120   60    8 : slabdata     15     20     24
cfq_io_context       275    299    168   23    1 : tunables  120   60    8 : slabdata     13     13      0
cfq_queue            275    322    168   23    1 : tunables  120   60    8 : slabdata     14     14      0
xfs_buf               39     60    384   10    1 : tunables   54   27    8 : slabdata      6      6      0
fstrm_item             0      0     24  144    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_mru_cache_elem      0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_ili             2426   3002    200   19    1 : tunables  120   60    8 : slabdata    158    158      0
xfs_inode         191742 193644    960    4    1 : tunables   54   27    8 : slabdata  48411  48411    172
xfs_efi_item           0      0    360   11    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_efd_item           0      0    368   10    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_buf_item          32     60    192   20    1 : tunables  120   60    8 : slabdata      3      3      0
xfs_trans             15     15    800    5    1 : tunables   54   27    8 : slabdata      3      3      0
xfs_ifork              0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_dabuf             15    144     24  144    1 : tunables  120   60    8 : slabdata      1      1      0
xfs_da_state           2      8    488    8    1 : tunables   54   27    8 : slabdata      1      1      0
xfs_btree_cur          9     19    208   19    1 : tunables  120   60    8 : slabdata      1      1      0
xfs_bmap_free_item      0      0     24  144    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_log_ticket         8     19    200   19    1 : tunables  120   60    8 : slabdata      1      1      0
xfs_ioend            470   1040     96   40    1 : tunables  120   60    8 : slabdata     20     26    384
udf_inode_cache        0      0    624    6    1 : tunables   54   27    8 : slabdata      0      0      0
ntfs_big_inode_cache      0      0    832    4    1 : tunables   54   27    8 : slabdata      0      0      0
ntfs_inode_cache       0      0    264   15    1 : tunables   54   27    8 : slabdata      0      0      0
ntfs_name_cache        0      0    512    8    1 : tunables   54   27    8 : slabdata      0      0      0
ntfs_attr_ctx_cache      0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
ntfs_index_ctx_cache      0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
cifs_small_rq         30     32    448    8    1 : tunables   54   27    8 : slabdata      4      4      0
cifs_request           4      4  16512    1    8 : tunables    8    4    0 : slabdata      4      4      0
cifs_oplock_structs      0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
cifs_mpx_ids           3     59     64   59    1 : tunables  120   60    8 : slabdata      1      1      0
cifs_inode_cache       0      0    624    6    1 : tunables   54   27    8 : slabdata      0      0      0
nfs_direct_cache       0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
nfs_write_data        36     44    704   11    2 : tunables   54   27    8 : slabdata      4      4      0
nfs_read_data         32     36    640    6    1 : tunables   54   27    8 : slabdata      6      6      0
nfs_inode_cache        4      4    888    4    1 : tunables   54   27    8 : slabdata      1      1      0
nfs_page               0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
isofs_inode_cache      0      0    600    6    1 : tunables   54   27    8 : slabdata      0      0      0
fat_inode_cache        0      0    632    6    1 : tunables   54   27    8 : slabdata      0      0      0
fat_cache              0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
journal_handle         0      0     24  144    1 : tunables  120   60    8 : slabdata      0      0      0
journal_head           0      0    112   34    1 : tunables  120   60    8 : slabdata      0      0      0
revoke_table           2    202     16  202    1 : tunables  120   60    8 : slabdata      1      1      0
revoke_record          0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
ext2_inode_cache       0      0    704    5    1 : tunables   54   27    8 : slabdata      0      0      0
ext3_inode_cache       2      5    720    5    1 : tunables   54   27    8 : slabdata      1      1      0
kioctx                 0      0    320   12    1 : tunables   54   27    8 : slabdata      0      0      0
kiocb                  0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
inotify_event_cache      0      0     40   92    1 : tunables  120   60    8 : slabdata      0      0      0
inotify_watch_cache     27    106     72   53    1 : tunables  120   60    8 : slabdata      2      2      0
dnotify_cache          0      0     40   92    1 : tunables  120   60    8 : slabdata      0      0      0
fasync_cache           2    144     24  144    1 : tunables  120   60    8 : slabdata      1      1      0
shmem_inode_cache   1492   1495    744    5    1 : tunables   54   27    8 : slabdata    299    299      0
nsproxy                0      0     48   77    1 : tunables  120   60    8 : slabdata      0      0      0
posix_timers_cache      0      0    160   24    1 : tunables  120   60    8 : slabdata      0      0      0
uid_cache             18     60    128   30    1 : tunables  120   60    8 : slabdata      2      2      0
kvm_vcpu               0      0  10352    1    4 : tunables    8    4    0 : slabdata      0      0      0
kvm_mmu_page_header      0      0    176   22    1 : tunables  120   60    8 : slabdata      0      0      0
kvm_rmap_desc          0      0     40   92    1 : tunables  120   60    8 : slabdata      0      0      0
kvm_pte_chain          0      0     56   67    1 : tunables  120   60    8 : slabdata      0      0      0
UNIX                 276    324    640    6    1 : tunables   54   27    8 : slabdata     54     54      0
UDP-Lite               0      0    704   11    2 : tunables   54   27    8 : slabdata      0      0      0
tcp_bind_bucket       90    224     32  112    1 : tunables  120   60    8 : slabdata      2      2      0
inet_peer_cache        6     59     64   59    1 : tunables  120   60    8 : slabdata      1      1      0
ip_fib_alias           0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
ip_fib_hash           20     53     72   53    1 : tunables  120   60    8 : slabdata      1      1      0
ip_dst_cache          80    170    384   10    1 : tunables   54   27    8 : slabdata     17     17      0
arp_cache              6     15    256   15    1 : tunables  120   60    8 : slabdata      1      1      0
RAW                    5     11    704   11    2 : tunables   54   27    8 : slabdata      1      1      0
UDP                   25     44    704   11    2 : tunables   54   27    8 : slabdata      4      4      0
tw_sock_TCP            1     20    192   20    1 : tunables  120   60    8 : slabdata      1      1      0
request_sock_TCP       1     30    128   30    1 : tunables  120   60    8 : slabdata      1      1      0
TCP                  135    160   1472    5    2 : tunables   24   12    8 : slabdata     32     32      0
eventpoll_pwq        111    265     72   53    1 : tunables  120   60    8 : slabdata      5      5      0
eventpoll_epi        111    240    128   30    1 : tunables  120   60    8 : slabdata      8      8      0
sgpool-128             2      2   4096    1    1 : tunables   24   12    8 : slabdata      2      2      0
sgpool-64              2      2   2048    2    1 : tunables   24   12    8 : slabdata      1      1      0
sgpool-32             94    160   1024    4    1 : tunables   54   27    8 : slabdata     28     40     64
sgpool-16             26     48    512    8    1 : tunables   54   27    8 : slabdata      6      6      0
sgpool-8              90     90    256   15    1 : tunables  120   60    8 : slabdata      6      6      0
scsi_data_buffer       0      0     24  144    1 : tunables  120   60    8 : slabdata      0      0      0
blkdev_queue          15     18   2080    3    2 : tunables   24   12    8 : slabdata      6      6      0
blkdev_requests      165    250    368   10    1 : tunables   54   27    8 : slabdata     24     25     74
blkdev_ioc           107    265     72   53    1 : tunables  120   60    8 : slabdata      5      5      0
bio-0                360    760    192   20    1 : tunables  120   60    8 : slabdata     29     38    228
biovec-256             2      2   4096    1    1 : tunables   24   12    8 : slabdata      2      2      0
biovec-128             0      0   2048    2    1 : tunables   24   12    8 : slabdata      0      0      0
biovec-64            190    328   1024    4    1 : tunables   54   27    8 : slabdata     50     82    172
biovec-16             26     45    256   15    1 : tunables  120   60    8 : slabdata      2      3      0
sock_inode_cache     462    510    640    6    1 : tunables   54   27    8 : slabdata     85     85      0
skbuff_fclone_cache     31     40    448    8    1 : tunables   54   27    8 : slabdata      5      5      0
skbuff_head_cache    975   1785    256   15    1 : tunables  120   60    8 : slabdata    119    119     36
file_lock_cache       30     88    176   22    1 : tunables  120   60    8 : slabdata      4      4      0
Acpi-Operand         956   1007     72   53    1 : tunables  120   60    8 : slabdata     19     19      0
Acpi-ParseExt          0      0     72   53    1 : tunables  120   60    8 : slabdata      0      0      0
Acpi-Parse             0      0     48   77    1 : tunables  120   60    8 : slabdata      0      0      0
Acpi-State             0      0     80   48    1 : tunables  120   60    8 : slabdata      0      0      0
Acpi-Namespace       652    672     32  112    1 : tunables  120   60    8 : slabdata      6      6      0
proc_inode_cache     321    336    600    6    1 : tunables   54   27    8 : slabdata     56     56      0
sigqueue              98    192    160   24    1 : tunables  120   60    8 : slabdata      8      8      0
radix_tree_node    42347  50939    552    7    1 : tunables   54   27    8 : slabdata   7277   7277      0
bdev_cache            20     24    832    4    1 : tunables   54   27    8 : slabdata      6      6      0
sysfs_dir_cache     6318   6432     80   48    1 : tunables  120   60    8 : slabdata    134    134      0
mnt_cache             25     45    256   15    1 : tunables  120   60    8 : slabdata      3      3      0
filp                3596   4020    192   20    1 : tunables  120   60    8 : slabdata    201    201      0
inode_cache          219    301    552    7    1 : tunables   54   27    8 : slabdata     43     43      0
dentry             94813 107840    192   20    1 : tunables  120   60    8 : slabdata   5392   5392    204
names_cache           25     25   4096    1    1 : tunables   24   12    8 : slabdata     25     25      0
buffer_head       1086394 1086394    104   37    1 : tunables  120   60    8 : slabdata  29362  29362      0
vm_area_struct     14669  15456    168   23    1 : tunables  120   60    8 : slabdata    672    672     60
mm_struct            193    261    832    9    2 : tunables   54   27    8 : slabdata     29     29      0
fs_cache             202    531     64   59    1 : tunables  120   60    8 : slabdata      9      9      0
files_cache          191    275    704   11    2 : tunables   54   27    8 : slabdata     25     25      0
signal_cache         276    315    832    9    2 : tunables   54   27    8 : slabdata     35     35      0
sighand_cache        281    291   2112    3    2 : tunables   24   12    8 : slabdata     97     97      0
task_xstate          206    280    512    8    1 : tunables   54   27    8 : slabdata     35     35      0
task_struct          302    325   1424    5    2 : tunables   24   12    8 : slabdata     65     65      0
cred_jar             712    930    128   30    1 : tunables  120   60    8 : slabdata     31     31      0
anon_vma            3429   3888     24  144    1 : tunables  120   60    8 : slabdata     27     27      0
pid                  313    510    128   30    1 : tunables  120   60    8 : slabdata     17     17      0
idr_layer_cache      173    182    544    7    1 : tunables   54   27    8 : slabdata     26     26      0
size-4194304(DMA)      0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
size-4194304           0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
size-2097152(DMA)      0      0 2097152    1  512 : tunables    1    1    0 : slabdata      0      0      0
size-2097152           0      0 2097152    1  512 : tunables    1    1    0 : slabdata      0      0      0
size-1048576(DMA)      0      0 1048576    1  256 : tunables    1    1    0 : slabdata      0      0      0
size-1048576           0      0 1048576    1  256 : tunables    1    1    0 : slabdata      0      0      0
size-524288(DMA)       0      0 524288    1  128 : tunables    1    1    0 : slabdata      0      0      0
size-524288            0      0 524288    1  128 : tunables    1    1    0 : slabdata      0      0      0
size-262144(DMA)       0      0 262144    1   64 : tunables    1    1    0 : slabdata      0      0      0
size-262144            0      0 262144    1   64 : tunables    1    1    0 : slabdata      0      0      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
size-65536             2      2  65536    1   16 : tunables    8    4    0 : slabdata      2      2      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-32768             9      9  32768    1    8 : tunables    8    4    0 : slabdata      9      9      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
size-16384            15     15  16384    1    4 : tunables    8    4    0 : slabdata     15     15      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    0 : slabdata      0      0      0
size-8192             28     28   8192    1    2 : tunables    8    4    0 : slabdata     28     28      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    8 : slabdata      0      0      0
size-4096            990   1028   4096    1    1 : tunables   24   12    8 : slabdata    990   1028     16
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    8 : slabdata      0      0      0
size-2048            345    354   2048    2    1 : tunables   24   12    8 : slabdata    176    177      0
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    8 : slabdata      0      0      0
size-1024            799    800   1024    4    1 : tunables   54   27    8 : slabdata    200    200      0
size-512(DMA)          0      0    512    8    1 : tunables   54   27    8 : slabdata      0      0      0
size-512             587    632    512    8    1 : tunables   54   27    8 : slabdata     79     79      0
size-256(DMA)          0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
size-256             138    315    256   15    1 : tunables  120   60    8 : slabdata     21     21      0
size-192(DMA)          0      0    192   20    1 : tunables  120   60    8 : slabdata      0      0      0
size-192            1806   2080    192   20    1 : tunables  120   60    8 : slabdata    104    104      0
size-128(DMA)          0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
size-64(DMA)           0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
size-64            22161  29323     64   59    1 : tunables  120   60    8 : slabdata    497    497    264
size-32(DMA)           0      0     32  112    1 : tunables  120   60    8 : slabdata      0      0      0
size-128           11605  13710    128   30    1 : tunables  120   60    8 : slabdata    457    457      0
size-32             4153   4256     32  112    1 : tunables  120   60    8 : slabdata     38     38      0
kmem_cache           164    180    192   20    1 : tunables  120   60    8 : slabdata      9      9      0

-------

[71681.279768] 3w-9xxx: scsi0: AEN: INFO (0x04:0x0033): Migration started:unit=0.
[113178.827374] swapper: page allocation failure. order:0, mode:0x20
[113178.827380] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113178.827382] Call Trace:
[113178.827385]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113178.827397]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113178.827400]  [<ffffffff802a714b>] ? __kmalloc+0xdb/0xe0
[113178.827405]  [<ffffffff805a622d>] ? __alloc_skb+0x6d/0x160
[113178.827408]  [<ffffffff805a6fd7>] ? __netdev_alloc_skb+0x17/0x40
[113178.827413]  [<ffffffff80509e73>] ? e1000_alloc_rx_buffers+0x2b3/0x360
[113178.827417]  [<ffffffff8050a200>] ? e1000_clean_rx_irq+0x260/0x3a0
[113178.827420]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113178.827425]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113178.827429]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113178.827434]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113178.827438]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113178.827442]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113178.827445]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113178.827449]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113178.827451]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113178.827459]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113178.827461] Mem-Info:
[113178.827463] DMA per-cpu:
[113178.827466] CPU    0: hi:    0, btch:   1 usd:   0
[113178.827469] CPU    1: hi:    0, btch:   1 usd:   0
[113178.827471] CPU    2: hi:    0, btch:   1 usd:   0
[113178.827474] CPU    3: hi:    0, btch:   1 usd:   0
[113178.827476] DMA32 per-cpu:
[113178.827478] CPU    0: hi:  186, btch:  31 usd:  28
[113178.827480] CPU    1: hi:  186, btch:  31 usd:  91
[113178.827483] CPU    2: hi:  186, btch:  31 usd:  41
[113178.827485] CPU    3: hi:  186, btch:  31 usd:  82
[113178.827487] Normal per-cpu:
[113178.827489] CPU    0: hi:  186, btch:  31 usd:  87
[113178.827492] CPU    1: hi:  186, btch:  31 usd:  46
[113178.827494] CPU    2: hi:  186, btch:  31 usd: 155
[113178.827497] CPU    3: hi:  186, btch:  31 usd: 224
[113178.827501] Active_anon:108704 active_file:12637 inactive_anon:24517
[113178.827503]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113178.827504]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113178.827509] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113178.827512] lowmem_reserve[]: 0 3246 7980 7980
[113178.827519] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113178.827533] lowmem_reserve[]: 0 0 4734 4734
[113178.827538] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113178.827541] lowmem_reserve[]: 0 0 0 0
[113178.827543] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113178.827551] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113178.827558] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113178.827565] 1761990 total pagecache pages
[113178.827567] 45 pages in swap cache
[113178.827569] Swap cache stats: add 109, delete 64, find 0/2
[113178.827570] Free swap  = 16787392kB
[113178.827571] Total swap = 16787768kB
[113178.828167] 2277376 pages RAM
[113178.828167] 252254 pages reserved
[113178.828167] 1853656 pages shared
[113178.828167] 216669 pages non-shared
[113178.857166] swapper: page allocation failure. order:0, mode:0x20
[113178.857169] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113178.857171] Call Trace:
[113178.857173]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113178.857181]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113178.857183]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113178.857186]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113178.857190]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113178.857192]  [<ffffffff805e841d>] ? tcp_rcv_established+0x3ed/0x940
[113178.857195]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113178.857197]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113178.857200]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113178.857202]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113178.857204]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113178.857208]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113178.857210]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113178.857213]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113178.857216]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113178.857219]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113178.857222]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113178.857225]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113178.857227]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113178.857229]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113178.857231]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113178.857236]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113178.857238] Mem-Info:
[113178.857239] DMA per-cpu:
[113178.857241] CPU    0: hi:    0, btch:   1 usd:   0
[113178.857243] CPU    1: hi:    0, btch:   1 usd:   0
[113178.857245] CPU    2: hi:    0, btch:   1 usd:   0
[113178.857247] CPU    3: hi:    0, btch:   1 usd:   0
[113178.857248] DMA32 per-cpu:
[113178.857250] CPU    0: hi:  186, btch:  31 usd:  28
[113178.857252] CPU    1: hi:  186, btch:  31 usd:  91
[113178.857253] CPU    2: hi:  186, btch:  31 usd:  41
[113178.857255] CPU    3: hi:  186, btch:  31 usd:  82
[113178.857257] Normal per-cpu:
[113178.857258] CPU    0: hi:  186, btch:  31 usd:  87
[113178.857260] CPU    1: hi:  186, btch:  31 usd:  46
[113178.857262] CPU    2: hi:  186, btch:  31 usd: 155
[113178.857263] CPU    3: hi:  186, btch:  31 usd: 224
[113178.857267] Active_anon:108704 active_file:12637 inactive_anon:24517
[113178.857268]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113178.857269]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113178.857273] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113178.857276] lowmem_reserve[]: 0 3246 7980 7980
[113178.857281] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113178.857284] lowmem_reserve[]: 0 0 4734 4734
[113178.857293] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113178.857296] lowmem_reserve[]: 0 0 0 0
[113178.857299] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113178.857307] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113178.857314] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113178.857322] 1761990 total pagecache pages
[113178.857323] 45 pages in swap cache
[113178.857325] Swap cache stats: add 109, delete 64, find 0/2
[113178.857327] Free swap  = 16787392kB
[113178.857328] Total swap = 16787768kB
[113178.858125] 2277376 pages RAM
[113178.858125] 252254 pages reserved
[113178.858125] 1853656 pages shared
[113178.858125] 216669 pages non-shared
[113178.886706] swapper: page allocation failure. order:0, mode:0x20
[113178.886709] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113178.886711] Call Trace:
[113178.886713]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113178.886720]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113178.886723]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113178.886726]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113178.886729]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113178.886732]  [<ffffffff805e87ed>] ? tcp_rcv_established+0x7bd/0x940
[113178.886735]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113178.886737]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113178.886739]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113178.886742]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113178.886744]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113178.886747]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113178.886749]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113178.886753]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113178.886755]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113178.886759]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113178.886762]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113178.886764]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113178.886766]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113178.886769]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113178.886770]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113178.886775]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113178.886777] Mem-Info:
[113178.886778] DMA per-cpu:
[113178.886780] CPU    0: hi:    0, btch:   1 usd:   0
[113178.886782] CPU    1: hi:    0, btch:   1 usd:   0
[113178.886784] CPU    2: hi:    0, btch:   1 usd:   0
[113178.886786] CPU    3: hi:    0, btch:   1 usd:   0
[113178.886787] DMA32 per-cpu:
[113178.886789] CPU    0: hi:  186, btch:  31 usd:  28
[113178.886791] CPU    1: hi:  186, btch:  31 usd:  91
[113178.886792] CPU    2: hi:  186, btch:  31 usd:  41
[113178.886794] CPU    3: hi:  186, btch:  31 usd:  82
[113178.886796] Normal per-cpu:
[113178.886797] CPU    0: hi:  186, btch:  31 usd:  87
[113178.886799] CPU    1: hi:  186, btch:  31 usd:  46
[113178.886801] CPU    2: hi:  186, btch:  31 usd: 155
[113178.886803] CPU    3: hi:  186, btch:  31 usd: 224
[113178.886806] Active_anon:108704 active_file:12637 inactive_anon:24517
[113178.886807]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113178.886808]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113178.886812] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113178.886815] lowmem_reserve[]: 0 3246 7980 7980
[113178.886820] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113178.886823] lowmem_reserve[]: 0 0 4734 4734
[113178.886828] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113178.886831] lowmem_reserve[]: 0 0 0 0
[113178.886834] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113178.886842] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113178.886849] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113178.886857] 1761990 total pagecache pages
[113178.886858] 45 pages in swap cache
[113178.886860] Swap cache stats: add 109, delete 64, find 0/2
[113178.886861] Free swap  = 16787392kB
[113178.886863] Total swap = 16787768kB
[113178.887664] 2277376 pages RAM
[113178.887664] 252254 pages reserved
[113178.887664] 1853656 pages shared
[113178.887664] 216669 pages non-shared
[113178.916232] swapper: page allocation failure. order:0, mode:0x20
[113178.916235] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113178.916237] Call Trace:
[113178.916239]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113178.916246]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113178.916249]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113178.916252]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113178.916255]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113178.916258]  [<ffffffff805e841d>] ? tcp_rcv_established+0x3ed/0x940
[113178.916260]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113178.916262]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113178.916265]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113178.916268]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113178.916270]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113178.916273]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113178.916275]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113178.916279]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113178.916291]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113178.916295]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113178.916298]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113178.916300]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113178.916302]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113178.916305]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113178.916306]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113178.916312]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113178.916313] Mem-Info:
[113178.916314] DMA per-cpu:
[113178.916316] CPU    0: hi:    0, btch:   1 usd:   0
[113178.916318] CPU    1: hi:    0, btch:   1 usd:   0
[113178.916320] CPU    2: hi:    0, btch:   1 usd:   0
[113178.916322] CPU    3: hi:    0, btch:   1 usd:   0
[113178.916323] DMA32 per-cpu:
[113178.916325] CPU    0: hi:  186, btch:  31 usd:  28
[113178.916327] CPU    1: hi:  186, btch:  31 usd:  91
[113178.916328] CPU    2: hi:  186, btch:  31 usd:  41
[113178.916330] CPU    3: hi:  186, btch:  31 usd:  82
[113178.916331] Normal per-cpu:
[113178.916333] CPU    0: hi:  186, btch:  31 usd:  87
[113178.916335] CPU    1: hi:  186, btch:  31 usd:  46
[113178.916337] CPU    2: hi:  186, btch:  31 usd: 155
[113178.916338] CPU    3: hi:  186, btch:  31 usd: 224
[113178.916342] Active_anon:108704 active_file:12637 inactive_anon:24517
[113178.916343]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113178.916344]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113178.916353] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113178.916356] lowmem_reserve[]: 0 3246 7980 7980
[113178.916361] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113178.916364] lowmem_reserve[]: 0 0 4734 4734
[113178.916369] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113178.916372] lowmem_reserve[]: 0 0 0 0
[113178.916375] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113178.916383] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113178.916390] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113178.916398] 1761990 total pagecache pages
[113178.916400] 45 pages in swap cache
[113178.916401] Swap cache stats: add 109, delete 64, find 0/2
[113178.916403] Free swap  = 16787392kB
[113178.916404] Total swap = 16787768kB
[113178.917188] 2277376 pages RAM
[113178.917188] 252254 pages reserved
[113178.917188] 1853656 pages shared
[113178.917188] 216669 pages non-shared
[113178.945846] swapper: page allocation failure. order:0, mode:0x20
[113178.945849] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113178.945851] Call Trace:
[113178.945853]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113178.945860]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113178.945863]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113178.945866]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113178.945869]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113178.945872]  [<ffffffff805e87ed>] ? tcp_rcv_established+0x7bd/0x940
[113178.945874]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113178.945877]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113178.945879]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113178.945882]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113178.945884]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113178.945887]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113178.945890]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113178.945893]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113178.945896]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113178.945899]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113178.945902]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113178.945904]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113178.945906]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113178.945909]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113178.945910]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113178.945916]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113178.945917] Mem-Info:
[113178.945919] DMA per-cpu:
[113178.945920] CPU    0: hi:    0, btch:   1 usd:   0
[113178.945922] CPU    1: hi:    0, btch:   1 usd:   0
[113178.945924] CPU    2: hi:    0, btch:   1 usd:   0
[113178.945926] CPU    3: hi:    0, btch:   1 usd:   0
[113178.945927] DMA32 per-cpu:
[113178.945929] CPU    0: hi:  186, btch:  31 usd:  28
[113178.945931] CPU    1: hi:  186, btch:  31 usd:  91
[113178.945932] CPU    2: hi:  186, btch:  31 usd:  41
[113178.945934] CPU    3: hi:  186, btch:  31 usd:  82
[113178.945936] Normal per-cpu:
[113178.945937] CPU    0: hi:  186, btch:  31 usd:  87
[113178.945939] CPU    1: hi:  186, btch:  31 usd:  46
[113178.945941] CPU    2: hi:  186, btch:  31 usd: 155
[113178.945942] CPU    3: hi:  186, btch:  31 usd: 224
[113178.945946] Active_anon:108704 active_file:12637 inactive_anon:24517
[113178.945947]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113178.945948]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113178.945952] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113178.945955] lowmem_reserve[]: 0 3246 7980 7980
[113178.945960] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113178.945963] lowmem_reserve[]: 0 0 4734 4734
[113178.945967] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113178.945971] lowmem_reserve[]: 0 0 0 0
[113178.945974] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113178.945982] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113178.945989] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113178.945997] 1761990 total pagecache pages
[113178.945998] 45 pages in swap cache
[113178.946000] Swap cache stats: add 109, delete 64, find 0/2
[113178.946001] Free swap  = 16787392kB
[113178.946003] Total swap = 16787768kB
[113178.946794] 2277376 pages RAM
[113178.946794] 252254 pages reserved
[113178.946794] 1853656 pages shared
[113178.946794] 216669 pages non-shared
[113178.975233] swapper: page allocation failure. order:0, mode:0x20
[113178.975237] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113178.975238] Call Trace:
[113178.975240]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113178.975248]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113178.975250]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113178.975253]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113178.975257]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113178.975259]  [<ffffffff805e841d>] ? tcp_rcv_established+0x3ed/0x940
[113178.975262]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113178.975264]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113178.975267]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113178.975269]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113178.975271]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113178.975274]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113178.975277]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113178.975280]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113178.975292]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113178.975295]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113178.975298]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113178.975300]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113178.975303]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113178.975305]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113178.975306]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113178.975312]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113178.975313] Mem-Info:
[113178.975315] DMA per-cpu:
[113178.975317] CPU    0: hi:    0, btch:   1 usd:   0
[113178.975318] CPU    1: hi:    0, btch:   1 usd:   0
[113178.975320] CPU    2: hi:    0, btch:   1 usd:   0
[113178.975322] CPU    3: hi:    0, btch:   1 usd:   0
[113178.975323] DMA32 per-cpu:
[113178.975325] CPU    0: hi:  186, btch:  31 usd:  28
[113178.975327] CPU    1: hi:  186, btch:  31 usd:  91
[113178.975329] CPU    2: hi:  186, btch:  31 usd:  41
[113178.975330] CPU    3: hi:  186, btch:  31 usd:  82
[113178.975332] Normal per-cpu:
[113178.975333] CPU    0: hi:  186, btch:  31 usd:  87
[113178.975335] CPU    1: hi:  186, btch:  31 usd:  46
[113178.975337] CPU    2: hi:  186, btch:  31 usd: 155
[113178.975339] CPU    3: hi:  186, btch:  31 usd: 224
[113178.975342] Active_anon:108704 active_file:12637 inactive_anon:24517
[113178.975351]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113178.975353]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113178.975356] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113178.975359] lowmem_reserve[]: 0 3246 7980 7980
[113178.975364] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113178.975367] lowmem_reserve[]: 0 0 4734 4734
[113178.975372] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113178.975375] lowmem_reserve[]: 0 0 0 0
[113178.975378] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113178.975386] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113178.975394] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113178.975401] 1761990 total pagecache pages
[113178.975403] 45 pages in swap cache
[113178.975405] Swap cache stats: add 109, delete 64, find 0/2
[113178.975406] Free swap  = 16787392kB
[113178.975407] Total swap = 16787768kB
[113178.976207] 2277376 pages RAM
[113178.976207] 252254 pages reserved
[113178.976207] 1853656 pages shared
[113178.976207] 216669 pages non-shared
[113179.004708] swapper: page allocation failure. order:0, mode:0x20
[113179.004711] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113179.004713] Call Trace:
[113179.004715]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113179.004722]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113179.004725]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113179.004728]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113179.004731]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113179.004734]  [<ffffffff805e87ed>] ? tcp_rcv_established+0x7bd/0x940
[113179.004736]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113179.004738]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113179.004741]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113179.004743]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113179.004745]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113179.004749]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113179.004751]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113179.004754]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113179.004757]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113179.004760]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113179.004763]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113179.004765]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113179.004767]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113179.004770]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113179.004771]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113179.004777]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113179.004778] Mem-Info:
[113179.004780] DMA per-cpu:
[113179.004781] CPU    0: hi:    0, btch:   1 usd:   0
[113179.004783] CPU    1: hi:    0, btch:   1 usd:   0
[113179.004785] CPU    2: hi:    0, btch:   1 usd:   0
[113179.004787] CPU    3: hi:    0, btch:   1 usd:   0
[113179.004788] DMA32 per-cpu:
[113179.004790] CPU    0: hi:  186, btch:  31 usd:  28
[113179.004792] CPU    1: hi:  186, btch:  31 usd:  91
[113179.004793] CPU    2: hi:  186, btch:  31 usd:  41
[113179.004795] CPU    3: hi:  186, btch:  31 usd:  82
[113179.004796] Normal per-cpu:
[113179.004798] CPU    0: hi:  186, btch:  31 usd:  87
[113179.004800] CPU    1: hi:  186, btch:  31 usd:  46
[113179.004802] CPU    2: hi:  186, btch:  31 usd: 155
[113179.004803] CPU    3: hi:  186, btch:  31 usd: 224
[113179.004807] Active_anon:108704 active_file:12637 inactive_anon:24517
[113179.004808]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113179.004809]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113179.004813] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113179.004815] lowmem_reserve[]: 0 3246 7980 7980
[113179.004820] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113179.004824] lowmem_reserve[]: 0 0 4734 4734
[113179.004828] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113179.004832] lowmem_reserve[]: 0 0 0 0
[113179.004835] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113179.004842] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113179.004850] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113179.004857] 1761990 total pagecache pages
[113179.004859] 45 pages in swap cache
[113179.004861] Swap cache stats: add 109, delete 64, find 0/2
[113179.004862] Free swap  = 16787392kB
[113179.004863] Total swap = 16787768kB
[113179.005668] 2277376 pages RAM
[113179.005668] 252254 pages reserved
[113179.005668] 1853656 pages shared
[113179.005668] 216669 pages non-shared
[113179.034436] swapper: page allocation failure. order:0, mode:0x20
[113179.034439] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113179.034441] Call Trace:
[113179.034442]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113179.034450]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113179.034453]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113179.034456]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113179.034459]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113179.034462]  [<ffffffff805e841d>] ? tcp_rcv_established+0x3ed/0x940
[113179.034464]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113179.034466]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113179.034469]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113179.034471]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113179.034473]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113179.034476]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113179.034488]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113179.034491]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113179.034494]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113179.034497]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113179.034500]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113179.034502]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113179.034504]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113179.034507]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113179.034508]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113179.034513]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113179.034515] Mem-Info:
[113179.034516] DMA per-cpu:
[113179.034518] CPU    0: hi:    0, btch:   1 usd:   0
[113179.034520] CPU    1: hi:    0, btch:   1 usd:   0
[113179.034522] CPU    2: hi:    0, btch:   1 usd:   0
[113179.034524] CPU    3: hi:    0, btch:   1 usd:   0
[113179.034525] DMA32 per-cpu:
[113179.034526] CPU    0: hi:  186, btch:  31 usd:  28
[113179.034528] CPU    1: hi:  186, btch:  31 usd:  91
[113179.034530] CPU    2: hi:  186, btch:  31 usd:  41
[113179.034532] CPU    3: hi:  186, btch:  31 usd:  82
[113179.034533] Normal per-cpu:
[113179.034535] CPU    0: hi:  186, btch:  31 usd:  87
[113179.034536] CPU    1: hi:  186, btch:  31 usd:  46
[113179.034538] CPU    2: hi:  186, btch:  31 usd: 155
[113179.034540] CPU    3: hi:  186, btch:  31 usd: 224
[113179.034543] Active_anon:108704 active_file:12637 inactive_anon:24517
[113179.034544]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113179.034546]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113179.034549] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113179.034552] lowmem_reserve[]: 0 3246 7980 7980
[113179.034557] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113179.034560] lowmem_reserve[]: 0 0 4734 4734
[113179.034565] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113179.034568] lowmem_reserve[]: 0 0 0 0
[113179.034571] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113179.034579] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113179.034586] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113179.034594] 1761990 total pagecache pages
[113179.034596] 45 pages in swap cache
[113179.034597] Swap cache stats: add 109, delete 64, find 0/2
[113179.034599] Free swap  = 16787392kB
[113179.034600] Total swap = 16787768kB
[113179.035359] 2277376 pages RAM
[113179.035359] 252254 pages reserved
[113179.035359] 1853656 pages shared
[113179.035359] 216669 pages non-shared
[113179.063881] swapper: page allocation failure. order:0, mode:0x20
[113179.063885] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113179.063887] Call Trace:
[113179.063888]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113179.063896]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113179.063899]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113179.063902]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113179.063905]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113179.063907]  [<ffffffff805e87ed>] ? tcp_rcv_established+0x7bd/0x940
[113179.063910]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113179.063912]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113179.063915]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113179.063917]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113179.063919]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113179.063922]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113179.063925]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113179.063928]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113179.063931]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113179.063934]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113179.063937]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113179.063939]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113179.063941]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113179.063944]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113179.063945]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113179.063950]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113179.063952] Mem-Info:
[113179.063953] DMA per-cpu:
[113179.063955] CPU    0: hi:    0, btch:   1 usd:   0
[113179.063957] CPU    1: hi:    0, btch:   1 usd:   0
[113179.063959] CPU    2: hi:    0, btch:   1 usd:   0
[113179.063960] CPU    3: hi:    0, btch:   1 usd:   0
[113179.063962] DMA32 per-cpu:
[113179.063963] CPU    0: hi:  186, btch:  31 usd:  28
[113179.063965] CPU    1: hi:  186, btch:  31 usd:  91
[113179.063967] CPU    2: hi:  186, btch:  31 usd:  41
[113179.063969] CPU    3: hi:  186, btch:  31 usd:  82
[113179.063970] Normal per-cpu:
[113179.063971] CPU    0: hi:  186, btch:  31 usd:  87
[113179.063973] CPU    1: hi:  186, btch:  31 usd:  46
[113179.063975] CPU    2: hi:  186, btch:  31 usd: 155
[113179.063977] CPU    3: hi:  186, btch:  31 usd: 224
[113179.063980] Active_anon:108704 active_file:12637 inactive_anon:24517
[113179.063981]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113179.063982]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113179.063986] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113179.063989] lowmem_reserve[]: 0 3246 7980 7980
[113179.063994] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113179.063997] lowmem_reserve[]: 0 0 4734 4734
[113179.064002] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113179.064005] lowmem_reserve[]: 0 0 0 0
[113179.064008] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113179.064015] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113179.064023] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113179.064030] 1761990 total pagecache pages
[113179.064042] 45 pages in swap cache
[113179.064043] Swap cache stats: add 109, delete 64, find 0/2
[113179.064045] Free swap  = 16787392kB
[113179.064046] Total swap = 16787768kB
[113179.064842] 2277376 pages RAM
[113179.064842] 252254 pages reserved
[113179.064842] 1853656 pages shared
[113179.064842] 216669 pages non-shared
[113179.093224] swapper: page allocation failure. order:0, mode:0x20
[113179.093227] Pid: 0, comm: swapper Not tainted 2.6.30.1 #1
[113179.093228] Call Trace:
[113179.093230]  <IRQ>  [<ffffffff80284b3d>] ? __alloc_pages_internal+0x3dd/0x4e0
[113179.093238]  [<ffffffff802a6dd7>] ? cache_alloc_refill+0x2d7/0x570
[113179.093240]  [<ffffffff802a71dd>] ? kmem_cache_alloc+0x8d/0xa0
[113179.093243]  [<ffffffff805a6209>] ? __alloc_skb+0x49/0x160
[113179.093246]  [<ffffffff805ea9b6>] ? tcp_send_ack+0x26/0x120
[113179.093249]  [<ffffffff805e87ed>] ? tcp_rcv_established+0x7bd/0x940
[113179.093252]  [<ffffffff805efc8d>] ? tcp_v4_do_rcv+0xdd/0x210
[113179.093254]  [<ffffffff805f0446>] ? tcp_v4_rcv+0x686/0x750
[113179.093256]  [<ffffffff805d24ac>] ? ip_local_deliver_finish+0x8c/0x170
[113179.093259]  [<ffffffff805d1fa1>] ? ip_rcv_finish+0x191/0x330
[113179.093261]  [<ffffffff805d2387>] ? ip_rcv+0x247/0x2e0
[113179.093264]  [<ffffffff8050a0b4>] ? e1000_clean_rx_irq+0x114/0x3a0
[113179.093266]  [<ffffffff8050be9b>] ? e1000_clean+0x7b/0x2b0
[113179.093270]  [<ffffffff8027006b>] ? getnstimeofday+0x5b/0xe0
[113179.093272]  [<ffffffff805ab033>] ? net_rx_action+0x83/0x120
[113179.093276]  [<ffffffff80258abb>] ? __do_softirq+0x7b/0x110
[113179.093278]  [<ffffffff8022d7fc>] ? call_softirq+0x1c/0x30
[113179.093281]  [<ffffffff8022f4e5>] ? do_softirq+0x35/0x70
[113179.093283]  [<ffffffff8022eca5>] ? do_IRQ+0x85/0xf0
[113179.093292]  [<ffffffff8022d0d3>] ? ret_from_intr+0x0/0xa
[113179.093293]  <EOI>  [<ffffffff80233ec7>] ? mwait_idle+0x77/0x80
[113179.093299]  [<ffffffff8022ba90>] ? cpu_idle+0x60/0xa0
[113179.093300] Mem-Info:
[113179.093301] DMA per-cpu:
[113179.093303] CPU    0: hi:    0, btch:   1 usd:   0
[113179.093305] CPU    1: hi:    0, btch:   1 usd:   0
[113179.093307] CPU    2: hi:    0, btch:   1 usd:   0
[113179.093309] CPU    3: hi:    0, btch:   1 usd:   0
[113179.093310] DMA32 per-cpu:
[113179.093311] CPU    0: hi:  186, btch:  31 usd:  28
[113179.093313] CPU    1: hi:  186, btch:  31 usd:  91
[113179.093315] CPU    2: hi:  186, btch:  31 usd:  41
[113179.093317] CPU    3: hi:  186, btch:  31 usd:  82
[113179.093318] Normal per-cpu:
[113179.093320] CPU    0: hi:  186, btch:  31 usd:  87
[113179.093321] CPU    1: hi:  186, btch:  31 usd:  46
[113179.093323] CPU    2: hi:  186, btch:  31 usd: 155
[113179.093325] CPU    3: hi:  186, btch:  31 usd: 224
[113179.093328] Active_anon:108704 active_file:12637 inactive_anon:24517
[113179.093329]  inactive_file:1749244 unevictable:0 dirty:450860 writeback:16983 unstable:0
[113179.093331]  free:8689 slab:76567 mapped:8257 pagetables:5094 bounce:0
[113179.093334] DMA free:9692kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB present:8668kB pages_scanned:0 all_unreclaimable? yes
[113179.093337] lowmem_reserve[]: 0 3246 7980 7980
[113179.093342] DMA32 free:21420kB min:6656kB low:8320kB high:9984kB active_anon:72660kB inactive_anon:19824kB active_file:17956kB inactive_file:2750632kB unevictable:0kB present:3324312kB pages_scanned:0 all_unreclaimable? no
[113179.093345] lowmem_reserve[]: 0 0 4734 4734
[113179.093353] Normal free:3644kB min:9708kB low:12132kB high:14560kB active_anon:362156kB inactive_anon:78244kB active_file:32592kB inactive_file:4246344kB unevictable:0kB present:4848000kB pages_scanned:0 all_unreclaimable? no
[113179.093356] lowmem_reserve[]: 0 0 0 0
[113179.093359] DMA: 3*4kB 4*8kB 3*16kB 4*32kB 0*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 1*2048kB 1*4096kB = 9692kB
[113179.093367] DMA32: 3263*4kB 1*8kB 1*16kB 1*32kB 1*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 1*4096kB = 21236kB
[113179.093374] Normal: 0*4kB 1*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3592kB
[113179.093382] 1761990 total pagecache pages
[113179.093384] 45 pages in swap cache
[113179.093385] Swap cache stats: add 109, delete 64, find 0/2
[113179.093387] Free swap  = 16787392kB
[113179.093388] Total swap = 16787768kB
[113179.094199] 2277376 pages RAM
[113179.094199] 252254 pages reserved
[113179.094199] 1853656 pages shared
[113179.094199] 216669 pages non-shared

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
