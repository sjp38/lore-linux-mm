Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C30F96B025E
	for <linux-mm@kvack.org>; Tue, 27 Dec 2016 06:48:44 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l2so28138572wml.5
        for <linux-mm@kvack.org>; Tue, 27 Dec 2016 03:48:44 -0800 (PST)
Received: from tschil.ethgen.ch (tschil.ethgen.ch. [5.9.7.51])
        by mx.google.com with ESMTPS id m76si45949487wmi.48.2016.12.27.03.48.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Dec 2016 03:48:38 -0800 (PST)
Date: Tue, 27 Dec 2016 12:48:24 +0100
From: Klaus Ethgen <Klaus+lkml@ethgen.de>
Subject: Re: Bug 4.9 and memorymanagement
Message-ID: <20161227114821.j3dl3r7segov6tb3@ikki.ethgen.ch>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="4jbyw4ckxstwdxmh"
Content-Disposition: inline
In-Reply-To: <20161226110053.GA16042@dhcp22.suse.cz>
 <66baf7dd-c5e3-e11c-092f-3a642c306e63@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org


--4jbyw4ckxstwdxmh
Content-Type: multipart/mixed; boundary="rlbqxeuxbnebjaro"
Content-Disposition: inline


--rlbqxeuxbnebjaro
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

Am Mo den 26. Dez 2016 um 11:38 schrieb Tetsuo Handa:
> linux-mm@kvack.org would be a better place to report.

Thanks, didn't know about that list.

Hope, it is ok to group reply?

Am Mo den 26. Dez 2016 um 12:00 schrieb Michal Hocko:
> > The last days I compiled version 4.9 for my i386 laptop. (Lenovo x61s)
>
> Do you have memory cgroups enabled in runtime (aka does the same happen
> with cgroup_disable=3Dmemory)?

Well, I have ulatencyd running and the support in the kernel, so yes.

> > What I was able to see is that it went to swap even if there is plenty
> > of memory left. The OOMs was also with many memory left.
>
> Could you paste those OOM reports from the kernel log?

Sure, see below in appendix.

By the way, I find the following two messages often. Maybe they are
unrelated, maybe not.
   [31633.189121] Purging GPU memory, 144 pages freed, 5692 pages still pin=
ned.
   [31638.530025] Unable to lock GPU to purge memory.

often the are seen after an OOM (maybe due to X killed).

> > I went back to 4.8.15 now with the same config from 4.9 and everything
> > gets back to normal.
> >
> > So it seems for me that there are some really strange memory leaks in
> > 4.9. The biggest problem is, that I do not know how to reproduce it
> > reliable. The only what I know is that it happened after several
> > suspends. (Not necessarily the first.)
> >
> > Am I the only one seeing that behavior or do anybody have an idea what
> > could went wrong?
>
> no there were some reports recently and 32b with memory cgroups are
> broken since 4.8 when the zone LRU's were moved to nodes.

Ah, nice, that matches with my findings that also 4.8.15 was broken but
not that wrong.

Finally I went back to 4.7.9 to start again with further tests.

In the end, I was able to have a 4.9 kernel that is stable so far. I did
it with reusing my 4.7.9 config and did a "make olddefconfig". (For the
broken one I did "make menuconfig" and read about the new parameters
before enabling them. Especially I was interested in hardening options
like CONFIG_SLAB_FREELIST_RANDOM and CONFIG_HARDENED_USERCOPY.)

Gru=DF
   Klaus

Appendix:
OOMs:
   [28756.498366] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), nodemask=3D0, order=3D0, oom_score_adj=3D0
   [28756.498373] Xorg cpuset=3D/ mems_allowed=3D0
   [28756.498382] CPU: 1 PID: 2746 Comm: Xorg Tainted: G     U     O    4.9=
=2E0 #1
   [28756.498385] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [28756.498388]  f2c25c24 c12b4830 f2c25c24 f09e8000 c113d7e1 f2c25b90 00=
003206 c12b99df
   [28756.498396]  f44bd31c 0001dcce 4e78dcce f09e8000 f09e842c c159e597 f2=
c25c24 c10e9553
   [28756.498403]  00000000 ef7d8840 00000000 0013cfe0 c10e91fb 00000000 00=
000000 0000006a
   [28756.498411] Call Trace:
   [28756.498420]  [<c12b4830>] ? dump_stack+0x44/0x64
   [28756.498426]  [<c113d7e1>] ? dump_header+0x5d/0x1b7
   [28756.498430]  [<c12b99df>] ? ___ratelimit+0x8f/0xf0
   [28756.498434]  [<c10e9553>] ? oom_kill_process+0x203/0x3d0
   [28756.498438]  [<c10e91fb>] ? oom_badness.part.12+0xeb/0x160
   [28756.498441]  [<c10e99de>] ? out_of_memory+0xde/0x290
   [28756.498445]  [<c10ed72c>] ? __alloc_pages_nodemask+0xc3c/0xc50
   [28756.498450]  [<c10fc297>] ? shmem_alloc_and_acct_page+0x137/0x210
   [28756.498455]  [<c10e5675>] ? find_get_entry+0xd5/0x110
   [28756.498459]  [<c10fcbc5>] ? shmem_getpage_gfp+0x165/0xbb0
   [28756.498464]  [<c1094c30>] ? rcu_seq_end+0x40/0x40
   [28756.498500]  [<f8944b0e>] ? i915_gem_shrink+0x23e/0x2d0 [i915]
   [28756.498506]  [<c14c194f>] ? wait_for_completion+0xbf/0xe0
   [28756.498510]  [<c10806e7>] ? __wake_up_locked+0x17/0x20
   [28756.498513]  [<c10fd652>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [28756.498537]  [<f893ca21>] ? i915_gem_object_get_pages_gtt+0x1e1/0x3d0=
 [i915]
   [28756.498561]  [<f893d265>] ? i915_gem_object_get_pages+0x35/0xb0 [i915]
   [28756.498586]  [<f893e1de>] ? i915_gem_object_set_to_gtt_domain+0x2e/0x=
150 [i915]
   [28756.498610]  [<f893ed15>] ? i915_gem_set_domain_ioctl+0xe5/0x120 [i91=
5]
   [28756.498634]  [<f893ec30>] ? i915_gem_obj_prepare_shmem_write+0x180/0x=
180 [i915]
   [28756.498648]  [<f824d666>] ? drm_ioctl+0x1c6/0x400 [drm]
   [28756.498672]  [<f893ec30>] ? i915_gem_obj_prepare_shmem_write+0x180/0x=
180 [i915]
   [28756.498677]  [<c1136a99>] ? get_mem_cgroup_from_mm+0x69/0xd0
   [28756.498680]  [<c12ba26b>] ? __rb_insert_augmented+0x1ab/0x1c0
   [28756.498685]  [<c1112620>] ? vm_get_page_prot+0x10/0x10
   [28756.498688]  [<c1112f00>] ? vma_link+0x60/0xb0
   [28756.498692]  [<c1113d76>] ? vma_set_page_prot+0x26/0x50
   [28756.498696]  [<c11155a1>] ? mmap_region+0x161/0x540
   [28756.498706]  [<f824d4a0>] ? drm_getunique+0x60/0x60 [drm]
   [28756.498711]  [<c115354f>] ? do_vfs_ioctl+0x8f/0x780
   [28756.498715]  [<c10c91de>] ? __audit_syscall_entry+0xae/0x110
   [28756.498719]  [<c10011b3>] ? syscall_trace_enter+0x183/0x200
   [28756.498723]  [<c10c8db1>] ? audit_filter_inodes+0xc1/0x100
   [28756.498727]  [<c10c88b5>] ? audit_filter_syscall+0xa5/0xd0
   [28756.498731]  [<c115d671>] ? __fget+0x61/0xb0
   [28756.498734]  [<c1153c6e>] ? SyS_ioctl+0x2e/0x50
   [28756.498738]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [28756.498742]  [<c14c4762>] ? sysenter_past_esp+0x47/0x75
   [28756.498744] Mem-Info:
   [28756.498751] active_anon:102497 inactive_anon:58398 isolated_anon:0
   [28756.498751]  active_file:318087 inactive_file:180221 isolated_file:0
   [28756.498751]  unevictable:6936 dirty:1164 writeback:0 unstable:0
   [28756.498751]  slab_reclaimable:48510 slab_unreclaimable:11849
   [28756.498751]  mapped:47698 shmem:8833 pagetables:766 bounce:0
   [28756.498751]  free:41859 free_pcp:451 free_cma:0
   [28756.498761] Node 0 active_anon:409988kB inactive_anon:233592kB active=
_file:1272348kB inactive_file:720884kB unevictable:27744kB isolated(anon):0=
kB isolated(file):0kB mapped:190792kB dirty:4656kB writeback:0kB shmem:0kB =
shmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 35332kB writeback_tmp:0kB uns=
table:0kB pages_scanned:4062806 all_unreclaimable? yes
   [28756.498769] DMA free:4116kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [28756.498782] Normal free:42404kB min:42416kB low:53020kB high:63624kB =
active_anon:1316kB inactive_anon:20540kB active_file:548376kB inactive_file=
:60kB unevictable:0kB writepending:260kB present:892920kB managed:854328kB =
mlocked:0kB slab_reclaimable:184192kB slab_unreclaimable:47020kB kernel_sta=
ck:2728kB pagetables:0kB bounce:0kB free_pcp:936kB local_pcp:216kB free_cma=
:0kB
   lowmem_reserve[]: 0 0 17397 17397
   [28756.498795] HighMem free:120916kB min:512kB low:28168kB high:55824kB =
active_anon:408672kB inactive_anon:213052kB active_file:722404kB inactive_f=
ile:720724kB unevictable:27744kB writepending:4396kB present:2226888kB mana=
ged:2226888kB mlocked:27744kB slab_reclaimable:0kB slab_unreclaimable:0kB k=
ernel_stack:0kB pagetables:3064kB bounce:0kB free_pcp:868kB local_pcp:220kB=
 free_cma:0kB
   lowmem_reserve[]: 0 0 0 0
   [28756.498803] DMA: 1*4kB (U) 2*8kB (UE) 0*16kB 0*32kB 0*64kB 4*128kB (U=
E) 4*256kB (E) 3*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D 4116kB
   Normal: 531*4kB (UME) 467*8kB (UME) 262*16kB (UME) 367*32kB (UME) 152*64=
kB (UME) 71*128kB (UM) 3*256kB (E) 2*512kB (E) 0*1024kB 0*2048kB 0*4096kB =
=3D 42404kB
   HighMem: 27*4kB (U) 27*8kB (U) 5*16kB (U) 2*32kB (U) 14*64kB (UM) 6*128k=
B (UM) 6*256kB (UM) 3*512kB (UM) 1*1024kB (U) 14*2048kB (UM) 21*4096kB (M) =
=3D 120916kB
   509526 total pagecache pages
   [28756.498863] 184 pages in swap cache
   [28756.498866] Swap cache stats: add 541, delete 357, find 0/0
   [28756.498868] Free swap  =3D 2094312kB
   [28756.498870] Total swap =3D 2096476kB
   [28756.498872] 783948 pages RAM
   [28756.498874] 556722 pages HighMem/MovableOnly
   [28756.498875] 9667 pages reserved
   [28756.498877] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [28756.498883] [  216]     0   216     2929      818       5       0    =
    0         -1000 udevd
   [28756.498888] [ 1669]     0  1669     1232       45       5       0    =
    0             0 acpi_fakekeyd
   [28756.498893] [ 1685]     0  1685     3233      523       5       0    =
    0         -1000 auditd
   [28756.498897] [ 2024]     0  2024     5349      343       7       0    =
    0             0 lxcfs
   [28756.498901] [ 2053]     0  2053      558       18       4       0    =
    0             0 thinkfan
   [28756.498905] [ 2054]     0  2054      559      196       4       0    =
    0             0 startpar
   [28756.498908] [ 2056]     0  2056     7910      609       6       0    =
    0             0 rsyslogd
   [28756.498912] [ 2060]     0  2060     5413      142       6       0    =
    0             0 lvmetad
   [28756.498916] [ 2101]     0  2101      601       23       3       0    =
    0             0 uuidd
   [28756.498920] [ 2198]     0  2198      595      434       4       0    =
    0             0 acpid
   [28756.498924] [ 2281]     0  2281     2003     1047       5       0    =
    0             0 haveged
   [28756.498928] [ 2294]     8  2294     1058      633       4       0    =
    0             0 nullmailer-send
   [28756.498931] [ 2307]   103  2307     1108      658       4       0    =
    0             0 dbus-daemon
   [28756.498935] [ 2354]     0  2354     7111      502       7       0    =
    0             0 pcscd
   [28756.498939] [ 2459]     0  2459     1451      973       5       0    =
    0             0 bluetoothd
   [28756.498943] [ 2488]   124  2488      824      594       4       0    =
    0             0 ulogd
   [28756.498947] [ 2545]     0  2545     2129      726       4       0    =
    0         -1000 sshd
   [28756.498951] [ 2566]     0  2566     1460      580       6       0    =
    0             0 smartd
   [28756.498954] [ 2572]   110  2572     5360     2818       8       0    =
    0             0 unbound
   [28756.498958] [ 2626]     0  2626     8222     3671       9       0    =
    0             0 wicd
   [28756.498962] [ 2675]     0  2675     1406      608       5       0    =
    0             0 cron
   [28756.498965] [ 2703]   121  2703     9921      741       8       0    =
    0             0 privoxy
   [28756.498969] [ 2729]     0  2729     1511      571       5       0    =
    0             0 wdm
   [28756.498973] [ 2736]     0  2736     1511      603       5       0    =
    0             0 wdm
   [28756.498977] [ 2746]     0  2746    26486    12809      26       0    =
    0             0 Xorg
   [28756.498981] [ 2761]     0  2761     4975     3281       8       0    =
    0             0 wicd-monitor
   [28756.498985] [ 2827]     0  2827      553      132       4       0    =
    0             0 mingetty
   [28756.498988] [ 2833]     0  2833     1698     1013       5       0    =
    0             0 wdm
   [28756.498992] [ 2849] 10230  2849    13596     3301      11       0    =
    0             0 fvwm2
   [28756.498996] [ 2903] 10230  2903     1136      605       6       0    =
    0             0 dbus-launch
   [28756.498999] [ 2904] 10230  2904     1075      604       5       0    =
    0             0 dbus-daemon
   [28756.503469] [ 2921] 10230  2921     8450      409       8       0    =
    0             0 gpg-agent
   [28756.503477] [ 2925] 10230  2925     3957      730       5       0    =
    0             0 tpb
   [28756.503482] [ 2937] 10230  2937     2099     1271       6       0    =
    0             0 xscreensaver
   [28756.503487] [ 2939] 10230  2939     2937      633       7       0    =
    0             0 redshift
   [28756.503492] [ 2949] 10230  2949     1284      620       4       0    =
    0             0 autocutsel
   [28756.503496] [ 2956] 10230  2956    10940     5171      12       0    =
    0             0 gkrellm
   [28756.503501] [ 2957] 10230  2957    52699    18548      39       0    =
    0             0 psi-plus
   [28756.503506] [ 2958] 10230  2958    10774     7323      15       0    =
    0             0 wicd-client
   [28756.503510] [ 2980] 10230  2980     1047      301       5       0    =
    0             0 FvwmCommandS
   [28756.503515] [ 2981] 10230  2981     1528      451       5       0    =
    0             0 FvwmEvent
   [28756.503520] [ 2982] 10230  2982    12182     2117      10       0    =
    0             0 FvwmAnimate
   [28756.503524] [ 2983] 10230  2983    12808     2430      11       0    =
    0             0 FvwmButtons
   [28756.503529] [ 2984] 10230  2984    13311     2697      12       0    =
    0             0 FvwmProxy
   [28756.503533] [ 2985] 10230  2985     1507      406       5       0    =
    0             0 FvwmAuto
   [28756.503538] [ 2986] 10230  2986    12803     2412      11       0    =
    0             0 FvwmPager
   [28756.503542] [ 2987] 10230  2987      581      145       3       0    =
    0             0 sh
   [28756.503547] [ 2988] 10230  2988     1030      703       4       0    =
    0             0 stalonetray
   [28756.503551] [ 3293] 10230  3293     2717     1591       6       0    =
    0             0 xterm
   [28756.503555] [ 3296] 10230  3296     2091     1417       5       0    =
    0             0 zsh
   [28756.503560] [ 3528] 10230  3528     3043     1864       7       0    =
    0             0 xterm
   [28756.503564] [ 3530] 10230  3530     2495     1325       6       0    =
    0             0 ssh
   [28756.503569] [ 3537]     0  3537     2866     1412       6       0    =
    0             0 sshd
   [28756.503573] [ 3541] 10230  3541     8278      817       8       0    =
    0             0 scdaemon
   [28756.503578] [ 3552] 10230  3552     2495      632       6       0    =
    0             0 ssh
   [28756.503582] [ 3555]     0  3555     2498     1837       7       0    =
    0             0 zsh
   [28756.503590] [ 4218] 10230  4218     2817     1648       6       0    =
    0             0 xterm
   [28756.503595] [ 4221] 10230  4221     2331     1647       5       0    =
    0             0 zsh
   [28756.503599] [15515] 10230 15515   291002   138194     253       0    =
    0             0 firefox.real
   [28756.503603] [16352] 10230 16352     2808     1618       6       0    =
    0             0 xterm
   [28756.503608] [16355] 10230 16355     2061     1370       6       0    =
    0             0 zsh
   [28756.503614] [30422]     0 30422      626      469       4       0    =
    0             0 anacron
   [28756.503618] [31403]     0 31403      581      143       4       0    =
    0             0 sh
   [28756.503623] [31404]     0 31404      554      379       4       0    =
    0             0 run-parts
   [28756.503627] [31551] 10230 31551    15591     9353      18       0    =
    0             0 vim
   [28756.503631] [  578] 10230   578    12479     5848      15       0    =
    0             0 vim
   [28756.503637] [ 7020]     0  7020      557      134       4       0    =
    0             0 sleep
   [28756.503643] [ 7316]     0  7316      581      391       4       0    =
    0             0 battery-stats-c
   [28756.503647] [ 7328]     0  7328      557      142       4       0    =
    0             0 sleep
   [28756.503652] [ 7425]     0  7425     7386     6886      11       0    =
    0         -1000 ulatencyd
   [28756.503656] [ 7459]     0  7459      891      668       4       0    =
    0             0 mlocate
   [28756.503661] [ 7465]     0  7465      595      159       4       0    =
    0             0 flock
   [28756.503665] [ 7466]     0  7466      604      447       4       0    =
    0             0 updatedb.mlocat
   [28756.503683] Out of memory: Kill process 15515 (firefox.real) score 10=
6 or sacrifice child
   [28756.503766] Killed process 15515 (firefox.real) total-vm:1164008kB, a=
non-rss:447680kB, file-rss:97228kB, shmem-rss:7868kB

   [28757.732436] updatedb.mlocat invoked oom-killer: gfp_mask=3D0x2400840(=
GFP_NOFS|__GFP_NOFAIL), nodemask=3D0, order=3D0, oom_score_adj=3D0
   [28757.732442] updatedb.mlocat cpuset=3D/ mems_allowed=3D0
   [28757.732450] CPU: 1 PID: 7466 Comm: updatedb.mlocat Tainted: G     U  =
   O    4.9.0 #1
   [28757.732453] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [28757.732456]  c3c85b54 c12b4830 c3c85b54 f36e2940 c113d7e1 c3c85ac0 00=
000206 c12b99df
   [28757.732464]  f44bd31c 0101ab10 ee8bab10 f36e2940 f36e2d6c c159e597 c3=
c85b54 c10e9553
   [28757.732472]  00000000 ef7d8840 00000000 0013cfe0 c10e91fb 00000000 00=
000000 0000000e
   [28757.732479] Call Trace:
   [28757.732488]  [<c12b4830>] ? dump_stack+0x44/0x64
   [28757.732493]  [<c113d7e1>] ? dump_header+0x5d/0x1b7
   [28757.732498]  [<c12b99df>] ? ___ratelimit+0x8f/0xf0
   [28757.732502]  [<c10e9553>] ? oom_kill_process+0x203/0x3d0
   [28757.732506]  [<c10e91fb>] ? oom_badness.part.12+0xeb/0x160
   [28757.732509]  [<c10e99de>] ? out_of_memory+0xde/0x290
   [28757.732513]  [<c10ed690>] ? __alloc_pages_nodemask+0xba0/0xc50
   [28757.732518]  [<c10e5a2a>] ? pagecache_get_page+0xaa/0x250
   [28757.732523]  [<c1202563>] ? __alloc_extent_buffer+0x93/0xd0
   [28757.732527]  [<c120a3ff>] ? alloc_extent_buffer+0x13f/0x450
   [28757.732532]  [<c11d6052>] ? read_tree_block+0x12/0x50
   [28757.732536]  [<c11af405>] ? btrfs_release_path+0x15/0x80
   [28757.732539]  [<c11b21fb>] ? read_block_for_search.isra.32+0x14b/0x380
   [28757.732544]  [<c1226a02>] ? btrfs_tree_read_lock+0x32/0x100
   [28757.732548]  [<c11b40c1>] ? btrfs_search_slot+0x341/0x950
   [28757.732553]  [<c11d339d>] ? btrfs_lookup_inode+0x3d/0xc0
   [28757.732557]  [<c112c21f>] ? kmem_cache_alloc+0xaf/0x100
   [28757.732561]  [<c11ee217>] ? btrfs_iget+0x107/0x7d0
   [28757.732565]  [<c11cf9e9>] ? btrfs_match_dir_item_name+0xe9/0x110
   [28757.732570]  [<c11ef22f>] ? btrfs_lookup_dentry+0x47f/0x5d0
   [28757.732574]  [<c11ef388>] ? btrfs_lookup+0x8/0x40
   [28757.732578]  [<c114bade>] ? lookup_slow+0x7e/0x140
   [28757.732581]  [<c114cf94>] ? walk_component+0x1d4/0x300
   [28757.732584]  [<c114ac1a>] ? path_init+0x16a/0x360
   [28757.732588]  [<c114d641>] ? path_lookupat+0x51/0x100
   [28757.732591]  [<c114f9bc>] ? filename_lookup+0x8c/0x170
   [28757.732595]  [<c12bff28>] ? lockref_get+0x8/0x20
   [28757.732599]  [<c10c9567>] ? __audit_getname+0x77/0x90
   [28757.732603]  [<c114f69c>] ? getname_flags+0x8c/0x190
   [28757.732607]  [<c1145788>] ? vfs_fstatat+0x68/0xc0
   [28757.732610]  [<c11460c8>] ? SyS_lstat64+0x28/0x50
   [28757.732614]  [<c10c8db1>] ? audit_filter_inodes+0xc1/0x100
   [28757.732618]  [<c10c88b5>] ? audit_filter_syscall+0xa5/0xd0
   [28757.732621]  [<c10c9416>] ? __audit_syscall_exit+0x1d6/0x260
   [28757.732625]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [28757.732630]  [<c14c4762>] ? sysenter_past_esp+0x47/0x75
   [28757.732632] Mem-Info:
   [28757.732638] active_anon:31030 inactive_anon:15460 isolated_anon:0
   [28757.732638]  active_file:320172 inactive_file:178465 isolated_file:0
   [28757.732638]  unevictable:6936 dirty:0 writeback:1 unstable:0
   [28757.732638]  slab_reclaimable:48471 slab_unreclaimable:11834
   [28757.732638]  mapped:25791 shmem:6838 pagetables:512 bounce:0
   [28757.732638]  free:156631 free_pcp:126 free_cma:0
   [28757.732649] Node 0 active_anon:124120kB inactive_anon:61840kB active_=
file:1280688kB inactive_file:713860kB unevictable:27744kB isolated(anon):0k=
B isolated(file):0kB mapped:103164kB dirty:0kB writeback:4kB shmem:0kB shme=
m_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 27352kB writeback_tmp:0kB unstabl=
e:0kB pages_scanned:3674354 all_unreclaimable? yes
   [28757.732656] DMA free:4116kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [28757.732669] Normal free:42324kB min:42416kB low:53020kB high:63624kB =
active_anon:1312kB inactive_anon:20408kB active_file:549628kB inactive_file=
:40kB unevictable:0kB writepending:0kB present:892920kB managed:854328kB ml=
ocked:0kB slab_reclaimable:184036kB slab_unreclaimable:46960kB kernel_stack=
:2384kB pagetables:0kB bounce:0kB free_pcp:408kB local_pcp:124kB free_cma:0=
kB
   lowmem_reserve[]: 0 0 17397 17397
   [28757.732681] HighMem free:580084kB min:512kB low:28168kB high:55824kB =
active_anon:122808kB inactive_anon:41432kB active_file:729492kB inactive_fi=
le:713820kB unevictable:27744kB writepending:4kB present:2226888kB managed:=
2226888kB mlocked:27744kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:2048kB bounce:0kB free_pcp:96kB local_pcp:96kB free_=
cma:0kB
   lowmem_reserve[]: 0 0 0 0
   [28757.732689] DMA: 1*4kB (U) 2*8kB (UE) 0*16kB 0*32kB 0*64kB 4*128kB (U=
E) 4*256kB (E) 3*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D 4116kB
   Normal: 485*4kB (ME) 498*8kB (UME) 273*16kB (ME) 355*32kB (UME) 153*64kB=
 (UME) 71*128kB (UM) 3*256kB (E) 2*512kB (E) 0*1024kB 0*2048kB 0*4096kB =3D=
 42324kB
   HighMem: 13625*4kB (UM) 6184*8kB (UM) 3241*16kB (UM) 1682*32kB (UM) 866*=
64kB (UM) 541*128kB (UM) 212*256kB (UM) 68*512kB (UM) 21*1024kB (UM) 18*204=
8kB (UM) 24*4096kB (M) =3D 580084kB
   507869 total pagecache pages
   [28757.732748] 188 pages in swap cache
   [28757.732751] Swap cache stats: add 789, delete 601, find 165/172
   [28757.732753] Free swap  =3D 2094296kB
   [28757.732755] Total swap =3D 2096476kB
   [28757.732757] 783948 pages RAM
   [28757.732759] 556722 pages HighMem/MovableOnly
   [28757.732761] 9667 pages reserved
   [28757.732763] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [28757.732768] [  216]     0   216     2929      818       5       0    =
    0         -1000 udevd
   [28757.732774] [ 1669]     0  1669     1232       45       5       0    =
    0             0 acpi_fakekeyd
   [28757.732778] [ 1685]     0  1685     3233      523       5       0    =
    0         -1000 auditd
   [28757.732782] [ 2024]     0  2024     5349      343       7       0    =
    0             0 lxcfs
   [28757.732786] [ 2053]     0  2053      558       18       4       0    =
    0             0 thinkfan
   [28757.732790] [ 2054]     0  2054      559      196       4       0    =
    0             0 startpar
   [28757.732794] [ 2056]     0  2056     7910      609       6       0    =
    0             0 rsyslogd
   [28757.732798] [ 2060]     0  2060     5413      142       6       0    =
    0             0 lvmetad
   [28757.732801] [ 2101]     0  2101      601       23       3       0    =
    0             0 uuidd
   [28757.732805] [ 2198]     0  2198      595      434       4       0    =
    0             0 acpid
   [28757.732809] [ 2281]     0  2281     2003     1047       5       0    =
    0             0 haveged
   [28757.732813] [ 2294]     8  2294     1058      633       4       0    =
    0             0 nullmailer-send
   [28757.732817] [ 2307]   103  2307     1108      658       4       0    =
    0             0 dbus-daemon
   [28757.732821] [ 2354]     0  2354     7111      502       7       0    =
    0             0 pcscd
   [28757.732825] [ 2459]     0  2459     1451      973       5       0    =
    0             0 bluetoothd
   [28757.732829] [ 2488]   124  2488      824      594       4       0    =
    0             0 ulogd
   [28757.732833] [ 2545]     0  2545     2129      726       4       0    =
    0         -1000 sshd
   [28757.732837] [ 2566]     0  2566     1460      580       6       0    =
    0             0 smartd
   [28757.732840] [ 2572]   110  2572     5360     2818       8       0    =
    0             0 unbound
   [28757.732844] [ 2626]     0  2626     8222     3671       9       0    =
    0             0 wicd
   [28757.732848] [ 2675]     0  2675     1406      608       5       0    =
    0             0 cron
   [28757.732852] [ 2703]   121  2703     9921      741       8       0    =
    0             0 privoxy
   [28757.732856] [ 2729]     0  2729     1511      571       5       0    =
    0             0 wdm
   [28757.732859] [ 2736]     0  2736     1511      603       5       0    =
    0             0 wdm
   [28757.732864] [ 2746]     0  2746    24496    10852      25       0    =
    0             0 Xorg
   [28757.732867] [ 2761]     0  2761     4975     3281       8       0    =
    0             0 wicd-monitor
   [28757.732871] [ 2827]     0  2827      553      132       4       0    =
    0             0 mingetty
   [28757.732875] [ 2833]     0  2833     1698     1013       5       0    =
    0             0 wdm
   [28757.732879] [ 2849] 10230  2849    13596     3301      11       0    =
    0             0 fvwm2
   [28757.732883] [ 2903] 10230  2903     1136      605       6       0    =
    0             0 dbus-launch
   [28757.732887] [ 2904] 10230  2904     1075      604       5       0    =
    0             0 dbus-daemon
   [28757.732890] [ 2921] 10230  2921     8450      409       8       0    =
    0             0 gpg-agent
   [28757.732894] [ 2925] 10230  2925     3957      730       5       0    =
    0             0 tpb
   [28757.732898] [ 2937] 10230  2937     2099     1271       6       0    =
    0             0 xscreensaver
   [28757.732902] [ 2939] 10230  2939     2937      633       7       0    =
    0             0 redshift
   [28757.732906] [ 2949] 10230  2949     1284      620       4       0    =
    0             0 autocutsel
   [28757.732910] [ 2956] 10230  2956    10940     5171      12       0    =
    0             0 gkrellm
   [28757.732914] [ 2957] 10230  2957    52699    18548      39       0    =
    0             0 psi-plus
   [28757.732918] [ 2958] 10230  2958    10774     7323      15       0    =
    0             0 wicd-client
   [28757.732921] [ 2980] 10230  2980     1047      301       5       0    =
    0             0 FvwmCommandS
   [28757.732925] [ 2981] 10230  2981     1528      451       5       0    =
    0             0 FvwmEvent
   [28757.732929] [ 2982] 10230  2982    12182     2117      10       0    =
    0             0 FvwmAnimate
   [28757.732933] [ 2983] 10230  2983    12808     2430      11       0    =
    0             0 FvwmButtons
   [28757.732937] [ 2984] 10230  2984    13311     2697      12       0    =
    0             0 FvwmProxy
   [28757.732941] [ 2985] 10230  2985     1507      406       5       0    =
    0             0 FvwmAuto
   [28757.732945] [ 2986] 10230  2986    12803     2412      11       0    =
    0             0 FvwmPager
   [28757.732949] [ 2987] 10230  2987      581      145       3       0    =
    0             0 sh
   [28757.732953] [ 2988] 10230  2988     1030      703       4       0    =
    0             0 stalonetray
   [28757.732957] [ 3293] 10230  3293     2717     1591       6       0    =
    0             0 xterm
   [28757.732960] [ 3296] 10230  3296     2091     1417       5       0    =
    0             0 zsh
   [28757.732964] [ 3528] 10230  3528     3043     1864       7       0    =
    0             0 xterm
   [28757.732968] [ 3530] 10230  3530     2495     1325       6       0    =
    0             0 ssh
   [28757.732972] [ 3537]     0  3537     2866     1412       6       0    =
    0             0 sshd
   [28757.732976] [ 3541] 10230  3541     8278      817       8       0    =
    0             0 scdaemon
   [28757.732980] [ 3552] 10230  3552     2495      632       6       0    =
    0             0 ssh
   [28757.732983] [ 3555]     0  3555     2498     1837       7       0    =
    0             0 zsh
   [28757.732988] [ 4218] 10230  4218     2817     1648       6       0    =
    0             0 xterm
   [28757.732991] [ 4221] 10230  4221     2331     1647       5       0    =
    0             0 zsh
   [28757.732995] [16352] 10230 16352     2808     1618       6       0    =
    0             0 xterm
   [28757.732999] [16355] 10230 16355     2061     1370       6       0    =
    0             0 zsh
   [28757.734531] [30422]     0 30422      626      469       4       0    =
    0             0 anacron
   [28757.734537] [31403]     0 31403      581      143       4       0    =
    0             0 sh
   [28757.734541] [31404]     0 31404      554      379       4       0    =
    0             0 run-parts
   [28757.734546] [31551] 10230 31551    15591     9353      18       0    =
    0             0 vim
   [28757.734550] [  578] 10230   578    12479     5848      15       0    =
    0             0 vim
   [28757.734554] [ 7020]     0  7020      557      134       4       0    =
    0             0 sleep
   [28757.734558] [ 7316]     0  7316      581      391       4       0    =
    0             0 battery-stats-c
   [28757.734562] [ 7328]     0  7328      557      142       4       0    =
    0             0 sleep
   [28757.734567] [ 7425]     0  7425     7386     6886      11       0    =
    0         -1000 ulatencyd
   [28757.734571] [ 7459]     0  7459      891      668       4       0    =
    0             0 mlocate
   [28757.734574] [ 7465]     0  7465      595      159       4       0    =
    0             0 flock
   [28757.734578] [ 7466]     0  7466      604      447       4       0    =
    0             0 updatedb.mlocat
   [28757.734582] Out of memory: Kill process 2957 (psi-plus) score 14 or s=
acrifice child
   [28757.734603] Killed process 2957 (psi-plus) total-vm:210796kB, anon-rs=
s:29156kB, file-rss:44496kB, shmem-rss:540kB

   [31617.991795] gkrellm invoked oom-killer: gfp_mask=3D0x25000c0(GFP_KERN=
EL_ACCOUNT), nodemask=3D0, order=3D0, oom_score_adj=3D0
   [31617.991802] gkrellm cpuset=3D/ mems_allowed=3D0
   [31617.991810] CPU: 0 PID: 2956 Comm: gkrellm Tainted: G     U     O    =
4.9.0 #1
   [31617.991813] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [31617.991817]  f15f1d64 c12b4830 f15f1d64 f09e8000 c113d7e1 f15f1cd0 00=
000206 c12b99df
   [31617.991825]  f44bd31c 0101a5ea 1adba5ea f09e8000 f09e842c c159e597 f1=
5f1d64 c10e9553
   [31617.991832]  00000000 f093d280 00000000 0013cfe0 c10e91fb 00000000 00=
000000 00000060
   [31617.991840] Call Trace:
   [31617.991849]  [<c12b4830>] ? dump_stack+0x44/0x64
   [31617.991855]  [<c113d7e1>] ? dump_header+0x5d/0x1b7
   [31617.991859]  [<c12b99df>] ? ___ratelimit+0x8f/0xf0
   [31617.991864]  [<c10e9553>] ? oom_kill_process+0x203/0x3d0
   [31617.991867]  [<c10e91fb>] ? oom_badness.part.12+0xeb/0x160
   [31617.991871]  [<c10e99de>] ? out_of_memory+0xde/0x290
   [31617.991875]  [<c10ed72c>] ? __alloc_pages_nodemask+0xc3c/0xc50
   [31617.991880]  [<c141d752>] ? alloc_skb_with_frags+0xf2/0x1b0
   [31617.991884]  [<c14186fe>] ? sock_alloc_send_pskb+0x1be/0x1e0
   [31617.991888]  [<c1163d70>] ? seq_open+0x20/0x90
   [31617.991893]  [<c112c21f>] ? kmem_cache_alloc+0xaf/0x100
   [31617.991897]  [<c14b6b1d>] ? unix_stream_sendmsg+0x23d/0x3a0
   [31617.991901]  [<c14145b5>] ? sock_write_iter+0x75/0xf0
   [31617.991905]  [<c1414540>] ? kernel_sendmsg+0x50/0x50
   [31617.991908]  [<c11415f8>] ? do_readv_writev+0x248/0x400
   [31617.991911]  [<c1414540>] ? kernel_sendmsg+0x50/0x50
   [31617.991916]  [<c10011b3>] ? syscall_trace_enter+0x183/0x200
   [31617.991919]  [<c11419e7>] ? vfs_writev+0x37/0x60
   [31617.991922]  [<c1141a62>] ? do_writev+0x52/0xe0
   [31617.991925]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [31617.991930]  [<c14c4762>] ? sysenter_past_esp+0x47/0x75
   [31617.991932] Mem-Info:
   [31617.991939] active_anon:102728 inactive_anon:47238 isolated_anon:0
   [31617.991939]  active_file:318732 inactive_file:144917 isolated_file:0
   [31617.991939]  unevictable:7117 dirty:17 writeback:0 unstable:0
   [31617.991939]  slab_reclaimable:45826 slab_unreclaimable:11350
   [31617.991939]  mapped:46166 shmem:8686 pagetables:741 bounce:0
   [31617.991939]  free:89837 free_pcp:508 free_cma:0
   [31617.991950] Node 0 active_anon:410912kB inactive_anon:188952kB active=
_file:1274928kB inactive_file:579668kB unevictable:28468kB isolated(anon):0=
kB isolated(file):0kB mapped:184664kB dirty:68kB writeback:0kB shmem:0kB sh=
mem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 34744kB writeback_tmp:0kB unsta=
ble:0kB pages_scanned:5362697 all_unreclaimable? yes
   [31617.991957] DMA free:4116kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [31617.991970] Normal free:42300kB min:42416kB low:53020kB high:63624kB =
active_anon:1380kB inactive_anon:20244kB active_file:558700kB inactive_file=
:16kB unevictable:0kB writepending:16kB present:892920kB managed:854328kB m=
locked:0kB slab_reclaimable:173456kB slab_unreclaimable:45024kB kernel_stac=
k:3144kB pagetables:0kB bounce:0kB free_pcp:1392kB local_pcp:612kB free_cma=
:0kB
   lowmem_reserve[]: 0 0 17397 17397
   [31617.991982] HighMem free:312932kB min:512kB low:28168kB high:55824kB =
active_anon:409600kB inactive_anon:168672kB active_file:714660kB inactive_f=
ile:579584kB unevictable:28468kB writepending:0kB present:2226888kB managed=
:2226888kB mlocked:28468kB slab_reclaimable:0kB slab_unreclaimable:0kB kern=
el_stack:0kB pagetables:2964kB bounce:0kB free_pcp:640kB local_pcp:620kB fr=
ee_cma:0kB
   lowmem_reserve[]: 0 0 0 0
   [31617.991990] DMA: 1*4kB (U) 2*8kB (UE) 0*16kB 0*32kB 0*64kB 4*128kB (U=
E) 4*256kB (E) 3*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D 4116kB
   Normal: 465*4kB (ME) 491*8kB (ME) 158*16kB (UME) 260*32kB (UME) 153*64kB=
 (UME) 60*128kB (UME) 24*256kB (UM) 4*512kB (M) 0*1024kB 0*2048kB 0*4096kB =
=3D 42300kB
   HighMem: 60*4kB (UM) 27*8kB (UM) 132*16kB (UM) 240*32kB (UM) 138*64kB (U=
M) 60*128kB (UM) 98*256kB (UM) 110*512kB (UM) 42*1024kB (UM) 25*2048kB (UM)=
 27*4096kB (M) =3D 312968kB
   474670 total pagecache pages
   [31617.992085] 191 pages in swap cache
   [31617.992088] Swap cache stats: add 2859, delete 2668, find 997/1128
   [31617.992090] Free swap  =3D 2093464kB
   [31617.992092] Total swap =3D 2096476kB
   [31617.992094] 783948 pages RAM
   [31617.992096] 556722 pages HighMem/MovableOnly
   [31617.992098] 9667 pages reserved
   [31617.992100] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [31617.992107] [  216]     0   216     2929      818       5       0    =
    0         -1000 udevd
   [31617.992115] [ 1669]     0  1669     1232       45       5       0    =
    0             0 acpi_fakekeyd
   [31617.992120] [ 1685]     0  1685     3233      523       5       0    =
    0         -1000 auditd
   [31617.992124] [ 2024]     0  2024     7688      343       8       0    =
    0             0 lxcfs
   [31617.992128] [ 2053]     0  2053      558       18       4       0    =
    0             0 thinkfan
   [31617.992132] [ 2054]     0  2054      559      196       4       0    =
    0             0 startpar
   [31617.992136] [ 2056]     0  2056     7910      609       6       0    =
    0             0 rsyslogd
   [31617.992141] [ 2060]     0  2060     5413      142       6       0    =
    0             0 lvmetad
   [31617.992144] [ 2101]     0  2101      601       23       3       0    =
    0             0 uuidd
   [31617.992148] [ 2198]     0  2198      595      434       4       0    =
    0             0 acpid
   [31617.992152] [ 2281]     0  2281     2003     1047       5       0    =
    0             0 haveged
   [31617.992156] [ 2294]     8  2294     1058      633       4       0    =
    0             0 nullmailer-send
   [31617.992160] [ 2307]   103  2307     1108      658       4       0    =
    0             0 dbus-daemon
   [31617.992164] [ 2354]     0  2354     7111      502       7       0    =
    0             0 pcscd
   [31617.992168] [ 2459]     0  2459     1451      973       5       0    =
    0             0 bluetoothd
   [31617.992172] [ 2488]   124  2488      824      594       4       0    =
    0             0 ulogd
   [31617.992176] [ 2545]     0  2545     2129      726       4       0    =
    0         -1000 sshd
   [31617.992180] [ 2566]     0  2566     1460      580       6       0    =
    0             0 smartd
   [31617.992184] [ 2572]   110  2572     5360     2884       8       0    =
    0             0 unbound
   [31617.992188] [ 2626]     0  2626     8317     3717       9       0    =
    0             0 wicd
   [31617.992197] [ 2675]     0  2675     1406      608       5       0    =
    0             0 cron
   [31617.992205] [ 2703]   121  2703     9921      741       8       0    =
    0             0 privoxy
   [31617.992212] [ 2729]     0  2729     1511      571       5       0    =
    0             0 wdm
   [31617.992218] [ 2736]     0  2736     1511      603       5       0    =
    0             0 wdm
   [31617.992225] [ 2746]     0  2746    26081    12408      25       0    =
    0             0 Xorg
   [31617.992232] [ 2761]     0  2761     4975     3281       8       0    =
    0             0 wicd-monitor
   [31617.992239] [ 2827]     0  2827      553      132       4       0    =
    0             0 mingetty
   [31617.992246] [ 2833]     0  2833     1698     1013       5       0    =
    0             0 wdm
   [31617.992253] [ 2849] 10230  2849    13599     3304      11       0    =
    0             0 fvwm2
   [31617.992260] [ 2903] 10230  2903     1136      605       6       0    =
    0             0 dbus-launch
   [31617.992274] [ 2904] 10230  2904     1075      604       5       0    =
    0             0 dbus-daemon
   [31617.992280] [ 2921] 10230  2921     8450      409       8       0    =
    0             0 gpg-agent
   [31617.992288] [ 2925] 10230  2925     3957      730       5       0    =
    0             0 tpb
   [31617.992294] [ 2937] 10230  2937     2099     1271       6       0    =
    0             0 xscreensaver
   [31617.992301] [ 2939] 10230  2939     2937      633       7       0    =
    0             0 redshift
   [31617.992307] [ 2949] 10230  2949     1284      620       4       0    =
    0             0 autocutsel
   [31617.992315] [ 2956] 10230  2956    10940     5171      12       0    =
    0             0 gkrellm
   [31617.992322] [ 2958] 10230  2958    11297     8193      15       0    =
    0             0 wicd-client
   [31617.992329] [ 2980] 10230  2980     1047      301       5       0    =
    0             0 FvwmCommandS
   [31617.992336] [ 2981] 10230  2981     1528      451       5       0    =
    0             0 FvwmEvent
   [31617.992343] [ 2982] 10230  2982    12182     2117      10       0    =
    0             0 FvwmAnimate
   [31617.992350] [ 2983] 10230  2983    12808     2430      11       0    =
    0             0 FvwmButtons
   [31617.992357] [ 2984] 10230  2984    13311     2697      12       0    =
    0             0 FvwmProxy
   [31617.992365] [ 2985] 10230  2985     1507      406       5       0    =
    0             0 FvwmAuto
   [31617.992372] [ 2986] 10230  2986    12803     2412      11       0    =
    0             0 FvwmPager
   [31617.992379] [ 2987] 10230  2987      581      145       3       0    =
    0             0 sh
   [31617.992386] [ 2988] 10230  2988     1063      703       4       0    =
    0             0 stalonetray
   [31617.992391] [ 3293] 10230  3293     2717     1591       6       0    =
    0             0 xterm
   [31617.992395] [ 3296] 10230  3296     2115     1420       5       0    =
    0             0 zsh
   [31617.992399] [ 3528] 10230  3528     3638     2452       7       0    =
    0             0 xterm
   [31617.992403] [ 3530] 10230  3530     2495     1325       6       0    =
    0             0 ssh
   [31617.992407] [ 3537]     0  3537     2866     1412       6       0    =
    0             0 sshd
   [31617.992411] [ 3541] 10230  3541     8278      817       8       0    =
    0             0 scdaemon
   [31617.992415] [ 3552] 10230  3552     2561      709       6       0    =
    0             0 ssh
   [31617.992419] [ 3555]     0  3555     2524     1850       7       0    =
    0             0 zsh
   [31617.992424] [ 4218] 10230  4218     2817     1648       6       0    =
    0             0 xterm
   [31617.992428] [ 4221] 10230  4221     2331     1647       5       0    =
    0             0 zsh
   [31617.992432] [16352] 10230 16352     2808     1618       6       0    =
    0             0 xterm
   [31617.992436] [16355] 10230 16355     2069     1379       6       0    =
    0             0 zsh
   [31617.992441] [ 7316]     0  7316      581      393       4       0    =
    0             0 battery-stats-c
   [31617.992445] [ 7425]     0  7425     7567     7069      11       0    =
    0         -1000 ulatencyd
   [31617.992450] [32214] 10230 32214    49046    17230      37       0    =
    0             0 psi-plus
   [31617.992454] [32249] 10230 32249   258814   125356     221       0    =
    0             0 firefox.real
   [31617.992458] [32456]     0 32456     1453      701       5       0    =
    0             0 top
   [31617.992464] [ 1858]     0  1858     2190      798       4       0    =
    0             0 wpa_supplicant
   [31617.992468] [ 1907]     0  1907     2026      180       4       0    =
    0             0 dhclient
   [31617.992472] [ 1937]     0  1937      581       16       4       0    =
    0             0 ntpdate
   [31617.992476] [ 1940]     0  1940      595      161       4       0    =
    0             0 flock
   [31617.992480] [ 1942]     0  1942     1353      666       5       0    =
    0             0 ntpdate
   [31617.992483] [ 1957] 65534  1957     2288     1441       5       0    =
    0             0 openvpn
   [31617.992487] [ 1965]   120  1965     8484     7507      12       0    =
    0             0 tor
   [31617.992491] [ 1974]     0  1974      557      143       4       0    =
    0             0 sleep
   [31617.992495] [ 2033] 10230  2033    45486     2635      27       0    =
    0             0 git
   [31617.992498] Out of memory: Kill process 32249 (firefox.real) score 96=
 or sacrifice child
   [31617.992590] Killed process 32249 (firefox.real) total-vm:1035256kB, a=
non-rss:407320kB, file-rss:87824kB, shmem-rss:6280kB
   [31618.087277] oom_reaper: reaped process 32249 (firefox.real), now anon=
-rss:0kB, file-rss:96kB, shmem-rss:6148kB

   [31626.627123] git invoked oom-killer: gfp_mask=3D0x2600840(GFP_NOFS|__G=
FP_NOFAIL|__GFP_NOTRACK), nodemask=3D0, order=3D0, oom_score_adj=3D0
   [31626.627126] git cpuset=3D/ mems_allowed=3D0
   [31626.627134] CPU: 1 PID: 2038 Comm: git Tainted: G     U     O    4.9.=
0 #1
   [31626.627137] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [31626.627140]  da8aba08 c12b4830 da8aba08 eb84f380 c113d7e1 da8ab974 00=
000206 c12b99df
   [31626.627148]  00000000 91b6f852 91b6f852 eb84f380 eb84f7ac c159e597 da=
8aba08 c10e9553
   [31626.627156]  00000000 f093d280 00000000 0013cfe0 c10e91fb 00000000 00=
000000 0000000d
   [31626.627163] Call Trace:
   [31626.627173]  [<c12b4830>] ? dump_stack+0x44/0x64
   [31626.627178]  [<c113d7e1>] ? dump_header+0x5d/0x1b7
   [31626.627182]  [<c12b99df>] ? ___ratelimit+0x8f/0xf0
   [31626.627187]  [<c10e9553>] ? oom_kill_process+0x203/0x3d0
   [31626.627190]  [<c10e91fb>] ? oom_badness.part.12+0xeb/0x160
   [31626.627194]  [<c10e99de>] ? out_of_memory+0xde/0x290
   [31626.627198]  [<c10ed690>] ? __alloc_pages_nodemask+0xba0/0xc50
   [31626.627203]  [<c112a532>] ? new_slab+0x322/0x480
   [31626.627208]  [<c14c039e>] ? __schedule+0x1be/0x590
   [31626.627211]  [<c112c002>] ? ___slab_alloc.constprop.78+0x472/0x5b0
   [31626.627215]  [<c14c079d>] ? schedule+0x2d/0x80
   [31626.627220]  [<c12024e9>] ? __alloc_extent_buffer+0x19/0xd0
   [31626.627225]  [<c10a26e4>] ? ktime_get+0x44/0x100
   [31626.627228]  [<c10cef67>] ? delayacct_end+0x37/0x70
   [31626.627232]  [<c14c01ba>] ? io_schedule_timeout+0xba/0xe0
   [31626.627236]  [<c11d4886>] ? verify_parent_transid+0x66/0x230
   [31626.627240]  [<c120ba27>] ? map_private_extent_buffer+0x57/0xd0
   [31626.627244]  [<c112c159>] ? __slab_alloc.isra.73.constprop.77+0x19/0x=
30
   [31626.627248]  [<c112c240>] ? kmem_cache_alloc+0xd0/0x100
   [31626.627251]  [<c12024e9>] ? __alloc_extent_buffer+0x19/0xd0
   [31626.627255]  [<c12024e9>] ? __alloc_extent_buffer+0x19/0xd0
   [31626.627258]  [<c120a362>] ? alloc_extent_buffer+0xa2/0x450
   [31626.627262]  [<c11feeb5>] ? btrfs_get_token_64+0x125/0x150
   [31626.627266]  [<c11d6052>] ? read_tree_block+0x12/0x50
   [31626.627270]  [<c11af405>] ? btrfs_release_path+0x15/0x80
   [31626.627273]  [<c11b21fb>] ? read_block_for_search.isra.32+0x14b/0x380
   [31626.627277]  [<c11b46b7>] ? btrfs_search_slot+0x937/0x950
   [31626.627281]  [<c11b73b4>] ? btrfs_next_old_leaf+0x234/0x430
   [31626.627284]  [<c11b75c7>] ? btrfs_next_leaf+0x17/0x20
   [31626.627290]  [<c126d88c>] ? btrfs_load_inode_props+0x9c/0x350
   [31626.627294]  [<c11ee2d3>] ? btrfs_iget+0x1c3/0x7d0
   [31626.627299]  [<c11cf9e9>] ? btrfs_match_dir_item_name+0xe9/0x110
   [31626.627303]  [<c11ef22f>] ? btrfs_lookup_dentry+0x47f/0x5d0
   [31626.627307]  [<c11ef388>] ? btrfs_lookup+0x8/0x40
   [31626.627311]  [<c114bade>] ? lookup_slow+0x7e/0x140
   [31626.627314]  [<c114cf94>] ? walk_component+0x1d4/0x300
   [31626.627317]  [<c114ac1a>] ? path_init+0x16a/0x360
   [31626.627321]  [<c114d641>] ? path_lookupat+0x51/0x100
   [31626.627324]  [<c114f9bc>] ? filename_lookup+0x8c/0x170
   [31626.627328]  [<c12bff28>] ? lockref_get+0x8/0x20
   [31626.627333]  [<c10c9567>] ? __audit_getname+0x77/0x90
   [31626.627336]  [<c114f69c>] ? getname_flags+0x8c/0x190
   [31626.627341]  [<c1145788>] ? vfs_fstatat+0x68/0xc0
   [31626.627344]  [<c11460c8>] ? SyS_lstat64+0x28/0x50
   [31626.627348]  [<c10c8db1>] ? audit_filter_inodes+0xc1/0x100
   [31626.627351]  [<c12bffdd>] ? lockref_put_or_lock+0x1d/0x30
   [31626.627355]  [<c1157c15>] ? dput+0xc5/0x250
   [31626.627359]  [<c115fc9d>] ? mntput_no_expire+0xd/0x180
   [31626.627362]  [<c10c9416>] ? __audit_syscall_exit+0x1d6/0x260
   [31626.627366]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [31626.627370]  [<c14c4762>] ? sysenter_past_esp+0x47/0x75
   [31626.627373] Mem-Info:
   [31626.627379] active_anon:33380 inactive_anon:12622 isolated_anon:0
   [31626.627379]  active_file:315871 inactive_file:108673 isolated_file:0
   [31626.627379]  unevictable:7117 dirty:7 writeback:0 unstable:0
   [31626.627379]  slab_reclaimable:42724 slab_unreclaimable:11239
   [31626.627379]  mapped:26211 shmem:7044 pagetables:506 bounce:0
   [31626.627379]  free:236761 free_pcp:199 free_cma:0
   [31626.627390] Node 0 active_anon:133520kB inactive_anon:50488kB active_=
file:1263484kB inactive_file:434692kB unevictable:28468kB isolated(anon):0k=
B isolated(file):0kB mapped:104844kB dirty:28kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 28176kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:3295193 all_unreclaimable? yes
   [31626.627398] DMA free:4116kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [31626.627410] Normal free:41928kB min:42416kB low:53020kB high:63624kB =
active_anon:1340kB inactive_anon:20004kB active_file:573156kB inactive_file=
:76kB unevictable:0kB writepending:28kB present:892920kB managed:854328kB m=
locked:0kB slab_reclaimable:161048kB slab_unreclaimable:44580kB kernel_stac=
k:2784kB pagetables:0kB bounce:0kB free_pcp:796kB local_pcp:152kB free_cma:=
0kB
   lowmem_reserve[]: 0 0 17397 17397
   [31626.627423] HighMem free:901000kB min:512kB low:28168kB high:55824kB =
active_anon:132180kB inactive_anon:30452kB active_file:688760kB inactive_fi=
le:434616kB unevictable:28468kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28468kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:2024kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cm=
a:0kB
   lowmem_reserve[]: 0 0 0 0
   [31626.627431] DMA: 1*4kB (U) 2*8kB (UE) 0*16kB 0*32kB 0*64kB 4*128kB (U=
E) 4*256kB (E) 3*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D 4116kB
   Normal: 594*4kB (UME) 572*8kB (UME) 122*16kB (UME) 324*32kB (ME) 162*64k=
B (ME) 50*128kB (ME) 21*256kB (UME) 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB =
=3D 41928kB
   HighMem: 8326*4kB (UM) 12102*8kB (UM) 7024*16kB (UM) 3442*32kB (UM) 1626=
*64kB (UM) 527*128kB (UM) 200*256kB (UM) 136*512kB (UM) 54*1024kB (UM) 32*2=
048kB (UM) 33*4096kB (M) =3D 901000kB
   434010 total pagecache pages
   [31626.627490] 217 pages in swap cache
   [31626.627493] Swap cache stats: add 6095, delete 5878, find 2283/2706
   [31626.627495] Free swap  =3D 2093256kB
   [31626.627497] Total swap =3D 2096476kB
   [31626.627499] 783948 pages RAM
   [31626.627501] 556722 pages HighMem/MovableOnly
   [31626.627502] 9667 pages reserved
   [31626.627504] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [31626.627510] [  216]     0   216     2929      818       5       0    =
    0         -1000 udevd
   [31626.627516] [ 1669]     0  1669     1232       45       5       0    =
    0             0 acpi_fakekeyd
   [31626.627520] [ 1685]     0  1685     3233      523       5       0    =
    0         -1000 auditd
   [31626.627524] [ 2024]     0  2024     7688      343       8       0    =
    0             0 lxcfs
   [31626.627528] [ 2053]     0  2053      558       18       4       0    =
    0             0 thinkfan
   [31626.627532] [ 2054]     0  2054      559      196       4       0    =
    0             0 startpar
   [31626.627536] [ 2056]     0  2056     7910      609       6       0    =
    0             0 rsyslogd
   [31626.627540] [ 2060]     0  2060     5413      142       6       0    =
    0             0 lvmetad
   [31626.627543] [ 2101]     0  2101      601       23       3       0    =
    0             0 uuidd
   [31626.627547] [ 2198]     0  2198      595      434       4       0    =
    0             0 acpid
   [31626.627551] [ 2281]     0  2281     2003     1047       5       0    =
    0             0 haveged
   [31626.627555] [ 2294]     8  2294     1058      633       4       0    =
    0             0 nullmailer-send
   [31626.627558] [ 2307]   103  2307     1108      658       4       0    =
    0             0 dbus-daemon
   [31626.627562] [ 2354]     0  2354     7111      502       7       0    =
    0             0 pcscd
   [31626.627566] [ 2459]     0  2459     1451      973       5       0    =
    0             0 bluetoothd
   [31626.627570] [ 2488]   124  2488      824      594       4       0    =
    0             0 ulogd
   [31626.627574] [ 2545]     0  2545     2129      726       4       0    =
    0         -1000 sshd
   [31626.627578] [ 2566]     0  2566     1460      580       6       0    =
    0             0 smartd
   [31626.627581] [ 2572]   110  2572     5360     2884       8       0    =
    0             0 unbound
   [31626.627585] [ 2626]     0  2626     8317     3717       9       0    =
    0             0 wicd
   [31626.627589] [ 2675]     0  2675     1406      608       5       0    =
    0             0 cron
   [31626.627593] [ 2703]   121  2703     9921      741       8       0    =
    0             0 privoxy
   [31626.627596] [ 2729]     0  2729     1511      571       5       0    =
    0             0 wdm
   [31626.627600] [ 2736]     0  2736     1511      603       5       0    =
    0             0 wdm
   [31626.627604] [ 2746]     0  2746    24513    10872      24       0    =
    0             0 Xorg
   [31626.627608] [ 2761]     0  2761     4975     3281       8       0    =
    0             0 wicd-monitor
   [31626.627611] [ 2827]     0  2827      553      132       4       0    =
    0             0 mingetty
   [31626.627615] [ 2833]     0  2833     1698     1013       5       0    =
    0             0 wdm
   [31626.627619] [ 2849] 10230  2849    13599     3304      11       0    =
    0             0 fvwm2
   [31626.627623] [ 2903] 10230  2903     1136      605       6       0    =
    0             0 dbus-launch
   [31626.627626] [ 2904] 10230  2904     1075      604       5       0    =
    0             0 dbus-daemon
   [31626.627630] [ 2921] 10230  2921     8450      409       8       0    =
    0             0 gpg-agent
   [31626.627634] [ 2925] 10230  2925     3957      730       5       0    =
    0             0 tpb
   [31626.627638] [ 2937] 10230  2937     2099     1271       6       0    =
    0             0 xscreensaver
   [31626.627642] [ 2939] 10230  2939     2937      633       7       0    =
    0             0 redshift
   [31626.627645] [ 2949] 10230  2949     1284      620       4       0    =
    0             0 autocutsel
   [31626.627649] [ 2956] 10230  2956    10940     5171      12       0    =
    0             0 gkrellm
   [31626.627653] [ 2958] 10230  2958    11297     8193      15       0    =
    0             0 wicd-client
   [31626.627657] [ 2980] 10230  2980     1047      301       5       0    =
    0             0 FvwmCommandS
   [31626.627661] [ 2981] 10230  2981     1528      451       5       0    =
    0             0 FvwmEvent
   [31626.627664] [ 2982] 10230  2982    12182     2117      10       0    =
    0             0 FvwmAnimate
   [31626.627668] [ 2983] 10230  2983    12808     2430      11       0    =
    0             0 FvwmButtons
   [31626.627672] [ 2984] 10230  2984    13311     2697      12       0    =
    0             0 FvwmProxy
   [31626.627676] [ 2985] 10230  2985     1507      406       5       0    =
    0             0 FvwmAuto
   [31626.627679] [ 2986] 10230  2986    12803     2412      11       0    =
    0             0 FvwmPager
   [31626.627683] [ 2987] 10230  2987      581      145       3       0    =
    0             0 sh
   [31626.627687] [ 2988] 10230  2988     1063      703       4       0    =
    0             0 stalonetray
   [31626.627691] [ 3293] 10230  3293     2717     1591       6       0    =
    0             0 xterm
   [31626.627694] [ 3296] 10230  3296     2115     1420       5       0    =
    0             0 zsh
   [31626.627698] [ 3528] 10230  3528     3638     2452       7       0    =
    0             0 xterm
   [31626.627702] [ 3530] 10230  3530     2495     1325       6       0    =
    0             0 ssh
   [31626.627705] [ 3537]     0  3537     2866     1412       6       0    =
    0             0 sshd
   [31626.627709] [ 3541] 10230  3541     8278      817       8       0    =
    0             0 scdaemon
   [31626.627713] [ 3552] 10230  3552     2561      709       6       0    =
    0             0 ssh
   [31626.627717] [ 3555]     0  3555     2524     1850       7       0    =
    0             0 zsh
   [31626.627721] [ 4218] 10230  4218     2817     1648       6       0    =
    0             0 xterm
   [31626.627725] [ 4221] 10230  4221     2331     1647       5       0    =
    0             0 zsh
   [31626.627729] [16352] 10230 16352     2808     1618       6       0    =
    0             0 xterm
   [31626.627733] [16355] 10230 16355     2069     1379       6       0    =
    0             0 zsh
   [31626.627737] [ 7316]     0  7316      581      393       4       0    =
    0             0 battery-stats-c
   [31626.627741] [ 7425]     0  7425     7567     7069      11       0    =
    0         -1000 ulatencyd
   [31626.627745] [32214] 10230 32214    49046    17230      37       0    =
    0             0 psi-plus
   [31626.627749] [32456]     0 32456     1453      701       5       0    =
    0             0 top
   [31626.627753] [ 1858]     0  1858     2190      798       4       0    =
    0             0 wpa_supplicant
   [31626.627757] [ 1907]     0  1907     2026      180       4       0    =
    0             0 dhclient
   [31626.627761] [ 1957] 65534  1957     2288     1441       5       0    =
    0             0 openvpn
   [31626.627765] [ 1965]   120  1965     8484     7507      12       0    =
    0             0 tor
   [31626.627769] [ 1974]     0  1974      557      143       4       0    =
    0             0 sleep
   [31626.627773] [ 2033] 10230  2033    45486     2635      27       0    =
    0             0 git
   [31626.627776] Out of memory: Kill process 32214 (psi-plus) score 13 or =
sacrifice child
   [31626.627796] Killed process 32214 (psi-plus) total-vm:196184kB, anon-r=
ss:27556kB, file-rss:40824kB, shmem-rss:540kB

   [31631.025619] git: page allocation stalls for 10085ms, order:0, mode:0x=
2400840(GFP_NOFS|__GFP_NOFAIL)
   [31631.025631] CPU: 1 PID: 2043 Comm: git Tainted: G     U     O    4.9.=
0 #1
   [31631.025634] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [31631.025638]  00000000 c12b4830 c15a0c38 00000000 c10eca5f c159e645 02=
400840 dcee9a7c
   [31631.025646]  dcee9a84 c15a0c38 dcee9a5c 9ff675c6 00000000 dcee9afc 00=
000000 c10ed528
   [31631.025653]  02400840 c15a0c38 00002765 00000000 00000000 00000000 00=
000000 00000001
   [31631.025661] Call Trace:
   [31631.025670]  [<c12b4830>] ? dump_stack+0x44/0x64
   [31631.025675]  [<c10eca5f>] ? warn_alloc+0xff/0x120
   [31631.025679]  [<c10ed528>] ? __alloc_pages_nodemask+0xa38/0xc50
   [31631.025684]  [<c10e5a2a>] ? pagecache_get_page+0xaa/0x250
   [31631.025689]  [<c1202563>] ? __alloc_extent_buffer+0x93/0xd0
   [31631.025694]  [<c120a3ff>] ? alloc_extent_buffer+0x13f/0x450
   [31631.025698]  [<c11d6052>] ? read_tree_block+0x12/0x50
   [31631.025702]  [<c11af405>] ? btrfs_release_path+0x15/0x80
   [31631.025705]  [<c11b21fb>] ? read_block_for_search.isra.32+0x14b/0x380
   [31631.025709]  [<c11b46b7>] ? btrfs_search_slot+0x937/0x950
   [31631.025713]  [<c11b73b4>] ? btrfs_next_old_leaf+0x234/0x430
   [31631.025717]  [<c11b75c7>] ? btrfs_next_leaf+0x17/0x20
   [31631.025722]  [<c126d88c>] ? btrfs_load_inode_props+0x9c/0x350
   [31631.025727]  [<c11ee2d3>] ? btrfs_iget+0x1c3/0x7d0
   [31631.025731]  [<c11cf9e9>] ? btrfs_match_dir_item_name+0xe9/0x110
   [31631.025735]  [<c11ef22f>] ? btrfs_lookup_dentry+0x47f/0x5d0
   [31631.025740]  [<c11ef388>] ? btrfs_lookup+0x8/0x40
   [31631.025744]  [<c114bade>] ? lookup_slow+0x7e/0x140
   [31631.025747]  [<c114cf94>] ? walk_component+0x1d4/0x300
   [31631.025750]  [<c114ac1a>] ? path_init+0x16a/0x360
   [31631.025754]  [<c114d641>] ? path_lookupat+0x51/0x100
   [31631.025757]  [<c114f9bc>] ? filename_lookup+0x8c/0x170
   [31631.025761]  [<c12bff28>] ? lockref_get+0x8/0x20
   [31631.025766]  [<c10c9567>] ? __audit_getname+0x77/0x90
   [31631.025769]  [<c114f69c>] ? getname_flags+0x8c/0x190
   [31631.025774]  [<c1145788>] ? vfs_fstatat+0x68/0xc0
   [31631.025777]  [<c11460c8>] ? SyS_lstat64+0x28/0x50
   [31631.025781]  [<c10c8db1>] ? audit_filter_inodes+0xc1/0x100
   [31631.025784]  [<c12bffdd>] ? lockref_put_or_lock+0x1d/0x30
   [31631.025788]  [<c1157c15>] ? dput+0xc5/0x250
   [31631.025792]  [<c115fc9d>] ? mntput_no_expire+0xd/0x180
   [31631.025796]  [<c10c9416>] ? __audit_syscall_exit+0x1d6/0x260
   [31631.025799]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [31631.025804]  [<c14c4762>] ? sysenter_past_esp+0x47/0x75
   [31631.025806] Mem-Info:
   [31631.025813] active_anon:26644 inactive_anon:12273 isolated_anon:160
   [31631.025813]  active_file:315747 inactive_file:107091 isolated_file:0
   [31631.025813]  unevictable:7117 dirty:1 writeback:0 unstable:0
   [31631.025813]  slab_reclaimable:42689 slab_unreclaimable:11234
   [31631.025813]  mapped:18660 shmem:6847 pagetables:478 bounce:0
   [31631.025813]  free:245651 free_pcp:59 free_cma:0
   [31631.025824] Node 0 active_anon:106576kB inactive_anon:49092kB active_=
file:1262988kB inactive_file:428364kB unevictable:28468kB isolated(anon):64=
0kB isolated(file):0kB mapped:74640kB dirty:4kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 27388kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:1687443 all_unreclaimable? no
   [31631.025831] DMA free:4116kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [31631.025844] Normal free:42392kB min:42416kB low:53020kB high:63624kB =
active_anon:1340kB inactive_anon:19080kB active_file:573844kB inactive_file=
:56kB unevictable:0kB writepending:4kB present:892920kB managed:854328kB ml=
ocked:0kB slab_reclaimable:160908kB slab_unreclaimable:44560kB kernel_stack=
:2752kB pagetables:0kB bounce:0kB free_pcp:236kB local_pcp:120kB free_cma:0=
kB
   lowmem_reserve[]: 0 0 17397 17397
   [31631.025856] HighMem free:936096kB min:512kB low:28168kB high:55824kB =
active_anon:105236kB inactive_anon:29908kB active_file:687576kB inactive_fi=
le:428308kB unevictable:28468kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28468kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:1912kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cm=
a:0kB
   lowmem_reserve[]: 0 0 0 0
   [31631.025864] DMA: 1*4kB (U) 2*8kB (UE) 0*16kB 0*32kB 0*64kB 4*128kB (U=
E) 4*256kB (E) 3*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D 4116kB
   Normal: 688*4kB (UME) 571*8kB (UME) 106*16kB (ME) 335*32kB (ME) 162*64kB=
 (ME) 50*128kB (ME) 21*256kB (UME) 1*512kB (M) 0*1024kB 0*2048kB 0*4096kB =
=3D 42392kB
   HighMem: 14584*4kB (UM) 12694*8kB (UM) 7111*16kB (UM) 3455*32kB (UM) 165=
3*64kB (UM) 531*128kB (UM) 201*256kB (UM) 138*512kB (UM) 54*1024kB (UM) 32*=
2048kB (UM) 33*4096kB (M) =3D 936096kB
   432098 total pagecache pages
   [31631.025923] 208 pages in swap cache
   [31631.025926] Swap cache stats: add 6336, delete 6128, find 2357/2807
   [31631.025928] Free swap  =3D 2093040kB
   [31631.025930] Total swap =3D 2096476kB
   [31631.025932] 783948 pages RAM
   [31631.025934] 556722 pages HighMem/MovableOnly
   [31631.025936] 9667 pages reserved

   [31638.530097] git invoked oom-killer: gfp_mask=3D0x2400840(GFP_NOFS|__G=
FP_NOFAIL), nodemask=3D0, order=3D0, oom_score_adj=3D0
   [31638.530101] git cpuset=3D/ mems_allowed=3D0
   [31638.530109] CPU: 1 PID: 2036 Comm: git Tainted: G     U     O    4.9.=
0 #1
   [31638.530111] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [31638.530115]  dce85afc c12b4830 dce85afc f36e6300 c113d7e1 dce85a68 00=
000206 c12b99df
   [31638.530122]  00000000 7f101eae 7f101eae f36e6300 f36e672c c159e597 dc=
e85afc c10e9553
   [31638.530130]  00000000 f093d280 00000000 0013cfe0 c10e91fb 00000000 00=
000000 00000008
   [31638.530137] Call Trace:
   [31638.530146]  [<c12b4830>] ? dump_stack+0x44/0x64
   [31638.530152]  [<c113d7e1>] ? dump_header+0x5d/0x1b7
   [31638.530156]  [<c12b99df>] ? ___ratelimit+0x8f/0xf0
   [31638.530160]  [<c10e9553>] ? oom_kill_process+0x203/0x3d0
   [31638.530164]  [<c10e91fb>] ? oom_badness.part.12+0xeb/0x160
   [31638.530168]  [<c10e99de>] ? out_of_memory+0xde/0x290
   [31638.530171]  [<c10ed690>] ? __alloc_pages_nodemask+0xba0/0xc50
   [31638.530177]  [<c10e5a2a>] ? pagecache_get_page+0xaa/0x250
   [31638.530181]  [<c1202563>] ? __alloc_extent_buffer+0x93/0xd0
   [31638.530185]  [<c120a3ff>] ? alloc_extent_buffer+0x13f/0x450
   [31638.530190]  [<c11d6052>] ? read_tree_block+0x12/0x50
   [31638.530194]  [<c11af405>] ? btrfs_release_path+0x15/0x80
   [31638.530198]  [<c11b21fb>] ? read_block_for_search.isra.32+0x14b/0x380
   [31638.530201]  [<c11b46b7>] ? btrfs_search_slot+0x937/0x950
   [31638.530205]  [<c11b73b4>] ? btrfs_next_old_leaf+0x234/0x430
   [31638.530209]  [<c11b75c7>] ? btrfs_next_leaf+0x17/0x20
   [31638.530214]  [<c126d88c>] ? btrfs_load_inode_props+0x9c/0x350
   [31638.530219]  [<c11ee2d3>] ? btrfs_iget+0x1c3/0x7d0
   [31638.530223]  [<c11cf9e9>] ? btrfs_match_dir_item_name+0xe9/0x110
   [31638.530227]  [<c11ef22f>] ? btrfs_lookup_dentry+0x47f/0x5d0
   [31638.530232]  [<c11ef388>] ? btrfs_lookup+0x8/0x40
   [31638.530235]  [<c114bade>] ? lookup_slow+0x7e/0x140
   [31638.530239]  [<c114cf94>] ? walk_component+0x1d4/0x300
   [31638.530242]  [<c114ac1a>] ? path_init+0x16a/0x360
   [31638.530246]  [<c114d641>] ? path_lookupat+0x51/0x100
   [31638.530249]  [<c114f9bc>] ? filename_lookup+0x8c/0x170
   [31638.530253]  [<c12bff28>] ? lockref_get+0x8/0x20
   [31638.530257]  [<c10c9567>] ? __audit_getname+0x77/0x90
   [31638.530261]  [<c114f69c>] ? getname_flags+0x8c/0x190
   [31638.530265]  [<c1145788>] ? vfs_fstatat+0x68/0xc0
   [31638.530269]  [<c11460c8>] ? SyS_lstat64+0x28/0x50
   [31638.530273]  [<c10c8db1>] ? audit_filter_inodes+0xc1/0x100
   [31638.530276]  [<c12bffdd>] ? lockref_put_or_lock+0x1d/0x30
   [31638.530279]  [<c1157c15>] ? dput+0xc5/0x250
   [31638.530283]  [<c115fc9d>] ? mntput_no_expire+0xd/0x180
   [31638.530287]  [<c10c9416>] ? __audit_syscall_exit+0x1d6/0x260
   [31638.530291]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [31638.530296]  [<c14c4762>] ? sysenter_past_esp+0x47/0x75
   [31638.530298] Mem-Info:
   [31638.530305] active_anon:26483 inactive_anon:12469 isolated_anon:0
   [31638.530305]  active_file:314265 inactive_file:103275 isolated_file:0
   [31638.530305]  unevictable:7117 dirty:0 writeback:0 unstable:0
   [31638.530305]  slab_reclaimable:42517 slab_unreclaimable:11233
   [31638.530305]  mapped:18660 shmem:6895 pagetables:469 bounce:0
   [31638.530305]  free:251271 free_pcp:60 free_cma:0
   [31638.530315] Node 0 active_anon:105932kB inactive_anon:49876kB active_=
file:1257060kB inactive_file:413100kB unevictable:28468kB isolated(anon):0k=
B isolated(file):0kB mapped:74640kB dirty:0kB writeback:0kB shmem:0kB shmem=
_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 27580kB writeback_tmp:0kB unstable=
:0kB pages_scanned:3111372 all_unreclaimable? yes
   [31638.530322] DMA free:4116kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [31638.530335] Normal free:42388kB min:42416kB low:53020kB high:63624kB =
active_anon:1340kB inactive_anon:19968kB active_file:574424kB inactive_file=
:88kB unevictable:0kB writepending:0kB present:892920kB managed:854328kB ml=
ocked:0kB slab_reclaimable:160220kB slab_unreclaimable:44556kB kernel_stack=
:2744kB pagetables:0kB bounce:0kB free_pcp:240kB local_pcp:120kB free_cma:0=
kB
   lowmem_reserve[]: 0 0 17397 17397
   [31638.530347] HighMem free:958580kB min:512kB low:28168kB high:55824kB =
active_anon:104592kB inactive_anon:29908kB active_file:681068kB inactive_fi=
le:413012kB unevictable:28468kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28468kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:1876kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cm=
a:0kB
   lowmem_reserve[]: 0 0 0 0
   [31638.530355] DMA: 1*4kB (U) 2*8kB (UE) 0*16kB 0*32kB 0*64kB 4*128kB (U=
E) 4*256kB (E) 3*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D 4116kB
   Normal: 625*4kB (UME) 562*8kB (ME) 108*16kB (UME) 345*32kB (UME) 167*64k=
B (UME) 51*128kB (UME) 21*256kB (UME) 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 42356kB
   HighMem: 15917*4kB (UM) 13408*8kB (UM) 7374*16kB (UM) 3559*32kB (UM) 170=
2*64kB (UM) 533*128kB (UM) 201*256kB (UM) 137*512kB (UM) 53*1024kB (UM) 31*=
2048kB (UM) 34*4096kB (M) =3D 958580kB
   426847 total pagecache pages
   [31638.530413] 207 pages in swap cache
   [31638.530416] Swap cache stats: add 6663, delete 6456, find 2500/2989
   [31638.530418] Free swap  =3D 2093200kB
   [31638.530420] Total swap =3D 2096476kB
   [31638.530422] 783948 pages RAM
   [31638.530424] 556722 pages HighMem/MovableOnly
   [31638.530426] 9667 pages reserved
   [31638.530428] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [31638.530434] [  216]     0   216     2929      818       5       0    =
    0         -1000 udevd
   [31638.530439] [ 1669]     0  1669     1232       45       5       0    =
    0             0 acpi_fakekeyd
   [31638.530444] [ 1685]     0  1685     3233      523       5       0    =
    0         -1000 auditd
   [31638.530448] [ 2024]     0  2024     7688      343       8       0    =
    0             0 lxcfs
   [31638.530451] [ 2053]     0  2053      558       18       4       0    =
    0             0 thinkfan
   [31638.530455] [ 2054]     0  2054      559      196       4       0    =
    0             0 startpar
   [31638.530459] [ 2056]     0  2056     7910      609       6       0    =
    0             0 rsyslogd
   [31638.530463] [ 2060]     0  2060     5413      142       6       0    =
    0             0 lvmetad
   [31638.530467] [ 2101]     0  2101      601       23       3       0    =
    0             0 uuidd
   [31638.530470] [ 2198]     0  2198      595      434       4       0    =
    0             0 acpid
   [31638.530474] [ 2281]     0  2281     2003     1047       5       0    =
    0             0 haveged
   [31638.530478] [ 2294]     8  2294     1058      633       4       0    =
    0             0 nullmailer-send
   [31638.530482] [ 2307]   103  2307     1108      658       4       0    =
    0             0 dbus-daemon
   [31638.530486] [ 2354]     0  2354     7111      502       7       0    =
    0             0 pcscd
   [31638.530489] [ 2459]     0  2459     1451      973       5       0    =
    0             0 bluetoothd
   [31638.530493] [ 2488]   124  2488      824      594       4       0    =
    0             0 ulogd
   [31638.530497] [ 2545]     0  2545     2129      726       4       0    =
    0         -1000 sshd
   [31638.530501] [ 2566]     0  2566     1460      580       6       0    =
    0             0 smartd
   [31638.530505] [ 2572]   110  2572     5360     2884       8       0    =
    0             0 unbound
   [31638.530509] [ 2626]     0  2626     8317     3717       9       0    =
    0             0 wicd
   [31638.530512] [ 2675]     0  2675     1406      608       5       0    =
    0             0 cron
   [31638.530516] [ 2703]   121  2703     9921      741       8       0    =
    0             0 privoxy
   [31638.530520] [ 2729]     0  2729     1511      571       5       0    =
    0             0 wdm
   [31638.530524] [ 2736]     0  2736     1511      603       5       0    =
    0             0 wdm
   [31638.530528] [ 2746]     0  2746    24378    10737      24       0    =
    0             0 Xorg
   [31638.530532] [ 2761]     0  2761     4975     3281       8       0    =
    0             0 wicd-monitor
   [31638.530535] [ 2827]     0  2827      553      132       4       0    =
    0             0 mingetty
   [31638.530539] [ 2833]     0  2833     1698     1013       5       0    =
    0             0 wdm
   [31638.530543] [ 2849] 10230  2849    13599     3304      11       0    =
    0             0 fvwm2
   [31638.530547] [ 2903] 10230  2903     1136      605       6       0    =
    0             0 dbus-launch
   [31638.530550] [ 2904] 10230  2904     1075      604       5       0    =
    0             0 dbus-daemon
   [31638.530554] [ 2921] 10230  2921     8450      409       8       0    =
    0             0 gpg-agent
   [31638.530558] [ 2925] 10230  2925     3957      730       5       0    =
    0             0 tpb
   [31638.530562] [ 2937] 10230  2937     2099     1271       6       0    =
    0             0 xscreensaver
   [31638.530566] [ 2939] 10230  2939     2937      633       7       0    =
    0             0 redshift
   [31638.530570] [ 2949] 10230  2949     1284      620       4       0    =
    0             0 autocutsel
   [31638.530574] [ 2956] 10230  2956    10940     5171      12       0    =
    0             0 gkrellm
   [31638.530578] [ 2958] 10230  2958    11297     8193      15       0    =
    0             0 wicd-client
   [31638.530582] [ 2980] 10230  2980     1047      301       5       0    =
    0             0 FvwmCommandS
   [31638.530585] [ 2981] 10230  2981     1528      451       5       0    =
    0             0 FvwmEvent
   [31638.530589] [ 2982] 10230  2982    12182     2117      10       0    =
    0             0 FvwmAnimate
   [31638.530593] [ 2983] 10230  2983    12808     2430      11       0    =
    0             0 FvwmButtons
   [31638.530597] [ 2984] 10230  2984    13311     2697      12       0    =
    0             0 FvwmProxy
   [31638.530601] [ 2985] 10230  2985     1507      406       5       0    =
    0             0 FvwmAuto
   [31638.530605] [ 2986] 10230  2986    12803     2412      11       0    =
    0             0 FvwmPager
   [31638.530609] [ 2987] 10230  2987      581      145       3       0    =
    0             0 sh
   [31638.530613] [ 2988] 10230  2988     1063      703       4       0    =
    0             0 stalonetray
   [31638.530616] [ 3293] 10230  3293     2717     1591       6       0    =
    0             0 xterm
   [31638.530620] [ 3296] 10230  3296     2115     1420       5       0    =
    0             0 zsh
   [31638.530624] [ 3528] 10230  3528     3638     2452       7       0    =
    0             0 xterm
   [31638.530628] [ 3530] 10230  3530     2495     1325       6       0    =
    0             0 ssh
   [31638.530631] [ 3537]     0  3537     2866     1412       6       0    =
    0             0 sshd
   [31638.530635] [ 3541] 10230  3541     8278      817       8       0    =
    0             0 scdaemon
   [31638.530639] [ 3552] 10230  3552     2561      709       6       0    =
    0             0 ssh
   [31638.530643] [ 3555]     0  3555     2524     1850       7       0    =
    0             0 zsh
   [31638.530647] [ 4218] 10230  4218     2817     1648       6       0    =
    0             0 xterm
   [31638.530651] [ 4221] 10230  4221     2331     1647       5       0    =
    0             0 zsh
   [31638.530655] [16352] 10230 16352     2808     1618       6       0    =
    0             0 xterm
   [31638.530658] [16355] 10230 16355     2069     1379       6       0    =
    0             0 zsh
   [31638.530663] [ 7316]     0  7316      581      393       4       0    =
    0             0 battery-stats-c
   [31638.530666] [ 7425]     0  7425     7567     7069      11       0    =
    0         -1000 ulatencyd
   [31638.530670] [32456]     0 32456     1453      701       5       0    =
    0             0 top
   [31638.530675] [ 1858]     0  1858     2190      798       4       0    =
    0             0 wpa_supplicant
   [31638.530678] [ 1907]     0  1907     2026      180       4       0    =
    0             0 dhclient
   [31638.530682] [ 1957] 65534  1957     2288     1441       5       0    =
    0             0 openvpn
   [31638.530686] [ 1965]   120  1965     8484     7507      12       0    =
    0             0 tor
   [31638.530690] [ 1974]     0  1974      557      143       4       0    =
    0             0 sleep
   [31638.530693] [ 2033] 10230  2033    45486     2635      27       0    =
    0             0 git
   [31638.530696] Out of memory: Kill process 2746 (Xorg) score 8 or sacrif=
ice child
   [31638.530706] Killed process 2746 (Xorg) total-vm:97512kB, anon-rss:264=
84kB, file-rss:15300kB, shmem-rss:1164kB
   [31638.537455] oom_reaper: reaped process 2746 (Xorg), now anon-rss:0kB,=
 file-rss:0kB, shmem-rss:1164kB

   [31638.619661] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), nodemask=3D0, order=3D0, oom_score_adj=3D0
   [31638.619667] Xorg cpuset=3D/ mems_allowed=3D0
   [31638.619675] CPU: 1 PID: 2746 Comm: Xorg Tainted: G     U     O    4.9=
=2E0 #1
   [31638.619678] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [31638.619681]  f2c25a1c c12b4830 f2c25a1c f36e7380 c113d7e1 f2c25988 00=
000206 c12b99df
   [31638.619689]  f44bd31c 0001dcce 4e78dcce f36e7380 f36e77ac c159e597 f2=
c25a1c c10e9553
   [31638.619697]  00000000 f093d280 00000000 0013cfe0 c10e91fb 00000000 00=
000000 00000006
   [31638.619704] Call Trace:
   [31638.619713]  [<c12b4830>] ? dump_stack+0x44/0x64
   [31638.619719]  [<c113d7e1>] ? dump_header+0x5d/0x1b7
   [31638.619723]  [<c12b99df>] ? ___ratelimit+0x8f/0xf0
   [31638.619727]  [<c10e9553>] ? oom_kill_process+0x203/0x3d0
   [31638.619731]  [<c10e91fb>] ? oom_badness.part.12+0xeb/0x160
   [31638.619735]  [<c10e99de>] ? out_of_memory+0xde/0x290
   [31638.619739]  [<c10ed72c>] ? __alloc_pages_nodemask+0xc3c/0xc50
   [31638.619743]  [<c106e838>] ? update_curr+0x58/0xf0
   [31638.619748]  [<c111f747>] ? __read_swap_cache_async+0x117/0x1d0
   [31638.619752]  [<c111f825>] ? read_swap_cache_async+0x25/0x50
   [31638.619756]  [<c111f92b>] ? swapin_readahead+0xdb/0x180
   [31638.619760]  [<c10fd30b>] ? shmem_getpage_gfp+0x8ab/0xbb0
   [31638.619765]  [<c14c079d>] ? schedule+0x2d/0x80
   [31638.619769]  [<c14c194f>] ? wait_for_completion+0xbf/0xe0
   [31638.619773]  [<c10fd652>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [31638.619806]  [<f893ca21>] ? i915_gem_object_get_pages_gtt+0x1e1/0x3d0=
 [i915]
   [31638.619830]  [<f89374b1>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [31638.619853]  [<f893d265>] ? i915_gem_object_get_pages+0x35/0xb0 [i915]
   [31638.619877]  [<f893f207>] ? __i915_vma_do_pin+0x117/0x6b0 [i915]
   [31638.619901]  [<f89305de>] ? i915_gem_execbuffer_reserve_vma.isra.36+0=
x15e/0x1f0 [i915]
   [31638.619924]  [<f8930a7b>] ? i915_gem_execbuffer_reserve.isra.37+0x40b=
/0x440 [i915]
   [31638.619948]  [<f8932431>] ? i915_gem_do_execbuffer.isra.40+0x5d1/0x11=
d0 [i915]
   [31638.619953]  [<c113d739>] ? __check_object_size+0xd9/0x124
   [31638.619956]  [<c113d739>] ? __check_object_size+0xd9/0x124
   [31638.619979]  [<f8933485>] ? i915_gem_execbuffer2+0x95/0x230 [i915]
   [31638.620002]  [<f89333f0>] ? i915_gem_execbuffer+0x3c0/0x3c0 [i915]
   [31638.620012]  [<f824d666>] ? drm_ioctl+0x1c6/0x400 [drm]
   [31638.620012]  [<f89333f0>] ? i915_gem_execbuffer+0x3c0/0x3c0 [i915]
   [31638.620012]  [<f824d4a0>] ? drm_getunique+0x60/0x60 [drm]
   [31638.620012]  [<c115354f>] ? do_vfs_ioctl+0x8f/0x780
   [31638.620012]  [<c10c91de>] ? __audit_syscall_entry+0xae/0x110
   [31638.620012]  [<c10011b3>] ? syscall_trace_enter+0x183/0x200
   [31638.620012]  [<c10c8db1>] ? audit_filter_inodes+0xc1/0x100
   [31638.620012]  [<c10c88b5>] ? audit_filter_syscall+0xa5/0xd0
   [31638.620012]  [<c115d671>] ? __fget+0x61/0xb0
   [31638.620012]  [<c1153c6e>] ? SyS_ioctl+0x2e/0x50
   [31638.620012]  [<c10014e9>] ? do_fast_syscall_32+0x79/0x130
   [31638.620012]  [<c14c4762>] ? sysenter_past_esp+0x47/0x75
   [31638.623187] Mem-Info:
   [31638.623195] active_anon:20008 inactive_anon:12217 isolated_anon:96
   [31638.623195]  active_file:314290 inactive_file:103275 isolated_file:0
   [31638.623195]  unevictable:7117 dirty:0 writeback:0 unstable:0
   [31638.623195]  slab_reclaimable:42517 slab_unreclaimable:11233
   [31638.623195]  mapped:16260 shmem:6895 pagetables:469 bounce:0
   [31638.623195]  free:257430 free_pcp:456 free_cma:0
   [31638.623206] Node 0 active_anon:80032kB inactive_anon:48868kB active_f=
ile:1257160kB inactive_file:413100kB unevictable:28468kB isolated(anon):384=
kB isolated(file):0kB mapped:65040kB dirty:0kB writeback:0kB shmem:0kB shme=
m_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 27580kB writeback_tmp:0kB unstabl=
e:0kB pages_scanned:1652269 all_unreclaimable? no
   [31638.623214] DMA free:4116kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:1568kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:9848kB slab_unreclaimable:376kB kernel_stack:0kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   lowmem_reserve[]: 0 833 3008 3008
   [31638.623227] Normal free:42348kB min:42416kB low:53020kB high:63624kB =
active_anon:388kB inactive_anon:19600kB active_file:574560kB inactive_file:=
88kB unevictable:0kB writepending:0kB present:892920kB managed:854328kB mlo=
cked:0kB slab_reclaimable:160220kB slab_unreclaimable:44556kB kernel_stack:=
2744kB pagetables:0kB bounce:0kB free_pcp:1072kB local_pcp:836kB free_cma:0=
kB
   lowmem_reserve[]: 0 0 17397 17397
   [31638.623239] HighMem free:983256kB min:512kB low:28168kB high:55824kB =
active_anon:79692kB inactive_anon:29408kB active_file:681068kB inactive_fil=
e:413012kB unevictable:28468kB writepending:0kB present:2226888kB managed:2=
226888kB mlocked:28468kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel=
_stack:0kB pagetables:1876kB bounce:0kB free_pcp:752kB local_pcp:628kB free=
_cma:0kB
   lowmem_reserve[]: 0 0 0 0
   [31638.623247] DMA: 1*4kB (U) 2*8kB (UE) 0*16kB 0*32kB 0*64kB 4*128kB (U=
E) 4*256kB (E) 3*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D 4116kB
   Normal: 655*4kB (UME) 554*8kB (UME) 110*16kB (UME) 342*32kB (UME) 167*64=
kB (UME) 51*128kB (UME) 21*256kB (UME) 0*512kB 0*1024kB 0*2048kB 0*4096kB =
=3D 42348kB
   HighMem: 16488*4kB (UM) 13685*8kB (UM) 7559*16kB (UM) 3655*32kB (UM) 174=
9*64kB (UM) 554*128kB (UM) 212*256kB (UM) 142*512kB (UM) 56*1024kB (UM) 31*=
2048kB (UM) 34*4096kB (M) =3D 983256kB
   426884 total pagecache pages
   [31638.623306] 207 pages in swap cache
   [31638.623309] Swap cache stats: add 6663, delete 6456, find 2500/2989
   [31638.623311] Free swap  =3D 2093200kB
   [31638.623313] Total swap =3D 2096476kB
   [31638.623315] 783948 pages RAM
   [31638.623317] 556722 pages HighMem/MovableOnly
   [31638.623319] 9667 pages reserved
   [31638.623321] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [31638.623327] [  216]     0   216     2929      818       5       0    =
    0         -1000 udevd
   [31638.623333] [ 1669]     0  1669     1232       45       5       0    =
    0             0 acpi_fakekeyd
   [31638.623337] [ 1685]     0  1685     3233      523       5       0    =
    0         -1000 auditd
   [31638.623342] [ 2024]     0  2024     7688      343       8       0    =
    0             0 lxcfs
   [31638.623346] [ 2053]     0  2053      558       18       4       0    =
    0             0 thinkfan
   [31638.623350] [ 2054]     0  2054      559      196       4       0    =
    0             0 startpar
   [31638.623353] [ 2056]     0  2056     7910      609       6       0    =
    0             0 rsyslogd
   [31638.623357] [ 2060]     0  2060     5413      142       6       0    =
    0             0 lvmetad
   [31638.623361] [ 2101]     0  2101      601       23       3       0    =
    0             0 uuidd
   [31638.623365] [ 2198]     0  2198      595      434       4       0    =
    0             0 acpid
   [31638.623368] [ 2281]     0  2281     2003     1047       5       0    =
    0             0 haveged
   [31638.623372] [ 2294]     8  2294     1058      633       4       0    =
    0             0 nullmailer-send
   [31638.623376] [ 2307]   103  2307     1108      658       4       0    =
    0             0 dbus-daemon
   [31638.623380] [ 2354]     0  2354     7111      502       7       0    =
    0             0 pcscd
   [31638.623384] [ 2459]     0  2459     1451      973       5       0    =
    0             0 bluetoothd
   [31638.623387] [ 2488]   124  2488      824      594       4       0    =
    0             0 ulogd
   [31638.623392] [ 2545]     0  2545     2129      726       4       0    =
    0         -1000 sshd
   [31638.623395] [ 2566]     0  2566     1460      580       6       0    =
    0             0 smartd
   [31638.623399] [ 2572]   110  2572     5360     2884       8       0    =
    0             0 unbound
   [31638.623403] [ 2626]     0  2626     8317     3717       9       0    =
    0             0 wicd
   [31638.623407] [ 2675]     0  2675     1406      608       5       0    =
    0             0 cron
   [31638.623411] [ 2703]   121  2703     9921      741       8       0    =
    0             0 privoxy
   [31638.623415] [ 2729]     0  2729     1511      571       5       0    =
    0             0 wdm
   [31638.623418] [ 2736]     0  2736     1511      603       5       0    =
    0             0 wdm
   [31638.623423] [ 2746]     0  2746    24378      291      24       0    =
    0             0 Xorg
   [31638.623426] [ 2761]     0  2761     4975     3281       8       0    =
    0             0 wicd-monitor
   [31638.623430] [ 2827]     0  2827      553      132       4       0    =
    0             0 mingetty
   [31638.623434] [ 2833]     0  2833     1698     1013       5       0    =
    0             0 wdm
   [31638.623438] [ 2849] 10230  2849    13599     3304      11       0    =
    0             0 fvwm2
   [31638.623442] [ 2903] 10230  2903     1136      605       6       0    =
    0             0 dbus-launch
   [31638.623446] [ 2904] 10230  2904     1075      604       5       0    =
    0             0 dbus-daemon
   [31638.623450] [ 2921] 10230  2921     8450      409       8       0    =
    0             0 gpg-agent
   [31638.623454] [ 2925] 10230  2925     3957      730       5       0    =
    0             0 tpb
   [31638.623458] [ 2937] 10230  2937     2099     1271       6       0    =
    0             0 xscreensaver
   [31638.623462] [ 2939] 10230  2939     2937      633       7       0    =
    0             0 redshift
   [31638.623466] [ 2949] 10230  2949     1284      620       4       0    =
    0             0 autocutsel
   [31638.623469] [ 2956] 10230  2956    10940     5171      12       0    =
    0             0 gkrellm
   [31638.623473] [ 2958] 10230  2958    11297     8193      15       0    =
    0             0 wicd-client
   [31638.623477] [ 2980] 10230  2980     1047      301       5       0    =
    0             0 FvwmCommandS
   [31638.623481] [ 2981] 10230  2981     1528      451       5       0    =
    0             0 FvwmEvent
   [31638.623485] [ 2982] 10230  2982    12182     2117      10       0    =
    0             0 FvwmAnimate
   [31638.623489] [ 2983] 10230  2983    12808     2430      11       0    =
    0             0 FvwmButtons
   [31638.623493] [ 2984] 10230  2984    13311     2697      12       0    =
    0             0 FvwmProxy
   [31638.623497] [ 2985] 10230  2985     1507      406       5       0    =
    0             0 FvwmAuto
   [31638.623501] [ 2986] 10230  2986    12803     2412      11       0    =
    0             0 FvwmPager
   [31638.623505] [ 2987] 10230  2987      581      145       3       0    =
    0             0 sh
   [31638.623509] [ 2988] 10230  2988     1063      703       4       0    =
    0             0 stalonetray
   [31638.623513] [ 3293] 10230  3293     2717     1591       6       0    =
    0             0 xterm
   [31638.623516] [ 3296] 10230  3296     2115     1420       5       0    =
    0             0 zsh
   [31638.623520] [ 3528] 10230  3528     3638     2452       7       0    =
    0             0 xterm
   [31638.623524] [ 3530] 10230  3530     2495     1325       6       0    =
    0             0 ssh
   [31638.623528] [ 3537]     0  3537     2866     1412       6       0    =
    0             0 sshd
   [31638.623532] [ 3541] 10230  3541     8278      817       8       0    =
    0             0 scdaemon
   [31638.623535] [ 3552] 10230  3552     2561      709       6       0    =
    0             0 ssh
   [31638.623539] [ 3555]     0  3555     2524     1850       7       0    =
    0             0 zsh
   [31638.623544] [ 4218] 10230  4218     2817     1648       6       0    =
    0             0 xterm
   [31638.623548] [ 4221] 10230  4221     2331     1647       5       0    =
    0             0 zsh
   [31638.623551] [16352] 10230 16352     2808     1618       6       0    =
    0             0 xterm
   [31638.623555] [16355] 10230 16355     2069     1379       6       0    =
    0             0 zsh
   [31638.623559] [ 7316]     0  7316      581      393       4       0    =
    0             0 battery-stats-c
   [31638.623564] [ 7425]     0  7425     7567     7069      11       0    =
    0         -1000 ulatencyd
   [31638.623568] [32456]     0 32456     1453      701       5       0    =
    0             0 top
   [31638.623572] [ 1858]     0  1858     2190      798       4       0    =
    0             0 wpa_supplicant
   [31638.623576] [ 1907]     0  1907     2026      180       4       0    =
    0             0 dhclient
   [31638.623580] [ 1957] 65534  1957     2288     1441       5       0    =
    0             0 openvpn
   [31638.623584] [ 1965]   120  1965     8484     7507      12       0    =
    0             0 tor
   [31638.623588] [ 1974]     0  1974      557      143       4       0    =
    0             0 sleep
   [31638.623592] [ 2033] 10230  2033    45486     2635      27       0    =
    0             0 git
   [31638.623595] Out of memory: Kill process 2958 (wicd-client) score 6 or=
 sacrifice child
   [31638.623606] Killed process 2958 (wicd-client) total-vm:45188kB, anon-=
rss:8900kB, file-rss:23496kB, shmem-rss:376kB


   [47073.478113] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47073.478116] Xorg cpuset=3D/ mems_allowed=3D0
   [47073.478125] CPU: 0 PID: 2631 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47073.478127] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47073.478131]  00000286 8d0bfcbf c12b1260 f3741ba0 f0a5ca40 c113c257 c1=
5933a0 f3b78be4
   [47073.478139]  024200d4 f3741bac 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47073.478146]  f447d0d8 00018840 f0a5ca40 f0a5ce6c c15910eb f3741ba0 c1=
0e7b4e c105fe23
   [47073.478153] Call Trace:
   [47073.478163]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47073.478168]  [<c113c257>] ? dump_header+0x43/0x19f
   [47073.478172]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47073.478177]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47073.478181]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47073.478185]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47073.478189]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47073.478193]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47073.478197]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47073.478202]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47073.478205]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47073.478208]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47073.478212]  [<c10fcd6b>] ? shmem_truncate_range+0x3b/0x70
   [47073.478246]  [<f888d09d>] ? i915_gem_object_truncate+0x2d/0x50 [i915]
   [47073.478271]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47073.478275]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47073.478299]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47073.478303]  [<c1159100>] ? inode_init_always+0xd0/0x160
   [47073.478327]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47073.478348]  [<f88720a9>] ? intel_runtime_pm_get+0x19/0xa0 [i915]
   [47073.478360]  [<f80869e8>] ? drm_gem_object_lookup+0x48/0x90 [drm]
   [47073.478384]  [<f88949b3>] ? i915_gem_pwrite_ioctl+0x803/0xcc0 [i915]
   [47073.478388]  [<c12b1dc9>] ? idr_mark_full+0x49/0x60
   [47073.478392]  [<c112c2c4>] ? __check_heap_object+0x54/0xa0
   [47073.478396]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47073.478399]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47073.478424]  [<f88dc89f>] ? intel_frontbuffer_flush+0x2f/0x70 [i915]
   [47073.478435]  [<f8094da9>] ? drm_mode_dirtyfb_ioctl+0x159/0x180 [drm]
   [47073.478439]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47073.478442]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47073.478451]  [<f80869e8>] ? drm_gem_object_lookup+0x48/0x90 [drm]
   [47073.478475]  [<f88941b0>] ? i915_gem_pread_ioctl+0x940/0x940 [i915]
   [47073.478484]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47073.478509]  [<f88941b0>] ? i915_gem_pread_ioctl+0x940/0x940 [i915]
   [47073.478513]  [<c106e419>] ? task_tick_fair+0x469/0xd80
   [47073.478523]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47073.478526]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47073.478530]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47073.478534]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47073.478538]  [<c115bec1>] ? __fget+0x61/0xb0
   [47073.478541]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47073.478544]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47073.478549]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47073.478551] Mem-Info:
   [47073.478558] active_anon:102174 inactive_anon:63513 isolated_anon:0
   [47073.478558]  active_file:315076 inactive_file:158931 isolated_file:0
   [47073.478558]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47073.478558]  slab_reclaimable:41926 slab_unreclaimable:11510
   [47073.478558]  mapped:52152 shmem:10692 pagetables:777 bounce:0
   [47073.478558]  free:67706 free_pcp:459 free_cma:0
   [47073.478569] Node 0 active_anon:408696kB inactive_anon:254052kB active=
_file:1260304kB inactive_file:635724kB unevictable:28564kB isolated(anon):0=
kB isolated(file):0kB mapped:208608kB dirty:0kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 42768kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:7264420 all_unreclaimable? yes
   [47073.478576] DMA free:4020kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:8096kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:3496kB slab_unreclaimable:288kB kernel_stack:8kB pagetables:0kB bounc=
e:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47073.478579] lowmem_reserve[]: 0 833 3008 3008
   [47073.478589] Normal free:42372kB min:42416kB low:53020kB high:63624kB =
active_anon:208kB inactive_anon:21208kB active_file:568680kB inactive_file:=
28kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:164208kB slab_unreclaimable:45752kB kernel_stack:=
2904kB pagetables:0kB bounce:0kB free_pcp:940kB local_pcp:380kB free_cma:0kB
   [47073.478591] lowmem_reserve[]: 0 0 17397 17397
   [47073.478601] HighMem free:224432kB min:512kB low:28164kB high:55816kB =
active_anon:408488kB inactive_anon:232804kB active_file:683608kB inactive_f=
ile:635696kB unevictable:28564kB writepending:0kB present:2226888kB managed=
:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kern=
el_stack:0kB pagetables:3108kB bounce:0kB free_pcp:896kB local_pcp:176kB fr=
ee_cma:0kB
   [47073.478603] lowmem_reserve[]: 0 0 0 0
   [47073.478608] DMA: 1*4kB (U) 0*8kB 1*16kB (U) 3*32kB (UE) 3*64kB (UE) 1=
*128kB (E) 2*256kB (UE) 2*512kB (U) 2*1024kB (U) 0*2048kB 0*4096kB =3D 4020=
kB
   [47073.478628] Normal: 241*4kB (ME) 142*8kB (UME) 57*16kB (UME) 35*32kB =
(ME) 35*64kB (UM) 27*128kB (UME) 33*256kB (UME) 13*512kB (UME) 7*1024kB (ME=
) 3*2048kB (E) 1*4096kB (E) =3D 42340kB
   [47073.478648] HighMem: 2605*4kB (UM) 389*8kB (UM) 668*16kB (UM) 869*32k=
B (UM) 863*64kB (UM) 314*128kB (UM) 31*256kB (UM) 19*512kB (M) 20*1024kB (M=
) 7*2048kB (M) 6*4096kB (UM) =3D 224508kB
   [47073.478668] 486900 total pagecache pages
   [47073.478671] 0 pages in swap cache
   [47073.478673] Swap cache stats: add 327, delete 327, find 23/27
   [47073.478676] Free swap  =3D 2095796kB
   [47073.478677] Total swap =3D 2096476kB
   [47073.478679] 783948 pages RAM
   [47073.478681] 556722 pages HighMem/MovableOnly
   [47073.478683] 9664 pages reserved
   [47073.478685] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47073.478691] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47073.478696] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47073.478700] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47073.478704] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47073.478707] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47073.478711] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47073.478714] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47073.478718] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47073.478721] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47073.478725] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47073.478729] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47073.478732] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47073.478736] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47073.478740] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47073.478743] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47073.478747] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47073.478750] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47073.478754] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47073.478757] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47073.478761] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47073.478764] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47073.478768] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47073.478771] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47073.478775] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47073.478778] [ 2631]     0  2631    28211    14371      27       0    =
    0             0 Xorg
   [47073.478782] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47073.478786] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47073.478789] [ 2738]     0  2738     1698     1040       4       0    =
    0             0 wdm
   [47073.478792] [ 2757] 10230  2757    13743     3418      11       0    =
    0             0 fvwm2
   [47073.478796] [ 2811] 10230  2811     1136       55       5       0    =
    0             0 dbus-launch
   [47073.478799] [ 2812] 10230  2812     1075      614       4       0    =
    0             0 dbus-daemon
   [47073.478803] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47073.478806] [ 2834] 10230  2834     3957      753       6       0    =
    0             0 tpb
   [47073.478810] [ 2846] 10230  2846     2098     1226       6       0    =
    0             0 xscreensaver
   [47073.478814] [ 2848] 10230  2848     2937      598       6       0    =
    0             0 redshift
   [47073.478817] [ 2855] 10230  2855     1284      620       5       0    =
    0             0 autocutsel
   [47073.478820] [ 2865] 10230  2865    10946     5203      11       0    =
    0             0 gkrellm
   [47073.478824] [ 2866] 10230  2866    54835    20730      43       0    =
    0             0 psi-plus
   [47073.478828] [ 2868] 10230  2868    12297     9287      14       0    =
    0             0 wicd-client
   [47073.478831] [ 2890] 10230  2890     1047      303       5       0    =
    0             0 FvwmCommandS
   [47073.478835] [ 2891] 10230  2891     1528      459       4       0    =
    0             0 FvwmEvent
   [47073.478838] [ 2892] 10230  2892    12182     2034      10       0    =
    0             0 FvwmAnimate
   [47073.478842] [ 2893] 10230  2893    12808     2435      11       0    =
    0             0 FvwmButtons
   [47073.478845] [ 2894] 10230  2894    13311     2718      11       0    =
    0             0 FvwmProxy
   [47073.478849] [ 2895] 10230  2895     1507      406       5       0    =
    0             0 FvwmAuto
   [47073.478852] [ 2896] 10230  2896    12803     2412      11       0    =
    0             0 FvwmPager
   [47073.478856] [ 2897] 10230  2897      581      153       4       0    =
    0             0 sh
   [47073.478859] [ 2898] 10230  2898     1063      671       4       0    =
    0             0 stalonetray
   [47073.478863] [ 2917] 10230  2917     2719     1558       6       0    =
    0             0 xterm
   [47073.478866] [ 2923] 10230  2923     1902     1257       5       0    =
    0             0 zsh
   [47073.478870] [ 3391] 10230  3391   284524   141883     246       0    =
    0             0 firefox.real
   [47073.478874] [ 5842] 10230  5842     3582     2437       7       0    =
    0             0 xterm
   [47073.478877] [ 5843] 10230  5843     2495     1306       6       0    =
    0             0 ssh
   [47073.478881] [ 5850]     0  5850     2900     1417       6       0    =
    0             0 sshd
   [47073.478884] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47073.478887] [ 5942] 10230  5942     2529      664       6       0    =
    0             0 ssh
   [47073.478891] [ 5947]     0  5947     2146     1488       6       0    =
    0             0 zsh
   [47073.478895] [ 6863] 10230  6863     2789     1656       5       0    =
    0             0 xterm
   [47073.478898] [ 6867] 10230  6867     2115     1472       5       0    =
    0             0 zsh
   [47073.478902] [22662] 10230 22662     1420      692       5       0    =
    0             0 top
   [47073.478906] [24073] 10230 24073     1073      715       5       0    =
    0             0 xsnow
   [47073.478909] [ 2746] 10230  2746     2027     1087       5       0    =
    0             0 xfconfd
   [47073.478913] [ 6589] 10230  6589     2815     1667       6       0    =
    0             0 xterm
   [47073.478916] [ 6592] 10230  6592     2050     1407       6       0    =
    0             0 zsh
   [47073.478920] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47073.478924] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47073.478927] [31386] 10230 31386     2815     1686       6       0    =
    0             0 xterm
   [47073.478931] [31389] 10230 31389     1981     1324       5       0    =
    0             0 zsh
   [47073.478934] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47073.478938] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47073.478941] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47073.478945] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47073.478948] [ 6096]     0  6096      557      147       4       0    =
    0             0 sleep
   [47073.478952] [ 6133] 10230  6133    45486     2618      26       0    =
    0             0 git
   [47073.478955] Out of memory: Kill process 3391 (firefox.real) score 109=
 or sacrifice child
   [47073.479075] Killed process 3391 (firefox.real) total-vm:1138096kB, an=
on-rss:452696kB, file-rss:100612kB, shmem-rss:14224kB

   [47075.299507] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47075.299509] Xorg cpuset=3D/ mems_allowed=3D0
   [47075.299518] CPU: 0 PID: 2631 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47075.299521] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47075.299524]  00003286 8d0bfcbf c12b1260 f3741c18 f3d94a40 c113c257 c1=
5933a0 f3b78be4
   [47075.299532]  024200d4 f3741c24 00000000 00000000 00000000 00003206 c1=
2b63ef 00000000
   [47075.299539]  f447d0d8 00018840 f3d94a40 f3d94e6c c15910eb f3741c18 c1=
0e7b4e c105fe23
   [47075.299546] Call Trace:
   [47075.299555]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47075.299560]  [<c113c257>] ? dump_header+0x43/0x19f
   [47075.299564]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47075.299570]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47075.299574]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47075.299578]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47075.299582]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47075.299586]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47075.299589]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47075.299594]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47075.299597]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47075.299601]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47075.299633]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47075.299637]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47075.299661]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47075.299685]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47075.299709]  [<f8891147>] ? i915_gem_object_set_to_gtt_domain+0x37/0x=
100 [i915]
   [47075.299732]  [<f88912a4>] ? i915_gem_set_domain_ioctl+0x94/0x110 [i91=
5]
   [47075.299756]  [<f8891210>] ? i915_gem_object_set_to_gtt_domain+0x100/0=
x100 [i915]
   [47075.299768]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47075.299773]  [<c1042c3a>] ? kmap_atomic+0xa/0x10
   [47075.299797]  [<f8891210>] ? i915_gem_object_set_to_gtt_domain+0x100/0=
x100 [i915]
   [47075.299802]  [<c1135349>] ? get_mem_cgroup_from_mm+0x69/0xd0
   [47075.299805]  [<c1139a12>] ? memcg_kmem_get_cache+0x72/0x160
   [47075.299809]  [<c1111b60>] ? vma_link+0x60/0xb0
   [47075.299813]  [<c1112905>] ? vma_set_page_prot+0x25/0x50
   [47075.299816]  [<c1114131>] ? mmap_region+0x161/0x540
   [47075.299826]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47075.299830]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47075.299834]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47075.299838]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47075.299841]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47075.299844]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47075.299848]  [<c115bec1>] ? __fget+0x61/0xb0
   [47075.299851]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47075.299854]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47075.299859]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47075.299861] Mem-Info:
   [47075.299868] active_anon:34988 inactive_anon:13521 isolated_anon:32
   [47075.299868]  active_file:316472 inactive_file:158234 isolated_file:0
   [47075.299868]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47075.299868]  slab_reclaimable:41479 slab_unreclaimable:11454
   [47075.299868]  mapped:28141 shmem:7139 pagetables:529 bounce:0
   [47075.299868]  free:185346 free_pcp:96 free_cma:0
   [47075.299878] Node 0 active_anon:139952kB inactive_anon:54084kB active_=
file:1265888kB inactive_file:632936kB unevictable:28564kB isolated(anon):12=
8kB isolated(file):0kB mapped:112564kB dirty:0kB writeback:0kB shmem:0kB sh=
mem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 28556kB writeback_tmp:0kB unsta=
ble:0kB pages_scanned:3473003 all_unreclaimable? yes
   [47075.299885] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:352kB active_file:9228kB inactive_file:16kB unevictabl=
e:0kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_rec=
laimable:1744kB slab_unreclaimable:320kB kernel_stack:24kB pagetables:0kB b=
ounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47075.299888] lowmem_reserve[]: 0 833 3008 3008
   [47075.299898] Normal free:42348kB min:42416kB low:53020kB high:63624kB =
active_anon:208kB inactive_anon:20504kB active_file:570396kB inactive_file:=
40kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:164172kB slab_unreclaimable:45496kB kernel_stack:=
2512kB pagetables:0kB bounce:0kB free_pcp:384kB local_pcp:160kB free_cma:0kB
   [47075.299901] lowmem_reserve[]: 0 0 17397 17397
   [47075.299910] HighMem free:694968kB min:512kB low:28164kB high:55816kB =
active_anon:139744kB inactive_anon:33108kB active_file:686204kB inactive_fi=
le:632880kB unevictable:28564kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:2116kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cm=
a:0kB
   [47075.299913] lowmem_reserve[]: 0 0 0 0
   [47075.299918] DMA: 1*4kB (E) 0*8kB 0*16kB 0*32kB 3*64kB (E) 4*128kB (UE=
) 3*256kB (E) 1*512kB (E) 2*1024kB (U) 0*2048kB 0*4096kB =3D 4036kB
   [47075.299935] Normal: 219*4kB (UME) 186*8kB (UME) 76*16kB (UME) 36*32kB=
 (UME) 24*64kB (UME) 28*128kB (UME) 33*256kB (UME) 13*512kB (UME) 7*1024kB =
(ME) 3*2048kB (E) 1*4096kB (E) =3D 42364kB
   [47075.299956] HighMem: 20312*4kB (UM) 8369*8kB (UM) 4665*16kB (UM) 2648=
*32kB (UM) 2059*64kB (UM) 695*128kB (UM) 173*256kB (UM) 57*512kB (M) 35*102=
4kB (M) 14*2048kB (M) 7*4096kB (UM) =3D 694968kB
   [47075.299975] 484064 total pagecache pages
   [47075.299978] 3 pages in swap cache
   [47075.299981] Swap cache stats: add 550, delete 547, find 149/167
   [47075.299983] Free swap  =3D 2095800kB
   [47075.299985] Total swap =3D 2096476kB
   [47075.299987] 783948 pages RAM
   [47075.299989] 556722 pages HighMem/MovableOnly
   [47075.299990] 9664 pages reserved
   [47075.299992] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47075.299998] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47075.300003] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47075.300032] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47075.300036] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47075.300039] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47075.300043] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47075.300047] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47075.300050] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47075.300054] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47075.300057] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47075.300061] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47075.300064] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47075.300068] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47075.300072] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47075.300075] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47075.300079] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47075.300082] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47075.300086] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47075.300089] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47075.300093] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47075.300096] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47075.300100] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47075.300103] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47075.300107] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47075.300110] [ 2631]     0  2631    24729    10836      25       0    =
    0             0 Xorg
   [47075.300114] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47075.300117] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47075.300121] [ 2738]     0  2738     1698     1040       4       0    =
    0             0 wdm
   [47075.300124] [ 2757] 10230  2757    13743     3418      11       0    =
    0             0 fvwm2
   [47075.300128] [ 2811] 10230  2811     1136       55       5       0    =
    0             0 dbus-launch
   [47075.300131] [ 2812] 10230  2812     1075      614       4       0    =
    0             0 dbus-daemon
   [47075.300135] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47075.300138] [ 2834] 10230  2834     3957      753       6       0    =
    0             0 tpb
   [47075.300142] [ 2846] 10230  2846     2098     1226       6       0    =
    0             0 xscreensaver
   [47075.300145] [ 2848] 10230  2848     2937      598       6       0    =
    0             0 redshift
   [47075.300149] [ 2855] 10230  2855     1284      620       5       0    =
    0             0 autocutsel
   [47075.300152] [ 2865] 10230  2865    10946     5203      11       0    =
    0             0 gkrellm
   [47075.300156] [ 2866] 10230  2866    54835    20730      43       0    =
    0             0 psi-plus
   [47075.300160] [ 2868] 10230  2868    12297     9287      14       0    =
    0             0 wicd-client
   [47075.300163] [ 2890] 10230  2890     1047      303       5       0    =
    0             0 FvwmCommandS
   [47075.300167] [ 2891] 10230  2891     1528      459       4       0    =
    0             0 FvwmEvent
   [47075.300170] [ 2892] 10230  2892    12182     2034      10       0    =
    0             0 FvwmAnimate
   [47075.300174] [ 2893] 10230  2893    12808     2435      11       0    =
    0             0 FvwmButtons
   [47075.300177] [ 2894] 10230  2894    13311     2718      11       0    =
    0             0 FvwmProxy
   [47075.300181] [ 2895] 10230  2895     1507      406       5       0    =
    0             0 FvwmAuto
   [47075.300184] [ 2896] 10230  2896    12803     2412      11       0    =
    0             0 FvwmPager
   [47075.300188] [ 2897] 10230  2897      581      153       4       0    =
    0             0 sh
   [47075.300191] [ 2898] 10230  2898     1063      671       4       0    =
    0             0 stalonetray
   [47075.300195] [ 2917] 10230  2917     2719     1558       6       0    =
    0             0 xterm
   [47075.300198] [ 2923] 10230  2923     1902     1257       5       0    =
    0             0 zsh
   [47075.300202] [ 5842] 10230  5842     3582     2437       7       0    =
    0             0 xterm
   [47075.300205] [ 5843] 10230  5843     2495     1306       6       0    =
    0             0 ssh
   [47075.300209] [ 5850]     0  5850     2900     1417       6       0    =
    0             0 sshd
   [47075.300212] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47075.300216] [ 5942] 10230  5942     2529      664       6       0    =
    0             0 ssh
   [47075.300219] [ 5947]     0  5947     2146     1488       6       0    =
    0             0 zsh
   [47075.300223] [ 6863] 10230  6863     2789     1656       5       0    =
    0             0 xterm
   [47075.300226] [ 6867] 10230  6867     2115     1472       5       0    =
    0             0 zsh
   [47075.300230] [22662] 10230 22662     1420      692       5       0    =
    0             0 top
   [47075.300234] [24073] 10230 24073     1073      715       5       0    =
    0             0 xsnow
   [47075.300237] [ 2746] 10230  2746     2027     1087       5       0    =
    0             0 xfconfd
   [47075.300241] [ 6589] 10230  6589     2815     1667       6       0    =
    0             0 xterm
   [47075.300244] [ 6592] 10230  6592     2050     1407       6       0    =
    0             0 zsh
   [47075.300248] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47075.300252] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47075.300255] [31386] 10230 31386     2815     1686       6       0    =
    0             0 xterm
   [47075.300259] [31389] 10230 31389     1981     1324       5       0    =
    0             0 zsh
   [47075.300262] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47075.300266] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47075.300269] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47075.300273] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47075.300277] [ 6096]     0  6096      557      147       4       0    =
    0             0 sleep
   [47075.300280] [ 6133] 10230  6133    45486     2618      26       0    =
    0             0 git
   [47075.300283] Out of memory: Kill process 2866 (psi-plus) score 15 or s=
acrifice child
   [47075.300302] Killed process 2866 (psi-plus) total-vm:219340kB, anon-rs=
s:35880kB, file-rss:45448kB, shmem-rss:1592kB
   [47075.307337] oom_reaper: reaped process 2866 (psi-plus), now anon-rss:=
0kB, file-rss:0kB, shmem-rss:1592kB

   [47078.629212] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47078.629215] Xorg cpuset=3D/ mems_allowed=3D0
   [47078.629224] CPU: 1 PID: 2631 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47078.629226] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47078.629229]  00000286 8d0bfcbf c12b1260 f37419f0 f3b78840 c113c257 c1=
5933a0 f3b78be4
   [47078.629237]  024200d4 f37419fc 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47078.629245]  f447d0d8 00018840 f3b78840 f3b78c6c c15910eb f37419f0 c1=
0e7b4e c105fe23
   [47078.629252] Call Trace:
   [47078.629260]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47078.629266]  [<c113c257>] ? dump_header+0x43/0x19f
   [47078.629270]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47078.629275]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47078.629279]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47078.629283]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47078.629287]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47078.629291]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47078.629294]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47078.629300]  [<c111e117>] ? __read_swap_cache_async+0x107/0x1d0
   [47078.629303]  [<c111e205>] ? read_swap_cache_async+0x25/0x50
   [47078.629307]  [<c111e35a>] ? swapin_readahead+0x12a/0x180
   [47078.629310]  [<c10e3d7e>] ? pagecache_get_page+0x1e/0x250
   [47078.629314]  [<c10fb8eb>] ? shmem_getpage_gfp+0x8ab/0xbb0
   [47078.629319]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47078.629349]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47078.629374]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47078.629378]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47078.629402]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47078.629424]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47078.629448]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47078.629472]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47078.629496]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47078.629519]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47078.629542]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47078.629565]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47078.629589]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47078.629593]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47078.629596]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47078.629619]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47078.629642]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47078.629654]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47078.629659]  [<c1042c3a>] ? kmap_atomic+0xa/0x10
   [47078.629663]  [<c110dd48>] ? __get_locked_pte+0x68/0x90
   [47078.629685]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47078.629695]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47078.629699]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47078.629704]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47078.629707]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47078.629710]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47078.629714]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47078.629717]  [<c115bec1>] ? __fget+0x61/0xb0
   [47078.629721]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47078.629724]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47078.629728]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47078.629731] Mem-Info:
   [47078.629737] active_anon:26345 inactive_anon:12547 isolated_anon:64
   [47078.629737]  active_file:305838 inactive_file:144596 isolated_file:0
   [47078.629737]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47078.629737]  slab_reclaimable:38693 slab_unreclaimable:11040
   [47078.629737]  mapped:19695 shmem:6536 pagetables:486 bounce:0
   [47078.629737]  free:222470 free_pcp:107 free_cma:0
   [47078.629748] Node 0 active_anon:105380kB inactive_anon:50188kB active_=
file:1223352kB inactive_file:578384kB unevictable:28564kB isolated(anon):25=
6kB isolated(file):0kB mapped:78780kB dirty:0kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 26144kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:3011309 all_unreclaimable? yes
   [47078.629755] DMA free:4032kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:8kB active_file:9716kB inactive_file:16kB unevictable:=
0kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_recla=
imable:1776kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB bou=
nce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47078.629758] lowmem_reserve[]: 0 833 3008 3008
   [47078.629768] Normal free:42304kB min:42416kB low:53020kB high:63624kB =
active_anon:204kB inactive_anon:20308kB active_file:583512kB inactive_file:=
52kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:152996kB slab_unreclaimable:43824kB kernel_stack:=
2472kB pagetables:0kB bounce:0kB free_pcp:428kB local_pcp:428kB free_cma:0kB
   [47078.629771] lowmem_reserve[]: 0 0 17397 17397
   [47078.629781] HighMem free:843544kB min:512kB low:28164kB high:55816kB =
active_anon:105176kB inactive_anon:29824kB active_file:630196kB inactive_fi=
le:578316kB unevictable:28564kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:1944kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cm=
a:0kB
   [47078.629783] lowmem_reserve[]: 0 0 0 0
   [47078.629788] DMA: 6*4kB (E) 7*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB (U=
E) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =3D=
 4032kB
   [47078.629808] Normal: 298*4kB (ME) 264*8kB (UME) 77*16kB (ME) 169*32kB =
(ME) 64*64kB (UME) 45*128kB (ME) 32*256kB (ME) 10*512kB (ME) 7*1024kB (UME)=
 1*2048kB (E) 0*4096kB =3D 42328kB
   [47078.629827] HighMem: 25839*4kB (UM) 12666*8kB (UM) 6307*16kB (UM) 318=
8*32kB (UM) 2239*64kB (UM) 777*128kB (UM) 209*256kB (UM) 73*512kB (M) 38*10=
24kB (M) 15*2048kB (M) 8*4096kB (UM) =3D 843644kB
   [47078.629847] 459194 total pagecache pages
   [47078.629850] 8 pages in swap cache
   [47078.629853] Swap cache stats: add 4257, delete 4249, find 1627/1984
   [47078.629855] Free swap  =3D 2095704kB
   [47078.629857] Total swap =3D 2096476kB
   [47078.629859] 783948 pages RAM
   [47078.629861] 556722 pages HighMem/MovableOnly
   [47078.629863] 9664 pages reserved
   [47078.629864] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47078.629870] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47078.629875] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47078.629879] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47078.629883] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47078.629887] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47078.629891] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47078.629894] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47078.629898] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47078.629901] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47078.629905] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47078.629909] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47078.629912] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47078.629916] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47078.629920] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47078.629923] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47078.629927] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47078.629930] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47078.629934] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47078.629938] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47078.629941] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47078.629945] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47078.629948] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47078.629952] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47078.629955] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47078.629959] [ 2631]     0  2631    24099    10393      25       0    =
    0             0 Xorg
   [47078.629963] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47078.629966] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47078.629970] [ 2738]     0  2738     1698     1040       4       0    =
    0             0 wdm
   [47078.629973] [ 2757] 10230  2757    13743     3418      11       0    =
    0             0 fvwm2
   [47078.629977] [ 2811] 10230  2811     1136       55       5       0    =
    0             0 dbus-launch
   [47078.629980] [ 2812] 10230  2812     1075      614       4       0    =
    0             0 dbus-daemon
   [47078.629984] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47078.629987] [ 2834] 10230  2834     3957      753       6       0    =
    0             0 tpb
   [47078.629991] [ 2846] 10230  2846     2098     1226       6       0    =
    0             0 xscreensaver
   [47078.629994] [ 2848] 10230  2848     2937      598       6       0    =
    0             0 redshift
   [47078.629998] [ 2855] 10230  2855     1284      620       5       0    =
    0             0 autocutsel
   [47078.645578] [ 2865] 10230  2865    10946     5203      11       0    =
    0             0 gkrellm
   [47078.645584] [ 2868] 10230  2868    12297     9287      14       0    =
    0             0 wicd-client
   [47078.645589] [ 2890] 10230  2890     1047      303       5       0    =
    0             0 FvwmCommandS
   [47078.645593] [ 2891] 10230  2891     1528      459       4       0    =
    0             0 FvwmEvent
   [47078.645597] [ 2892] 10230  2892    12182     2034      10       0    =
    0             0 FvwmAnimate
   [47078.645601] [ 2893] 10230  2893    12808     2435      11       0    =
    0             0 FvwmButtons
   [47078.645605] [ 2894] 10230  2894    13311     2718      11       0    =
    0             0 FvwmProxy
   [47078.645609] [ 2895] 10230  2895     1507      406       5       0    =
    0             0 FvwmAuto
   [47078.645613] [ 2896] 10230  2896    12803     2412      11       0    =
    0             0 FvwmPager
   [47078.645617] [ 2897] 10230  2897      581      153       4       0    =
    0             0 sh
   [47078.645621] [ 2898] 10230  2898     1063      671       4       0    =
    0             0 stalonetray
   [47078.645625] [ 2917] 10230  2917     2719     1558       6       0    =
    0             0 xterm
   [47078.645629] [ 2923] 10230  2923     1902     1257       5       0    =
    0             0 zsh
   [47078.645633] [ 5842] 10230  5842     3582     2437       7       0    =
    0             0 xterm
   [47078.645636] [ 5843] 10230  5843     2495     1306       6       0    =
    0             0 ssh
   [47078.645641] [ 5850]     0  5850     2900     1417       6       0    =
    0             0 sshd
   [47078.645644] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47078.645648] [ 5942] 10230  5942     2529      664       6       0    =
    0             0 ssh
   [47078.645652] [ 5947]     0  5947     2146     1488       6       0    =
    0             0 zsh
   [47078.645658] [ 6863] 10230  6863     2789     1656       5       0    =
    0             0 xterm
   [47078.645662] [ 6867] 10230  6867     2115     1472       5       0    =
    0             0 zsh
   [47078.645666] [22662] 10230 22662     1420      692       5       0    =
    0             0 top
   [47078.645670] [24073] 10230 24073     1073      715       5       0    =
    0             0 xsnow
   [47078.645673] [ 2746] 10230  2746     2027     1087       5       0    =
    0             0 xfconfd
   [47078.645677] [ 6589] 10230  6589     2815     1667       6       0    =
    0             0 xterm
   [47078.645681] [ 6592] 10230  6592     2050     1407       6       0    =
    0             0 zsh
   [47078.645685] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47078.645690] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47078.645694] [31386] 10230 31386     2815     1686       6       0    =
    0             0 xterm
   [47078.645698] [31389] 10230 31389     1981     1324       5       0    =
    0             0 zsh
   [47078.645702] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47078.645706] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47078.645710] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47078.645714] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47078.645718] [ 6096]     0  6096      557      147       4       0    =
    0             0 sleep
   [47078.645722] [ 6133] 10230  6133    45486     2618      26       0    =
    0             0 git
   [47078.646829] Out of memory: Kill process 2631 (Xorg) score 7 or sacrif=
ice child
   [47078.646841] Killed process 2631 (Xorg) total-vm:96396kB, anon-rss:245=
60kB, file-rss:15536kB, shmem-rss:1476kB
   [47078.655080] oom_reaper: reaped process 2631 (Xorg), now anon-rss:0kB,=
 file-rss:0kB, shmem-rss:1476kB
   [47082.009172] oom_reaper: reaped process 6147 (git), now anon-rss:0kB, =
file-rss:0kB, shmem-rss:0kB

   [47195.138905] git invoked oom-killer: gfp_mask=3D0x2400840(GFP_NOFS|__G=
FP_NOFAIL), order=3D0, oom_score_adj=3D0
   [47195.138907] git cpuset=3D/ mems_allowed=3D0
   [47195.138916] CPU: 0 PID: 6893 Comm: git Tainted: G     U     O    4.8.=
15 #1
   [47195.138919] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47195.138922]  00000286 f789519d c12b1260 c1825ae4 f369f380 c113c257 c1=
5933a0 d67b3d64
   [47195.138930]  02400840 c1825af0 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47195.138937]  f447d0d8 010139c0 f369f380 f369f7ac c15910eb c1825ae4 c1=
0e7b4e c105fe23
   [47195.138945] Call Trace:
   [47195.138953]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47195.138958]  [<c113c257>] ? dump_header+0x43/0x19f
   [47195.138962]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47195.138967]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47195.138971]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47195.138975]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47195.138979]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47195.138983]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47195.138987]  [<c10eba31>] ? __alloc_pages_nodemask+0xa71/0xb30
   [47195.138991]  [<c10e3e0a>] ? pagecache_get_page+0xaa/0x250
   [47195.138995]  [<c11ffb73>] ? __alloc_extent_buffer+0x93/0xd0
   [47195.138999]  [<c1207ccf>] ? alloc_extent_buffer+0x13f/0x450
   [47195.139004]  [<c11d3972>] ? read_tree_block+0x12/0x50
   [47195.139008]  [<c11acd95>] ? btrfs_release_path+0x15/0x80
   [47195.139012]  [<c11afbcb>] ? read_block_for_search.isra.32+0x14b/0x3b0
   [47195.139014]  [<c11b4db4>] ? btrfs_next_old_leaf+0x234/0x430
   [47195.139014]  [<c11b4fc7>] ? btrfs_next_leaf+0x17/0x20
   [47195.139014]  [<c126a2fc>] ? btrfs_load_inode_props+0x9c/0x350
   [47195.139014]  [<c11eb983>] ? btrfs_iget+0x1c3/0x7d0
   [47195.139014]  [<c11cd2d9>] ? btrfs_match_dir_item_name+0xe9/0x110
   [47195.139014]  [<c11ec8df>] ? btrfs_lookup_dentry+0x47f/0x5d0
   [47195.139014]  [<c11eca38>] ? btrfs_lookup+0x8/0x40
   [47195.139014]  [<c114a37e>] ? lookup_slow+0x7e/0x140
   [47195.139014]  [<c114b834>] ? walk_component+0x1d4/0x300
   [47195.139014]  [<c114949a>] ? path_init+0x16a/0x360
   [47195.139014]  [<c114bf01>] ? path_lookupat+0x51/0x100
   [47195.139014]  [<c114e2fc>] ? filename_lookup+0x8c/0x170
   [47195.139014]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47195.139014]  [<c12bc954>] ? _copy_to_user+0x34/0x50
   [47195.139014]  [<c12bcb58>] ? lockref_get+0x8/0x20
   [47195.139014]  [<c10c7a07>] ? __audit_getname+0x77/0x90
   [47195.139014]  [<c114dfdc>] ? getname_flags+0x8c/0x190
   [47195.139014]  [<c11440d8>] ? vfs_fstatat+0x68/0xc0
   [47195.139014]  [<c1144a18>] ? SyS_lstat64+0x28/0x50
   [47195.139014]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47195.139014]  [<c12bcc0d>] ? lockref_put_or_lock+0x1d/0x30
   [47195.139014]  [<c11565e5>] ? dput+0xd5/0x280
   [47195.139014]  [<c115e4ed>] ? mntput_no_expire+0xd/0x180
   [47195.139014]  [<c10c78b6>] ? __audit_syscall_exit+0x1d6/0x260
   [47195.139014]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47195.139014]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47195.139142] Mem-Info:
   [47195.139153] active_anon:31420 inactive_anon:8443 isolated_anon:0
   [47195.139153]  active_file:300314 inactive_file:130742 isolated_file:0
   [47195.139153]  unevictable:7141 dirty:36 writeback:0 unstable:0
   [47195.139153]  slab_reclaimable:38221 slab_unreclaimable:10817
   [47195.139153]  mapped:26788 shmem:6094 pagetables:471 bounce:0
   [47195.139153]  free:241416 free_pcp:398 free_cma:0
   [47195.139166] Node 0 active_anon:125680kB inactive_anon:33772kB active_=
file:1201256kB inactive_file:522968kB unevictable:28564kB isolated(anon):0k=
B isolated(file):0kB mapped:107152kB dirty:144kB writeback:0kB shmem:0kB sh=
mem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 24376kB writeback_tmp:0kB unsta=
ble:0kB pages_scanned:6073890 all_unreclaimable? yes
   [47195.139176] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47195.139182] lowmem_reserve[]: 0 833 3008 3008
   [47195.139213] Normal free:42376kB min:42416kB low:53020kB high:63624kB =
active_anon:252kB inactive_anon:18824kB active_file:587512kB inactive_file:=
76kB unevictable:0kB writepending:72kB present:892920kB managed:854340kB ml=
ocked:0kB slab_reclaimable:151128kB slab_unreclaimable:42932kB kernel_stack=
:2504kB pagetables:0kB bounce:0kB free_pcp:912kB local_pcp:380kB free_cma:0=
kB
   [47195.139220] lowmem_reserve[]: 0 0 17397 17397
   [47195.139254] HighMem free:919220kB min:512kB low:28164kB high:55816kB =
active_anon:125428kB inactive_anon:14912kB active_file:604100kB inactive_fi=
le:522892kB unevictable:28564kB writepending:72kB present:2226888kB managed=
:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kern=
el_stack:0kB pagetables:1884kB bounce:0kB free_pcp:680kB local_pcp:48kB fre=
e_cma:0kB
   [47195.139259] lowmem_reserve[]: 0 0 0 0
   [47195.139268] DMA: 9*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB =
(UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4068kB
   [47195.139288] Normal: 152*4kB (UME) 81*8kB (ME) 46*16kB (M) 33*32kB (ME=
) 30*64kB (ME) 50*128kB (ME) 39*256kB (UME) 15*512kB (UME) 9*1024kB (UME) 2=
*2048kB (E) 0*4096kB =3D 42344kB
   [47195.139307] HighMem: 31*4kB (U) 8245*8kB (UM) 7859*16kB (UM) 4273*32k=
B (UM) 2553*64kB (UM) 928*128kB (UM) 303*256kB (UM) 129*512kB (M) 61*1024kB=
 (M) 26*2048kB (M) 12*4096kB (UM) =3D 919220kB
   [47195.139327] 439404 total pagecache pages
   [47195.139330] 12 pages in swap cache
   [47195.139333] Swap cache stats: add 4361, delete 4349, find 1695/2069
   [47195.139335] Free swap  =3D 2096428kB
   [47195.139337] Total swap =3D 2096476kB
   [47195.139339] 783948 pages RAM
   [47195.139341] 556722 pages HighMem/MovableOnly
   [47195.139342] 9664 pages reserved
   [47195.139344] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47195.139350] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47195.139355] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47195.139359] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47195.139363] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47195.139366] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47195.139370] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47195.139374] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47195.139377] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47195.139381] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47195.139384] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47195.139388] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47195.139391] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47195.139395] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47195.139399] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47195.139403] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47195.139406] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47195.139409] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47195.139413] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47195.139416] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47195.139420] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47195.139423] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47195.139427] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47195.139430] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47195.139434] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47195.139437] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47195.139441] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47195.139444] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47195.139448] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47195.139451] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47195.139454] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47195.139459] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47195.139462] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47195.139466] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47195.139469] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47195.139473] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47195.139476] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47195.139480] [ 6228]     0  6228    22559     9093      21       0    =
    0             0 Xorg
   [47195.139484] [ 6234]     0  6234     1698     1041       4       0    =
    0             0 wdm
   [47195.139487] [ 6252] 10230  6252    13570     3267      13       0    =
    0             0 fvwm2
   [47195.139491] [ 6305] 10230  6305     1136      586       4       0    =
    0             0 dbus-launch
   [47195.139494] [ 6306] 10230  6306     1075       54       5       0    =
    0             0 dbus-daemon
   [47195.139498] [ 6327] 10230  6327     3690      772       5       0    =
    0             0 tpb
   [47195.139501] [ 6339] 10230  6339     2021     1210       5       0    =
    0             0 xscreensaver
   [47195.139505] [ 6343] 10230  6343     2937      614       5       0    =
    0             0 redshift
   [47195.139508] [ 6349] 10230  6349     1284      637       5       0    =
    0             0 autocutsel
   [47195.139512] [ 6356] 10230  6356    10919     5133      13       0    =
    0             0 gkrellm
   [47195.139516] [ 6357] 10230  6357    52643    18228      43       0    =
    0             0 psi-plus
   [47195.139519] [ 6358] 10230  6358    10775     7226      12       0    =
    0             0 wicd-client
   [47195.139523] [ 6380] 10230  6380     1047      299       5       0    =
    0             0 FvwmCommandS
   [47195.139526] [ 6381] 10230  6381     1528      473       5       0    =
    0             0 FvwmEvent
   [47195.139530] [ 6382] 10230  6382    12182     2138      10       0    =
    0             0 FvwmAnimate
   [47195.139533] [ 6383] 10230  6383    12808     2480      11       0    =
    0             0 FvwmButtons
   [47195.139537] [ 6384] 10230  6384    13311     2678      11       0    =
    0             0 FvwmProxy
   [47195.139540] [ 6385] 10230  6385     1507      434       5       0    =
    0             0 FvwmAuto
   [47195.139544] [ 6389] 10230  6389    12803     2459      11       0    =
    0             0 FvwmPager
   [47195.139548] [ 6391] 10230  6391      581      146       4       0    =
    0             0 sh
   [47195.139551] [ 6392] 10230  6392     1030      672       5       0    =
    0             0 stalonetray
   [47195.139555] [ 6406] 10230  6406     2759     1611       6       0    =
    0             0 xterm
   [47195.139558] [ 6409] 10230  6409     2022     1392       6       0    =
    0             0 zsh
   [47195.139562] [ 6703] 10230  6703     2684     1518       6       0    =
    0             0 xterm
   [47195.139565] [ 6717] 10230  6717     1980     1337       5       0    =
    0             0 zsh
   [47195.139569] [ 6775]     0  6775      557      138       4       0    =
    0             0 sleep
   [47195.139572] [ 6885] 10230  6885    45486     2615      26       0    =
    0             0 git
   [47195.139575] Out of memory: Kill process 6357 (psi-plus) score 14 or s=
acrifice child
   [47195.139595] Killed process 6357 (psi-plus) total-vm:210572kB, anon-rs=
s:28944kB, file-rss:43428kB, shmem-rss:540kB

   [47196.621110] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47196.621113] Xorg cpuset=3D/ mems_allowed=3D0
   [47196.621122] CPU: 0 PID: 6228 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47196.621124] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47196.621127]  00000286 2d7b4819 c12b1260 f37419f0 d8095280 c113c257 c1=
5933a0 d8095624
   [47196.621135]  024200d4 f37419fc 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47196.621142]  f447d0d8 00015280 d8095280 d80956ac c15910eb f37419f0 c1=
0e7b4e c105fe23
   [47196.621150] Call Trace:
   [47196.621158]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47196.621164]  [<c113c257>] ? dump_header+0x43/0x19f
   [47196.621168]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47196.621173]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47196.621177]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47196.621181]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47196.621185]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47196.621189]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47196.621192]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47196.621197]  [<c111e117>] ? __read_swap_cache_async+0x107/0x1d0
   [47196.621201]  [<c111e205>] ? read_swap_cache_async+0x25/0x50
   [47196.621204]  [<c111e35a>] ? swapin_readahead+0x12a/0x180
   [47196.621208]  [<c10e3d7e>] ? pagecache_get_page+0x1e/0x250
   [47196.621212]  [<c10fb8eb>] ? shmem_getpage_gfp+0x8ab/0xbb0
   [47196.621217]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47196.621246]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47196.621270]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47196.621274]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47196.621298]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47196.621321]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47196.621344]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47196.621368]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47196.621393]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47196.621416]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47196.621439]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47196.621461]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47196.621486]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47196.621490]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47196.621493]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47196.621516]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47196.621539]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47196.621551]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47196.621574]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47196.621578]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47196.621582]  [<c102181f>] ? __fpu__restore_sig+0x22f/0x410
   [47196.621592]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47196.621595]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47196.621600]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47196.621603]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47196.621607]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47196.621610]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47196.621613]  [<c115bec1>] ? __fget+0x61/0xb0
   [47196.621617]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47196.621620]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47196.621625]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47196.621627] Mem-Info:
   [47196.621634] active_anon:24180 inactive_anon:7910 isolated_anon:160
   [47196.621634]  active_file:284067 inactive_file:107023 isolated_file:0
   [47196.621634]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47196.621634]  slab_reclaimable:37040 slab_unreclaimable:10783
   [47196.621634]  mapped:19051 shmem:5655 pagetables:428 bounce:0
   [47196.621634]  free:290649 free_pcp:30 free_cma:0
   [47196.621644] Node 0 active_anon:96720kB inactive_anon:31640kB active_f=
ile:1136268kB inactive_file:428092kB unevictable:28564kB isolated(anon):640=
kB isolated(file):0kB mapped:76204kB dirty:0kB writeback:0kB shmem:0kB shme=
m_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 22620kB writeback_tmp:0kB unstabl=
e:0kB pages_scanned:656669 all_unreclaimable? no
   [47196.621651] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47196.621654] lowmem_reserve[]: 0 833 3008 3008
   [47196.621664] Normal free:42388kB min:42416kB low:53020kB high:63624kB =
active_anon:256kB inactive_anon:17128kB active_file:594212kB inactive_file:=
60kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:146404kB slab_unreclaimable:42796kB kernel_stack:=
2456kB pagetables:0kB bounce:0kB free_pcp:120kB local_pcp:120kB free_cma:0kB
   [47196.621667] lowmem_reserve[]: 0 0 17397 17397
   [47196.621676] HighMem free:1116140kB min:512kB low:28164kB high:55816kB=
 active_anon:96464kB inactive_anon:14368kB active_file:532412kB inactive_fi=
le:427960kB unevictable:28564kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:1712kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cm=
a:0kB
   [47196.621679] lowmem_reserve[]: 0 0 0 0
   [47196.621684] DMA: 9*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB =
(UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4068kB
   [47196.621703] Normal: 152*4kB (UME) 167*8kB (UME) 49*16kB (UME) 79*32kB=
 (UME) 73*64kB (UME) 58*128kB (ME) 38*256kB (ME) 14*512kB (UME) 8*1024kB (U=
ME) 0*2048kB 0*4096kB =3D 42440kB
   [47196.621722] HighMem: 7909*4kB (UM) 12935*8kB (UM) 9378*16kB (UM) 4922=
*32kB (UM) 2858*64kB (UM) 1183*128kB (UM) 397*256kB (UM) 140*512kB (M) 62*1=
024kB (M) 26*2048kB (M) 12*4096kB (UM) =3D 1116204kB
   [47196.621742] 399003 total pagecache pages
   [47196.621745] 21 pages in swap cache
   [47196.621748] Swap cache stats: add 6296, delete 6275, find 2342/2867
   [47196.621750] Free swap  =3D 2095560kB
   [47196.621752] Total swap =3D 2096476kB
   [47196.621754] 783948 pages RAM
   [47196.621756] 556722 pages HighMem/MovableOnly
   [47196.621758] 9664 pages reserved
   [47196.621760] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47196.621765] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47196.621770] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47196.621774] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47196.621778] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47196.621782] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47196.621786] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47196.621789] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47196.621793] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47196.621797] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47196.621800] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47196.621804] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47196.621808] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47196.621811] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47196.621815] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47196.621819] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47196.621822] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47196.621826] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47196.621829] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47196.621833] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47196.621837] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47196.621840] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47196.621844] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47196.621847] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47196.621851] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47196.621854] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47196.621858] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47196.621862] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47196.621865] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47196.621869] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47196.621872] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47196.621876] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47196.621880] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47196.621884] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47196.621887] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47196.621891] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47196.621895] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47196.621898] [ 6228]     0  6228    22465     8979      21       0    =
    0             0 Xorg
   [47196.621902] [ 6234]     0  6234     1698     1041       4       0    =
    0             0 wdm
   [47196.621906] [ 6252] 10230  6252    13570     3267      13       0    =
    0             0 fvwm2
   [47196.621909] [ 6305] 10230  6305     1136      586       4       0    =
    0             0 dbus-launch
   [47196.621913] [ 6306] 10230  6306     1075       54       5       0    =
    0             0 dbus-daemon
   [47196.621916] [ 6327] 10230  6327     3690      772       5       0    =
    0             0 tpb
   [47196.621920] [ 6339] 10230  6339     2021     1210       5       0    =
    0             0 xscreensaver
   [47196.621924] [ 6343] 10230  6343     2937      614       5       0    =
    0             0 redshift
   [47196.621927] [ 6349] 10230  6349     1284      637       5       0    =
    0             0 autocutsel
   [47196.621931] [ 6356] 10230  6356    10919     5133      13       0    =
    0             0 gkrellm
   [47196.621934] [ 6358] 10230  6358    10775     7226      12       0    =
    0             0 wicd-client
   [47196.621938] [ 6380] 10230  6380     1047      299       5       0    =
    0             0 FvwmCommandS
   [47196.621942] [ 6381] 10230  6381     1528      473       5       0    =
    0             0 FvwmEvent
   [47196.621945] [ 6382] 10230  6382    12182     2138      10       0    =
    0             0 FvwmAnimate
   [47196.621949] [ 6383] 10230  6383    12808     2480      11       0    =
    0             0 FvwmButtons
   [47196.621952] [ 6384] 10230  6384    13311     2678      11       0    =
    0             0 FvwmProxy
   [47196.621956] [ 6385] 10230  6385     1507      434       5       0    =
    0             0 FvwmAuto
   [47196.621960] [ 6389] 10230  6389    12803     2459      11       0    =
    0             0 FvwmPager
   [47196.621963] [ 6391] 10230  6391      581      146       4       0    =
    0             0 sh
   [47196.621967] [ 6392] 10230  6392     1063      672       5       0    =
    0             0 stalonetray
   [47196.621970] [ 6406] 10230  6406     2759     1611       6       0    =
    0             0 xterm
   [47196.621974] [ 6409] 10230  6409     2022     1392       6       0    =
    0             0 zsh
   [47196.621977] [ 6703] 10230  6703     2684     1518       6       0    =
    0             0 xterm
   [47196.621981] [ 6717] 10230  6717     1980     1337       5       0    =
    0             0 zsh
   [47196.621984] [ 6775]     0  6775      557      138       4       0    =
    0             0 sleep
   [47196.621988] [ 6885] 10230  6885    45486     2615      26       0    =
    0             0 git
   [47196.621991] Out of memory: Kill process 6228 (Xorg) score 6 or sacrif=
ice child
   [47196.622001] Killed process 6228 (Xorg) total-vm:89860kB, anon-rss:196=
40kB, file-rss:15484kB, shmem-rss:792kB
   [47196.659317] oom_reaper: reaped process 6228 (Xorg), now anon-rss:0kB,=
 file-rss:0kB, shmem-rss:792kB

   [47213.431887] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47213.431890] Xorg cpuset=3D/ mems_allowed=3D0
   [47213.431899] CPU: 1 PID: 6941 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47213.431902] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47213.431905]  00200286 62c060a1 c12b1260 f0045a3c e9d0f380 c113c257 c1=
5933a0 f36cb524
   [47213.431913]  024200d4 f0045a48 00000000 00000000 00000000 00200206 c1=
2b63ef 00000000
   [47213.431920]  f447d0d8 0001b180 e9d0f380 e9d0f7ac c15910eb f0045a3c c1=
0e7b4e c105fe23
   [47213.431928] Call Trace:
   [47213.431937]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47213.431942]  [<c113c257>] ? dump_header+0x43/0x19f
   [47213.431946]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47213.431951]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47213.431955]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47213.431959]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47213.431963]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47213.431967]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47213.431971]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47213.431975]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47213.431979]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47213.431982]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47213.431988]  [<c14baaf3>] ? common_interrupt+0x33/0x38
   [47213.431992]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47213.432008]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47213.432008]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47213.432008]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47213.432008]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47213.432008]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47213.432008]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47213.432008]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47213.432008]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47213.432008]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47213.432008]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47213.432008]  [<c107474c>] ? enqueue_task_fair+0x4c/0xd50
   [47213.432008]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47213.432008]  [<f88937d3>] ? i915_gem_object_ggtt_unpin_view+0x23/0xc0=
 [i915]
   [47213.432008]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47213.432008]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47213.432008]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47213.432008]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47213.432008]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47213.432008]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47213.432008]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47213.432008]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47213.432008]  [<c1052f04>] ? __set_current_blocked+0x24/0x40
   [47213.432008]  [<c1052f92>] ? signal_setup_done+0x62/0xb0
   [47213.432008]  [<c102181f>] ? __fpu__restore_sig+0x22f/0x410
   [47213.432008]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47213.432008]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47213.432008]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47213.432008]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47213.432008]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47213.432008]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47213.432008]  [<c115bec1>] ? __fget+0x61/0xb0
   [47213.432008]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47213.432008]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47213.432008]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47213.434668] Mem-Info:
   [47213.434676] active_anon:36758 inactive_anon:8541 isolated_anon:0
   [47213.434676]  active_file:286774 inactive_file:102663 isolated_file:0
   [47213.434676]  unevictable:7141 dirty:15 writeback:0 unstable:0
   [47213.434676]  slab_reclaimable:36633 slab_unreclaimable:10704
   [47213.434676]  mapped:25591 shmem:6229 pagetables:454 bounce:0
   [47213.434676]  free:279709 free_pcp:49 free_cma:0
   [47213.434688] Node 0 active_anon:147032kB inactive_anon:34164kB active_=
file:1147096kB inactive_file:410652kB unevictable:28564kB isolated(anon):0k=
B isolated(file):0kB mapped:102364kB dirty:60kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 24916kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:441444 all_unreclaimable? no
   [47213.434695] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47213.434698] lowmem_reserve[]: 0 833 3008 3008
   [47213.434708] Normal free:42412kB min:42416kB low:53020kB high:63624kB =
active_anon:272kB inactive_anon:19788kB active_file:594304kB inactive_file:=
52kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:144776kB slab_unreclaimable:42480kB kernel_stack:=
2352kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47213.434711] lowmem_reserve[]: 0 0 17397 17397
   [47213.434720] HighMem free:1072356kB min:512kB low:28164kB high:55816kB=
 active_anon:146732kB inactive_anon:14380kB active_file:543068kB inactive_f=
ile:410600kB unevictable:28564kB writepending:40kB present:2226888kB manage=
d:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB ker=
nel_stack:0kB pagetables:1816kB bounce:0kB free_pcp:196kB local_pcp:112kB f=
ree_cma:0kB
   [47213.434723] lowmem_reserve[]: 0 0 0 0
   [47213.434728] DMA: 9*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB =
(UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4068kB
   [47213.434748] Normal: 90*4kB (UME) 61*8kB (UME) 63*16kB (UME) 39*32kB (=
UM) 103*64kB (UME) 60*128kB (ME) 40*256kB (UME) 13*512kB (ME) 8*1024kB (UME=
) 0*2048kB 0*4096kB =3D 42464kB
   [47213.434767] HighMem: 231*4kB (UM) 10239*8kB (UM) 9575*16kB (UM) 4985*=
32kB (UM) 2879*64kB (UM) 1188*128kB (UM) 396*256kB (UM) 139*512kB (M) 62*10=
24kB (M) 25*2048kB (M) 13*4096kB (UM) =3D 1072356kB
   [47213.434787] 397872 total pagecache pages
   [47213.434790] 2 pages in swap cache
   [47213.434793] Swap cache stats: add 6423, delete 6421, find 2397/2942
   [47213.434795] Free swap  =3D 2096204kB
   [47213.434797] Total swap =3D 2096476kB
   [47213.434799] 783948 pages RAM
   [47213.434801] 556722 pages HighMem/MovableOnly
   [47213.434803] 9664 pages reserved
   [47213.434805] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47213.434813] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47213.434822] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47213.434826] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47213.434831] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47213.434834] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47213.434838] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47213.434842] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47213.434846] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47213.434850] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47213.434854] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47213.434858] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47213.434861] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47213.434866] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47213.434869] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47213.434873] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47213.434877] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47213.434881] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47213.434885] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47213.434889] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47213.434892] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47213.434896] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47213.434900] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47213.434904] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47213.434908] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47213.434912] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47213.434916] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47213.434920] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47213.434923] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47213.434927] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47213.434931] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47213.434936] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47213.434940] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47213.434944] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47213.434948] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47213.434952] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47213.434956] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47213.434961] [ 6775]     0  6775      557      138       4       0    =
    0             0 sleep
   [47213.434965] [ 6941]     0  6941    21494     8806      21       0    =
    0             0 Xorg
   [47213.434969] [ 6947]     0  6947     1698     1041       4       0    =
    0             0 wdm
   [47213.434972] [ 6965] 10230  6965    13570     3266      11       0    =
    0             0 fvwm2
   [47213.434976] [ 7018] 10230  7018     1136      586       5       0    =
    0             0 dbus-launch
   [47213.434980] [ 7019] 10230  7019     1075       54       5       0    =
    0             0 dbus-daemon
   [47213.434984] [ 7042] 10230  7042     3690      771       5       0    =
    0             0 tpb
   [47213.434988] [ 7052] 10230  7052     2021     1197       5       0    =
    0             0 xscreensaver
   [47213.434992] [ 7056] 10230  7056     2937      596       6       0    =
    0             0 redshift
   [47213.434995] [ 7062] 10230  7062     1284      621       4       0    =
    0             0 autocutsel
   [47213.434999] [ 7069] 10230  7069    10919     5109      12       0    =
    0             0 gkrellm
   [47213.438115] [ 7070] 10230  7070    48136    16350      37       0    =
    0             0 psi-plus
   [47213.438121] [ 7071] 10230  7071    10775     7319      13       0    =
    0             0 wicd-client
   [47213.438125] [ 7093] 10230  7093     1047      312       5       0    =
    0             0 FvwmCommandS
   [47213.438130] [ 7094] 10230  7094     1528      453       5       0    =
    0             0 FvwmEvent
   [47213.438134] [ 7095] 10230  7095    12182     2119      10       0    =
    0             0 FvwmAnimate
   [47213.438138] [ 7096] 10230  7096    12808     2472      11       0    =
    0             0 FvwmButtons
   [47213.438142] [ 7097] 10230  7097    13311     2695      11       0    =
    0             0 FvwmProxy
   [47213.438146] [ 7098] 10230  7098     1507      410       5       0    =
    0             0 FvwmAuto
   [47213.438150] [ 7101] 10230  7101    12803     2388      11       0    =
    0             0 FvwmPager
   [47213.438154] [ 7104] 10230  7104      581      151       4       0    =
    0             0 sh
   [47213.438158] [ 7105] 10230  7105     1030      728       4       0    =
    0             0 stalonetray
   [47213.438162] [ 7124] 10230  7124     2684     1650       6       0    =
    0             0 lsb_release
   [47213.438166] [ 7125] 10230  7125    10487     9983      14       0    =
    0             0 apt-cache
   [47213.438170] [ 7128]     0  7128     2974      213       5       0    =
    0             0 udevd
   [47213.438174] [ 7129]     0  7129     2974      213       5       0    =
    0             0 udevd
   [47213.438178] [ 7130]     0  7130     2974      213       5       0    =
    0             0 udevd
   [47213.438181] [ 7131]     0  7131     2974      213       5       0    =
    0             0 udevd
   [47213.438185] Out of memory: Kill process 7070 (psi-plus) score 12 or s=
acrifice child
   [47213.438199] Killed process 7124 (lsb_release) total-vm:10736kB, anon-=
rss:2380kB, file-rss:4220kB, shmem-rss:0kB

   [47213.648905] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47213.648908] Xorg cpuset=3D/ mems_allowed=3D0
   [47213.648917] CPU: 0 PID: 6941 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47213.648920] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47213.648923]  00000286 62c060a1 c12b1260 f0045a3c e9d0f380 c113c257 c1=
5933a0 f36cb524
   [47213.648931]  024200d4 f0045a48 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47213.648939]  f447d0d8 0001b180 e9d0f380 e9d0f7ac c15910eb f0045a3c c1=
0e7b4e c105fe23
   [47213.648946] Call Trace:
   [47213.648955]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47213.648960]  [<c113c257>] ? dump_header+0x43/0x19f
   [47213.648964]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47213.648969]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47213.648973]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47213.648977]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47213.648981]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47213.648984]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47213.648988]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47213.648993]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47213.648996]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47213.648999]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47213.649005]  [<c14baaf3>] ? common_interrupt+0x33/0x38
   [47213.649009]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47213.649012]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47213.649012]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47213.649012]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47213.649012]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47213.649012]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47213.649012]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47213.649012]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47213.649012]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47213.649012]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47213.649012]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47213.649012]  [<c107474c>] ? enqueue_task_fair+0x4c/0xd50
   [47213.649012]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47213.649012]  [<f88937d3>] ? i915_gem_object_ggtt_unpin_view+0x23/0xc0=
 [i915]
   [47213.649012]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47213.649012]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47213.649012]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47213.649012]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47213.649012]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47213.649012]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47213.649012]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47213.649012]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47213.649012]  [<c1052f04>] ? __set_current_blocked+0x24/0x40
   [47213.649012]  [<c1052f92>] ? signal_setup_done+0x62/0xb0
   [47213.649012]  [<c102181f>] ? __fpu__restore_sig+0x22f/0x410
   [47213.649012]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47213.649012]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47213.649012]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47213.649012]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47213.649012]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47213.649012]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47213.649012]  [<c115bec1>] ? __fget+0x61/0xb0
   [47213.649012]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47213.649012]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47213.649012]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47213.651672] Mem-Info:
   [47213.651680] active_anon:36952 inactive_anon:8560 isolated_anon:0
   [47213.651680]  active_file:286774 inactive_file:102639 isolated_file:0
   [47213.651680]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47213.651680]  slab_reclaimable:36621 slab_unreclaimable:10715
   [47213.651680]  mapped:25741 shmem:6238 pagetables:455 bounce:0
   [47213.651680]  free:279505 free_pcp:91 free_cma:0
   [47213.651691] Node 0 active_anon:147808kB inactive_anon:34240kB active_=
file:1147096kB inactive_file:410556kB unevictable:28564kB isolated(anon):0k=
B isolated(file):0kB mapped:102964kB dirty:0kB writeback:0kB shmem:0kB shme=
m_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 24952kB writeback_tmp:0kB unstabl=
e:0kB pages_scanned:412370 all_unreclaimable? no
   [47213.651698] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47213.651701] lowmem_reserve[]: 0 833 3008 3008
   [47213.651711] Normal free:42340kB min:42416kB low:53020kB high:63624kB =
active_anon:272kB inactive_anon:19848kB active_file:594304kB inactive_file:=
52kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:144728kB slab_unreclaimable:42524kB kernel_stack:=
2352kB pagetables:0kB bounce:0kB free_pcp:128kB local_pcp:0kB free_cma:0kB
   [47213.651714] lowmem_reserve[]: 0 0 17397 17397
   [47213.651723] HighMem free:1071612kB min:512kB low:28164kB high:55816kB=
 active_anon:147536kB inactive_anon:14380kB active_file:543068kB inactive_f=
ile:410504kB unevictable:28564kB writepending:0kB present:2226888kB managed=
:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kern=
el_stack:0kB pagetables:1820kB bounce:0kB free_pcp:236kB local_pcp:184kB fr=
ee_cma:0kB
   [47213.651726] lowmem_reserve[]: 0 0 0 0
   [47213.651731] DMA: 9*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB =
(UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4068kB
   [47213.651752] Normal: 59*4kB (UME) 62*8kB (UME) 63*16kB (UME) 39*32kB (=
UM) 103*64kB (UME) 60*128kB (ME) 40*256kB (UME) 13*512kB (ME) 8*1024kB (UME=
) 0*2048kB 0*4096kB =3D 42348kB
   [47213.651771] HighMem: 1*4kB (U) 10261*8kB (UM) 9575*16kB (UM) 4985*32k=
B (UM) 2879*64kB (UM) 1188*128kB (UM) 396*256kB (UM) 139*512kB (M) 62*1024k=
B (M) 25*2048kB (M) 13*4096kB (UM) =3D 1071612kB
   [47213.651791] 397858 total pagecache pages
   [47213.651793] 2 pages in swap cache
   [47213.651796] Swap cache stats: add 6423, delete 6421, find 2397/2942
   [47213.651798] Free swap  =3D 2096204kB
   [47213.651800] Total swap =3D 2096476kB
   [47213.651802] 783948 pages RAM
   [47213.651804] 556722 pages HighMem/MovableOnly
   [47213.651806] 9664 pages reserved
   [47213.651808] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47213.651816] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47213.651825] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47213.651830] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47213.651834] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47213.651838] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47213.651842] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47213.651846] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47213.651849] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47213.651853] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47213.651857] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47213.651861] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47213.651865] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47213.651869] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47213.651873] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47213.651876] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47213.651880] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47213.651884] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47213.651888] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47213.651892] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47213.651895] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47213.651899] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47213.651903] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47213.651907] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47213.651911] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47213.651915] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47213.651919] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47213.651922] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47213.651926] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47213.651930] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47213.651933] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47213.651939] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47213.651943] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47213.651948] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47213.651952] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47213.651955] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47213.651959] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47213.651964] [ 6775]     0  6775      557      138       4       0    =
    0             0 sleep
   [47213.651968] [ 6941]     0  6941    21494     8806      21       0    =
    0             0 Xorg
   [47213.651971] [ 6947]     0  6947     1698     1041       4       0    =
    0             0 wdm
   [47213.651975] [ 6965] 10230  6965    13570     3266      11       0    =
    0             0 fvwm2
   [47213.651979] [ 7018] 10230  7018     1136      586       5       0    =
    0             0 dbus-launch
   [47213.651983] [ 7019] 10230  7019     1075       54       5       0    =
    0             0 dbus-daemon
   [47213.651987] [ 7042] 10230  7042     3690      771       5       0    =
    0             0 tpb
   [47213.651991] [ 7052] 10230  7052     2021     1197       5       0    =
    0             0 xscreensaver
   [47213.651995] [ 7056] 10230  7056     2937      596       6       0    =
    0             0 redshift
   [47213.651999] [ 7062] 10230  7062     1284      621       4       0    =
    0             0 autocutsel
   [47213.654987] [ 7069] 10230  7069    10919     5109      12       0    =
    0             0 gkrellm
   [47213.654992] [ 7070] 10230  7070    48226    16577      37       0    =
    0             0 psi-plus
   [47213.654997] [ 7071] 10230  7071    10775     7319      13       0    =
    0             0 wicd-client
   [47213.655001] [ 7093] 10230  7093     1047      312       5       0    =
    0             0 FvwmCommandS
   [47213.655267] [ 7094] 10230  7094     1528      453       5       0    =
    0             0 FvwmEvent
   [47213.655272] [ 7095] 10230  7095    12182     2119      10       0    =
    0             0 FvwmAnimate
   [47213.655276] [ 7096] 10230  7096    12808     2472      11       0    =
    0             0 FvwmButtons
   [47213.655280] [ 7097] 10230  7097    13311     2695      11       0    =
    0             0 FvwmProxy
   [47213.655284] [ 7098] 10230  7098     1507      410       5       0    =
    0             0 FvwmAuto
   [47213.655288] [ 7101] 10230  7101    12803     2388      11       0    =
    0             0 FvwmPager
   [47213.655292] [ 7104] 10230  7104      581      151       4       0    =
    0             0 sh
   [47213.655296] [ 7105] 10230  7105     1030      728       4       0    =
    0             0 stalonetray
   [47213.655300] [ 7125] 10230  7125    11288    10643      15       0    =
    0             0 apt-cache
   [47213.655304] [ 7128]     0  7128     2974      213       5       0    =
    0             0 udevd
   [47213.655308] [ 7129]     0  7129     2974      213       5       0    =
    0             0 udevd
   [47213.655311] [ 7130]     0  7130     2974      213       5       0    =
    0             0 udevd
   [47213.655316] [ 7131]     0  7131     2974      213       5       0    =
    0             0 udevd
   [47213.655319] Out of memory: Kill process 7070 (psi-plus) score 12 or s=
acrifice child
   [47213.655338] Killed process 7070 (psi-plus) total-vm:192904kB, anon-rs=
s:26704kB, file-rss:39604kB, shmem-rss:0kB

   [47214.050690] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47214.050693] Xorg cpuset=3D/ mems_allowed=3D0
   [47214.050701] CPU: 0 PID: 6941 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47214.050704] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47214.050707]  00000286 62c060a1 c12b1260 f0045a3c d8096300 c113c257 c1=
5933a0 f36cb524
   [47214.050715]  024200d4 f0045a48 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47214.050723]  f447d0d8 0001b180 d8096300 d809672c c15910eb f0045a3c c1=
0e7b4e c105fe23
   [47214.050730] Call Trace:
   [47214.050738]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47214.050744]  [<c113c257>] ? dump_header+0x43/0x19f
   [47214.050748]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47214.050753]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47214.050757]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47214.050761]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47214.050765]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47214.050769]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47214.050773]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47214.050777]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47214.050780]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47214.050784]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47214.050789]  [<c14baaf3>] ? common_interrupt+0x33/0x38
   [47214.050794]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47214.050823]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47214.050848]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47214.050852]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47214.050875]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47214.050898]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47214.050922]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47214.050946]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47214.050970]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47214.050993]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47214.051008]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47214.051008]  [<c107474c>] ? enqueue_task_fair+0x4c/0xd50
   [47214.051008]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47214.051008]  [<f88937d3>] ? i915_gem_object_ggtt_unpin_view+0x23/0xc0=
 [i915]
   [47214.051008]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47214.051008]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47214.051008]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47214.051008]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47214.051008]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47214.051008]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47214.051008]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47214.051008]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47214.051008]  [<c1052f04>] ? __set_current_blocked+0x24/0x40
   [47214.051008]  [<c1052f92>] ? signal_setup_done+0x62/0xb0
   [47214.051008]  [<c102181f>] ? __fpu__restore_sig+0x22f/0x410
   [47214.051008]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47214.051008]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47214.051008]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47214.051008]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47214.051008]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47214.051008]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47214.051008]  [<c115bec1>] ? __fget+0x61/0xb0
   [47214.051008]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47214.051008]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47214.051008]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47214.064170] Mem-Info:
   [47214.064181] active_anon:31671 inactive_anon:8560 isolated_anon:32
   [47214.064181]  active_file:286581 inactive_file:102404 isolated_file:0
   [47214.064181]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47214.064181]  slab_reclaimable:36601 slab_unreclaimable:10707
   [47214.064181]  mapped:18707 shmem:6271 pagetables:413 bounce:0
   [47214.064181]  free:285209 free_pcp:139 free_cma:0
   [47214.064192] Node 0 active_anon:126684kB inactive_anon:34340kB active_=
file:1146324kB inactive_file:409616kB unevictable:28564kB isolated(anon):0k=
B isolated(file):0kB mapped:74828kB dirty:0kB writeback:0kB shmem:0kB shmem=
_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 25084kB writeback_tmp:0kB unstable=
:0kB pages_scanned:454588 all_unreclaimable? no
   [47214.064199] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47214.064202] lowmem_reserve[]: 0 833 3008 3008
   [47214.064212] Normal free:42348kB min:42416kB low:53020kB high:63624kB =
active_anon:272kB inactive_anon:19852kB active_file:594180kB inactive_file:=
52kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:144648kB slab_unreclaimable:42492kB kernel_stack:=
2304kB pagetables:0kB bounce:0kB free_pcp:240kB local_pcp:240kB free_cma:0kB
   [47214.064215] lowmem_reserve[]: 0 0 17397 17397
   [47214.064224] HighMem free:1094420kB min:512kB low:28164kB high:55816kB=
 active_anon:126412kB inactive_anon:14356kB active_file:542420kB inactive_f=
ile:409564kB unevictable:28564kB writepending:0kB present:2226888kB managed=
:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kern=
el_stack:0kB pagetables:1652kB bounce:0kB free_pcp:316kB local_pcp:240kB fr=
ee_cma:0kB
   [47214.064227] lowmem_reserve[]: 0 0 0 0
   [47214.064232] DMA: 9*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB =
(UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4068kB
   [47214.064252] Normal: 97*4kB (UM) 63*8kB (UME) 61*16kB (UME) 39*32kB (U=
ME) 101*64kB (UME) 60*128kB (ME) 40*256kB (UME) 13*512kB (ME) 8*1024kB (UME=
) 0*2048kB 0*4096kB =3D 42348kB
   [47214.064271] HighMem: 4607*4kB (UM) 10671*8kB (UM) 9574*16kB (UM) 5014=
*32kB (UM) 2880*64kB (UM) 1189*128kB (UM) 396*256kB (UM) 139*512kB (M) 62*1=
024kB (M) 25*2048kB (M) 13*4096kB (UM) =3D 1094420kB
   [47214.064291] 397463 total pagecache pages
   [47214.064294] 2 pages in swap cache
   [47214.064297] Swap cache stats: add 6423, delete 6421, find 2397/2942
   [47214.064299] Free swap  =3D 2096204kB
   [47214.064301] Total swap =3D 2096476kB
   [47214.064303] 783948 pages RAM
   [47214.064305] 556722 pages HighMem/MovableOnly
   [47214.064306] 9664 pages reserved
   [47214.064308] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47214.064320] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47214.064333] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47214.064337] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47214.064342] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47214.064346] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47214.064350] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47214.064354] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47214.064358] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47214.064362] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47214.064366] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47214.064370] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47214.064374] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47214.064379] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47214.064383] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47214.064387] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47214.064391] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47214.064395] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47214.064399] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47214.064402] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47214.064406] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47214.064410] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47214.064414] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47214.064419] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47214.064423] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47214.064427] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47214.064431] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47214.064435] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47214.064439] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47214.064442] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47214.064446] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47214.064454] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47214.064458] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47214.064463] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47214.064467] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47214.064471] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47214.064474] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47214.064480] [ 6775]     0  6775      557      138       4       0    =
    0             0 sleep
   [47214.064484] [ 6941]     0  6941    21494     8806      21       0    =
    0             0 Xorg
   [47214.064488] [ 6947]     0  6947     1698     1041       4       0    =
    0             0 wdm
   [47214.064492] [ 6965] 10230  6965    13570     3266      11       0    =
    0             0 fvwm2
   [47214.064497] [ 7018] 10230  7018     1136      586       5       0    =
    0             0 dbus-launch
   [47214.064501] [ 7019] 10230  7019     1075       54       5       0    =
    0             0 dbus-daemon
   [47214.064505] [ 7042] 10230  7042     3690      771       5       0    =
    0             0 tpb
   [47214.064508] [ 7052] 10230  7052     2021     1197       5       0    =
    0             0 xscreensaver
   [47214.064513] [ 7056] 10230  7056     2937      596       6       0    =
    0             0 redshift
   [47214.064517] [ 7062] 10230  7062     1284      621       4       0    =
    0             0 autocutsel
   [47214.064521] [ 7069] 10230  7069    10919     5109      12       0    =
    0             0 gkrellm
   [47214.064525] [ 7071] 10230  7071    10775     7319      13       0    =
    0             0 wicd-client
   [47214.064529] [ 7093] 10230  7093     1047      312       5       0    =
    0             0 FvwmCommandS
   [47214.064533] [ 7094] 10230  7094     1528      453       5       0    =
    0             0 FvwmEvent
   [47214.064537] [ 7095] 10230  7095    12182     2119      10       0    =
    0             0 FvwmAnimate
   [47214.064541] [ 7096] 10230  7096    12808     2472      11       0    =
    0             0 FvwmButtons
   [47214.064545] [ 7097] 10230  7097    13311     2695      11       0    =
    0             0 FvwmProxy
   [47214.064549] [ 7098] 10230  7098     1507      410       5       0    =
    0             0 FvwmAuto
   [47214.064553] [ 7101] 10230  7101    12803     2388      11       0    =
    0             0 FvwmPager
   [47214.085459] [ 7104] 10230  7104      581      151       4       0    =
    0             0 sh
   [47214.085467] [ 7105] 10230  7105     1030      728       4       0    =
    0             0 stalonetray
   [47214.085471] [ 7125] 10230  7125    12693    12095      16       0    =
    0             0 apt-cache
   [47214.085476] [ 7128]     0  7128     2974      213       5       0    =
    0             0 udevd
   [47214.085480] [ 7129]     0  7129     2974      213       5       0    =
    0             0 udevd
   [47214.085484] [ 7130]     0  7130     2974      213       5       0    =
    0             0 udevd
   [47214.085489] [ 7131]     0  7131     2974      213       5       0    =
    0             0 udevd
   [47214.085496] Out of memory: Kill process 7125 (apt-cache) score 9 or s=
acrifice child
   [47214.085502] Killed process 7125 (apt-cache) total-vm:50772kB, anon-rs=
s:43220kB, file-rss:5160kB, shmem-rss:0kB

   [47228.066498] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47228.066501] Xorg cpuset=3D/ mems_allowed=3D0
   [47228.066510] CPU: 0 PID: 6941 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47228.066513] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47228.066516]  00000286 62c060a1 c12b1260 f0045a3c f36cb180 c113c257 c1=
5933a0 f36cb524
   [47228.066524]  024200d4 f0045a48 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47228.066531]  f447d0d8 0001b180 f36cb180 f36cb5ac c15910eb f0045a3c c1=
0e7b4e c105fe23
   [47228.066538] Call Trace:
   [47228.066547]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47228.066552]  [<c113c257>] ? dump_header+0x43/0x19f
   [47228.066556]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47228.066561]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47228.066565]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47228.066569]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47228.066573]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47228.066576]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47228.066580]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47228.066585]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47228.066588]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47228.066591]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47228.066596]  [<c14ba33a>] ? need_resched+0x21/0x23
   [47228.066601]  [<c138007b>] ? component_unbind.isra.9+0x1b/0x50
   [47228.066632]  [<f8895cec>] ? can_release_pages+0x2c/0x90 [i915]
   [47228.066657]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47228.066661]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47228.066685]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47228.066708]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47228.066732]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47228.066737]  [<c106cf78>] ? update_curr+0x58/0xf0
   [47228.066761]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47228.066784]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47228.066806]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47228.066810]  [<c1074b02>] ? enqueue_task_fair+0x402/0xd50
   [47228.066833]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47228.066857]  [<f88937d3>] ? i915_gem_object_ggtt_unpin_view+0x23/0xc0=
 [i915]
   [47228.066882]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47228.066886]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47228.066889]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47228.066912]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47228.066934]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47228.066947]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47228.066970]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47228.066974]  [<c113ff22>] ? do_readv_writev+0x132/0x400
   [47228.066978]  [<c140d170>] ? kernel_sendmsg+0x50/0x50
   [47228.066988]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47228.066992]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47228.066996]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47228.067000]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47228.067003]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47228.067007]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47228.067010]  [<c115bec1>] ? __fget+0x61/0xb0
   [47228.067013]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47228.067016]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47228.067016]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47228.070945] Mem-Info:
   [47228.070954] active_anon:21447 inactive_anon:8460 isolated_anon:32
   [47228.070954]  active_file:286681 inactive_file:103196 isolated_file:0
   [47228.070954]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47228.070954]  slab_reclaimable:36640 slab_unreclaimable:10777
   [47228.070954]  mapped:18676 shmem:6147 pagetables:389 bounce:0
   [47228.070954]  free:294426 free_pcp:291 free_cma:0
   [47228.070965] Node 0 active_anon:85788kB inactive_anon:33840kB active_f=
ile:1146724kB inactive_file:412784kB unevictable:28564kB isolated(anon):128=
kB isolated(file):0kB mapped:74704kB dirty:0kB writeback:0kB shmem:0kB shme=
m_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 24588kB writeback_tmp:0kB unstabl=
e:0kB pages_scanned:408459 all_unreclaimable? no
   [47228.070972] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47228.070975] lowmem_reserve[]: 0 833 3008 3008
   [47228.070985] Normal free:42364kB min:42416kB low:53020kB high:63624kB =
active_anon:240kB inactive_anon:19392kB active_file:594196kB inactive_file:=
32kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:144804kB slab_unreclaimable:42772kB kernel_stack:=
2280kB pagetables:0kB bounce:0kB free_pcp:372kB local_pcp:252kB free_cma:0kB
   [47228.070988] lowmem_reserve[]: 0 0 17397 17397
   [47228.070997] HighMem free:1131272kB min:512kB low:28164kB high:55816kB=
 active_anon:85548kB inactive_anon:14448kB active_file:542804kB inactive_fi=
le:412752kB unevictable:28564kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:1556kB bounce:0kB free_pcp:792kB local_pcp:564kB fre=
e_cma:0kB
   [47228.071690] lowmem_reserve[]: 0 0 0 0
   [47228.071696] DMA: 9*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB =
(UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4068kB
   [47228.071717] Normal: 39*4kB (UME) 64*8kB (UME) 60*16kB (UME) 39*32kB (=
UME) 105*64kB (UME) 60*128kB (ME) 40*256kB (UME) 13*512kB (ME) 8*1024kB (UM=
E) 0*2048kB 0*4096kB =3D 42364kB
   [47228.071735] HighMem: 5288*4kB (UM) 14621*8kB (UM) 9596*16kB (UM) 5028=
*32kB (UM) 2887*64kB (UM) 1191*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*1=
024kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 1131272kB
   [47228.071755] 398241 total pagecache pages
   [47228.071758] 12 pages in swap cache
   [47228.071761] Swap cache stats: add 7212, delete 7200, find 2638/3243
   [47228.071763] Free swap  =3D 2095984kB
   [47228.071765] Total swap =3D 2096476kB
   [47228.071767] 783948 pages RAM
   [47228.071769] 556722 pages HighMem/MovableOnly
   [47228.071771] 9664 pages reserved
   [47228.071773] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47228.071781] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47228.071791] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47228.071795] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47228.071799] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47228.071803] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47228.071807] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47228.071811] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47228.071815] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47228.071818] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47228.071822] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47228.071826] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47228.071830] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47228.071835] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47228.071839] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47228.071843] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47228.071847] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47228.071850] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47228.071854] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47228.071858] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47228.071862] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47228.071866] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47228.071870] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47228.071874] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47228.071877] [ 2615]     0  2615     1511      611       4       0    =
    0             0 wdm
   [47228.071881] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47228.071885] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47228.071889] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47228.071893] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47228.071897] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47228.071900] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47228.071905] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47228.071909] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47228.071914] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47228.071918] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47228.071921] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47228.071925] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47228.071930] [ 6775]     0  6775      557      138       4       0    =
    0             0 sleep
   [47228.071933] [ 6941]     0  6941    21668     8910      21       0    =
    0             0 Xorg
   [47228.071937] [ 6947]     0  6947     1698     1041       4       0    =
    0             0 wdm
   [47228.071941] [ 6965] 10230  6965    13570     3271      11       0    =
    0             0 fvwm2
   [47228.071945] [ 7018] 10230  7018     1136      586       5       0    =
    0             0 dbus-launch
   [47228.071949] [ 7019] 10230  7019     1075       54       5       0    =
    0             0 dbus-daemon
   [47228.071953] [ 7042] 10230  7042     3690      771       5       0    =
    0             0 tpb
   [47228.071957] [ 7052] 10230  7052     2021     1197       5       0    =
    0             0 xscreensaver
   [47228.071960] [ 7056] 10230  7056     2937      596       6       0    =
    0             0 redshift
   [47228.071964] [ 7062] 10230  7062     1284      621       4       0    =
    0             0 autocutsel
   [47228.071968] [ 7069] 10230  7069    10919     5109      12       0    =
    0             0 gkrellm
   [47228.071972] [ 7071] 10230  7071    10775     7319      13       0    =
    0             0 wicd-client
   [47228.071976] [ 7093] 10230  7093     1047      312       5       0    =
    0             0 FvwmCommandS
   [47228.071980] [ 7094] 10230  7094     1528      453       5       0    =
    0             0 FvwmEvent
   [47228.071983] [ 7095] 10230  7095    12182     2119      10       0    =
    0             0 FvwmAnimate
   [47228.071987] [ 7096] 10230  7096    12808     2472      11       0    =
    0             0 FvwmButtons
   [47228.071991] [ 7097] 10230  7097    13311     2695      11       0    =
    0             0 FvwmProxy
   [47228.071995] [ 7098] 10230  7098     1507      410       5       0    =
    0             0 FvwmAuto
   [47228.071999] [ 7101] 10230  7101    12803     2388      11       0    =
    0             0 FvwmPager
   [47228.077524] [ 7104] 10230  7104      581      151       4       0    =
    0             0 sh
   [47228.077530] [ 7105] 10230  7105     1063      728       4       0    =
    0             0 stalonetray
   [47228.077544] [ 7143] 10230  7143     2727     1556       6       0    =
    0             0 xterm
   [47228.077548] [ 7155] 10230  7155     1915     1216       6       0    =
    0             0 zsh
   [47228.077562] Out of memory: Kill process 6941 (Xorg) score 6 or sacrif=
ice child
   [47228.077571] Killed process 6941 (Xorg) total-vm:86672kB, anon-rss:192=
08kB, file-rss:15456kB, shmem-rss:976kB
   [47228.082204] oom_reaper: reaped process 6941 (Xorg), now anon-rss:4kB,=
 file-rss:0kB, shmem-rss:976kB

   [47242.965778] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47242.965781] Xorg cpuset=3D/ mems_allowed=3D0
   [47242.965789] CPU: 0 PID: 7312 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47242.965791] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47242.965794]  00000286 bb044c6f c12b1260 f080ba3c e9d0ca40 c113c257 c1=
5933a0 e9d0e6a4
   [47242.965803]  024200d4 f080ba48 00000000 00000000 00000000 00000206 c1=
2b63ef 00000000
   [47242.965810]  f447d0d8 0001e300 e9d0ca40 e9d0ce6c c15910eb f080ba3c c1=
0e7b4e c105fe23
   [47242.965817] Call Trace:
   [47242.965826]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47242.965831]  [<c113c257>] ? dump_header+0x43/0x19f
   [47242.965835]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47242.965840]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47242.965844]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47242.965848]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47242.965852]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47242.965856]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47242.965859]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47242.965864]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47242.965867]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47242.965871]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47242.965875]  [<c1018b5a>] ? do_IRQ+0x3a/0xb0
   [47242.965880]  [<c14baaf3>] ? common_interrupt+0x33/0x38
   [47242.965885]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47242.965915]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47242.965939]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47242.965943]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47242.965967]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47242.965990]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47242.966009]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47242.966009]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47242.966009]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47242.966009]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47242.966009]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47242.966009]  [<c1074b02>] ? enqueue_task_fair+0x402/0xd50
   [47242.966009]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47242.966009]  [<f88937d3>] ? i915_gem_object_ggtt_unpin_view+0x23/0xc0=
 [i915]
   [47242.966009]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47242.966009]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47242.966009]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47242.966009]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47242.966009]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47242.966009]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47242.966009]  [<c1042c3a>] ? kmap_atomic+0xa/0x10
   [47242.966009]  [<c10eaac6>] ? get_page_from_freelist+0x756/0x7e0
   [47242.966009]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47242.966009]  [<c113aaa0>] ? mem_cgroup_commit_charge+0x60/0x3e0
   [47242.966009]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47242.966009]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47242.966009]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47242.966009]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47242.966009]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47242.966009]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47242.966009]  [<c115bec1>] ? __fget+0x61/0xb0
   [47242.966009]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47242.966009]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47242.966009]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47242.968480] Mem-Info:
   [47242.968488] active_anon:28746 inactive_anon:8592 isolated_anon:32
   [47242.968488]  active_file:286801 inactive_file:102183 isolated_file:0
   [47242.968488]  unevictable:7141 dirty:4 writeback:0 unstable:0
   [47242.968488]  slab_reclaimable:36551 slab_unreclaimable:10669
   [47242.968488]  mapped:25999 shmem:6286 pagetables:472 bounce:0
   [47242.968488]  free:288171 free_pcp:175 free_cma:0
   [47242.968499] Node 0 active_anon:114984kB inactive_anon:34368kB active_=
file:1147204kB inactive_file:408732kB unevictable:28564kB isolated(anon):12=
8kB isolated(file):0kB mapped:103996kB dirty:16kB writeback:0kB shmem:0kB s=
hmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 25144kB writeback_tmp:0kB unst=
able:0kB pages_scanned:500002 all_unreclaimable? no
   [47242.968506] DMA free:4068kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:336kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47242.968509] lowmem_reserve[]: 0 833 3008 3008
   [47242.968519] Normal free:42412kB min:42416kB low:53020kB high:63624kB =
active_anon:272kB inactive_anon:20060kB active_file:594224kB inactive_file:=
108kB unevictable:0kB writepending:84kB present:892920kB managed:854340kB m=
locked:0kB slab_reclaimable:144448kB slab_unreclaimable:42340kB kernel_stac=
k:2416kB pagetables:0kB bounce:0kB free_pcp:128kB local_pcp:128kB free_cma:=
0kB
   [47242.968522] lowmem_reserve[]: 0 0 17397 17397
   [47242.968531] HighMem free:1106204kB min:512kB low:28164kB high:55816kB=
 active_anon:114684kB inactive_anon:14352kB active_file:543256kB inactive_f=
ile:408520kB unevictable:28564kB writepending:80kB present:2226888kB manage=
d:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB ker=
nel_stack:0kB pagetables:1888kB bounce:0kB free_pcp:572kB local_pcp:108kB f=
ree_cma:0kB
   [47242.968534] lowmem_reserve[]: 0 0 0 0
   [47242.968539] DMA: 9*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB =
(UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4068kB
   [47242.968559] Normal: 137*4kB (UM) 38*8kB (UM) 56*16kB (UM) 44*32kB (UM=
) 94*64kB (UME) 64*128kB (UME) 40*256kB (UME) 13*512kB (ME) 8*1024kB (UME) =
0*2048kB 0*4096kB =3D 42452kB
   [47242.968577] HighMem: 10*4kB (UM) 13726*8kB (UM) 9638*16kB (UM) 5064*3=
2kB (UM) 2892*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*102=
4kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 1106168kB
   [47242.968597] 397440 total pagecache pages
   [47242.968600] 2 pages in swap cache
   [47242.968602] Swap cache stats: add 7468, delete 7466, find 2638/3243
   [47242.968605] Free swap  =3D 2096116kB
   [47242.968606] Total swap =3D 2096476kB
   [47242.968608] 783948 pages RAM
   [47242.968610] 556722 pages HighMem/MovableOnly
   [47242.968612] 9664 pages reserved
   [47242.968614] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47242.968621] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47242.968629] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47242.968633] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47242.968637] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47242.968641] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47242.968644] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47242.968648] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47242.968652] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47242.968656] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47242.968660] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47242.968663] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47242.968667] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47242.968671] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47242.968675] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47242.968678] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47242.968682] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47242.968686] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47242.968690] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47242.968693] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47242.968697] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47242.968701] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47242.968704] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47242.968708] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47242.968712] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47242.968715] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47242.968719] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47242.968723] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47242.968727] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47242.968730] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47242.968734] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47242.968739] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47242.968742] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47242.968747] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47242.968750] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47242.968754] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47242.968758] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47242.968762] [ 6775]     0  6775      557      138       4       0    =
    0             0 sleep
   [47242.968766] [ 7312]     0  7312    21665     8856      21       0    =
    0             0 Xorg
   [47242.968769] [ 7346]     0  7346     1698     1042       4       0    =
    0             0 wdm
   [47242.968773] [ 7361] 10230  7361    13570     3277      11       0    =
    0             0 fvwm2
   [47242.968777] [ 7414] 10230  7414     1136       54       6       0    =
    0             0 dbus-launch
   [47242.968780] [ 7415] 10230  7415     1075       53       5       0    =
    0             0 dbus-daemon
   [47242.968784] [ 7438] 10230  7438     3690      730       5       0    =
    0             0 tpb
   [47242.968787] [ 7448] 10230  7448     2021     1182       6       0    =
    0             0 xscreensaver
   [47242.968791] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47242.968795] [ 7456] 10230  7456     1284      627       5       0    =
    0             0 autocutsel
   [47242.968799] [ 7463] 10230  7463    10919     5147      12       0    =
    0             0 gkrellm
   [47242.968803] [ 7464] 10230  7464    48136    16251      36       0    =
    0             0 psi-plus
   [47242.968806] [ 7465] 10230  7465    10775     7074      15       0    =
    0             0 wicd-client
   [47242.968810] [ 7486] 10230  7486     1047      297       5       0    =
    0             0 FvwmCommandS
   [47242.968814] [ 7487] 10230  7487     1528      475       5       0    =
    0             0 FvwmEvent
   [47242.968818] [ 7488] 10230  7488    12182     2081      10       0    =
    0             0 FvwmAnimate
   [47242.968821] [ 7489] 10230  7489    12808     2467      11       0    =
    0             0 FvwmButtons
   [47242.968825] [ 7490] 10230  7490    13311     2727      11       0    =
    0             0 FvwmProxy
   [47242.968829] [ 7491] 10230  7491     1507      434       5       0    =
    0             0 FvwmAuto
   [47242.968832] [ 7496] 10230  7496    12803     2396      11       0    =
    0             0 FvwmPager
   [47242.968836] [ 7498] 10230  7498      581      144       4       0    =
    0             0 sh
   [47242.968840] [ 7499] 10230  7499     1030      702       5       0    =
    0             0 stalonetray
   [47242.968844] [ 7517] 10230  7517     2684     1551       6       0    =
    0             0 xterm
   [47242.968847] [ 7521] 10230  7521     1707     1013       5       0    =
    0             0 zsh
   [47242.968851] [ 7527]     0  7527     2974      213       5       0    =
    0             0 udevd
   [47242.968855] [ 7528]     0  7528     2974      213       5       0    =
    0             0 udevd
   [47242.968858] [ 7529] 10230  7529     2684     1643       6       0    =
    0             0 lsb_release
   [47242.968862] [ 7530]     0  7530     2974      213       5       0    =
    0             0 udevd
   [47242.968866] [ 7531]     0  7531     2974      213       5       0    =
    0             0 udevd
   [47242.968869] [ 7532]     0  7532     2974      213       5       0    =
    0             0 udevd
   [47242.968873] [ 7533]     0  7533     2974      213       5       0    =
    0             0 udevd
   [47242.968877] [ 7534] 10230  7534     8004     1414       5       0    =
    0             0 apt-cache
   [47242.968880] Out of memory: Kill process 7464 (psi-plus) score 12 or s=
acrifice child
   [47242.968891] Killed process 7529 (lsb_release) total-vm:10736kB, anon-=
rss:2376kB, file-rss:4196kB, shmem-rss:0kB

   [47434.260556] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47434.260559] Xorg cpuset=3D/ mems_allowed=3D0
   [47434.260567] CPU: 0 PID: 7312 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47434.260570] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47434.260573]  00200286 bb044c6f c12b1260 f080b9f0 e9d0ca40 c113c257 c1=
5933a0 e9d0e6a4
   [47434.260581]  024200d4 f080b9fc 00000000 00000000 00000000 00200206 c1=
2b63ef 00000000
   [47434.260588]  f447d0d8 0001e300 e9d0ca40 e9d0ce6c c15910eb f080b9f0 c1=
0e7b4e c105fe23
   [47434.260596] Call Trace:
   [47434.260604]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47434.260610]  [<c113c257>] ? dump_header+0x43/0x19f
   [47434.260614]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47434.260619]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47434.260623]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47434.260627]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47434.260631]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47434.260635]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47434.260639]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47434.260644]  [<c111e117>] ? __read_swap_cache_async+0x107/0x1d0
   [47434.260647]  [<c111e205>] ? read_swap_cache_async+0x25/0x50
   [47434.260651]  [<c111e30b>] ? swapin_readahead+0xdb/0x180
   [47434.260654]  [<c10fb8eb>] ? shmem_getpage_gfp+0x8ab/0xbb0
   [47434.260660]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47434.260688]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47434.260712]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47434.260717]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47434.260740]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47434.260763]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47434.260786]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47434.260810]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47434.260835]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47434.260858]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47434.260880]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47434.260903]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47434.260928]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47434.260932]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47434.260935]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47434.260958]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47434.260980]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47434.260992]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47434.261012]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47434.261012]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47434.261012]  [<c102181f>] ? __fpu__restore_sig+0x22f/0x410
   [47434.261012]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47434.261012]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47434.261012]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47434.261012]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47434.261012]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47434.261012]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47434.261012]  [<c115bec1>] ? __fget+0x61/0xb0
   [47434.261012]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47434.261012]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47434.261012]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47434.261103] Mem-Info:
   [47434.261110] active_anon:44243 inactive_anon:8158 isolated_anon:0
   [47434.261110]  active_file:287934 inactive_file:126135 isolated_file:0
   [47434.261110]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47434.261110]  slab_reclaimable:36794 slab_unreclaimable:10849
   [47434.261110]  mapped:27474 shmem:5829 pagetables:564 bounce:0
   [47434.261110]  free:247495 free_pcp:52 free_cma:0
   [47434.261120] Node 0 active_anon:176972kB inactive_anon:32632kB active_=
file:1151736kB inactive_file:504540kB unevictable:28564kB isolated(anon):0k=
B isolated(file):0kB mapped:109896kB dirty:0kB writeback:0kB shmem:0kB shme=
m_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 23316kB writeback_tmp:0kB unstabl=
e:0kB pages_scanned:182064 all_unreclaimable? no
   [47434.261133] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47434.261139] lowmem_reserve[]: 0 833 3008 3008
   [47434.261169] Normal free:42308kB min:42416kB low:53020kB high:63624kB =
active_anon:220kB inactive_anon:17736kB active_file:594856kB inactive_file:=
120kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB ml=
ocked:0kB slab_reclaimable:145420kB slab_unreclaimable:43064kB kernel_stack=
:2520kB pagetables:0kB bounce:0kB free_pcp:208kB local_pcp:208kB free_cma:0=
kB
   [47434.261176] lowmem_reserve[]: 0 0 17397 17397
   [47434.261204] HighMem free:943600kB min:512kB low:28164kB high:55816kB =
active_anon:176752kB inactive_anon:14892kB active_file:547156kB inactive_fi=
le:504420kB unevictable:28564kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:2256kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cm=
a:0kB
   [47434.261210] lowmem_reserve[]: 0 0 0 0
   [47434.261234] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47434.261261] Normal: 123*4kB (ME) 127*8kB (ME) 32*16kB (UM) 52*32kB (U=
ME) 92*64kB (UME) 62*128kB (ME) 41*256kB (UME) 14*512kB (UME) 7*1024kB (UME=
) 0*2048kB 0*4096kB =3D 42340kB
   [47434.261280] HighMem: 76*4kB (UM) 70*8kB (UM) 6291*16kB (UM) 5063*32kB=
 (UM) 2892*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*1024kB=
 (M) 24*2048kB (M) 14*4096kB (UM) =3D 943600kB
   [47434.261300] 422124 total pagecache pages
   [47434.261303] 17 pages in swap cache
   [47434.261305] Swap cache stats: add 8787, delete 8770, find 3173/3862
   [47434.261307] Free swap  =3D 2095352kB
   [47434.261309] Total swap =3D 2096476kB
   [47434.261311] 783948 pages RAM
   [47434.261313] 556722 pages HighMem/MovableOnly
   [47434.261315] 9664 pages reserved
   [47434.261317] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47434.261323] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47434.261329] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47434.261333] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47434.261336] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47434.261340] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47434.261344] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47434.261347] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47434.261351] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47434.261355] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47434.261359] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47434.261362] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47434.261366] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47434.261369] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47434.261373] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47434.261376] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47434.261380] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47434.261383] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47434.261387] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47434.261390] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47434.261394] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47434.261398] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47434.261401] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47434.261405] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47434.261408] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47434.261412] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47434.261416] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47434.261419] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47434.261423] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47434.261426] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47434.261430] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47434.261434] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47434.261438] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47434.261442] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47434.261445] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47434.261449] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47434.261452] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47434.261456] [ 7312]     0  7312    22596     9165      23       0    =
    0             0 Xorg
   [47434.261460] [ 7346]     0  7346     1698     1042       4       0    =
    0             0 wdm
   [47434.261463] [ 7361] 10230  7361    13570     3286      11       0    =
    0             0 fvwm2
   [47434.261467] [ 7414] 10230  7414     1136       54       6       0    =
    0             0 dbus-launch
   [47434.261471] [ 7415] 10230  7415     1075       53       5       0    =
    0             0 dbus-daemon
   [47434.261474] [ 7438] 10230  7438     3690      730       5       0    =
    0             0 tpb
   [47434.261607] [ 7448] 10230  7448     2021     1182       6       0    =
    0             0 xscreensaver
   [47434.261611] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47434.261615] [ 7456] 10230  7456     1284      627       5       0    =
    0             0 autocutsel
   [47434.261618] [ 7463] 10230  7463    10919     5147      12       0    =
    0             0 gkrellm
   [47434.261622] [ 7464] 10230  7464    49061    17112      37       0    =
    0             0 psi-plus
   [47434.261626] [ 7465] 10230  7465    10775     7175      15       0    =
    0             0 wicd-client
   [47434.261629] [ 7486] 10230  7486     1047      297       5       0    =
    0             0 FvwmCommandS
   [47434.261633] [ 7487] 10230  7487     1528      475       5       0    =
    0             0 FvwmEvent
   [47434.261637] [ 7488] 10230  7488    12182     2081      10       0    =
    0             0 FvwmAnimate
   [47434.261640] [ 7489] 10230  7489    12808     2467      11       0    =
    0             0 FvwmButtons
   [47434.261644] [ 7490] 10230  7490    13311     2727      11       0    =
    0             0 FvwmProxy
   [47434.261648] [ 7491] 10230  7491     1507      434       5       0    =
    0             0 FvwmAuto
   [47434.261652] [ 7496] 10230  7496    12803     2396      11       0    =
    0             0 FvwmPager
   [47434.261655] [ 7498] 10230  7498      581      144       4       0    =
    0             0 sh
   [47434.261659] [ 7499] 10230  7499     1030      702       5       0    =
    0             0 stalonetray
   [47434.261663] [ 7517] 10230  7517     2725     1557       6       0    =
    0             0 xterm
   [47434.261666] [ 7521] 10230  7521     1903     1248       5       0    =
    0             0 zsh
   [47434.261669] [ 7706] 10230  7706     1420      666       5       0    =
    0             0 top
   [47434.261673] [ 7724] 10230  7724     2683     1545       6       0    =
    0             0 xterm
   [47434.261676] [ 7728] 10230  7728     2495     1223       6       0    =
    0             0 ssh
   [47434.261680] [ 7739]     0  7739     2484     1835       8       0    =
    0             0 zsh
   [47434.261684] [ 8077]     0  8077    16483    15491      23       0    =
    0             0 apt-get
   [47434.261687] [ 8091]     0  8091      557      148       4       0    =
    0             0 sleep
   [47434.261691] [ 8102]     0  8102    16483    13958      22       0    =
    0             0 apt-get
   [47434.261694] [ 8103]     0  8103      581      142       4       0    =
    0             0 sh
   [47434.261698] [ 8104]     0  8104      581      149       4       0    =
    0             0 etckeeper
   [47434.261702] [ 8126]     0  8126      581      147       4       0    =
    0             0 50uncommitted-c
   [47434.261705] [ 8139]     0  8139      581      385       4       0    =
    0             0 etckeeper
   [47434.261709] [ 8171]     0  8171      581      384       4       0    =
    0             0 50vcs-commit
   [47434.261712] [ 8185]     0  8185    11283     1197      11       0    =
    0             0 git
   [47434.261716] [ 8191]     0  8191      581      146       4       0    =
    0             0 pre-commit
   [47434.261719] [ 8192]     0  8192      581      143       4       0    =
    0             0 etckeeper
   [47434.261723] [ 8197]     0  8197      581      152       4       0    =
    0             0 20warn-problem-
   [47434.261726] [ 8202]     0  8202      581       19       4       0    =
    0             0 20warn-problem-
   [47434.261730] [ 8203]     0  8203     1464      639       5       0    =
    0             0 find
   [47434.261733] [ 8204]     0  8204      581       20       4       0    =
    0             0 20warn-problem-
   [47434.261737] [ 8205]     0  8205     1285      473       5       0    =
    0             0 grep
   [47434.261740] Out of memory: Kill process 7464 (psi-plus) score 13 or s=
acrifice child
   [47434.261759] Killed process 7464 (psi-plus) total-vm:196244kB, anon-rs=
s:27604kB, file-rss:40304kB, shmem-rss:540kB

   [47458.375553] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47458.375556] Xorg cpuset=3D/ mems_allowed=3D0
   [47458.375564] CPU: 0 PID: 7312 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47458.375567] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47458.375570]  00200286 bb044c6f c12b1260 f080b9f0 e9d0d280 c113c257 c1=
5933a0 e9d0e6a4
   [47458.375578]  024200d4 f080b9fc 00000000 00000000 00000000 00200206 c1=
2b63ef 00000000
   [47458.375585]  f447d0d8 0001e300 e9d0d280 e9d0d6ac c15910eb f080b9f0 c1=
0e7b4e c105fe23
   [47458.375592] Call Trace:
   [47458.375601]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47458.375606]  [<c113c257>] ? dump_header+0x43/0x19f
   [47458.375610]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47458.375615]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47458.375620]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47458.375624]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47458.375627]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47458.375631]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47458.375635]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47458.375640]  [<c111e117>] ? __read_swap_cache_async+0x107/0x1d0
   [47458.375643]  [<c111e205>] ? read_swap_cache_async+0x25/0x50
   [47458.375647]  [<c111e30b>] ? swapin_readahead+0xdb/0x180
   [47458.375651]  [<c10fb8eb>] ? shmem_getpage_gfp+0x8ab/0xbb0
   [47458.375656]  [<c138d1f4>] ? pm_runtime_get_if_in_use+0x54/0xa0
   [47458.375685]  [<f8872174>] ? intel_runtime_pm_get_if_in_use+0x14/0xf0 =
[i915]
   [47458.375709]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47458.375714]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47458.375737]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47458.375760]  [<f8888841>] ? ggtt_bind_vma+0x41/0x70 [i915]
   [47458.375784]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47458.375807]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47458.375832]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47458.375855]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47458.375877]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47458.375900]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47458.375925]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47458.375929]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47458.375932]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47458.375955]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47458.375977]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47458.375989]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47458.375994]  [<c1042c3a>] ? kmap_atomic+0xa/0x10
   [47458.375997]  [<c110dd48>] ? __get_locked_pte+0x68/0x90
   [47458.376011]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47458.376011]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47458.376011]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47458.376011]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47458.376011]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47458.376011]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47458.376011]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47458.376011]  [<c115bec1>] ? __fget+0x61/0xb0
   [47458.376011]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47458.376011]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47458.376011]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47458.386053] Mem-Info:
   [47458.386062] active_anon:37386 inactive_anon:8013 isolated_anon:0
   [47458.386062]  active_file:288156 inactive_file:126014 isolated_file:0
   [47458.386062]  unevictable:7141 dirty:0 writeback:0 unstable:0
   [47458.386062]  slab_reclaimable:36514 slab_unreclaimable:10808
   [47458.386062]  mapped:20142 shmem:5694 pagetables:527 bounce:0
   [47458.386062]  free:254683 free_pcp:125 free_cma:0
   [47458.386073] Node 0 active_anon:149544kB inactive_anon:32052kB active_=
file:1152624kB inactive_file:504056kB unevictable:28564kB isolated(anon):0k=
B isolated(file):0kB mapped:80568kB dirty:0kB writeback:0kB shmem:0kB shmem=
_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 22776kB writeback_tmp:0kB unstable=
:0kB pages_scanned:493606 all_unreclaimable? no
   [47458.386080] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47458.386083] lowmem_reserve[]: 0 833 3008 3008
   [47458.386093] Normal free:42408kB min:42416kB low:53020kB high:63624kB =
active_anon:220kB inactive_anon:17640kB active_file:596108kB inactive_file:=
92kB unevictable:0kB writepending:0kB present:892920kB managed:854340kB mlo=
cked:0kB slab_reclaimable:144300kB slab_unreclaimable:42900kB kernel_stack:=
2472kB pagetables:0kB bounce:0kB free_pcp:268kB local_pcp:72kB free_cma:0kB
   [47458.386096] lowmem_reserve[]: 0 0 17397 17397
   [47458.386105] HighMem free:972252kB min:512kB low:28164kB high:55816kB =
active_anon:149324kB inactive_anon:14392kB active_file:546792kB inactive_fi=
le:503964kB unevictable:28564kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:2108kB bounce:0kB free_pcp:232kB local_pcp:232kB fre=
e_cma:0kB
   [47458.386108] lowmem_reserve[]: 0 0 0 0
   [47458.386113] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47458.386133] Normal: 90*4kB (UME) 130*8kB (ME) 72*16kB (ME) 50*32kB (U=
ME) 96*64kB (ME) 63*128kB (ME) 40*256kB (ME) 13*512kB (ME) 7*1024kB (UME) 0=
*2048kB 0*4096kB =3D 42424kB
   [47458.386151] HighMem: 6079*4kB (UM) 642*8kB (UM) 6293*16kB (UM) 5064*3=
2kB (UM) 2892*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*102=
4kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 972252kB
   [47458.386171] 422106 total pagecache pages
   [47458.386174] 16 pages in swap cache
   [47458.386177] Swap cache stats: add 11434, delete 11418, find 4298/5278
   [47458.386179] Free swap  =3D 2095524kB
   [47458.386181] Total swap =3D 2096476kB
   [47458.386183] 783948 pages RAM
   [47458.386185] 556722 pages HighMem/MovableOnly
   [47458.386187] 9664 pages reserved
   [47458.386189] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47458.386197] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47458.386208] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47458.386212] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47458.386216] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47458.386220] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47458.386224] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47458.386228] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47458.386232] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47458.386236] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47458.386240] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47458.386243] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47458.386247] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47458.386252] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47458.386256] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47458.386260] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47458.386263] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47458.386267] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47458.386271] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47458.386275] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47458.386279] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47458.386282] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47458.386286] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47458.386290] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47458.386294] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47458.386298] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47458.386302] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47458.386306] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47458.386310] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47458.386314] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47458.386318] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47458.386323] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47458.386327] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47458.386332] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47458.386336] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47458.386340] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47458.386344] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47458.386349] [ 7312]     0  7312    22526     9064      23       0    =
    0             0 Xorg
   [47458.386352] [ 7346]     0  7346     1698     1042       4       0    =
    0             0 wdm
   [47458.386356] [ 7361] 10230  7361    13570     3286      11       0    =
    0             0 fvwm2
   [47458.386360] [ 7414] 10230  7414     1136       54       6       0    =
    0             0 dbus-launch
   [47458.386364] [ 7415] 10230  7415     1075       53       5       0    =
    0             0 dbus-daemon
   [47458.386368] [ 7438] 10230  7438     3690      730       5       0    =
    0             0 tpb
   [47458.386372] [ 7448] 10230  7448     2021     1182       6       0    =
    0             0 xscreensaver
   [47458.386375] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47458.386379] [ 7456] 10230  7456     1284      627       5       0    =
    0             0 autocutsel
   [47458.386383] [ 7463] 10230  7463    10919     5147      12       0    =
    0             0 gkrellm
   [47458.386387] [ 7465] 10230  7465    10775     7175      15       0    =
    0             0 wicd-client
   [47458.386391] [ 7486] 10230  7486     1047      297       5       0    =
    0             0 FvwmCommandS
   [47458.386395] [ 7487] 10230  7487     1528      475       5       0    =
    0             0 FvwmEvent
   [47458.386399] [ 7488] 10230  7488    12182     2081      10       0    =
    0             0 FvwmAnimate
   [47458.386403] [ 7489] 10230  7489    12808     2467      11       0    =
    0             0 FvwmButtons
   [47458.386407] [ 7490] 10230  7490    13311     2727      11       0    =
    0             0 FvwmProxy
   [47458.386411] [ 7491] 10230  7491     1507      434       5       0    =
    0             0 FvwmAuto
   [47458.386415] [ 7496] 10230  7496    12803     2396      11       0    =
    0             0 FvwmPager
   [47458.386418] [ 7498] 10230  7498      581      144       4       0    =
    0             0 sh
   [47458.386422] [ 7499] 10230  7499     1063      702       5       0    =
    0             0 stalonetray
   [47458.386426] [ 7517] 10230  7517     2725     1557       6       0    =
    0             0 xterm
   [47458.386430] [ 7521] 10230  7521     1903     1248       5       0    =
    0             0 zsh
   [47458.386434] [ 7706] 10230  7706     1420      666       5       0    =
    0             0 top
   [47458.386438] [ 7724] 10230  7724     2683     1545       6       0    =
    0             0 xterm
   [47458.386441] [ 7728] 10230  7728     2495     1223       6       0    =
    0             0 ssh
   [47458.386445] [ 7739]     0  7739     2484     1835       8       0    =
    0             0 zsh
   [47458.386449] [ 8077]     0  8077    16483    15491      23       0    =
    0             0 apt-get
   [47458.386453] [ 8091]     0  8091      557      148       4       0    =
    0             0 sleep
   [47458.386457] [ 8102]     0  8102    16483    13958      22       0    =
    0             0 apt-get
   [47458.386461] [ 8103]     0  8103      581      142       4       0    =
    0             0 sh
   [47458.386465] [ 8104]     0  8104      581      149       4       0    =
    0             0 etckeeper
   [47458.386468] [ 8126]     0  8126      581      147       4       0    =
    0             0 50uncommitted-c
   [47458.386472] [ 8139]     0  8139      581      385       4       0    =
    0             0 etckeeper
   [47458.386476] [ 8171]     0  8171      581      384       4       0    =
    0             0 50vcs-commit
   [47458.386480] [ 8185]     0  8185    11283     1197      11       0    =
    0             0 git
   [47458.386483] [ 8191]     0  8191      581      146       4       0    =
    0             0 pre-commit
   [47458.386487] [ 8192]     0  8192      581      143       4       0    =
    0             0 etckeeper
   [47458.386491] [ 8197]     0  8197      581      152       4       0    =
    0             0 20warn-problem-
   [47458.386495] [ 8202]     0  8202      581       19       4       0    =
    0             0 20warn-problem-
   [47458.386499] [ 8203]     0  8203     1464      639       5       0    =
    0             0 find
   [47458.386503] [ 8204]     0  8204      581       20       4       0    =
    0             0 20warn-problem-
   [47458.386507] [ 8205]     0  8205     1285      473       5       0    =
    0             0 grep
   [47458.386510] Out of memory: Kill process 8077 (apt-get) score 11 or sa=
crifice child
   [47458.386519] Killed process 8102 (apt-get) total-vm:65932kB, anon-rss:=
55832kB, file-rss:0kB, shmem-rss:0kB

   [47480.356401] btrfs-transacti invoked oom-killer: gfp_mask=3D0x2400840(=
GFP_NOFS|__GFP_NOFAIL), order=3D0, oom_score_adj=3D0
   [47480.356404] btrfs-transacti cpuset=3D/ mems_allowed=3D0
   [47480.356412] CPU: 0 PID: 85 Comm: btrfs-transacti Tainted: G     U    =
 O    4.8.15 #1
   [47480.356415] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47480.356418]  00000286 50ab7fd6 c12b1260 f4d5da18 e9d0e300 c113c257 c1=
5933a0 f4c6a4a4
   [47480.356426]  02400840 f4d5da24 00000000 00000000 02400840 00000206 c1=
2b63ef 00000000
   [47480.356434]  0000000c f4c6a100 e9d0e300 e9d0e72c c15910eb f4d5da18 c1=
0e7b4e c105fe23
   [47480.356441] Call Trace:
   [47480.356450]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47480.356455]  [<c113c257>] ? dump_header+0x43/0x19f
   [47480.356459]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47480.356464]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47480.356468]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47480.356472]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47480.356476]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47480.356480]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47480.356484]  [<c10eba31>] ? __alloc_pages_nodemask+0xa71/0xb30
   [47480.356488]  [<c10e3e0a>] ? pagecache_get_page+0xaa/0x250
   [47480.356492]  [<c11ffb73>] ? __alloc_extent_buffer+0x93/0xd0
   [47480.356496]  [<c1207ccf>] ? alloc_extent_buffer+0x13f/0x450
   [47480.356501]  [<c11c8daf>] ? btrfs_alloc_tree_block+0x22f/0x670
   [47480.356506]  [<c11ad9a7>] ? __btrfs_cow_block+0x177/0x690
   [47480.356510]  [<c11afb23>] ? read_block_for_search.isra.32+0xa3/0x3b0
   [47480.356513]  [<c11ae082>] ? btrfs_cow_block+0x142/0x1b0
   [47480.356517]  [<c11b1985>] ? btrfs_search_slot+0x205/0x950
   [47480.356521]  [<c11ba0be>] ? lookup_inline_extent_backref+0x1ce/0x7c0
   [47480.356525]  [<c11bb2f0>] ? update_block_group.isra.73+0x130/0x410
   [47480.356529]  [<c112ac7f>] ? kmem_cache_alloc+0xaf/0x100
   [47480.356532]  [<c11bb761>] ? __btrfs_free_extent+0x191/0x10e0
   [47480.356538]  [<c12395ae>] ? btrfs_merge_delayed_refs+0x7e/0x570
   [47480.356541]  [<c11c0933>] ? __btrfs_run_delayed_refs+0x4e3/0x1240
   [47480.356546]  [<c11c468d>] ? btrfs_run_delayed_refs+0x7d/0x270
   [47480.356550]  [<c11db938>] ? btrfs_commit_transaction+0x88/0xc00
   [47480.356554]  [<c112ac7f>] ? kmem_cache_alloc+0xaf/0x100
   [47480.356557]  [<c11dc5cf>] ? start_transaction+0x11f/0x430
   [47480.356560]  [<c11dc518>] ? start_transaction+0x68/0x430
   [47480.356564]  [<c14b94d9>] ? schedule_timeout+0x129/0x200
   [47480.356568]  [<c1065e32>] ? ttwu_do_activate+0x32/0x60
   [47480.356573]  [<c11d697d>] ? transaction_kthread+0x19d/0x1e0
   [47480.356577]  [<c11d67e0>] ? btrfs_cleanup_transaction+0x490/0x490
   [47480.356580]  [<c105f344>] ? kthread+0xa4/0xc0
   [47480.356585]  [<c14ba2e2>] ? ret_from_kernel_thread+0xe/0x24
   [47480.356588]  [<c105f2a0>] ? kthread_worker_fn+0x120/0x120
   [47480.356591] Mem-Info:
   [47480.356597] active_anon:23150 inactive_anon:8050 isolated_anon:0
   [47480.356597]  active_file:288475 inactive_file:126485 isolated_file:0
   [47480.356597]  unevictable:7141 dirty:81 writeback:0 unstable:0
   [47480.356597]  slab_reclaimable:36460 slab_unreclaimable:10798
   [47480.356597]  mapped:18848 shmem:5699 pagetables:433 bounce:0
   [47480.356597]  free:268316 free_pcp:123 free_cma:0
   [47480.356608] Node 0 active_anon:92600kB inactive_anon:32200kB active_f=
ile:1153900kB inactive_file:505940kB unevictable:28564kB isolated(anon):0kB=
 isolated(file):0kB mapped:75392kB dirty:324kB writeback:0kB shmem:0kB shme=
m_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 22796kB writeback_tmp:0kB unstabl=
e:0kB pages_scanned:2689846 all_unreclaimable? yes
   [47480.356615] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47480.356617] lowmem_reserve[]: 0 833 3008 3008
   [47480.356627] Normal free:42344kB min:42416kB low:53020kB high:63624kB =
active_anon:220kB inactive_anon:17812kB active_file:596564kB inactive_file:=
68kB unevictable:0kB writepending:324kB present:892920kB managed:854340kB m=
locked:0kB slab_reclaimable:144084kB slab_unreclaimable:42860kB kernel_stac=
k:2360kB pagetables:0kB bounce:0kB free_pcp:244kB local_pcp:120kB free_cma:=
0kB
   [47480.356630] lowmem_reserve[]: 0 0 17397 17397
   [47480.356639] HighMem free:1026848kB min:512kB low:28164kB high:55816kB=
 active_anon:92380kB inactive_anon:14388kB active_file:547612kB inactive_fi=
le:505872kB unevictable:28564kB writepending:0kB present:2226888kB managed:=
2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB kerne=
l_stack:0kB pagetables:1732kB bounce:0kB free_pcp:248kB local_pcp:48kB free=
_cma:0kB
   [47480.356642] lowmem_reserve[]: 0 0 0 0
   [47480.356647] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47480.356667] Normal: 86*4kB (ME) 122*8kB (ME) 62*16kB (UME) 61*32kB (U=
ME) 97*64kB (UME) 65*128kB (UME) 40*256kB (ME) 14*512kB (UME) 6*1024kB (ME)=
 0*2048kB 0*4096kB =3D 42344kB
   [47480.356685] HighMem: 5588*4kB (UM) 6702*8kB (UM) 6796*16kB (UM) 5065*=
32kB (UM) 2892*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*10=
24kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 1026848kB
   [47480.356705] 422894 total pagecache pages
   [47480.356708] 30 pages in swap cache
   [47480.356711] Swap cache stats: add 13017, delete 12987, find 4982/6148
   [47480.356713] Free swap  =3D 2095516kB
   [47480.356715] Total swap =3D 2096476kB
   [47480.356717] 783948 pages RAM
   [47480.356718] 556722 pages HighMem/MovableOnly
   [47480.356720] 9664 pages reserved
   [47480.356722] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47480.356728] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47480.356733] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47480.356737] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47480.356741] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47480.356744] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47480.356748] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47480.356752] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47480.356755] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47480.356759] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47480.356763] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47480.356766] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47480.356770] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47480.356774] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47480.356777] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47480.356781] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47480.356785] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47480.356788] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47480.356792] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47480.356795] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47480.356799] [ 2531]     0  2531     8820     4029      11       0    =
    0             0 wicd
   [47480.356802] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47480.356806] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47480.356809] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47480.356813] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47480.356816] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47480.356820] [ 2733]     0  2733      553      129       4       0    =
    0             0 mingetty
   [47480.356824] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47480.356827] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47480.356831] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47480.356834] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47480.356838] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47480.356842] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47480.356846] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47480.356850] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47480.356853] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47480.356857] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47480.356861] [ 7312]     0  7312    22510     9064      23       0    =
    0             0 Xorg
   [47480.356864] [ 7346]     0  7346     1698     1042       4       0    =
    0             0 wdm
   [47480.356868] [ 7361] 10230  7361    13570     3286      11       0    =
    0             0 fvwm2
   [47480.356871] [ 7414] 10230  7414     1136       54       6       0    =
    0             0 dbus-launch
   [47480.356875] [ 7415] 10230  7415     1075       53       5       0    =
    0             0 dbus-daemon
   [47480.356878] [ 7438] 10230  7438     3690      730       5       0    =
    0             0 tpb
   [47480.356882] [ 7448] 10230  7448     2021     1182       6       0    =
    0             0 xscreensaver
   [47480.356885] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47480.356889] [ 7456] 10230  7456     1284      627       5       0    =
    0             0 autocutsel
   [47480.356892] [ 7463] 10230  7463    10919     5147      12       0    =
    0             0 gkrellm
   [47480.356896] [ 7465] 10230  7465    10775     7175      15       0    =
    0             0 wicd-client
   [47480.356899] [ 7486] 10230  7486     1047      297       5       0    =
    0             0 FvwmCommandS
   [47480.356903] [ 7487] 10230  7487     1528      475       5       0    =
    0             0 FvwmEvent
   [47480.356907] [ 7488] 10230  7488    12182     2081      10       0    =
    0             0 FvwmAnimate
   [47480.356910] [ 7489] 10230  7489    12808     2467      11       0    =
    0             0 FvwmButtons
   [47480.356914] [ 7490] 10230  7490    13311     2727      11       0    =
    0             0 FvwmProxy
   [47480.356917] [ 7491] 10230  7491     1507      434       5       0    =
    0             0 FvwmAuto
   [47480.356921] [ 7496] 10230  7496    12803     2396      11       0    =
    0             0 FvwmPager
   [47480.356925] [ 7498] 10230  7498      581      144       4       0    =
    0             0 sh
   [47480.356928] [ 7499] 10230  7499     1063      702       5       0    =
    0             0 stalonetray
   [47480.356932] [ 7517] 10230  7517     2725     1557       6       0    =
    0             0 xterm
   [47480.356935] [ 7521] 10230  7521     1903     1248       5       0    =
    0             0 zsh
   [47480.356939] [ 7706] 10230  7706     1420      666       5       0    =
    0             0 top
   [47480.356942] [ 7724] 10230  7724     2683     1545       6       0    =
    0             0 xterm
   [47480.356946] [ 7728] 10230  7728     2495     1223       6       0    =
    0             0 ssh
   [47480.356949] [ 7739]     0  7739     2484     1836       8       0    =
    0             0 zsh
   [47480.356953] [ 8091]     0  8091      557      148       4       0    =
    0             0 sleep
   [47480.356956] [ 8252]     0  8252     8563     3041      11       0    =
    0             0 wicd
   [47480.356959] Out of memory: Kill process 7312 (Xorg) score 6 or sacrif=
ice child
   [47480.356969] Killed process 7312 (Xorg) total-vm:90040kB, anon-rss:199=
68kB, file-rss:15412kB, shmem-rss:876kB

   [47538.670798] dpkg invoked oom-killer: gfp_mask=3D0x2400840(GFP_NOFS|__=
GFP_NOFAIL), order=3D0, oom_score_adj=3D0
   [47538.670869] dpkg cpuset=3D/ mems_allowed=3D0
   [47538.670921] CPU: 1 PID: 8655 Comm: dpkg Tainted: G     U     O    4.8=
=2E15 #1
   [47538.670966] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47538.671012]  00000286 b2e7b078 c12b1260 eb8bdacc f3698840 c113c257 c1=
5933a0 eb94ace4
   [47538.671012]  02400840 eb8bdad8 00000000 00000000 02400840 00000206 c1=
2b63ef 00000000
   [47538.671012]  f447d0d8 0101a940 f3698840 f3698c6c c15910eb eb8bdacc c1=
0e7b4e c105fe23
   [47538.671012] Call Trace:
   [47538.671012]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47538.671012]  [<c113c257>] ? dump_header+0x43/0x19f
   [47538.671012]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47538.671012]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47538.671012]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47538.671012]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47538.671012]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47538.671012]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47538.671012]  [<c10eba31>] ? __alloc_pages_nodemask+0xa71/0xb30
   [47538.671012]  [<c10e3e0a>] ? pagecache_get_page+0xaa/0x250
   [47538.671012]  [<c11ffb73>] ? __alloc_extent_buffer+0x93/0xd0
   [47538.671012]  [<c1207ccf>] ? alloc_extent_buffer+0x13f/0x450
   [47538.671012]  [<c11c8daf>] ? btrfs_alloc_tree_block+0x22f/0x670
   [47538.671012]  [<c12bf2b4>] ? __sg_alloc_table+0x74/0x160
   [47538.671012]  [<c11ad9a7>] ? __btrfs_cow_block+0x177/0x690
   [47538.671012]  [<c12096a7>] ? map_private_extent_buffer+0x57/0xd0
   [47538.671012]  [<c11ae082>] ? btrfs_cow_block+0x142/0x1b0
   [47538.671012]  [<c11b1985>] ? btrfs_search_slot+0x205/0x950
   [47538.671012]  [<c112ac7f>] ? kmem_cache_alloc+0xaf/0x100
   [47538.671012]  [<c11d0544>] ? btrfs_del_inode_ref+0x84/0x330
   [47538.671012]  [<c11b5732>] ? block_rsv_add_bytes+0x22/0xa0
   [47538.671012]  [<c124385d>] ? __btrfs_add_delayed_item+0x7d/0x130
   [47538.671012]  [<c1245b4a>] ? btrfs_delete_delayed_dir_index+0x11a/0x270
   [47538.671012]  [<c122f1bd>] ? btrfs_del_inode_ref_in_log+0xed/0x1a0
   [47538.671012]  [<c11e373c>] ? __btrfs_unlink_inode+0x22c/0x520
   [47538.671012]  [<c1097900>] ? SYSC_adjtimex+0x70/0x80
   [47538.671012]  [<c11edef0>] ? btrfs_rename2+0x590/0x1870
   [47538.671012]  [<c10c4b00>] ? audit_uid_comparator+0x80/0x80
   [47538.671012]  [<c10c7096>] ? __audit_inode_child+0x236/0x330
   [47538.671012]  [<c114c385>] ? vfs_rename+0x145/0x9d0
   [47538.671012]  [<c11ed960>] ? btrfs_add_link+0x4f0/0x4f0
   [47538.671012]  [<c114c733>] ? vfs_rename+0x4f3/0x9d0
   [47538.671012]  [<c114a1df>] ? __lookup_hash+0xf/0x70
   [47538.671012]  [<c1150831>] ? SyS_rename+0x361/0x380
   [47538.671012]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47538.671012]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47538.740173] Mem-Info:
   [47538.742047] active_anon:31356 inactive_anon:6275 isolated_anon:0
   [47538.742047]  active_file:304003 inactive_file:121495 isolated_file:0
   [47538.742047]  unevictable:7141 dirty:507 writeback:0 unstable:0
   [47538.742047]  slab_reclaimable:36566 slab_unreclaimable:10561
   [47538.742047]  mapped:25849 shmem:3919 pagetables:317 bounce:0
   [47538.742047]  free:251749 free_pcp:456 free_cma:0
   [47538.742052] Node 0 active_anon:125424kB inactive_anon:25100kB active_=
file:1216012kB inactive_file:485980kB unevictable:28564kB isolated(anon):0k=
B isolated(file):0kB mapped:103396kB dirty:2028kB writeback:0kB shmem:0kB s=
hmem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 15676kB writeback_tmp:0kB unst=
able:0kB pages_scanned:0 all_unreclaimable? no
   [47538.742057] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47538.742059] lowmem_reserve[]: 0 833 3008 3008
   [47538.742065] Normal free:42324kB min:42416kB low:53020kB high:63624kB =
active_anon:0kB inactive_anon:11536kB active_file:604000kB inactive_file:11=
6kB unevictable:0kB writepending:1584kB present:892920kB managed:854340kB m=
locked:0kB slab_reclaimable:144508kB slab_unreclaimable:41912kB kernel_stac=
k:2240kB pagetables:0kB bounce:0kB free_pcp:1032kB local_pcp:340kB free_cma=
:0kB
   [47538.742067] lowmem_reserve[]: 0 0 17397 17397
   [47538.742072] HighMem free:960600kB min:512kB low:28164kB high:55816kB =
active_anon:125424kB inactive_anon:13564kB active_file:602288kB inactive_fi=
le:485864kB unevictable:28564kB writepending:444kB present:2226888kB manage=
d:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB ker=
nel_stack:0kB pagetables:1268kB bounce:0kB free_pcp:792kB local_pcp:676kB f=
ree_cma:0kB
   [47538.742074] lowmem_reserve[]: 0 0 0 0
   [47538.742093] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47538.742104] Normal: 41*4kB (ME) 38*8kB (UME) 74*16kB (ME) 249*32kB (M=
E) 97*64kB (UME) 61*128kB (UME) 35*256kB (ME) 11*512kB (UME) 4*1024kB (ME) =
0*2048kB 0*4096kB =3D 42324kB
   [47538.742116] HighMem: 334*4kB (UM) 1000*8kB (UM) 6818*16kB (UM) 5066*3=
2kB (UM) 2892*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*102=
4kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 960600kB
   [47538.742117] 431626 total pagecache pages
   [47538.742119] 0 pages in swap cache
   [47538.742120] Swap cache stats: add 13259, delete 13259, find 5042/6221
   [47538.742121] Free swap  =3D 0kB
   [47538.742121] Total swap =3D 0kB
   [47538.742122] 783948 pages RAM
   [47538.742123] 556722 pages HighMem/MovableOnly
   [47538.742123] 9664 pages reserved
   [47538.742124] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47538.742130] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47538.742136] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47538.742138] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47538.742141] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47538.742143] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47538.742145] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47538.742148] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47538.742150] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47538.742152] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47538.742155] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47538.742157] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47538.742159] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47538.742162] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47538.742164] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47538.742166] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47538.742169] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47538.742171] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47538.742173] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47538.742175] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47538.742178] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47538.742180] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47538.742182] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47538.742185] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47538.742187] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47538.742189] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47538.742192] [ 2733]     0  2733     1069      773       5       0    =
    0             0 login
   [47538.742194] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47538.742196] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47538.742199] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47538.742201] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47538.742204] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47538.742207] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47538.742209] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47538.742211] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47538.742214] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47538.742216] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47538.742219] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47538.742221] [ 8294]     0  8294    19368     7862      18       0    =
    0             0 Xorg
   [47538.742223] [ 8300]     0  8300     1511      643       4       0    =
    0             0 wdm
   [47538.742226] [ 8307]     0  8307     3504     2148       7       0    =
    0             0 wdmLogin
   [47538.742228] [ 8316]     0  8316      557      136       3       0    =
    0             0 sleep
   [47538.742230] [ 8333] 10230  8333     2062     1387       6       0    =
    0             0 zsh
   [47538.742232] [ 8463] 10230  8463     2495     1296       6       0    =
    0             0 ssh
   [47538.742235] [ 8466]     0  8466     1973     1285       5       0    =
    0             0 zsh
   [47538.742237] [ 8594]     0  8594    16311    15404      19       0    =
    0             0 apt-get
   [47538.742240] [ 8655]     0  8655    13079    12242      16       0    =
    0             0 dpkg
   [47538.742242] [ 8656]     0  8656      581      152       3       0    =
    0             0 sh
   [47538.742244] [ 8657]     0  8657      581       18       3       0    =
    0             0 sh
   [47538.742247] [ 8658]     0  8658      581      167       4       0    =
    0             0 dpkg-status
   [47538.742248] Out of memory: Kill process 8594 (apt-get) score 19 or sa=
crifice child
   [47538.742253] Killed process 8655 (dpkg) total-vm:52316kB, anon-rss:462=
44kB, file-rss:2724kB, shmem-rss:0kB
   [47538.748286] oom_reaper: reaped process 8655 (dpkg), now anon-rss:0kB,=
 file-rss:0kB, shmem-rss:0kB

   [47538.808382] dpkg invoked oom-killer: gfp_mask=3D0x2400840(GFP_NOFS|__=
GFP_NOFAIL), order=3D0, oom_score_adj=3D0
   [47538.808386] dpkg cpuset=3D/ mems_allowed=3D0
   [47538.808389] CPU: 1 PID: 8655 Comm: dpkg Tainted: G     U     O    4.8=
=2E15 #1
   [47538.808390] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47538.808395]  00000286 b2e7b078 c12b1260 eb8bdacc f3698840 c113c257 c1=
5933a0 eb94ace4
   [47538.808399]  02400840 eb8bdad8 00000000 00000000 02400840 00000206 c1=
2b63ef 00000000
   [47538.808403]  f447d0d8 0101a940 f3698840 f3698c6c c15910eb eb8bdacc c1=
0e7b4e c105fe23
   [47538.808404] Call Trace:
   [47538.808411]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47538.808414]  [<c113c257>] ? dump_header+0x43/0x19f
   [47538.808417]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47538.808421]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47538.808423]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47538.808426]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47538.808428]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47538.808431]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47538.808433]  [<c10eba31>] ? __alloc_pages_nodemask+0xa71/0xb30
   [47538.808437]  [<c10e3e0a>] ? pagecache_get_page+0xaa/0x250
   [47538.808439]  [<c11ffb73>] ? __alloc_extent_buffer+0x93/0xd0
   [47538.808442]  [<c1207ccf>] ? alloc_extent_buffer+0x13f/0x450
   [47538.808445]  [<c11c8daf>] ? btrfs_alloc_tree_block+0x22f/0x670
   [47538.808449]  [<c11ad9a7>] ? __btrfs_cow_block+0x177/0x690
   [47538.808452]  [<c11afb23>] ? read_block_for_search.isra.32+0xa3/0x3b0
   [47538.808455]  [<c11ae082>] ? btrfs_cow_block+0x142/0x1b0
   [47538.808457]  [<c11b1985>] ? btrfs_search_slot+0x205/0x950
   [47538.808460]  [<c11d0544>] ? btrfs_del_inode_ref+0x84/0x330
   [47538.808463]  [<c11b5732>] ? block_rsv_add_bytes+0x22/0xa0
   [47538.808466]  [<c124385d>] ? __btrfs_add_delayed_item+0x7d/0x130
   [47538.808468]  [<c1245b4a>] ? btrfs_delete_delayed_dir_index+0x11a/0x270
   [47538.808471]  [<c122f1bd>] ? btrfs_del_inode_ref_in_log+0xed/0x1a0
   [47538.808474]  [<c11e373c>] ? __btrfs_unlink_inode+0x22c/0x520
   [47538.808478]  [<c1097900>] ? SYSC_adjtimex+0x70/0x80
   [47538.808480]  [<c11edef0>] ? btrfs_rename2+0x590/0x1870
   [47538.808483]  [<c10c4b00>] ? audit_uid_comparator+0x80/0x80
   [47538.808486]  [<c10c7096>] ? __audit_inode_child+0x236/0x330
   [47538.808489]  [<c114c385>] ? vfs_rename+0x145/0x9d0
   [47538.808491]  [<c11ed960>] ? btrfs_add_link+0x4f0/0x4f0
   [47538.808493]  [<c114c733>] ? vfs_rename+0x4f3/0x9d0
   [47538.808496]  [<c114a1df>] ? __lookup_hash+0xf/0x70
   [47538.808498]  [<c1150831>] ? SyS_rename+0x361/0x380
   [47538.808501]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47538.808504]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47538.808505] Mem-Info:
   [47538.808511] active_anon:19806 inactive_anon:6275 isolated_anon:0
   [47538.808511]  active_file:304003 inactive_file:121495 isolated_file:0
   [47538.808511]  unevictable:7141 dirty:507 writeback:0 unstable:0
   [47538.808511]  slab_reclaimable:36566 slab_unreclaimable:10561
   [47538.808511]  mapped:25749 shmem:3919 pagetables:317 bounce:0
   [47538.808511]  free:263299 free_pcp:454 free_cma:0
   [47538.808516] Node 0 active_anon:79224kB inactive_anon:25100kB active_f=
ile:1216012kB inactive_file:485980kB unevictable:28564kB isolated(anon):0kB=
 isolated(file):0kB mapped:102996kB dirty:2028kB writeback:0kB shmem:0kB sh=
mem_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 15676kB writeback_tmp:0kB unsta=
ble:0kB pages_scanned:0 all_unreclaimable? no
   [47538.808520] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47538.808523] lowmem_reserve[]: 0 833 3008 3008
   [47538.808528] Normal free:42324kB min:42416kB low:53020kB high:63624kB =
active_anon:0kB inactive_anon:11536kB active_file:604000kB inactive_file:11=
6kB unevictable:0kB writepending:1584kB present:892920kB managed:854340kB m=
locked:0kB slab_reclaimable:144508kB slab_unreclaimable:41912kB kernel_stac=
k:2240kB pagetables:0kB bounce:0kB free_pcp:1028kB local_pcp:336kB free_cma=
:0kB
   [47538.808531] lowmem_reserve[]: 0 0 17397 17397
   [47538.808536] HighMem free:1006800kB min:512kB low:28164kB high:55816kB=
 active_anon:79224kB inactive_anon:13564kB active_file:602288kB inactive_fi=
le:485864kB unevictable:28564kB writepending:444kB present:2226888kB manage=
d:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB ker=
nel_stack:0kB pagetables:1268kB bounce:0kB free_pcp:788kB local_pcp:672kB f=
ree_cma:0kB
   [47538.808538] lowmem_reserve[]: 0 0 0 0
   [47538.808550] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47538.808561] Normal: 41*4kB (ME) 38*8kB (UME) 74*16kB (ME) 250*32kB (U=
ME) 96*64kB (ME) 61*128kB (UME) 35*256kB (ME) 11*512kB (UME) 4*1024kB (ME) =
0*2048kB 0*4096kB =3D 42292kB
   [47538.808572] HighMem: 5023*4kB (UM) 4405*8kB (UM) 6834*16kB (UM) 5066*=
32kB (UM) 2892*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*10=
24kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 1006852kB
   [47538.808573] 431626 total pagecache pages
   [47538.808574] 0 pages in swap cache
   [47538.808575] Swap cache stats: add 13259, delete 13259, find 5042/6221
   [47538.808576] Free swap  =3D 0kB
   [47538.808577] Total swap =3D 0kB
   [47538.808577] 783948 pages RAM
   [47538.808578] 556722 pages HighMem/MovableOnly
   [47538.808579] 9664 pages reserved
   [47538.808580] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47538.808584] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47538.808587] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47538.808590] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47538.808592] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47538.808595] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47538.808597] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47538.808599] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47538.808602] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47538.808604] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47538.808606] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47538.808609] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47538.808611] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47538.808613] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47538.808616] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47538.808618] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47538.808620] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47538.808622] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47538.808624] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47538.808627] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47538.808629] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47538.808631] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47538.808634] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47538.808636] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47538.808638] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47538.808641] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47538.808643] [ 2733]     0  2733     1069      773       5       0    =
    0             0 login
   [47538.808645] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47538.808647] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47538.808650] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47538.808652] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47538.808655] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47538.808658] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47538.808660] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47538.808662] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47538.808665] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47538.808667] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47538.808669] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47538.808672] [ 8294]     0  8294    19368     7862      18       0    =
    0             0 Xorg
   [47538.808674] [ 8300]     0  8300     1511      643       4       0    =
    0             0 wdm
   [47538.808676] [ 8307]     0  8307     3504     2148       7       0    =
    0             0 wdmLogin
   [47538.808678] [ 8316]     0  8316      557      136       3       0    =
    0             0 sleep
   [47538.808681] [ 8333] 10230  8333     2062     1387       6       0    =
    0             0 zsh
   [47538.808683] [ 8463] 10230  8463     2495     1296       6       0    =
    0             0 ssh
   [47538.808685] [ 8466]     0  8466     1973     1285       5       0    =
    0             0 zsh
   [47538.808687] [ 8594]     0  8594    16311    15404      19       0    =
    0             0 apt-get
   [47538.808690] [ 8655]     0  8655    13079        0      16       0    =
    0             0 dpkg
   [47538.808692] [ 8656]     0  8656      581      152       3       0    =
    0             0 sh
   [47538.808694] [ 8657]     0  8657      581       18       3       0    =
    0             0 sh
   [47538.808696] [ 8658]     0  8658      581      167       4       0    =
    0             0 dpkg-status
   [47538.808698] Out of memory: Kill process 8594 (apt-get) score 19 or sa=
crifice child
   [47538.808704] Killed process 8594 (apt-get) total-vm:65244kB, anon-rss:=
12876kB, file-rss:48740kB, shmem-rss:0kB
   [47538.813663] oom_reaper: reaped process 8594 (apt-get), now anon-rss:0=
kB, file-rss:0kB, shmem-rss:0kB

   [47538.921562] kworker/u4:8 invoked oom-killer: gfp_mask=3D0x27000c0(GFP=
_KERNEL_ACCOUNT|__GFP_NOTRACK), order=3D1, oom_score_adj=3D0
   [47538.921566] kworker/u4:8 cpuset=3D/ mems_allowed=3D0
   [47538.921570] CPU: 0 PID: 8265 Comm: kworker/u4:8 Tainted: G     U     =
O    4.8.15 #1
   [47538.921571] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47538.921578] Workqueue: events_unbound call_usermodehelper_exec_work
   [47538.921583]  00000286 67a66f2e c12b1260 c1bafdec f3698000 c113c257 c1=
5933a0 f15e1c64
   [47538.921587]  027000c0 c1bafdf8 00000001 00000000 00000001 00000206 c1=
2b63ef 00000000
   [47538.921591]  f447d0d8 010100c0 f3698000 f369842c c15910eb c1bafdec c1=
0e7b4e c105fe23
   [47538.921591] Call Trace:
   [47538.921596]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47538.921600]  [<c113c257>] ? dump_header+0x43/0x19f
   [47538.921602]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47538.921606]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47538.921608]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47538.921611]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47538.921613]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47538.921616]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47538.921618]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47538.921622]  [<c10443d6>] ? copy_process.part.51+0xe6/0x1440
   [47538.921625]  [<c10573c0>] ? umh_complete+0x30/0x30
   [47538.921627]  [<c10754d6>] ? set_next_entity+0x86/0xd00
   [47538.921630]  [<c10573c0>] ? umh_complete+0x30/0x30
   [47538.921632]  [<c10458d6>] ? _do_fork+0xd6/0x310
   [47538.921634]  [<c10792c2>] ? pick_next_task_fair+0x492/0x4f0
   [47538.921637]  [<c10573c0>] ? umh_complete+0x30/0x30
   [47538.921638]  [<c1045b3d>] ? kernel_thread+0x2d/0x40
   [47538.921641]  [<c10574e9>] ? call_usermodehelper_exec_work+0x29/0xe0
   [47538.921643]  [<c1059e50>] ? process_one_work+0x160/0x350
   [47538.921646]  [<c105a9b7>] ? worker_thread+0x37/0x4c0
   [47538.921648]  [<c107f007>] ? __wake_up_locked+0x17/0x20
   [47538.921650]  [<c105a980>] ? cancel_delayed_work_sync+0x10/0x10
   [47538.921652]  [<c105f344>] ? kthread+0xa4/0xc0
   [47538.921656]  [<c14ba2e2>] ? ret_from_kernel_thread+0xe/0x24
   [47538.921659]  [<c105f2a0>] ? kthread_worker_fn+0x120/0x120
   [47538.921660] Mem-Info:
   [47538.921665] active_anon:16581 inactive_anon:6275 isolated_anon:0
   [47538.921665]  active_file:304003 inactive_file:121495 isolated_file:0
   [47538.921665]  unevictable:7141 dirty:507 writeback:0 unstable:0
   [47538.921665]  slab_reclaimable:36566 slab_unreclaimable:10561
   [47538.921665]  mapped:14424 shmem:3919 pagetables:317 bounce:0
   [47538.921665]  free:266524 free_pcp:471 free_cma:0
   [47538.921670] Node 0 active_anon:66324kB inactive_anon:25100kB active_f=
ile:1216012kB inactive_file:485980kB unevictable:28564kB isolated(anon):0kB=
 isolated(file):0kB mapped:57696kB dirty:2028kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 15676kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:0 all_unreclaimable? no
   [47538.921675] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47538.921678] lowmem_reserve[]: 0 833 3008 3008
   [47538.921682] Normal free:42324kB min:42416kB low:53020kB high:63624kB =
active_anon:0kB inactive_anon:11536kB active_file:604000kB inactive_file:11=
6kB unevictable:0kB writepending:1584kB present:892920kB managed:854340kB m=
locked:0kB slab_reclaimable:144508kB slab_unreclaimable:41912kB kernel_stac=
k:2240kB pagetables:0kB bounce:0kB free_pcp:1040kB local_pcp:708kB free_cma=
:0kB
   [47538.921685] lowmem_reserve[]: 0 0 17397 17397
   [47538.921690] HighMem free:1019700kB min:512kB low:28164kB high:55816kB=
 active_anon:66324kB inactive_anon:13564kB active_file:602288kB inactive_fi=
le:485864kB unevictable:28564kB writepending:444kB present:2226888kB manage=
d:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB ker=
nel_stack:0kB pagetables:1268kB bounce:0kB free_pcp:844kB local_pcp:204kB f=
ree_cma:0kB
   [47538.921692] lowmem_reserve[]: 0 0 0 0
   [47538.921704] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47538.921715] Normal: 41*4kB (ME) 39*8kB (UME) 74*16kB (ME) 250*32kB (U=
ME) 96*64kB (ME) 61*128kB (UME) 35*256kB (ME) 11*512kB (UME) 4*1024kB (ME) =
0*2048kB 0*4096kB =3D 42300kB
   [47538.921726] HighMem: 8127*4kB (UM) 4461*8kB (UM) 6836*16kB (UM) 5066*=
32kB (UM) 2892*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*10=
24kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 1019748kB
   [47538.921727] 431626 total pagecache pages
   [47538.921728] 0 pages in swap cache
   [47538.921730] Swap cache stats: add 13259, delete 13259, find 5042/6221
   [47538.921730] Free swap  =3D 0kB
   [47538.921731] Total swap =3D 0kB
   [47538.921732] 783948 pages RAM
   [47538.921732] 556722 pages HighMem/MovableOnly
   [47538.921733] 9664 pages reserved
   [47538.921734] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47538.921738] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47538.921742] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47538.921744] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47538.921746] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47538.921749] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47538.921751] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47538.921753] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47538.921755] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47538.921758] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47538.921760] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47538.921762] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47538.921764] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47538.921767] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47538.921769] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47538.921771] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47538.921773] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47538.921775] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47538.921778] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47538.921780] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47538.921782] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47538.921784] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47538.921787] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47538.921789] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47538.921791] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47538.921793] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47538.921795] [ 2733]     0  2733     1069      773       5       0    =
    0             0 login
   [47538.921797] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47538.921800] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47538.921802] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47538.921804] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47538.921807] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47538.921809] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47538.921812] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47538.921814] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47538.921816] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47538.921818] [ 2791]   120  2791     8763     7661      12       0    =
    0             0 tor
   [47538.921821] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47538.921823] [ 8294]     0  8294    19368     7862      18       0    =
    0             0 Xorg
   [47538.921825] [ 8300]     0  8300     1511      643       4       0    =
    0             0 wdm
   [47538.921828] [ 8307]     0  8307     3504     2148       7       0    =
    0             0 wdmLogin
   [47538.921830] [ 8316]     0  8316      557      136       3       0    =
    0             0 sleep
   [47538.921832] [ 8333] 10230  8333     2062     1387       6       0    =
    0             0 zsh
   [47538.921834] [ 8463] 10230  8463     2495     1296       6       0    =
    0             0 ssh
   [47538.921836] [ 8466]     0  8466     1981     1288       5       0    =
    0             0 zsh
   [47538.921839] [ 8655]     0  8655    13079        0      16       0    =
    0             0 dpkg
   [47538.921841] [ 8656]     0  8656      581      152       3       0    =
    0             0 sh
   [47538.921843] [ 8657]     0  8657      581       18       3       0    =
    0             0 sh
   [47538.921845] [ 8658]     0  8658      581      167       4       0    =
    0             0 dpkg-status
   [47538.921847] Out of memory: Kill process 2791 (tor) score 9 or sacrifi=
ce child
   [47538.921852] Killed process 2791 (tor) total-vm:35052kB, anon-rss:1734=
4kB, file-rss:13300kB, shmem-rss:0kB

   [47538.934319] dpkg invoked oom-killer: gfp_mask=3D0x2400840(GFP_NOFS|__=
GFP_NOFAIL), order=3D0, oom_score_adj=3D0
   [47538.934323] dpkg cpuset=3D/ mems_allowed=3D0
   [47538.934326] CPU: 1 PID: 8655 Comm: dpkg Tainted: G     U     O    4.8=
=2E15 #1
   [47538.934327] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47538.934332]  00000286 b2e7b078 c12b1260 eb8bd990 eb948000 c113c257 c1=
5933a0 eb94ace4
   [47538.934336]  02400840 eb8bd99c 00000000 00000000 02400840 00000206 c1=
2b63ef 00000000
   [47538.934340]  f447d0d8 0101a940 eb948000 eb94842c c15910eb eb8bd990 c1=
0e7b4e c105fe23
   [47538.934341] Call Trace:
   [47538.934347]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47538.934351]  [<c113c257>] ? dump_header+0x43/0x19f
   [47538.934353]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47538.934357]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47538.934360]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47538.934362]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47538.934364]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47538.934367]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47538.934369]  [<c10eba31>] ? __alloc_pages_nodemask+0xa71/0xb30
   [47538.934373]  [<c10e3e0a>] ? pagecache_get_page+0xaa/0x250
   [47538.934375]  [<c11ffb73>] ? __alloc_extent_buffer+0x93/0xd0
   [47538.934378]  [<c1207ccf>] ? alloc_extent_buffer+0x13f/0x450
   [47538.934381]  [<c11c8daf>] ? btrfs_alloc_tree_block+0x22f/0x670
   [47538.934385]  [<c11ad9a7>] ? __btrfs_cow_block+0x177/0x690
   [47538.934388]  [<c11afb23>] ? read_block_for_search.isra.32+0xa3/0x3b0
   [47538.934390]  [<c11ae082>] ? btrfs_cow_block+0x142/0x1b0
   [47538.934393]  [<c11b1985>] ? btrfs_search_slot+0x205/0x950
   [47538.934396]  [<c1227a75>] ? drop_objectid_items+0x135/0x1a0
   [47538.934398]  [<c1208c19>] ? read_extent_buffer+0xb9/0x110
   [47538.934401]  [<c112ac7f>] ? kmem_cache_alloc+0xaf/0x100
   [47538.934403]  [<c122cbe7>] ? btrfs_log_inode+0x8f7/0x16e0
   [47538.934406]  [<c11af1dd>] ? comp_keys+0x3d/0x60
   [47538.934410]  [<c12bcc0d>] ? lockref_put_or_lock+0x1d/0x30
   [47538.934412]  [<c11565e5>] ? dput+0xd5/0x280
   [47538.934415]  [<c122de26>] ? btrfs_log_inode_parent+0x3e6/0x8c0
   [47538.934418]  [<c122f8d0>] ? btrfs_log_new_name+0xa0/0xd0
   [47538.934421]  [<c11eea67>] ? btrfs_rename2+0x1107/0x1870
   [47538.934424]  [<c10c4b00>] ? audit_uid_comparator+0x80/0x80
   [47538.934426]  [<c10c7096>] ? __audit_inode_child+0x236/0x330
   [47538.934430]  [<c114c385>] ? vfs_rename+0x145/0x9d0
   [47538.934432]  [<c11ed960>] ? btrfs_add_link+0x4f0/0x4f0
   [47538.934434]  [<c114c733>] ? vfs_rename+0x4f3/0x9d0
   [47538.934437]  [<c114a1df>] ? __lookup_hash+0xf/0x70
   [47538.934438]  [<c1150831>] ? SyS_rename+0x361/0x380
   [47538.934441]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47538.934445]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47538.934446] Mem-Info:
   [47538.934451] active_anon:12256 inactive_anon:6275 isolated_anon:0
   [47538.934451]  active_file:304003 inactive_file:121495 isolated_file:0
   [47538.934451]  unevictable:7141 dirty:507 writeback:0 unstable:0
   [47538.934451]  slab_reclaimable:36566 slab_unreclaimable:10561
   [47538.934451]  mapped:12224 shmem:3919 pagetables:280 bounce:0
   [47538.934451]  free:270724 free_pcp:606 free_cma:0
   [47538.934455] Node 0 active_anon:49024kB inactive_anon:25100kB active_f=
ile:1216012kB inactive_file:485980kB unevictable:28564kB isolated(anon):0kB=
 isolated(file):0kB mapped:48896kB dirty:2028kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 15676kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:0 all_unreclaimable? no
   [47538.934460] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47538.934463] lowmem_reserve[]: 0 833 3008 3008
   [47538.934467] Normal free:42324kB min:42416kB low:53020kB high:63624kB =
active_anon:0kB inactive_anon:11536kB active_file:604000kB inactive_file:11=
6kB unevictable:0kB writepending:1584kB present:892920kB managed:854340kB m=
locked:0kB slab_reclaimable:144508kB slab_unreclaimable:41912kB kernel_stac=
k:2240kB pagetables:0kB bounce:0kB free_pcp:1048kB local_pcp:332kB free_cma=
:0kB
   [47538.934470] lowmem_reserve[]: 0 0 17397 17397
   [47538.934474] HighMem free:1036500kB min:512kB low:28164kB high:55816kB=
 active_anon:49024kB inactive_anon:13564kB active_file:602288kB inactive_fi=
le:485864kB unevictable:28564kB writepending:444kB present:2226888kB manage=
d:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB ker=
nel_stack:0kB pagetables:1120kB bounce:0kB free_pcp:1376kB local_pcp:640kB =
free_cma:0kB
   [47538.934476] lowmem_reserve[]: 0 0 0 0
   [47538.934488] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47538.934501] Normal: 41*4kB (ME) 40*8kB (UME) 74*16kB (ME) 250*32kB (U=
ME) 96*64kB (ME) 61*128kB (UME) 35*256kB (ME) 11*512kB (UME) 4*1024kB (ME) =
0*2048kB 0*4096kB =3D 42308kB
   [47538.934512] HighMem: 9777*4kB (UM) 5518*8kB (UM) 6945*16kB (UM) 5064*=
32kB (UM) 2894*64kB (UM) 1199*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*10=
24kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 1036612kB
   [47538.934513] 431626 total pagecache pages
   [47538.934514] 0 pages in swap cache
   [47538.934516] Swap cache stats: add 13259, delete 13259, find 5042/6221
   [47538.934516] Free swap  =3D 0kB
   [47538.934517] Total swap =3D 0kB
   [47538.934518] 783948 pages RAM
   [47538.934519] 556722 pages HighMem/MovableOnly
   [47538.934519] 9664 pages reserved
   [47538.934520] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47538.934524] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47538.934528] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47538.934530] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47538.934532] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47538.934535] [ 1803]     0  1803     7910      621       7       0    =
    0             0 rsyslogd
   [47538.934537] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47538.934539] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47538.934541] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47538.934543] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47538.934545] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47538.934548] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47538.934550] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47538.934552] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47538.934555] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47538.934557] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47538.934559] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47538.934561] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47538.934563] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47538.934565] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47538.934567] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47538.934570] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47538.934572] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47538.934574] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47538.934576] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47538.934578] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47538.934580] [ 2733]     0  2733     1069      773       5       0    =
    0             0 login
   [47538.934583] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47538.934585] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47538.934587] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47538.934589] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47538.934592] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47538.934594] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47538.934597] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47538.934599] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47538.934601] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47538.934604] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47538.934606] [ 8294]     0  8294    19368     7862      18       0    =
    0             0 Xorg
   [47538.934608] [ 8300]     0  8300     1511      643       4       0    =
    0             0 wdm
   [47538.934611] [ 8307]     0  8307     3504     2148       7       0    =
    0             0 wdmLogin
   [47538.934613] [ 8316]     0  8316      557      136       3       0    =
    0             0 sleep
   [47538.934615] [ 8333] 10230  8333     2062     1387       6       0    =
    0             0 zsh
   [47538.934617] [ 8463] 10230  8463     2495     1296       6       0    =
    0             0 ssh
   [47538.934619] [ 8466]     0  8466     1981     1288       5       0    =
    0             0 zsh
   [47538.934621] [ 8655]     0  8655    13079        0      16       0    =
    0             0 dpkg
   [47538.934624] [ 8656]     0  8656      581      152       3       0    =
    0             0 sh
   [47538.934626] [ 8657]     0  8657      581       18       3       0    =
    0             0 sh
   [47538.934628] [ 8658]     0  8658      581      167       4       0    =
    0             0 dpkg-status
   [47538.934630] Out of memory: Kill process 8294 (Xorg) score 9 or sacrif=
ice child
   [47538.934638] Killed process 8294 (Xorg) total-vm:77472kB, anon-rss:160=
48kB, file-rss:15268kB, shmem-rss:132kB
   [47538.942843] oom_reaper: reaped process 8294 (Xorg), now anon-rss:0kB,=
 file-rss:0kB, shmem-rss:132kB

   [47541.319278] Xorg invoked oom-killer: gfp_mask=3D0x24200d4(GFP_USER|GF=
P_DMA32|__GFP_RECLAIMABLE), order=3D0, oom_score_adj=3D0
   [47541.319285] Xorg cpuset=3D/ mems_allowed=3D0
   [47541.319293] CPU: 0 PID: 8693 Comm: Xorg Tainted: G     U     O    4.8=
=2E15 #1
   [47541.319295] Hardware name: LENOVO 7669A26/7669A26, BIOS 7NETB3WW (2.1=
3 ) 04/30/2008
   [47541.319298]  00003286 47322bc2 c12b1260 eb8bda3c f369a100 c113c257 c1=
5933a0 f369a4a4
   [47541.319305]  024200d4 eb8bda48 00000000 00000000 024200d4 00003206 c1=
2b63ef 00000000
   [47541.319312]  f447d0d8 0001a100 f369a100 f369a52c c15910eb eb8bda3c c1=
0e7b4e c105fe23
   [47541.319318] Call Trace:
   [47541.319326]  [<c12b1260>] ? dump_stack+0x44/0x64
   [47541.319331]  [<c113c257>] ? dump_header+0x43/0x19f
   [47541.319334]  [<c12b63ef>] ? ___ratelimit+0x8f/0xf0
   [47541.319339]  [<c10e7b4e>] ? oom_kill_process+0x1fe/0x3c0
   [47541.319342]  [<c105fe23>] ? notifier_call_chain+0x43/0x60
   [47541.319346]  [<c104e3de>] ? has_ns_capability_noaudit+0x2e/0x40
   [47541.319349]  [<c10e72fb>] ? oom_badness.part.11+0xeb/0x160
   [47541.319352]  [<c10e7f4f>] ? out_of_memory+0x1ef/0x230
   [47541.319356]  [<c10ebab6>] ? __alloc_pages_nodemask+0xaf6/0xb30
   [47541.319360]  [<c10fa877>] ? shmem_alloc_and_acct_page+0x137/0x210
   [47541.319363]  [<c10e3a55>] ? find_get_entry+0xd5/0x110
   [47541.319366]  [<c10fb1a5>] ? shmem_getpage_gfp+0x165/0xbb0
   [47541.319369]  [<c10fcd6b>] ? shmem_truncate_range+0x3b/0x70
   [47541.319396]  [<f888d09d>] ? i915_gem_object_truncate+0x2d/0x50 [i915]
   [47541.319417]  [<f88961a9>] ? i915_gem_shrink+0x249/0x2e0 [i915]
   [47541.319421]  [<c10fbc32>] ? shmem_read_mapping_page_gfp+0x42/0x70
   [47541.319442]  [<f888de2b>] ? i915_gem_object_get_pages_gtt+0x1eb/0x3e0=
 [i915]
   [47541.319463]  [<f888efb9>] ? i915_gem_object_get_pages+0x39/0xc0 [i915]
   [47541.319484]  [<f8892146>] ? i915_gem_object_do_pin+0x466/0xaf0 [i915]
   [47541.319506]  [<f8892804>] ? i915_gem_object_pin+0x34/0x40 [i915]
   [47541.319526]  [<f8881b38>] ? i915_gem_execbuffer_reserve_vma.isra.16+0=
x88/0x180 [i915]
   [47541.319546]  [<f8881fd5>] ? i915_gem_execbuffer_reserve.isra.17+0x3a5=
/0x3d0 [i915]
   [47541.319567]  [<f88830d5>] ? i915_gem_do_execbuffer.isra.21+0x665/0x10=
00 [i915]
   [47541.319588]  [<f88937d3>] ? i915_gem_object_ggtt_unpin_view+0x23/0xc0=
 [i915]
   [47541.319610]  [<f889426d>] ? i915_gem_pwrite_ioctl+0xbd/0xcc0 [i915]
   [47541.319613]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47541.319616]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47541.319636]  [<f88845f9>] ? i915_gem_execbuffer2+0xd9/0x260 [i915]
   [47541.319656]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47541.319667]  [<f808780a>] ? drm_ioctl+0x16a/0x410 [drm]
   [47541.319687]  [<f8884520>] ? i915_gem_execbuffer+0x3d0/0x3d0 [i915]
   [47541.319691]  [<c113c1c9>] ? __check_object_size+0xd9/0x124
   [47541.319695]  [<c102181f>] ? __fpu__restore_sig+0x22f/0x410
   [47541.319703]  [<f80876a0>] ? drm_getunique+0x60/0x60 [drm]
   [47541.319707]  [<c1151e9f>] ? do_vfs_ioctl+0x8f/0x780
   [47541.319711]  [<c10c767e>] ? __audit_syscall_entry+0xae/0x110
   [47541.319714]  [<c100123a>] ? syscall_trace_enter+0x1ca/0x1f0
   [47541.319717]  [<c10c7251>] ? audit_filter_inodes+0xc1/0x100
   [47541.319720]  [<c10c6d55>] ? audit_filter_syscall+0xa5/0xd0
   [47541.319723]  [<c115bec1>] ? __fget+0x61/0xb0
   [47541.319726]  [<c11525be>] ? SyS_ioctl+0x2e/0x50
   [47541.319729]  [<c1001510>] ? do_fast_syscall_32+0x80/0x130
   [47541.319733]  [<c14ba38a>] ? sysenter_past_esp+0x47/0x75
   [47541.319735] Mem-Info:
   [47541.319741] active_anon:12102 inactive_anon:6305 isolated_anon:0
   [47541.319741]  active_file:304091 inactive_file:121462 isolated_file:0
   [47541.319741]  unevictable:7141 dirty:572 writeback:0 unstable:0
   [47541.319741]  slab_reclaimable:36565 slab_unreclaimable:10556
   [47541.319741]  mapped:12176 shmem:3957 pagetables:258 bounce:0
   [47541.319741]  free:271043 free_pcp:426 free_cma:0
   [47541.319750] Node 0 active_anon:48408kB inactive_anon:25220kB active_f=
ile:1216364kB inactive_file:485848kB unevictable:28564kB isolated(anon):0kB=
 isolated(file):0kB mapped:48704kB dirty:2288kB writeback:0kB shmem:0kB shm=
em_thp: 0kB shmem_pmdmapped: 0kB anon_thp: 15828kB writeback_tmp:0kB unstab=
le:0kB pages_scanned:0 all_unreclaimable? no
   [47541.319757] DMA free:4072kB min:788kB low:984kB high:1180kB active_an=
on:0kB inactive_anon:0kB active_file:9724kB inactive_file:0kB unevictable:0=
kB writepending:0kB present:15984kB managed:15908kB mlocked:0kB slab_reclai=
mable:1756kB slab_unreclaimable:332kB kernel_stack:24kB pagetables:0kB boun=
ce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
   [47541.319759] lowmem_reserve[]: 0 833 3008 3008
   [47541.319768] Normal free:42372kB min:42416kB low:53020kB high:63624kB =
active_anon:0kB inactive_anon:11672kB active_file:604020kB inactive_file:12=
0kB unevictable:0kB writepending:1628kB present:892920kB managed:854340kB m=
locked:0kB slab_reclaimable:144504kB slab_unreclaimable:41892kB kernel_stac=
k:2192kB pagetables:0kB bounce:0kB free_pcp:972kB local_pcp:408kB free_cma:=
0kB
   [47541.319770] lowmem_reserve[]: 0 0 17397 17397
   [47541.319778] HighMem free:1037728kB min:512kB low:28164kB high:55816kB=
 active_anon:48408kB inactive_anon:13564kB active_file:602620kB inactive_fi=
le:485728kB unevictable:28564kB writepending:660kB present:2226888kB manage=
d:2226888kB mlocked:28564kB slab_reclaimable:0kB slab_unreclaimable:0kB ker=
nel_stack:0kB pagetables:1032kB bounce:0kB free_pcp:732kB local_pcp:328kB f=
ree_cma:0kB
   [47541.319781] lowmem_reserve[]: 0 0 0 0
   [47541.319785] DMA: 10*4kB (UE) 10*8kB (E) 7*16kB (UE) 6*32kB (E) 5*64kB=
 (UE) 4*128kB (UE) 3*256kB (E) 2*512kB (UE) 1*1024kB (U) 0*2048kB 0*4096kB =
=3D 4072kB
   [47541.319803] Normal: 41*4kB (M) 64*8kB (UME) 52*16kB (UM) 251*32kB (UM=
E) 99*64kB (UME) 61*128kB (UME) 35*256kB (ME) 11*512kB (UME) 4*1024kB (ME) =
0*2048kB 0*4096kB =3D 42372kB
   [47541.319819] HighMem: 9422*4kB (UM) 5773*8kB (UM) 6970*16kB (UM) 5063*=
32kB (UM) 2892*64kB (UM) 1201*128kB (UM) 396*256kB (UM) 139*512kB (M) 61*10=
24kB (M) 24*2048kB (M) 14*4096kB (UM) =3D 1037728kB
   [47541.319837] 431715 total pagecache pages
   [47541.319840] 0 pages in swap cache
   [47541.319842] Swap cache stats: add 13259, delete 13259, find 5042/6221
   [47541.319844] Free swap  =3D 0kB
   [47541.319846] Total swap =3D 0kB
   [47541.319847] 783948 pages RAM
   [47541.319849] 556722 pages HighMem/MovableOnly
   [47541.319851] 9664 pages reserved
   [47541.319852] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swa=
pents oom_score_adj name
   [47541.319857] [  218]     0   218     2974      896       5       0    =
    0         -1000 udevd
   [47541.319862] [ 1658]     0  1658     3233      538       5       0    =
    0         -1000 auditd
   [47541.319865] [ 1760]     0  1760     5349      343       7       0    =
    0             0 lxcfs
   [47541.319869] [ 1778]     0  1778     5413      158       6       0    =
    0             0 lvmetad
   [47541.319872] [ 1803]     0  1803     7910      715       7       0    =
    0             0 rsyslogd
   [47541.319875] [ 1966]     0  1966      581      403       4       0    =
    0             0 battery-stats-c
   [47541.319878] [ 1994]     0  1994      595      439       4       0    =
    0             0 acpid
   [47541.319882] [ 2034]     0  2034     2003     1046       5       0    =
    0             0 haveged
   [47541.319885] [ 2041]   103  2041     1108      677       4       0    =
    0             0 dbus-daemon
   [47541.319888] [ 2063]     8  2063     1058      631       5       0    =
    0             0 nullmailer-send
   [47541.319891] [ 2134]     0  2134     7111      485       6       0    =
    0             0 pcscd
   [47541.319894] [ 2168]     0  2168     1451      994       4       0    =
    0             0 bluetoothd
   [47541.319898] [ 2222]     0  2222     2129      707       6       0    =
    0         -1000 sshd
   [47541.319901] [ 2232]     0  2232     1460      551       5       0    =
    0             0 smartd
   [47541.319904] [ 2287]     0  2287      558       19       4       0    =
    0             0 thinkfan
   [47541.319907] [ 2288]     0  2288      559      184       4       0    =
    0             0 startpar
   [47541.319910] [ 2303]   124  2303      824      592       4       0    =
    0             0 ulogd
   [47541.319913] [ 2376]     0  2376      601       23       4       0    =
    0             0 uuidd
   [47541.319916] [ 2454]   110  2454     5497     2987      10       0    =
    0             0 unbound
   [47541.319920] [ 2531]     0  2531     8563     4029      11       0    =
    0             0 wicd
   [47541.319923] [ 2543]   121  2543     5567      729       6       0    =
    0             0 privoxy
   [47541.319926] [ 2608]     0  2608     1511       77       4       0    =
    0             0 wdm
   [47541.319929] [ 2612]     0  2612     1406      610       5       0    =
    0             0 cron
   [47541.319932] [ 2615]     0  2615     1511      640       4       0    =
    0             0 wdm
   [47541.319935] [ 2681]     0  2681     4975     3274       7       0    =
    0             0 wicd-monitor
   [47541.319938] [ 2733]     0  2733     1069      773       5       0    =
    0             0 login
   [47541.319941] [ 2830] 10230  2830     8450      359       8       0    =
    0             0 gpg-agent
   [47541.319944] [ 5850]     0  5850     2900     1429       6       0    =
    0             0 sshd
   [47541.319947] [ 5854] 10230  5854     8278      832       9       0    =
    0             0 scdaemon
   [47541.319950] [ 5942] 10230  5942     2527      715       6       0    =
    0             0 ssh
   [47541.319954] [ 9853]     0  9853     7591     7123      11       0    =
    0         -1000 ulatencyd
   [47541.319958] [30312]     0 30312     1233       45       5       0    =
    0             0 acpi_fakekeyd
   [47541.319961] [ 2524]     0  2524     2190      800       5       0    =
    0             0 wpa_supplicant
   [47541.319964] [ 2727]     0  2727     2026      180       5       0    =
    0             0 dhclient
   [47541.319967] [ 2782] 65534  2782     2289     1436       5       0    =
    0             0 openvpn
   [47541.319970] [ 7450] 10230  7450     2937      581       6       0    =
    0             0 redshift
   [47541.319974] [ 8316]     0  8316      557      136       3       0    =
    0             0 sleep
   [47541.319977] [ 8333] 10230  8333     2062     1387       6       0    =
    0             0 zsh
   [47541.319980] [ 8463] 10230  8463     2495     1296       6       0    =
    0             0 ssh
   [47541.319983] [ 8466]     0  8466     1973     1285       5       0    =
    0             0 zsh
   [47541.319986] [ 8693]     0  8693    19244     7831      18       0    =
    0             0 Xorg
   [47541.319989] [ 8699]     0  8699     1511      643       4       0    =
    0             0 wdm
   [47541.319992] [ 8706]     0  8706     3504     2135       7       0    =
    0             0 wdmLogin
   [47541.319995] Out of memory: Kill process 8693 (Xorg) score 9 or sacrif=
ice child
   [47541.320030] Killed process 8693 (Xorg) total-vm:76976kB, anon-rss:156=
92kB, file-rss:15484kB, shmem-rss:148kB
   [47541.324453] oom_reaper: reaped process 8693 (Xorg), now anon-rss:0kB,=
 file-rss:0kB, shmem-rss:148kB
--=20
Klaus Ethgen                                       http://www.ethgen.ch/
pub  4096R/4E20AF1C 2011-05-16            Klaus Ethgen <Klaus@Ethgen.ch>
Fingerprint: 85D4 CA42 952C 949B 1753  62B3 79D0 B06F 4E20 AF1C

--rlbqxeuxbnebjaro
Content-Type: application/octet-stream
Content-Disposition: attachment; filename="config-4.9.0.bz2"
Content-Transfer-Encoding: base64

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
U4UJAQkDLOA=

--rlbqxeuxbnebjaro--

--4jbyw4ckxstwdxmh
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Comment: Charset: ISO-8859-1

iQGzBAEBCgAdFiEEMWF28vh4/UMJJLQEpnwKsYAZ9qwFAlhiVPsACgkQpnwKsYAZ
9qzkCAwAwe5X3izwKeYGMMxDx9bP6k0kq/pK76I1XuBDqE4onjKwW81IIwijN//b
K3+egFRIDpVrK5z3RzsrdPOVkZEtMFPG05sInoixwHdTgvn3L2c6oTfzk6nNpWBr
hG8GZCZVkBszP0y/mf+o+oaftLaJ4tQFyl/3/MbGgSPbp7QeQlSICwgmDne9n+1s
knOPYNl5g8HyL/SrJF3Vtwyne2WA+2z1n1jgx5jj9yAO8kr1OlT/xUwvBBRBblJJ
rfNTZkHdNC5ATSHETP7EwvkAXa7sahpCBhDcaums5tfuQtozYNXLchZAy0Z3n1zx
D+/5Cm/sozwkEy5HtTiNveRyt3si791EmZm7uZDyF+znQ/gnyUQ29BaawDb/NwMW
bLWHqhZgpyr7Hqvb4FSAoHTwNNYlVdqpv2LvT7abbsbg0vpn+BNrUkXcd25+7P6p
uHnjTl9AK/k//nxgjjOnRHz9mwRixKKNseXGKiQdL7KdB1Z4f5PtvwqWrC4oyAfp
kGHarRRk
=zvOQ
-----END PGP SIGNATURE-----

--4jbyw4ckxstwdxmh--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
