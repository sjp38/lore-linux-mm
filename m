Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 875146B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 20:54:50 -0400 (EDT)
Date: Thu, 26 Apr 2012 20:54:48 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 3.4-rc4 oom killer out of control.
Message-ID: <20120427005448.GD23877@home.goodmis.org>
References: <20120426193551.GA24968@redhat.com>
 <alpine.DEB.2.00.1204261437470.28376@chino.kir.corp.google.com>
 <20120426215257.GA12908@redhat.com>
 <alpine.DEB.2.00.1204261517100.28376@chino.kir.corp.google.com>
 <20120426224419.GA13598@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120426224419.GA13598@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Apr 26, 2012 at 06:44:19PM -0400, Dave Jones wrote:
> On Thu, Apr 26, 2012 at 03:20:34PM -0700, David Rientjes wrote:
>  > On Thu, 26 Apr 2012, Dave Jones wrote:
>  > 
>  > > /sys/kernel/mm/ksm/full_scans is increasing constantly
>  > > 
>  > > full_scans: 146370
>  > > pages_shared: 1
>  > > pages_sharing: 4
>  > > pages_to_scan: 1250
>  > > pages_unshared: 867
>  > > pages_volatile: 1
>  > > run: 1
>  > > sleep_millisecs: 20
>  > > 
>  > 
>  > full_scans is just a counter of how many times it has scanned mergable 
>  > memory so it should be increasing constantly.  Whether pages_to_scan == 
>  > 1250 and sleep_millisecs == 20 is good for your system is unknown.  You 
>  > may want to try disabling ksm entirely (echo 0 > /sys/kernel/mm/ksm/run) 
>  > to see if it significantly increases responsiveness for your workload.
> 

You didn't happen to see any RCU CPU stalls, did you?

-- Steve

> Disabling it stops it hogging the cpu obviously, but there's still 8G of RAM
> and 1G of used swap sitting around doing something.
> 
> # free
>              total       used       free     shared    buffers     cached
> Mem:       8149440    8025716     123724          0        148       7764
> -/+ buffers/cache:    8017804     131636
> Swap:      1423736    1066112     357624
> 
> SysRq : Show Memory
> Mem-Info:
> Node 0 DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> CPU    2: hi:    0, btch:   1 usd:   0
> CPU    3: hi:    0, btch:   1 usd:   0
> Node 0 DMA32 per-cpu:
> CPU    0: hi:  186, btch:  31 usd:  19
> CPU    1: hi:  186, btch:  31 usd: 175
> CPU    2: hi:  186, btch:  31 usd: 140
> CPU    3: hi:  186, btch:  31 usd: 182
> Node 0 Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 167
> CPU    1: hi:  186, btch:  31 usd: 176
> CPU    2: hi:  186, btch:  31 usd: 102
> CPU    3: hi:  186, btch:  31 usd:  94
> active_anon:1529737 inactive_anon:306307 isolated_anon:0
>  active_file:1124 inactive_file:2170 isolated_file:0
>  unevictable:1414 dirty:1 writeback:0 unstable:0
>  free:35645 slab_reclaimable:10150 slab_unreclaimable:56678
>  mapped:404 shmem:48 pagetables:45796 bounce:0
> Node 0 DMA free:15876kB min:128kB low:160kB high:192kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15652kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> lowmem_reserve[]: 0 3246 8034 8034
> Node 0 DMA32 free:62632kB min:27252kB low:34064kB high:40876kB active_anon:2637356kB inactive_anon:527504kB active_file:72kB inactive_file:84kB unevictable:788kB isolated(anon):0kB isolated(file):0kB present:3324200kB mlocked:788kB dirty:0kB writeback:0kB mapped:212kB shmem:72kB slab_reclaimable:944kB slab_unreclaimable:24736kB kernel_stack:336kB pagetables:30028kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:116 all_unreclaimable? no
> lowmem_reserve[]: 0 0 4788 4788
> Node 0 Normal free:64072kB min:40196kB low:50244kB high:60292kB active_anon:3481592kB inactive_anon:697724kB active_file:4424kB inactive_file:8596kB unevictable:4868kB isolated(anon):0kB isolated(file):0kB present:4902912kB mlocked:4868kB dirty:4kB writeback:0kB mapped:1404kB shmem:120kB slab_reclaimable:39656kB slab_unreclaimable:201944kB kernel_stack:2968kB pagetables:153156kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 0 DMA: 1*4kB 0*8kB 0*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 3*4096kB = 15876kB
> Node 0 DMA32: 214*4kB 124*8kB 65*16kB 55*32kB 32*64kB 15*128kB 9*256kB 7*512kB 7*1024kB 4*2048kB 8*4096kB = 62632kB
> Node 0 Normal: 670*4kB 573*8kB 402*16kB 468*32kB 171*64kB 73*128kB 31*256kB 12*512kB 1*1024kB 0*2048kB 0*4096kB = 64064kB
> 5683 total pagecache pages
> 2341 pages in swap cache
> Swap cache stats: add 2029253, delete 2026912, find 483987/484568
> Free swap  = 343568kB
> Total swap = 1423736kB
> 2097136 pages RAM
> 59776 pages reserved
> 891838 pages shared
> 1996710 pages non-shared
> 
> 
> All that anon memory seems to be unaccounted for.
> 
> [ pid ]   uid  tgid total_vm      rss cpu oom_adj oom_score_adj name
> [  351]     0   351     4372        2   3     -17         -1000 udevd
> [  818]     0   818    18861       26   0     -17         -1000 sshd
> [ 1199]     0  1199     4372        2   3     -17         -1000 udevd
> [ 1214]     0  1214     4371        2   1     -17         -1000 udevd
> [28963]     0 28963    30988      271   2       0             0 sshd
> [28987]    81 28987     5439      150   3     -13          -900 dbus-daemon
> [28990]     0 28990     7085      136   0       0             0 systemd-logind
> [28995]  1000 28995    31023      373   1       0             0 sshd
> [29008]  1000 29008    29864      875   2       0             0 bash
> [29132]  1000 29132    44732      155   3       0             0 sudo
> [29135]     0 29135    29870     1094   3       0             0 bash
> [29521]     0 29521     4877      196   0       0             0 systemd-kmsg-sy
> [29541]     0 29541    27232      211   3       0             0 agetty
> [29553]     0 29553    29870      875   2       0             0 bash
> 
> 	Dave
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
