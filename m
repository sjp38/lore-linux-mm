Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id CFF3D6B0036
	for <linux-mm@kvack.org>; Sun, 18 May 2014 15:17:06 -0400 (EDT)
Received: by mail-pb0-f53.google.com with SMTP id md12so4806020pbc.26
        for <linux-mm@kvack.org>; Sun, 18 May 2014 12:17:06 -0700 (PDT)
Received: from mail-pb0-x236.google.com (mail-pb0-x236.google.com [2607:f8b0:400e:c01::236])
        by mx.google.com with ESMTPS id zo5si16669406pac.210.2014.05.18.12.17.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 18 May 2014 12:17:05 -0700 (PDT)
Received: by mail-pb0-f54.google.com with SMTP id jt11so4883577pbb.27
        for <linux-mm@kvack.org>; Sun, 18 May 2014 12:17:05 -0700 (PDT)
Date: Sun, 18 May 2014 12:15:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: oops when swapping on latest kernel git 3.15-rc5
In-Reply-To: <5378CD7C.9070004@gmail.com>
Message-ID: <alpine.LSU.2.11.1405181123380.14447@eggly.anvils>
References: <5378CD7C.9070004@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Branimir Maksimovic <branimir.maksimovic@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 18 May 2014, Branimir Maksimovic wrote:

> Ia hev discovered this accidentaly when tried to see how oom killer
> works. Program is this:
> 
> #include <unistd.h>
> #include <cstring>
> #include <exception>
> #include <iostream>
> 
> int counter=0;
> int main()
> try
> {
>   for(;;++counter)
>   {
>     char* p = new char[1024*1024];
>     memset(p,1,1024*1024);
>     std::cout<<counter<<'\n';
> //    if(counter > 24000)sleep(100);
> 
>   }
> }catch(const std::exception& e)
> {
>   std::cout<<"exception:"<<e.what()<<" count:"<<counter<<std::endl;
> }
> 
> After running this program system froze after some time. Programs could be
> started but they will not finish.
> Fortunatelly I could paste dmesg output:
> 
> [  388.522421] BUG: unable to handle kernel NULL pointer dereference at
> 0000000000000340
> [  388.522427] IP: [<ffffffff81185b0b>]
> get_mem_cgroup_from_mm.isra.42+0x2b/0x60

Thank you very much for reporting.  That BUG is a 3.15-rc regression.
3.14's try_get_mem_cgroup_from_mm() had protection against NULL mm,
as when exiting.  That was correctly removed as unnecessary by one
3.15 commit, but a new caller added in a later commit: which made
it necessary again, as you have now found.

Easily fixable, but opinions will differ on the right way to write it
(and I'm rather out of touch with the current flux in css_tryget and
root_mem_cgroup), so Cc'ing Hannes and Michal for the definitive fix.

> [  388.522435] PGD 3f233c067 PUD 3f20f7067 PMD 0
> [  388.522439] Oops: 0000 [#1] SMP
> [  388.522441] Modules linked in: snd_hrtimer pci_stub vboxpci(OE)
> vboxnetadp(OE) vboxnetflt(OE) vboxdrv(OE) cuse rfcomm bnep bluetooth
> binfmt_misc intel_rapl x86_pkg_temp_thermal intel_powerclamp crct10dif_pclmul
> crc32_pclmul ghash_clmulni_intel aesni_intel snd_hda_codec_hdmi aes_x86_64
> lrw gf128mul glue_helper snd_hda_codec_realtek snd_hda_codec_generic
> ablk_helper cryptd gspca_spca561 gspca_main videodev mxm_wmi snd_hda_intel
> snd_hda_controller snd_hda_codec microcode snd_hwdep joydev snd_pcm
> snd_seq_midi snd_seq_midi_event snd_rawmidi snd_seq dm_multipath scsi_dh
> snd_seq_device snd_timer mei_me snd mei lpc_ich wmi soundcore video mac_hid
> serio_raw parport_pc ppdev nct6775 hwmon_vid coretemp nvidia(POE) drm lp
> parport btrfs xor raid6_pq hid_generic usbhid hid psmouse e1000e ahci libahci
> ptp pps_core
> [  388.522494] CPU: 1 PID: 160 Comm: kworker/u8:5 Tainted: P           OE
> 3.15.0-rc5-core2-custom #159
> [  388.522496] Hardware name: System manufacturer System Product Name/MAXIMUS
> V GENE, BIOS 1903 08/19/2013
> [  388.522498] task: ffff880404e349b0 ti: ffff88040486a000 task.ti:
> ffff88040486a000
> [  388.522500] RIP: 0010:[<ffffffff81185b0b>] [<ffffffff81185b0b>]
> get_mem_cgroup_from_mm.isra.42+0x2b/0x60
> [  388.522504] RSP: 0000:ffff88040486bab8  EFLAGS: 00010246
> [  388.522506] RAX: 0000000000000000 RBX: ffffea000a416340 RCX:
> 0000000000000a40
> [  388.522508] RDX: ffff88041efe8a40 RSI: ffffea000a416340 RDI:
> 0000000000000340
> [  388.522509] RBP: ffff88040486bab8 R08: 000000000001cb56 R09:
> 0000000000072d5a
> [  388.522511] R10: 0000000000000000 R11: 0000000000000005 R12:
> ffff88040486bb00
> [  388.522512] R13: 00000000000000d0 R14: 0000000000000000 R15:
> ffff8803f3fe82f8
> [  388.522515] FS:  0000000000000000(0000) GS:ffff88041ec80000(0000)
> knlGS:0000000000000000
> [  388.522517] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [  388.522518] CR2: 0000000000000340 CR3: 00000003ee44d000 CR4:
> 00000000001407e0
> [  388.522520] Stack:
> [  388.522521]  ffff88040486baf0 ffffffff8118abf5 ffffffff8112ce1a
> 0000000000000000
> [  388.522524]  ffffea000a416340 0000000000000003 00000000ffffffef
> ffff88040486bb18
> [  388.522527]  ffffffff8118b1cc ffff88040486baf8 000000000001cb56
> 0000000000000000
> [  388.522530] Call Trace:
> [  388.522536]  [<ffffffff8118abf5>] __mem_cgroup_try_charge_swapin+0x45/0xf0
> [  388.522539]  [<ffffffff8112ce1a>] ? __lock_page+0x6a/0x70
> [  388.522543]  [<ffffffff8118b1cc>] mem_cgroup_charge_file+0x9c/0xe0
> [  388.522548]  [<ffffffff8114599c>] shmem_getpage_gfp+0x62c/0x770
> [  388.522552]  [<ffffffff81145b18>] shmem_write_begin+0x38/0x40
> [  388.522555]  [<ffffffff8112d1c5>] generic_perform_write+0xc5/0x1c0
> [  388.522559]  [<ffffffff811ad53a>] ? file_update_time+0x8a/0xd0
> [  388.522563]  [<ffffffff8112f211>] __generic_file_aio_write+0x1d1/0x3f0
> [  388.522567]  [<ffffffff81084fc1>] ? enqueue_entity+0x291/0xb90
> [  388.522570]  [<ffffffff8112f47f>] generic_file_aio_write+0x4f/0xc0
> [  388.522574]  [<ffffffff81192eaa>] do_sync_write+0x5a/0x90
> [  388.522578]  [<ffffffff810c53c1>] do_acct_process+0x4b1/0x550
> [  388.522582]  [<ffffffff810c5acd>] acct_process+0x6d/0xa0
> [  388.522587]  [<ffffffff810667d0>] ? manage_workers.isra.25+0x2a0/0x2a0
> [  388.522590]  [<ffffffff8104d937>] do_exit+0x827/0xa70
> [  388.522594]  [<ffffffff8106699e>] ? worker_thread+0x1ce/0x3a0
> [  388.522597]  [<ffffffff810667d0>] ? manage_workers.isra.25+0x2a0/0x2a0
> [  388.522600]  [<ffffffff8106cad3>] kthread+0xc3/0xf0
> [  388.522604]  [<ffffffff8106ca10>] ? kthread_create_on_node+0x180/0x180
> [  388.522608]  [<ffffffff816bfe6c>] ret_from_fork+0x7c/0xb0
> [  388.522611]  [<ffffffff8106ca10>] ? kthread_create_on_node+0x180/0x180

Or does that backtrace say that it's a kernel thread that was exiting
(and being accounted)?  A kernel thread would not have had an mm in the
first place.

I know very little about accounting (acct_process etc).  You said above
"Programs could be started but they will not finish": I'll assume that
hitting such a BUG inside acct_process() led to that.

> [  388.522613] Code: 0f 1f 44 00 00 55 48 89 e5 eb 20 0f 1f 44 00 00 f6 40 48
> 01 75 3a 48 8b 50 18 f6 c2 03 75 33 65 ff 02 ba 01 00 00 00 84 d2 75 25 <48>
> 8b 07 48 85 c0 74 10 48 8b 80 20 08 00 00 48 8b 40 60 48 85
> [  388.522644] RIP  [<ffffffff81185b0b>]
> get_mem_cgroup_from_mm.isra.42+0x2b/0x60
> [  388.522648]  RSP <ffff88040486bab8>
> [  388.522649] CR2: 0000000000000340
> [  388.522652] ---[ end trace 1b08285a09489a81 ]---
> [  388.522654] Fixing recursive fault but reboot is needed!

Then a good interval of 85 seconds.

> [  473.905138] alloc invoked oom-killer: gfp_mask=0x280da, order=0,
> oom_score_adj=0
> [  473.905144] alloc cpuset=/ mems_allowed=0
> [  473.905150] CPU: 0 PID: 31463 Comm: alloc Tainted: P      D    OE
> 3.15.0-rc5-core2-custom #159
> [  473.905152] Hardware name: System manufacturer System Product Name/MAXIMUS
> V GENE, BIOS 1903 08/19/2013
> [  473.905154]  0000000000000000 ffff88040794da68 ffffffff816b03eb
> ffff8803c4d50000
> [  473.905158]  ffff88040794daf0 ffffffff816ad5bc ffffffff8104b176
> ffff88040794dac8
> [  473.905161]  ffffffff810a9a1c 000000000001a932 00000000000280da
> 0000000000000003
> [  473.905164] Call Trace:
> [  473.905173]  [<ffffffff816b03eb>] dump_stack+0x45/0x56
> [  473.905177]  [<ffffffff816ad5bc>] dump_header+0x7b/0x1e9
> [  473.905182]  [<ffffffff8104b176>] ? put_online_cpus+0x56/0x80
> [  473.905185]  [<ffffffff810a9a1c>] ? rcu_oom_notify+0xcc/0xf0
> [  473.905190]  [<ffffffff81130af1>] oom_kill_process+0x201/0x350
> [  473.905194]  [<ffffffff81131292>] out_of_memory+0x492/0x4d0
> [  473.905198]  [<ffffffff81137006>] __alloc_pages_nodemask+0x9d6/0xac0
> [  473.905204]  [<ffffffff8117620a>] alloc_pages_vma+0x9a/0x160
> [  473.905209]  [<ffffffff81157b32>] handle_mm_fault+0xba2/0xeb0
> [  473.905214]  [<ffffffff816bac26>] __do_page_fault+0x176/0x540
> [  473.905218]  [<ffffffff810f00ec>] ? acct_account_cputime+0x1c/0x20
> [  473.905221]  [<ffffffff8107f6a7>] ? account_user_time+0x87/0x90
> [  473.905224]  [<ffffffff8107fbc0>] ? vtime_account_user+0x40/0x60
> [  473.905227]  [<ffffffff816bb00e>] do_page_fault+0x1e/0x70
> [  473.905231]  [<ffffffff816b7a22>] page_fault+0x22/0x30
> [  473.905233] Mem-Info:
> [  473.905235] Node 0 DMA per-cpu:
> [  473.905237] CPU    0: hi:    0, btch:   1 usd:   0
> [  473.905239] CPU    1: hi:    0, btch:   1 usd:   0
> [  473.905241] CPU    2: hi:    0, btch:   1 usd:   0
> [  473.905242] CPU    3: hi:    0, btch:   1 usd:   0
> [  473.905243] Node 0 DMA32 per-cpu:
> [  473.905246] CPU    0: hi:  186, btch:  31 usd:  31
> [  473.905247] CPU    1: hi:  186, btch:  31 usd: 138
> [  473.905249] CPU    2: hi:  186, btch:  31 usd: 163
> [  473.905250] CPU    3: hi:  186, btch:  31 usd:  74
> [  473.905251] Node 0 Normal per-cpu:
> [  473.905253] CPU    0: hi:  186, btch:  31 usd:  56
> [  473.905255] CPU    1: hi:  186, btch:  31 usd:  86
> [  473.905256] CPU    2: hi:  186, btch:  31 usd: 130
> [  473.905258] CPU    3: hi:  186, btch:  31 usd: 166
> [  473.905262] active_anon:3554228 inactive_anon:426658 isolated_anon:0
> [  473.905262]  active_file:122 inactive_file:146 isolated_file:44
> [  473.905262]  unevictable:1218 dirty:0 writeback:0 unstable:0
> [  473.905262]  free:33361 slab_reclaimable:6684 slab_unreclaimable:7801
> [  473.905262]  mapped:10140 shmem:62 pagetables:22261 bounce:0
> [  473.905262]  free_cma:0
> [  473.905266] Node 0 DMA free:15892kB min:64kB low:80kB high:96kB
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB
> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15984kB
> managed:15900kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB
> slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB
> unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0
> all_unreclaimable? yes
> [  473.905272] lowmem_reserve[]: 0 3450 15976 15976
> [  473.905276] Node 0 DMA32 free:64628kB min:14580kB low:18224kB high:21868kB
> active_anon:2849160kB inactive_anon:569760kB active_file:100kB
> inactive_file:96kB unevictable:712kB isolated(anon):0kB isolated(file):0kB
> present:3614516kB managed:3536136kB mlocked:712kB dirty:0kB writeback:0kB
> mapped:13204kB shmem:188kB slab_reclaimable:4680kB slab_unreclaimable:5432kB
> kernel_stack:872kB pagetables:18568kB unstable:0kB bounce:0kB free_cma:0kB
> writeback_tmp:0kB pages_scanned:110958 all_unreclaimable? yes
> [  473.905282] lowmem_reserve[]: 0 0 12526 12526
> [  473.905285] Node 0 Normal free:52924kB min:52936kB low:66168kB
> high:79404kB active_anon:11367752kB inactive_anon:1136872kB active_file:388kB
> inactive_file:488kB unevictable:4160kB isolated(anon):0kB
> isolated(file):176kB present:13090816kB managed:12827504kB mlocked:4160kB
> dirty:0kB writeback:0kB mapped:27356kB shmem:60kB slab_reclaimable:22056kB
> slab_unreclaimable:25764kB kernel_stack:2680kB pagetables:70476kB
> unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:3425
> all_unreclaimable? yes
> [  473.905290] lowmem_reserve[]: 0 0 0 0
> [  473.905294] Node 0 DMA: 1*4kB (U) 2*8kB (U) 2*16kB (U) 1*32kB (U) 1*64kB
> (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) =
> 15892kB
> [  473.905308] Node 0 DMA32: 129*4kB (UE) 66*8kB (UEM) 118*16kB (UE) 50*32kB
> (UEM) 21*64kB (UE) 9*128kB (UEM) 7*256kB (UEM) 1*512kB (E) 0*1024kB 1*2048kB
> (U) 13*4096kB (MR) = 64628kB
> [  473.905322] Node 0 Normal: 739*4kB (UEM) 280*8kB (UE) 369*16kB (UEM)
> 164*32kB (UEM) 62*64kB (UEM) 22*128kB (UEM) 9*256kB (UEM) 4*512kB (E)
> 1*1024kB (U) 0*2048kB 6*4096kB (MR) = 53084kB
> [  473.905337] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> [  473.905339] 1647 total pagecache pages
> [  473.905341] 380 pages in swap cache
> [  473.905342] Swap cache stats: add 4234126, delete 4233746, find
> 256353/270546
> [  473.905344] Free swap  = 0kB
> [  473.905345] Total swap = 16777212kB
> [  473.905346] 4180329 pages RAM
> [  473.905348] 0 pages HighMem/MovableOnly
> [  473.905349] 65828 pages reserved
> [  473.905350] 0 pages hwpoisoned
> [  473.905351] [ pid ]   uid  tgid total_vm      rss nr_ptes swapents
> oom_score_adj name
> [  473.905358] [  317]     0   317     4868        0      14 62             0
> upstart-udev-br
> [  473.905361] [  325]     0   325    13015      399      28 298
> -1000 systemd-udevd
> [  473.905365] [  609]     0   609     3814        0      12 55             0
> upstart-socket-
> [  473.905370] [  958]     0   958    67900      501     135 467
> 0 smbd
> [  473.905372] [  989]     0   989     3818        0      12 54             0
> upstart-file-br
> [  473.905375] [ 1063]   101  1063    63959      333      26 151
> 0 rsyslogd
> [  473.905378] [ 1071]   102  1071    10172      573      24 228
> 0 dbus-daemon
> [  473.905380] [ 1086]     0  1086    82558      405      63 297
> 0 ModemManager
> [  473.905383] [ 1090]     0  1090     4822      173      13 71             0
> bluetoothd
> [  473.905385] [ 1098]     0  1098    67900      371     128 467
> 0 smbd
> [  473.905387] [ 1121]     0  1121    10885      422      26 98             0
> systemd-logind
> [  473.905390] [ 1129]   104  1129     8087      388      23 47             0
> avahi-daemon
> [  473.905393] [ 1131]   104  1131     8055        0      20 63             0
> avahi-daemon
> [  473.905395] [ 1138]     0  1138    85188      342      60 310
> 0 NetworkManager
> [  473.905398] [ 1145]     0  1145    70408      842      40 253
> 0 polkitd
> [  473.905400] [ 1221]     0  1221     2557      415       9 572
> 0 dhclient
> [  473.905403] [ 1247]     0  1247     3954      384      13 41             0
> getty
> [  473.905405] [ 1251]     0  1251     3954      390      13 41             0
> getty
> [  473.905407] [ 1259]     0  1259     3954      399      13 40             0
> getty
> [  473.905410] [ 1260]     0  1260     3954      396      12 40             0
> getty
> [  473.905412] [ 1264]     0  1264     3954      396      13 41             0
> getty
> [  473.905415] [ 1314]     0  1314    15340      414      33 168
> -1000 sshd
> [  473.905417] [ 1315]     0  1315     4784        0      13 43             0
> atd
> [  473.905419] [ 1323]     0  1323     5882      254      15 89             0
> vsftpd
> [  473.905422] [ 1325]     0  1325     5913      425      17 42             0
> cron
> [  473.905424] [ 1326]     0  1326    52742      438      40 177
> 0 gdm
> [  473.905427] [ 1334]     0  1334     4796      372      14 28             0
> irqbalance
> [  473.905429] [ 1351]     0  1351    18870      401      41 219
> 0 cups-browsed
> [  473.905432] [ 1356]     0  1356     1091      357       8 49             0
> acpid
> [  473.905434] [ 1433]     0  1433    73634      437      47 247
> 0 gdm-simple-slav
> [  473.905437] [ 1506]     0  1506    51435     4774      91 3708
> 0 Xorg
> [  473.905439] [ 1508]     0  1508    71869      353      43 249
> 0 accounts-daemon
> [  473.905442] [ 1530] 65534  1530     7756      427      20 59             0
> dnsmasq
> [  473.905444] [ 1641]     0  1641    57531      390     111 366
> 0 winbindd
> [  473.905447] [ 1678]   122  1678    61926      469      57 342
> -900 postgres
> [  473.905449] [ 1693]     0  1693    57531      354     111 378
> 0 winbindd
> [  473.905451] [ 1703]     0  1703    47861      236      91 298
> 0 nmbd
> [  473.905454] [ 1709]   122  1709    61926       41      48 349
> 0 postgres
> [  473.905456] [ 1710]   122  1710    61926      213      49 346
> 0 postgres
> [  473.905459] [ 1711]   122  1711    61926      166      47 349
> 0 postgres
> [  473.905461] [ 1712]   122  1712    62141      240      52 496
> 0 postgres
> [  473.905463] [ 1713]   122  1713    25845      240      45 355
> 0 postgres
> [  473.905466] [ 1786]     0  1786     4271     1204      15 0             0
> atop
> [  473.905468] [ 1790] 65534  1790     3741      357      13 44             0
> gdomap
> [  473.905471] [ 1799]   108  1799     9285      322      19 83             0
> kerneloops
> [  473.905473] [ 1819]     0  1819   107382      130      25 71             0
> osspd
> [  473.905476] [ 1834]     0  1834    23862      379      17 104
> 0 pcscd
> [  473.905479] [ 1937]     0  1937    23793      263      14 42             0
> apcupsd
> [  473.905481] [ 2018]     0  2018     6671     1972      18 1378
> 0 preload
> [  473.905483] [ 2052]   119  2052    28682      637      56 1209
> 0 timidity
> [  473.905486] [ 2057]     0  2057     3954      393      13 41             0
> getty
> [  473.905488] [ 2081]     0  2081    59850       93      46 196
> 0 upowerd
> [  473.905491] [ 2129]   115  2129    75411      599      48 905
> 0 colord
> [  473.905493] [ 2135]   110  2135    42228      399      19 71             0
> rtkit-daemon
> [  473.905496] [ 2151]   130  2151     4260      295      14 44             0
> nvidia-persiste
> [  473.905498] [ 2820]   113  2820     8891      297      22 128
> 0 ntpd
> [  473.905501] [ 4846]     0  4846    19557      496      43 562
> 0 cupsd
> [  473.905503] [ 4976]     0  4976    68341      459      67 268
> 0 gdm-session-wor
> [  473.905506] [ 4996]  1000  4996   147088      328      47 837
> 0 gnome-keyring-d
> [  473.905508] [ 4998]  1000  4998     8994      489      22 168
> 0 init
> [  473.905511] [ 5078]  1000  5078     6142      261      16 79             0
> dbus-launch
> [  473.905513] [ 5080]  1000  5080     9774        0      24 87             0
> dbus-daemon
> [  473.905516] [ 5097]  1000  5097     2653        0       8 78             0
> ssh-agent
> [  473.905518] [ 5107]  1000  5107    10286      359      24 465
> 0 dbus-daemon
> [  473.905521] [ 5114]  1000  5114    60335      343      53 695
> 0 mediascanner-se
> [  473.905523] [ 5117]  1000  5117     4525      200      13 36             0
> upstart-event-b
> [  473.905525] [ 5123]  1000  5123    18500        0      32 141
> 0 window-stack-br
> [  473.905528] [ 5129]  1000  5129     4527      172      12 63             0
> upstart-dbus-br
> [  473.905530] [ 5133]  1000  5133     4527      180      12 40             0
> upstart-dbus-br
> [  473.905533] [ 5135]  1000  5135   162161      537     108 1536
> 0 bamfdaemon
> [  473.905535] [ 5137]  1000  5137    89407      555      41 165
> 0 ibus-daemon
> [  473.905538] [ 5148]  1000  5148    84480      362      32 671
> 0 at-spi-bus-laun
> [  473.905540] [ 5152]  1000  5152     9807      408      24 97             0
> dbus-daemon
> [  473.905543] [ 5155]  1000  5155    31253      294      30 113
> 0 at-spi2-registr
> [  473.905545] [ 5159]  1000  5159    48110      370      29 163
> 0 gvfsd
> [  473.905548] [ 5165]  1000  5165    69230      377      37 189
> 0 ibus-dconf
> [  473.905550] [ 5166]  1000  5166   144909      525     109 1916
> 0 ibus-ui-gtk3
> [  473.905553] [ 5168]  1000  5168    96227      397      87 487
> 0 ibus-x11
> [  473.905555] [ 5184]  1000  5184    86415      350      38 199
> 0 gvfsd-fuse
> [  473.905557] [ 5196]  1000  5196     6646      186      17 70             0
> upstart-file-br
> [  473.905560] [ 5798]  1000  5798   210028      890     175 2053
> 0 gnome-settings-
> [  473.905562] [ 5827]  1000  5827   143845      522     111 1264
> 0 gnome-session
> [  473.905565] [ 7788]  1000  7788   112673      517      90 812
> 0 pulseaudio
> [  473.905567] [ 7813]  1000  7813    24597       59      50 180
> 0 gconf-helper
> [  473.905570] [ 7815]  1000  7815    13523      460      32 400
> 0 gconfd-2
> [  473.905572] [ 7817]  1000  7817    96739      400      84 344
> 0 gsd-printer
> [  473.905575] [ 7819]  1000  7819    45501      406      25 1101
> 0 dconf-service
> [  473.905577] [ 7825]  1000  7825    50238      388      35 151
> 0 ibus-engine-sim
> [  473.905580] [ 7855]  1000  7855   436938     9733     319 25236
> 0 gnome-shell
> [  473.905583] [ 7871]  1000  7871   123350      447      70 1220
> 0 gnome-shell-cal
> [  473.905585] [ 7877]  1000  7877   160284      528     137 759
> 0 evolution-sourc
> [  473.905588] [ 7883]  1000  7883   100333      472      65 445
> 0 mission-control
> [  473.905590] [ 7887]  1000  7887   166665        0     156 4417
> 0 goa-daemon
> [  473.905592] [ 7895]  1000  7895   145369      369      54 632
> 0 gvfs-udisks2-vo
> [  473.905595] [ 7898]     0  7898    92939      402      48 1074
> 0 udisksd
> [  473.905597] [ 7923]  1000  7923    49019      227      32 197
> 0 gvfs-mtp-volume
> [  473.905600] [ 7927]  1000  7927    45864      307      25 170
> 0 gvfs-goa-volume
> [  473.905602] [ 7931]  1000  7931    70440      332      39 209
> 0 gvfs-afc-volume
> [  473.905605] [ 7936]  1000  7936    52060      443      37 210
> 0 gvfs-gphoto2-vo
> [  473.905607] [ 7943]  1000  7943    30156      414      29 186
> 0 gvfsd-metadata
> [  473.905610] [ 7947]  1000  7947   366257      562     210 3228
> 0 nautilus
> [  473.905612] [ 7963]  1000  7963    68650      352      35 180
> 0 indicator-power
> [  473.905615] [ 7965]  1000  7965   195421      626     128 2368
> 0 nm-applet
> [  473.905617] [ 7967]  1000  7967    64915      408      27 148
> 0 indicator-bluet
> [  473.905620] [ 7971]  1000  7971   119599      366      68 3242
> 0 tracker-miner-f
> [  473.905622] [ 7990]  1000  7990   228654      357     171 10717
> 0 evolution-calen
> [  473.905625] [ 7992]  1000  7992   118206      507     129 3519
> 0 guake
> [  473.905627] [ 7994]  1000  7994    98425      399      55 2468
> 0 tracker-store
> [  473.905629] [ 8020]  1000  8020    73119      370      41 261
> 0 telepathy-logge
> [  473.905632] [ 8099]  1000  8099    66544      207      31 165
> 0 gvfsd-burn
> [  473.905634] [ 8105]  1000  8105   107236      401      43 235
> 0 gvfsd-trash
> [  473.905637] [ 8164]  1000  8164     3705      378      13 39             0
> gnome-pty-helpe
> [  473.905639] [ 8165]  1000  8165     6502      461      17 1350
> 0 bash
> [  473.905642] [10468]  1000 10468   185692     1047     133 1947
> 0 gnome-terminal-
> [  473.905644] [10476]  1000 10476     3705      364      13 40             0
> gnome-pty-helpe
> [  473.905647] [10477]  1000 10477     6502      439      17 1349
> 0 bash
> [  473.905649] [10557]  1000 10557   102685      785      86 620
> 0 zeitgeist-datah
> [  473.905652] [10562]  1000 10562    87219      523      40 159
> 0 zeitgeist-daemo
> [  473.905654] [10568]  1000 10568    81497      446      55 644
> 0 zeitgeist-fts
> [  473.905657] [10574]  1000 10574     1803       57       9 24             0
> cat
> [  473.905659] [10588]  1000 10588    93847      462      50 372
> 0 gvfsd-http
> [  473.905662] [10600]  1000 10600   198286      459     217 5341
> 0 evolution-alarm
> [  473.905664] [10619]  1000 10619   137054      504     124 8342
> 0 ubuntuone-syncd
> [  473.905666] [12873]  1000 12873     6502      440      18 1349
> 0 bash
> [  473.905669] [12953]  1000 12953     6503      449      18 1350
> 0 bash
> [  473.905671] [13033]  1000 13033     6504      560      18 1264
> 0 bash
> [  473.905674] [13113]  1000 13113     6505      484      18 1355
> 0 bash
> [  473.905676] [13193]  1000 13193     6504      492      17 1343
> 0 bash
> [  473.905678] [13285]  1000 13285   164668      496     114 2170
> 0 update-notifier
> [  473.905681] [17869]  1000 17869    93505      408      49 303
> 0 deja-dup-monito
> [  473.905684] [31463]  1000 31463  8041866  3969604   15713 4069471
> 0 alloc
> [  473.905686] Out of memory: Kill process 31463 (alloc) score 971 or
> sacrifice child
> [  473.905688] Killed process 31463 (alloc) total-vm:32167464kB,
> anon-rss:15876888kB, file-rss:1528kB
> 
> Hope someone can resolve issue.

And I'll assume that the OOM-kill above is working as intended:
that's what you were trying to trigger with your test program.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
