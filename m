Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2DA106B00E7
	for <linux-mm@kvack.org>; Tue, 11 Jan 2011 05:11:20 -0500 (EST)
Date: Tue, 11 Jan 2011 05:11:17 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1871880786.44703.1294740677491.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <917078699.44615.1294739707429.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: known oom issues on numa in -mm tree?
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> ----- Original Message -----
> > BTW, the latest linux-next also had the similar issue.
> >
> > - kswapd was running for a long time.
> >
> > runnable tasks:
> > task PID tree-key switches prio exec-runtime sum-exec sum-sleep
> > ----------------------------------------------------------------------------------------------------------
> > R kswapd1 82 564957.671501 32922 120 564986.657154 1188257.259742
> > 3555627.915255
> >
> > - it was looping for drain_local_pages.
> >
> > oom02 R running task 0 2023 1969 0x00000088
> > 0000000000000282 ffff88041d219df0 ffff88041fbf8ef0 ffffffff81100800
> > ffff880418ab5b18 0000000000000282 ffffffff8100c9ee ffff880418ab5ba8
> > 0000000087654321 0000000000000000 ffff880000000000 0000000000000001
> > Call Trace:
> > [<ffffffff81100800>] ? drain_local_pages+0x0/0x20
> > [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
> > [<ffffffff81097ea6>] ? smp_call_function_many+0x1b6/0x210
> > [<ffffffff81097e82>] ? smp_call_function_many+0x192/0x210
> > [<ffffffff81100800>] ? drain_local_pages+0x0/0x20
> > [<ffffffff81097f22>] ? smp_call_function+0x22/0x30
> > [<ffffffff81068184>] ? on_each_cpu+0x24/0x50
> > [<ffffffff810fe68c>] ? drain_all_pages+0x1c/0x20
> > [<ffffffff81100d04>] ? __alloc_pages_nodemask+0x4e4/0x840
> > [<ffffffff81138e09>] ? alloc_page_vma+0x89/0x140
> > [<ffffffff8111c481>] ? handle_mm_fault+0x871/0xd80
> > [<ffffffff814a4ecd>] ? schedule+0x3fd/0x980
> > [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
> > [<ffffffff8100c9ee>] ? apic_timer_interrupt+0xe/0x20
> > [<ffffffff814aadd3>] ? do_page_fault+0x143/0x4b0
> > [<ffffffff8100a7b4>] ? __switch_to+0x194/0x320
> > [<ffffffff814a4ecd>] ? schedule+0x3fd/0x980
> > [<ffffffff814a7ad5>] ? page_fault+0x25/0x30
> >
> > - although the local pages were low.
> >
> > Node 1 Normal free:8052kB min:8136kB low:10168kB high:12204kB
> > active_anon:8026400kB inactive_anon:0kB active_file:0kB
> > inactive_file:20kB unevictable:0kB isolated(anon):0kB
> > isolated(file):0kB present:8273920kB mlocked:0kB dirty:0kB
> > writeback:0kB mapped:0kB shmem:116kB slab_reclaimable:23728kB
> > slab_unreclaimable:175932kB kernel_stack:176kB pagetables:17136kB
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:10
> > all_unreclaimable? no
> > lowmem_reserve[]: 0 0 0 0
> > Node 0 DMA: 0*4kB 0*8kB 1*16kB 0*32kB 2*64kB 1*128kB 1*256kB 0*512kB
> > 1*1024kB 1*2048kB 3*4096kB = 15888kB
> > Node 0 DMA32: 10*4kB 10*8kB 7*16kB 8*32kB 4*64kB 8*128kB 10*256kB
> > 2*512kB 4*1024kB 2*2048kB 534*4096kB = 2200808kB
> > Node 0 Normal: 519*4kB 824*8kB 440*16kB 202*32kB 87*64kB 29*128kB
> > 15*256kB 11*512kB 3*1024kB 8*2048kB 1065*4096kB = 4422620kB
> > Node 1 Normal: 579*4kB 205*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB
> > 0*512kB 0*1024kB 0*2048kB 1*4096kB = 8052kB
> >
> > It could also be reproduced by using mempolicy alone. The test just
> > hung at memset() while allocating memory.
> >
> > set_mempolicy(MPOL_BIND, &nmask, MAXNODES);
> > while(1) {
> > s = mmap(NULL, length, PROT_READ|PROT_WRITE,
> > MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
> > memset(s, '\a', length);
> > }
> Is it possible that,
> 
> drain_all_pages()
> on_each_cpu()
> drain_local_pages()
> 
> Thought that there were still free pages in other node, so it was
> still trying to call direct reclaim path?
It was looping here...

...
zone_watermark_ok()
zone_watermark_ok()
inactive_anon_is_low()
zone_watermark_ok()
mem_cgroup_soft_limit_reclaim()
zone_watermark_ok()
shrink_zone()
shrink_slab()

zone_watermark_ok()
zone_watermark_ok()
inactive_anon_is_low()
zone_watermark_ok()
mem_cgroup_soft_limit_reclaim()
zone_watermark_ok()
shrink_zone()
shrink_slab()
...

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
