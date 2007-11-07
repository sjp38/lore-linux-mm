Date: Wed, 7 Nov 2007 10:20:16 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUG] Linux 2.6.24-rc2 - oom-killer gets invoked
Message-Id: <20071107102016.e9d24b0c.akpm@linux-foundation.org>
In-Reply-To: <4731667C.2020302@linux.vnet.ibm.com>
References: <alpine.LFD.0.999.0711061601180.15101@woody.linux-foundation.org>
	<4731667C.2020302@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, apw@shadowen.org, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, 07 Nov 2007 12:47:16 +0530 Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> Hi,
> 
> oom-killer got invoked while running ltp-runall on the 2.6.24-rc2 kernel.
> 
> python invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
> 
> Call Trace:
>  [<ffffffff8026b03b>] oom_kill_process+0x4f/0xf5
>  [<ffffffff8026b517>] out_of_memory+0x1bc/0x22d
>  [<ffffffff8026dfa2>] __alloc_pages+0x282/0x313
>  [<ffffffff804e453c>] __wait_on_bit_lock+0x5b/0x66
>  [<ffffffff8026fad8>] __do_page_cache_readahead+0x7c/0x18f
>  [<ffffffff8026a723>] filemap_fault+0x15d/0x317
>  [<ffffffff8027513e>] __do_fault+0x68/0x3bb
>  [<ffffffff80276d44>] handle_mm_fault+0x325/0x694
>  [<ffffffff804e739f>] do_page_fault+0x3c5/0x764
>  [<ffffffff802118c7>] arch_get_unmapped_area+0x184/0x1f9
>  [<ffffffff804e5939>] error_exit+0x0/0x51
> 
> Mem-info:
> Node 0 DMA per-cpu:
> CPU    0: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
> CPU    1: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
> CPU    2: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
> CPU    3: Hot: hi:    0, btch:   1 usd:   0   Cold: hi:    0, btch:   1 usd:   0
> Node 0 DMA32 per-cpu:
> CPU    0: Hot: hi:  186, btch:  31 usd:  29   Cold: hi:   62, btch:  15 usd:  14
> CPU    1: Hot: hi:  186, btch:  31 usd:  95   Cold: hi:   62, btch:  15 usd:  52
> CPU    2: Hot: hi:  186, btch:  31 usd:  33   Cold: hi:   62, btch:  15 usd:  51
> CPU    3: Hot: hi:  186, btch:  31 usd: 101   Cold: hi:   62, btch:  15 usd:  50
> Active:118809 inactive:124570 dirty:0 writeback:1882 unstable:0
>  free:2358 slab:2831 mapped:41 pagetables:2058 bounce:0
> Node 0 DMA free:3972kB min:28kB low:32kB high:40kB active:996kB inactive:3036kB present:7552kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 992 992 992
> Node 0 DMA32 free:177860kB min:4012kB low:5012kB high:6016kB active:408456kB inactive:388372kB present:1015864kB pages_scanned:640 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 0 DMA: 57*4kB 39*8kB 25*16kB 10*32kB 2*64kB 3*128kB 1*256kB 0*512kB 1*1024kB 1*2048kB 0*4096kB = 5100kB
> Node 0 DMA32: 1597*4kB 1029*8kB 544*16kB 348*32kB 296*64kB 363*128kB 305*256kB 253*512kB 134*1024kB 73*2048kB 0*4096kB = 594204kB
> Swap cache: add 841053, delete 835135, find 529/803, race 0+0
> Free swap  = 1986640kB
> Total swap = 2031640kB
> Free swap:       1986640kB
> 262093 pages of RAM
> 6981 reserved pages
> 190 pages shared
> 5918 pages swap cached
> Out of memory: kill process 23256 (mem01) score 46673 or a child
> Killed process 23256 (mem01)
> 

This is stupid - there's just no way we should have got within five miles
of out_of_memory() when there's 177MB free in ZONE_DMA32.

I can only think that the zonelists got set up wrongly, or the freelist got
damaged or something like that.

> 
> and during the bootup, following call trace was seen 
> 
> sysctl table check failed: /net/token-ring .3.14 procname does not match binary path procname
> 
> Call Trace:
>  [<ffffffff8024dae9>] set_fail+0x3f/0x47
>  [<ffffffff8024dfbc>] sysctl_check_table+0x4cb/0x51e
>  [<ffffffff8024da9b>] sysctl_check_lookup+0xc9/0xd8
>  [<ffffffff8024dfca>] sysctl_check_table+0x4d9/0x51e
>  [<ffffffff8023d283>] sysctl_set_parent+0x1f/0x32
>  [<ffffffff808baf17>] sysctl_init+0x1e/0x22
>  [<ffffffff808aa656>] kernel_init+0x195/0x307
>  [<ffffffff8020cc88>] child_rip+0xa/0x12
>  [<ffffffff808aa4c1>] kernel_init+0x0/0x307
>  [<ffffffff8020cc7e>] child_rip+0x0/0x12
> 

Yeah, I'm sitting on a fix for that - I have a large number of for-2.6.24
fixes which I need to launder through subystem maintainers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
