Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id 8EBC26B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 20:50:42 -0500 (EST)
From: Hubert Kario <hubert@kario.pl>
Subject: Big kernel dynamic memory usage (non-cache)
Date: Tue, 22 Jan 2013 02:50:40 +0100
Message-ID: <2233004.c1QkIFnMrK@bursa22>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi!

In short, how to get detailed information what is the "noncache" column in
"kernel dynamic memory" in smem -w output?

# smem -wtk
Area                           Used      Cache   Noncache 
firmware/hardware                 0          0          0 
kernel image                      0          0          0 
kernel dynamic memory          1.5G     637.7M     853.5M 
userspace memory               2.0G     142.7M       1.9G 
free memory                  383.5M     383.5M          0 
----------------------------------------------------------
                               3.9G       1.1G       2.7G

Little background info:

I'm experiencing a weird problem with the kernel, where it does allocate
lots of memory, but I can't find what it is used for.
After the system has been running for few days (around a week usually) it
starts to swap quite heavily (if I don't close the biggest applications 
quickly to recover I usually have to reset it as even remote ssh access 
doesn't work, it responds to pings so it's not a hard lock up, Magic SysRq
doesn't restart it though). Thing is, it's enough to log-out from the X
environment and back in to make it go back to normal (where the noncache
memory is less than 200MiB).

It's a workstation, with KMail, Opera and the usual background KDE services 
running in the back (with file indexing turned off). Any other processes 
are either short lived or not using any big amounts (>5MiB) of memory.
Archlinux, so the packages (both kernel and userspace) are either vanilla or
with minimal patches.

The sum of USS of all processes in the system, as reported by smem 
(the sum of RSS from `ps` is only 10-15% larger), during all that time oscillates 
around 2GiB and basically never reaches 3GiB. I have tried running with zram 
and it made the situation a bit better, but it sometimes still locks up 
(because it starts swapping so hard).

As restarting X helps, it led me to believe it may be a regression from this
bug: https://bugzilla.redhat.com/show_bug.cgi?id=615505
but it doesn't look like it to me:

# cat /sys/kernel/debug/dri/0/gem_names 
  name     size handles refcount
     1  7680000       1        3
     2 15564800       1        3

Some statistics and information on the system follow.

Regards,
Hubert Kario

# uname -a
Linux bursa22 3.6.11-1-ARCH #1 SMP PREEMPT Tue Dec 18 08:57:15 CET 2012 x86_64 GNU/Linux

# free -k
             total       used       free     shared    buffers     cached
Mem:       4051956    3598176     453780          0      30264     646828
-/+ buffers/cache:    2921084    1130872
Swap:      4051952     292524    3759428

# lsmod 
Module                  Size  Used by
vboxdrv              1823470  0 
iptable_filter          1457  1 
iptable_mangle          1585  1 
xt_tcpudp               2472  14 
xt_connmark             1910  12 
xt_mark                 1214  13 
iptable_nat             4025  1 
nf_nat                 15371  1 iptable_nat
nf_conntrack_ipv4       7799  15 nf_nat,iptable_nat
nf_defrag_ipv4          1340  1 nf_conntrack_ipv4
nf_conntrack           64101  4 nf_nat,xt_connmark,iptable_nat,nf_conntrack_ipv4
ip_tables              16947  3 iptable_filter,iptable_mangle,iptable_nat
x_tables               17000  7 xt_mark,ip_tables,xt_tcpudp,iptable_filter,xt_connmark,iptable_mangle,iptable_nat
tun                    16593  2 
zram                    9460  2 
xfs                   748208  1 
snd_hda_codec_hdmi     24529  1 
fuse                   69213  5 
btrfs                 718583  2 
coretemp                6071  0 
kvm_intel             124718  0 
crc32c                  1769  1 
libcrc32c               1003  1 btrfs
zlib_deflate           20437  1 btrfs
kvm                   374014  1 kvm_intel
radeon                859687  2 
iTCO_wdt                5256  0 
iTCO_vendor_support     1930  1 iTCO_wdt
gpio_ich                4064  0 
snd_hda_codec_realtek    61420  1 
ttm                    64385  1 radeon
drm_kms_helper         32878  1 radeon
drm                   218903  4 ttm,drm_kms_helper,radeon
r8169                  56872  0 
i2c_algo_bit            5392  1 radeon
snd_hda_intel          26181  4 
mii                     4092  1 r8169
snd_hda_codec          98034  3 snd_hda_codec_realtek,snd_hda_codec_hdmi,snd_hda_intel
snd_hwdep               6429  1 snd_hda_codec
snd_pcm                75735  3 snd_hda_codec_hdmi,snd_hda_codec,snd_hda_intel
snd_page_alloc          7218  2 snd_pcm,snd_hda_intel
snd_timer              18935  1 snd_pcm
acpi_cpufreq            5934  0 
snd                    60189  15 snd_hda_codec_realtek,snd_hwdep,snd_timer,snd_hda_codec_hdmi,snd_pcm,snd_hda_codec,snd_hda_intel
mperf                   1300  1 acpi_cpufreq
intel_agp              10745  0 
i2c_i801                9572  0 
soundcore               5443  1 snd
intel_gtt              15660  1 intel_agp
microcode              12346  0 
i2c_core               20708  5 drm,i2c_i801,drm_kms_helper,i2c_algo_bit,radeon
lpc_ich                10610  0 
pcspkr                  1900  0 
processor              26856  3 acpi_cpufreq
button                  4663  0 
evdev                  10267  7 
ext4                  440435  4 
crc16                   1360  1 ext4
jbd2                   78802  1 ext4
mbcache                 6027  1 ext4
dm_mod                 72106  25 
raid456                55308  1 
async_raid6_recov       5375  1 raid456
async_memcpy            1367  2 raid456,async_raid6_recov
async_pq                3261  2 raid456,async_raid6_recov
async_xor               2394  3 async_pq,raid456,async_raid6_recov
xor                     8866  1 async_xor
async_tx                1903  5 async_pq,raid456,async_xor,async_memcpy,async_raid6_recov
raid6_pq               86983  2 async_pq,async_raid6_recov
raid10                 40365  1 
md_mod                104017  3 raid456,raid10
hid_generic             1114  0 
usbhid                 37036  0 
hid                    85974  2 hid_generic,usbhid
sr_mod                 14824  0 
cdrom                  35521  1 sr_mod
sd_mod                 29560  27 
ata_generic             3339  0 
uhci_hcd               23437  0 
pata_acpi               3452  0 
sata_via                8124  5 
ahci                   21361  12 
libahci                20024  1 ahci
pata_it8213             3587  1 
firewire_ohci          31942  0 
libata                167757  6 ahci,pata_acpi,sata_via,libahci,ata_generic,pata_it8213
scsi_mod              133434  3 libata,sd_mod,sr_mod
firewire_core          53174  1 firewire_ohci
crc_itu_t               1364  1 firewire_core
ehci_hcd               41849  0 
usbcore               150472  3 uhci_hcd,ehci_hcd,usbhid
usb_common               955  1 usbcore

# smem -kt | sed -n '1p;$p'
  PID User     Command                         Swap      USS      PSS      RSS 
  110 6                                      281.6M     2.0G     2.0G     2.3G

# cat /proc/meminfo 
MemTotal:        4051956 kB
MemFree:          452512 kB
Buffers:           29784 kB
Cached:           648796 kB
SwapCached:       144308 kB
Active:          1555176 kB
Inactive:        1175416 kB
Active(anon):    1238968 kB
Inactive(anon):   868836 kB
Active(file):     316208 kB
Inactive(file):   306580 kB
Unevictable:        7720 kB
Mlocked:            7720 kB
SwapTotal:       4051952 kB
SwapFree:        3759416 kB
Dirty:               372 kB
Writeback:             0 kB
AnonPages:       1982576 kB
Mapped:           148724 kB
Shmem:             52248 kB
Slab:             185580 kB
SReclaimable:      69316 kB
SUnreclaim:       116264 kB
KernelStack:        3320 kB
PageTables:        43996 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     6077928 kB
Committed_AS:    3751688 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      139780 kB
VmallocChunk:   34359570976 kB
HardwareCorrupted:     0 kB
AnonHugePages:    442368 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:     2536128 kB
DirectMap2M:     1656832 kB

# cat /proc/vmstat 
nr_free_pages 113256
nr_inactive_anon 217210
nr_active_anon 309694
nr_inactive_file 76546
nr_active_file 79049
nr_unevictable 1930
nr_mlock 1930
nr_anon_pages 385048
nr_mapped 37179
nr_file_pages 205623
nr_dirty 24
nr_writeback 0
nr_slab_reclaimable 17329
nr_slab_unreclaimable 29066
nr_page_table_pages 10973
nr_kernel_stack 413
nr_unstable 0
nr_bounce 0
nr_vmscan_write 3103053
nr_vmscan_immediate_reclaim 21226934
nr_writeback_temp 0
nr_isolated_anon 0
nr_isolated_file 0
nr_shmem 13062
nr_dirtied 39768555
nr_written 38668348
numa_hit 1043570022
numa_miss 0
numa_foreign 0
numa_interleave 7629
numa_local 1043570022
numa_other 0
nr_anon_transparent_hugepages 216
nr_dirty_threshold 76584
nr_dirty_background_threshold 38292
pgpgin 538657436
pgpgout 172521740
pswpin 350320
pswpout 404062
pgalloc_dma 2
pgalloc_dma32 666912295
pgalloc_normal 571432892
pgalloc_movable 0
pgfree 1243823469
pgactivate 73410706
pgdeactivate 72896276
pgfault 544723643
pgmajfault 2023827
pgrefill_dma 0
pgrefill_dma32 64507672
pgrefill_normal 18650343
pgrefill_movable 0
pgsteal_kswapd_dma 0
pgsteal_kswapd_dma32 3005794
pgsteal_kswapd_normal 26891312
pgsteal_kswapd_movable 0
pgsteal_direct_dma 0
pgsteal_direct_dma32 15653023
pgsteal_direct_normal 42635574
pgsteal_direct_movable 0
pgscan_kswapd_dma 0
pgscan_kswapd_dma32 3136881
pgscan_kswapd_normal 32518914
pgscan_kswapd_movable 0
pgscan_direct_dma 0
pgscan_direct_dma32 361983838
pgscan_direct_normal 6556538987
pgscan_direct_movable 0
pgscan_direct_throttle 0
zone_reclaim_failed 0
pginodesteal 24512
slabs_scanned 35039616
kswapd_inodesteal 193648
kswapd_low_wmark_hit_quickly 654504
kswapd_high_wmark_hit_quickly 690974
kswapd_skip_congestion_wait 2977
pageoutrun 645618572
allocstall 7647697
pgrotated 285215
compact_blocks_moved 23846881
compact_pages_moved 4897380
compact_pagemigrate_failed 48162348
compact_stall 145117
compact_fail 138243
compact_success 6874
htlb_buddy_alloc_success 0
htlb_buddy_alloc_fail 0
unevictable_pgs_culled 8443
unevictable_pgs_scanned 0
unevictable_pgs_rescued 7075596
unevictable_pgs_mlocked 7082893
unevictable_pgs_munlocked 7076462
unevictable_pgs_cleared 0
unevictable_pgs_stranded 0
unevictable_pgs_mlockfreed 0
thp_fault_alloc 15563
thp_fault_fallback 59524
thp_collapse_alloc 1356
thp_collapse_alloc_failed 4821
thp_split 513

# cat /proc/swaps 
Filename                                Type            Size    Used    Priority
/dev/zram0                              partition       2025976 146416  100
/dev/zram1                              partition       2025976 146108  100

# cat /sys/block/zram*/compr_data_size
47152674
47090766

-- 
Hubert Kario

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
