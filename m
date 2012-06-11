Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id B32676B005A
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 15:14:05 -0400 (EDT)
Date: Mon, 11 Jun 2012 15:13:59 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [patch 3.5-rc2] mm, oom: fix and cleanup oom score calculations
Message-ID: <20120611191359.GA3695@redhat.com>
References: <alpine.DEB.2.00.1206041629500.7769@chino.kir.corp.google.com>
 <20120605174454.GA23867@redhat.com>
 <alpine.DEB.2.00.1206081313000.19054@chino.kir.corp.google.com>
 <20120608210330.GA21010@redhat.com>
 <alpine.DEB.2.00.1206091920140.7832@chino.kir.corp.google.com>
 <4FD412CB.9060809@gmail.com>
 <20120610201055.GA27662@redhat.com>
 <alpine.DEB.2.00.1206101652180.18114@chino.kir.corp.google.com>
 <20120611004602.GA29713@redhat.com>
 <alpine.DEB.2.00.1206110209080.6843@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1206110209080.6843@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 11, 2012 at 02:11:50AM -0700, David Rientjes wrote:
 > The divide in p->signal->oom_score_adj * totalpages / 1000 within 
 > oom_badness() was causing an overflow of the signed long data type.
 > 
 > This adds both the root bias and p->signal->oom_score_adj before doing the 
 > normalization which fixes the issue and also cleans up the calculation.
 > 
 > Tested-by: Dave Jones <davej@redhat.com>
 > Signed-off-by: David Rientjes <rientjes@google.com>

Even with this, I'm still seeing the wrong processes getting killed..


[17384.172181] trinity-child4 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0, oom_score_adj=0
[17384.172435] trinity-child4 cpuset=/ mems_allowed=0
[17384.172463] Pid: 32149, comm: trinity-child4 Not tainted 3.5.0-rc2+ #86
[17384.172495] Call Trace:
[17384.172515]  [<ffffffff8164e2f5>] ? _raw_spin_unlock+0x55/0x60
[17384.172547]  [<ffffffff81144014>] dump_header+0x84/0x350
[17384.172576]  [<ffffffff810b7f35>] ? trace_hardirqs_on_caller+0x115/0x1a0
[17384.172610]  [<ffffffff8164e262>] ? _raw_spin_unlock_irqrestore+0x42/0x80
[17384.172646]  [<ffffffff8131face>] ? ___ratelimit+0x9e/0x130
[17384.172676]  [<ffffffff8114486e>] oom_kill_process+0x1ee/0x340
[17384.172707]  [<ffffffff81144ea9>] out_of_memory+0x249/0x410
[17384.172737]  [<ffffffff8114aded>] __alloc_pages_nodemask+0xa6d/0xab0
[17384.172770]  [<ffffffff8118a9e6>] alloc_pages_vma+0xb6/0x190
[17384.172802]  [<ffffffff81169c0a>] do_wp_page+0xca/0x790
[17384.172830]  [<ffffffff8164e2d5>] ? _raw_spin_unlock+0x35/0x60
[17384.172861]  [<ffffffff8116becd>] handle_pte_fault+0x73d/0x9d0
[17384.172891]  [<ffffffff810b26b0>] ? lock_release_holdtime.part.24+0x90/0x140
[17384.172928]  [<ffffffff8116c96f>] handle_mm_fault+0x21f/0x2e0
[17384.172960]  [<ffffffff8165158b>] do_page_fault+0x13b/0x4b0
[17384.172990]  [<ffffffff81086f91>] ? get_parent_ip+0x11/0x50
[17384.173019]  [<ffffffff81086f91>] ? get_parent_ip+0x11/0x50
[17384.173049]  [<ffffffff81651c59>] ? sub_preempt_count+0x79/0xd0
[17384.173080]  [<ffffffff8164e903>] ? error_sti+0x5/0x6
[17384.173991]  [<ffffffff813271bd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[17384.174894]  [<ffffffff8164e70f>] page_fault+0x1f/0x30
[17384.175830]  [<ffffffff810b26b0>] ? lock_release_holdtime.part.24+0x90/0x140
[17384.176751]  [<ffffffff810b1fde>] ? put_lock_stats.isra.23+0xe/0x40
[17384.177643]  [<ffffffff8132705d>] ? __put_user_4+0x1d/0x30
[17384.178517]  [<ffffffff8106611c>] ? sys_getresuid+0x7c/0xd0
[17384.179383]  [<ffffffff81655c52>] system_call_fastpath+0x16/0x1b
[17384.180238] Mem-Info:
[17384.180996] Node 0 DMA per-cpu:
[17384.181652] CPU    0: hi:    0, btch:   1 usd:   0
[17384.182306] CPU    1: hi:    0, btch:   1 usd:   0
[17384.182944] CPU    2: hi:    0, btch:   1 usd:   0
[17384.183567] CPU    3: hi:    0, btch:   1 usd:   0
[17384.184177] CPU    4: hi:    0, btch:   1 usd:   0
[17384.184772] CPU    5: hi:    0, btch:   1 usd:   0
[17384.185442] CPU    6: hi:    0, btch:   1 usd:   0
[17384.186020] CPU    7: hi:    0, btch:   1 usd:   0
[17384.186591] Node 0 DMA32 per-cpu:
[17384.187158] CPU    0: hi:  186, btch:  31 usd:   1
[17384.187723] CPU    1: hi:  186, btch:  31 usd:   4
[17384.188271] CPU    2: hi:  186, btch:  31 usd:  35
[17384.188809] CPU    3: hi:  186, btch:  31 usd:  47
[17384.189338] CPU    4: hi:  186, btch:  31 usd:  21
[17384.189857] CPU    5: hi:  186, btch:  31 usd:  85
[17384.190367] CPU    6: hi:  186, btch:  31 usd: 134
[17384.190854] CPU    7: hi:  186, btch:  31 usd:  82
[17384.191328] Node 0 Normal per-cpu:
[17384.191795] CPU    0: hi:  186, btch:  31 usd:   5
[17384.192260] CPU    1: hi:  186, btch:  31 usd:   0
[17384.192717] CPU    2: hi:  186, btch:  31 usd:  35
[17384.193169] CPU    3: hi:  186, btch:  31 usd:  43
[17384.193611] CPU    4: hi:  186, btch:  31 usd:  46
[17384.194045] CPU    5: hi:  186, btch:  31 usd:  82
[17384.194472] CPU    6: hi:  186, btch:  31 usd:  31
[17384.194892] CPU    7: hi:  186, btch:  31 usd:  36
[17384.195345] active_anon:20877 inactive_anon:20816 isolated_anon:542
[17384.195345]  active_file:142 inactive_file:490 isolated_file:0
[17384.195345]  unevictable:97 dirty:0 writeback:20142 unstable:0
[17384.195345]  free:22184 slab_reclaimable:29060 slab_unreclaimable:581537
[17384.195345]  mapped:164 shmem:888 pagetables:3103 bounce:0
[17384.197465] Node 0 DMA free:15776kB min:264kB low:328kB high:396kB active_anon:0kB inactive_anon:44kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15632kB mlocked:0kB dirty:0kB writeback:60kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:48kB kernel_stack:8kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2264 all_unreclaimable? yes
[17384.199388] lowmem_reserve[]: 0 2643 3878 3878
[17384.199895] Node 0 DMA32 free:51032kB min:45888kB low:57360kB high:68832kB active_anon:49052kB inactive_anon:49232kB active_file:8kB inactive_file:0kB unevictable:208kB isolated(anon):1504kB isolated(file):208kB present:2707204kB mlocked:208kB dirty:0kB writeback:49584kB mapped:404kB shmem:24kB slab_reclaimable:4304kB slab_unreclaimable:1914140kB kernel_stack:602920kB pagetables:3132kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:234420 all_unreclaimable? yes
[17384.202166] lowmem_reserve[]: 0 0 1234 1234
[17384.202751] Node 0 Normal free:21928kB min:21424kB low:26780kB high:32136kB active_anon:34460kB inactive_anon:33988kB active_file:560kB inactive_file:2140kB unevictable:180kB isolated(anon):664kB isolated(file):0kB present:1264032kB mlocked:180kB dirty:0kB writeback:30924kB mapped:252kB shmem:3528kB slab_reclaimable:111936kB slab_unreclaimable:411960kB kernel_stack:492392kB pagetables:9280kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:142173 all_unreclaimable? yes
[17384.205361] lowmem_reserve[]: 0 0 0 0
[17384.206038] Node 0 DMA: 1*4kB 3*8kB 4*16kB 0*32kB 1*64kB 2*128kB 2*256kB 1*512kB 2*1024kB 2*2048kB 2*4096kB = 15772kB
[17384.206747] Node 0 DMA32: 785*4kB 310*8kB 495*16kB 273*32kB 340*64kB 47*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 52100kB
[17384.208180] Node 0 Normal: 240*4kB 2342*8kB 6*16kB 0*32kB 0*64kB 1*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 21968kB
[17384.208952] 25433 total pagecache pages
[17384.209725] 23956 pages in swap cache
[17384.210503] Swap cache stats: add 1989506, delete 1965550, find 7882958/7981228
[17384.211307] Free swap  = 5833752kB
[17384.212115] Total swap = 6029308kB
[17384.220271] 1041904 pages RAM
[17384.221089] 70330 pages reserved
[17384.221894] 17795 pages shared
[17384.222698] 806729 pages non-shared
[17384.223507] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[17384.224410] [  327]     0   327     7866        1   7       0             0 systemd-journal
[17384.225345] [  334]     0   334     6566        1   2     -17         -1000 udevd
[17384.226282] [  482]     0   482    86847        1   0       0             0 NetworkManager
[17384.227205] [  485]     0   485     4866        1   0       0             0 smartd
[17384.228082] [  487]     0   487    29598        1   0       0             0 crond
[17384.228953] [  489]     0   489     7068        1   6       0             0 systemd-logind
[17384.229823] [  490]    38   490     8301        1   5       0             0 ntpd
[17384.230746] [  503]    81   503     5435        1   4     -13          -900 dbus-daemon
[17384.231678] [  506]     0   506    47106        1   7     -13          -900 polkitd
[17384.232614] [  510]     0   510    17260        1   0     -13          -900 modem-manager
[17384.233560] [  511]     0   511    27239        1   7       0             0 agetty
[17384.234564] [  522]     0   522     4790       16   3       0             0 rpcbind
[17384.235628] [  530]     0   530    22206        1   0       0             0 dhclient
[17384.236634] [  536]     0   536    19403        1   6     -17         -1000 sshd
[17384.237599] [  578]    29   578     5883        1   2       0             0 rpc.statd
[17384.238561] [  585]     0   585     5993        1   1       0             0 rpc.mountd
[17384.239522] [  588]     0   588     5845        1   3       0             0 rpc.idmapd
[17384.240479] [  598]     0   598    60782        1   5       0             0 rsyslogd
[17384.241427] [  616]     0   616    21273       38   2       0             0 sendmail
[17384.242358] [  636]    51   636    20167        1   4       0             0 sendmail
[17384.243267] [  786]  1000   786     6100       78   7       0             0 tmux
[17384.244158] [  787]  1000   787    28989        1   4       0             0 bash
[17384.244996] [  861]  1000   861    28022        2   2       0             0 test-random.sh
[17384.245892] [  868]  1000   868     4433       19   1       0             0 trinity
[17384.246744] [  869]  1000   869     4417        5   4       0             0 trinity
[17384.247574] [  870]  1000   870     4365       18   4       0             0 trinity
[17384.248332] [  871]  1000   871     4347        1   7       0             0 trinity
[17384.249117] [  872]  1000   872     4387       19   2       0             0 trinity
[17384.249885] [  873]  1000   873     4285       19   7       0             0 trinity
[17384.250582] [  874]  1000   874     4293       14   0       0             0 trinity
[17384.251258] [  875]  1000   875     4423       20   4       0             0 trinity
[17384.251910] [  876]  1000   876     4365       16   4       0             0 trinity
[17384.252537] [  877]  1000   877     4391       19   2       0             0 trinity
[17384.253149] [  878]  1000   878     4377       10   1       0             0 trinity
[17384.253741] [  879]  1000   879     4347        9   7       0             0 trinity
[17384.254313] [  880]  1000   880     4401       10   4       0             0 trinity
[17384.254877] [  881]  1000   881     4429       18   1       0             0 trinity
[17384.255406] [  882]  1000   882     4389        7   4       0             0 trinity
[17384.255913] [  883]  1000   883     4389       17   2       0             0 trinity
[17384.256414] [  973]     0   973     6566        1   6     -17         -1000 udevd
[17384.256912] [  974]     0   974     6549        1   3     -17         -1000 udevd
[17384.257399] [ 4895]  1000  4895     4387       30   6       0             0 trinity-watchdo
[17384.257897] [ 4952]  1000  4952     4365       28   4       0             0 trinity-watchdo
[17384.258394] [ 4953]  1000  4953     4433       31   1       0             0 trinity-watchdo
[17384.258890] [ 4954]  1000  4954     4347       23   5       0             0 trinity-watchdo
[17384.259389] [ 5300]  1000  5300     4417       16   1       0             0 trinity-watchdo
[17384.259886] [ 5688]  1000  5688     4389       15   6       0             0 trinity-watchdo
[17384.260373] [ 5868]  1000  5868     4429       30   3       0             0 trinity-watchdo
[17384.260847] [ 5972]  1000  5972     4377       20   2       0             0 trinity-watchdo
[17384.261314] [ 5973]  1000  5973     4389       29   4       0             0 trinity-watchdo
[17384.261775] [ 6125]  1000  6125     4347       19   4       0             0 trinity-watchdo
[17384.262232] [ 6136]  1000  6136     4293       18   2       0             0 trinity-watchdo
[17384.262688] [ 6137]  1000  6137     4401       17   6       0             0 trinity-watchdo
[17384.263143] [ 6138]  1000  6138     4423       29   6       0             0 trinity-watchdo
[17384.263593] [ 6139]  1000  6139     4285       30   4       0             0 trinity-watchdo
[17384.264036] [ 6227]  1000  6227     4365       31   6       0             0 trinity-watchdo
[17384.264476] [ 6288]  1000  6288     4391       30   3       0             0 trinity-watchdo
[17384.264930] [30721]  1000 30721     5239       24   7       0             0 trinity-child7
[17384.265361] [30881]  1000 30881     4897       27   2       0             0 trinity-child2
[17384.265791] [30921]  1000 30921     4389      242   0       0             0 trinity-child0
[17384.266216] [30928]  1000 30928     5479       36   0       0             0 trinity-child0
[17384.266637] [30939]  1000 30939     4864       33   1       0             0 trinity-child1
[17384.267052] [31051]  1000 31051     4365      171   2       0             0 trinity-child2
[17384.267467] [31052]  1000 31052     5849     1345   1       0             0 trinity-child1
[17384.267882] [31103]  1000 31103     6277     1764   6       0             0 trinity-child6
[17384.268297] [31109]  1000 31109     4429      109   7       0             0 trinity-child7
[17384.268709] [31137]  1000 31137     4465      303   0       0             0 trinity-child0
[17384.269124] [31141]  1000 31141     5220       65   3       0             0 trinity-child3
[17384.269535] [31158]  1000 31158     4425       70   3       0             0 trinity-child3
[17384.269948] [31160]  1000 31160     5978     1899   7       0             0 trinity-child7
[17384.270355] [31178]  1000 31178     4429      228   0       0             0 trinity-child0
[17384.270761] [31245]  1000 31245     4391      208   0       0             0 trinity-child0
[17384.271162] [31284]  1000 31284     5089      109   1       0             0 trinity-child1
[17384.271575] [31333]  1000 31333     5201      309   2       0             0 trinity-child2
[17384.271984] [31349]  1000 31349     4781      189   0       0             0 trinity-child0
[17384.272393] [31358]  1000 31358     4743       24   5       0             0 trinity-child5
[17384.272806] [31359]  1000 31359     4347       34   3       0             0 trinity-child3
[17384.273219] [31360]  1000 31360     4644       34   6       0             0 trinity-child6
[17384.273634] [31362]  1000 31362     4347       34   1       0             0 trinity-child1
[17384.274049] [31363]  1000 31363     4347       29   2       0             0 trinity-child2
[17384.274466] [31364]  1000 31364     4347       24   4       0             0 trinity-child4
[17384.274892] [31365]  1000 31365     4347       17   0       0             0 trinity-child0
[17384.275305] [31409]  1000 31409     4347        1   3       0             0 trinity-child3
[17384.275719] [31620]  1000 31620     6661       31   7       0             0 trinity-child7
[17384.276134] [31621]  1000 31621     7161       43   5       0             0 trinity-child5
[17384.276550] [31654]  1000 31654     5576       35   4       0             0 trinity-child4
[17384.276972] [31666]  1000 31666     4377       31   0       0             0 trinity-child0
[17384.277385] [31739]  1000 31739     4347       30   6       0             0 trinity-child6
[17384.277797] [31742]  1000 31742     4816      312   7       0             0 trinity-child7
[17384.278203] [31743]  1000 31743     4865      505   0       0             0 trinity-child0
[17384.278609] [31744]  1000 31744     4864       26   3       0             0 trinity-child3
[17384.279016] [31745]  1000 31745     4863       47   5       0             0 trinity-child5
[17384.279422] [31746]  1000 31746     4863       28   4       0             0 trinity-child4
[17384.279829] [31747]  1000 31747     4898       25   7       0             0 trinity-child7
[17384.280235] [31748]  1000 31748     4901       27   5       0             0 trinity-child5
[17384.280642] [31749]  1000 31749     4293       27   4       0             0 trinity-child4
[17384.281049] [31750]  1000 31750     4524      311   0       0             0 trinity-child0
[17384.281460] [31751]  1000 31751     4389       23   3       0             0 trinity-child3
[17384.281870] [31752]  1000 31752     5479       83   2       0             0 trinity-child2
[17384.282279] [31753]  1000 31753     5913      506   6       0             0 trinity-child6
[17384.282689] [31754]  1000 31754     5908      479   4       0             0 trinity-child4
[17384.283103] [31755]  1000 31755     4951       61   7       0             0 trinity-child7
[17384.283518] [31756]  1000 31756     4389       23   5       0             0 trinity-child5
[17384.283936] [31757]  1000 31757     4389       23   1       0             0 trinity-child1
[17384.284350] [31758]  1000 31758     5128      196   6       0             0 trinity-child6
[17384.284786] [31779]  1000 31779     4326       70   7       0             0 trinity-child7
[17384.285206] [31838]  1000 31838     4464      371   5       0             0 trinity-child5
[17384.285620] [31839]  1000 31839     4543      427   1       0             0 trinity-child1
[17384.286037] [31840]  1000 31840     4431      313   6       0             0 trinity-child6
[17384.286454] [31859]  1000 31859     4541      427   2       0             0 trinity-child2
[17384.286867] [31865]  1000 31865     4327       94   6       0             0 trinity-child6
[17384.287281] [31876]  1000 31876     4374      382   6       0             0 trinity-child6
[17384.287693] [31877]  1000 31877     4365      348   0       0             0 trinity-child0
[17384.288105] [31878]  1000 31878     4365      344   1       0             0 trinity-child1
[17384.288516] [31879]  1000 31879     4365      333   5       0             0 trinity-child5
[17384.288922] [31880]  1000 31880     4374      381   7       0             0 trinity-child7
[17384.289328] [31882]  1000 31882     4364      298   4       0             0 trinity-child4
[17384.289735] [31884]  1000 31884     4364      344   3       0             0 trinity-child3
[17384.290139] [31895]  1000 31895     4431      352   3       0             0 trinity-child3
[17384.290543] [31979]  1000 31979     4389      369   4       0             0 trinity-child4
[17384.290944] [31980]  1000 31980     4425      280   5       0             0 trinity-child5
[17384.291348] [31981]  1000 31981     5216     1164   2       0             0 trinity-child2
[17384.291750] [31983]  1000 31983     5546     1489   1       0             0 trinity-child1
[17384.292154] [31984]  1000 31984     4753      737   5       0             0 trinity-child5
[17384.292557] [31985]  1000 31985     5021      989   1       0             0 trinity-child1
[17384.292962] [31986]  1000 31986     4389      419   7       0             0 trinity-child7
[17384.293369] [31987]  1000 31987     4984      952   3       0             0 trinity-child3
[17384.293778] [31988]  1000 31988     4389      445   6       0             0 trinity-child6
[17384.294190] [31989]  1000 31989     6310     2260   6       0             0 trinity-child6
[17384.294603] [32072]  1000 32072     4648      568   2       0             0 trinity-child2
[17384.295026] [32073]  1000 32073     4285      227   1       0             0 trinity-child1
[17384.295441] [32074]  1000 32074     4648      609   3       0             0 trinity-child3
[17384.295856] [32079]  1000 32079     4429      292   3       0             0 trinity-child3
[17384.296267] [32083]  1000 32083     4429      292   4       0             0 trinity-child4
[17384.296677] [32084]  1000 32084     4549      538   5       0             0 trinity-child5
[17384.297083] [32085]  1000 32085     4648      567   6       0             0 trinity-child6
[17384.297490] [32094]  1000 32094     4429      128   5       0             0 trinity-child5
[17384.297899] [32095]  1000 32095     4429       34   3       0             0 trinity-child2
[17384.298306] [32104]  1000 32104     4465      330   7       0             0 trinity-child7
[17384.298715] [32117]  1000 32117     4648      577   4       0             0 trinity-child4
[17384.299128] [32128]  1000 32128     4458      382   4       0             0 trinity-child4
[17384.299537] [32131]  1000 32131     4433      126   6       0             0 trinity-child6
[17384.299948] [32132]  1000 32132     4433      120   5       0             0 trinity-child5
[17384.300356] [32133]  1000 32133     4432      373   7       0             0 trinity-child7
[17384.300764] [32135]  1000 32135     4433      121   1       0             0 trinity-child1
[17384.301172] [32136]  1000 32136     4432      344   2       0             0 trinity-child2
[17384.301581] [32138]  1000 32138     4387      152   2       0             0 trinity-child2
[17384.301987] [32146]  1000 32146     4387      148   3       0             0 trinity-child3
[17384.302391] [32148]  1000 32148     4433       74   0       0             0 trinity-child0
[17384.302795] [32149]  1000 32149     4433      103   4       0             0 trinity-child4
[17384.303200] [32150]  1000 32150     4433      115   3       0             0 trinity-child3
[17384.303606] [32151]  1000 32151     4285      200   7       0             0 trinity-child7
[17384.304011] [32162]  1000 32162     4365      160   4       0             0 trinity-child4
[17384.304417] [32163]  1000 32163     4387      156   1       0             0 trinity-child1
[17384.304832] [32178]  1000 32178     4387       35   1       0             0 trinity-child6
[17384.305238] [32179]  1000 32179     4391      214   2       0             0 trinity-child2
[17384.305646] [32180]  1000 32180     4387      147   0       0             0 trinity-child0
[17384.306053] [32181]  1000 32181     4387      153   4       0             0 trinity-child4
[17384.306459] [32182]  1000 32182     4423      225   4       0             0 trinity-child4
[17384.306865] [32183]  1000 32183     4885      621   5       0             0 trinity-child5
[17384.307270] [32184]  1000 32184     4885      632   1       0             0 trinity-child1
[17384.307676] [32185]  1000 32185     4423      233   6       0             0 trinity-child6
[17384.308086] [32186]  1000 32186     4423      142   2       0             0 trinity-child2
[17384.308493] [32187]  1000 32187     4423      118   0       0             0 trinity-child0
[17384.308897] [32188]  1000 32188     4423      185   7       0             0 trinity-child7
[17384.309302] [32189]  1000 32189     4423      232   3       0             0 trinity-child3
[17384.309707] [32190]  1000 32190     4387       35   4       0             0 trinity-child5
[17384.310116] Out of memory: Kill process 503 (dbus-daemon) score 511952 or sacrifice child
[17384.310534] Killed process 503 (dbus-daemon) total-vm:21740kB, anon-rss:0kB, file-rss:4kB

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
