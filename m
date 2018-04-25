Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id F3E2C6B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 15:58:02 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b13so11495696pgw.1
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 12:58:02 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m68sor4879511pfm.130.2018.04.25.12.58.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Apr 2018 12:58:01 -0700 (PDT)
Date: Wed, 25 Apr 2018 12:57:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: OOM killer invoked while still one forth of mem is available
In-Reply-To: <df1a8c14-bda3-6271-d403-24b88a254b2c@c-s.fr>
Message-ID: <alpine.DEB.2.21.1804251253240.151692@chino.kir.corp.google.com>
References: <df1a8c14-bda3-6271-d403-24b88a254b2c@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: christophe leroy <christophe.leroy@c-s.fr>
Cc: linux-mm@kvack.org

On Tue, 24 Apr 2018, christophe leroy wrote:

> Hi
> 
> Allthough there is still about one forth of memory available (7976kB
> among 32MB), oom-killer is invoked and makes a victim.
> 
> What could be the reason and how could it be solved ?
> 
> [   54.400754] S99watchdogd-ap invoked oom-killer:
> gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), nodemask=0,
> order=1, oom_score_adj=0
> [   54.400815] CPU: 0 PID: 777 Comm: S99watchdogd-ap Not tainted
> 4.9.85-local-knld-998 #5
> [   54.400830] Call Trace:
> [   54.400910] [c1ca5d10] [c0327d28] dump_header.isra.4+0x54/0x17c
> (unreliable)
> [   54.400998] [c1ca5d50] [c0079d88] oom_kill_process+0xc4/0x414
> [   54.401067] [c1ca5d90] [c007a5c8] out_of_memory+0x35c/0x37c
> [   54.401220] [c1ca5dc0] [c007d68c] __alloc_pages_nodemask+0x8ec/0x9a8
> [   54.401318] [c1ca5e70] [c00169d4] copy_process.isra.9.part.10+0xdc/0x10d0
> [   54.401398] [c1ca5f00] [c0017b30] _do_fork+0xcc/0x2a8
> [   54.401473] [c1ca5f40] [c000a660] ret_from_syscall+0x0/0x38

Looks like this is because the allocation is order-1, likely the 
allocation of a struct task_struct for a new process on fork.

I'm interested in your platform, though, with 512KB and 8MB hugepages.  
Could you send the .config and also describe the system a bit more?  How 
many cpus are there and does this always happen?

> [   54.401501] Mem-Info:
> [   54.401616] active_anon:2727 inactive_anon:91 isolated_anon:0
> [   54.401616]  active_file:51 inactive_file:26 isolated_file:0
> [   54.401616]  unevictable:604 dirty:0 writeback:0 unstable:0
> [   54.401616]  slab_reclaimable:115 slab_unreclaimable:722
> [   54.401616]  mapped:787 shmem:284 pagetables:167 bounce:0
> [   54.401616]  free:1994 free_pcp:0 free_cma:0
> [   54.401715] Node 0 active_anon:10908kB inactive_anon:364kB
> active_file:204kB inactive_file:104kB unevictable:2416kB
> isolated(anon):0kB isolated(file):0kB mapped:3148kB dirty:0kB
> writeback:0kB shmem:1136kB writeback_tmp:0kB unstable:0kB
> pages_scanned:59 all_unreclaimable? no
> [   54.401851] DMA free:7976kB min:660kB low:824kB high:988kB
> active_anon:10908kB inactive_anon:364kB active_file:204kB
> inactive_file:104kB unevictable:2416kB writepending:0kB present:32768kB
> managed:27912kB mlocked:2416kB slab_reclaimable:460kB
> slab_unreclaimable:2888kB kernel_stack:880kB pagetables:668kB bounce:0kB
> free_pcp:0kB local_pcp:0kB free_cma:0kB
> lowmem_reserve[]: 0 0 0
> [   54.437414] DMA: 460*4kB (UH) 201*8kB (UH) 121*16kB (UH) 43*32kB (UH)
> 10*64kB (U) 4*128kB (UH) 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB
> 0*8192kB = 7912kB
> [   54.437730] Node 0 hugepages_total=0 hugepages_free=0
> hugepages_surp=0 hugepages_size=512kB
> [   54.437768] Node 0 hugepages_total=0 hugepages_free=0
> hugepages_surp=0 hugepages_size=8192kB
> [   54.437784] 892 total pagecache pages
> [   54.437802] 8192 pages RAM
> [   54.437818] 0 pages HighMem/MovableOnly
> [   54.437834] 1214 pages reserved
> [   54.437854] [ pid ]   uid  tgid total_vm      rss nr_ptes nr_pmds
> swapents oom_score_adj name
> [   54.437928] [  216]     0   216     1240      253       6       0
>    0             0 rcS
> [   54.437986] [  356]     0   356     4687      333       7       0
>    0             0 rsyslogd
> [   54.438042] [  360]     0   360     1240      245       5       0
>    0             0 klogd
> [   54.438099] [  370]     0   370      701      607       5       0
>    0         -1000 watchdog
> [   54.438156] [  384]     0   384     1114      440       5       0
>    0             0 ntpd
> [   54.438213] [  401]     0   401     1279      419       6       0
>    0             0 inetd
> [   54.438270] [  413]     0   413     1240      330       6       0
>    0             0 crond
> [   54.438328] [  587]     0   587     3334      586       7       0
>    0             0 CORSurv
> [   54.438384] [  614]     0   614      484      232       5       0
>    0             0 ASMcsci
> [   54.438441] [  662]     0   662    18777      625      13       0
>    0             0 VOIPcsc
> [   54.438499] [  708]     0   708    18402     1166      22       0
>    0             0 RCUSwitch
> [   54.447253] [  739]     0   739    12958     1275      17       0
>    0             0 CRI_main
> [   54.447320] [  756]     0   756     1240      380       6       0
>    0             0 exe
> [   54.447379] [  757]     0   757     1240      369       6       0
>    0             0 S99watchdogd-ap
> [   54.447436] [  777]     0   777     1240      210       5       0
>    0             0 S99watchdogd-ap
> [   54.447493] [  782]     0   782      793      425       5       0
>    0             0 socat
> [   54.447550] [  784]     0   784      754      420       5       0
>    0             0 socat
> [   54.447607] [  791]     0   791      793      426       5       0
>    0             0 socat
> [   54.447663] [  792]     0   792      754      420       5       0
>    0             0 socat
> [   54.447720] [  799]     0   799      793      426       5       0
>    0             0 socat
> [   54.447777] [  800]     0   800      754      420       5       0
>    0             0 socat
> [   54.447833] [  807]     0   807      793      425       5       0
>    0             0 socat
> [   54.447890] [  808]     0   808      754      421       5       0
>    0             0 socat
> [   54.447927] Out of memory: Kill process 739 (CRI_main) score 180 or
> sacrifice child
> [   54.528280] Killed process 739 (CRI_main) total-vm:51832kB,
> anon-rss:3140kB, file-rss:1592kB, shmem-rss:236kB
