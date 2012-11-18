Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 1418B6B005D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 14:00:51 -0500 (EST)
Message-ID: <50A9304E.3020205@redhat.com>
Date: Sun, 18 Nov 2012 20:00:30 +0100
From: Zdenek Kabelac <zkabelac@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd0: excessive CPU usage
References: <20121015110937.GE29125@suse.de> <5093A3F4.8090108@redhat.com> <5093A631.5020209@suse.cz> <509422C3.1000803@suse.cz> <509C84ED.8090605@linux.vnet.ibm.com> <509CB9D1.6060704@redhat.com> <20121109090635.GG8218@suse.de> <509F6C2A.9060502@redhat.com> <20121112121956.GT8218@suse.de> <50A0F5F0.6090400@redhat.com> <20121112133139.GU8218@suse.de>
In-Reply-To: <20121112133139.GU8218@suse.de>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Jiri Slaby <jslaby@suse.cz>, Valdis.Kletnieks@vt.edu, Jiri Slaby <jirislaby@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Robert Jennings <rcj@linux.vnet.ibm.com>

Dne 12.11.2012 14:31, Mel Gorman napsal(a):
> On Mon, Nov 12, 2012 at 02:13:20PM +0100, Zdenek Kabelac wrote:
>> Dne 12.11.2012 13:19, Mel Gorman napsal(a):
>>> On Sun, Nov 11, 2012 at 10:13:14AM +0100, Zdenek Kabelac wrote:
>>>> Hmm,  so it's just took longer to hit the problem and observe kswapd0
>>>> spinning on my CPU again - it's not as endless like before - but
>>>> still it easily eats minutes - it helps to  turn off  Firefox or TB
>>>> (memory hungry apps) so kswapd0 stops soon - and restart those apps
>>>> again.
>>>> (And I still have like >1GB of cached memory)
>>>>
>>>
>>> I posted a "safe" patch that I believe explains why you are seeing what
>>> you are seeing. It does mean that there will still be some stalls due to
>>> THP because kswapd is not helping and it's avoiding the problem rather
>>> than trying to deal with it.
>>>
>>> Hence, I'm also going to post this patch even though I have not tested
>>> it myself. If you find it fixes the problem then it would be a
>>> preferable patch to the revert. It still is the case that the
>>> balance_pgdat() logic is in sort need of a rethink as it's pretty
>>> twisted right now.
>>>
>>
>>
>> Should I apply them all together for 3.7-rc5 ?
>>
>> 1) https://lkml.org/lkml/2012/11/5/308
>> 2) https://lkml.org/lkml/2012/11/12/113
>> 3) https://lkml.org/lkml/2012/11/12/151
>>
>
> Not all together. Test either 1+2 or 1+3. 1+2 is the safer choice but
> does nothing about THP stalls. 1+3 is a riskier version but depends on
> me being correct on what the root cause of the problem you see it.
>
> If both 1+2 and 1+3 work for you, I'd choose 1+3 for merging. If you only
> have the time to test one combination then it would be preferred that you
> test the safe option of 1+2.

So I've tested  1+2 for a few days - once I've rebooted for another reason,
but today happened this to me (with ~2day uptime)

For some reason my machine went ouf of memory and OOM killed
firefox and then even whole Xsession.

Unsure whether it's related to those 2 patches - but I've never had
such OOM failure before.

Should I experiment now with 1+3 - or is there newer thing to test ?

Zdenek

  X: page allocation failure: order:0, mode:0x200da
  Pid: 1126, comm: X Not tainted 3.7.0-rc5-00007-g95e21c5 #100
  Call Trace:
   [<ffffffff811354e9>] warn_alloc_failed+0xe9/0x140
   [<ffffffff81138eda>] __alloc_pages_nodemask+0x7fa/0xa40
   [<ffffffff81148fc3>] shmem_getpage_gfp+0x603/0x9d0
   [<ffffffff8100a166>] ? native_sched_clock+0x26/0x90
   [<ffffffff81149d6f>] shmem_fault+0x4f/0xa0
   [<ffffffff812ad69e>] shm_fault+0x1e/0x20
   [<ffffffff811571d3>] __do_fault+0x73/0x4d0
   [<ffffffff81131640>] ? generic_file_aio_write+0xb0/0x100
   [<ffffffff81159d67>] handle_pte_fault+0x97/0x9a0
   [<ffffffff810aca4f>] ? __lock_is_held+0x5f/0x90
   [<ffffffff81081711>] ? get_parent_ip+0x11/0x50
  rsyslogd invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
  rsyslogd cpuset=/ mems_allowed=0
  Pid: 571, comm: rsyslogd Not tainted 3.7.0-rc5-00007-g95e21c5 #100
  Call Trace:
   [<ffffffff8154dfcb>] dump_header.isra.12+0x78/0x224
   [<ffffffff8155b529>] ? sub_preempt_count+0x79/0xd0
   [<ffffffff81557842>] ? _raw_spin_unlock_irqrestore+0x42/0x80
   [<ffffffff81317c0e>] ? ___ratelimit+0x9e/0x130
   [<ffffffff81133ac3>] oom_kill_process+0x1d3/0x330
   [<ffffffff81134219>] out_of_memory+0x439/0x4a0
   [<ffffffff81139056>] __alloc_pages_nodemask+0x976/0xa40
   [<ffffffff811304b5>] ? find_get_page+0x5/0x230
   [<ffffffff811322a0>] filemap_fault+0x2d0/0x480
   [<ffffffff811571d3>] __do_fault+0x73/0x4d0
   [<ffffffff81159d67>] handle_pte_fault+0x97/0x9a0
   [<ffffffff810aca4f>] ? __lock_is_held+0x5f/0x90
   [<ffffffff81081711>] ? get_parent_ip+0x11/0x50
   [<ffffffff8115ae6f>] handle_mm_fault+0x22f/0x2f0
   [<ffffffff8155ae7d>] __do_page_fault+0x15d/0x4e0
   [<ffffffff8155b529>] ? sub_preempt_count+0x79/0xd0
   [<ffffffff815578b5>] ? _raw_spin_unlock+0x35/0x60
   [<ffffffff811f8d9c>] ? proc_reg_read+0x8c/0xc0
   [<ffffffff815580a3>] ? error_sti+0x5/0x6
   [<ffffffff8131f55d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
   [<ffffffff8155b20e>] do_page_fault+0xe/0x10
   [<ffffffff81557ea2>] page_fault+0x22/0x30
  Mem-Info:
  DMA per-cpu:
  CPU    0: hi:    0, btch:   1 usd:   0
  CPU    1: hi:    0, btch:   1 usd:   0
  DMA32 per-cpu:
  CPU    0: hi:  186, btch:  31 usd:  30
  CPU    1: hi:  186, btch:  31 usd:   6
  Normal per-cpu:
  CPU    0: hi:  186, btch:  31 usd:  30
  CPU    1: hi:  186, btch:  31 usd:   0
  active_anon:900420 inactive_anon:28835 isolated_anon:0
   active_file:43 inactive_file:21 isolated_file:0
   unevictable:4 dirty:34 writeback:2 unstable:0
   free:20731 slab_reclaimable:8641 slab_unreclaimable:10446
   mapped:18325 shmem:243662 pagetables:7705 bounce:0
   free_cma:0
  DMA free:12120kB min:272kB low:340kB high:408kB active_anon:2892kB 
inactive_anon:872kB active_file:0kB inactive_file:0kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:15900kB mlocked:0kB dirty:0kB 
writeback:0kB mapped:1672kB shmem:3596kB slab_reclaimable:0kB 
slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB 
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
  lowmem_reserve[]: 0 2951 3836 3836
  DMA32 free:55296kB min:51776kB low:64720kB high:77664kB 
active_anon:2834992kB inactive_anon:107924kB active_file:92kB 
inactive_file:52kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
present:3021968kB mlocked:0kB dirty:88kB writeback:0kB mapped:65460kB 
shmem:943100kB slab_reclaimable:11700kB slab_unreclaimable:8968kB 
kernel_stack:592kB pagetables:11852kB unstable:0kB bounce:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:180 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 885 885
  Normal free:15508kB min:15532kB low:19412kB high:23296kB 
active_anon:763796kB inactive_anon:6544kB active_file:80kB inactive_file:32kB 
unevictable:16kB isolated(anon):0kB isolated(file):0kB present:906664kB 
mlocked:16kB dirty:48kB writeback:52kB mapped:6168kB shmem:27952kB 
slab_reclaimable:22864kB slab_unreclaimable:32800kB kernel_stack:2568kB 
pagetables:18968kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:234 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 0 0
  DMA: 2*4kB 2*8kB 2*16kB 1*32kB 2*64kB 1*128kB 2*256kB 2*512kB 2*1024kB 
2*2048kB 1*4096kB = 12120kB
  DMA32: 900*4kB 1512*8kB 513*16kB 635*32kB 109*64kB 8*128kB 0*256kB 0*512kB 
1*1024kB 1*2048kB 0*4096kB = 55296kB
  Normal: 452*4kB 363*8kB 225*16kB 139*32kB 30*64kB 4*128kB 1*256kB 0*512kB 
0*1024kB 1*2048kB 0*4096kB = 17496kB
  243783 total pagecache pages
  0 pages in swap cache
  Swap cache stats: add 0, delete 0, find 0/0
  Free swap  = 0kB
  Total swap = 0kB
  1032176 pages RAM
  42789 pages reserved
  553592 pages shared
  943414 pages non-shared
  [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
  [  351]     0   351    74685     1679     154        0             0 
systemd-journal
  [  544]     0   544     5863      107      16        0             0 bluetoothd
  [  545]     0   545    88977      725      56        0             0 
NetworkManager
  [  546]     0   546    30170      158      15        0             0 crond
  [  552]     0   552     1879       28       8        0             0 gpm
  [  557]     0   557     1092       37       8        0             0 acpid
  [  564]    81   564     6361      373      16        0          -900 dbus-daemon
  [  566]     0   566    61331      155      22        0             0 rsyslogd
  [  567]   498   567     7026      104      19        0             0 
avahi-daemon
  [  568]   498   568     6994       59      17        0             0 
avahi-daemon
  [  573]     0   573     1758       33       9        0             0 mcelog
  [  578]     0   578     5925       51      16        0             0 atd
  [  586]   105   586   121536     4270      56        0             0 polkitd
  [  593]     0   593    21967      205      48        0          -900 
modem-manager
  [  601]     0   601     1087       26       8        0             0 thinkfan
  [  619]     0   619   122722     1085     129        0             0 libvirtd
  [  630]    32   630     4812       68      13        0             0 rpcbind
  [  633]     0   633    20080      199      43        0         -1000 sshd
  [  653]    29   653     5905      116      16        0             0 rpc.statd
  [  700]     0   700    13173      190      28        0             0 
wpa_supplicant
  [  719]     0   719     4810       50      14        0             0 rpc.idmapd
  [  730]     0   730    28268       36      10        0             0 rpc.rquotad
  [  766]     0   766     6030      153      15        0             0 rpc.mountd
  [  806]    99   806     3306       45      11        0             0 dnsmasq
  [  985]     0   985    21219      150      46        0             0 login
  [  988]     0   988   260408      355      48        0             0 
console-kit-dae
  [ 1053] 11641  1053    28706      241      14        0             0 bash
  [ 1097] 11641  1097    27972       58      10        0             0 startx
  [ 1125] 11641  1125     3487       48      13        0             0 xinit
  [ 1126] 11641  1126    80028    35289     154        0             0 X
  [ 1138] 11641  1138   142989      930     122        0             0 
gnome-session
  [ 1151] 11641  1151     4013       64      12        0             0 dbus-launch
  [ 1152] 11641  1152     6069       82      17        0             0 dbus-daemon
  [ 1154] 11641  1154    85449      162      36        0             0 
at-spi-bus-laun
  [ 1158] 11641  1158     6103      116      17        0             0 dbus-daemon
  [ 1161] 11641  1161    32328      174      33        0             0 
at-spi2-registr
  [ 1172] 11641  1172     4013       65      13        0             0 dbus-launch
  [ 1173] 11641  1173     6350      265      18        0             0 dbus-daemon
  [ 1177] 11641  1177    37416      416      29        0             0 gconfd-2
  [ 1184] 11641  1184   117556     1203      44        0             0 
gnome-keyring-d
  [ 1185] 11641  1185   224829     2236     177        0             0 
gnome-settings-
  [ 1194]     0  1194    57227      786      46        0             0 upowerd
  [ 1226] 11641  1226    77392      190      36        0             0 gvfsd
  [ 1246] 11641  1246   118201      772      90        0             0 pulseaudio
  [ 1247]   496  1247    41161       59      17        0             0 
rtkit-daemon
  [ 1252] 11641  1252    29494      205      58        0             0 
gconf-helper
  [ 1253]   106  1253    81296      355      46        0             0 colord
  [ 1257] 11641  1257    59080     1574      60        0             0 openbox
  [ 1258] 11641  1258   185569     3216     146        0             0 gnome-panel
  [ 1264] 11641  1264    64102      229      27        0             0 
dconf-service
  [ 1268] 11641  1268   139203      858     116        0             0 
gnome-user-shar
  [ 1269] 11641  1269   268645    27442     334        0             0 pidgin
  [ 1270] 11641  1270   142642     1064     117        0             0 
bluetooth-apple
  [ 1271] 11641  1271   193218     1775     175        0             0 nm-applet
  [ 1272] 11641  1272   220194     1810     138        0             0 
gnome-sound-app
  [ 1285] 11641  1285    80914      632      45        0             0 
gvfs-udisks2-vo
  [ 1287]     0  1287    88101      599      41        0             0 udisksd
  [ 1295] 11641  1295   177162    14140     150        0             0 wnck-applet
  [ 1297] 11641  1297   281043     3161     199        0             0 
clock-applet
  [ 1299] 11641  1299   142537     1053     120        0             0 
cpufreq-applet
  [ 1302] 11641  1302   141960      986     113        0             0 
notification-ar
  [ 1340] 11641  1340   190026     6265     144        0             0 
gnome-terminal
  [ 1346] 11641  1346     2123       35      10        0             0 
gnome-pty-helpe
  [ 1347] 11641  1347    28719      253      11        0             0 bash
  [ 1858] 11641  1858    10895      101      27        0             0 xfconfd
  [ 2052] 11641  2052    28720      255      11        0             0 bash
  [ 6239] 11641  6239    73437      711      88        0             0 kdeinit4
  [ 6240] 11641  6240    83952      717     101        0             0 klauncher
  [ 6242] 11641  6242   126497     1479     172        0             0 kded4
  [ 6244] 11641  6244     2977       48      11        0             0 gam_server
  [10804] 11641 10804   101320      307      47        0             0 gvfsd-http
  [12175]     0 12175    27197       32      10        0             0 agetty
  [12249] 11641 12249    28719      252      14        0             0 bash
  [14862]     0 14862    51773      344      55        0             0 cupsd
  [14868]     4 14868    18105      158      39        0             0 cups-polld
  [16728] 11641 16728    28691      244      12        0             0 bash
  [16975]     0 16975     9109      253      23        0         -1000 
systemd-udevd
  [17618]     0 17618     8245       87      22        0             0 
systemd-logind
  [ 3133] 11641  3133    43721      132      40        0             0 su
  [ 3136]     0  3136    28564      139      12        0             0 bash
  [ 3983] 11641  3983    43722      134      41        0             0 su
  [ 3986]     0  3986    28564      144      13        0             0 bash
  [16350] 11641 16350    28691      245      14        0             0 bash
  [31228] 11641 31228    28691      245      11        0             0 bash
  [31922] 11641 31922    28719      250      13        0             0 bash
  [ 2340] 11641  2340    28691      245      15        0             0 bash
  [12586]    38 12586     7851      150      19        0             0 ntpd
  [32658] 11641 32658    41192      424      35        0             0 mc
  [32660] 11641 32660    28692      245      13        0             0 bash
  [29193] 11641 29193   713846   414344    1614        0             0 firefox
  [10971] 11641 10971    43722      133      43        0             0 su
  [10974]     0 10974    28564      132      12        0             0 bash
  [11343]     0 11343    28497       66      11        0             0 ksmtuned
  [11387] 11641 11387    28719      254      11        0             0 bash
  [11450] 11641 11450    28691      246      13        0             0 bash
  [11576] 11641 11576    43722      133      40        0             0 su
  [11579]     0 11579    28564      141      13        0             0 bash
  [12106] 11641 12106    28691      244      12        0             0 bash
  [12141] 11641 12141    43722      132      44        0             0 su
  [12144]     0 12144    28564      140      11        0             0 bash
  [12264] 11641 12264    28691      245      11        0             0 bash
  [12299] 11641 12299    43721      133      40        0             0 su
  [12302]     0 12302    28564      137      12        0             0 bash
  [26024] 11641 26024    28691      245      13        0             0 bash
  [26083] 11641 26083    28691      245      13        0             0 bash
  [28235] 11641 28235    43721      132      42        0             0 su
  [28238]     0 28238    28564      143      13        0             0 bash
  [29460] 11641 29460    43721      132      42        0             0 su
  [29463]     0 29463    28564      137      12        0             0 bash
  [29758] 11641 29758    28720      256      12        0             0 bash
  [29864] 11641 29864    41916     1153      36        0             0 mc
  [29866] 11641 29866    28728      257      11        0             0 bash
  [32750]     0 32750    23164     2994      47        0             0 dhclient
  [  323]     0   323    24081      471      48        0             0 sendmail
  [  347]    51   347    20347      367      38        0             0 sendmail
  [  907] 11641   907   379562   159766     707        0             0 thunderbird
  [ 6340] 11641  6340    28719      251      12        0             0 bash
  [ 6790] 11641  6790    80307      620     101        0             0 
xfce4-notifyd
  [ 6844]     0  6844    26669       23       9        0             0 sleep
  Out of memory: Kill process 29193 (firefox) score 420 or sacrifice child
  Killed process 29193 (firefox) total-vm:2855384kB, anon-rss:1653868kB, 
file-rss:3508kB
   [<ffffffff8115ae6f>] handle_mm_fault+0x22f/0x2f0
   [<ffffffff8115b12a>] __get_user_pages+0x12a/0x530
   [<ffffffff8115b575>] get_dump_page+0x45/0x60
   [<ffffffff811eec6d>] elf_core_dump+0x16bd/0x1960
   [<ffffffff811edf86>] ? elf_core_dump+0x9d6/0x1960
   [<ffffffff8155b529>] ? sub_preempt_count+0x79/0xd0
   [<ffffffff815546ae>] ? mutex_unlock+0xe/0x10
   [<ffffffff8118ed63>] ? do_truncate+0x73/0xa0
   [<ffffffff811f55a1>] do_coredump+0xa21/0xeb0
   [<ffffffff810b22a0>] ? debug_check_no_locks_freed+0xe0/0x170
   [<ffffffff810abe8d>] ? trace_hardirqs_off+0xd/0x10
   [<ffffffff8105a961>] get_signal_to_deliver+0x2e1/0x960
   [<ffffffff8100236f>] do_signal+0x3f/0x9a0
   [<ffffffff81540000>] ? pci_fixup_msi_k8t_onboard_sound+0x7d/0x97
   [<ffffffff8154b565>] ? is_prefetch.isra.15+0x1a6/0x1fd
   [<ffffffff815580a3>] ? error_sti+0x5/0x6
   [<ffffffff81557cd1>] ? retint_signal+0x11/0x90
   [<ffffffff81002d70>] do_notify_resume+0x80/0xb0
   [<ffffffff81557d06>] retint_signal+0x46/0x90
  Mem-Info:
  DMA per-cpu:
  CPU    0: hi:    0, btch:   1 usd:   0
  CPU    1: hi:    0, btch:   1 usd:   0
  DMA32 per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   0
  CPU    1: hi:  186, btch:  31 usd:  30
  Normal per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   0
  CPU    1: hi:  186, btch:  31 usd:  30
  active_anon:900420 inactive_anon:28835 isolated_anon:0
   active_file:8 inactive_file:0 isolated_file:0
   unevictable:4 dirty:34 writeback:2 unstable:0
   free:20724 slab_reclaimable:8641 slab_unreclaimable:10446
   mapped:18325 shmem:243662 pagetables:7705 bounce:0
   free_cma:0
  DMA free:12120kB min:272kB low:340kB high:408kB active_anon:2892kB 
inactive_anon:872kB active_file:0kB inactive_file:0kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:15900kB mlocked:0kB dirty:0kB 
writeback:0kB mapped:1672kB shmem:3596kB slab_reclaimable:0kB 
slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB 
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
  lowmem_reserve[]: 0 2951 3836 3836
  DMA32 free:55404kB min:51776kB low:64720kB high:77664kB 
active_anon:2834992kB inactive_anon:107924kB active_file:0kB 
inactive_file:28kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
present:3021968kB mlocked:0kB dirty:0kB writeback:0kB mapped:65460kB 
shmem:943100kB slab_reclaimable:11700kB slab_unreclaimable:8968kB 
kernel_stack:592kB pagetables:11852kB unstable:0kB bounce:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:129 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 885 885
  Normal free:15364kB min:15532kB low:19412kB high:23296kB 
active_anon:763796kB inactive_anon:6544kB active_file:0kB inactive_file:24kB 
unevictable:16kB isolated(anon):0kB isolated(file):0kB present:906664kB 
mlocked:16kB dirty:48kB writeback:52kB mapped:6168kB shmem:27952kB 
slab_reclaimable:22864kB slab_unreclaimable:32800kB kernel_stack:2568kB 
pagetables:18968kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:379 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 0 0
  DMA: 2*4kB 2*8kB 2*16kB 1*32kB 2*64kB 1*128kB 2*256kB 2*512kB 2*1024kB 
2*2048kB 1*4096kB = 12120kB
  DMA32: 896*4kB 1512*8kB 513*16kB 635*32kB 109*64kB 8*128kB 0*256kB 0*512kB 
1*1024kB 1*2048kB 0*4096kB = 55280kB
  Normal: 403*4kB 377*8kB 225*16kB 139*32kB 30*64kB 4*128kB 1*256kB 0*512kB 
0*1024kB 1*2048kB 0*4096kB = 17412kB
  243733 total pagecache pages
  rsyslogd invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
  rsyslogd cpuset=/ mems_allowed=0
  Pid: 571, comm: rsyslogd Not tainted 3.7.0-rc5-00007-g95e21c5 #100
  Call Trace:
   [<ffffffff8154dfcb>] dump_header.isra.12+0x78/0x224
   [<ffffffff8155b529>] ? sub_preempt_count+0x79/0xd0
   [<ffffffff81557842>] ? _raw_spin_unlock_irqrestore+0x42/0x80
   [<ffffffff81317c0e>] ? ___ratelimit+0x9e/0x130
   [<ffffffff81133ac3>] oom_kill_process+0x1d3/0x330
   [<ffffffff81134219>] out_of_memory+0x439/0x4a0
   [<ffffffff81139056>] __alloc_pages_nodemask+0x976/0xa40
   [<ffffffff811304b5>] ? find_get_page+0x5/0x230
   [<ffffffff811322a0>] filemap_fault+0x2d0/0x480
   [<ffffffff811571d3>] __do_fault+0x73/0x4d0
   [<ffffffff81159d67>] handle_pte_fault+0x97/0x9a0
   [<ffffffff810aca4f>] ? __lock_is_held+0x5f/0x90
   [<ffffffff81081711>] ? get_parent_ip+0x11/0x50
   [<ffffffff8115ae6f>] handle_mm_fault+0x22f/0x2f0
   [<ffffffff8155ae7d>] __do_page_fault+0x15d/0x4e0
   [<ffffffff815578b5>] ? _raw_spin_unlock+0x35/0x60
   [<ffffffff811f8d9c>] ? proc_reg_read+0x8c/0xc0
   [<ffffffff815580a3>] ? error_sti+0x5/0x6
   [<ffffffff8131f55d>] ? trace_hardirqs_off_thunk+0x3a/0x3c
   [<ffffffff8155b20e>] do_page_fault+0xe/0x10
   [<ffffffff81557ea2>] page_fault+0x22/0x30
  Mem-Info:
  DMA per-cpu:
  CPU    0: hi:    0, btch:   1 usd:   0
  CPU    1: hi:    0, btch:   1 usd:   0
  DMA32 per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   0
  CPU    1: hi:  186, btch:  31 usd:  30
  Normal per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   1
  CPU    1: hi:  186, btch:  31 usd:  46
  active_anon:900420 inactive_anon:28835 isolated_anon:0
   active_file:0 inactive_file:7 isolated_file:0
   unevictable:4 dirty:0 writeback:2 unstable:0
   free:20691 slab_reclaimable:8641 slab_unreclaimable:10446
   mapped:18325 shmem:243662 pagetables:7705 bounce:0
   free_cma:0
  DMA free:12120kB min:272kB low:340kB high:408kB active_anon:2892kB 
inactive_anon:872kB active_file:0kB inactive_file:0kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:15900kB mlocked:0kB dirty:0kB 
writeback:0kB mapped:1672kB shmem:3596kB slab_reclaimable:0kB 
slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB 
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
  lowmem_reserve[]: 0 2951 3836 3836
  DMA32 free:55280kB min:51776kB low:64720kB high:77664kB 
active_anon:2834992kB inactive_anon:107924kB active_file:0kB 
inactive_file:12kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
present:3021968kB mlocked:0kB dirty:0kB writeback:0kB mapped:65460kB 
shmem:943100kB slab_reclaimable:11700kB slab_unreclaimable:8968kB 
kernel_stack:592kB pagetables:11852kB unstable:0kB bounce:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:520 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 885 885
  Normal free:15364kB min:15532kB low:19412kB high:23296kB 
active_anon:763796kB inactive_anon:6544kB active_file:0kB inactive_file:16kB 
unevictable:16kB isolated(anon):0kB isolated(file):0kB present:906664kB 
mlocked:16kB dirty:48kB writeback:52kB mapped:6168kB shmem:27952kB 
slab_reclaimable:22864kB slab_unreclaimable:32800kB kernel_stack:2568kB 
pagetables:18968kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:571 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 0 0
  DMA: 2*4kB 2*8kB 2*16kB 1*32kB 2*64kB 1*128kB 2*256kB 2*512kB 2*1024kB 
2*2048kB 1*4096kB = 12120kB
  DMA32: 896*4kB 1512*8kB 513*16kB 635*32kB 109*64kB 8*128kB 0*256kB 0*512kB 
1*1024kB 1*2048kB 0*4096kB = 55280kB
  Normal: 403*4kB 377*8kB 225*16kB 139*32kB 30*64kB 4*128kB 1*256kB 0*512kB 
0*1024kB 1*2048kB 0*4096kB = 17412kB
  243733 total pagecache pages
  0 pages in swap cache
  Swap cache stats: add 0, delete 0, find 0/0
  Free swap  = 0kB
  Total swap = 0kB
  0 pages in swap cache
  Swap cache stats: add 0, delete 0, find 0/0
  Free swap  = 0kB
  Total swap = 0kB
  1032176 pages RAM
  42789 pages reserved
  553579 pages shared
  943538 pages non-shared
  1032176 pages RAM
  42789 pages reserved
  553576 pages shared
  943549 pages non-shared
  [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
  [  351]     0   351    74685     1682     154        0             0 
systemd-journal
  [  544]     0   544     5863      107      16        0             0 bluetoothd
  [  545]     0   545    88977      725      56        0             0 
NetworkManager
  [  546]     0   546    30170      158      15        0             0 crond
  [  552]     0   552     1879       28       8        0             0 gpm
  [  557]     0   557     1092       37       8        0             0 acpid
  [  564]    81   564     6361      373      16        0          -900 dbus-daemon
  [  566]     0   566    61331      155      22        0             0 rsyslogd
  [  567]   498   567     7026      104      19        0             0 
avahi-daemon
  [  568]   498   568     6994       59      17        0             0 
avahi-daemon
  [  573]     0   573     1758       33       9        0             0 mcelog
  [  578]     0   578     5925       51      16        0             0 atd
  [  586]   105   586   121536     4270      56        0             0 polkitd
  [  593]     0   593    21967      205      48        0          -900 
modem-manager
  [  601]     0   601     1087       26       8        0             0 thinkfan
  [  619]     0   619   122722     1085     129        0             0 libvirtd
  [  630]    32   630     4812       68      13        0             0 rpcbind
  [  633]     0   633    20080      199      43        0         -1000 sshd
  [  653]    29   653     5905      116      16        0             0 rpc.statd
  [  700]     0   700    13173      190      28        0             0 
wpa_supplicant
  [  719]     0   719     4810       50      14        0             0 rpc.idmapd
  [  730]     0   730    28268       36      10        0             0 rpc.rquotad
  [  766]     0   766     6030      153      15        0             0 rpc.mountd
  [  806]    99   806     3306       45      11        0             0 dnsmasq
  [  985]     0   985    21219      150      46        0             0 login
  [  988]     0   988   260408      355      48        0             0 
console-kit-dae
  [ 1053] 11641  1053    28706      241      14        0             0 bash
  [ 1097] 11641  1097    27972       58      10        0             0 startx
  [ 1125] 11641  1125     3487       48      13        0             0 xinit
  [ 1126] 11641  1126    80028    35379     154        0             0 X
  [ 1138] 11641  1138   142989      930     122        0             0 
gnome-session
  [ 1151] 11641  1151     4013       64      12        0             0 dbus-launch
  [ 1152] 11641  1152     6069       82      17        0             0 dbus-daemon
  [ 1154] 11641  1154    85449      162      36        0             0 
at-spi-bus-laun
  [ 1158] 11641  1158     6103      116      17        0             0 dbus-daemon
  [ 1161] 11641  1161    32328      174      33        0             0 
at-spi2-registr
  [ 1172] 11641  1172     4013       65      13        0             0 dbus-launch
  [ 1173] 11641  1173     6350      265      18        0             0 dbus-daemon
  [ 1177] 11641  1177    37416      416      29        0             0 gconfd-2
  [ 1184] 11641  1184   117556     1203      44        0             0 
gnome-keyring-d
  [ 1185] 11641  1185   224829     2236     177        0             0 
gnome-settings-
  [ 1194]     0  1194    57227      786      46        0             0 upowerd
  [ 1226] 11641  1226    77392      190      36        0             0 gvfsd
  [ 1246] 11641  1246   118201      772      90        0             0 pulseaudio
  [ 1247]   496  1247    41161       59      17        0             0 
rtkit-daemon
  [ 1252] 11641  1252    29494      205      58        0             0 
gconf-helper
  [ 1253]   106  1253    81296      355      46        0             0 colord
  [ 1257] 11641  1257    59080     1574      60        0             0 openbox
  [ 1258] 11641  1258   185569     3216     146        0             0 gnome-panel
  [ 1264] 11641  1264    64102      229      27        0             0 
dconf-service
  [ 1268] 11641  1268   139203      858     116        0             0 
gnome-user-shar
  [ 1269] 11641  1269   268645    27442     334        0             0 pidgin
  [ 1270] 11641  1270   142642     1064     117        0             0 
bluetooth-apple
  [ 1271] 11641  1271   193218     1775     175        0             0 nm-applet
  [ 1272] 11641  1272   220194     1810     138        0             0 
gnome-sound-app
  [ 1285] 11641  1285    80914      632      45        0             0 
gvfs-udisks2-vo
  [ 1287]     0  1287    88101      599      41        0             0 udisksd
  [ 1295] 11641  1295   177162    14140     150        0             0 wnck-applet
  [ 1297] 11641  1297   281043     3161     199        0             0 
clock-applet
  [ 1299] 11641  1299   142537     1051     120        0             0 
cpufreq-applet
  [ 1302] 11641  1302   141960      986     113        0             0 
notification-ar
  [ 1340] 11641  1340   190026     6265     144        0             0 
gnome-terminal
  [ 1346] 11641  1346     2123       35      10        0             0 
gnome-pty-helpe
  [ 1347] 11641  1347    28719      253      11        0             0 bash
  [ 1858] 11641  1858    10895      101      27        0             0 xfconfd
  X: page allocation failure: order:0, mode:0x200da
  Pid: 1126, comm: X Not tainted 3.7.0-rc5-00007-g95e21c5 #100
  [ 2052] 11641  2052    28720      255      11        0             0 bash
  [ 6239] 11641  6239    73437      711      88        0             0 kdeinit4
  [ 6240] 11641  6240    83952      717     101        0             0 klauncher
  Call Trace:
   [<ffffffff811354e9>] warn_alloc_failed+0xe9/0x140
   [<ffffffff81138eda>] __alloc_pages_nodemask+0x7fa/0xa40
   [<ffffffff81148fc3>] shmem_getpage_gfp+0x603/0x9d0
   [<ffffffff8100a166>] ? native_sched_clock+0x26/0x90
   [<ffffffff81149d6f>] shmem_fault+0x4f/0xa0
   [<ffffffff812ad69e>] shm_fault+0x1e/0x20
   [<ffffffff811571d3>] __do_fault+0x73/0x4d0
   [<ffffffff81131640>] ? generic_file_aio_write+0xb0/0x100
   [<ffffffff81159d67>] handle_pte_fault+0x97/0x9a0
   [<ffffffff810aca4f>] ? __lock_is_held+0x5f/0x90
   [<ffffffff81081711>] ? get_parent_ip+0x11/0x50
   [<ffffffff8115ae6f>] handle_mm_fault+0x22f/0x2f0
   [<ffffffff8115b12a>] __get_user_pages+0x12a/0x530
   [<ffffffff8115b575>] get_dump_page+0x45/0x60
   [<ffffffff811eec6d>] elf_core_dump+0x16bd/0x1960
   [<ffffffff811edf86>] ? elf_core_dump+0x9d6/0x1960
   [<ffffffff8155b529>] ? sub_preempt_count+0x79/0xd0
   [<ffffffff815546ae>] ? mutex_unlock+0xe/0x10
   [<ffffffff8118ed63>] ? do_truncate+0x73/0xa0
   [<ffffffff811f55a1>] do_coredump+0xa21/0xeb0
   [<ffffffff810b22a0>] ? debug_check_no_locks_freed+0xe0/0x170
   [<ffffffff810abe8d>] ? trace_hardirqs_off+0xd/0x10
   [<ffffffff8105a961>] get_signal_to_deliver+0x2e1/0x960
   [<ffffffff8100236f>] do_signal+0x3f/0x9a0
   [<ffffffff81540000>] ? pci_fixup_msi_k8t_onboard_sound+0x7d/0x97
   [<ffffffff8154b565>] ? is_prefetch.isra.15+0x1a6/0x1fd
   [<ffffffff815580a3>] ? error_sti+0x5/0x6
   [<ffffffff81557cd1>] ? retint_signal+0x11/0x90
   [<ffffffff81002d70>] do_notify_resume+0x80/0xb0
   [<ffffffff81557d06>] retint_signal+0x46/0x90
  Mem-Info:
  DMA per-cpu:
  CPU    0: hi:    0, btch:   1 usd:   0
  CPU    1: hi:    0, btch:   1 usd:   0
  DMA32 per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   0
  CPU    1: hi:  186, btch:  31 usd:   0
  Normal per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   1
  CPU    1: hi:  186, btch:  31 usd:  14
  active_anon:900420 inactive_anon:28978 isolated_anon:0
   active_file:22 inactive_file:24 isolated_file:0
   unevictable:4 dirty:5 writeback:0 unstable:0
   free:20346 slab_reclaimable:8656 slab_unreclaimable:10414
   mapped:18437 shmem:243751 pagetables:7717 bounce:0
   free_cma:0
  DMA free:12120kB min:272kB low:340kB high:408kB active_anon:2892kB 
inactive_anon:872kB active_file:0kB inactive_file:0kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:15900kB mlocked:0kB dirty:0kB 
writeback:0kB mapped:1672kB shmem:3596kB slab_reclaimable:0kB 
slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB 
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
  lowmem_reserve[]: 0 2951 3836 3836
  DMA32 free:55316kB min:51776kB low:64720kB high:77664kB 
active_anon:2834992kB inactive_anon:108408kB active_file:52kB 
inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
present:3021968kB mlocked:0kB dirty:20kB writeback:0kB mapped:65916kB 
shmem:943452kB slab_reclaimable:11716kB slab_unreclaimable:8904kB 
kernel_stack:488kB pagetables:11880kB unstable:0kB bounce:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:3103 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 885 885
  Normal free:13948kB min:15532kB low:19412kB high:23296kB 
active_anon:763796kB inactive_anon:6632kB active_file:36kB inactive_file:40kB 
unevictable:16kB isolated(anon):0kB isolated(file):0kB present:906664kB 
mlocked:16kB dirty:0kB writeback:0kB mapped:6160kB shmem:27956kB 
slab_reclaimable:22908kB slab_unreclaimable:32736kB kernel_stack:2352kB 
pagetables:18988kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:602 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 0 0
  DMA: 2*4kB 2*8kB 2*16kB 1*32kB 2*64kB 1*128kB 2*256kB 2*512kB 2*1024kB 
2*2048kB 1*4096kB = 12120kB
  DMA32: 883*4kB 1525*8kB 513*16kB 637*32kB 109*64kB 8*128kB 0*256kB 0*512kB 
1*1024kB 1*2048kB 0*4096kB = 55396kB
  Normal: 269*4kB 255*8kB 227*16kB 141*32kB 30*64kB 4*128kB 1*256kB 0*512kB 
0*1024kB 1*2048kB 0*4096kB = 15996kB
  243797 total pagecache pages
  0 pages in swap cache
  Swap cache stats: add 0, delete 0, find 0/0
  Free swap  = 0kB
  Total swap = 0kB
  1032176 pages RAM
  42789 pages reserved
  553637 pages shared
  943817 pages non-shared
  X: page allocation failure: order:0, mode:0x200da
  Pid: 1126, comm: X Not tainted 3.7.0-rc5-00007-g95e21c5 #100
  Call Trace:
   [<ffffffff811354e9>] warn_alloc_failed+0xe9/0x140
   [<ffffffff81138eda>] __alloc_pages_nodemask+0x7fa/0xa40
   [<ffffffff81148fc3>] shmem_getpage_gfp+0x603/0x9d0
   [<ffffffff8100a166>] ? native_sched_clock+0x26/0x90
   [<ffffffff81149d6f>] shmem_fault+0x4f/0xa0
   [<ffffffff812ad69e>] shm_fault+0x1e/0x20
   [<ffffffff811571d3>] __do_fault+0x73/0x4d0
   [<ffffffff81159d67>] handle_pte_fault+0x97/0x9a0
   [<ffffffff810aca4f>] ? __lock_is_held+0x5f/0x90
   [<ffffffff81081711>] ? get_parent_ip+0x11/0x50
   [<ffffffff8115ae6f>] handle_mm_fault+0x22f/0x2f0
   [<ffffffff8115b12a>] __get_user_pages+0x12a/0x530
   [<ffffffff815578b5>] ? _raw_spin_unlock+0x35/0x60
   [<ffffffff8115b575>] get_dump_page+0x45/0x60
   [<ffffffff811eec6d>] elf_core_dump+0x16bd/0x1960
   [<ffffffff811edf86>] ? elf_core_dump+0x9d6/0x1960
   [<ffffffff8155b529>] ? sub_preempt_count+0x79/0xd0
   [<ffffffff815546ae>] ? mutex_unlock+0xe/0x10
   [<ffffffff8118ed63>] ? do_truncate+0x73/0xa0
   [<ffffffff811f55a1>] do_coredump+0xa21/0xeb0
   [<ffffffff810b22a0>] ? debug_check_no_locks_freed+0xe0/0x170
   [<ffffffff810abe8d>] ? trace_hardirqs_off+0xd/0x10
   [<ffffffff8105a961>] get_signal_to_deliver+0x2e1/0x960
   [<ffffffff8100236f>] do_signal+0x3f/0x9a0
   [<ffffffff81540000>] ? pci_fixup_msi_k8t_onboard_sound+0x7d/0x97
   [<ffffffff8154b565>] ? is_prefetch.isra.15+0x1a6/0x1fd
   [<ffffffff815580a3>] ? error_sti+0x5/0x6
   [<ffffffff81557cd1>] ? retint_signal+0x11/0x90
   [<ffffffff81002d70>] do_notify_resume+0x80/0xb0
   [<ffffffff81557d06>] retint_signal+0x46/0x90
  Mem-Info:
  DMA per-cpu:
  CPU    0: hi:    0, btch:   1 usd:   0
  CPU    1: hi:    0, btch:   1 usd:   0
  DMA32 per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   0
  CPU    1: hi:  186, btch:  31 usd:   0
  Normal per-cpu:
  CPU    0: hi:  186, btch:  31 usd:   1
  CPU    1: hi:  186, btch:  31 usd:  24
  active_anon:900420 inactive_anon:28978 isolated_anon:0
   active_file:22 inactive_file:24 isolated_file:19
   unevictable:4 dirty:5 writeback:0 unstable:0
   free:20222 slab_reclaimable:8656 slab_unreclaimable:10414
   mapped:18437 shmem:243751 pagetables:7717 bounce:0
   free_cma:0
  DMA free:12120kB min:272kB low:340kB high:408kB active_anon:2892kB 
inactive_anon:872kB active_file:0kB inactive_file:0kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:15900kB mlocked:0kB dirty:0kB 
writeback:0kB mapped:1672kB shmem:3596kB slab_reclaimable:0kB 
slab_unreclaimable:16kB kernel_stack:0kB pagetables:0kB unstable:0kB 
bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
  lowmem_reserve[]: 0 2951 3836 3836
  DMA32 free:55316kB min:51776kB low:64720kB high:77664kB 
active_anon:2834992kB inactive_anon:108408kB active_file:52kB 
inactive_file:56kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
present:3021968kB mlocked:0kB dirty:20kB writeback:0kB mapped:65916kB 
shmem:943452kB slab_reclaimable:11716kB slab_unreclaimable:8904kB 
kernel_stack:488kB pagetables:11880kB unstable:0kB bounce:0kB free_cma:0kB 
writeback_tmp:0kB pages_scanned:3940 all_unreclaimable? yes
  [ 6242] 11641  6242   126497     1479     172        0             0 kded4
  [ 6244] 11641  6244     2977       48      11        0             0 gam_server
  [10804] 11641 10804   101320      307      47        0             0 gvfsd-http
  [12175]     0 12175    27197       32      10        0             0 agetty
  [12249] 11641 12249    28719      252      14        0             0 bash
  [14862]     0 14862    51773      344      55        0             0 cupsd
  [14868]     4 14868    18105      158      39        0             0 cups-polld
  [16728] 11641 16728    28691      244      12        0             0 bash
  [16975]     0 16975     9109      253      23        0         -1000 
systemd-udevd
  [17618]     0 17618     8245       87      22        0             0 
systemd-logind
  [ 3133] 11641  3133    43721      132      40        0             0 su
  [ 3136]     0  3136    28564      139      12        0             0 bash
  [ 3983] 11641  3983    43722      134      41        0             0 su
  [ 3986]     0  3986    28564      144      13        0             0 bash
  [16350] 11641 16350    28691      245      14        0             0 bash
  [31228] 11641 31228    28691      245      11        0             0 bash
  [31922] 11641 31922    28719      250      13        0             0 bash
  [ 2340] 11641  2340    28691      245      15        0             0 bash
  [12586]    38 12586     7851      150      19        0             0 ntpd
  [32658] 11641 32658    41192      424      35        0             0 mc
  [32660] 11641 32660    28692      245      13        0             0 bash
  [10971] 11641 10971    43722      133      43        0             0 su
  [10974]     0 10974    28564      132      12        0             0 bash
  [11343]     0 11343    28497       66      11        0             0 ksmtuned
  [11387] 11641 11387    28719      254      11        0             0 bash
  [11450] 11641 11450    28691      246      13        0             0 bash
  [11576] 11641 11576    43722      133      40        0             0 su
  [11579]     0 11579    28564      141      13        0             0 bash
  [12106] 11641 12106    28691      244      12        0             0 bash
  [12141] 11641 12141    43722      132      44        0             0 su
  [12144]     0 12144    28564      140      11        0             0 bash
  [12264] 11641 12264    28691      245      11        0             0 bash
  [12299] 11641 12299    43721      133      40        0             0 su
  [12302]     0 12302    28564      137      12        0             0 bash
  [26024] 11641 26024    28691      245      13        0             0 bash
  [26083] 11641 26083    28691      245      13        0             0 bash
  [28235] 11641 28235    43721      132      42        0             0 su
  [28238]     0 28238    28564      143      13        0             0 bash
  [29460] 11641 29460    43721      132      42        0             0 su
  [29463]     0 29463    28564      137      12        0             0 bash
  [29758] 11641 29758    28720      256      12        0             0 bash
  [29864] 11641 29864    41916     1153      36        0             0 mc
  [29866] 11641 29866    28728      257      11        0             0 bash
  [32750]     0 32750    23164     2994      47        0             0 dhclient
  [  323]     0   323    24081      471      48        0             0 sendmail
  [  347]    51   347    20347      367      38        0             0 sendmail
  [  907] 11641   907   379562   159766     707        0             0 thunderbird
  [ 6340] 11641  6340    28719      251      12        0             0 bash
  [ 6790] 11641  6790    80307      620     101        0             0 
xfce4-notifyd
  [ 6844]     0  6844    26669       23       9        0             0 sleep
  Out of memory: Kill process 907 (thunderbird) score 162 or sacrifice child
  Killed process 907 (thunderbird) total-vm:1518248kB, anon-rss:638476kB, 
file-rss:588kB
  lowmem_reserve[]: 0 0 885 885
  Normal free:12832kB min:15532kB low:19412kB high:23296kB 
active_anon:763796kB inactive_anon:6632kB active_file:36kB inactive_file:40kB 
unevictable:16kB isolated(anon):0kB isolated(file):0kB present:906664kB 
mlocked:16kB dirty:0kB writeback:0kB mapped:6160kB shmem:27956kB 
slab_reclaimable:22908kB slab_unreclaimable:32736kB kernel_stack:2352kB 
pagetables:18988kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:1742 all_unreclaimable? yes
  lowmem_reserve[]: 0 0 0 0
  DMA: 2*4kB 2*8kB 2*16kB 1*32kB 2*64kB 1*128kB 2*256kB 2*512kB 2*1024kB 
2*2048kB 1*4096kB = 12120kB
  DMA32: 883*4kB 1525*8kB 513*16kB 637*32kB 109*64kB 8*128kB 0*256kB 0*512kB 
1*1024kB 1*2048kB 0*4096kB = 55396kB
  Normal: 270*4kB 173*8kB 198*16kB 141*32kB 30*64kB 4*128kB 1*256kB 0*512kB 
0*1024kB 1*2048kB 0*4096kB = 14880kB
  243797 total pagecache pages
  0 pages in swap cache
  Swap cache stats: add 0, delete 0, find 0/0
  Free swap  = 0kB
  Total swap = 0kB
  1032176 pages RAM
  42789 pages reserved
  553659 pages shared
  937056 pages non-shared

  SysRq : Emergency Sync
  Emergency Sync complete
  SysRq : Emergency Remount R/O



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
