Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE7926B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:47:14 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so10444369wmw.0
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:47:14 -0800 (PST)
Received: from celine.tisys.org (celine.tisys.org. [85.25.117.166])
        by mx.google.com with ESMTPS id z80si4582106wmd.57.2016.12.16.10.47.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:47:11 -0800 (PST)
Date: Fri, 16 Dec 2016 19:47:00 +0100
From: Nils Holland <nholland@tisys.org>
Subject: Re: OOM: Better, but still there on
Message-ID: <20161216184655.GA5664@boerne.fritz.box>
References: <20161216073941.GA26976@dhcp22.suse.cz>
 <20161216155808.12809-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161216155808.12809-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chris Mason <clm@fb.com>, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On Fri, Dec 16, 2016 at 04:58:06PM +0100, Michal Hocko wrote:
> On Fri 16-12-16 08:39:41, Michal Hocko wrote:
> [...]
> > That being said, the OOM killer invocation is clearly pointless and
> > pre-mature. We normally do not invoke it normally for GFP_NOFS requests
> > exactly for these reasons. But this is GFP_NOFS|__GFP_NOFAIL which
> > behaves differently. I am about to change that but my last attempt [1]
> > has to be rethought.
> > 
> > Now another thing is that the __GFP_NOFAIL which has this nasty side
> > effect has been introduced by me d1b5c5671d01 ("btrfs: Prevent from
> > early transaction abort") in 4.3 so I am quite surprised that this has
> > shown up only in 4.8. Anyway there might be some other changes in the
> > btrfs which could make it more subtle.
> > 
> > I believe the right way to go around this is to pursue what I've started
> > in [1]. I will try to prepare something for testing today for you. Stay
> > tuned. But I would be really happy if somebody from the btrfs camp could
> > check the NOFS aspect of this allocation. We have already seen
> > allocation stalls from this path quite recently
> 
> Could you try to run with the two following patches?

I tried the two patches you sent, and ... well, things are different
now, but probably still a bit problematic. ;-)

Once again, I freshly booted both of my machines and told Gentoo's
portage to unpack and build the firefox sources. The first machine,
the one from which yesterday's OOM report came, became unresponsive
during the tarball unpack phase and had to be power cycled.
Unfortunately, there's nothing concerning its OOMs in the logs. :-(

The second machine actually finished the unpack phase successfully and
started the build process (which, every now and then, had also worked
with previous problematic kernels). However, after it had been
building for a while and I decided to increase the stress level by
starting X, firefox as well as a terminal and unpack a kernel source
tarball in it, it also started OOMing, this time once more with a
genuine kernel panic. Luckily, this machine also caught something in
the logs, which I'm including below.

Despite the fact that I'm no expert, I can see that there's no more
GFP_NOFS being logged, which seems to be what the patches tried to
achieve. What the still present OOMs mean remains up for
interpretation by the experts, all I can say is that in the (pre-4.8?)
past, doing all of the things I just did would probably slow down my
machine quite a bit, but I can't remember to have ever seen it OOM or
even crash completely.

Dec 16 18:56:24 boerne.fritz.box kernel: Purging GPU memory, 37 pages freed, 10219 pages still pinned.
Dec 16 18:56:29 boerne.fritz.box kernel: kthreadd invoked oom-killer: gfp_mask=0x27080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK), nodemask=0, order=1, oom_score_adj=0
Dec 16 18:56:29 boerne.fritz.box kernel: kthreadd cpuset=/ mems_allowed=0
Dec 16 18:56:29 boerne.fritz.box kernel: CPU: 1 PID: 2 Comm: kthreadd Not tainted 4.9.0-gentoo #3
Dec 16 18:56:29 boerne.fritz.box kernel: Hardware name: TOSHIBA Satellite L500/KSWAA, BIOS V1.80 10/28/2009
Dec 16 18:56:29 boerne.fritz.box kernel:  f4105d6c c1433406 f4105e9c c6611280 f4105d9c c1170011 f4105df0 00200296
Dec 16 18:56:29 boerne.fritz.box kernel:  f4105d9c c1438fff f4105da0 edc1bc80 ee32ce00 c6611280 c1ad1899 f4105e9c
Dec 16 18:56:29 boerne.fritz.box kernel:  f4105de0 c1114407 c10513a5 f4105dcc c11140a1 00000001 00000000 00000000
Dec 16 18:56:29 boerne.fritz.box kernel: Call Trace:
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1433406>] dump_stack+0x47/0x61
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1170011>] dump_header+0x5f/0x175
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1438fff>] ? ___ratelimit+0x7f/0xe0
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1114407>] oom_kill_process+0x207/0x3c0
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c10513a5>] ? has_capability_noaudit+0x15/0x20
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c11140a1>] ? oom_badness.part.13+0xb1/0x120
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c11148c4>] out_of_memory+0xd4/0x270
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1118615>] __alloc_pages_nodemask+0xcf5/0xd60
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c10464f5>] copy_process.part.52+0xd5/0x1410
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1080779>] ? pick_next_task_fair+0x479/0x510
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1062ba0>] ? __kthread_parkme+0x60/0x60
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c10479d7>] _do_fork+0xc7/0x360
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1062ba0>] ? __kthread_parkme+0x60/0x60
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c1047ca0>] kernel_thread+0x30/0x40
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c10637c6>] kthreadd+0x106/0x150
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c10636c0>] ? kthread_park+0x50/0x50
Dec 16 18:56:29 boerne.fritz.box kernel:  [<c19422b7>] ret_from_fork+0x1b/0x28
Dec 16 18:56:29 boerne.fritz.box kernel: Mem-Info:
Dec 16 18:56:29 boerne.fritz.box kernel: active_anon:132176 inactive_anon:11640 isolated_anon:0
                                          active_file:295257 inactive_file:389350 isolated_file:20
                                          unevictable:0 dirty:3956 writeback:0 unstable:0
                                          slab_reclaimable:54632 slab_unreclaimable:21963
                                          mapped:36724 shmem:11853 pagetables:914 bounce:0
                                          free:77600 free_pcp:327 free_cma:0
Dec 16 18:56:29 boerne.fritz.box kernel: Node 0 active_anon:528704kB inactive_anon:46560kB active_file:1181028kB inactive_file:1557400kB unevictable:0kB isolated(anon):0kB isolated(file):80kB mapped:146896kB dirty:15824kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 172032kB anon_thp: 47412kB writeback_tmp:0kB unstable:0kB pages_scanned:15066965 all_unreclaimable? yes
Dec 16 18:56:29 boerne.fritz.box kernel: DMA free:3976kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:4788kB inactive_file:0kB unevictable:0kB writepending:160kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:5356kB slab_unreclaimable:1616kB kernel_stack:32kB pagetables:84kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Dec 16 18:56:29 boerne.fritz.box kernel: lowmem_reserve[]: 0 808 3849 3849
Dec 16 18:56:29 boerne.fritz.box kernel: Normal free:41008kB min:41100kB low:51372kB high:61644kB active_anon:0kB inactive_anon:0kB active_file:470556kB inactive_file:148kB unevictable:0kB writepending:1616kB present:897016kB managed:831480kB mlocked:0kB slab_reclaimable:213172kB slab_unreclaimable:86236kB kernel_stack:1864kB pagetables:3572kB bounce:0kB free_pcp:532kB local_pcp:456kB free_cma:0kB
Dec 16 18:56:29 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 24330 24330
Dec 16 18:56:29 boerne.fritz.box kernel: HighMem free:265416kB min:512kB low:39184kB high:77856kB active_anon:528704kB inactive_anon:46560kB active_file:705684kB inactive_file:1557292kB unevictable:0kB writepending:14048kB present:3114256kB managed:3114256kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:776kB local_pcp:660kB free_cma:0kB
Dec 16 18:56:29 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 0 0
Dec 16 18:56:29 boerne.fritz.box kernel: DMA: 2*4kB (UE) 2*8kB (U) 1*16kB (E) 1*32kB (U) 1*64kB (U) 0*128kB 1*256kB (E) 1*512kB (E) 1*1024kB (U) 1*2048kB (M) 0*4096kB = 3976kB
Dec 16 18:56:29 boerne.fritz.box kernel: Normal: 32*4kB (ME) 28*8kB (UM) 15*16kB (UM) 141*32kB (UME) 141*64kB (UM) 80*128kB (UM) 19*256kB (UME) 3*512kB (UME) 2*1024kB (ME) 2*2048kB (ME) 1*4096kB (M) = 41008kB
Dec 16 18:56:29 boerne.fritz.box kernel: HighMem: 340*4kB (UME) 339*8kB (UME) 258*16kB (UME) 192*32kB (UME) 69*64kB (UME) 15*128kB (UME) 6*256kB (ME) 5*512kB (UME) 7*1024kB (UME) 4*2048kB (UE) 55*4096kB (UM) = 265416kB
Dec 16 18:56:29 boerne.fritz.box kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Dec 16 18:56:29 boerne.fritz.box kernel: 696480 total pagecache pages
Dec 16 18:56:29 boerne.fritz.box kernel: 0 pages in swap cache
Dec 16 18:56:29 boerne.fritz.box kernel: Swap cache stats: add 0, delete 0, find 0/0
Dec 16 18:56:29 boerne.fritz.box kernel: Free swap  = 3781628kB
Dec 16 18:56:29 boerne.fritz.box kernel: Total swap = 3781628kB
Dec 16 18:56:29 boerne.fritz.box kernel: 1006816 pages RAM
Dec 16 18:56:29 boerne.fritz.box kernel: 778564 pages HighMem/MovableOnly
Dec 16 18:56:29 boerne.fritz.box kernel: 16403 pages reserved
Dec 16 18:56:29 boerne.fritz.box kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
Dec 16 18:56:29 boerne.fritz.box kernel: [ 1874]     0  1874     6166      987       9       3        0             0 systemd-journal
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2497]     0  2497     2965      911       8       3        0         -1000 systemd-udevd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2582]   107  2582     3874      958       8       3        0             0 systemd-timesyn
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2585]   108  2585     1269      883       6       3        0          -900 dbus-daemon
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2586]     0  2586    22054     3277      20       3        0             0 NetworkManager
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2587]     0  2587     1521      972       7       3        0             0 systemd-logind
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2589]    88  2589     1158      627       6       3        0             0 nullmailer-send
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2612]     0  2612     1510      460       5       3        0             0 fcron
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2665]     0  2665      768      580       5       3        0             0 dhcpcd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2668]     0  2668      639      408       5       3        0             0 vnstatd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2669]     0  2669     1460     1063       6       3        0         -1000 sshd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2670]     0  2670     1235      838       6       3        0             0 login
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2672]     0  2672     1972     1267       7       3        0             0 systemd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2700]     0  2700     2279      586       7       3        0             0 (sd-pam)
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2733]     0  2733     1836      890       7       3        0             0 bash
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2753]   109  2753    16724     3089      19       3        0             0 polkitd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2776]     0  2776     2153     1349       7       3        0             0 wpa_supplicant
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2941]     0  2941    16268    15095      36       3        0             0 emerge
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2942]     0  2942     1235      833       5       3        0             0 login
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2949]  1000  2949     2033     1378       7       3        0             0 systemd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2973]  1000  2973     2279      589       7       3        0             0 (sd-pam)
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2989]  1000  2989     1836      907       7       3        0             0 bash
Dec 16 18:56:29 boerne.fritz.box kernel: [ 2997]  1000  2997    25339     2169      17       3        0             0 pulseaudio
Dec 16 18:56:29 boerne.fritz.box kernel: [ 3000]   111  3000     5763      655       9       3        0             0 rtkit-daemon
Dec 16 18:56:29 boerne.fritz.box kernel: [ 3019]  1000  3019     3575     1403      11       3        0             0 gconf-helper
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5626]  1000  5626     1743      709       8       3        0             0 startx
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5647]  1000  5647     1001      579       6       3        0             0 xinit
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5648]  1000  5648    22873     7477      43       3        0             0 X
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5674]  1000  5674    10584     4543      21       3        0             0 awesome
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5718]  1000  5718     1571      610       7       3        0             0 dbus-launch
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5720]  1000  5720     1238      645       6       3        0             0 dbus-daemon
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5725]  1000  5725     1571      634       7       3        0             0 dbus-launch
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5726]  1000  5726     1238      649       6       3        0             0 dbus-daemon
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5823]  1000  5823    35683     8366      42       3        0             0 nm-applet
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5825]  1000  5825    21454     7358      31       3        0             0 xfce4-terminal
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5827]  1000  5827    11257     1911      14       3        0             0 at-spi-bus-laun
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5832]  1000  5832     1238      831       6       3        0             0 dbus-daemon
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5838]  1000  5838     7480     2110      12       3        0             0 at-spi2-registr
Dec 16 18:56:29 boerne.fritz.box kernel: [ 5840]  1000  5840    10179     1459      13       3        0             0 gvfsd
Dec 16 18:56:29 boerne.fritz.box kernel: [ 6181]  1000  6181     1836      883       7       3        0             0 bash
Dec 16 18:56:29 boerne.fritz.box kernel: [ 7874]  1000  7874     2246     1185       8       3        0             0 ssh
Dec 16 18:56:29 boerne.fritz.box kernel: [12950]  1000 12950   197232    73307     252       3        0             0 firefox
Dec 16 18:56:29 boerne.fritz.box kernel: [13020]   250 13020      549      377       4       3        0             0 sandbox
Dec 16 18:56:29 boerne.fritz.box kernel: [13022]   250 13022     2629     1567       8       3        0             0 ebuild.sh
Dec 16 18:56:29 boerne.fritz.box kernel: [13040]  1000 13040     1836      933       7       3        0             0 bash
Dec 16 18:56:29 boerne.fritz.box kernel: [13048]   250 13048     3002     1718       8       3        0             0 ebuild.sh
Dec 16 18:56:29 boerne.fritz.box kernel: [13052]   250 13052     1122      732       5       3        0             0 emake
Dec 16 18:56:29 boerne.fritz.box kernel: [13054]   250 13054      921      697       5       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13118]   250 13118     1048      783       5       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13181]   250 13181     1043      789       5       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13208]   250 13208     1095      855       6       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13255]   250 13255      772      555       5       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13299]   250 13299      913      689       5       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13493]   250 13493      876      619       5       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13494]   250 13494    15191    14639      34       3        0             0 python
Dec 16 18:56:29 boerne.fritz.box kernel: [13532]   250 13532      808      594       4       3        0             0 make
Dec 16 18:56:29 boerne.fritz.box kernel: [13593]  1000 13593     1533      624       7       3        0             0 tar
Dec 16 18:56:29 boerne.fritz.box kernel: [13594]  1000 13594    17834    16906      38       3        0             0 xz
Dec 16 18:56:29 boerne.fritz.box kernel: [13604]   250 13604    12439    11843      27       3        0             0 python
Dec 16 18:56:29 boerne.fritz.box kernel: [13651]   250 13651      253        5       1       3        0             0 sh
Dec 16 18:56:29 boerne.fritz.box kernel: Out of memory: Kill process 12950 (firefox) score 38 or sacrifice child
Dec 16 18:56:29 boerne.fritz.box kernel: Killed process 12950 (firefox) total-vm:788928kB, anon-rss:192656kB, file-rss:100548kB, shmem-rss:24kB
Dec 16 18:56:29 boerne.fritz.box kernel: oom_reaper: reaped process 12950 (firefox), now anon-rss:0kB, file-rss:96kB, shmem-rss:24kB
Dec 16 18:56:31 boerne.fritz.box kernel: xfce4-terminal invoked oom-killer: gfp_mask=0x25000c0(GFP_KERNEL_ACCOUNT), nodemask=0, order=0, oom_score_adj=0
Dec 16 18:56:31 boerne.fritz.box kernel: xfce4-terminal cpuset=/ mems_allowed=0
Dec 16 18:56:31 boerne.fritz.box kernel: CPU: 0 PID: 5825 Comm: xfce4-terminal Not tainted 4.9.0-gentoo #3
Dec 16 18:56:31 boerne.fritz.box kernel: Hardware name: TOSHIBA Satellite L500/KSWAA, BIOS V1.80 10/28/2009
Dec 16 18:56:31 boerne.fritz.box kernel:  c6941c18 c1433406 c6941d48 c5972500 c6941c48 c1170011 c6941c9c 00200286
Dec 16 18:56:31 boerne.fritz.box kernel:  c6941c48 c1438fff c6941c4c edc1a940 ee32d400 c5972500 c1ad1899 c6941d48
Dec 16 18:56:31 boerne.fritz.box kernel:  c6941c8c c1114407 c10513a5 c6941c78 c11140a1 00000006 00000000 00000000
Dec 16 18:56:31 boerne.fritz.box kernel: Call Trace:
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1433406>] dump_stack+0x47/0x61
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1170011>] dump_header+0x5f/0x175
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1438fff>] ? ___ratelimit+0x7f/0xe0
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1114407>] oom_kill_process+0x207/0x3c0
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c10513a5>] ? has_capability_noaudit+0x15/0x20
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c11140a1>] ? oom_badness.part.13+0xb1/0x120
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c11148c4>] out_of_memory+0xd4/0x270
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1118615>] __alloc_pages_nodemask+0xcf5/0xd60
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1758900>] ? skb_queue_purge+0x30/0x30
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c175dcde>] alloc_skb_with_frags+0xee/0x1a0
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1753dba>] sock_alloc_send_pskb+0x19a/0x1c0
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1186120>] ? poll_select_copy_remaining+0x120/0x120
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1825880>] ? wait_for_unix_gc+0x20/0x90
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1823fc0>] unix_stream_sendmsg+0x2a0/0x350
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1750b3d>] sock_sendmsg+0x2d/0x40
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1750bb7>] sock_write_iter+0x67/0xc0
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1172c42>] do_readv_writev+0x1e2/0x380
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1750b50>] ? sock_sendmsg+0x40/0x40
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1033763>] ? lapic_next_event+0x13/0x20
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c10ae675>] ? clockevents_program_event+0x95/0x190
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c10a074a>] ? __hrtimer_run_queues+0x20a/0x280
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1173d16>] vfs_writev+0x36/0x60
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1173d85>] do_writev+0x45/0xc0
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c1173efb>] SyS_writev+0x1b/0x20
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c10018ec>] do_fast_syscall_32+0x7c/0x130
Dec 16 18:56:31 boerne.fritz.box kernel:  [<c194232b>] sysenter_past_esp+0x40/0x6a
Dec 16 18:56:31 boerne.fritz.box kernel: Mem-Info:
Dec 16 18:56:31 boerne.fritz.box kernel: active_anon:72795 inactive_anon:7267 isolated_anon:0
                                          active_file:297627 inactive_file:387672 isolated_file:0
                                          unevictable:0 dirty:77 writeback:18 unstable:0
                                          slab_reclaimable:54648 slab_unreclaimable:21983
                                          mapped:17819 shmem:8215 pagetables:662 bounce:8
                                          free:141692 free_pcp:107 free_cma:0
Dec 16 18:56:31 boerne.fritz.box kernel: Node 0 active_anon:291180kB inactive_anon:29068kB active_file:1190508kB inactive_file:1550688kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:71276kB dirty:308kB writeback:72kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 122880kB anon_thp: 32860kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
Dec 16 18:56:31 boerne.fritz.box kernel: DMA free:4020kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:4804kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:5356kB slab_unreclaimable:1572kB kernel_stack:32kB pagetables:84kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: lowmem_reserve[]: 0 808 3849 3849
Dec 16 18:56:32 boerne.fritz.box kernel: Normal free:41028kB min:41100kB low:51372kB high:61644kB active_anon:0kB inactive_anon:0kB active_file:472164kB inactive_file:108kB unevictable:0kB writepending:112kB present:897016kB managed:831480kB mlocked:0kB slab_reclaimable:213236kB slab_unreclaimable:86360kB kernel_stack:1584kB pagetables:2564kB bounce:32kB free_pcp:180kB local_pcp:24kB free_cma:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 24330 24330
Dec 16 18:56:32 boerne.fritz.box kernel: HighMem free:521720kB min:512kB low:39184kB high:77856kB active_anon:291180kB inactive_anon:29068kB active_file:713448kB inactive_file:1550556kB unevictable:0kB writepending:76kB present:3114256kB managed:3114256kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:248kB local_pcp:156kB free_cma:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 0 0
Dec 16 18:56:32 boerne.fritz.box kernel: DMA: 13*4kB (UE) 2*8kB (U) 1*16kB (E) 1*32kB (U) 1*64kB (U) 0*128kB 1*256kB (E) 1*512kB (E) 1*1024kB (U) 1*2048kB (M) 0*4096kB = 4020kB
Dec 16 18:56:32 boerne.fritz.box kernel: Normal: 37*4kB (UME) 24*8kB (ME) 17*16kB (UME) 137*32kB (UME) 143*64kB (UME) 82*128kB (UM) 18*256kB (UM) 3*512kB (UME) 2*1024kB (ME) 2*2048kB (ME) 1*4096kB (M) = 41028kB
Dec 16 18:56:32 boerne.fritz.box kernel: HighMem: 3230*4kB (ME) 1616*8kB (M) 680*16kB (UM) 398*32kB (UME) 145*64kB (UM) 59*128kB (UM) 25*256kB (ME) 19*512kB (UME) 9*1024kB (UME) 36*2048kB (UME) 87*4096kB (UME) = 521720kB
Dec 16 18:56:32 boerne.fritz.box kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Dec 16 18:56:32 boerne.fritz.box kernel: 693537 total pagecache pages
Dec 16 18:56:32 boerne.fritz.box kernel: 0 pages in swap cache
Dec 16 18:56:32 boerne.fritz.box kernel: Swap cache stats: add 0, delete 0, find 0/0
Dec 16 18:56:32 boerne.fritz.box kernel: Free swap  = 3781628kB
Dec 16 18:56:32 boerne.fritz.box kernel: Total swap = 3781628kB
Dec 16 18:56:32 boerne.fritz.box kernel: 1006816 pages RAM
Dec 16 18:56:32 boerne.fritz.box kernel: 778564 pages HighMem/MovableOnly
Dec 16 18:56:32 boerne.fritz.box kernel: 16403 pages reserved
Dec 16 18:56:32 boerne.fritz.box kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
Dec 16 18:56:32 boerne.fritz.box kernel: [ 1874]     0  1874     6166     1007       9       3        0             0 systemd-journal
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2497]     0  2497     2965      911       8       3        0         -1000 systemd-udevd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2582]   107  2582     3874      958       8       3        0             0 systemd-timesyn
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2585]   108  2585     1301      885       6       3        0          -900 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2586]     0  2586    22054     3277      20       3        0             0 NetworkManager
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2587]     0  2587     1521      972       7       3        0             0 systemd-logind
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2589]    88  2589     1158      627       6       3        0             0 nullmailer-send
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2612]     0  2612     1510      460       5       3        0             0 fcron
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2665]     0  2665      768      580       5       3        0             0 dhcpcd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2668]     0  2668      639      408       5       3        0             0 vnstatd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2669]     0  2669     1460     1063       6       3        0         -1000 sshd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2670]     0  2670     1235      838       6       3        0             0 login
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2672]     0  2672     1972     1267       7       3        0             0 systemd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2700]     0  2700     2279      586       7       3        0             0 (sd-pam)
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2733]     0  2733     1836      890       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2753]   109  2753    16724     3089      19       3        0             0 polkitd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2776]     0  2776     2153     1349       7       3        0             0 wpa_supplicant
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2941]     0  2941    16268    15095      36       3        0             0 emerge
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2942]     0  2942     1235      833       5       3        0             0 login
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2949]  1000  2949     2033     1378       7       3        0             0 systemd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2973]  1000  2973     2279      589       7       3        0             0 (sd-pam)
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2989]  1000  2989     1836      907       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2997]  1000  2997    25339     2169      17       3        0             0 pulseaudio
Dec 16 18:56:32 boerne.fritz.box kernel: [ 3000]   111  3000     5763      655       9       3        0             0 rtkit-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 3019]  1000  3019     3575     1403      11       3        0             0 gconf-helper
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5626]  1000  5626     1743      709       8       3        0             0 startx
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5647]  1000  5647     1001      579       6       3        0             0 xinit
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5648]  1000  5648    22392     7078      41       3        0             0 X
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5674]  1000  5674    10584     4543      21       3        0             0 awesome
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5718]  1000  5718     1571      610       7       3        0             0 dbus-launch
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5720]  1000  5720     1238      645       6       3        0             0 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5725]  1000  5725     1571      634       7       3        0             0 dbus-launch
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5726]  1000  5726     1238      649       6       3        0             0 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5823]  1000  5823    35683     8366      42       3        0             0 nm-applet
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5825]  1000  5825    21454     7358      31       3        0             0 xfce4-terminal
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5827]  1000  5827    11257     1911      14       3        0             0 at-spi-bus-laun
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5832]  1000  5832     1238      831       6       3        0             0 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5838]  1000  5838     7480     2110      12       3        0             0 at-spi2-registr
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5840]  1000  5840    10179     1459      13       3        0             0 gvfsd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 6181]  1000  6181     1836      883       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [ 7874]  1000  7874     2246     1185       8       3        0             0 ssh
Dec 16 18:56:32 boerne.fritz.box kernel: [13020]   250 13020      549      377       4       3        0             0 sandbox
Dec 16 18:56:32 boerne.fritz.box kernel: [13022]   250 13022     2629     1567       8       3        0             0 ebuild.sh
Dec 16 18:56:32 boerne.fritz.box kernel: [13040]  1000 13040     1836      933       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [13048]   250 13048     3002     1718       8       3        0             0 ebuild.sh
Dec 16 18:56:32 boerne.fritz.box kernel: [13052]   250 13052     1122      732       5       3        0             0 emake
Dec 16 18:56:32 boerne.fritz.box kernel: [13054]   250 13054      921      697       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13118]   250 13118     1048      783       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13181]   250 13181     1043      789       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13208]   250 13208     1095      855       6       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13255]   250 13255      772      555       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13299]   250 13299      913      689       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13493]   250 13493      876      619       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13494]   250 13494    15321    14729      34       3        0             0 python
Dec 16 18:56:32 boerne.fritz.box kernel: [13532]   250 13532      808      594       4       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13593]  1000 13593     1533      624       7       3        0             0 tar
Dec 16 18:56:32 boerne.fritz.box kernel: [13594]  1000 13594    17834    16906      38       3        0             0 xz
Dec 16 18:56:32 boerne.fritz.box kernel: [13604]   250 13604    12599    12029      28       3        0             0 python
Dec 16 18:56:32 boerne.fritz.box kernel: [13658]   250 13658     1549     1104       6       3        0             0 python
Dec 16 18:56:32 boerne.fritz.box kernel: Out of memory: Kill process 13594 (xz) score 8 or sacrifice child
Dec 16 18:56:32 boerne.fritz.box kernel: Killed process 13594 (xz) total-vm:71336kB, anon-rss:65668kB, file-rss:1956kB, shmem-rss:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: xfce4-terminal invoked oom-killer: gfp_mask=0x25000c0(GFP_KERNEL_ACCOUNT), nodemask=0, order=0, oom_score_adj=0
Dec 16 18:56:32 boerne.fritz.box kernel: xfce4-terminal cpuset=/ mems_allowed=0
Dec 16 18:56:32 boerne.fritz.box kernel: CPU: 1 PID: 5825 Comm: xfce4-terminal Not tainted 4.9.0-gentoo #3
Dec 16 18:56:32 boerne.fritz.box kernel: Hardware name: TOSHIBA Satellite L500/KSWAA, BIOS V1.80 10/28/2009
Dec 16 18:56:32 boerne.fritz.box kernel:  c6941c18 c1433406 c6941d48 ef25ef00 c6941c48 c1170011 c6941c9c 00200286
Dec 16 18:56:32 boerne.fritz.box kernel:  c6941c48 c1438fff c6941c4c ef267c80 ef233a00 ef25ef00 c1ad1899 c6941d48
Dec 16 18:56:32 boerne.fritz.box kernel:  c6941c8c c1114407 c10513a5 c6941c78 c11140a1 00000006 00000000 00000000
Dec 16 18:56:32 boerne.fritz.box kernel: Call Trace:
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1433406>] dump_stack+0x47/0x61
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1170011>] dump_header+0x5f/0x175
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1438fff>] ? ___ratelimit+0x7f/0xe0
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1114407>] oom_kill_process+0x207/0x3c0
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c10513a5>] ? has_capability_noaudit+0x15/0x20
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c11140a1>] ? oom_badness.part.13+0xb1/0x120
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c11148c4>] out_of_memory+0xd4/0x270
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1118615>] __alloc_pages_nodemask+0xcf5/0xd60
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1758900>] ? skb_queue_purge+0x30/0x30
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c175dcde>] alloc_skb_with_frags+0xee/0x1a0
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1753dba>] sock_alloc_send_pskb+0x19a/0x1c0
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1186120>] ? poll_select_copy_remaining+0x120/0x120
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1825880>] ? wait_for_unix_gc+0x20/0x90
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1823fc0>] unix_stream_sendmsg+0x2a0/0x350
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1750b3d>] sock_sendmsg+0x2d/0x40
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1750bb7>] sock_write_iter+0x67/0xc0
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1172c42>] do_readv_writev+0x1e2/0x380
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1750b50>] ? sock_sendmsg+0x40/0x40
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1033763>] ? lapic_next_event+0x13/0x20
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c10ae675>] ? clockevents_program_event+0x95/0x190
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c10a074a>] ? __hrtimer_run_queues+0x20a/0x280
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1173d16>] vfs_writev+0x36/0x60
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1173d85>] do_writev+0x45/0xc0
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c1173efb>] SyS_writev+0x1b/0x20
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c10018ec>] do_fast_syscall_32+0x7c/0x130
Dec 16 18:56:32 boerne.fritz.box kernel:  [<c194232b>] sysenter_past_esp+0x40/0x6a
Dec 16 18:56:32 boerne.fritz.box kernel: Mem-Info:
Dec 16 18:56:32 boerne.fritz.box kernel: active_anon:56747 inactive_anon:7267 isolated_anon:0
                                          active_file:297677 inactive_file:387697 isolated_file:0
                                          unevictable:0 dirty:151 writeback:18 unstable:0
                                          slab_reclaimable:54648 slab_unreclaimable:21983
                                          mapped:17769 shmem:8215 pagetables:637 bounce:8
                                          free:157498 free_pcp:299 free_cma:0
Dec 16 18:56:32 boerne.fritz.box kernel: Node 0 active_anon:226988kB inactive_anon:29068kB active_file:1190708kB inactive_file:1550788kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:71076kB dirty:604kB writeback:72kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 47104kB anon_thp: 32860kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
Dec 16 18:56:32 boerne.fritz.box kernel: DMA free:4020kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:4804kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:5356kB slab_unreclaimable:1572kB kernel_stack:32kB pagetables:84kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: lowmem_reserve[]: 0 808 3849 3849
Dec 16 18:56:32 boerne.fritz.box kernel: Normal free:40988kB min:41100kB low:51372kB high:61644kB active_anon:0kB inactive_anon:0kB active_file:472436kB inactive_file:144kB unevictable:0kB writepending:312kB present:897016kB managed:831480kB mlocked:0kB slab_reclaimable:213236kB slab_unreclaimable:86360kB kernel_stack:1584kB pagetables:2464kB bounce:32kB free_pcp:116kB local_pcp:0kB free_cma:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 24330 24330
Dec 16 18:56:32 boerne.fritz.box kernel: HighMem free:584984kB min:512kB low:39184kB high:77856kB active_anon:226988kB inactive_anon:29068kB active_file:713448kB inactive_file:1550556kB unevictable:0kB writepending:224kB present:3114256kB managed:3114256kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:1080kB local_pcp:400kB free_cma:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: lowmem_reserve[]: 0 0 0 0
Dec 16 18:56:32 boerne.fritz.box kernel: DMA: 13*4kB (UE) 2*8kB (U) 1*16kB (E) 1*32kB (U) 1*64kB (U) 0*128kB 1*256kB (E) 1*512kB (E) 1*1024kB (U) 1*2048kB (M) 0*4096kB = 4020kB
Dec 16 18:56:32 boerne.fritz.box kernel: Normal: 36*4kB (ME) 24*8kB (ME) 16*16kB (ME) 138*32kB (UME) 143*64kB (UME) 82*128kB (UM) 18*256kB (UM) 3*512kB (UME) 2*1024kB (ME) 2*2048kB (ME) 1*4096kB (M) = 41040kB
Dec 16 18:56:32 boerne.fritz.box kernel: HighMem: 3430*4kB (UME) 1795*8kB (UME) 750*16kB (UM) 401*32kB (UM) 148*64kB (UME) 56*128kB (UM) 28*256kB (UME) 19*512kB (UME) 9*1024kB (UME) 55*2048kB (UME) 92*4096kB (UME) = 585136kB
Dec 16 18:56:32 boerne.fritz.box kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB
Dec 16 18:56:32 boerne.fritz.box kernel: 693648 total pagecache pages
Dec 16 18:56:32 boerne.fritz.box kernel: 0 pages in swap cache
Dec 16 18:56:32 boerne.fritz.box kernel: Swap cache stats: add 0, delete 0, find 0/0
Dec 16 18:56:32 boerne.fritz.box kernel: Free swap  = 3781628kB
Dec 16 18:56:32 boerne.fritz.box kernel: Total swap = 3781628kB
Dec 16 18:56:32 boerne.fritz.box kernel: 1006816 pages RAM
Dec 16 18:56:32 boerne.fritz.box kernel: 778564 pages HighMem/MovableOnly
Dec 16 18:56:32 boerne.fritz.box kernel: 16403 pages reserved
Dec 16 18:56:32 boerne.fritz.box kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
Dec 16 18:56:32 boerne.fritz.box kernel: [ 1874]     0  1874     6166     1011       9       3        0             0 systemd-journal
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2497]     0  2497     2965      911       8       3        0         -1000 systemd-udevd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2582]   107  2582     3874      958       8       3        0             0 systemd-timesyn
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2585]   108  2585     1301      885       6       3        0          -900 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2586]     0  2586    22054     3277      20       3        0             0 NetworkManager
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2587]     0  2587     1521      972       7       3        0             0 systemd-logind
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2589]    88  2589     1158      627       6       3        0             0 nullmailer-send
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2612]     0  2612     1510      460       5       3        0             0 fcron
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2665]     0  2665      768      580       5       3        0             0 dhcpcd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2668]     0  2668      639      408       5       3        0             0 vnstatd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2669]     0  2669     1460     1063       6       3        0         -1000 sshd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2670]     0  2670     1235      838       6       3        0             0 login
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2672]     0  2672     1972     1267       7       3        0             0 systemd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2700]     0  2700     2279      586       7       3        0             0 (sd-pam)
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2733]     0  2733     1836      890       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2753]   109  2753    16724     3089      19       3        0             0 polkitd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2776]     0  2776     2153     1349       7       3        0             0 wpa_supplicant
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2941]     0  2941    16268    15095      36       3        0             0 emerge
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2942]     0  2942     1235      833       5       3        0             0 login
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2949]  1000  2949     2033     1378       7       3        0             0 systemd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2973]  1000  2973     2279      589       7       3        0             0 (sd-pam)
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2989]  1000  2989     1836      907       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [ 2997]  1000  2997    25339     2169      17       3        0             0 pulseaudio
Dec 16 18:56:32 boerne.fritz.box kernel: [ 3000]   111  3000     5763      655       9       3        0             0 rtkit-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 3019]  1000  3019     3575     1403      11       3        0             0 gconf-helper
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5626]  1000  5626     1743      709       8       3        0             0 startx
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5647]  1000  5647     1001      579       6       3        0             0 xinit
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5648]  1000  5648    22392     7078      41       3        0             0 X
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5674]  1000  5674    10584     4543      21       3        0             0 awesome
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5718]  1000  5718     1571      610       7       3        0             0 dbus-launch
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5720]  1000  5720     1238      645       6       3        0             0 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5725]  1000  5725     1571      634       7       3        0             0 dbus-launch
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5726]  1000  5726     1238      649       6       3        0             0 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5823]  1000  5823    35683     8366      42       3        0             0 nm-applet
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5825]  1000  5825    21454     7358      31       3        0             0 xfce4-terminal
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5827]  1000  5827    11257     1911      14       3        0             0 at-spi-bus-laun
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5832]  1000  5832     1238      831       6       3        0             0 dbus-daemon
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5838]  1000  5838     7480     2110      12       3        0             0 at-spi2-registr
Dec 16 18:56:32 boerne.fritz.box kernel: [ 5840]  1000  5840    10179     1459      13       3        0             0 gvfsd
Dec 16 18:56:32 boerne.fritz.box kernel: [ 6181]  1000  6181     1836      883       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [ 7874]  1000  7874     2246     1185       8       3        0             0 ssh
Dec 16 18:56:32 boerne.fritz.box kernel: [13020]   250 13020      549      377       4       3        0             0 sandbox
Dec 16 18:56:32 boerne.fritz.box kernel: [13022]   250 13022     2629     1567       8       3        0             0 ebuild.sh
Dec 16 18:56:32 boerne.fritz.box kernel: [13040]  1000 13040     1836      933       7       3        0             0 bash
Dec 16 18:56:32 boerne.fritz.box kernel: [13048]   250 13048     3002     1718       8       3        0             0 ebuild.sh
Dec 16 18:56:32 boerne.fritz.box kernel: [13052]   250 13052     1122      732       5       3        0             0 emake
Dec 16 18:56:32 boerne.fritz.box kernel: [13054]   250 13054      921      697       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13118]   250 13118     1048      783       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13181]   250 13181     1043      789       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13208]   250 13208     1095      855       6       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13255]   250 13255      772      555       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13299]   250 13299      913      689       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13493]   250 13493      876      619       5       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13494]   250 13494    15321    14775      34       3        0             0 python
Dec 16 18:56:32 boerne.fritz.box kernel: [13532]   250 13532      808      594       4       3        0             0 make
Dec 16 18:56:32 boerne.fritz.box kernel: [13593]  1000 13593     1533      643       7       3        0             0 tar
Dec 16 18:56:32 boerne.fritz.box kernel: [13604]   250 13604    12760    12198      28       3        0             0 python
Dec 16 18:56:32 boerne.fritz.box kernel: [13658]   250 13658     1687     1280       6       3        0             0 python
Dec 16 18:56:32 boerne.fritz.box kernel: Out of memory: Kill process 13494 (python) score 7 or sacrifice child
Dec 16 18:56:32 boerne.fritz.box kernel: Killed process 13494 (python) total-vm:61284kB, anon-rss:54128kB, file-rss:4972kB, shmem-rss:0kB
Dec 16 18:56:32 boerne.fritz.box kernel: oom_reaper: reaped process 13494 (python), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB

Greetings
Nils

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
