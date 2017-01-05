Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 712E56B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 14:44:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id f188so1683689753pgc.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 11:44:55 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j15si76963829pli.53.2017.01.05.11.44.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 11:44:53 -0800 (PST)
Date: Thu, 5 Jan 2017 11:46:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 190351] New: OOM but no swap used
Message-Id: <20170105114611.8b0fa5d3ec779e8a71b3973c@linux-foundation.org>
In-Reply-To: <bug-190351-27@https.bugzilla.kernel.org/>
References: <bug-190351-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, rtc@helen.plasma.xg8.de


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).


On Wed, 14 Dec 2016 12:54:35 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=190351
> 
>             Bug ID: 190351
>            Summary: OOM but no swap used
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.9.0
>           Hardware: All
>                 OS: Linux
>               Tree: Fedora
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: rtc@helen.plasma.xg8.de
>         Regression: No

(Yes, it's a regression)

This oom-killing seems premature?  There's plenty of pagecache still
sitting around.

> Since upgrading from kernel-PAE 4.5.3 on fedora 24 to kernel-PAE 4.8.10 on
> fedora 25, I get OOM when I run my daily rsync for backup. I upgraded to
> kernel-PAE-4.9.0-1.fc26.i686 and the problem still occurs. The OOM occurs
> although the system doesn't use any swap and memory is not used up either.
> 
> See https://bugzilla.redhat.com/show_bug.cgi?id=1401012
> 
> Here is the dmesg from today:
> 
> [32863.748720] gpg-agent invoked oom-killer:
> gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), nodemask=0, order=1,
> oom_score_adj=0
> [32863.748723] gpg-agent cpuset=/ mems_allowed=0
> [32863.748729] CPU: 1 PID: 1099 Comm: gpg-agent Not tainted
> 4.9.0-1.fc26.i686+PAE #1
> [32863.748730] Hardware name: .   .  /IP35V(Intel P35+ICH7), BIOS 6.00 PG
> 03/31/2008
> [32863.748731]  ef6afd58 c4b61460 ef6afe80 f29710c0 ef6afd88 c49dd360 00200206
> ef6afd88
> [32863.748735]  c4b670ef c52a03a0 ef6afd8c f0643700 c4f7b3b4 f29710c0 c516c375
> ef6afe80
> [32863.748738]  ef6afdcc c4976b0d c4876a4a ef6afdb8 c4976799 00000003 00000000
> 00000566
> [32863.748742] Call Trace:
> [32863.748751]  [<c4b61460>] dump_stack+0x58/0x78
> [32863.748754]  [<c49dd360>] dump_header+0x64/0x1a6
> [32863.748756]  [<c4b670ef>] ? ___ratelimit+0x9f/0x100
> [32863.748760]  [<c4976b0d>] oom_kill_process+0x1fd/0x3c0
> [32863.748762]  [<c4876a4a>] ? has_capability_noaudit+0x1a/0x30
> [32863.748764]  [<c4976799>] ? oom_badness.part.13+0xc9/0x140
> [32863.748765]  [<c4976fd5>] out_of_memory+0xf5/0x2b0
> [32863.748767]  [<c497bc0b>] __alloc_pages_nodemask+0xc9b/0xcb0
> [32863.748770]  [<c4869f98>] copy_process.part.44+0x108/0x14e0
> [32863.748771]  [<c49dd27d>] ? __check_object_size+0x9d/0x11c
> [32863.748774]  [<c48e4aad>] ? ktime_get_ts64+0x4d/0x190
> [32863.748776]  [<c4878d67>] ? recalc_sigpending+0x17/0x50
> [32863.748777]  [<c486b534>] _do_fork+0xd4/0x370
> [32863.748778]  [<c486b8bc>] SyS_clone+0x2c/0x30
> [32863.748780]  [<c480369c>] do_int80_syscall_32+0x5c/0xc0
> [32863.748783]  [<c4f670e9>] entry_INT80_32+0x31/0x31
> [32863.748785] Mem-Info:
> [32863.748789] active_anon:122505 inactive_anon:129240 isolated_anon:0
>                 active_file:174922 inactive_file:371696 isolated_file:64
>                 unevictable:8 dirty:0 writeback:0 unstable:0
>                 slab_reclaimable:186174 slab_unreclaimable:17717
>                 mapped:69769 shmem:11168 pagetables:2174 bounce:0
>                 free:13565 free_pcp:660 free_cma:0
> [32863.748792] Node 0 active_anon:490020kB inactive_anon:516960kB
> active_file:699688kB inactive_file:1486784kB unevictable:32kB
> isolated(anon):0kB isolated(file):256kB mapped:279076kB dirty:0kB writeback:0kB
> shmem:44672kB writeback_tmp:0kB unstable:0kB pages_scanned:9963129
> all_unreclaimable? yes
> [32863.748795] DMA free:3260kB min:68kB low:84kB high:100kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:15992kB managed:15916kB mlocked:0kB
> slab_reclaimable:12460kB slab_unreclaimable:132kB kernel_stack:64kB
> pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [32863.748796] lowmem_reserve[]: 0 798 4005 4005
> [32863.748801] Normal free:3880kB min:3580kB low:4472kB high:5364kB
> active_anon:0kB inactive_anon:0kB active_file:1220kB inactive_file:68kB
> unevictable:0kB writepending:0kB present:892920kB managed:830896kB mlocked:0kB
> slab_reclaimable:732236kB slab_unreclaimable:70736kB kernel_stack:2560kB
> pagetables:0kB bounce:0kB free_pcp:1252kB local_pcp:624kB free_cma:0kB
> [32863.748801] lowmem_reserve[]: 0 0 25655 25655
> [32863.748805] HighMem free:47120kB min:512kB low:4104kB high:7696kB
> active_anon:490020kB inactive_anon:516960kB active_file:698400kB
> inactive_file:1486684kB unevictable:32kB writepending:0kB present:3283848kB
> managed:3283848kB mlocked:32kB slab_reclaimable:0kB slab_unreclaimable:0kB
> kernel_stack:0kB pagetables:8696kB bounce:0kB free_pcp:1388kB local_pcp:628kB
> free_cma:0kB
> [32863.748806] lowmem_reserve[]: 0 0 0 0
> [32863.748808] DMA: 5*4kB (E) 13*8kB (UE) 20*16kB (UE) 30*32kB (UE) 11*64kB
> (UME) 9*128kB (UE) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3260kB
> [32863.748816] Normal: 566*4kB (UMEH) 17*8kB (UM) 26*16kB (H) 17*32kB (H)
> 7*64kB (H) 1*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3936kB
> [32863.748824] HighMem: 90*4kB (UM) 331*8kB (M) 1021*16kB (UM) 354*32kB (UM)
> 59*64kB (UM) 21*128kB (U) 7*256kB (U) 4*512kB (U) 2*1024kB (UM) 2*2048kB (UM)
> 0*4096kB = 47120kB
> [32863.748834] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> [32863.748835] 557821 total pagecache pages
> [32863.748837] 0 pages in swap cache
> [32863.748839] Swap cache stats: add 0, delete 0, find 0/0
> [32863.748839] Free swap  = 4192960kB
> [32863.748840] Total swap = 4192960kB
> [32863.748840] 1048190 pages RAM
> [32863.748841] 820962 pages HighMem/MovableOnly
> [32863.748841] 15525 pages reserved
> [32863.748842] 0 pages hwpoisoned
> [32863.748842] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents
> oom_score_adj name
> [32863.748852] [  295]     0   295    16105     8055      24       3        0  
>           0 systemd-journal
> [32863.748854] [  332]     0   332     4155     1719       9       3        0  
>       -1000 systemd-udevd
> [32863.748857] [  471]     0   471     3486      741       7       3        0  
>       -1000 auditd
> [32863.748859] [  483]     0   483     2979      444       6       3        0  
>           0 audispd
> [32863.748860] [  487]     0   487     1509      486       7       3        0  
>           0 sedispatch
> [32863.748862] [  496]     0   496      999      301       6       3        0  
>           0 alsactl
> [32863.748864] [  499]     0   499      702       18       5       3        0  
>           0 gpm
> [32863.748867] [  510]     0   510     1140      320       6       3        0  
>           0 irqbalance
> [32863.748868] [  511]     0   511     2459     1887       9       3        0  
>           0 systemd-logind
> [32863.748870] [  514]    81   514     3814     1175       7       3        0  
>        -900 dbus-daemon
> [32863.748872] [  529]    38   529     1804     1225       6       3        0  
>           0 ntpd
> [32863.748874] [  554]     0   554    18820     3075      21       3        0  
>           0 NetworkManager
> [32863.748875] [  555]     0   555      701      460       5       3        0  
>           0 mcelog
> [32863.748877] [  598]     0   598     2989     1878       9       3        0  
>           0 wpa_supplicant
> [32863.748879] [  599]   485   599    19005     3423      21       3        0  
>           0 polkitd
> [32863.748881] [  817]     0   817     4070     2227      11       3        0  
>           0 cupsd
> [32863.748883] [  822]     0   822     1692      745       7       3        0  
>           0 crond
> [32863.748884] [  823]     0   823      884      541       5       3        0  
>           0 atd
> [32863.748886] [  833]     0   833    11251     1577      13       3        0  
>           0 lightdm
> [32863.748888] [  844]     0   844    72357    23827      86       3        0  
>           0 Xorg
> [32863.748889] [  848]     0   848     9997     1639      14       3        0  
>           0 accounts-daemon
> [32863.748891] [  870]   488   870    10763     2384      16       3        0  
>           0 colord
> [32863.748892] [  924]     0   924     7440     1855      12       3        0  
>           0 lightdm
> [32863.748894] [  949]  1001   949     2419     1676       8       3        0  
>           0 systemd
> [32863.748895] [  951]  1001   951     3294      523      10       3        0  
>           0 (sd-pam)
> [32863.748897] [  955]  1001   955     1498      679       6       3        0  
>           0 sh
> [32863.748899] [  966]  1001   966     4026     1165       8       3        0  
>           0 dbus-daemon
> [32863.748900] [  972]  1001   972     2022      102       8       3        0  
>           0 ssh-agent
> [32863.748902] [ 1092]  1001  1092    11566     3434      20       3        0  
>           0 xfce4-session
> [32863.748903] [ 1096]  1001  1096     2532     1240       9       3        0  
>           0 xfconfd
> [32863.748905] [ 1099]  1001  1099     6146      151       9       3        0  
>           0 gpg-agent
> [32863.748906] [ 1101]  1001  1101     8646     4725      20       3        0  
>           0 xfwm4
> [32863.748908] [ 1105]  1001  1105    14667     7087      27       3        0  
>           0 xfce4-panel
> [32863.748909] [ 1107]  1001  1107    11812     3753      20       3        0  
>           0 Thunar
> [32863.748911] [ 1109]  1001  1109    53207    10792      40       3        0  
>           0 xfdesktop
> [32863.748912] [ 1110]  1001  1110    12407     4006      21       3        0  
>           0 xfsettingsd
> [32863.748913] [ 1111]  1001  1111    16412     4286      24       3        0  
>           0 seapplet
> [32863.748915] [ 1117]  1001  1117    16785     8884      29       3        0  
>           0 redshift-gtk
> [32863.748916] [ 1118]  1001  1118    25569     6702      35       3        0  
>           0 nm-applet
> [32863.748918] [ 1119]  1001  1119    11228     1432      14       3        0  
>           0 at-spi-bus-laun
> [32863.748919] [ 1124]  1001  1124     3931     1055       7       3        0  
>           0 dbus-daemon
> [32863.748921] [ 1129]  1001  1129     7552     1659      11       3        0  
>           0 at-spi2-registr
> [32863.748922] [ 1134]  1001  1134    14194     6137      25       3        0  
>           0 xfce4-power-man
> [32863.748924] [ 1137]  1001  1137    10022     1525      15       3        0  
>           0 gvfsd
> [32863.748925] [ 1142]  1001  1142    13074     1341      15       3        0  
>           0 gvfsd-fuse
> [32863.748926] [ 1151]  1001  1151    11253     3222      21       3        0  
>           0 xfce-polkit
> [32863.748928] [ 1157]  1001  1157     2059     1179       7       3        0  
>           0 xscreensaver
> [32863.748929] [ 1201]     0  1201    13160     2066      18       3        0  
>           0 upowerd
> [32863.748931] [ 1246]  1001  1246    11844     4207      22       3        0  
>           0 panel-8-actions
> [32863.748933] [ 1247]  1001  1247    11848     4173      22       3        0  
>           0 panel-17-action
> [32863.748934] [ 1248]  1001  1248    11720     4217      20       3        0  
>           0 panel-12-thunar
> [32863.748935] [ 1249]  1001  1249     6938     3556      17       3        0  
>           0 panel-15-systra
> [32863.748937] [ 1250]  1001  1250   120950     5815      33       3        0  
>           0 panel-18-mixer
> [32863.748938] [ 1260]  1001  1260    12154     1656      14       3        0  
>           0 gvfsd-trash
> [32863.748940] [ 1277]  1001  1277    11106     2160      16       3        0  
>           0 gvfs-udisks2-vo
> [32863.748941] [ 1284]  1001  1284   107776     5964      52       3        0  
>           0 pulseaudio
> [32863.748943] [ 1285]  1001  1285     2359     1045       8       3        0  
>           0 redshift
> [32863.748944] [ 1290]     0  1290    14261     2176      15       3        0  
>           0 udisksd
> [32863.748946] [ 1297]  1001  1297    13023     1842      15       3        0  
>           0 gvfs-afc-volume
> [32863.748947] [ 1306]  1001  1306     7242     1227      12       3        0  
>           0 gvfsd-metadata
> [32863.748949] [ 1329]  1001  1329    23629     9760      38       3        0  
>           0 xfce4-terminal
> [32863.748950] [ 1334]  1001  1334     1956     1123       8       3        0  
>           0 zsh
> [32863.748952] [ 1351]  1001  1351     1486      653       6       3        0  
>           0 screen
> [32863.748953] [ 1352]  1001  1352     1585      736       6       3        0  
>           0 screen
> [32863.748955] [ 1353]  1001  1353     4176     2075      11       3        0  
>           0 micq
> [32863.748956] [ 1355]  1001  1355     1957     1152       7       3        0  
>           0 zsh
> [32863.748957] [ 1379]  1001  1379     1956     1139       8       3        0  
>           0 zsh
> [32863.748959] [ 1403]  1001  1403     1956     1122       7       3        0  
>           0 zsh
> [32863.748960] [ 1422]  1001  1422    16168     6248      28       3        0  
>           0 orage
> [32863.748962] [ 1423]  1001  1423    12524     5248      23       3        0  
>           0 globaltime
> [32863.748963] [ 1426]  1001  1426    74112    20511      94       3        0  
>           0 liferea
> [32863.748965] [ 1437]  1001  1437     6533     1262      10       3        0  
>           0 dconf-service
> [32863.748966] [ 1471]  1001  1471    18298     4532      25       3        0  
>           0 gvfsd-http
> [32863.748968] [ 1547]  1001  1547     3578     1789      10       3        0  
>           0 gconfd-2
> [32863.748969] [ 1623]  1001  1623     1957     1143       7       3        0  
>           0 zsh
> [32863.748971] [ 2425]  1001  2425   102507    21798      94       3        0  
>           0 rhythmbox
> [32863.748972] [ 2461]  1001  2461   390178   196816     602       2        0  
>           0 firefox
> [32863.748974] [ 3760]     0  3760     2800      149       9       3        0  
>       -1000 sshd
> [32863.748975] [17911]  1001 17911    24484    11943      39       3        0  
>           0 gvim
> [32863.748977] [18097]     0 18097     5034     3500      13       3        0  
>           0 dhclient
> [32863.748978] [18171]     0 18171     3656      988      11       3        0  
>           0 sendmail
> [32863.748980] [18192]    51 18192     3526      792      11       3        0  
>           0 sendmail
> [32863.748981] [18204]  1001 18204     3279     1760      10       3        0  
>           0 ssh
> [32863.748983] [19033]     0 19033     1692      659       6       3        0  
>           0 crond
> [32863.748984] [19034]     0 19034     1498      692       6       3        0  
>           0 sh
> [32863.748985] [19038]     0 19038     1498      698       6       3        0  
>           0 dorsync
> [32863.748987] [19041]    51 19041     3525     1743      11       3        0  
>           0 sendmail
> [32863.748988] [19050]     0 19050    15815     3090      34       3        0  
>           0 rsync
> [32863.748990] [19051]     0 19051     1410      540       6       3        0  
>           0 grep
> [32863.748991] [19052]     0 19052     5192     2230      13       3        0  
>           0 rsync
> [32863.748993] [19053]     0 19053     7736     1937      18       3        0  
>           0 rsync
> [32863.748994] Out of memory: Kill process 2461 (firefox) score 94 or sacrifice
> child
> [32863.749097] Killed process 2461 (firefox) total-vm:1560712kB,
> anon-rss:664944kB, file-rss:105900kB, shmem-rss:16420kB
> [32866.693254] oom_reaper: reaped process 2461 (firefox), now anon-rss:0kB,
> file-rss:96kB, shmem-rss:16420kB
> [32887.266926] wlan0: authenticate with 00:23:69:14:c6:a8
> [32887.600036] wlan0: send auth to 00:23:69:14:c6:a8 (try 1/3)
> [32887.608689] wlan0: authenticated
> [32887.617209] wlan0: associate with 00:23:69:14:c6:a8 (try 1/3)
> [32887.627438] wlan0: RX AssocResp from 00:23:69:14:c6:a8 (capab=0x411 status=0
> aid=1)
> [32887.641053] wlan0: associated
> [32919.951379] rhythmbox invoked oom-killer:
> gfp_mask=0x25000c0(GFP_KERNEL_ACCOUNT), nodemask=0, order=0, oom_score_adj=0
> [32919.951382] rhythmbox cpuset=/ mems_allowed=0
> [32919.951388] CPU: 0 PID: 2425 Comm: rhythmbox Not tainted
> 4.9.0-1.fc26.i686+PAE #1
> [32919.951388] Hardware name: .   .  /IP35V(Intel P35+ICH7), BIOS 6.00 PG
> 03/31/2008
> [32919.951390]  ea5c5bfc c4b61460 ea5c5d24 eea653c0 ea5c5c2c c49dd360 00200206
> ea5c5c2c
> [32919.951394]  c4b670ef c52a03a0 ea5c5c30 ee8fcdc0 c4f7b3b4 eea653c0 c516c375
> ea5c5d24
> [32919.951397]  ea5c5c70 c4976b0d c4876a4a ea5c5c5c c4976799 00000003 00000000
> 000005a8
> [32919.951401] Call Trace:
> [32919.951409]  [<c4b61460>] dump_stack+0x58/0x78
> [32919.951412]  [<c49dd360>] dump_header+0x64/0x1a6
> [32919.951414]  [<c4b670ef>] ? ___ratelimit+0x9f/0x100
> [32919.951418]  [<c4976b0d>] oom_kill_process+0x1fd/0x3c0
> [32919.951420]  [<c4876a4a>] ? has_capability_noaudit+0x1a/0x30
> [32919.951422]  [<c4976799>] ? oom_badness.part.13+0xc9/0x140
> [32919.951423]  [<c4976fd5>] out_of_memory+0xf5/0x2b0
> [32919.951425]  [<c497bc0b>] __alloc_pages_nodemask+0xc9b/0xcb0
> [32919.951429]  [<c4e3bdd3>] alloc_skb_with_frags+0xf3/0x1b0
> [32919.951431]  [<c4e372aa>] sock_alloc_send_pskb+0x1ba/0x1e0
> [32919.951434]  [<c4ae22ec>] ? security_socket_getpeersec_dgram+0x3c/0x50
> [32919.951438]  [<c4f00c20>] unix_stream_sendmsg+0x2e0/0x390
> [32919.951441]  [<c4e32b6d>] sock_sendmsg+0x2d/0x40
> [32919.951443]  [<c4e32bf7>] sock_write_iter+0x77/0xe0
> [32919.951444]  [<c4e32b80>] ? sock_sendmsg+0x40/0x40
> [32919.951446]  [<c49e10e6>] do_readv_writev+0x246/0x410
> [32919.951447]  [<c4e32b80>] ? sock_sendmsg+0x40/0x40
> [32919.951449]  [<c49e14ed>] vfs_writev+0x3d/0x60
> [32919.951451]  [<c49e1566>] do_writev+0x56/0xe0
> [32919.951452]  [<c49e2150>] SyS_writev+0x20/0x30
> [32919.951455]  [<c480378a>] do_fast_syscall_32+0x8a/0x150
> [32919.951458]  [<c4f6708a>] sysenter_past_esp+0x47/0x75
> [32919.951459] Mem-Info:
> [32919.951463] active_anon:64184 inactive_anon:16572 isolated_anon:0
>                 active_file:175244 inactive_file:371618 isolated_file:64
>                 unevictable:8 dirty:0 writeback:0 unstable:0
>                 slab_reclaimable:186370 slab_unreclaimable:17574
>                 mapped:49133 shmem:6958 pagetables:1561 bounce:0
>                 free:186098 free_pcp:298 free_cma:0
> [32919.951465] Node 0 active_anon:256736kB inactive_anon:66288kB
> active_file:700976kB inactive_file:1486472kB unevictable:32kB
> isolated(anon):0kB isolated(file):256kB mapped:196532kB dirty:0kB writeback:0kB
> shmem:27832kB writeback_tmp:0kB unstable:0kB pages_scanned:6127287
> all_unreclaimable? yes
> [32919.951468] DMA free:3256kB min:68kB low:84kB high:100kB active_anon:0kB
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB
> writepending:0kB present:15992kB managed:15916kB mlocked:0kB
> slab_reclaimable:12468kB slab_unreclaimable:192kB kernel_stack:0kB
> pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [32919.951469] lowmem_reserve[]: 0 798 4005 4005
> [32919.951474] Normal free:3476kB min:3580kB low:4472kB high:5364kB
> active_anon:0kB inactive_anon:0kB active_file:1952kB inactive_file:68kB
> unevictable:0kB writepending:0kB present:892920kB managed:830896kB mlocked:0kB
> slab_reclaimable:733012kB slab_unreclaimable:70104kB kernel_stack:2248kB
> pagetables:0kB bounce:0kB free_pcp:1048kB local_pcp:316kB free_cma:0kB
> [32919.951474] lowmem_reserve[]: 0 0 25655 25655
> [32919.951478] HighMem free:737660kB min:512kB low:4104kB high:7696kB
> active_anon:256736kB inactive_anon:66288kB active_file:698964kB
> inactive_file:1486372kB unevictable:32kB writepending:0kB present:3283848kB
> managed:3283848kB mlocked:32kB slab_reclaimable:0kB slab_unreclaimable:0kB
> kernel_stack:0kB pagetables:6244kB bounce:0kB free_pcp:144kB local_pcp:116kB
> free_cma:0kB
> [32919.951479] lowmem_reserve[]: 0 0 0 0
> [32919.951481] DMA: 16*4kB (UE) 17*8kB (UE) 21*16kB (UME) 29*32kB (UME) 8*64kB
> (UM) 8*128kB (UM) 1*256kB (M) 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3256kB
> [32919.951490] Normal: 493*4kB (MEH) 0*8kB 26*16kB (H) 17*32kB (H) 7*64kB (H)
> 1*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 3508kB
> [32919.951497] HighMem: 27255*4kB (UM) 14640*8kB (UM) 11728*16kB (UM) 5029*32kB
> (UM) 882*64kB (UM) 258*128kB (UM) 123*256kB (UM) 34*512kB (UM) 16*1024kB (UM)
> 2*2048kB (UM) 1*4096kB (U) = 737660kB
> [32919.951507] Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0
> hugepages_size=2048kB
> [32919.951508] 553905 total pagecache pages
> [32919.951510] 0 pages in swap cache
> [32919.951511] Swap cache stats: add 0, delete 0, find 0/0
> [32919.951511] Free swap  = 4192960kB
> [32919.951512] Total swap = 4192960kB
> [32919.951512] 1048190 pages RAM
> [32919.951513] 820962 pages HighMem/MovableOnly
> [32919.951513] 15525 pages reserved
> [32919.951514] 0 pages hwpoisoned
> [32919.951514] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents
> oom_score_adj name
> [32919.951517] [  295]     0   295    16105     8075      24       3        0  
>           0 systemd-journal
> [32919.951519] [  332]     0   332     4155     1719       9       3        0  
>       -1000 systemd-udevd
> [32919.951521] [  471]     0   471     3486      741       7       3        0  
>       -1000 auditd
> [32919.951522] [  483]     0   483     2979      444       6       3        0  
>           0 audispd
> [32919.951523] [  487]     0   487     1509      486       7       3        0  
>           0 sedispatch
> [32919.951525] [  496]     0   496      999      301       6       3        0  
>           0 alsactl
> [32919.951526] [  499]     0   499      702       18       5       3        0  
>           0 gpm
> [32919.951528] [  510]     0   510     1140      320       6       3        0  
>           0 irqbalance
> [32919.951529] [  511]     0   511     2459     1887       9       3        0  
>           0 systemd-logind
> [32919.951530] [  514]    81   514     3814     1175       7       3        0  
>        -900 dbus-daemon
> [32919.951532] [  529]    38   529     1804     1225       6       3        0  
>           0 ntpd
> [32919.951533] [  554]     0   554    18820     3075      21       3        0  
>           0 NetworkManager
> [32919.951535] [  555]     0   555      701      460       5       3        0  
>           0 mcelog
> [32919.951536] [  598]     0   598     2989     1878       9       3        0  
>           0 wpa_supplicant
> [32919.951537] [  599]   485   599    19005     3423      21       3        0  
>           0 polkitd
> [32919.951539] [  817]     0   817     4070     2227      11       3        0  
>           0 cupsd
> [32919.951540] [  822]     0   822     1692      745       7       3        0  
>           0 crond
> [32919.951542] [  823]     0   823      884      541       5       3        0  
>           0 atd
> [32919.951543] [  833]     0   833    11251     1577      13       3        0  
>           0 lightdm
> [32919.951544] [  844]     0   844    67447    19748      76       3        0  
>           0 Xorg
> [32919.951546] [  848]     0   848     9997     1639      14       3        0  
>           0 accounts-daemon
> [32919.951547] [  870]   488   870    10763     2384      16       3        0  
>           0 colord
> [32919.951549] [  924]     0   924     7440     1855      12       3        0  
>           0 lightdm
> [32919.951550] [  949]  1001   949     2419     1676       8       3        0  
>           0 systemd
> [32919.951552] [  951]  1001   951     3294      523      10       3        0  
>           0 (sd-pam)
> [32919.951553] [  955]  1001   955     1498      679       6       3        0  
>           0 sh
> [32919.951554] [  966]  1001   966     4026     1165       8       3        0  
>           0 dbus-daemon
> [32919.951556] [  972]  1001   972     2022      102       8       3        0  
>           0 ssh-agent
> [32919.951557] [ 1092]  1001  1092    11566     3434      20       3        0  
>           0 xfce4-session
> [32919.951558] [ 1096]  1001  1096     2532     1240       9       3        0  
>           0 xfconfd
> [32919.951560] [ 1099]  1001  1099     6146      151       9       3        0  
>           0 gpg-agent
> [32919.951561] [ 1101]  1001  1101     8646     4725      20       3        0  
>           0 xfwm4
> [32919.951563] [ 1105]  1001  1105    14667     7087      27       3        0  
>           0 xfce4-panel
> [32919.951564] [ 1107]  1001  1107    11812     3753      20       3        0  
>           0 Thunar
> [32919.951566] [ 1109]  1001  1109    53207    10792      40       3        0  
>           0 xfdesktop
> [32919.951567] [ 1110]  1001  1110    12407     4006      21       3        0  
>           0 xfsettingsd
> [32919.951568] [ 1111]  1001  1111    16412     4286      24       3        0  
>           0 seapplet
> [32919.951570] [ 1117]  1001  1117    16785     8884      29       3        0  
>           0 redshift-gtk
> [32919.951571] [ 1118]  1001  1118    25569     6702      35       3        0  
>           0 nm-applet
> [32919.951572] [ 1119]  1001  1119    11228     1432      14       3        0  
>           0 at-spi-bus-laun
> [32919.951574] [ 1124]  1001  1124     3931     1055       7       3        0  
>           0 dbus-daemon
> [32919.951575] [ 1129]  1001  1129     7552     1659      11       3        0  
>           0 at-spi2-registr
> [32919.951576] [ 1134]  1001  1134    14194     6137      25       3        0  
>           0 xfce4-power-man
> [32919.951578] [ 1137]  1001  1137    10022     1525      15       3        0  
>           0 gvfsd
> [32919.951579] [ 1142]  1001  1142    13074     1341      15       3        0  
>           0 gvfsd-fuse
> [32919.951580] [ 1151]  1001  1151    11253     3222      21       3        0  
>           0 xfce-polkit
> [32919.951582] [ 1157]  1001  1157     2059     1179       7       3        0  
>           0 xscreensaver
> [32919.951583] [ 1201]     0  1201    13160     2066      18       3        0  
>           0 upowerd
> [32919.951585] [ 1246]  1001  1246    11844     4207      22       3        0  
>           0 panel-8-actions
> [32919.951586] [ 1247]  1001  1247    11848     4173      22       3        0  
>           0 panel-17-action
> [32919.951587] [ 1248]  1001  1248    11720     4217      20       3        0  
>           0 panel-12-thunar
> [32919.951589] [ 1249]  1001  1249     6938     3556      17       3        0  
>           0 panel-15-systra
> [32919.951590] [ 1250]  1001  1250   120950     5815      33       3        0  
>           0 panel-18-mixer
> [32919.951592] [ 1260]  1001  1260    12154     1656      14       3        0  
>           0 gvfsd-trash
> [32919.951593] [ 1277]  1001  1277    11106     2160      16       3        0  
>           0 gvfs-udisks2-vo
> [32919.951594] [ 1284]  1001  1284    91391     6073      51       3        0  
>           0 pulseaudio
> [32919.951596] [ 1285]  1001  1285     2359     1045       8       3        0  
>           0 redshift
> [32919.951597] [ 1290]     0  1290    14261     2176      15       3        0  
>           0 udisksd
> [32919.951599] [ 1297]  1001  1297    13023     1842      15       3        0  
>           0 gvfs-afc-volume
> [32919.951600] [ 1306]  1001  1306     7242     1227      12       3        0  
>           0 gvfsd-metadata
> [32919.951601] [ 1329]  1001  1329    23629     9760      38       3        0  
>           0 xfce4-terminal
> [32919.951603] [ 1334]  1001  1334     1956     1123       8       3        0  
>           0 zsh
> [32919.951604] [ 1351]  1001  1351     1486      653       6       3        0  
>           0 screen
> [32919.951605] [ 1352]  1001  1352     1585      736       6       3        0  
>           0 screen
> [32919.951607] [ 1353]  1001  1353     4176     2075      11       3        0  
>           0 micq
> [32919.951608] [ 1355]  1001  1355     1957     1152       7       3        0  
>           0 zsh
> [32919.951610] [ 1379]  1001  1379     1956     1139       8       3        0  
>           0 zsh
> [32919.951611] [ 1403]  1001  1403     1956     1122       7       3        0  
>           0 zsh
> [32919.951612] [ 1422]  1001  1422    16168     6248      28       3        0  
>           0 orage
> [32919.951614] [ 1423]  1001  1423    12524     5248      23       3        0  
>           0 globaltime
> [32919.951615] [ 1426]  1001  1426    74112    20511      94       3        0  
>           0 liferea
> [32919.951617] [ 1437]  1001  1437     6533     1262      10       3        0  
>           0 dconf-service
> [32919.951618] [ 1471]  1001  1471    18298     4532      25       3        0  
>           0 gvfsd-http
> [32919.951620] [ 1547]  1001  1547     3578     1789      10       3        0  
>           0 gconfd-2
> [32919.951621] [ 1623]  1001  1623     1957     1143       7       3        0  
>           0 zsh
> [32919.951622] [ 2425]  1001  2425   102380    21596      94       3        0  
>           0 rhythmbox
> [32919.951624] [ 3760]     0  3760     2800      149       9       3        0  
>       -1000 sshd
> [32919.951625] [17911]  1001 17911    24484    11943      39       3        0  
>           0 gvim
> [32919.951627] [18097]     0 18097     5034     3500      13       3        0  
>           0 dhclient
> [32919.951628] [18171]     0 18171     3656      988      11       3        0  
>           0 sendmail
> [32919.951630] [18192]    51 18192     3526      792      11       3        0  
>           0 sendmail
> [32919.951631] [18204]  1001 18204     3279     1760      10       3        0  
>           0 ssh
> [32919.951633] [19033]     0 19033     1692      659       6       3        0  
>           0 crond
> [32919.951634] [19034]     0 19034     1498      692       6       3        0  
>           0 sh
> [32919.951635] [19038]     0 19038     1498      698       6       3        0  
>           0 dorsync
> [32919.951637] [19041]    51 19041     3525     1743      11       3        0  
>           0 sendmail
> [32919.951638] [19050]     0 19050    15815     3156      34       3        0  
>           0 rsync
> [32919.951640] [19051]     0 19051     1410      540       6       3        0  
>           0 grep
> [32919.951641] [19052]     0 19052     5192     2296      13       3        0  
>           0 rsync
> [32919.951643] [19053]     0 19053     7736     2003      18       3        0  
>           0 rsync
> [32919.951644] Out of memory: Kill process 2425 (rhythmbox) score 10 or
> sacrifice child
> [32919.951672] Killed process 2425 (rhythmbox) total-vm:409520kB,
> anon-rss:34484kB, file-rss:50172kB, shmem-rss:1728kB
> [32920.328068] oom_reaper: reaped process 2425 (rhythmbox), now anon-rss:0kB,
> file-rss:8kB, shmem-rss:1800kB
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
