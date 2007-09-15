Subject: Re: VM/VFS bug with large amount of memory and file systems?
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>
Content-Type: text/plain
Date: Sat, 15 Sep 2007 12:08:17 +0200
Message-Id: <1189850897.21778.301.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Anton Altaparmakov <aia21@cam.ac.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

On Sat, 2007-09-15 at 08:27 +0100, Anton Altaparmakov wrote:

Please, don't word wrap log-files, they're hard enough to read without
it :-(

( I see people do this more and more often, *WHY*? is that because we
like 80 char lines, in code and email? )


Anyway, looks like all of zone_normal is pinned in kernel allocations:

> Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB high: 5616kB active:0kB inactive:3160kB present:894080kB pages_scanned:5336 all_unreclaimable? yes

Out of the 870 odd mb only 3 is on the lru.

Would be grand it you could have a look at slabinfo and the like.

Peter

---

> Sep 13 15:31:25 escabot init invoked oom-killer: gfp_mask=0xd0,  
> order=0, oomkilladj=0
> Sep 13 15:31:25 escabot [<c0149ea8>] out_of_memory+0x158/0x1b0
> Sep 13 15:31:25 escabot [<c014b7b0>] __alloc_pages+0x2a0/0x300
> Sep 13 15:31:25 escabot [<c01729aa>] core_sys_select+0x1fa/0x2f0
> Sep 13 15:31:25 escabot [<c0162a21>] cache_alloc_refill+0x2e1/0x500
> Sep 13 15:31:25 escabot [<c0162736>] kmem_cache_alloc+0x46/0x50
> Sep 13 15:31:25 escabot [<c016e238>] getname+0x28/0xf0
> Sep 13 15:31:25 escabot [<c016fe5e>] __user_walk_fd+0x1e/0x60
> Sep 13 15:31:25 escabot [<c0168e29>] cp_new_stat64+0xf9/0x110
> Sep 13 15:31:25 escabot [<c0169152>] vfs_stat_fd+0x22/0x60
> Sep 13 15:31:25 escabot [<c016922f>] sys_stat64+0xf/0x30
> Sep 13 15:31:25 escabot [<c0124956>] do_gettimeofday+0x36/0xf0
> Sep 13 15:31:25 escabot [<c0120bbf>] sys_time+0xf/0x30
> Sep 13 15:31:25 escabot [<c0102b10>] sysenter_past_esp+0x5d/0x81
> Sep 13 15:31:25 escabot =======================
> Sep 13 15:31:25 escabot Mem-info:
> Sep 13 15:31:25 escabot DMA per-cpu:
> Sep 13 15:31:25 escabot CPU    0: Hot: hi:    0, btch:   1 usd:   0    
> Cold: hi:    0, btch:   1 usd:   0
> Sep 13 15:31:25 escabot CPU    1: Hot: hi:    0, btch:   1 usd:   0    
> Cold: hi:    0, btch:   1 usd:   0
> Sep 13 15:31:25 escabot CPU    2: Hot: hi:    0, btch:   1 usd:   0    
> Cold: hi:    0, btch:   1 usd:   0
> Sep 13 15:31:25 escabot CPU    3: Hot: hi:    0, btch:   1 usd:   0    
> Cold: hi:    0, btch:   1 usd:   0
> Sep 13 15:31:25 escabot Normal per-cpu:
> Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd: 143    
> Cold: hi:   62, btch:  15 usd:  56
> Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  31    
> Cold: hi:   62, btch:  15 usd:  53
> Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:   8    
> Cold: hi:   62, btch:  15 usd:  54
> Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:  99    
> Cold: hi:   62, btch:  15 usd:  58
> Sep 13 15:31:25 escabot HighMem per-cpu:
> Sep 13 15:31:25 escabot CPU    0: Hot: hi:  186, btch:  31 usd:   1    
> Cold: hi:   62, btch:  15 usd:  10
> Sep 13 15:31:25 escabot CPU    1: Hot: hi:  186, btch:  31 usd:  23    
> Cold: hi:   62, btch:  15 usd:   1
> Sep 13 15:31:25 escabot CPU    2: Hot: hi:  186, btch:  31 usd:  18    
> Cold: hi:   62, btch:  15 usd:   1
> Sep 13 15:31:25 escabot CPU    3: Hot: hi:  186, btch:  31 usd:   9    
> Cold: hi:   62, btch:  15 usd:  12
> Sep 13 15:31:25 escabot Active:8078 inactive:1776744 dirty:10338  
> writeback:0 unstable:0
> Sep 13 15:31:25 escabot free:1090395 slab:198893 mapped:988  
> pagetables:129 bounce:0
> Sep 13 15:31:25 escabot DMA free:3560kB min:68kB low:84kB high:100kB  
> active:0kB inactive:0kB present:16256kB pages_scanned:0  
> all_unreclaimable? yes
> Sep 13 15:31:25 escabot lowmem_reserve[]: 0 873 12176
> Sep 13 15:31:25 escabot Normal free:3648kB min:3744kB low:4680kB high: 
> 5616kB active:0kB inactive:3160kB present:894080kB pages_scanned:5336  
> all_unreclaimable? yes
> Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 90424
> Sep 13 15:31:25 escabot HighMem free:4354372kB min:512kB low:12640kB  
> high:24768kB active:32312kB inactive:7103816kB present:11574272kB  
> pages_scanned:0 all_unreclaimable? no
> Sep 13 15:31:25 escabot lowmem_reserve[]: 0 0 0
> Sep 13 15:31:25 escabot DMA: 4*4kB 3*8kB 0*16kB 0*32kB 1*64kB 1*128kB  
> 1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 3560kB
> Sep 13 15:31:25 escabot Normal: 44*4kB 18*8kB 6*16kB 1*32kB 6*64kB  
> 2*128kB 0*256kB 1*512kB 0*1024kB 1*2048kB 0*4096kB = 3648kB
> Sep 13 15:31:25 escabot HighMem: 1*4kB 0*8kB 0*16kB 37914*32kB  
> 43188*64kB 1628*128kB 5*256kB 247*512kB 30*1024kB 1*2048kB 2*4096kB =  
> 4354372kB
> Sep 13 15:31:25 escabot Swap cache: add 983, delete 972, find 0/1,  
> race 0+0
> Sep 13 15:31:25 escabot Free swap  = 2004216kB
> Sep 13 15:31:25 escabot Total swap = 2008116kB
> Sep 13 15:31:25 escabot Free swap:       2004216kB


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
