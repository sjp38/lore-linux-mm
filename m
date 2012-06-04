Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id A4D766B005C
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 11:27:16 -0400 (EDT)
Date: Mon, 4 Jun 2012 11:27:10 -0400
From: Dave Jones <davej@redhat.com>
Subject: oomkillers gone wild.
Message-ID: <20120604152710.GA1710@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

I managed to drive a machine into a state of constant oom killing.
Looking over the logs, it started killing a bunch of processes that look
'wrong' to me..

Here's the first example. From here it just gets worse, taking out
sshd & NetworkManager, and other useful things rather than the memory hogs.

	Dave

[21622.923039] modprobe invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0, oom_score_adj=0
[21622.924540] modprobe cpuset=/ mems_allowed=0
[21622.925989] Pid: 10940, comm: modprobe Not tainted 3.5.0-rc1+ #51
[21622.927447] Call Trace:
[21622.928984]  [<ffffffff816426b7>] dump_header+0x81/0x2d8
[21622.930427]  [<ffffffff810b7cd5>] ? trace_hardirqs_on_caller+0x115/0x1a0
[21622.931860]  [<ffffffff8164d742>] ? _raw_spin_unlock_irqrestore+0x42/0x80
[21622.933238]  [<ffffffff8131ee0e>] ? ___ratelimit+0x9e/0x130
[21622.934705]  [<ffffffff81144402>] oom_kill_process+0x282/0x2b0
[21622.936165]  [<ffffffff81144919>] out_of_memory+0x249/0x410
[21622.937688]  [<ffffffff8114a85d>] __alloc_pages_nodemask+0xa6d/0xab0
[21622.939215]  [<ffffffff81189cb6>] alloc_pages_vma+0xb6/0x190
[21622.940720]  [<ffffffff81168940>] __do_fault+0x2f0/0x530
[21622.942235]  [<ffffffff81086f81>] ? get_parent_ip+0x11/0x50
[21622.943802]  [<ffffffff81086f81>] ? get_parent_ip+0x11/0x50
[21622.945313]  [<ffffffff8116b253>] handle_pte_fault+0x93/0x9d0
[21622.946819]  [<ffffffff810b2450>] ? lock_release_holdtime.part.24+0x90/0x140
[21622.948527]  [<ffffffff8116c39f>] handle_mm_fault+0x21f/0x2e0
[21622.950080]  [<ffffffff81650a8b>] do_page_fault+0x13b/0x4b0
[21622.951620]  [<ffffffff81079c03>] ? up_write+0x23/0x40
[21622.953089]  [<ffffffff8164de03>] ? error_sti+0x5/0x6
[21622.954648]  [<ffffffff813264fd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[21622.956244]  [<ffffffff8164dc0f>] page_fault+0x1f/0x30
[21622.957866] Mem-Info:
[21622.959468] Node 0 DMA per-cpu:
[21622.961067] CPU    0: hi:    0, btch:   1 usd:   0
[21622.962682] CPU    1: hi:    0, btch:   1 usd:   0
[21622.964277] CPU    2: hi:    0, btch:   1 usd:   0
[21622.965877] CPU    3: hi:    0, btch:   1 usd:   0
[21622.967463] CPU    4: hi:    0, btch:   1 usd:   0
[21622.969056] CPU    5: hi:    0, btch:   1 usd:   0
[21622.970673] CPU    6: hi:    0, btch:   1 usd:   0
[21622.972272] CPU    7: hi:    0, btch:   1 usd:   0
[21622.973840] Node 0 DMA32 per-cpu:
[21622.975414] CPU    0: hi:  186, btch:  31 usd:  46
[21622.977075] CPU    1: hi:  186, btch:  31 usd:   0
[21622.978557] CPU    2: hi:  186, btch:  31 usd:  90
[21622.980103] CPU    3: hi:  186, btch:  31 usd: 102
[21622.981609] CPU    4: hi:  186, btch:  31 usd:   0
[21622.983067] CPU    5: hi:  186, btch:  31 usd:  70
[21622.984445] CPU    6: hi:  186, btch:  31 usd:  63
[21622.985854] CPU    7: hi:  186, btch:  31 usd:   0
[21622.987208] Node 0 Normal per-cpu:
[21622.988498] CPU    0: hi:  186, btch:  31 usd:   0
[21622.989772] CPU    1: hi:  186, btch:  31 usd:   0
[21622.990972] CPU    2: hi:  186, btch:  31 usd:   0
[21622.992201] CPU    3: hi:  186, btch:  31 usd:   0
[21622.993348] CPU    4: hi:  186, btch:  31 usd:   0
[21622.994475] CPU    5: hi:  186, btch:  31 usd:   0
[21622.995528] CPU    6: hi:  186, btch:  31 usd:   0
[21622.996551] CPU    7: hi:  186, btch:  31 usd:   0
[21622.997520] active_anon:38553 inactive_anon:39448 isolated_anon:224
[21622.997520]  active_file:84 inactive_file:233 isolated_file:0
[21622.997520]  unevictable:85 dirty:0 writeback:37692 unstable:0
[21622.997520]  free:19526 slab_reclaimable:23656 slab_unreclaimable:553126
[21622.997520]  mapped:50 shmem:1391 pagetables:2892 bounce:0
[21623.001856] Node 0 DMA free:15768kB min:264kB low:328kB high:396kB active_anon:20kB inactive_anon:100kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15632kB mlocked:0kB dirty:0kB writeback:100kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2 all_unreclaimable? no
[21623.004699] lowmem_reserve[]: 0 2643 3878 3878
[21623.005684] Node 0 DMA32 free:51344kB min:45888kB low:57360kB high:68832kB active_anon:153016kB inactive_anon:152172kB active_file:268kB inactive_file:916kB unevictable:340kB isolated(anon):896kB isolated(file):0kB present:2707204kB mlocked:340kB dirty:0kB writeback:149916kB mapped:200kB shmem:44kB slab_reclaimable:3696kB slab_unreclaimable:1524768kB kernel_stack:725000kB pagetables:6976kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[21623.008972] lowmem_reserve[]: 0 0 1234 1234
[21623.010090] Node 0 Normal free:10992kB min:21424kB low:26780kB high:32136kB active_anon:1176kB inactive_anon:5520kB active_file:68kB inactive_file:16kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1264032kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:5520kB slab_reclaimable:90928kB slab_unreclaimable:687736kB kernel_stack:306280kB pagetables:4592kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:154144 all_unreclaimable? yes
[21623.013696] lowmem_reserve[]: 0 0 0 0
[21623.014957] Node 0 DMA: 3*4kB 0*8kB 1*16kB 0*32kB 4*64kB 1*128kB 2*256kB 1*512kB 2*1024kB 2*2048kB 2*4096kB = 15772kB
[21623.016244] Node 0 DMA32: 740*4kB 306*8kB 113*16kB 101*32kB 219*64kB 104*128kB 39*256kB 4*512kB 1*1024kB 0*2048kB 0*4096kB = 50832kB
[21623.017559] Node 0 Normal: 1356*4kB 382*8kB 5*16kB 0*32kB 2*64kB 0*128kB 1*256kB 0*512kB 0*1024kB 1*2048kB 0*4096kB = 10992kB
[21623.018880] 41885 total pagecache pages
[21623.020193] 39819 pages in swap cache
[21623.021507] Swap cache stats: add 51603753, delete 51563934, find 307374090/308668676
[21623.022846] Free swap  = 5162300kB
[21623.024181] Total swap = 6029308kB
[21623.035243] 1041904 pages RAM
[21623.036660] 70330 pages reserved
[21623.038082] 9037 pages shared
[21623.039509] 814628 pages non-shared
[21623.040899] [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
[21623.042271] [  335]     0   335     7906        1   2       0             0 systemd-journal
[21623.043645] [  341]     0   341     6590        1   0     -17         -1000 udevd
[21623.045019] [  466]     0   466    86847        2   6       0             0 NetworkManager
[21623.046421] [  470]     0   470     4866        3   0       0             0 smartd
[21623.047891] [  476]     0   476    29599       10   2       0             0 crond
[21623.049313] [  487]     0   487     7068        1   7       0             0 systemd-logind
[21623.050768] [  488]    38   488     8301       10   6       0             0 ntpd
[21623.052189] [  501]    81   501     5435        1   7     -13          -900 dbus-daemon
[21623.053606] [  504]     0   504    47106        1   2     -13          -900 polkitd
[21623.054998] [  507]     0   507    27239        1   7       0             0 agetty
[21623.056575] [  509]     0   509    17260        1   3     -13          -900 modem-manager
[21623.058055] [  520]     0   520     4790        2   4       0             0 rpcbind
[21623.059532] [  530]     0   530    19403        1   5     -17         -1000 sshd
[21623.060988] [  554]     0   554    60782        1   0       0             0 rsyslogd
[21623.062421] [  562]    29   562     5883        1   4       0             0 rpc.statd
[21623.063957] [  570]     0   570     6361        1   1       0             0 rpc.idmapd
[21623.065440] [  571]     0   571     5993        1   3       0             0 rpc.mountd
[21623.066911] [  588]     0   588    22206        1   2       0             0 dhclient
[21623.068409] [  613]     0   613    21273       26   7       0             0 sendmail
[21623.069905] [  633]    51   633    20167       10   1       0             0 sendmail
[21623.071427] [  736]  1000   736     6212      139   7       0             0 tmux
[21623.072933] [  737]  1000   737    29011        1   4       0             0 bash
[21623.074461] [  811]  1000   811    28022        2   3       0             0 test-random.sh
[21623.075977] [  818]  1000   818     4295        7   3       0             0 trinity
[21623.077512] [  820]  1000   820     4311       16   5       0             0 trinity
[21623.079038] [  821]  1000   821     4309       11   6       0             0 trinity
[21623.080572] [  822]  1000   822     4317        9   1       0             0 trinity
[21623.082114] [  823]  1000   823     4301        9   5       0             0 trinity
[21623.083689] [  825]  1000   825     4229        8   4       0             0 trinity
[21623.085225] [  826]  1000   826     4335       14   4       0             0 trinity
[21623.086784] [  827]  1000   827     4403       13   6       0             0 trinity
[21623.088311] [  828]  1000   828     4343       10   5       0             0 trinity
[21623.089849] [  829]  1000   829     4287       16   6       0             0 trinity
[21623.091393] [  830]  1000   830     4319        9   3       0             0 trinity
[21623.092927] [  831]  1000   831     4321        7   5       0             0 trinity
[21623.094467] [  832]  1000   832     4327       15   2       0             0 trinity
[21623.096003] [  833]  1000   833     4389       14   4       0             0 trinity
[21623.097496] [  889]     0   889     6589        1   1     -17         -1000 udevd
[21623.098983] [  899]     0   899     6589        1   4     -17         -1000 udevd
[21623.100424] [23414]  1000 23414     4309       14   2       0             0 trinity-watchdo
[21623.101840] [23752]  1000 23752     4319        9   4       0             0 trinity-watchdo
[21623.103213] [23753]  1000 23753     4343       17   4       0             0 trinity-watchdo
[21623.104583] [23978]  1000 23978     4327       18   0       0             0 trinity-watchdo
[21623.105902] [24392]  1000 24392     4229       10   3       0             0 trinity-watchdo
[21623.107162] [24408]  1000 24408     4389       20   3       0             0 trinity-watchdo
[21623.108408] [24593]  1000 24593     4403       13   3       0             0 trinity-watchdo
[21623.109607] [24656]  1000 24656     4321       10   5       0             0 trinity-watchdo
[21623.110744] [24686]  1000 24686     4335       16   1       0             0 trinity-watchdo
[21623.111838] [25172]  1000 25172     4287       18   4       0             0 trinity-watchdo
[21623.112893] [25229]  1000 25229     4317       17   2       0             0 trinity-watchdo
[21623.113837] [25338]  1000 25338     4301       14   2       0             0 trinity-watchdo
[21623.114758] [27690]  1000 27690     4311       24   6       0             0 trinity-watchdo
[21623.115728] [29047]  1000 29047     4295       12   7       0             0 trinity-watchdo
[21623.116597] [ 7092]  1000  7092  1051124    31660   3       0             0 trinity-child3
[21623.117430] [ 8230]  1000  8230     5070       50   5       0             0 trinity-child5
[21623.118269] [ 8510]  1000  8510     8696      119   5       0             0 trinity-child5
[21623.119088] [ 8572]  1000  8572     4758       30   0       0             0 trinity-child0
[21623.119887] [ 9084]  1000  9084     4998       36   0       0             0 trinity-child0
[21623.120687] [ 9138]  1000  9138     4343       48   0       0             0 trinity-child0
[21623.121479] [ 9518]  1000  9518     4317       45   6       0             0 trinity-child6
[21623.122280] [ 9563]  1000  9563     4857      216   0       0             0 trinity-child0
[21623.123077] [ 9626]  1000  9626     4317       40   1       0             0 trinity-child1
[21623.123875] [ 9700]  1000  9700     4317       27   2       0             0 trinity-child2
[21623.124658] [ 9967]  1000  9967     4747       40   4       0             0 trinity-child4
[21623.125422] [10011]  1000 10011     4317       36   7       0             0 trinity-child7
[21623.126182] [10064]  1000 10064     4311       80   7       0             0 trinity-child7
[21623.126928] [10072]  1000 10072     4623      346   6       0             0 trinity-child6
[21623.127668] [10077]  1000 10077     4403      231   5       0             0 trinity-child5
[21623.128402] [10079]  1000 10079     4834      241   7       0             0 trinity-child7
[21623.129137] [10084]  1000 10084     4733      510   4       0             0 trinity-child4
[21623.129869] [10085]  1000 10085     4403       20   3       0             0 trinity-child3
[21623.130594] [10086]  1000 10086     4858       27   3       0             0 trinity-child3
[21623.131310] [10099]  1000 10099     4321       27   5       0             0 trinity-child5
[21623.132022] [10100]  1000 10100     4387       26   7       0             0 trinity-child7
[21623.132733] [10102]  1000 10102     5520       27   2       0             0 trinity-child2
[21623.133432] [10117]  1000 10117   532719      293   5       0             0 trinity-child5
[21623.134136] [10143]  1000 10143     4319       25   4       0             0 trinity-child4
[21623.134834] [10144]  1000 10144     4287      121   6       0             0 trinity-child6
[21623.135531] [10178]  1000 10178     4295       25   2       0             0 trinity-child2
[21623.136228] [10224]  1000 10224     4319       24   6       0             0 trinity-child6
[21623.136926] [10235]  1000 10235     4319       24   3       0             0 trinity-child3
[21623.137617] [10243]  1000 10243     4499       25   5       0             0 trinity-child5
[21623.138298] [10250]  1000 10250     4229       27   6       0             0 trinity-child6
[21623.138981] [10251]  1000 10251     4389      109   0       0             0 trinity-child0
[21623.139658] [10254]  1000 10254     4319       27   1       0             0 trinity-child1
[21623.140336] [10369]  1000 10369     5010       45   3       0             0 trinity-child3
[21623.141007] [10389]  1000 10389     4371       76   2       0             0 trinity-child2
[21623.141679] [10458]  1000 10458  1052885       46   6       0             0 trinity-child6
[21623.142343] [10460]  1000 10460     5431       39   2       0             0 trinity-child2
[21623.143016] [10461]  1000 10461     4804       38   7       0             0 trinity-child7
[21623.143689] [10462]  1000 10462     4309       30   3       0             0 trinity-child3
[21623.144358] [10475]  1000 10475     4229       23   1       0             0 trinity-child1
[21623.145033] [10476]  1000 10476     4499      284   0       0             0 trinity-child0
[21623.145711] [10478]  1000 10478     4301      111   3       0             0 trinity-child3
[21623.146382] [10482]  1000 10482     4337       86   7       0             0 trinity-child7
[21623.147064] [10485]  1000 10485     4862      116   2       0             0 trinity-child2
[21623.147743] [10499]  1000 10499     4424       82   5       0             0 trinity-child5
[21623.148423] [10526]  1000 10526     5136       36   1       0             0 trinity-child1
[21623.149111] [10538]  1000 10538     4403      137   1       0             0 trinity-child1
[21623.149796] [10553]  1000 10553     4951      355   1       0             0 trinity-child1
[21623.150483] [10554]  1000 10554     4472       25   2       0             0 trinity-child2
[21623.151155] [10555]  1000 10555     4321       40   0       0             0 trinity-child0
[21623.151840] [10650]  1000 10650     5152      208   1       0             0 trinity-child1
[21623.152515] [10685]  1000 10685     4429      366   4       0             0 trinity-child4
[21623.153180] [10693]  1000 10693     4301       68   6       0             0 trinity-child6
[21623.153855] [10694]  1000 10694     4522       64   6       0             0 trinity-child6
[21623.154532] [10712]  1000 10712     4723      656   3       0             0 trinity-child3
[21623.155202] [10713]  1000 10713     4335      219   5       0             0 trinity-child5
[21623.155877] [10714]  1000 10714     4335      251   4       0             0 trinity-child4
[21623.156555] [10715]  1000 10715     4813      682   7       0             0 trinity-child7
[21623.157226] [10761]  1000 10761     4335      234   2       0             0 trinity-child2
[21623.157904] [10777]  1000 10777     4336      279   6       0             0 trinity-child6
[21623.158580] [10788]  1000 10788     4311       48   0       0             0 trinity-child0
[21623.159250] [10789]  1000 10789     4575      466   2       0             0 trinity-child2
[21623.159927] [10790]  1000 10790     4311       60   4       0             0 trinity-child4
[21623.160607] [10791]  1000 10791     4344      276   6       0             0 trinity-child6
[21623.161279] [10792]  1000 10792     4617      574   3       0             0 trinity-child3
[21623.161950] [10793]  1000 10793     4311       55   5       0             0 trinity-child5
[21623.162618] [10794]  1000 10794     4311       52   1       0             0 trinity-child1
[21623.163277] [10795]  1000 10795     5094      974   1       0             0 trinity-child1
[21623.163939] [10802]  1000 10802     4335       82   0       0             0 trinity-child0
[21623.164605] [10813]  1000 10813     4327      113   1       0             0 trinity-child1
[21623.165271] [10846]  1000 10846     4521      273   7       0             0 trinity-child7
[21623.165938] [10856]  1000 10856     4422      217   4       0             0 trinity-child4
[21623.166605] [10880]  1000 10880     4287       71   2       0             0 trinity-child2
[21623.167266] [10884]  1000 10884     4287       53   0       0             0 trinity-child0
[21623.167936] [10894]  1000 10894     4308       53   0       0             0 trinity-child0
[21623.168604] [10897]  1000 10897     4287       77   4       0             0 trinity-child4
[21623.169257] [10905]  1000 10905     4309       52   4       0             0 trinity-child4
[21623.169920] [10907]  1000 10907     4403      300   6       0             0 trinity-child6
[21623.170581] [10924]  1000 10924     4287       69   7       0             0 trinity-child7
[21623.171242] [10931]  1000 10931     4389      143   3       0             0 trinity-child3
[21623.171910] [10938]     0 10938     3182       53   7       0             0 modprobe
[21623.172576] [10940]     0 10940     3726       24   1       0             0 modprobe
[21623.173239] [10942]     0 10942     3182       52   4       0             0 modprobe
[21623.173907] [10944]     0 10944     3726       43   3       0             0 modprobe
[21623.174577] [10945]     0 10945     3726       34   4       0             0 modprobe
[21623.175237] [10946]  1000 10946     4287       19   2       0             0 trinity
[21623.175906] Out of memory: Kill process 588 (dhclient) score 1732579 or sacrifice child
[21623.176588] Killed process 588 (dhclient) total-vm:88824kB, anon-rss:0kB, file-rss:4kB



wtf ?

we picked this..

[21623.066911] [  588]     0   588    22206        1   2       0             0 dhclient

over say..

[21623.116597] [ 7092]  1000  7092  1051124    31660   3       0             0 trinity-child3

What went wrong here ?

And why does that score look so.. weird.


If the death spiral of endless oom killing sounds interesting, I have about 300MB of logfile
so far which I can upload somewhere.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
