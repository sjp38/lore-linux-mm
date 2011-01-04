Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3A2A46B0087
	for <linux-mm@kvack.org>; Tue,  4 Jan 2011 02:53:29 -0500 (EST)
Message-ID: <4D22D190.1080706@leadcoretech.com>
Date: Tue, 04 Jan 2011 15:51:44 +0800
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3]mm/oom-kill: direct hardware access processes should
 get bonus
References: <1288662213.10103.2.camel@localhost.localdomain>	 <1289305468.10699.2.camel@localhost.localdomain>	 <1289402093.10699.25.camel@localhost.localdomain> <1289402666.10699.28.camel@localhost.localdomain>
In-Reply-To: <1289402666.10699.28.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "Figo.zhang" <figo1802@gmail.com>, "rientjes@google.com" <rientjes@google.com>, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>


i had send the patch to protect the hardware access processes for 
oom-killer before, but rientjes have not agree with me.

but today i catch log from my desktop. oom-killer have kill my "minicom" 
and "Xorg". so i think it should add protection about it.


my desktop run on linux-2.6.36.

[figo@figo-desktop android]$ uname -a
Linux figo-desktop 2.6.36-ARCH #1 SMP PREEMPT Fri Dec 10 20:01:53 UTC 
2010 i686 Intel(R) Core(TM)2 Duo CPU E8400 @ 3.00GHz GenuineIntel GNU/Linux
[figo@figo-desktop android]$

pls see the log:

> Jan  4 15:22:17 figo-desktop kernel: Mem-Info:
> Jan  4 15:22:17 figo-desktop kernel: DMA per-cpu:
> Jan  4 15:22:17 figo-desktop kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jan  4 15:22:17 figo-desktop kernel: CPU    1: hi:    0, btch:   1 usd:   0
> Jan  4 15:22:17 figo-desktop kernel: Normal per-cpu:
> Jan  4 15:22:17 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:  61
> Jan  4 15:22:17 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:  31
> Jan  4 15:22:17 figo-desktop kernel: HighMem per-cpu:
> Jan  4 15:22:17 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:  51
> Jan  4 15:22:17 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:  50
> Jan  4 15:22:17 figo-desktop kernel: active_anon:123081 inactive_anon:170583 isolated_anon:0
> Jan  4 15:22:17 figo-desktop kernel: active_file:53958 inactive_file:122582 isolated_file:0
> Jan  4 15:22:17 figo-desktop kernel: unevictable:17 dirty:6 writeback:31 unstable:0
> Jan  4 15:22:17 figo-desktop kernel: free:11919 slab_reclaimable:5454 slab_unreclaimable:6124
> Jan  4 15:22:17 figo-desktop kernel: mapped:49964 shmem:29206 pagetables:2585 bounce:0
> Jan  4 15:22:17 figo-desktop kernel: DMA free:7976kB min:64kB low:80kB high:96kB active_anon:1272kB inactive_anon:4672kB active_file:516kB inactive_file:760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15788kB mlocked:0kB dirty:0kB writeback:0kB mapped:752kB shmem:488kB slab_reclaimable:480kB slab_unreclaimable:112kB kernel_stack:8kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2513 all_unreclaimable? no
> Jan  4 15:22:17 figo-desktop kernel: lowmem_reserve[]: 0 865 1980 1980
> Jan  4 15:22:17 figo-desktop kernel: Normal free:39220kB min:3728kB low:4660kB high:5592kB active_anon:137716kB inactive_anon:312976kB active_file:85368kB inactive_file:207988kB unevictable:68kB isolated(anon):0kB isolated(file):0kB present:885944kB mlocked:68kB dirty:0kB writeback:0kB mapped:57464kB shmem:45012kB slab_reclaimable:21336kB slab_unreclaimable:24384kB kernel_stack:3272kB pagetables:10340kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:441679 all_unreclaimable? yes
> Jan  4 15:22:17 figo-desktop kernel: lowmem_reserve[]: 0 0 8921 8921
> Jan  4 15:22:17 figo-desktop kernel: HighMem free:480kB min:512kB low:1712kB high:2912kB active_anon:353336kB inactive_anon:364684kB active_file:129948kB inactive_file:281580kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1141984kB mlocked:0kB dirty:24kB writeback:124kB mapped:141640kB shmem:71324kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:650648 all_unreclaimable? yes
> Jan  4 15:22:17 figo-desktop kernel: lowmem_reserve[]: 0 0 0 0
> Jan  4 15:22:17 figo-desktop kernel: DMA: 1482*4kB 256*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7976kB
> Jan  4 15:22:17 figo-desktop kernel: Normal: 1409*4kB 3862*8kB 44*16kB 8*32kB 3*64kB 2*128kB 3*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 39220kB
> Jan  4 15:22:17 figo-desktop kernel: HighMem: 20*4kB 10*8kB 18*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 480kB
> Jan  4 15:22:17 figo-desktop kernel: 212446 total pagecache pages
> Jan  4 15:22:17 figo-desktop kernel: 6668 pages in swap cache
> Jan  4 15:22:17 figo-desktop kernel: Swap cache stats: add 789540, delete 782872, find 277051/391346
> Jan  4 15:22:17 figo-desktop kernel: Free swap  = -28688kB
> Jan  4 15:22:17 figo-desktop kernel: Total swap = 0kB
> Jan  4 15:22:17 figo-desktop kernel: 515070 pages RAM
> Jan  4 15:22:17 figo-desktop kernel: 287745 pages HighMem
> Jan  4 15:22:17 figo-desktop kernel: 8297 pages reserved
> Jan  4 15:22:17 figo-desktop kernel: 306524 pages shared
> Jan  4 15:22:17 figo-desktop kernel: 304318 pages non-shared
> Jan  4 15:22:17 figo-desktop kernel: [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> Jan  4 15:22:17 figo-desktop kernel: [  583]     0   583      581      221   0     -17         -1000 udevd
> Jan  4 15:22:17 figo-desktop kernel: [ 1303]     0  1303      868       37   0       0             0 syslog-ng
> Jan  4 15:22:17 figo-desktop kernel: [ 1304]     0  1304     1604      358   0       0             0 syslog-ng
> Jan  4 15:22:17 figo-desktop kernel: [ 1306]    81  1306      808      351   0       0             0 dbus-daemon
> Jan  4 15:22:17 figo-desktop kernel: [ 1309]    82  1309     3777      366   1       0             0 hald
> Jan  4 15:22:17 figo-desktop kernel: [ 1310]     0  1310      903      128   1       0             0 hald-runner
> Jan  4 15:22:17 figo-desktop kernel: [ 1339]     0  1339      919       92   0       0             0 hald-addon-inpu
> Jan  4 15:22:17 figo-desktop kernel: [ 1357]     0  1357      919      184   0       0             0 hald-addon-stor
> Jan  4 15:22:17 figo-desktop kernel: [ 1359]    82  1359      824      107   1       0             0 hald-addon-acpi
> Jan  4 15:22:17 figo-desktop kernel: [ 1448]     0  1448      616      294   1       0             0 crond
> Jan  4 15:22:17 figo-desktop kernel: [ 1477]     0  1477      720      107   0       0             0 mysqld_safe
> Jan  4 15:22:17 figo-desktop kernel: [ 1484]     0  1484     3580      269   0       0             0 gdm-binary
> Jan  4 15:22:17 figo-desktop kernel: [ 1497]     0  1497      440       67   1       0             0 agetty
> Jan  4 15:22:17 figo-desktop kernel: [ 1498]     0  1498      440       67   0       0             0 agetty
> Jan  4 15:22:17 figo-desktop kernel: [ 1499]     0  1499      440       67   0       0             0 agetty
> Jan  4 15:22:17 figo-desktop kernel: [ 1500]     0  1500      440       67   1       0             0 agetty
> Jan  4 15:22:17 figo-desktop kernel: [ 1501]     0  1501      440       67   0       0             0 agetty
> Jan  4 15:22:17 figo-desktop kernel: [ 1502]     0  1502      440       68   0       0             0 agetty
> Jan  4 15:22:17 figo-desktop kernel: [ 1553]     0  1553     6607      615   0       0             0 NetworkManager
> Jan  4 15:22:17 figo-desktop kernel: [ 1592]     0  1592     2256      329   0       0             0 cupsd
> Jan  4 15:22:17 figo-desktop kernel: [ 1597]    89  1597    29903     2811   1       0             0 mysqld
> Jan  4 15:22:17 figo-desktop kernel: [ 1598]     0  1598     1652      147   1     -17         -1000 sshd
> Jan  4 15:22:17 figo-desktop kernel: [ 1612]     0  1612     6263      506   1       0             0 polkitd
> Jan  4 15:22:17 figo-desktop kernel: [ 1613]     0  1613     2015      122   0       0             0 vmware-usbarbit
> Jan  4 15:22:17 figo-desktop kernel: [ 1617]     0  1617     2887     1483   1       0             0 cntlm
> Jan  4 15:22:17 figo-desktop kernel: [ 1620]     0  1620     4398      365   0       0             0 gdm-simple-slav
> Jan  4 15:22:17 figo-desktop kernel: [ 1636]     0  1636    37300    12287   0       0             0 Xorg
> Jan  4 15:22:17 figo-desktop kernel: [ 1638]     0  1638     1248       88   0       0             0 wpa_supplicant
> Jan  4 15:22:17 figo-desktop kernel: [ 1720]     0  1720     4789     1551   1       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [ 1722]     0  1722      488       93   0       0             0 dhcpcd
> Jan  4 15:22:17 figo-desktop kernel: [ 1732]     0  1732      519       62   1       0             0 vmnet-bridge
> Jan  4 15:22:17 figo-desktop kernel: [ 1750]     0  1750     4922      302   1       0             0 smbd
> Jan  4 15:22:17 figo-desktop kernel: [ 1764]     0  1764      655       39   1       0             0 vmnet-dhcpd
> Jan  4 15:22:17 figo-desktop kernel: [ 1772]     0  1772      513       15   0       0             0 vmnet-netifup
> Jan  4 15:22:17 figo-desktop kernel: [ 1774]     0  1774      655       39   0       0             0 vmnet-dhcpd
> Jan  4 15:22:17 figo-desktop kernel: [ 1776]     0  1776     4922      224   0       0             0 smbd
> Jan  4 15:22:17 figo-desktop kernel: [ 1778]     0  1778      634       44   0       0             0 vmnet-natd
> Jan  4 15:22:17 figo-desktop kernel: [ 1780]     0  1780      513       14   1       0             0 vmnet-netifup
> Jan  4 15:22:17 figo-desktop kernel: [ 1796]     0  1796     6677      326   0       0             0 console-kit-dae
> Jan  4 15:22:17 figo-desktop kernel: [ 1899]   120  1899     6587      598   0       0             0 polkit-gnome-au
> Jan  4 15:22:17 figo-desktop kernel: [ 1903]     0  1903     3905      245   0       0             0 gdm-session-wor
> Jan  4 15:22:17 figo-desktop kernel: [ 1906]     0  1906     3677      314   1       0             0 upowerd
> Jan  4 15:22:17 figo-desktop kernel: [ 1974]  1000  1974    10963     1246   0       0             0 gnome-keyring-d
> Jan  4 15:22:17 figo-desktop kernel: [ 1993]  1000  1993     9253      768   0       0             0 gnome-session
> Jan  4 15:22:17 figo-desktop kernel: [ 2012]  1000  2012      796      102   0       0             0 dbus-launch
> Jan  4 15:22:17 figo-desktop kernel: [ 2013]  1000  2013     5854     3940   0       0             0 dbus-daemon
> Jan  4 15:22:17 figo-desktop kernel: [ 2015]  1000  2015      887       54   0       0             0 ssh-agent
> Jan  4 15:22:17 figo-desktop kernel: [ 2022]  1000  2022    10904     4577   0       0             0 fcitx
> Jan  4 15:22:17 figo-desktop kernel: [ 2032]  1000  2032    41764     1992   0       0             0 gnome-settings-
> Jan  4 15:22:17 figo-desktop kernel: [ 2036]  1000  2036     2367      413   0       0             0 gvfsd
> Jan  4 15:22:17 figo-desktop kernel: [ 2039]  1000  2039    85188    29574   1       0             0 metacity
> Jan  4 15:22:17 figo-desktop kernel: [ 2049]  1000  2049    14162      277   1       0             0 gvfs-fuse-daemo
> Jan  4 15:22:17 figo-desktop kernel: [ 2053]  1000  2053    76657     3521   1       0             0 gnome-panel
> Jan  4 15:22:17 figo-desktop kernel: [ 2056]  1000  2056    10978      456   1       0             0 gvfs-gdu-volume
> Jan  4 15:22:17 figo-desktop kernel: [ 2058]     0  2058     5767      451   1       0             0 udisks-daemon
> Jan  4 15:22:17 figo-desktop kernel: [ 2059]     0  2059     1291       72   1       0             0 udisks-daemon
> Jan  4 15:22:17 figo-desktop kernel: [ 2069]  1000  2069   168292    49344   1       0             0 nautilus
> Jan  4 15:22:17 figo-desktop kernel: [ 2071]  1000  2071    12907      223   0       0             0 bonobo-activati
> Jan  4 15:22:17 figo-desktop kernel: [ 2081]  1000  2081     1633      136   0       0             0 sh
> Jan  4 15:22:17 figo-desktop kernel: [ 2082]  1000  2082     1666      136   1       0             0 thunderbird
> Jan  4 15:22:17 figo-desktop kernel: [ 2084]  1000  2084    46718     3505   1       0             0 wnck-applet
> Jan  4 15:22:17 figo-desktop kernel: [ 2086]  1000  2086    42862     1463   0       0             0 polkit-gnome-au
> Jan  4 15:22:17 figo-desktop kernel: [ 2087]  1000  2087   285933     1579   0       0             0 nm-applet
> Jan  4 15:22:17 figo-desktop kernel: [ 2104]  1000  2104     5056      693   1       0             0 gdu-notificatio
> Jan  4 15:22:17 figo-desktop kernel: [ 2107]  1000  2107     1666      142   1       0             0 run-mozilla.sh
> Jan  4 15:22:17 figo-desktop kernel: [ 2108]  1000  2108    39395      919   0       0             0 gnome-power-man
> Jan  4 15:22:17 figo-desktop kernel: [ 2109]  1000  2109     7886      701   0       0             0 vino-server
> Jan  4 15:22:17 figo-desktop kernel: [ 2110]  1000  2110    10764      791   1       0             0 evolution-alarm
> Jan  4 15:22:17 figo-desktop kernel: [ 2114]  1000  2114   167865    28925   1       0             0 thunderbird-bin
> Jan  4 15:22:17 figo-desktop kernel: [ 2121]  1000  2121    42098     1969   1       0             0 notify-osd
> Jan  4 15:22:17 figo-desktop kernel: [ 2125]  1000  2125    42488     1203   0       0             0 cpufreq-applet
> Jan  4 15:22:17 figo-desktop kernel: [ 2126]  1000  2126    41394     1145   1       0             0 multiload-apple
> Jan  4 15:22:17 figo-desktop kernel: [ 2129]  1000  2129    64405     1826   0       0             0 mixer_applet2
> Jan  4 15:22:17 figo-desktop kernel: [ 2131]  1000  2131    75346     2473   0       0             0 clock-applet
> Jan  4 15:22:17 figo-desktop kernel: [ 2132]  1000  2132    41163      931   0       0             0 notification-ar
> Jan  4 15:22:17 figo-desktop kernel: [ 2149]  1000  2149    15325      695   1       0             0 e-calendar-fact
> Jan  4 15:22:17 figo-desktop kernel: [ 2153]  1000  2153     7497     1010   0       0             0 gnome-screensav
> Jan  4 15:22:17 figo-desktop kernel: [ 2155]  1000  2155     3848      202   1       0             0 pxgconf
> Jan  4 15:22:17 figo-desktop kernel: [ 2163]  1000  2163     1781      341   0       0             0 mission-control
> Jan  4 15:22:17 figo-desktop kernel: [ 2173]  1000  2173     4486      424   0       0             0 gvfsd-trash
> Jan  4 15:22:17 figo-desktop kernel: [ 2186]     0  2186     3543      190   1       0             0 system-tools-ba
> Jan  4 15:22:17 figo-desktop kernel: [ 2210]  1000  2210     2202      238   0       0             0 gvfsd-burn
> Jan  4 15:22:17 figo-desktop kernel: [ 2245]  1000  2245     3895     1586   0       0             0 gvfsd-metadata
> Jan  4 15:22:17 figo-desktop kernel: [ 2274]  1000  2274    22823      424   1       0             0 conky
> Jan  4 15:22:17 figo-desktop kernel: [ 2281]     0  2281     3295     2278   0       0             0 SystemToolsBack
> Jan  4 15:22:17 figo-desktop kernel: [ 2663]  1000  2663    68807     3072   0       0             0 gnome-terminal
> Jan  4 15:22:17 figo-desktop kernel: [ 2683]  1000  2683      451       76   0       0             0 gnome-pty-helpe
> Jan  4 15:22:17 figo-desktop kernel: [ 2685]  1000  2685     2072      566   0       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [ 2885]     0  2885     1489      119   0       0             0 sudo
> Jan  4 15:22:17 figo-desktop kernel: [ 2886]     0  2886     6273      352   1       0             0 vim
> Jan  4 15:22:17 figo-desktop kernel: [ 2887]  1000  2887      472       84   0       0             0 ping
> Jan  4 15:22:17 figo-desktop kernel: [ 2892]  1000  2892      472       83   1       0             0 ping
> Jan  4 15:22:17 figo-desktop kernel: [ 2894]  1000  2894    76113     5872   1       0             0 vmware
> Jan  4 15:22:17 figo-desktop kernel: [ 2919]  1000  2919    51497     3314   1       0             0 vmware-tray
> Jan  4 15:22:17 figo-desktop kernel: [ 2954]  1000  2954    48676     1589   1       0             0 vmware-unity-he
> Jan  4 15:22:17 figo-desktop kernel: [ 2988]  1000  2988   190471    42233   1       0             0 vmware-vmx
> Jan  4 15:22:17 figo-desktop kernel: [ 3207]  1000  3207     4377      360   1       0             0 gvfsd-computer
> Jan  4 15:22:17 figo-desktop kernel: [ 3211]  1000  3211     9920      506   0       0             0 gvfsd-smb-brows
> Jan  4 15:22:17 figo-desktop kernel: [ 3217]  1000  3217     9876      564   0       0             0 gvfsd-smb
> Jan  4 15:22:17 figo-desktop kernel: [15186]  1000 15186     2069      558   1       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [17451]  1000 17451     5679      496   0       0             0 dconf-service
> Jan  4 15:22:17 figo-desktop kernel: [19085]  1000 19085     1576      149   0       0             0 ssh
> Jan  4 15:22:17 figo-desktop kernel: [19261]  1000 19261     1682      962   0       0             0 wineserver
> Jan  4 15:22:17 figo-desktop kernel: [19266]  1000 19266   399085      212   0       0             0 services.exe
> Jan  4 15:22:17 figo-desktop kernel: [19269]  1000 19269   399117      158   1       0             0 winedevice.exe
> Jan  4 15:22:17 figo-desktop kernel: [19342]  1000 19342   404518      639   0       0             0 explorer.exe
> Jan  4 15:22:17 figo-desktop kernel: [19344]  1000 19344   550020    10958   0       0             0 insight3.exe
> Jan  4 15:22:17 figo-desktop kernel: [  360]  1000   360     2069      540   1       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [ 9821]  1000  9821   166228     2900   0       0             0 stardict
> Jan  4 15:22:17 figo-desktop kernel: [14614]  1000 14614     2040      521   1       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [17002]  1000 17002     2069      541   0       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [18612]     0 18612     1536      125   1       0             0 sudo
> Jan  4 15:22:17 figo-desktop kernel: [18613]     0 18613     1988      608   1       0             0 minicom
> Jan  4 15:22:17 figo-desktop kernel: [21183]  1000 21183     2041      517   1       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [21194]  1000 21194     1611      125   0       0             0 ssh
> Jan  4 15:22:17 figo-desktop kernel: [22451]  1000 22451     2069      571   1       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [23428]  1000 23428     6475      552   1       0             0 vim
> Jan  4 15:22:17 figo-desktop kernel: [23484]  1000 23484     6501      593   1       0             0 vim
> Jan  4 15:22:17 figo-desktop kernel: [23549]  1000 23549     6501      591   0       0             0 vim
> Jan  4 15:22:17 figo-desktop kernel: [23642]  1000 23642     9865      578   0       0             0 gvfsd-smb
> Jan  4 15:22:17 figo-desktop kernel: [26358]  1000 26358   407339     5016   1       0             0 insight3.exe
> Jan  4 15:22:17 figo-desktop kernel: [29711]  1000 29711     9943      606   0       0             0 gvfsd-smb
> Jan  4 15:22:17 figo-desktop kernel: [26156]  1000 26156    61269     9117   0       0             0 skype
> Jan  4 15:22:17 figo-desktop kernel: [32490]  1000 32490     2647      684   0       0             0 gconfd-2
> Jan  4 15:22:17 figo-desktop kernel: [10622]  1000 10622     2072      734   0       0             0 bash
> Jan  4 15:22:17 figo-desktop kernel: [10634]  1000 10634     1576      156   0       0             0 ssh
> Jan  4 15:22:17 figo-desktop kernel: [15410]  1000 15410    76559    12123   0       0             0 evince
> Jan  4 15:22:17 figo-desktop kernel: [15415]  1000 15415     5490      216   1       0             0 evinced
> Jan  4 15:22:17 figo-desktop kernel: [16754]  1000 16754     9899      482   0       0             0 gvfsd-smb
> Jan  4 15:22:17 figo-desktop kernel: [16772]  1000 16772     9900      485   0       0             0 gvfsd-smb
> Jan  4 15:22:17 figo-desktop kernel: [25390]  1000 25390   407306     2149   0       0             0 insight3.exe
> Jan  4 15:22:17 figo-desktop kernel: [ 2127]  1000  2127     1609      122   0       0             0 ssh
> Jan  4 15:22:17 figo-desktop kernel: [10661]    33 10661     4775     1503   1       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [10662]    33 10662     4823     1565   0       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [10663]    33 10663     4823     1566   0       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [10664]    33 10664     4823     1565   0       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [10665]    33 10665     4823     1565   0       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [10666]    33 10666     4823     1565   1       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [32159]  1000 32159   166096    38997   0       0             0 firefox
> Jan  4 15:22:17 figo-desktop kernel: [32228]    33 32228     4823     1508   0       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [32233]    33 32233     4857     1591   1       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [32234]    33 32234     4857     1593   1       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [32241]    33 32241     4789     1532   1       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [32246]    33 32246     4789     1532   0       0             0 httpd
> Jan  4 15:22:17 figo-desktop kernel: [32268]  1000 32268    27543     4106   1       0             0 plugin-containe
> Jan  4 15:22:17 figo-desktop kernel: [32320]  1000 32320    16230     1439   1       0             0 GoogleTalkPlugi
> Jan  4 15:22:17 figo-desktop kernel: [  970]  1000   970   407197     2574   1       0             0 insight3.exe
> Jan  4 15:22:17 figo-desktop kernel: [ 1240]  1000  1240      601      101   1       0             0 top
> Jan  4 15:22:17 figo-desktop kernel: [ 2038]  1000  2038   407785     2659   1       0             0 insight3.exe
> Jan  4 15:22:17 figo-desktop kernel: [12415]     0 12415      580      192   1     -17         -1000 udevd
> Jan  4 15:22:17 figo-desktop kernel: [12416]     0 12416      580      192   1     -17         -1000 udevd
> Jan  4 15:22:17 figo-desktop kernel: [13760]     0 13760      719      217   1       0             0 sh
> Jan  4 15:22:17 figo-desktop kernel: [13762]     0 13762      719      213   0       0             0 sh
> Jan  4 15:22:17 figo-desktop kernel: [13765]     0 13765     1187      161   1       0             0 git
> Jan  4 15:22:17 figo-desktop kernel: [13766]     0 13766      719      236   1       0             0 git-pull
> Jan  4 15:22:17 figo-desktop kernel: [13782]     0 13782     1189      172   0       0             0 git
> Jan  4 15:22:17 figo-desktop kernel: [13784]     0 13784     1575      353   1       0             0 ssh
> Jan  4 15:22:17 figo-desktop kernel: [13824]     0 13824     1535      244   1       0             0 sudo
> Jan  4 15:22:17 figo-desktop kernel: [13825]     0 13825     1386      124   1       0             0 swapoff
> Jan  4 15:22:51 figo-desktop kernel: minicom invoked oom-killer: gfp_mask=0x201da, order=0, oom_adj=0, oom_score_adj=0
> Jan  4 15:22:51 figo-desktop kernel: minicom cpuset=/ mems_allowed=0
> Jan  4 15:22:51 figo-desktop kernel: Pid: 18613, comm: minicom Not tainted 2.6.36-ARCH #1
> Jan  4 15:22:51 figo-desktop kernel: Call Trace:
> Jan  4 15:22:51 figo-desktop kernel: [<c10c11d0>] dump_header.clone.5+0x80/0x1e0
> Jan  4 15:22:51 figo-desktop kernel: [<c10c153c>] oom_kill_process+0x5c/0x1c0
> Jan  4 15:22:51 figo-desktop kernel: [<c10c171d>] ? select_bad_process.clone.7+0x7d/0xd0
> Jan  4 15:22:51 figo-desktop kernel: [<c10c1a0f>] out_of_memory+0xbf/0x1d0
> Jan  4 15:22:51 figo-desktop kernel: [<c10c18d8>] ? try_set_zonelist_oom+0xc8/0xe0
> Jan  4 15:22:51 figo-desktop kernel: [<c10c5288>] __alloc_pages_nodemask+0x5e8/0x600
> Jan  4 15:22:51 figo-desktop kernel: [<c10c6c35>] __do_page_cache_readahead+0x105/0x230
> Jan  4 15:22:51 figo-desktop kernel: [<c10c6fc1>] ra_submit+0x21/0x30
> Jan  4 15:22:51 figo-desktop kernel: [<c10bf31b>] filemap_fault+0x36b/0x3e0
> Jan  4 15:22:51 figo-desktop kernel: [<c10d637b>] __do_fault+0x3b/0x4f0
> Jan  4 15:22:51 figo-desktop kernel: [<c122e619>] ? check_modem_status+0x19/0x1d0
> Jan  4 15:22:51 figo-desktop kernel: [<c10befb0>] ? filemap_fault+0x0/0x3e0
> Jan  4 15:22:51 figo-desktop kernel: [<c10d95c1>] handle_mm_fault+0x111/0x970
> Jan  4 15:22:51 figo-desktop kernel: [<c1172121>] ? tomoyo_init_request_info+0x41/0x50
> Jan  4 15:22:51 figo-desktop kernel: [<c1028d60>] ? do_page_fault+0x0/0x3e0
> Jan  4 15:22:51 figo-desktop kernel: [<c1028eb0>] do_page_fault+0x150/0x3e0
> Jan  4 15:22:51 figo-desktop kernel: [<c1170eb2>] ? tomoyo_file_ioctl+0x12/0x20
> Jan  4 15:22:51 figo-desktop kernel: [<c110c43f>] ? sys_ioctl+0x5f/0x80
> Jan  4 15:22:51 figo-desktop kernel: [<c1028d60>] ? do_page_fault+0x0/0x3e0
> Jan  4 15:22:51 figo-desktop kernel: [<c130753b>] error_code+0x67/0x6c
> Jan  4 15:22:51 figo-desktop kernel: Mem-Info:
> Jan  4 15:22:51 figo-desktop kernel: DMA per-cpu:
> Jan  4 15:22:51 figo-desktop kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jan  4 15:22:51 figo-desktop kernel: CPU    1: hi:    0, btch:   1 usd:   0
> Jan  4 15:22:51 figo-desktop kernel: Normal per-cpu:
> Jan  4 15:22:51 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:  61
> Jan  4 15:22:54 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:   1
> Jan  4 15:22:54 figo-desktop kernel: HighMem per-cpu:
> Jan  4 15:22:54 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:  30
> Jan  4 15:22:54 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:  30
> Jan  4 15:22:54 figo-desktop kernel: active_anon:191656 inactive_anon:101947 isolated_anon:0
> Jan  4 15:22:54 figo-desktop kernel: active_file:54186 inactive_file:122506 isolated_file:0
> Jan  4 15:22:54 figo-desktop kernel: unevictable:17 dirty:0 writeback:0 unstable:0
> Jan  4 15:22:54 figo-desktop kernel: free:11958 slab_reclaimable:5450 slab_unreclaimable:6123
> Jan  4 15:22:54 figo-desktop kernel: mapped:49649 shmem:29219 pagetables:2559 bounce:0
> Jan  4 15:22:54 figo-desktop kernel: DMA free:7960kB min:64kB low:80kB high:96kB active_anon:4772kB inactive_anon:1180kB active_file:524kB inactive_file:768kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15788kB mlocked:0kB dirty:0kB writeback:0kB mapped:592kB shmem:348kB slab_reclaimable:480kB slab_unreclaimable:112kB kernel_stack:8kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2689 all_unreclaimable? yes
> Jan  4 15:22:55 figo-desktop kernel: lowmem_reserve[]: 0 865 1980 1980
> Jan  4 15:22:55 figo-desktop kernel: Normal free:39364kB min:3728kB low:4660kB high:5592kB active_anon:224324kB inactive_anon:226020kB active_file:86076kB inactive_file:207880kB unevictable:68kB isolated(anon):0kB isolated(file):0kB present:885944kB mlocked:68kB dirty:0kB writeback:0kB mapped:57272kB shmem:42072kB slab_reclaimable:21320kB slab_unreclaimable:24380kB kernel_stack:3224kB pagetables:10236kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:445029 all_unreclaimable? yes
> Jan  4 15:22:55 figo-desktop kernel: lowmem_reserve[]: 0 0 8921 8921
> Jan  4 15:22:55 figo-desktop kernel: HighMem free:508kB min:512kB low:1712kB high:2912kB active_anon:537528kB inactive_anon:180588kB active_file:130144kB inactive_file:281376kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1141984kB mlocked:0kB dirty:0kB writeback:0kB mapped:140732kB shmem:74456kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:644938 all_unreclaimable? yes
> Jan  4 15:22:55 figo-desktop kernel: lowmem_reserve[]: 0 0 0 0
> Jan  4 15:22:55 figo-desktop kernel: DMA: 1500*4kB 245*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7960kB
> Jan  4 15:22:55 figo-desktop kernel: Normal: 1399*4kB 3723*8kB 91*16kB 21*32kB 5*64kB 2*128kB 3*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 39364kB
> Jan  4 15:22:55 figo-desktop kernel: HighMem: 27*4kB 10*8kB 18*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 508kB
> Jan  4 15:22:55 figo-desktop kernel: 206073 total pagecache pages
> Jan  4 15:22:55 figo-desktop kernel: 151 pages in swap cache
> Jan  4 15:22:55 figo-desktop kernel: Swap cache stats: add 889409, delete 889258, find 277087/391428
> Jan  4 15:22:55 figo-desktop kernel: Free swap  = -1636kB
> Jan  4 15:22:55 figo-desktop kernel: Total swap = 0kB
> Jan  4 15:22:55 figo-desktop kernel: 515070 pages RAM
> Jan  4 15:22:55 figo-desktop kernel: 287745 pages HighMem
> Jan  4 15:22:55 figo-desktop kernel: 8297 pages reserved
> Jan  4 15:22:55 figo-desktop kernel: 304095 pages shared
> Jan  4 15:22:55 figo-desktop kernel: 306148 pages non-shared
> Jan  4 15:22:55 figo-desktop kernel: [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> Jan  4 15:22:55 figo-desktop kernel: [  583]     0   583      581      207   1     -17         -1000 udevd
> Jan  4 15:22:55 figo-desktop kernel: [ 1303]     0  1303      868       37   0       0             0 syslog-ng
> Jan  4 15:22:55 figo-desktop kernel: [ 1304]     0  1304     1604      350   0       0             0 syslog-ng
> Jan  4 15:22:55 figo-desktop kernel: [ 1306]    81  1306      808      396   1       0             0 dbus-daemon
> Jan  4 15:22:55 figo-desktop kernel: [ 1309]    82  1309     3777      406   0       0             0 hald
> Jan  4 15:22:55 figo-desktop kernel: [ 1310]     0  1310      903      130   1       0             0 hald-runner
> Jan  4 15:22:55 figo-desktop kernel: [ 1339]     0  1339      919       90   1       0             0 hald-addon-inpu
> Jan  4 15:22:55 figo-desktop kernel: [ 1357]     0  1357      919      184   1       0             0 hald-addon-stor
> Jan  4 15:22:55 figo-desktop kernel: [ 1359]    82  1359      824      107   1       0             0 hald-addon-acpi
> Jan  4 15:22:55 figo-desktop kernel: [ 1448]     0  1448      616      294   0       0             0 crond
> Jan  4 15:22:55 figo-desktop kernel: [ 1477]     0  1477      720      108   0       0             0 mysqld_safe
> Jan  4 15:22:55 figo-desktop kernel: [ 1484]     0  1484     3580      269   0       0             0 gdm-binary
> Jan  4 15:22:55 figo-desktop kernel: [ 1497]     0  1497      440       67   1       0             0 agetty
> Jan  4 15:22:55 figo-desktop kernel: [ 1498]     0  1498      440       67   0       0             0 agetty
> Jan  4 15:22:55 figo-desktop kernel: [ 1499]     0  1499      440       67   0       0             0 agetty
> Jan  4 15:22:55 figo-desktop kernel: [ 1500]     0  1500      440       67   1       0             0 agetty
> Jan  4 15:22:55 figo-desktop kernel: [ 1501]     0  1501      440       67   0       0             0 agetty
> Jan  4 15:22:55 figo-desktop kernel: [ 1502]     0  1502      440       68   0       0             0 agetty
> Jan  4 15:22:55 figo-desktop kernel: [ 1553]     0  1553     6607      619   0       0             0 NetworkManager
> Jan  4 15:22:55 figo-desktop kernel: [ 1592]     0  1592     2256      330   0       0             0 cupsd
> Jan  4 15:22:55 figo-desktop kernel: [ 1597]    89  1597    29903     2812   1       0             0 mysqld
> Jan  4 15:22:55 figo-desktop kernel: [ 1598]     0  1598     1652      147   1     -17         -1000 sshd
> Jan  4 15:22:55 figo-desktop kernel: [ 1612]     0  1612     6263      508   1       0             0 polkitd
> Jan  4 15:22:55 figo-desktop kernel: [ 1613]     0  1613     2015      123   1       0             0 vmware-usbarbit
> Jan  4 15:22:55 figo-desktop kernel: [ 1617]     0  1617     2887     1603   0       0             0 cntlm
> Jan  4 15:22:55 figo-desktop kernel: [ 1620]     0  1620     4398      366   0       0             0 gdm-simple-slav
> Jan  4 15:22:55 figo-desktop kernel: [ 1636]     0  1636    37298    12186   0       0             0 Xorg
> Jan  4 15:22:55 figo-desktop kernel: [ 1638]     0  1638     1248       88   0       0             0 wpa_supplicant
> Jan  4 15:22:55 figo-desktop kernel: [ 1720]     0  1720     4789     1555   1       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [ 1722]     0  1722      488       93   0       0             0 dhcpcd
> Jan  4 15:22:55 figo-desktop kernel: [ 1732]     0  1732      519       62   1       0             0 vmnet-bridge
> Jan  4 15:22:55 figo-desktop kernel: [ 1750]     0  1750     4922      304   1       0             0 smbd
> Jan  4 15:22:55 figo-desktop kernel: [ 1764]     0  1764      655       39   1       0             0 vmnet-dhcpd
> Jan  4 15:22:55 figo-desktop kernel: [ 1772]     0  1772      513       15   0       0             0 vmnet-netifup
> Jan  4 15:22:55 figo-desktop kernel: [ 1774]     0  1774      655       39   0       0             0 vmnet-dhcpd
> Jan  4 15:22:55 figo-desktop kernel: [ 1776]     0  1776     4922      225   0       0             0 smbd
> Jan  4 15:22:55 figo-desktop kernel: [ 1778]     0  1778      634       44   0       0             0 vmnet-natd
> Jan  4 15:22:55 figo-desktop kernel: [ 1780]     0  1780      513       14   1       0             0 vmnet-netifup
> Jan  4 15:22:55 figo-desktop kernel: [ 1796]     0  1796     6677      329   0       0             0 console-kit-dae
> Jan  4 15:22:55 figo-desktop kernel: [ 1899]   120  1899     6587      598   0       0             0 polkit-gnome-au
> Jan  4 15:22:55 figo-desktop kernel: [ 1903]     0  1903     3905      245   0       0             0 gdm-session-wor
> Jan  4 15:22:55 figo-desktop kernel: [ 1906]     0  1906     3677      314   1       0             0 upowerd
> Jan  4 15:22:55 figo-desktop kernel: [ 1974]  1000  1974    10963     1248   0       0             0 gnome-keyring-d
> Jan  4 15:22:55 figo-desktop kernel: [ 1993]  1000  1993     9253      776   0       0             0 gnome-session
> Jan  4 15:22:55 figo-desktop kernel: [ 2012]  1000  2012      796      103   0       0             0 dbus-launch
> Jan  4 15:22:55 figo-desktop kernel: [ 2013]  1000  2013     5854     4985   0       0             0 dbus-daemon
> Jan  4 15:22:55 figo-desktop kernel: [ 2015]  1000  2015      887       54   0       0             0 ssh-agent
> Jan  4 15:22:55 figo-desktop kernel: [ 2022]  1000  2022    10904     4789   0       0             0 fcitx
> Jan  4 15:22:55 figo-desktop kernel: [ 2032]  1000  2032    41764     2007   0       0             0 gnome-settings-
> Jan  4 15:22:55 figo-desktop kernel: [ 2036]  1000  2036     2367      416   0       0             0 gvfsd
> Jan  4 15:22:55 figo-desktop kernel: [ 2039]  1000  2039    85188    29636   1       0             0 metacity
> Jan  4 15:22:55 figo-desktop kernel: [ 2049]  1000  2049    14162      280   1       0             0 gvfs-fuse-daemo
> Jan  4 15:22:55 figo-desktop kernel: [ 2053]  1000  2053    76657     3620   0       0             0 gnome-panel
> Jan  4 15:22:55 figo-desktop kernel: [ 2056]  1000  2056    10978      563   1       0             0 gvfs-gdu-volume
> Jan  4 15:22:55 figo-desktop kernel: [ 2058]     0  2058     5767      503   0       0             0 udisks-daemon
> Jan  4 15:22:55 figo-desktop kernel: [ 2059]     0  2059     1291       72   0       0             0 udisks-daemon
> Jan  4 15:22:55 figo-desktop kernel: [ 2069]  1000  2069   168292    50943   0       0             0 nautilus
> Jan  4 15:22:55 figo-desktop kernel: [ 2071]  1000  2071    12907      223   0       0             0 bonobo-activati
> Jan  4 15:22:55 figo-desktop kernel: [ 2081]  1000  2081     1633      136   0       0             0 sh
> Jan  4 15:22:55 figo-desktop kernel: [ 2082]  1000  2082     1666      136   1       0             0 thunderbird
> Jan  4 15:22:55 figo-desktop kernel: [ 2084]  1000  2084    46718     3501   1       0             0 wnck-applet
> Jan  4 15:22:55 figo-desktop kernel: [ 2086]  1000  2086    42862     1487   0       0             0 polkit-gnome-au
> Jan  4 15:22:55 figo-desktop kernel: [ 2087]  1000  2087   285933     1584   0       0             0 nm-applet
> Jan  4 15:22:55 figo-desktop kernel: [ 2104]  1000  2104     5056      715   0       0             0 gdu-notificatio
> Jan  4 15:22:55 figo-desktop kernel: [ 2107]  1000  2107     1666      142   1       0             0 run-mozilla.sh
> Jan  4 15:22:55 figo-desktop kernel: [ 2108]  1000  2108    39395      973   0       0             0 gnome-power-man
> Jan  4 15:22:55 figo-desktop kernel: [ 2109]  1000  2109     7886      709   0       0             0 vino-server
> Jan  4 15:22:55 figo-desktop kernel: [ 2110]  1000  2110    10764      791   1       0             0 evolution-alarm
> Jan  4 15:22:55 figo-desktop kernel: [ 2114]  1000  2114   167865    29673   1       0             0 thunderbird-bin
> Jan  4 15:22:55 figo-desktop kernel: [ 2121]  1000  2121    42098     1965   0       0             0 notify-osd
> Jan  4 15:22:55 figo-desktop kernel: [ 2125]  1000  2125    42488     1203   1       0             0 cpufreq-applet
> Jan  4 15:22:55 figo-desktop kernel: [ 2126]  1000  2126    41394     1148   1       0             0 multiload-apple
> Jan  4 15:22:55 figo-desktop kernel: [ 2129]  1000  2129    64405     1827   0       0             0 mixer_applet2
> Jan  4 15:22:55 figo-desktop kernel: [ 2131]  1000  2131    75346     2489   0       0             0 clock-applet
> Jan  4 15:22:55 figo-desktop kernel: [ 2132]  1000  2132    41163      930   1       0             0 notification-ar
> Jan  4 15:22:55 figo-desktop kernel: [ 2149]  1000  2149    15325      697   1       0             0 e-calendar-fact
> Jan  4 15:22:55 figo-desktop kernel: [ 2153]  1000  2153     7497     1008   0       0             0 gnome-screensav
> Jan  4 15:22:55 figo-desktop kernel: [ 2155]  1000  2155     3848      202   1       0             0 pxgconf
> Jan  4 15:22:55 figo-desktop kernel: [ 2163]  1000  2163     1781      342   0       0             0 mission-control
> Jan  4 15:22:55 figo-desktop kernel: [ 2173]  1000  2173     4486      428   0       0             0 gvfsd-trash
> Jan  4 15:22:55 figo-desktop kernel: [ 2186]     0  2186     3543      192   1       0             0 system-tools-ba
> Jan  4 15:22:55 figo-desktop kernel: [ 2210]  1000  2210     2202      238   0       0             0 gvfsd-burn
> Jan  4 15:22:55 figo-desktop kernel: [ 2245]  1000  2245     3895     1730   0       0             0 gvfsd-metadata
> Jan  4 15:22:55 figo-desktop kernel: [ 2274]  1000  2274    22823      424   0       0             0 conky
> Jan  4 15:22:55 figo-desktop kernel: [ 2281]     0  2281     3295     2278   0       0             0 SystemToolsBack
> Jan  4 15:22:55 figo-desktop kernel: [ 2663]  1000  2663    68807     3042   1       0             0 gnome-terminal
> Jan  4 15:22:55 figo-desktop kernel: [ 2683]  1000  2683      451       76   0       0             0 gnome-pty-helpe
> Jan  4 15:22:55 figo-desktop kernel: [ 2685]  1000  2685     2072      570   0       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [ 2885]     0  2885     1489      119   0       0             0 sudo
> Jan  4 15:22:55 figo-desktop kernel: [ 2886]     0  2886     6273      355   1       0             0 vim
> Jan  4 15:22:55 figo-desktop kernel: [ 2887]  1000  2887      472       84   0       0             0 ping
> Jan  4 15:22:55 figo-desktop kernel: [ 2892]  1000  2892      472       83   1       0             0 ping
> Jan  4 15:22:55 figo-desktop kernel: [ 2894]  1000  2894    76113     5890   0       0             0 vmware
> Jan  4 15:22:55 figo-desktop kernel: [ 2919]  1000  2919    51497     3315   1       0             0 vmware-tray
> Jan  4 15:22:55 figo-desktop kernel: [ 2954]  1000  2954    48676     1589   0       0             0 vmware-unity-he
> Jan  4 15:22:55 figo-desktop kernel: [ 2988]  1000  2988   190471    42400   0       0             0 vmware-vmx
> Jan  4 15:22:55 figo-desktop kernel: [ 3207]  1000  3207     4377      362   1       0             0 gvfsd-computer
> Jan  4 15:22:55 figo-desktop kernel: [ 3211]  1000  3211     9920      509   0       0             0 gvfsd-smb-brows
> Jan  4 15:22:55 figo-desktop kernel: [ 3217]  1000  3217     9876      569   0       0             0 gvfsd-smb
> Jan  4 15:22:55 figo-desktop kernel: [15186]  1000 15186     2069      558   1       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [17451]  1000 17451     5679      503   0       0             0 dconf-service
> Jan  4 15:22:55 figo-desktop kernel: [19085]  1000 19085     1576      149   0       0             0 ssh
> Jan  4 15:22:55 figo-desktop kernel: [19261]  1000 19261     1682      967   0       0             0 wineserver
> Jan  4 15:22:55 figo-desktop kernel: [19266]  1000 19266   399085      212   0       0             0 services.exe
> Jan  4 15:22:55 figo-desktop kernel: [19269]  1000 19269   399117      158   1       0             0 winedevice.exe
> Jan  4 15:22:55 figo-desktop kernel: [19342]  1000 19342   404518      643   0       0             0 explorer.exe
> Jan  4 15:22:55 figo-desktop kernel: [19344]  1000 19344   550020    11028   1       0             0 insight3.exe
> Jan  4 15:22:55 figo-desktop kernel: [  360]  1000   360     2069      541   1       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [ 9821]  1000  9821   166228     2915   0       0             0 stardict
> Jan  4 15:22:55 figo-desktop kernel: [14614]  1000 14614     2040      523   1       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [17002]  1000 17002     2069      541   0       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [18612]     0 18612     1536      125   1       0             0 sudo
> Jan  4 15:22:55 figo-desktop kernel: [18613]     0 18613     1988      608   1       0             0 minicom
> Jan  4 15:22:55 figo-desktop kernel: [21183]  1000 21183     2041      517   1       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [21194]  1000 21194     1611      125   0       0             0 ssh
> Jan  4 15:22:55 figo-desktop kernel: [22451]  1000 22451     2069      578   1       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [23428]  1000 23428     6475      554   1       0             0 vim
> Jan  4 15:22:55 figo-desktop kernel: [23484]  1000 23484     6501      594   1       0             0 vim
> Jan  4 15:22:55 figo-desktop kernel: [23549]  1000 23549     6501      594   0       0             0 vim
> Jan  4 15:22:55 figo-desktop kernel: [23642]  1000 23642     9865      594   0       0             0 gvfsd-smb
> Jan  4 15:22:55 figo-desktop kernel: [26358]  1000 26358   407339     5019   1       0             0 insight3.exe
> Jan  4 15:22:55 figo-desktop kernel: [29711]  1000 29711     9943      617   0       0             0 gvfsd-smb
> Jan  4 15:22:55 figo-desktop kernel: [26156]  1000 26156    61269     9179   0       0             0 skype
> Jan  4 15:22:55 figo-desktop kernel: [32490]  1000 32490     2647      684   0       0             0 gconfd-2
> Jan  4 15:22:55 figo-desktop kernel: [10622]  1000 10622     2072      725   1       0             0 bash
> Jan  4 15:22:55 figo-desktop kernel: [10634]  1000 10634     1576      156   0       0             0 ssh
> Jan  4 15:22:55 figo-desktop kernel: [15410]  1000 15410    76559    12161   0       0             0 evince
> Jan  4 15:22:55 figo-desktop kernel: [15415]  1000 15415     5490      217   1       0             0 evinced
> Jan  4 15:22:55 figo-desktop kernel: [16754]  1000 16754     9899      485   0       0             0 gvfsd-smb
> Jan  4 15:22:55 figo-desktop kernel: [16772]  1000 16772     9900      500   0       0             0 gvfsd-smb
> Jan  4 15:22:55 figo-desktop kernel: [25390]  1000 25390   407306     2164   1       0             0 insight3.exe
> Jan  4 15:22:55 figo-desktop kernel: [ 2127]  1000  2127     1609      125   0       0             0 ssh
> Jan  4 15:22:55 figo-desktop kernel: [10661]    33 10661     4775     1510   1       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [10662]    33 10662     4823     1569   0       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [10663]    33 10663     4823     1570   0       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [10664]    33 10664     4823     1569   0       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [10665]    33 10665     4823     1569   0       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [10666]    33 10666     4823     1569   1       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [32159]  1000 32159   166096    39479   0       0             0 firefox
> Jan  4 15:22:55 figo-desktop kernel: [32228]    33 32228     4823     1512   0       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [32233]    33 32233     4857     1596   1       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [32234]    33 32234     4857     1597   1       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [32241]    33 32241     4789     1536   1       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [32246]    33 32246     4789     1536   0       0             0 httpd
> Jan  4 15:22:55 figo-desktop kernel: [32268]  1000 32268    27543     4279   1       0             0 plugin-containe
> Jan  4 15:22:55 figo-desktop kernel: [32320]  1000 32320    16230     1445   1       0             0 GoogleTalkPlugi
> Jan  4 15:22:55 figo-desktop kernel: [  970]  1000   970   407197     2636   1       0             0 insight3.exe
> Jan  4 15:22:55 figo-desktop kernel: [ 1240]  1000  1240      601      116   1       0             0 top
> Jan  4 15:22:55 figo-desktop kernel: [ 2038]  1000  2038   407786     2842   0       0             0 insight3.exe
> Jan  4 15:22:55 figo-desktop kernel: [12415]     0 12415      543      232   1     -17         -1000 udevd
> Jan  4 15:22:55 figo-desktop kernel: [12416]     0 12416      580      195   1     -17         -1000 udevd
> Jan  4 15:22:55 figo-desktop kernel: [13904]     0 13904     1488      219   1       0             0 sudo
> Jan  4 15:22:55 figo-desktop kernel: [13906]     0 13906     1386      131   0       0             0 swapoff
> Jan  4 15:23:30 figo-desktop kernel: hald-addon-stor invoked oom-killer: gfp_mask=0x280da, order=0, oom_adj=0, oom_score_adj=0
> Jan  4 15:23:30 figo-desktop kernel: hald-addon-stor cpuset=/ mems_allowed=0
> Jan  4 15:23:30 figo-desktop kernel: Pid: 1357, comm: hald-addon-stor Not tainted 2.6.36-ARCH #1
> Jan  4 15:23:30 figo-desktop kernel: Call Trace:
> Jan  4 15:23:30 figo-desktop kernel: [<c10c11d0>] dump_header.clone.5+0x80/0x1e0
> Jan  4 15:23:30 figo-desktop kernel: [<c10c153c>] oom_kill_process+0x5c/0x1c0
> Jan  4 15:23:30 figo-desktop kernel: [<c10c171d>] ? select_bad_process.clone.7+0x7d/0xd0
> Jan  4 15:23:30 figo-desktop kernel: [<c10c1a0f>] out_of_memory+0xbf/0x1d0
> Jan  4 15:23:30 figo-desktop kernel: [<c10c18d8>] ? try_set_zonelist_oom+0xc8/0xe0
> Jan  4 15:23:30 figo-desktop kernel: [<c10c5288>] __alloc_pages_nodemask+0x5e8/0x600
> Jan  4 15:23:35 figo-desktop kernel: [<c10d9b42>] handle_mm_fault+0x692/0x970
> Jan  4 15:23:35 figo-desktop kernel: [<c110f2c9>] ? prepend_path+0x59/0x140
> Jan  4 15:23:35 figo-desktop kernel: [<c10f1b85>] ? __kmalloc+0xb5/0x1b0
> Jan  4 15:23:35 figo-desktop kernel: [<c1028d60>] ? do_page_fault+0x0/0x3e0
> Jan  4 15:23:35 figo-desktop kernel: [<c1028eb0>] do_page_fault+0x150/0x3e0
> Jan  4 15:23:35 figo-desktop kernel: [<c1171e27>] ? tomoyo_fill_path_info+0x17/0xf0
> Jan  4 15:23:35 figo-desktop kernel: [<c113e74a>] ? dquot_file_open+0x1a/0x50
> Jan  4 15:23:35 figo-desktop kernel: [<f81e2225>] ? ext4_file_open+0x45/0xe0 [ext4]
> Jan  4 15:23:35 figo-desktop kernel: [<c1028d60>] ? do_page_fault+0x0/0x3e0
> Jan  4 15:23:35 figo-desktop kernel: [<c130753b>] error_code+0x67/0x6c
> Jan  4 15:23:35 figo-desktop kernel: [<c10be3eb>] ? file_read_actor+0x2b/0xd0
> Jan  4 15:23:35 figo-desktop kernel: [<c10be719>] ? find_get_page+0x29/0xb0
> Jan  4 15:23:35 figo-desktop kernel: [<c10c0381>] generic_file_aio_read+0x331/0x760
> Jan  4 15:23:35 figo-desktop kernel: [<c10fd2dc>] do_sync_read+0x9c/0xd0
> Jan  4 15:23:35 figo-desktop kernel: [<c10fd5ed>] ? rw_verify_area+0x5d/0xd0
> Jan  4 15:23:35 figo-desktop kernel: [<c10fda87>] vfs_read+0x97/0x160
> Jan  4 15:23:35 figo-desktop kernel: [<c10fd240>] ? do_sync_read+0x0/0xd0
> Jan  4 15:23:35 figo-desktop kernel: [<c10fdb8d>] sys_read+0x3d/0x70
> Jan  4 15:23:35 figo-desktop kernel: [<c100379f>] sysenter_do_call+0x12/0x28
> Jan  4 15:23:35 figo-desktop kernel: Mem-Info:
> Jan  4 15:23:35 figo-desktop kernel: DMA per-cpu:
> Jan  4 15:23:35 figo-desktop kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jan  4 15:23:35 figo-desktop kernel: CPU    1: hi:    0, btch:   1 usd:   0
> Jan  4 15:23:35 figo-desktop kernel: Normal per-cpu:
> Jan  4 15:23:35 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:  31
> Jan  4 15:23:35 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Jan  4 15:23:35 figo-desktop kernel: HighMem per-cpu:
> Jan  4 15:23:35 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:  30
> Jan  4 15:23:35 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:   0
> Jan  4 15:23:35 figo-desktop kernel: active_anon:184575 inactive_anon:108966 isolated_anon:0
> Jan  4 15:23:35 figo-desktop kernel: active_file:54381 inactive_file:122394 isolated_file:0
> Jan  4 15:23:35 figo-desktop kernel: unevictable:17 dirty:1 writeback:0 unstable:0
> Jan  4 15:23:35 figo-desktop kernel: free:11938 slab_reclaimable:5448 slab_unreclaimable:6124
> Jan  4 15:23:35 figo-desktop kernel: mapped:48017 shmem:28204 pagetables:2587 bounce:0
> Jan  4 15:23:35 figo-desktop kernel: DMA free:7964kB min:64kB low:80kB high:96kB active_anon:4624kB inactive_anon:1316kB active_file:532kB inactive_file:760kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15788kB mlocked:0kB dirty:0kB writeback:0kB mapped:548kB shmem:72kB slab_reclaimable:480kB slab_unreclaimable:112kB kernel_stack:8kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:1963 all_unreclaimable? yes
> Jan  4 15:23:35 figo-desktop kernel: lowmem_reserve[]: 0 865 1980 1980
> Jan  4 15:23:35 figo-desktop kernel: Normal free:39344kB min:3728kB low:4660kB high:5592kB active_anon:234180kB inactive_anon:216232kB active_file:86148kB inactive_file:207704kB unevictable:68kB isolated(anon):0kB isolated(file):0kB present:885944kB mlocked:68kB dirty:4kB writeback:0kB mapped:55852kB shmem:36852kB slab_reclaimable:21312kB slab_unreclaimable:24384kB kernel_stack:3272kB pagetables:10348kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:441365 all_unreclaimable? yes
> Jan  4 15:23:35 figo-desktop kernel: lowmem_reserve[]: 0 0 8921 8921
> Jan  4 15:23:35 figo-desktop kernel: HighMem free:444kB min:512kB low:1712kB high:2912kB active_anon:499496kB inactive_anon:218316kB active_file:130844kB inactive_file:281112kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1141984kB mlocked:0kB dirty:0kB writeback:0kB mapped:135668kB shmem:75892kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:686994 all_unreclaimable? yes
> Jan  4 15:23:35 figo-desktop kernel: lowmem_reserve[]: 0 0 0 0
> Jan  4 15:23:35 figo-desktop kernel: DMA: 1549*4kB 221*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7964kB
> Jan  4 15:23:35 figo-desktop kernel: Normal: 1472*4kB 3840*8kB 47*16kB 8*32kB 3*64kB 2*128kB 3*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 39344kB
> Jan  4 15:23:35 figo-desktop kernel: HighMem: 13*4kB 9*8kB 18*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 444kB
> Jan  4 15:23:35 figo-desktop kernel: 224327 total pagecache pages
> Jan  4 15:23:35 figo-desktop kernel: 19316 pages in swap cache
> Jan  4 15:23:35 figo-desktop kernel: Swap cache stats: add 999341, delete 980025, find 277475/391898
> Jan  4 15:23:35 figo-desktop kernel: Free swap  = -79552kB
> Jan  4 15:23:35 figo-desktop kernel: Total swap = 0kB
> Jan  4 15:23:35 figo-desktop kernel: 515070 pages RAM
> Jan  4 15:23:35 figo-desktop kernel: 287745 pages HighMem
> Jan  4 15:23:35 figo-desktop kernel: 8297 pages reserved
> Jan  4 15:23:35 figo-desktop kernel: 300103 pages shared
> Jan  4 15:23:35 figo-desktop kernel: 310097 pages non-shared
> Jan  4 15:23:35 figo-desktop kernel: [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> Jan  4 15:23:35 figo-desktop kernel: [  583]     0   583      581      195   0     -17         -1000 udevd
> Jan  4 15:23:35 figo-desktop kernel: [ 1303]     0  1303      868       35   0       0             0 syslog-ng
> Jan  4 15:23:35 figo-desktop kernel: [ 1304]     0  1304     1604      387   0       0             0 syslog-ng
> Jan  4 15:23:35 figo-desktop kernel: [ 1306]    81  1306      808      375   0       0             0 dbus-daemon
> Jan  4 15:23:35 figo-desktop kernel: [ 1309]    82  1309     3777      391   0       0             0 hald
> Jan  4 15:23:35 figo-desktop kernel: [ 1310]     0  1310      903      128   1       0             0 hald-runner
> Jan  4 15:23:35 figo-desktop kernel: [ 1339]     0  1339      919       87   1       0             0 hald-addon-inpu
> Jan  4 15:23:35 figo-desktop kernel: [ 1357]     0  1357      920      184   1       0             0 hald-addon-stor
> Jan  4 15:23:35 figo-desktop kernel: [ 1359]    82  1359      824      106   1       0             0 hald-addon-acpi
> Jan  4 15:23:35 figo-desktop kernel: [ 1448]     0  1448      616      294   1       0             0 crond
> Jan  4 15:23:35 figo-desktop kernel: [ 1477]     0  1477      720      108   0       0             0 mysqld_safe
> Jan  4 15:23:35 figo-desktop kernel: [ 1484]     0  1484     3580      268   0       0             0 gdm-binary
> Jan  4 15:23:35 figo-desktop kernel: [ 1497]     0  1497      440       66   1       0             0 agetty
> Jan  4 15:23:35 figo-desktop kernel: [ 1498]     0  1498      440       66   0       0             0 agetty
> Jan  4 15:23:35 figo-desktop kernel: [ 1499]     0  1499      440       66   0       0             0 agetty
> Jan  4 15:23:35 figo-desktop kernel: [ 1500]     0  1500      440       67   1       0             0 agetty
> Jan  4 15:23:35 figo-desktop kernel: [ 1501]     0  1501      440       66   0       0             0 agetty
> Jan  4 15:23:35 figo-desktop kernel: [ 1502]     0  1502      440       67   0       0             0 agetty
> Jan  4 15:23:35 figo-desktop kernel: [ 1553]     0  1553     6607      650   1       0             0 NetworkManager
> Jan  4 15:23:35 figo-desktop kernel: [ 1592]     0  1592     2256      329   0       0             0 cupsd
> Jan  4 15:23:35 figo-desktop kernel: [ 1597]    89  1597    29903     2812   1       0             0 mysqld
> Jan  4 15:23:35 figo-desktop kernel: [ 1598]     0  1598     1652      147   1     -17         -1000 sshd
> Jan  4 15:23:35 figo-desktop kernel: [ 1612]     0  1612     6263      506   1       0             0 polkitd
> Jan  4 15:23:35 figo-desktop kernel: [ 1613]     0  1613     2015      121   1       0             0 vmware-usbarbit
> Jan  4 15:23:35 figo-desktop kernel: [ 1617]     0  1617     2887     1481   0       0             0 cntlm
> Jan  4 15:23:35 figo-desktop kernel: [ 1620]     0  1620     4398      365   0       0             0 gdm-simple-slav
> Jan  4 15:23:35 figo-desktop kernel: [ 1636]     0  1636    37287    10088   1       0             0 Xorg
> Jan  4 15:23:35 figo-desktop kernel: [ 1638]     0  1638     1248       88   0       0             0 wpa_supplicant
> Jan  4 15:23:35 figo-desktop kernel: [ 1720]     0  1720     4789     1527   1       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [ 1722]     0  1722      488       92   0       0             0 dhcpcd
> Jan  4 15:23:35 figo-desktop kernel: [ 1732]     0  1732      519       61   1       0             0 vmnet-bridge
> Jan  4 15:23:35 figo-desktop kernel: [ 1750]     0  1750     4922      302   1       0             0 smbd
> Jan  4 15:23:35 figo-desktop kernel: [ 1764]     0  1764      655       37   1       0             0 vmnet-dhcpd
> Jan  4 15:23:35 figo-desktop kernel: [ 1772]     0  1772      513       15   0       0             0 vmnet-netifup
> Jan  4 15:23:35 figo-desktop kernel: [ 1774]     0  1774      655       38   0       0             0 vmnet-dhcpd
> Jan  4 15:23:35 figo-desktop kernel: [ 1776]     0  1776     4922      223   0       0             0 smbd
> Jan  4 15:23:35 figo-desktop kernel: [ 1778]     0  1778      634       43   0       0             0 vmnet-natd
> Jan  4 15:23:35 figo-desktop kernel: [ 1780]     0  1780      513       13   1       0             0 vmnet-netifup
> Jan  4 15:23:35 figo-desktop kernel: [ 1796]     0  1796     6677      327   0       0             0 console-kit-dae
> Jan  4 15:23:35 figo-desktop kernel: [ 1899]   120  1899     6587      597   0       0             0 polkit-gnome-au
> Jan  4 15:23:35 figo-desktop kernel: [ 1903]     0  1903     3905      244   0       0             0 gdm-session-wor
> Jan  4 15:23:35 figo-desktop kernel: [ 1906]     0  1906     3677      313   1       0             0 upowerd
> Jan  4 15:23:35 figo-desktop kernel: [ 1974]  1000  1974    10963      917   0       0             0 gnome-keyring-d
> Jan  4 15:23:35 figo-desktop kernel: [ 1993]  1000  1993     9253      771   0       0             0 gnome-session
> Jan  4 15:23:35 figo-desktop kernel: [ 2012]  1000  2012      796      103   0       0             0 dbus-launch
> Jan  4 15:23:35 figo-desktop kernel: [ 2013]  1000  2013     5854     4749   0       0             0 dbus-daemon
> Jan  4 15:23:35 figo-desktop kernel: [ 2015]  1000  2015      887       54   1       0             0 ssh-agent
> Jan  4 15:23:35 figo-desktop kernel: [ 2022]  1000  2022    10904     2634   1       0             0 fcitx
> Jan  4 15:23:35 figo-desktop kernel: [ 2032]  1000  2032    41764     1971   1       0             0 gnome-settings-
> Jan  4 15:23:35 figo-desktop kernel: [ 2036]  1000  2036     2367      408   0       0             0 gvfsd
> Jan  4 15:23:35 figo-desktop kernel: [ 2039]  1000  2039    85188    22437   0       0             0 metacity
> Jan  4 15:23:35 figo-desktop kernel: [ 2049]  1000  2049    14162      267   1       0             0 gvfs-fuse-daemo
> Jan  4 15:23:35 figo-desktop kernel: [ 2053]  1000  2053    76657     3448   0       0             0 gnome-panel
> Jan  4 15:23:35 figo-desktop kernel: [ 2056]  1000  2056    10978      563   0       0             0 gvfs-gdu-volume
> Jan  4 15:23:35 figo-desktop kernel: [ 2058]     0  2058     5767      451   1       0             0 udisks-daemon
> Jan  4 15:23:35 figo-desktop kernel: [ 2059]     0  2059     1291       72   0       0             0 udisks-daemon
> Jan  4 15:23:35 figo-desktop kernel: [ 2069]  1000  2069   168292    48504   0       0             0 nautilus
> Jan  4 15:23:35 figo-desktop kernel: [ 2071]  1000  2071    12907      223   0       0             0 bonobo-activati
> Jan  4 15:23:35 figo-desktop kernel: [ 2081]  1000  2081     1633      136   0       0             0 sh
> Jan  4 15:23:35 figo-desktop kernel: [ 2082]  1000  2082     1666      136   1       0             0 thunderbird
> Jan  4 15:23:35 figo-desktop kernel: [ 2084]  1000  2084    46718     3138   0       0             0 wnck-applet
> Jan  4 15:23:35 figo-desktop kernel: [ 2086]  1000  2086    42862     1439   0       0             0 polkit-gnome-au
> Jan  4 15:23:35 figo-desktop kernel: [ 2087]  1000  2087   285933     1524   0       0             0 nm-applet
> Jan  4 15:23:35 figo-desktop kernel: [ 2104]  1000  2104     5056      732   0       0             0 gdu-notificatio
> Jan  4 15:23:35 figo-desktop kernel: [ 2107]  1000  2107     1666      142   1       0             0 run-mozilla.sh
> Jan  4 15:23:35 figo-desktop kernel: [ 2108]  1000  2108    39395      953   1       0             0 gnome-power-man
> Jan  4 15:23:35 figo-desktop kernel: [ 2109]  1000  2109     7886      709   0       0             0 vino-server
> Jan  4 15:23:35 figo-desktop kernel: [ 2110]  1000  2110    10764      790   1       0             0 evolution-alarm
> Jan  4 15:23:35 figo-desktop kernel: [ 2114]  1000  2114   167865    29127   0       0             0 thunderbird-bin
> Jan  4 15:23:35 figo-desktop kernel: [ 2121]  1000  2121    42098     1885   0       0             0 notify-osd
> Jan  4 15:23:35 figo-desktop kernel: [ 2125]  1000  2125    42488     1202   1       0             0 cpufreq-applet
> Jan  4 15:23:35 figo-desktop kernel: [ 2126]  1000  2126    41394     1143   0       0             0 multiload-apple
> Jan  4 15:23:35 figo-desktop kernel: [ 2129]  1000  2129    64405     1748   0       0             0 mixer_applet2
> Jan  4 15:23:35 figo-desktop kernel: [ 2131]  1000  2131    75346     2380   1       0             0 clock-applet
> Jan  4 15:23:35 figo-desktop kernel: [ 2132]  1000  2132    41163      924   1       0             0 notification-ar
> Jan  4 15:23:35 figo-desktop kernel: [ 2149]  1000  2149    15325      696   1       0             0 e-calendar-fact
> Jan  4 15:23:35 figo-desktop kernel: [ 2153]  1000  2153     7497     1006   0       0             0 gnome-screensav
> Jan  4 15:23:35 figo-desktop kernel: [ 2155]  1000  2155     3848      202   1       0             0 pxgconf
> Jan  4 15:23:35 figo-desktop kernel: [ 2163]  1000  2163     1781      342   0       0             0 mission-control
> Jan  4 15:23:35 figo-desktop kernel: [ 2173]  1000  2173     4486      417   0       0             0 gvfsd-trash
> Jan  4 15:23:35 figo-desktop kernel: [ 2186]     0  2186     3543      192   1       0             0 system-tools-ba
> Jan  4 15:23:35 figo-desktop kernel: [ 2210]  1000  2210     2202      236   0       0             0 gvfsd-burn
> Jan  4 15:23:35 figo-desktop kernel: [ 2245]  1000  2245     3895     1713   0       0             0 gvfsd-metadata
> Jan  4 15:23:35 figo-desktop kernel: [ 2274]  1000  2274    22825      423   1       0             0 conky
> Jan  4 15:23:35 figo-desktop kernel: [ 2281]     0  2281     3295     2278   0       0             0 SystemToolsBack
> Jan  4 15:23:35 figo-desktop kernel: [ 2663]  1000  2663    68807     2924   1       0             0 gnome-terminal
> Jan  4 15:23:35 figo-desktop kernel: [ 2683]  1000  2683      451       76   0       0             0 gnome-pty-helpe
> Jan  4 15:23:35 figo-desktop kernel: [ 2685]  1000  2685     2072      555   0       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [ 2885]     0  2885     1489      118   0       0             0 sudo
> Jan  4 15:23:35 figo-desktop kernel: [ 2886]     0  2886     6273      353   1       0             0 vim
> Jan  4 15:23:35 figo-desktop kernel: [ 2887]  1000  2887      472       84   0       0             0 ping
> Jan  4 15:23:35 figo-desktop kernel: [ 2892]  1000  2892      472       83   1       0             0 ping
> Jan  4 15:23:35 figo-desktop kernel: [ 2894]  1000  2894    76113     5382   0       0             0 vmware
> Jan  4 15:23:35 figo-desktop kernel: [ 2919]  1000  2919    51497     3224   1       0             0 vmware-tray
> Jan  4 15:23:35 figo-desktop kernel: [ 2954]  1000  2954    48676     1588   1       0             0 vmware-unity-he
> Jan  4 15:23:35 figo-desktop kernel: [ 2988]  1000  2988   190471    40349   1       0             0 vmware-vmx
> Jan  4 15:23:35 figo-desktop kernel: [ 3207]  1000  3207     4377      279   1       0             0 gvfsd-computer
> Jan  4 15:23:35 figo-desktop kernel: [ 3211]  1000  3211     9920      416   0       0             0 gvfsd-smb-brows
> Jan  4 15:23:35 figo-desktop kernel: [ 3217]  1000  3217     9876      545   0       0             0 gvfsd-smb
> Jan  4 15:23:35 figo-desktop kernel: [15186]  1000 15186     2069      551   1       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [17451]  1000 17451     5679      500   0       0             0 dconf-service
> Jan  4 15:23:35 figo-desktop kernel: [19085]  1000 19085     1576      147   0       0             0 ssh
> Jan  4 15:23:35 figo-desktop kernel: [19261]  1000 19261     1682      957   0       0             0 wineserver
> Jan  4 15:23:35 figo-desktop kernel: [19266]  1000 19266   399085      102   0       0             0 services.exe
> Jan  4 15:23:35 figo-desktop kernel: [19269]  1000 19269   399117       70   1       0             0 winedevice.exe
> Jan  4 15:23:35 figo-desktop kernel: [19342]  1000 19342   404518      611   0       0             0 explorer.exe
> Jan  4 15:23:35 figo-desktop kernel: [19344]  1000 19344   550020    10567   0       0             0 insight3.exe
> Jan  4 15:23:35 figo-desktop kernel: [  360]  1000   360     2069      508   1       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [ 9821]  1000  9821   166228     2782   0       0             0 stardict
> Jan  4 15:23:35 figo-desktop kernel: [14614]  1000 14614     2040      515   1       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [17002]  1000 17002     2069      435   0       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [18612]     0 18612     1536      124   1       0             0 sudo
> Jan  4 15:23:35 figo-desktop kernel: [18613]     0 18613     1988      607   1       0             0 minicom
> Jan  4 15:23:35 figo-desktop kernel: [21183]  1000 21183     2041      383   1       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [21194]  1000 21194     1611      124   0       0             0 ssh
> Jan  4 15:23:35 figo-desktop kernel: [22451]  1000 22451     2069      575   1       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [23428]  1000 23428     6475      549   1       0             0 vim
> Jan  4 15:23:35 figo-desktop kernel: [23484]  1000 23484     6501      585   1       0             0 vim
> Jan  4 15:23:35 figo-desktop kernel: [23549]  1000 23549     6501      582   0       0             0 vim
> Jan  4 15:23:35 figo-desktop kernel: [23642]  1000 23642     9865      569   0       0             0 gvfsd-smb
> Jan  4 15:23:35 figo-desktop kernel: [26358]  1000 26358   407339     4454   0       0             0 insight3.exe
> Jan  4 15:23:35 figo-desktop kernel: [29711]  1000 29711     9943      549   0       0             0 gvfsd-smb
> Jan  4 15:23:35 figo-desktop kernel: [26156]  1000 26156    61269     9022   0       0             0 skype
> Jan  4 15:23:35 figo-desktop kernel: [32490]  1000 32490     2647      675   1       0             0 gconfd-2
> Jan  4 15:23:35 figo-desktop kernel: [10622]  1000 10622     2072      725   0       0             0 bash
> Jan  4 15:23:35 figo-desktop kernel: [10634]  1000 10634     1576      155   0       0             0 ssh
> Jan  4 15:23:35 figo-desktop kernel: [15410]  1000 15410    76559    12077   0       0             0 evince
> Jan  4 15:23:35 figo-desktop kernel: [15415]  1000 15415     5490      217   1       0             0 evinced
> Jan  4 15:23:35 figo-desktop kernel: [16754]  1000 16754     9899      484   0       0             0 gvfsd-smb
> Jan  4 15:23:35 figo-desktop kernel: [16772]  1000 16772     9900      498   0       0             0 gvfsd-smb
> Jan  4 15:23:35 figo-desktop kernel: [25390]  1000 25390   407306     2127   1       0             0 insight3.exe
> Jan  4 15:23:35 figo-desktop kernel: [ 2127]  1000  2127     1609      124   0       0             0 ssh
> Jan  4 15:23:35 figo-desktop kernel: [10661]    33 10661     4775     1324   1       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [10662]    33 10662     4823     1557   0       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [10663]    33 10663     4823     1558   0       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [10664]    33 10664     4823     1557   0       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [10665]    33 10665     4823     1557   0       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [10666]    33 10666     4823     1557   1       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [32159]  1000 32159   166096    39370   1       0             0 firefox
> Jan  4 15:23:35 figo-desktop kernel: [32228]    33 32228     4823     1500   0       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [32233]    33 32233     4857     1584   1       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [32234]    33 32234     4857     1585   1       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [32241]    33 32241     4789     1524   1       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [32246]    33 32246     4789     1524   0       0             0 httpd
> Jan  4 15:23:35 figo-desktop kernel: [32268]  1000 32268    27543     4243   1       0             0 plugin-containe
> Jan  4 15:23:35 figo-desktop kernel: [32320]  1000 32320    16230     1445   1       0             0 GoogleTalkPlugi
> Jan  4 15:23:35 figo-desktop kernel: [  970]  1000   970   407197     2605   1       0             0 insight3.exe
> Jan  4 15:23:35 figo-desktop kernel: [ 1240]  1000  1240      601      116   1       0             0 top
> Jan  4 15:23:35 figo-desktop kernel: [ 2038]  1000  2038   407785     2770   1       0             0 insight3.exe
> Jan  4 15:23:35 figo-desktop kernel: [12415]     0 12415      543      242   1     -17         -1000 udevd
> Jan  4 15:23:35 figo-desktop kernel: [12416]     0 12416      580      195   1     -17         -1000 udevd
> Jan  4 15:23:35 figo-desktop kernel: [13911]     0 13911      719      269   0       0             0 sh
> Jan  4 15:23:35 figo-desktop kernel: [13914]     0 13914      719      268   0       0             0 sh
> Jan  4 15:23:35 figo-desktop kernel: [13916]     0 13916     1187      188   1       0             0 git
> Jan  4 15:23:35 figo-desktop kernel: [13918]     0 13918      719      313   0       0             0 git-pull
> Jan  4 15:23:35 figo-desktop kernel: [13952]     0 13952     1189      263   1       0             0 git
> Jan  4 15:23:35 figo-desktop kernel: [13954]     0 13954     1575      460   1       0             0 ssh
> Jan  4 15:23:35 figo-desktop kernel: [13956]     0 13956     1488      219   1       0             0 sudo
> Jan  4 15:23:35 figo-desktop kernel: [13957]     0 13957     1386      130   0       0             0 swapoff
> Jan  4 15:23:43 figo-desktop kernel: Xorg invoked oom-killer: gfp_mask=0x80d2, order=0, oom_adj=0, oom_score_adj=0
> Jan  4 15:23:43 figo-desktop kernel: Xorg cpuset=/ mems_allowed=0
> Jan  4 15:23:43 figo-desktop kernel: Pid: 1636, comm: Xorg Not tainted 2.6.36-ARCH #1
> Jan  4 15:23:43 figo-desktop kernel: Call Trace:
> Jan  4 15:23:43 figo-desktop kernel: [<c10c11d0>] dump_header.clone.5+0x80/0x1e0
> Jan  4 15:23:43 figo-desktop kernel: [<c10c153c>] oom_kill_process+0x5c/0x1c0
> Jan  4 15:23:43 figo-desktop kernel: [<c10c171d>] ? select_bad_process.clone.7+0x7d/0xd0
> Jan  4 15:23:43 figo-desktop kernel: [<c10c1a0f>] out_of_memory+0xbf/0x1d0
> Jan  4 15:23:43 figo-desktop kernel: [<c10c18d8>] ? try_set_zonelist_oom+0xc8/0xe0
> Jan  4 15:23:43 figo-desktop kernel: [<c10c5288>] __alloc_pages_nodemask+0x5e8/0x600
> Jan  4 15:23:44 figo-desktop kernel: [<c10e36f6>] __vmalloc_area_node+0x76/0x100
> Jan  4 15:23:44 figo-desktop kernel: [<c102fb30>] ? __wake_up_common+0x40/0x70
> Jan  4 15:23:44 figo-desktop kernel: [<f8991f87>] ? i915_gem_do_execbuffer+0xa87/0x1110 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<c10e381a>] __vmalloc_node+0x9a/0xa0
> Jan  4 15:23:44 figo-desktop kernel: [<f8991f87>] ? i915_gem_do_execbuffer+0xa87/0x1110 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<f8991f87>] ? i915_gem_do_execbuffer+0xa87/0x1110 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<f8991f87>] ? i915_gem_do_execbuffer+0xa87/0x1110 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<c10e3975>] __vmalloc+0x25/0x30
> Jan  4 15:23:44 figo-desktop kernel: [<f8991f87>] ? i915_gem_do_execbuffer+0xa87/0x1110 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<f8991f87>] i915_gem_do_execbuffer+0xa87/0x1110 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<c12e49c8>] ? unix_stream_recvmsg+0x498/0x580
> Jan  4 15:23:44 figo-desktop kernel: [<c11a34d2>] ? _copy_from_user+0x32/0x50
> Jan  4 15:23:44 figo-desktop kernel: [<f8992687>] i915_gem_execbuffer2+0x77/0x1e0 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<f8323231>] drm_ioctl+0x1e1/0x470 [drm]
> Jan  4 15:23:44 figo-desktop kernel: [<f8992610>] ? i915_gem_execbuffer2+0x0/0x1e0 [i915]
> Jan  4 15:23:44 figo-desktop kernel: [<c10fd2dc>] ? do_sync_read+0x9c/0xd0
> Jan  4 15:23:44 figo-desktop kernel: [<c1064e06>] ? __hrtimer_start_range_ns+0x1a6/0x4d0
> Jan  4 15:23:44 figo-desktop kernel: [<f8323050>] ? drm_ioctl+0x0/0x470 [drm]
> Jan  4 15:23:44 figo-desktop kernel: [<c110beca>] do_vfs_ioctl+0x7a/0x590
> Jan  4 15:23:44 figo-desktop kernel: [<c1172121>] ? tomoyo_init_request_info+0x41/0x50
> Jan  4 15:23:44 figo-desktop kernel: [<c116ebb9>] ? tomoyo_path_number_perm+0x29/0xe0
> Jan  4 15:23:44 figo-desktop kernel: [<c10fdb39>] ? vfs_read+0x149/0x160
> Jan  4 15:23:44 figo-desktop kernel: [<c1170eb2>] ? tomoyo_file_ioctl+0x12/0x20
> Jan  4 15:23:44 figo-desktop kernel: [<c110c43f>] sys_ioctl+0x5f/0x80
> Jan  4 15:23:44 figo-desktop kernel: [<c100379f>] sysenter_do_call+0x12/0x28
> Jan  4 15:23:44 figo-desktop kernel: Mem-Info:
> Jan  4 15:23:44 figo-desktop kernel: DMA per-cpu:
> Jan  4 15:23:44 figo-desktop kernel: CPU    0: hi:    0, btch:   1 usd:   0
> Jan  4 15:23:44 figo-desktop kernel: CPU    1: hi:    0, btch:   1 usd:   0
> Jan  4 15:23:44 figo-desktop kernel: Normal per-cpu:
> Jan  4 15:23:44 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:  37
> Jan  4 15:23:44 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:  45
> Jan  4 15:23:44 figo-desktop kernel: HighMem per-cpu:
> Jan  4 15:23:44 figo-desktop kernel: CPU    0: hi:  186, btch:  31 usd:   2
> Jan  4 15:23:44 figo-desktop kernel: CPU    1: hi:  186, btch:  31 usd:  36
> Jan  4 15:23:44 figo-desktop kernel: active_anon:196238 inactive_anon:97262 isolated_anon:0
> Jan  4 15:23:44 figo-desktop kernel: active_file:54385 inactive_file:122363 isolated_file:0
> Jan  4 15:23:44 figo-desktop kernel: unevictable:17 dirty:0 writeback:41 unstable:0
> Jan  4 15:23:44 figo-desktop kernel: free:11933 slab_reclaimable:5456 slab_unreclaimable:6120
> Jan  4 15:23:44 figo-desktop kernel: mapped:47868 shmem:29255 pagetables:2585 bounce:0
> Jan  4 15:23:44 figo-desktop kernel: DMA free:7976kB min:64kB low:80kB high:96kB active_anon:2908kB inactive_anon:3020kB active_file:532kB inactive_file:764kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15788kB mlocked:0kB dirty:0kB writeback:0kB mapped:528kB shmem:52kB slab_reclaimable:480kB slab_unreclaimable:112kB kernel_stack:8kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:2053 all_unreclaimable? yes
> Jan  4 15:23:44 figo-desktop kernel: lowmem_reserve[]: 0 865 1980 1980
> Jan  4 15:23:44 figo-desktop kernel: Normal free:39352kB min:3728kB low:4660kB high:5592kB active_anon:230308kB inactive_anon:219780kB active_file:86232kB inactive_file:207668kB unevictable:68kB isolated(anon):0kB isolated(file):0kB present:885944kB mlocked:68kB dirty:0kB writeback:0kB mapped:55204kB shmem:36960kB slab_reclaimable:21344kB slab_unreclaimable:24368kB kernel_stack:3272kB pagetables:10340kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:448565 all_unreclaimable? yes
> Jan  4 15:23:44 figo-desktop kernel: lowmem_reserve[]: 0 0 8921 8921
> Jan  4 15:23:44 figo-desktop kernel: HighMem free:404kB min:512kB low:1712kB high:2912kB active_anon:551736kB inactive_anon:166248kB active_file:130776kB inactive_file:281020kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:1141984kB mlocked:0kB dirty:0kB writeback:164kB mapped:135740kB shmem:80008kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:687864 all_unreclaimable? yes
> Jan  4 15:23:44 figo-desktop kernel: lowmem_reserve[]: 0 0 0 0
> Jan  4 15:23:44 figo-desktop kernel: DMA: 1546*4kB 224*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 7976kB
> Jan  4 15:23:44 figo-desktop kernel: Normal: 1678*4kB 3750*8kB 49*16kB 6*32kB 2*64kB 2*128kB 3*256kB 1*512kB 0*1024kB 0*2048kB 0*4096kB = 39352kB
> Jan  4 15:23:44 figo-desktop kernel: HighMem: 20*4kB 7*8kB 18*16kB 1*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 456kB
> Jan  4 15:23:44 figo-desktop kernel: 209015 total pagecache pages
> Jan  4 15:23:44 figo-desktop kernel: 2993 pages in swap cache
> Jan  4 15:23:44 figo-desktop kernel: Swap cache stats: add 1046799, delete 1043806, find 277476/391899
> Jan  4 15:23:44 figo-desktop kernel: Free swap  = -14768kB
> Jan  4 15:23:44 figo-desktop kernel: Total swap = 0kB
> Jan  4 15:23:44 figo-desktop kernel: 515070 pages RAM
> Jan  4 15:23:44 figo-desktop kernel: 287745 pages HighMem
> Jan  4 15:23:44 figo-desktop kernel: 8297 pages reserved
> Jan  4 15:23:44 figo-desktop kernel: 302258 pages shared
> Jan  4 15:23:44 figo-desktop kernel: 308041 pages non-shared
> Jan  4 15:23:44 figo-desktop kernel: [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> Jan  4 15:23:44 figo-desktop kernel: [  583]     0   583      581      246   1     -17         -1000 udevd
> Jan  4 15:23:44 figo-desktop kernel: [ 1303]     0  1303      868       37   0       0             0 syslog-ng
> Jan  4 15:23:44 figo-desktop kernel: [ 1304]     0  1304     1604      383   1       0             0 syslog-ng
> Jan  4 15:23:44 figo-desktop kernel: [ 1306]    81  1306      808      362   0       0             0 dbus-daemon
> Jan  4 15:23:44 figo-desktop kernel: [ 1309]    82  1309     3777      376   1       0             0 hald
> Jan  4 15:23:44 figo-desktop kernel: [ 1310]     0  1310      903      130   1       0             0 hald-runner
> Jan  4 15:23:44 figo-desktop kernel: [ 1339]     0  1339      919       87   1       0             0 hald-addon-inpu
> Jan  4 15:23:44 figo-desktop kernel: [ 1357]     0  1357      919      184   0       0             0 hald-addon-stor
> Jan  4 15:23:44 figo-desktop kernel: [ 1359]    82  1359      824      107   1       0             0 hald-addon-acpi
> Jan  4 15:23:44 figo-desktop kernel: [ 1448]     0  1448      616      294   0       0             0 crond
> Jan  4 15:23:44 figo-desktop kernel: [ 1477]     0  1477      720      108   0       0             0 mysqld_safe
> Jan  4 15:23:44 figo-desktop kernel: [ 1484]     0  1484     3580      269   0       0             0 gdm-binary
> Jan  4 15:23:44 figo-desktop kernel: [ 1497]     0  1497      440       67   1       0             0 agetty
> Jan  4 15:23:44 figo-desktop kernel: [ 1498]     0  1498      440       67   0       0             0 agetty
> Jan  4 15:23:44 figo-desktop kernel: [ 1499]     0  1499      440       67   0       0             0 agetty
> Jan  4 15:23:44 figo-desktop kernel: [ 1500]     0  1500      440       67   1       0             0 agetty
> Jan  4 15:23:44 figo-desktop kernel: [ 1501]     0  1501      440       67   0       0             0 agetty
> Jan  4 15:23:44 figo-desktop kernel: [ 1502]     0  1502      440       68   0       0             0 agetty
> Jan  4 15:23:44 figo-desktop kernel: [ 1553]     0  1553     6607      652   0       0             0 NetworkManager
> Jan  4 15:23:44 figo-desktop kernel: [ 1592]     0  1592     2256      330   0       0             0 cupsd
> Jan  4 15:23:44 figo-desktop kernel: [ 1597]    89  1597    29903     2812   1       0             0 mysqld
> Jan  4 15:23:44 figo-desktop kernel: [ 1598]     0  1598     1652      147   1     -17         -1000 sshd
> Jan  4 15:23:44 figo-desktop kernel: [ 1612]     0  1612     6263      508   1       0             0 polkitd
> Jan  4 15:23:44 figo-desktop kernel: [ 1613]     0  1613     2015      123   1       0             0 vmware-usbarbit
> Jan  4 15:23:44 figo-desktop kernel: [ 1617]     0  1617     2887     1600   1       0             0 cntlm
> Jan  4 15:23:44 figo-desktop kernel: [ 1620]     0  1620     4398      366   0       0             0 gdm-simple-slav
> Jan  4 15:23:44 figo-desktop kernel: [ 1636]     0  1636    37333     9882   1       0             0 Xorg
> Jan  4 15:23:44 figo-desktop kernel: [ 1638]     0  1638     1248       88   0       0             0 wpa_supplicant
> Jan  4 15:23:44 figo-desktop kernel: [ 1720]     0  1720     4789     1537   1       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [ 1722]     0  1722      488       93   0       0             0 dhcpcd
> Jan  4 15:23:44 figo-desktop kernel: [ 1732]     0  1732      519       62   1       0             0 vmnet-bridge
> Jan  4 15:23:44 figo-desktop kernel: [ 1750]     0  1750     4922      304   1       0             0 smbd
> Jan  4 15:23:44 figo-desktop kernel: [ 1764]     0  1764      655       39   1       0             0 vmnet-dhcpd
> Jan  4 15:23:44 figo-desktop kernel: [ 1772]     0  1772      513       15   0       0             0 vmnet-netifup
> Jan  4 15:23:44 figo-desktop kernel: [ 1774]     0  1774      655       39   0       0             0 vmnet-dhcpd
> Jan  4 15:23:44 figo-desktop kernel: [ 1776]     0  1776     4922      225   0       0             0 smbd
> Jan  4 15:23:44 figo-desktop kernel: [ 1778]     0  1778      634       44   0       0             0 vmnet-natd
> Jan  4 15:23:44 figo-desktop kernel: [ 1780]     0  1780      513       14   1       0             0 vmnet-netifup
> Jan  4 15:23:44 figo-desktop kernel: [ 1796]     0  1796     6677      329   0       0             0 console-kit-dae
> Jan  4 15:23:44 figo-desktop kernel: [ 1899]   120  1899     6587      598   0       0             0 polkit-gnome-au
> Jan  4 15:23:44 figo-desktop kernel: [ 1903]     0  1903     3905      245   0       0             0 gdm-session-wor
> Jan  4 15:23:44 figo-desktop kernel: [ 1906]     0  1906     3677      314   1       0             0 upowerd
> Jan  4 15:23:44 figo-desktop kernel: [ 1974]  1000  1974    10963     1248   0       0             0 gnome-keyring-d
> Jan  4 15:23:44 figo-desktop kernel: [ 1993]  1000  1993     9253      776   0       0             0 gnome-session
> Jan  4 15:23:44 figo-desktop kernel: [ 2012]  1000  2012      796      103   0       0             0 dbus-launch
> Jan  4 15:23:44 figo-desktop kernel: [ 2013]  1000  2013     5854     4969   0       0             0 dbus-daemon
> Jan  4 15:23:44 figo-desktop kernel: [ 2015]  1000  2015      887       54   1       0             0 ssh-agent
> Jan  4 15:23:44 figo-desktop kernel: [ 2022]  1000  2022    10904     4786   1       0             0 fcitx
> Jan  4 15:23:44 figo-desktop kernel: [ 2032]  1000  2032    41764     1981   1       0             0 gnome-settings-
> Jan  4 15:23:44 figo-desktop kernel: [ 2036]  1000  2036     2367      416   0       0             0 gvfsd
> Jan  4 15:23:44 figo-desktop kernel: [ 2039]  1000  2039    85188    26593   0       0             0 metacity
> Jan  4 15:23:44 figo-desktop kernel: [ 2049]  1000  2049    14162      280   1       0             0 gvfs-fuse-daemo
> Jan  4 15:23:44 figo-desktop kernel: [ 2053]  1000  2053    76657     3497   0       0             0 gnome-panel
> Jan  4 15:23:44 figo-desktop kernel: [ 2056]  1000  2056    10978      563   0       0             0 gvfs-gdu-volume
> Jan  4 15:23:44 figo-desktop kernel: [ 2058]     0  2058     5767      465   1       0             0 udisks-daemon
> Jan  4 15:23:44 figo-desktop kernel: [ 2059]     0  2059     1291       72   1       0             0 udisks-daemon
> Jan  4 15:23:44 figo-desktop kernel: [ 2069]  1000  2069   168292    50767   0       0             0 nautilus
> Jan  4 15:23:44 figo-desktop kernel: [ 2071]  1000  2071    12907      223   0       0             0 bonobo-activati
> Jan  4 15:23:44 figo-desktop kernel: [ 2081]  1000  2081     1633      136   0       0             0 sh
> Jan  4 15:23:44 figo-desktop kernel: [ 2082]  1000  2082     1666      136   1       0             0 thunderbird
> Jan  4 15:23:44 figo-desktop kernel: [ 2084]  1000  2084    46718     3364   0       0             0 wnck-applet
> Jan  4 15:23:44 figo-desktop kernel: [ 2086]  1000  2086    42862     1443   0       0             0 polkit-gnome-au
> Jan  4 15:23:44 figo-desktop kernel: [ 2087]  1000  2087   285933     1529   0       0             0 nm-applet
> Jan  4 15:23:44 figo-desktop kernel: [ 2104]  1000  2104     5056      756   1       0             0 gdu-notificatio
> Jan  4 15:23:44 figo-desktop kernel: [ 2107]  1000  2107     1666      142   1       0             0 run-mozilla.sh
> Jan  4 15:23:44 figo-desktop kernel: [ 2108]  1000  2108    39395      941   0       0             0 gnome-power-man
> Jan  4 15:23:44 figo-desktop kernel: [ 2109]  1000  2109     7886      709   0       0             0 vino-server
> Jan  4 15:23:44 figo-desktop kernel: [ 2110]  1000  2110    10764      791   1       0             0 evolution-alarm
> Jan  4 15:23:44 figo-desktop kernel: [ 2114]  1000  2114   167865    29566   1       0             0 thunderbird-bin
> Jan  4 15:23:44 figo-desktop kernel: [ 2121]  1000  2121    42098     1946   0       0             0 notify-osd
> Jan  4 15:23:44 figo-desktop kernel: [ 2125]  1000  2125    42488     1203   1       0             0 cpufreq-applet
> Jan  4 15:23:44 figo-desktop kernel: [ 2126]  1000  2126    41394     1148   1       0             0 multiload-apple
> Jan  4 15:23:44 figo-desktop kernel: [ 2129]  1000  2129    64405     1758   0       0             0 mixer_applet2
> Jan  4 15:23:44 figo-desktop kernel: [ 2131]  1000  2131    75346     2389   1       0             0 clock-applet
> Jan  4 15:23:44 figo-desktop kernel: [ 2132]  1000  2132    41163      930   1       0             0 notification-ar
> Jan  4 15:23:44 figo-desktop kernel: [ 2149]  1000  2149    15325      697   1       0             0 e-calendar-fact
> Jan  4 15:23:44 figo-desktop kernel: [ 2153]  1000  2153     7497     1008   1       0             0 gnome-screensav
> Jan  4 15:23:44 figo-desktop kernel: [ 2155]  1000  2155     3848      202   1       0             0 pxgconf
> Jan  4 15:23:44 figo-desktop kernel: [ 2163]  1000  2163     1781      342   0       0             0 mission-control
> Jan  4 15:23:44 figo-desktop kernel: [ 2173]  1000  2173     4486      427   0       0             0 gvfsd-trash
> Jan  4 15:23:44 figo-desktop kernel: [ 2186]     0  2186     3543      192   1       0             0 system-tools-ba
> Jan  4 15:23:44 figo-desktop kernel: [ 2210]  1000  2210     2202      238   0       0             0 gvfsd-burn
> Jan  4 15:23:44 figo-desktop kernel: [ 2245]  1000  2245     3895     1728   0       0             0 gvfsd-metadata
> Jan  4 15:23:44 figo-desktop kernel: [ 2274]  1000  2274    22823      424   1       0             0 conky
> Jan  4 15:23:44 figo-desktop kernel: [ 2281]     0  2281     3295     2278   0       0             0 SystemToolsBack
> Jan  4 15:23:44 figo-desktop kernel: [ 2663]  1000  2663    68807     2944   1       0             0 gnome-terminal
> Jan  4 15:23:44 figo-desktop kernel: [ 2683]  1000  2683      451       76   0       0             0 gnome-pty-helpe
> Jan  4 15:23:44 figo-desktop kernel: [ 2685]  1000  2685     2072      570   0       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [ 2885]     0  2885     1489      119   0       0             0 sudo
> Jan  4 15:23:44 figo-desktop kernel: [ 2886]     0  2886     6273      355   1       0             0 vim
> Jan  4 15:23:44 figo-desktop kernel: [ 2887]  1000  2887      472       84   0       0             0 ping
> Jan  4 15:23:44 figo-desktop kernel: [ 2892]  1000  2892      472       83   1       0             0 ping
> Jan  4 15:23:44 figo-desktop kernel: [ 2894]  1000  2894    76113     5872   0       0             0 vmware
> Jan  4 15:23:44 figo-desktop kernel: [ 2919]  1000  2919    51497     3266   1       0             0 vmware-tray
> Jan  4 15:23:44 figo-desktop kernel: [ 2954]  1000  2954    48676     1589   0       0             0 vmware-unity-he
> Jan  4 15:23:44 figo-desktop kernel: [ 2988]  1000  2988   190471    42604   1       0             0 vmware-vmx
> Jan  4 15:23:44 figo-desktop kernel: [ 3207]  1000  3207     4377      362   1       0             0 gvfsd-computer
> Jan  4 15:23:44 figo-desktop kernel: [ 3211]  1000  3211     9920      509   0       0             0 gvfsd-smb-brows
> Jan  4 15:23:44 figo-desktop kernel: [ 3217]  1000  3217     9876      569   0       0             0 gvfsd-smb
> Jan  4 15:23:44 figo-desktop kernel: [15186]  1000 15186     2069      558   1       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [17451]  1000 17451     5679      503   0       0             0 dconf-service
> Jan  4 15:23:44 figo-desktop kernel: [19085]  1000 19085     1576      149   0       0             0 ssh
> Jan  4 15:23:44 figo-desktop kernel: [19261]  1000 19261     1682      967   1       0             0 wineserver
> Jan  4 15:23:44 figo-desktop kernel: [19266]  1000 19266   399085      212   0       0             0 services.exe
> Jan  4 15:23:44 figo-desktop kernel: [19269]  1000 19269   399117      158   1       0             0 winedevice.exe
> Jan  4 15:23:44 figo-desktop kernel: [19342]  1000 19342   404518      620   0       0             0 explorer.exe
> Jan  4 15:23:44 figo-desktop kernel: [19344]  1000 19344   550020    10921   0       0             0 insight3.exe
> Jan  4 15:23:44 figo-desktop kernel: [  360]  1000   360     2069      541   1       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [ 9821]  1000  9821   166228     2835   0       0             0 stardict
> Jan  4 15:23:44 figo-desktop kernel: [14614]  1000 14614     2040      523   1       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [17002]  1000 17002     2069      541   0       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [18612]     0 18612     1536      125   1       0             0 sudo
> Jan  4 15:23:44 figo-desktop kernel: [18613]     0 18613     1988      607   0       0             0 minicom
> Jan  4 15:23:44 figo-desktop kernel: [21183]  1000 21183     2041      517   1       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [21194]  1000 21194     1611      125   0       0             0 ssh
> Jan  4 15:23:44 figo-desktop kernel: [22451]  1000 22451     2069      578   1       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [23428]  1000 23428     6475      554   1       0             0 vim
> Jan  4 15:23:44 figo-desktop kernel: [23484]  1000 23484     6501      594   1       0             0 vim
> Jan  4 15:23:44 figo-desktop kernel: [23549]  1000 23549     6501      594   0       0             0 vim
> Jan  4 15:23:44 figo-desktop kernel: [23642]  1000 23642     9865      594   0       0             0 gvfsd-smb
> Jan  4 15:23:44 figo-desktop kernel: [26358]  1000 26358   407339     4819   1       0             0 insight3.exe
> Jan  4 15:23:44 figo-desktop kernel: [29711]  1000 29711     9943      617   0       0             0 gvfsd-smb
> Jan  4 15:23:44 figo-desktop kernel: [26156]  1000 26156    61269     9261   0       0             0 skype
> Jan  4 15:23:44 figo-desktop kernel: [32490]  1000 32490     2647      678   1       0             0 gconfd-2
> Jan  4 15:23:44 figo-desktop kernel: [10622]  1000 10622     2072      741   1       0             0 bash
> Jan  4 15:23:44 figo-desktop kernel: [10634]  1000 10634     1576      156   0       0             0 ssh
> Jan  4 15:23:44 figo-desktop kernel: [15410]  1000 15410    76559    12077   0       0             0 evince
> Jan  4 15:23:44 figo-desktop kernel: [15415]  1000 15415     5490      217   1       0             0 evinced
> Jan  4 15:23:44 figo-desktop kernel: [16754]  1000 16754     9899      485   0       0             0 gvfsd-smb
> Jan  4 15:23:44 figo-desktop kernel: [16772]  1000 16772     9900      500   0       0             0 gvfsd-smb
> Jan  4 15:23:44 figo-desktop kernel: [25390]  1000 25390   407306     2127   1       0             0 insight3.exe
> Jan  4 15:23:44 figo-desktop kernel: [ 2127]  1000  2127     1609      125   0       0             0 ssh
> Jan  4 15:23:44 figo-desktop kernel: [10661]    33 10661     4775     1510   1       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [10662]    33 10662     4823     1567   0       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [10663]    33 10663     4823     1568   0       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [10664]    33 10664     4823     1567   0       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [10665]    33 10665     4823     1567   0       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [10666]    33 10666     4823     1567   1       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [32159]  1000 32159   166096    39444   1       0             0 firefox
> Jan  4 15:23:44 figo-desktop kernel: [32228]    33 32228     4823     1510   0       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [32233]    33 32233     4857     1594   1       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [32234]    33 32234     4857     1595   1       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [32241]    33 32241     4789     1534   1       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [32246]    33 32246     4789     1534   0       0             0 httpd
> Jan  4 15:23:44 figo-desktop kernel: [32268]  1000 32268    27543     4273   1       0             0 plugin-containe
> Jan  4 15:23:44 figo-desktop kernel: [32320]  1000 32320    16230     1445   1       0             0 GoogleTalkPlugi
> Jan  4 15:23:44 figo-desktop kernel: [  970]  1000   970   407197     2621   0       0             0 insight3.exe
> Jan  4 15:23:44 figo-desktop kernel: [ 1240]  1000  1240      601      116   1       0             0 top
> Jan  4 15:23:44 figo-desktop kernel: [ 2038]  1000  2038   407785     2796   1       0             0 insight3.exe
> Jan  4 15:23:44 figo-desktop kernel: [12415]     0 12415      543      242   1     -17         -1000 udevd
> Jan  4 15:23:44 figo-desktop kernel: [12416]     0 12416      580      195   1     -17         -1000 udevd
> Jan  4 15:23:44 figo-desktop kernel: [13911]     0 13911      719      269   0       0             0 sh
> Jan  4 15:23:44 figo-desktop kernel: [13914]     0 13914      719      268   0       0             0 sh
> Jan  4 15:23:44 figo-desktop kernel: [13916]     0 13916     1187      188   1       0             0 git
> Jan  4 15:23:44 figo-desktop kernel: [13918]     0 13918      719      313   0       0             0 git-pull
> Jan  4 15:23:44 figo-desktop kernel: [13952]     0 13952     1189      263   1       0             0 git
> Jan  4 15:23:44 figo-desktop kernel: [13954]     0 13954     1575      460   1       0             0 ssh
> Jan  4 15:23:44 figo-desktop kernel: [13960]     0 13960     1488      224   1       0             0 sudo
> Jan  4 15:23:44 figo-desktop kernel: [13962]     0 13962     1386      130   0       0             0 swapoff






On 11/10/2010 11:24 PM, Figo.zhang wrote:
> the victim should not directly access hardware devices like Xorg server,
> because the hardware could be left in an unpredictable state, although
> user-application can set /proc/pid/oom_score_adj to protect it. so i think
> those processes should get bonus for protection.
>
> in v2, fix the incorrect comment.
> in v3, change the divided the badness score by 4, like old heuristic for protection. we just
> want the oom_killer don't select Root/RESOURCE/RAWIO process as possible.
>
> suppose that if a user process A such as email cleint "evolution" and a process B with
> ditecly hareware access such as "Xorg", they have eat the equal memory (the badness score is
> the same),so which process are you want to kill? so in new heuristic, it will kill the process B.
> but in reality, we want to kill process A.
>
> Signed-off-by: Figo.zhang<figo1802@gmail.com>
> Reviewed-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> ---
> mm/oom_kill.c |    9 +++++++++
>   1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4029583..f43d759 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -202,6 +202,15 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>   		points -= 30;
>
>   	/*
> +	 * Root and direct hareware access processes are usually more
> +	 * important, so they should get bonus for protection.
> +	 */
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> +	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
> +	    has_capability_noaudit(p, CAP_SYS_RAWIO))
> +		points /= 4;
> +
> +	/*
>   	 * /proc/pid/oom_score_adj ranges from -1000 to +1000 such that it may
>   	 * either completely disable oom killing or always prefer a certain
>   	 * task.
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
