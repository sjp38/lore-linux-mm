Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 961BA6B004D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 11:26:54 -0400 (EDT)
Date: Fri, 20 Mar 2009 15:27:00 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: oom-killer killing even if memory is available?
Message-ID: <20090320152700.GM24586@csn.ul.ie>
References: <20090317100049.33f67964@osiris.boeblingen.de.ibm.com> <20090317024605.846420e1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090317024605.846420e1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Andreas Krebbel <krebbel@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Mar 17, 2009 at 02:46:05AM -0700, Andrew Morton wrote:
> On Tue, 17 Mar 2009 10:00:49 +0100 Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
> 
> > Hi all,
> > 
> > the below looks like there is some bug in the memory management code.
> > Even if there seems to be plenty of memory available the oom-killer
> > kills processes.
> > 
> > The below happened after 27 days uptime, memory seems to be heavily
> > fragmented, but there are stills larger portions of memory free that
> > could satisfy an order 2 allocation. Any idea why this fails?
> > 

You are hitting the watermark code for the order-2 allocation in all
liklihood. This looks like a GFP_KERNEL allocation so ordinarily it's a
bit surprising.

> > [root@t6360003 ~]# uptime
> >  09:33:41 up 27 days, 22:55,  1 user,  load average: 0.00, 0.00, 0.00
> > 
> > Mar 16 21:40:40 t6360003 kernel: basename invoked oom-killer: gfp_mask=0xd0, order=2, oomkilladj=0
> > Mar 16 21:40:40 t6360003 kernel: CPU: 0 Not tainted 2.6.28 #1
> > Mar 16 21:40:40 t6360003 kernel: Process basename (pid: 30555, task: 000000007baa6838, ksp: 0000000063867968)
> > Mar 16 21:40:40 t6360003 kernel: 0700000084a8c238 0000000063867a90 0000000000000002 0000000000000000 
> > Mar 16 21:40:40 t6360003 kernel:        0000000063867b30 0000000063867aa8 0000000063867aa8 000000000010534e 
> > Mar 16 21:40:40 t6360003 kernel:        0000000000000000 0000000063867968 0000000000000000 000000000000000a 
> > Mar 16 21:40:40 t6360003 kernel:        000000000000000d 0000000000000000 0000000063867a90 0000000063867b08 
> > Mar 16 21:40:40 t6360003 kernel:        00000000004a5ab0 000000000010534e 0000000063867a90 0000000063867ae0 
> > Mar 16 21:40:40 t6360003 kernel: Call Trace:
> > Mar 16 21:40:40 t6360003 kernel: ([<0000000000105248>] show_trace+0xf4/0x144)
> > Mar 16 21:40:40 t6360003 kernel:  [<0000000000105300>] show_stack+0x68/0xf4
> > Mar 16 21:40:40 t6360003 kernel:  [<000000000049c84c>] dump_stack+0xb0/0xc0
> > Mar 16 21:40:40 t6360003 kernel:  [<000000000019235e>] oom_kill_process+0x9e/0x220
> > Mar 16 21:40:40 t6360003 kernel:  [<0000000000192c30>] out_of_memory+0x17c/0x264
> > Mar 16 21:40:40 t6360003 kernel:  [<000000000019714e>] __alloc_pages_internal+0x4f6/0x534
> > Mar 16 21:40:40 t6360003 kernel:  [<0000000000104058>] crst_table_alloc+0x48/0x108
> > Mar 16 21:40:40 t6360003 kernel:  [<00000000001a3f60>] __pmd_alloc+0x3c/0x1a8
> > Mar 16 21:40:40 t6360003 kernel:  [<00000000001a802e>] handle_mm_fault+0x262/0x9cc
> > Mar 16 21:40:40 t6360003 kernel:  [<00000000004a1a7a>] do_dat_exception+0x30a/0x41c
> > Mar 16 21:40:40 t6360003 kernel:  [<0000000000115e5c>] sysc_return+0x0/0x8
> > Mar 16 21:40:40 t6360003 kernel:  [<0000004d193bfae0>] 0x4d193bfae0
> > Mar 16 21:40:40 t6360003 kernel: Mem-Info:
> > Mar 16 21:40:40 t6360003 kernel: DMA per-cpu:
> > Mar 16 21:40:40 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: Normal per-cpu:
> > Mar 16 21:40:40 t6360003 kernel: CPU    0: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    1: hi:  186, btch:  31 usd:  30
> > Mar 16 21:40:40 t6360003 kernel: CPU    2: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    3: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    4: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: CPU    5: hi:  186, btch:  31 usd:   0
> > Mar 16 21:40:40 t6360003 kernel: Active_anon:372 active_file:45 inactive_anon:154
> > Mar 16 21:40:40 t6360003 kernel:  inactive_file:152 unevictable:987 dirty:0 writeback:188 unstable:0
> > Mar 16 21:40:40 t6360003 kernel:  free:146348 slab:875833 mapped:805 pagetables:378 bounce:0
> > Mar 16 21:40:40 t6360003 kernel: DMA free:467728kB min:4064kB low:5080kB high:6096kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:116kB unevictable:0kB present:2068480kB pages_scanned:0 all_unreclaimable? no
> > Mar 16 21:40:40 t6360003 kernel: lowmem_reserve[]: 0 2020 2020
> > Mar 16 21:40:40 t6360003 kernel: Normal free:117664kB min:4064kB low:5080kB high:6096kB active_anon:1488kB inactive_anon:616kB active_file:188kB inactive_file:492kB unevictable:3948kB present:2068480kB pages_scanned:128 all_unreclaimable? no
> > Mar 16 21:40:40 t6360003 kernel: lowmem_reserve[]: 0 0 0
> 
> The scanner has wrung pretty much all it can out of the reclaimable pages -
> the LRUs are nearly empty.  There's a few hundred MB free and apparently we
> don't have four physically contiguous free pages anywhere.  It's
> believeable.
> 
> The question is: where the heck did all your memory go?  You have 2GB of
> ZONE_NORMAL memory in that machine, but only a tenth of it is visible to
> the page reclaim code.
> 
> Something must have allocated (and possibly leaked) it.
> 

This looks like a memory leak all right. There used to be a patch that
recorded a stack trace for every page allocation but it was dropped from
-mm ages ago because of a merge conflict. I didn't revive it at the time
because it wasn't of immediate concern.

Should I revive the patch or do we have preferred ways of tracking down
memory leaks these days?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
