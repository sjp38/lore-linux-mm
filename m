In-Reply-To: <20070915035228.8b8a7d6d.akpm@linux-foundation.org>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk> <1189850897.21778.301.camel@twins> <20070915035228.8b8a7d6d.akpm@linux-foundation.org>
Mime-Version: 1.0 (Apple Message framework v752.3)
Content-Type: multipart/mixed; boundary=Apple-Mail-7--870235608
Message-Id: <13126578-A4F8-43EA-9B0D-A3BCBFB41FEC@cam.ac.uk>
From: Anton Altaparmakov <aia21@cam.ac.uk>
Subject: Re: VM/VFS bug with large amount of memory and file systems?
Date: Mon, 17 Sep 2007 15:04:05 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

--Apple-Mail-7--870235608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	delsp=yes;
	format=flowed

On 15 Sep 2007, at 11:52, Andrew Morton wrote:
> On Sat, 15 Sep 2007 12:08:17 +0200 Peter Zijlstra  
> <peterz@infradead.org> wrote:
>> Anyway, looks like all of zone_normal is pinned in kernel  
>> allocations:
>>
>>> Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB  
>>> high: 5616kB active:0kB inactive:3160kB present:894080kB  
>>> pages_scanned:5336 all_unreclaimable? yes
>>
>> Out of the 870 odd mb only 3 is on the lru.
>>
>> Would be grand it you could have a look at slabinfo and the like.
>
> Definitely.
>
>>> Sep 13 15:31:25 escabot free:1090395 slab:198893 mapped:988
>>> pagetables:129 bounce:0
>
> 814,665,728 bytes of slab.

Marc emailed me the contents of /proc/ 
{slabinfo,meminfo,vmstat,zoneinfo} taken just a few seconds before  
the machine panic()ed due to running OOM completely...  They files  
are attached this time rather than inlined so people don't complain  
about line wrapping!  (No doubt people will not complain about them  
being attached!  )-:)

If I read it correctly it appears all of low memory is eaten up by  
buffer_heads.

<quote>
# name            <active_objs> <num_objs> <objsize> <objperslab>  
<pagesperslab>
: tunables <limit> <batchcount> <sharedfactor> : slabdata  
<active_slabs> <num_s
labs> <sharedavail>
buffer_head       12569528 12569535     56   67    1 : tunables   
120   60    8 :
slabdata 187605 187605      0
</quote>

That is 671MiB of low memory in buffer_heads.

But why is the kernel not reclaiming them by getting rid of the page  
cache pages they are attached to or even leaving the pages around but  
killing their buffers?

I don't think I am doing anything in NTFS to cause this problem to  
happen...  Other than using buffer heads for my page cache pages that  
is but that is hardly a crime!  /-;

Best regards,

	Anton
-- 
Anton Altaparmakov <aia21 at cam.ac.uk> (replace at with @)
Unix Support, Computing Service, University of Cambridge, CB2 3QH, UK
Linux NTFS maintainer, http://www.linux-ntfs.org/


--Apple-Mail-7--870235608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	x-unix-mode=0644;
	name=slabinfo.txt
Content-Disposition: attachment;
	filename=slabinfo.txt

slabinfo - version: 2.1
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
jbd_4k                 0      0   4096    1    1 : tunables   24   12    8 : slabdata      0      0      0
scsi_cmd_cache        48     48    320   12    1 : tunables   54   27    8 : slabdata      4      4      0
qla2xxx_srbs         283    330    128   30    1 : tunables  120   60    8 : slabdata     11     11      0
rpc_buffers            8      8   2048    2    1 : tunables   24   12    8 : slabdata      4      4      0
rpc_tasks              8     20    192   20    1 : tunables  120   60    8 : slabdata      1      1      0
rpc_inode_cache        0      0    448    9    1 : tunables   54   27    8 : slabdata      0      0      0
UNIX                   4     27    448    9    1 : tunables   54   27    8 : slabdata      3      3      0
flow_cache             0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
cfq_ioc_pool           0      0     88   44    1 : tunables  120   60    8 : slabdata      0      0      0
cfq_pool               0      0     96   40    1 : tunables  120   60    8 : slabdata      0      0      0
mqueue_inode_cache      1      7    576    7    1 : tunables   54   27    8 : slabdata      1      1      0
xfs_chashlist          0      0     24  145    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_ili                0      0    140   28    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_inode              0      0    448    9    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_efi_item           0      0    260   15    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_efd_item           0      0    260   15    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_buf_item           0      0    148   26    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_acl                0      0    304   13    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_ifork              0      0     56   67    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_dabuf              0      0     16  203    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_da_state           0      0    336   11    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_trans              0      0    636    6    1 : tunables   54   27    8 : slabdata      0      0      0
xfs_btree_cur          0      0    140   28    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_bmap_free_item      0      0     16  203    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_buf                0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
xfs_ioend             32     67     56   67    1 : tunables  120   60    8 : slabdata      1      1      0
xfs_vnode              0      0    384   10    1 : tunables   54   27    8 : slabdata      0      0      0
udf_inode_cache        0      0    404    9    1 : tunables   54   27    8 : slabdata      0      0      0
ntfs_big_inode_cache     23     28    576    7    1 : tunables   54   27    8 : slabdata      4      4      0
ntfs_inode_cache       0      0    184   21    1 : tunables  120   60    8 : slabdata      0      0      0
ntfs_name_cache        0      0    512    8    1 : tunables   54   27    8 : slabdata      0      0      0
ntfs_attr_ctx_cache      0      0     32  113    1 : tunables  120   60    8 : slabdata      0      0      0
ntfs_index_ctx_cache      0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
nfs_write_data        36     36    448    9    1 : tunables   54   27    8 : slabdata      4      4      0
nfs_read_data         32     36    448    9    1 : tunables   54   27    8 : slabdata      4      4      0
nfs_inode_cache        0      0    612    6    1 : tunables   54   27    8 : slabdata      0      0      0
nfs_page               0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
isofs_inode_cache      0      0    376   10    1 : tunables   54   27    8 : slabdata      0      0      0
fat_inode_cache        0      0    408    9    1 : tunables   54   27    8 : slabdata      0      0      0
fat_cache              0      0     20  169    1 : tunables  120   60    8 : slabdata      0      0      0
ext2_inode_cache       2     16    464    8    1 : tunables   54   27    8 : slabdata      2      2      0
journal_handle        32    169     20  169    1 : tunables  120   60    8 : slabdata      1      1      0
journal_head          40     72     52   72    1 : tunables  120   60    8 : slabdata      1      1      0
revoke_table           4    254     12  254    1 : tunables  120   60    8 : slabdata      1      1      0
revoke_record          0      0     16  203    1 : tunables  120   60    8 : slabdata      0      0      0
ext3_inode_cache     324    368    500    8    1 : tunables   54   27    8 : slabdata     46     46      0
ext3_xattr             0      0     48   78    1 : tunables  120   60    8 : slabdata      0      0      0
reiser_inode_cache      0      0    452    8    1 : tunables   54   27    8 : slabdata      0      0      0
dnotify_cache          0      0     20  169    1 : tunables  120   60    8 : slabdata      0      0      0
eventpoll_pwq          0      0     36  101    1 : tunables  120   60    8 : slabdata      0      0      0
eventpoll_epi          0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
inotify_event_cache      0      0     28  127    1 : tunables  120   60    8 : slabdata      0      0      0
inotify_watch_cache      1     92     40   92    1 : tunables  120   60    8 : slabdata      1      1      0
kioctx                 0      0    192   20    1 : tunables  120   60    8 : slabdata      0      0      0
kiocb                  0      0    192   20    1 : tunables  120   60    8 : slabdata      0      0      0
fasync_cache           0      0     16  203    1 : tunables  120   60    8 : slabdata      0      0      0
shmem_inode_cache   1443   1476    448    9    1 : tunables   54   27    8 : slabdata    164    164      0
posix_timers_cache      0      0     96   40    1 : tunables  120   60    8 : slabdata      0      0      0
uid_cache              0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
UDP-Lite               0      0    576    7    1 : tunables   54   27    8 : slabdata      0      0      0
tcp_bind_bucket        1    203     16  203    1 : tunables  120   60    8 : slabdata      1      1      0
inet_peer_cache        0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
secpath_cache          0      0     32  113    1 : tunables  120   60    8 : slabdata      0      0      0
xfrm_dst_cache         0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
ip_fib_alias          14    113     32  113    1 : tunables  120   60    8 : slabdata      1      1      0
ip_fib_hash           14    113     32  113    1 : tunables  120   60    8 : slabdata      1      1      0
ip_dst_cache          10     30    256   15    1 : tunables  120   60    8 : slabdata      2      2      0
arp_cache              3     20    192   20    1 : tunables  120   60    8 : slabdata      1      1      0
RAW                    5      7    512    7    1 : tunables   54   27    8 : slabdata      1      1      0
UDP                    0      0    576    7    1 : tunables   54   27    8 : slabdata      0      0      0
tw_sock_TCP            0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
request_sock_TCP       0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
TCP                    4      7   1152    7    2 : tunables   24   12    8 : slabdata      1      1      0
sgpool-128            39     42   2560    3    2 : tunables   24   12    8 : slabdata     14     14      0
sgpool-64             44     51   1280    3    1 : tunables   24   12    8 : slabdata     16     17      0
sgpool-32             34     54    640    6    1 : tunables   54   27    8 : slabdata      8      9      0
sgpool-16             57     60    320   12    1 : tunables   54   27    8 : slabdata      5      5      0
sgpool-8              57     80    192   20    1 : tunables  120   60    8 : slabdata      3      4      0
scsi_io_context        0      0    104   37    1 : tunables  120   60    8 : slabdata      0      0      0
blkdev_ioc            31    127     28  127    1 : tunables  120   60    8 : slabdata      1      1      0
blkdev_queue          32     32    956    4    1 : tunables   54   27    8 : slabdata      8      8      0
blkdev_requests      100    126    184   21    1 : tunables  120   60    8 : slabdata      6      6      0
biovec-256             7      8   3072    2    2 : tunables   24   12    8 : slabdata      4      4      0
biovec-128             7     10   1536    5    2 : tunables   24   12    8 : slabdata      2      2      0
biovec-64              7     10    768    5    1 : tunables   54   27    8 : slabdata      2      2      0
biovec-16              7     20    192   20    1 : tunables  120   60    8 : slabdata      1      1      0
biovec-4               7     59     64   59    1 : tunables  120   60    8 : slabdata      1      1      0
biovec-1             596    812     16  203    1 : tunables  120   60    8 : slabdata      4      4      0
bio                  862   1110    128   30    1 : tunables  120   60    8 : slabdata     37     37      0
sock_inode_cache      23     45    448    9    1 : tunables   54   27    8 : slabdata      5      5      0
skbuff_fclone_cache     24     24    320   12    1 : tunables   54   27    8 : slabdata      2      2      0
skbuff_head_cache    461    580    192   20    1 : tunables  120   60    8 : slabdata     29     29      0
file_lock_cache       15     39    100   39    1 : tunables  120   60    8 : slabdata      1      1      0
Acpi-Operand        1107   1196     40   92    1 : tunables  120   60    8 : slabdata     13     13      0
Acpi-ParseExt          0      0     44   84    1 : tunables  120   60    8 : slabdata      0      0      0
Acpi-Parse             0      0     28  127    1 : tunables  120   60    8 : slabdata      0      0      0
Acpi-State             0      0     44   84    1 : tunables  120   60    8 : slabdata      0      0      0
Acpi-Namespace       797    845     20  169    1 : tunables  120   60    8 : slabdata      5      5      0
proc_inode_cache     418    418    364   11    1 : tunables   54   27    8 : slabdata     38     38      0
sigqueue               0      0    144   27    1 : tunables  120   60    8 : slabdata      0      0      0
radix_tree_node    25298  25298    288   13    1 : tunables   54   27    8 : slabdata   1946   1946      0
bdev_cache            10     21    512    7    1 : tunables   54   27    8 : slabdata      3      3      0
sysfs_dir_cache     7276   7308     44   84    1 : tunables  120   60    8 : slabdata     87     87      0
mnt_cache             25     90    128   30    1 : tunables  120   60    8 : slabdata      3      3      0
inode_cache         1968   2057    348   11    1 : tunables   54   27    8 : slabdata    187    187      0
dentry_cache        4266   5452    136   29    1 : tunables  120   60    8 : slabdata    188    188      0
filp                 413    740    192   20    1 : tunables  120   60    8 : slabdata     37     37      0
names_cache            3      3   4096    1    1 : tunables   24   12    8 : slabdata      3      3      0
idr_layer_cache       98    116    136   29    1 : tunables  120   60    8 : slabdata      4      4      0
buffer_head       12569528 12569535     56   67    1 : tunables  120   60    8 : slabdata 187605 187605      0
mm_struct             63     63    512    7    1 : tunables   54   27    8 : slabdata      9      9      0
vm_area_struct       761   1716     88   44    1 : tunables  120   60    8 : slabdata     39     39      0
fs_cache              54    177     64   59    1 : tunables  120   60    8 : slabdata      3      3      0
files_cache           55     90    256   15    1 : tunables  120   60    8 : slabdata      6      6      0
signal_cache         100    110    384   10    1 : tunables   54   27    8 : slabdata     11     11      0
sighand_cache         81     81   1344    3    1 : tunables   24   12    8 : slabdata     27     27      0
task_struct           87     87   1296    3    1 : tunables   24   12    8 : slabdata     29     29      0
anon_vma             359    609     16  203    1 : tunables  120   60    8 : slabdata      3      3      0
pgd                  112    226     32  113    1 : tunables  120   60    8 : slabdata      2      2      0
pmd                   72     72   4096    1    1 : tunables   24   12    8 : slabdata     72     72      0
pid                   97    505     36  101    1 : tunables  120   60    8 : slabdata      5      5      0
size-131072(DMA)       0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-131072            0      0 131072    1   32 : tunables    8    4    0 : slabdata      0      0      0
size-65536(DMA)        0      0  65536    1   16 : tunables    8    4    0 : slabdata      0      0      0
size-65536             1      1  65536    1   16 : tunables    8    4    0 : slabdata      1      1      0
size-32768(DMA)        0      0  32768    1    8 : tunables    8    4    0 : slabdata      0      0      0
size-32768             5      5  32768    1    8 : tunables    8    4    0 : slabdata      5      5      0
size-16384(DMA)        0      0  16384    1    4 : tunables    8    4    0 : slabdata      0      0      0
size-16384             4      4  16384    1    4 : tunables    8    4    0 : slabdata      4      4      0
size-8192(DMA)         0      0   8192    1    2 : tunables    8    4    0 : slabdata      0      0      0
size-8192             84     84   8192    1    2 : tunables    8    4    0 : slabdata     84     84      0
size-4096(DMA)         0      0   4096    1    1 : tunables   24   12    8 : slabdata      0      0      0
size-4096             36     36   4096    1    1 : tunables   24   12    8 : slabdata     36     36      0
size-2048(DMA)         0      0   2048    2    1 : tunables   24   12    8 : slabdata      0      0      0
size-2048            575    580   2048    2    1 : tunables   24   12    8 : slabdata    290    290      0
size-1024(DMA)         0      0   1024    4    1 : tunables   54   27    8 : slabdata      0      0      0
size-1024            196    196   1024    4    1 : tunables   54   27    8 : slabdata     49     49      0
size-512(DMA)          0      0    512    8    1 : tunables   54   27    8 : slabdata      0      0      0
size-512            1096   1208    512    8    1 : tunables   54   27    8 : slabdata    151    151      0
size-256(DMA)          0      0    256   15    1 : tunables  120   60    8 : slabdata      0      0      0
size-256             256    270    256   15    1 : tunables  120   60    8 : slabdata     18     18      0
size-192(DMA)          0      0    192   20    1 : tunables  120   60    8 : slabdata      0      0      0
size-192             140    140    192   20    1 : tunables  120   60    8 : slabdata      7      7      0
size-128(DMA)          0      0    128   30    1 : tunables  120   60    8 : slabdata      0      0      0
size-128             700    780    128   30    1 : tunables  120   60    8 : slabdata     26     26      0
size-64(DMA)           0      0     64   59    1 : tunables  120   60    8 : slabdata      0      0      0
size-32(DMA)           0      0     32  113    1 : tunables  120   60    8 : slabdata      0      0      0
size-64             2388   2478     64   59    1 : tunables  120   60    8 : slabdata     42     42      0
size-32             4299   5198     32  113    1 : tunables  120   60    8 : slabdata     46     46      0
kmem_cache           149    180    128   30    1 : tunables  120   60    8 : slabdata      6      6      0

--Apple-Mail-7--870235608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed



--Apple-Mail-7--870235608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	x-unix-mode=0644;
	name=meminfo.txt
Content-Disposition: attachment;
	filename=meminfo.txt

MemTotal:     12306460 kB
MemFree:       5228260 kB
Buffers:          3968 kB
Cached:        6293928 kB
SwapCached:          0 kB
Active:          10756 kB
Inactive:      6291416 kB
HighTotal:    11493340 kB
HighFree:      5191416 kB
LowTotal:       813120 kB
LowFree:         36844 kB
SwapTotal:     2008116 kB
SwapFree:      2008116 kB
Dirty:               4 kB
Writeback:           0 kB
AnonPages:        4328 kB
Mapped:           3100 kB
Slab:           766572 kB
SReclaimable:   752292 kB
SUnreclaim:      14280 kB
PageTables:        320 kB
NFS_Unstable:        0 kB
Bounce:              0 kB
CommitLimit:   8161344 kB
Committed_AS:    19520 kB
VmallocTotal:   118776 kB
VmallocUsed:      3028 kB
VmallocChunk:   115384 kB

--Apple-Mail-7--870235608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	x-unix-mode=0644;
	name=vmstat.txt
Content-Disposition: attachment;
	filename=vmstat.txt

nr_free_pages 1307065
nr_active 1572854
nr_inactive 2689
nr_anon_pages 1082
nr_mapped 775
nr_file_pages 1574474
nr_dirty 1
nr_writeback 0
nr_slab_reclaimable 188073
nr_slab_unreclaimable 3570
nr_page_table_pages 80
nr_unstable 0
nr_bounce 0
nr_vmscan_write 10
pgpgin 12847034
pgpgout 3501
pswpin 0
pswpout 0
pgalloc_dma 1944
pgalloc_normal 465694
pgalloc_high 3432418
pgfree 5207478
pgactivate 17439
pgdeactivate 13952
pgfault 1211997
pgmajfault 695
pgrefill_dma 0
pgrefill_normal 13952
pgrefill_high 0
pgsteal_dma 0
pgsteal_normal 1074
pgsteal_high 0
pgscan_kswapd_dma 0
pgscan_kswapd_normal 14688
pgscan_kswapd_high 0
pgscan_direct_dma 0
pgscan_direct_normal 3808
pgscan_direct_high 0
pginodesteal 0
slabs_scanned 8448
kswapd_steal 1007
kswapd_inodesteal 1637276
pageoutrun 609
allocstall 271
pgrotated 10

--Apple-Mail-7--870235608
Content-Transfer-Encoding: 7bit
Content-Type: text/plain;
	x-unix-mode=0644;
	name=zoneinfo.txt
Content-Disposition: attachment;
	filename=zoneinfo.txt

Node 0, zone      DMA
  pages free     2828
        min      17
        low      21
        high     25
        scanned  0 (a: 14 i: 14)
        spanned  4096
        present  4064
    nr_free_pages 2828
    nr_active    0
    nr_inactive  0
    nr_anon_pages 0
    nr_mapped    1
    nr_file_pages 0
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 0
    nr_page_table_pages 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
        protection: (0, 873, 12176)
  pagesets
    cpu: 0 pcp: 0
              count: 0
              high:  0
              batch: 1
    cpu: 0 pcp: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
    cpu: 1 pcp: 0
              count: 0
              high:  0
              batch: 1
    cpu: 1 pcp: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
    cpu: 2 pcp: 0
              count: 0
              high:  0
              batch: 1
    cpu: 2 pcp: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
    cpu: 3 pcp: 0
              count: 0
              high:  0
              batch: 1
    cpu: 3 pcp: 1
              count: 0
              high:  0
              batch: 1
  vm stats threshold: 6
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         0
Node 0, zone   Normal
  pages free     6383
        min      936
        low      1170
        high     1404
        scanned  0 (a: 20 i: 20)
        spanned  225280
        present  223520
    nr_free_pages 6383
    nr_active    489
    nr_inactive  495
    nr_anon_pages 0
    nr_mapped    0
    nr_file_pages 988
    nr_dirty     1
    nr_writeback 0
    nr_slab_reclaimable 188073
    nr_slab_unreclaimable 3570
    nr_page_table_pages 80
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 10
        protection: (0, 0, 90424)
  pagesets
    cpu: 0 pcp: 0
              count: 19
              high:  186
              batch: 31
    cpu: 0 pcp: 1
              count: 1
              high:  62
              batch: 15
  vm stats threshold: 24
    cpu: 1 pcp: 0
              count: 25
              high:  186
              batch: 31
    cpu: 1 pcp: 1
              count: 0
              high:  62
              batch: 15
  vm stats threshold: 24
    cpu: 2 pcp: 0
              count: 13
              high:  186
              batch: 31
    cpu: 2 pcp: 1
              count: 54
              high:  62
              batch: 15
  vm stats threshold: 24
    cpu: 3 pcp: 0
              count: 21
              high:  186
              batch: 31
    cpu: 3 pcp: 1
              count: 45
              high:  62
              batch: 15
  vm stats threshold: 24
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         4096
Node 0, zone  HighMem
  pages free     1297805
        min      128
        low      3160
        high     6192
        scanned  0 (a: 0 i: 0)
        spanned  2916351
        present  2893568
    nr_free_pages 1297805
    nr_active    1572438
    nr_inactive  2194
    nr_anon_pages 1082
    nr_mapped    774
    nr_file_pages 1573559
    nr_dirty     0
    nr_writeback 0
    nr_slab_reclaimable 0
    nr_slab_unreclaimable 0
    nr_page_table_pages 0
    nr_unstable  0
    nr_bounce    0
    nr_vmscan_write 0
        protection: (0, 0, 0)
  pagesets
    cpu: 0 pcp: 0
              count: 19
              high:  186
              batch: 31
    cpu: 0 pcp: 1
              count: 12
              high:  62
              batch: 15
  vm stats threshold: 48
    cpu: 1 pcp: 0
              count: 6
              high:  186
              batch: 31
    cpu: 1 pcp: 1
              count: 9
              high:  62
              batch: 15
  vm stats threshold: 48
    cpu: 2 pcp: 0
              count: 151
              high:  186
              batch: 31
    cpu: 2 pcp: 1
              count: 8
              high:  62
              batch: 15
  vm stats threshold: 48
    cpu: 3 pcp: 0
              count: 55
              high:  186
              batch: 31
    cpu: 3 pcp: 1
              count: 4
              high:  62
              batch: 15
  vm stats threshold: 48
  all_unreclaimable: 0
  prev_priority:     12
  start_pfn:         229376

--Apple-Mail-7--870235608--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
