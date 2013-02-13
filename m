Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id A58A96B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 23:26:04 -0500 (EST)
Date: Wed, 13 Feb 2013 14:55:52 +1030
From: Jonathan Woithe <jwoithe@atrad.com.au>
Subject: Re: OOM triggered with plenty of memory free
Message-ID: <20130213042552.GC32135@marvin.atrad.com.au>
References: <20130213031056.GA32135@marvin.atrad.com.au>
 <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Jonathan Woithe <jwoithe@atrad.com.au>

On Tue, Feb 12, 2013 at 07:30:41PM -0800, David Rientjes wrote:
> The allocation triggering the oom killer is a standard GFP_KERNEL 
> allocation, your lowmem is not depleted.

Ok.

> > Some system specifications:
> >  - CPU: i7 860 at 2.8 GHz
> >  - Mainboard: Advantech AIMB-780
> >  - RAM: 4 GB
> >  - Kernel: 2.6.35.11 SMP, 32 bit (kernel.org kernel, no patches applied)
> 
> I'm afraid you're not going to get much help with a 2 1/2 year old kernel.

Yeah, I was afraid of that.

> > The first OOM report (about 3 days before we were made aware of the problem):
> > 
> >   kernel: ftp invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
> >   kernel: Pid: 22217, comm: ftp Not tainted 2.6.35.11-smp #2
> ...
> >   kernel: DMA free:3480kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:12kB inactive_file:52kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15800kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:148kB slab_unreclaimable:12148kB kernel_stack:16kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:151 all_unreclaimable? yes
> >   kernel: lowmem_reserve[]: 0 865 2991 2991
> >   kernel: Normal free:3856kB min:3728kB low:4660kB high:5592kB active_anon:0kB inactive_anon:0kB active_file:916kB inactive_file:1068kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:885944kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:7572kB slab_unreclaimable:797376kB kernel_stack:3136kB pagetables:36kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:3616 all_unreclaimable? yes
> >   kernel: lowmem_reserve[]: 0 0 17014 17014
> 
> This allocation cannot allocate in highmem, it needs to be allocated from 
> ZONE_NORMAL above.  Notice how your free watermark, 3856KB, is below the 
> min watermark, 3728KB.  This indicates you've simply exhausted the amount 
> of memory on the system.
> 
> Notice also that the amount of RAM this zone has is 865MB and over 90% of 
> it is slab.

Right - so the exhaustion of memory then is a consequence of the
extraordinarily large usage by slab.

> > slabinfo after 106 days uptime and continuous operation:
> > 
> > slabinfo - version: 2.1
> > # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
> ...
> > kmalloc-128       1234556 1235168    128   32    1 : tunables    0    0    0 : slabdata  38599  38599      0
> > kmalloc-64        1238117 1238144     64   64    1 : tunables    0    0    0 : slabdata  19346  19346      0
> > kmalloc-32        1236600 1236608     32  128    1 : tunables    0    0    0 : slabdata   9661   9661      0
> 
> You've most certainly got a memory leak here and it's surprising to see it 
> over three separate slab caches.
> 
> Any investigation that we could do into that leak would at best result in 
> a kernel patch to your 2.6.35 kernel; I'm not sure if there is a fix for a 
> memory leak that matches your symptoms between 2.6.35.11 and 2.6.35.14.

A kernel patch would be acceptable.  An upgrade to 2.6.35.x would also be
relatively easy to push out I suspect.

> Better yet would be to try to upgrade these machines to a more recent 
> kernel to see if it is already fixed.  Are we allowed to upgrade or at 
> least enable kmemleak?

Upgrading to a recent kernel would be a possibility if it was proven to fix
the problem; doing it "just to check" will be impossible I fear, at least on
the production systems.  Enabling KMEMLEAK on 2.6.35.x may be doable.

I will see whether I can gain access to a test system and if so, try a more
recent kernel to see if it makes any difference.

I'll advise which of these options proves practical as soon as possible and
report any findings which come out of them.

Regards
  jonathan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
