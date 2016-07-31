Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9E5828EA
	for <linux-mm@kvack.org>; Sun, 31 Jul 2016 11:10:51 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so61295199lfw.1
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 08:10:51 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id u2si27500798wji.139.2016.07.31.08.10.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 31 Jul 2016 08:10:49 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id o80so211632731wme.1
        for <linux-mm@kvack.org>; Sun, 31 Jul 2016 08:10:49 -0700 (PDT)
Date: Sun, 31 Jul 2016 17:10:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: OOM killer invoked during btrfs send/recieve on otherwise idle
 machine
Message-ID: <20160731151047.GA4496@dhcp22.suse.cz>
References: <20160731051121.GB307@x4>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160731051121.GB307@x4>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

[CC Mel and linux-mm]

On Sun 31-07-16 07:11:21, Markus Trippelsdorf wrote:
> Tonight the OOM killer got invoked during backup of /:
> 
> [Jul31 01:56] kthreadd invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0

This a kernel stack allocation.

> [  +0.000004] CPU: 3 PID: 2 Comm: kthreadd Not tainted 4.7.0-06816-g797cee982eef-dirty #37
> [  +0.000000] Hardware name: System manufacturer System Product Name/M4A78T-E, BIOS 3503    04/13/2011
> [  +0.000002]  0000000000000000 ffffffff813c2d58 ffff8802168e7d48 00000000002ec4ea
> [  +0.000002]  ffffffff8118eb9d 00000000000001b8 0000000000000440 00000000000003b0
> [  +0.000002]  ffff8802133fe400 00000000002ec4ea ffffffff81b8ac9c 0000000000000006
> [  +0.000001] Call Trace:
> [  +0.000004]  [<ffffffff813c2d58>] ? dump_stack+0x46/0x6e
> [  +0.000003]  [<ffffffff8118eb9d>] ? dump_header.isra.11+0x4c/0x1a7
> [  +0.000002]  [<ffffffff811382eb>] ? oom_kill_process+0x2ab/0x460
> [  +0.000001]  [<ffffffff811387e3>] ? out_of_memory+0x2e3/0x380
> [  +0.000002]  [<ffffffff81141532>] ? __alloc_pages_slowpath.constprop.124+0x1d32/0x1e40
> [  +0.000001]  [<ffffffff81141b4c>] ? __alloc_pages_nodemask+0x10c/0x120
> [  +0.000002]  [<ffffffff810939aa>] ? copy_process.part.72+0xea/0x17a0
> [  +0.000002]  [<ffffffff810d1a55>] ? pick_next_task_fair+0x915/0x1520
> [  +0.000001]  [<ffffffff810b7a00>] ? kthread_flush_work_fn+0x20/0x20
> [  +0.000001]  [<ffffffff8109549a>] ? kernel_thread+0x7a/0x1c0
> [  +0.000001]  [<ffffffff810b82f2>] ? kthreadd+0xd2/0x120
> [  +0.000002]  [<ffffffff818d828f>] ? ret_from_fork+0x1f/0x40
> [  +0.000001]  [<ffffffff810b8220>] ? kthread_stop+0x100/0x100
> [  +0.000001] Mem-Info:
> [  +0.000003] active_anon:5882 inactive_anon:60307 isolated_anon:0
>                active_file:1523729 inactive_file:223965 isolated_file:0
>                unevictable:1970 dirty:130014 writeback:40735 unstable:0
>                slab_reclaimable:179690 slab_unreclaimable:8041
>                mapped:6771 shmem:3 pagetables:592 bounce:0
>                free:11374 free_pcp:54 free_cma:0
> [  +0.000004] Node 0 active_anon:23528kB inactive_anon:241228kB active_file:6094916kB inactive_file:895860kB unevictable:7880kB isolated(anon):0kB isolated(file):0kB mapped:27084kB dirty:520056kB writeback:162940kB shmem:12kB writeback_tmp:0kB unstable:0kB pages_scanned:32 all_unreclaimable? no
> [  +0.000002] DMA free:15908kB min:20kB low:32kB high:44kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [  +0.000001] lowmem_reserve[]: 0 3486 7953 7953
> [  +0.000004] DMA32 free:23456kB min:4996kB low:8564kB high:12132kB active_anon:2480kB inactive_anon:10564kB active_file:2559792kB inactive_file:478680kB unevictable:0kB writepending:365292kB present:3652160kB managed:3574264kB mlocked:0kB slab_reclaimable:437456kB slab_unreclaimable:12304kB kernel_stack:144kB pagetables:28kB bounce:0kB free_pcp:212kB local_pcp:0kB free_cma:0kB
> [  +0.000001] lowmem_reserve[]: 0 0 4466 4466
> [  +0.000003] Normal free:6132kB min:6400kB low:10972kB high:15544kB active_anon:21048kB inactive_anon:230664kB active_file:3535124kB inactive_file:417312kB unevictable:7880kB writepending:318020kB present:4718592kB managed:4574096kB mlocked:7880kB slab_reclaimable:281304kB slab_unreclaimable:19860kB kernel_stack:2944kB pagetables:2340kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
> [  +0.000000] lowmem_reserve[]: 0 0 0 0
> [  +0.000002] DMA: 1*4kB (U) 0*8kB 0*16kB 1*32kB (U) 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (U) 3*4096kB (M) = 15908kB
> [  +0.000005] DMA32: 4215*4kB (UMEH) 319*8kB (UMH) 5*16kB (H) 2*32kB (H) 2*64kB (H) 1*128kB (H) 0*256kB 1*512kB (H) 1*1024kB (H) 1*2048kB (H) 0*4096kB = 23396kB
> [  +0.000006] Normal: 650*4kB (UMH) 4*8kB (UH) 27*16kB (H) 23*32kB (H) 17*64kB (H) 11*128kB (H) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 6296kB

The memory is quite fragmented but there are order-2+ free blocks. They
seem to be in the high atomic reserves but we should release them.
Is this reproducible? If yes, could you try with the 4.7 kernel please?

Keeping the rest of the emil for reference.

> [  +0.000005] 1749526 total pagecache pages
> [  +0.000001] 150 pages in swap cache
> [  +0.000001] Swap cache stats: add 1222, delete 1072, find 2366/2401
> [  +0.000000] Free swap  = 4091520kB
> [  +0.000001] Total swap = 4095996kB
> [  +0.000000] 2096686 pages RAM
> [  +0.000001] 0 pages HighMem/MovableOnly
> [  +0.000000] 55619 pages reserved
> [  +0.000001] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds swapents oom_score_adj name
> [  +0.000004] [  153]     0   153     4087      406       9       3      104         -1000 udevd
> [  +0.000001] [  181]     0   181     5718     1169      15       3      143             0 syslog-ng
> [  +0.000001] [  187]   102   187    88789     5137      53       3      663             0 mpd
> [  +0.000002] [  188]     0   188    22278     1956      16       3        0             0 ntpd
> [  +0.000001] [  189]     0   189     4973      859      14       3      188             0 cupsd
> [  +0.000001] [  192]     0   192     2680      391      10       3       21             0 fcron
> [  +0.000001] [  219]     0   219     4449      506      13       3        0             0 login
> [  +0.000002] [  220]     0   220     2876      368       9       3        0             0 agetty
> [  +0.000001] [  222]    31   222    27193    20995      57       3        0             0 squid
> [  +0.000001] [  225]  1000   225     7410     3878      17       3        0             0 zsh
> [  +0.000001] [  297]  1000   297     9339     4771      23       3        0             0 tmux
> [  +0.000001] [  298]     0   298     4674      571      13       3        0             0 sudo
> [  +0.000001] [  300]     0   300     4674      588      13       3        0             0 sudo
> [  +0.000002] [  302]  1000   302     2721      738       9       3        0             0 sh
> [  +0.000001] [  304]  1000   304    18149     5230      35       3        0             0 ncmpcpp
> [  +0.000014] [  307]  1000   307    19239    13079      40       3        0             0 mutt
> [  +0.000001] [  309]  1000   309     7550     4002      17       3        0             0 zsh
> [  +0.000001] [  311]  1000   311     7620     4089      18       3        0             0 zsh
> [  +0.000002] [  313]     0   313     4072      568      13       3        0             0 su
> [  +0.000001] [  314]     0   314     4072      560      14       3        0             0 su
> [  +0.000001] [  315]  1000   315     7554     4045      19       3        0             0 zsh
> [  +0.000001] [  317]  1000   317     7571     4030      18       3        0             0 zsh
> [  +0.000001] [  319]  1000   319     7624     4097      18       3        0             0 zsh
> [  +0.000002] [  334]     0   334     5511     1952      15       3        0             0 zsh
> [  +0.000001] [  335]     0   335     5539     2059      15       3        0             0 zsh
> [  +0.000001] [  376]     0   376     4674      553      14       3        0             0 sudo
> [  +0.000001] [  377]     0   377     6915     2915      17       3        0             0 multitail
> [  +0.000001] [  378]     0   378     1829      146       8       3        0             0 tail
> [  +0.000001] [  379]     0   379     1829      144       8       3        0             0 tail
> [  +0.000002] [14764]  1000 14764     6731     2363      16       3        0             0 mc
> [  +0.000005] [22909]     0 22909     2680      430      10       3        8             0 fcron
> [  +0.000003] [22910]     0 22910     1943      612       8       3        0             0 sh
> [  +0.000002] [22915]     0 22915     3915      242       8       3        0             0 btrfs
> [  +0.000003] [22916]     0 22916     1866      245       8       3        0             0 btrfs
> [  +0.000003] Out of memory: Kill process 222 (squid) score 6 or sacrifice child
> [  +0.001307] Killed process 222 (squid) total-vm:108772kB, anon-rss:76336kB, file-rss:7632kB, shmem-rss:12kB
> 
> The machine was otherwise idle (I was asleep). I have 8GB of memory.
> 
> This is the backup script that I run daily at 01:52:
> 
> x4 ~ # cat /sbin/snapshot_btrfs
> btrfs subvolume snapshot -r / /root/snap-new
> sync
> btrfs send -p /root/snap /root/snap-new | btrfs receive /var/.snapshots
> sync
> btrfs subvolume delete /root/snap
> mv /root/snap-new /root/snap
> mv /var/.snapshots/snap /var/.snapshots/snap.$(date +%Y-%m-%d)
> mv /var/.snapshots/snap-new /var/.snapshots/snap
> 
> The OOM killer triggered during btrfs send/receive.
> 
> I'm running the latest git kernel.
> 
> -- 
> Markus

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
