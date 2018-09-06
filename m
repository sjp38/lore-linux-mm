Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C2F706B75FD
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 21:00:25 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id l191-v6so10758787oig.23
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 18:00:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id k5-v6si2173606oih.2.2018.09.05.18.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 18:00:22 -0700 (PDT)
Message-Id: <201809060100.w86100i6060716@www262.sakura.ne.jp>
Subject: Re: [PATCH] =?ISO-2022-JP?B?bW0scGFnZV9hbGxvYzogUEZfV1FfV09SS0VSIHRocmVh?=
 =?ISO-2022-JP?B?ZHMgbXVzdCBzbGVlcCBhdCBzaG91bGRfcmVjbGFpbV9yZXRyeSgpLg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Thu, 06 Sep 2018 10:00:00 +0900
References: <81cc1f29-e42e-7813-dc70-5d6d9e999dd1@i-love.sakura.ne.jp> <20180905140451.GG14951@dhcp22.suse.cz>
In-Reply-To: <20180905140451.GG14951@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Michal Hocko wrote:
> On Wed 05-09-18 22:53:33, Tetsuo Handa wrote:
> > On 2018/09/05 22:40, Michal Hocko wrote:
> > > Changelog said 
> > > 
> > > "Although this is possible in principle let's wait for it to actually
> > > happen in real life before we make the locking more complex again."
> > > 
> > > So what is the real life workload that hits it? The log you have pasted
> > > below doesn't tell much.
> > 
> > Nothing special. I just ran a multi-threaded memory eater on a CONFIG_PREEMPT=y kernel.
> 
> I strongly suspec that your test doesn't really represent or simulate
> any real and useful workload. Sure it triggers a rare race and we kill
> another oom victim. Does this warrant to make the code more complex?
> Well, I am not convinced, as I've said countless times.

Yes. Below is an example from a machine running Apache Web server/Tomcat AP server/PostgreSQL DB server.
An memory eater needlessly killed Tomcat due to this race. I assert that we should fix af5679fbc669f31f.



Before:

systemd(1)-+-NetworkManager(693)-+-dhclient(791)
           |                     |-{NetworkManager}(698)
           |                     `-{NetworkManager}(702)
           |-abrtd(630)
           |-agetty(1007)
           |-atd(653)
           |-auditd(600)---{auditd}(601)
           |-avahi-daemon(625)---avahi-daemon(631)
           |-crond(657)
           |-dbus-daemon(638)
           |-firewalld(661)---{firewalld}(788)
           |-httpd(1169)-+-httpd(1170)
           |             |-httpd(1171)
           |             |-httpd(1172)
           |             |-httpd(1173)
           |             `-httpd(1174)
           |-irqbalance(628)
           |-java(1074)-+-{java}(1092)
           |            |-{java}(1093)
           |            |-{java}(1094)
           |            |-{java}(1095)
           |            |-{java}(1096)
           |            |-{java}(1097)
           |            |-{java}(1098)
           |            |-{java}(1099)
           |            |-{java}(1100)
           |            |-{java}(1101)
           |            |-{java}(1102)
           |            |-{java}(1103)
           |            |-{java}(1104)
           |            |-{java}(1105)
           |            |-{java}(1106)
           |            |-{java}(1107)
           |            |-{java}(1108)
           |            |-{java}(1109)
           |            |-{java}(1110)
           |            |-{java}(1111)
           |            |-{java}(1114)
           |            |-{java}(1115)
           |            |-{java}(1116)
           |            |-{java}(1117)
           |            |-{java}(1118)
           |            |-{java}(1119)
           |            |-{java}(1120)
           |            |-{java}(1121)
           |            |-{java}(1122)
           |            |-{java}(1123)
           |            |-{java}(1124)
           |            |-{java}(1125)
           |            |-{java}(1126)
           |            |-{java}(1127)
           |            |-{java}(1128)
           |            |-{java}(1129)
           |            |-{java}(1130)
           |            |-{java}(1131)
           |            |-{java}(1132)
           |            |-{java}(1133)
           |            |-{java}(1134)
           |            |-{java}(1135)
           |            |-{java}(1136)
           |            |-{java}(1137)
           |            `-{java}(1138)
           |-ksmtuned(659)---sleep(1727)
           |-login(1006)---bash(1052)---pstree(1728)
           |-polkitd(624)-+-{polkitd}(633)
           |              |-{polkitd}(642)
           |              |-{polkitd}(643)
           |              |-{polkitd}(645)
           |              `-{polkitd}(650)
           |-postgres(1154)-+-postgres(1155)
           |                |-postgres(1157)
           |                |-postgres(1158)
           |                |-postgres(1159)
           |                |-postgres(1160)
           |                `-postgres(1161)
           |-rsyslogd(986)-+-{rsyslogd}(997)
           |               `-{rsyslogd}(999)
           |-sendmail(1008)
           |-sendmail(1023)
           |-smbd(983)-+-cleanupd(1027)
           |           |-lpqd(1032)
           |           `-smbd-notifyd(1026)
           |-sshd(981)
           |-systemd-journal(529)
           |-systemd-logind(627)
           |-systemd-udevd(560)
           `-tuned(980)-+-{tuned}(1030)
                        |-{tuned}(1031)
                        |-{tuned}(1033)
                        `-{tuned}(1047)



After:

systemd(1)-+-NetworkManager(693)-+-dhclient(791)
           |                     |-{NetworkManager}(698)
           |                     `-{NetworkManager}(702)
           |-abrtd(630)
           |-agetty(1007)
           |-atd(653)
           |-auditd(600)---{auditd}(601)
           |-avahi-daemon(625)---avahi-daemon(631)
           |-crond(657)
           |-dbus-daemon(638)
           |-firewalld(661)---{firewalld}(788)
           |-httpd(1169)-+-httpd(1170)
           |             |-httpd(1171)
           |             |-httpd(1172)
           |             |-httpd(1173)
           |             `-httpd(1174)
           |-irqbalance(628)
           |-ksmtuned(659)---sleep(1758)
           |-login(1006)---bash(1052)---pstree(1759)
           |-polkitd(624)-+-{polkitd}(633)
           |              |-{polkitd}(642)
           |              |-{polkitd}(643)
           |              |-{polkitd}(645)
           |              `-{polkitd}(650)
           |-postgres(1154)-+-postgres(1155)
           |                |-postgres(1157)
           |                |-postgres(1158)
           |                |-postgres(1159)
           |                |-postgres(1160)
           |                `-postgres(1161)
           |-rsyslogd(986)-+-{rsyslogd}(997)
           |               `-{rsyslogd}(999)
           |-sendmail(1008)
           |-sendmail(1023)
           |-smbd(983)-+-cleanupd(1027)
           |           |-lpqd(1032)
           |           `-smbd-notifyd(1026)
           |-sshd(981)
           |-systemd-journal(529)
           |-systemd-logind(627)
           |-systemd-udevd(560)
           `-tuned(980)-+-{tuned}(1030)
                        |-{tuned}(1031)
                        |-{tuned}(1033)
                        `-{tuned}(1047)



[  222.165946] a.out invoked oom-killer: gfp_mask=0x6280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO), nodemask=(null), order=0, oom_score_adj=0
[  222.170631] a.out cpuset=/ mems_allowed=0
[  222.172956] CPU: 4 PID: 1748 Comm: a.out Tainted: G                T 4.19.0-rc2+ #690
[  222.176517] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  222.180892] Call Trace:
[  222.182947]  dump_stack+0x85/0xcb
[  222.185240]  dump_header+0x69/0x2fe
[  222.187579]  ? _raw_spin_unlock_irqrestore+0x41/0x70
[  222.190319]  oom_kill_process+0x307/0x390
[  222.192803]  out_of_memory+0x2f3/0x5d0
[  222.195190]  __alloc_pages_slowpath+0xc01/0x1030
[  222.197844]  __alloc_pages_nodemask+0x333/0x390
[  222.200452]  alloc_pages_vma+0x77/0x1f0
[  222.202869]  __handle_mm_fault+0x81c/0xf40
[  222.205334]  handle_mm_fault+0x1b7/0x3c0
[  222.207712]  __do_page_fault+0x2a6/0x580
[  222.210036]  do_page_fault+0x32/0x270
[  222.212266]  ? page_fault+0x8/0x30
[  222.214402]  page_fault+0x1e/0x30
[  222.216463] RIP: 0033:0x4008d8
[  222.218429] Code: Bad RIP value.
[  222.220388] RSP: 002b:00007fff34061350 EFLAGS: 00010206
[  222.222931] RAX: 00007efea3c2e010 RBX: 0000000100000000 RCX: 0000000000000000
[  222.225976] RDX: 00000000b190f000 RSI: 0000000000020000 RDI: 0000000200000050
[  222.228891] RBP: 00007efea3c2e010 R08: 0000000200001000 R09: 0000000000021000
[  222.231779] R10: 0000000000000022 R11: 0000000000001000 R12: 0000000000000006
[  222.234626] R13: 00007fff34061440 R14: 0000000000000000 R15: 0000000000000000
[  222.238482] Mem-Info:
[  222.240511] active_anon:789816 inactive_anon:3457 isolated_anon:0
[  222.240511]  active_file:11 inactive_file:44 isolated_file:0
[  222.240511]  unevictable:0 dirty:6 writeback:0 unstable:0
[  222.240511]  slab_reclaimable:8052 slab_unreclaimable:24408
[  222.240511]  mapped:1898 shmem:3704 pagetables:4316 bounce:0
[  222.240511]  free:20841 free_pcp:0 free_cma:0
[  222.254349] Node 0 active_anon:3159264kB inactive_anon:13828kB active_file:44kB inactive_file:176kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:7592kB dirty:24kB writeback:0kB shmem:14816kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 2793472kB writeback_tmp:0kB unstable:0kB all_unreclaimable? yes
[  222.264038] Node 0 DMA free:13812kB min:308kB low:384kB high:460kB active_anon:1876kB inactive_anon:8kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  222.274208] lowmem_reserve[]: 0 2674 3378 3378
[  222.276831] Node 0 DMA32 free:56068kB min:53260kB low:66572kB high:79884kB active_anon:2673292kB inactive_anon:216kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2738564kB mlocked:0kB kernel_stack:96kB pagetables:3024kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  222.287961] lowmem_reserve[]: 0 0 703 703
[  222.291154] Node 0 Normal free:13672kB min:14012kB low:17512kB high:21012kB active_anon:483864kB inactive_anon:13604kB active_file:0kB inactive_file:4kB unevictable:0kB writepending:0kB present:1048576kB managed:720644kB mlocked:0kB kernel_stack:7520kB pagetables:14272kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  222.302407] lowmem_reserve[]: 0 0 0 0
[  222.304596] Node 0 DMA: 1*4kB (M) 0*8kB 1*16kB (U) 7*32kB (UM) 4*64kB (U) 4*128kB (UM) 2*256kB (U) 0*512kB 0*1024kB 0*2048kB 3*4096kB (ME) = 13812kB
[  222.311748] Node 0 DMA32: 37*4kB (U) 29*8kB (UM) 20*16kB (UM) 30*32kB (UME) 28*64kB (UME) 11*128kB (UME) 9*256kB (UME) 8*512kB (UM) 6*1024kB (UME) 1*2048kB (E) 9*4096kB (UM) = 56316kB
[  222.318932] Node 0 Normal: 151*4kB (UM) 2*8kB (UM) 97*16kB (UM) 195*32kB (UME) 53*64kB (UME) 11*128kB (UME) 2*256kB (UM) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 13724kB
[  222.325455] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  222.329059] 3707 total pagecache pages
[  222.331315] 0 pages in swap cache
[  222.333440] Swap cache stats: add 0, delete 0, find 0/0
[  222.336097] Free swap  = 0kB
[  222.338091] Total swap = 0kB
[  222.340084] 1048422 pages RAM
[  222.342165] 0 pages HighMem/MovableOnly
[  222.344460] 179651 pages reserved
[  222.347423] 0 pages cma reserved
[  222.349793] 0 pages hwpoisoned
[  222.351784] Out of memory: Kill process 1748 (a.out) score 838 or sacrifice child
[  222.355131] Killed process 1748 (a.out) total-vm:4267252kB, anon-rss:2909224kB, file-rss:0kB, shmem-rss:0kB
[  222.359644] java invoked oom-killer: gfp_mask=0x6200ca(GFP_HIGHUSER_MOVABLE), nodemask=(null), order=0, oom_score_adj=0
[  222.364180] java cpuset=/ mems_allowed=0
[  222.366619] CPU: 0 PID: 1110 Comm: java Tainted: G                T 4.19.0-rc2+ #690
[  222.370088] Hardware name: VMware, Inc. VMware Virtual Platform/440BX Desktop Reference Platform, BIOS 6.00 05/19/2017
[  222.377089] Call Trace:
[  222.380503]  dump_stack+0x85/0xcb
[  222.380509]  dump_header+0x69/0x2fe
[  222.380515]  ? _raw_spin_unlock_irqrestore+0x41/0x70
[  222.380518]  oom_kill_process+0x307/0x390
[  222.380553]  out_of_memory+0x2f3/0x5d0
[  222.396414]  __alloc_pages_slowpath+0xc01/0x1030
[  222.396423]  __alloc_pages_nodemask+0x333/0x390
[  222.396431]  filemap_fault+0x465/0x910
[  222.404090]  ? xfs_ilock+0xbf/0x2b0 [xfs]
[  222.404118]  ? __xfs_filemap_fault+0x7d/0x2c0 [xfs]
[  222.404124]  ? down_read_nested+0x66/0xa0
[  222.404148]  __xfs_filemap_fault+0x8e/0x2c0 [xfs]
[  222.404156]  __do_fault+0x11/0x133
[  222.404158]  __handle_mm_fault+0xa57/0xf40
[  222.404165]  handle_mm_fault+0x1b7/0x3c0
[  222.404171]  __do_page_fault+0x2a6/0x580
[  222.404187]  do_page_fault+0x32/0x270
[  222.404194]  ? page_fault+0x8/0x30
[  222.404196]  page_fault+0x1e/0x30
[  222.404199] RIP: 0033:0x7fedb229ed42
[  222.404205] Code: Bad RIP value.
[  222.404207] RSP: 002b:00007fed92ae9c90 EFLAGS: 00010202
[  222.404209] RAX: ffffffffffffff92 RBX: 00007fedb187c470 RCX: 00007fedb229ed42
[  222.404210] RDX: 0000000000000001 RSI: 0000000000000089 RDI: 00007fedac13c354
[  222.404211] RBP: 00007fed92ae9d50 R08: 00007fedac13c328 R09: 00000000ffffffff
[  222.404212] R10: 00007fed92ae9cf0 R11: 0000000000000202 R12: 0000000000000001
[  222.404213] R13: 00007fed92ae9cf0 R14: ffffffffffffff92 R15: 00007fedac13c300
[  222.404783] Mem-Info:
[  222.404790] active_anon:429056 inactive_anon:3457 isolated_anon:0
[  222.404790]  active_file:0 inactive_file:833 isolated_file:0
[  222.404790]  unevictable:0 dirty:0 writeback:0 unstable:0
[  222.404790]  slab_reclaimable:8052 slab_unreclaimable:24344
[  222.404790]  mapped:2375 shmem:3704 pagetables:3030 bounce:0
[  222.404790]  free:381368 free_pcp:89 free_cma:0
[  222.404793] Node 0 active_anon:1716224kB inactive_anon:13828kB active_file:0kB inactive_file:3332kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:9500kB dirty:0kB writeback:0kB shmem:14816kB shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 155648kB writeback_tmp:0kB unstable:0kB all_unreclaimable? no
[  222.404794] Node 0 DMA free:13812kB min:308kB low:384kB high:460kB active_anon:1876kB inactive_anon:8kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15960kB managed:15876kB mlocked:0kB kernel_stack:0kB pagetables:4kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  222.404798] lowmem_reserve[]: 0 2674 3378 3378
[  222.404802] Node 0 DMA32 free:1362940kB min:53260kB low:66572kB high:79884kB active_anon:1366928kB inactive_anon:216kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:3129152kB managed:2738564kB mlocked:0kB kernel_stack:96kB pagetables:3028kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
[  222.404831] lowmem_reserve[]: 0 0 703 703
[  222.404837] Node 0 Normal free:149160kB min:14012kB low:17512kB high:21012kB active_anon:348116kB inactive_anon:13604kB active_file:0kB inactive_file:3080kB unevictable:0kB writepending:0kB present:1048576kB managed:720644kB mlocked:0kB kernel_stack:7504kB pagetables:9088kB bounce:0kB free_pcp:376kB local_pcp:12kB free_cma:0kB
[  222.404841] lowmem_reserve[]: 0 0 0 0
[  222.404859] Node 0 DMA: 1*4kB (M) 0*8kB 1*16kB (U) 7*32kB (UM) 4*64kB (U) 4*128kB (UM) 2*256kB (U) 0*512kB 0*1024kB 0*2048kB 3*4096kB (ME) = 13812kB
[  222.405114] Node 0 DMA32: 37*4kB (U) 29*8kB (UM) 20*16kB (UM) 30*32kB (UME) 28*64kB (UME) 11*128kB (UME) 9*256kB (UME) 8*512kB (UM) 6*1024kB (UME) 10*2048kB (ME) 326*4096kB (UM) = 1373180kB
[  222.405423] Node 0 Normal: 512*4kB (U) 1075*8kB (UM) 1667*16kB (UM) 1226*32kB (UME) 497*64kB (UME) 209*128kB (UME) 50*256kB (UM) 0*512kB 0*1024kB 0*2048kB 1*4096kB (M) = 152008kB
[  222.405797] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
[  222.405799] 4655 total pagecache pages
[  222.405801] 0 pages in swap cache
[  222.405802] Swap cache stats: add 0, delete 0, find 0/0
[  222.405803] Free swap  = 0kB
[  222.405803] Total swap = 0kB
[  222.405835] 1048422 pages RAM
[  222.405837] 0 pages HighMem/MovableOnly
[  222.405838] 179651 pages reserved
[  222.405839] 0 pages cma reserved
[  222.405840] 0 pages hwpoisoned
[  222.405843] Out of memory: Kill process 1074 (java) score 50 or sacrifice child
[  222.406136] Killed process 1074 (java) total-vm:5555688kB, anon-rss:174244kB, file-rss:0kB, shmem-rss:0kB
[  222.443446] oom_reaper: reaped process 1748 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
