Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id A322E6B0005
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 22:30:44 -0500 (EST)
Received: by mail-da0-f47.google.com with SMTP id s35so348789dak.34
        for <linux-mm@kvack.org>; Tue, 12 Feb 2013 19:30:43 -0800 (PST)
Date: Tue, 12 Feb 2013 19:30:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: OOM triggered with plenty of memory free
In-Reply-To: <20130213031056.GA32135@marvin.atrad.com.au>
Message-ID: <alpine.DEB.2.02.1302121917020.11158@chino.kir.corp.google.com>
References: <20130213031056.GA32135@marvin.atrad.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Woithe <jwoithe@atrad.com.au>
Cc: linux-mm@kvack.org

On Wed, 13 Feb 2013, Jonathan Woithe wrote:

> We have a number of Linux systems in the field controlling some
> instrumentation.  They are backed by UPS and local generators so uptimes are
> often several hundred days.  Recently we have noticed that after a few
> hundred days of uptime one of these systems started to trigger the OOM
> killer repeatedly even though "free" reports plenty of memory free.  After
> speaking with a few people at linux.conf.au it was thought that an
> exhaustion of lowmem may be implicated and the suggestion was to ask here to
> see if anyone had ideas as to what the underlying cause might be.
> 

The allocation triggering the oom killer is a standard GFP_KERNEL 
allocation, your lowmem is not depleted.

> The output of "ps auxw" is practically unchanged from the time the machine
> boots.
> 
> Some system specifications:
>  - CPU: i7 860 at 2.8 GHz
>  - Mainboard: Advantech AIMB-780
>  - RAM: 4 GB
>  - Kernel: 2.6.35.11 SMP, 32 bit (kernel.org kernel, no patches applied)

I'm afraid you're not going to get much help with a 2 1/2 year old kernel.

> The machine is set up to boot during which time the data acquisition program
> is started.  The system then runs indefinitely.  Beyond the data acquisition
> program the machine does very little.  The memory usage of all processes on
> the system (including the data acquisition program) as reported by "ps"
> remains unchanged for the lifetime of the processes.
> 

This isn't surprising, the vast majority of RAM is consumed by slab.

> I have however been able to obtain the slabinfo from another machine
> operating in a similar way to the one which faulted.  Its uptime is just
> over 100 days and has not yet started misbehaving.  I have noted that the
> active_objs and num_objs fields for the kmalloc-32, kmalloc-64 and
> kmalloc-128 lines in particular are very large and seem to be increasing
> without limit over both short and long timescales (eg: over an hour, the
> kmalloc-128 active_objs increased from 2093227 to 2094021).  If the
> acquisition is stopped (ie: software idling, hardware not sending data to
> ethernet port) these statistics do not appear to increase over a 30 minute
> period.  I do not know whether this is significant.
> 

You're exactly right, and this is what is causing your oom condition.

> The first OOM report (about 3 days before we were made aware of the problem):
> 
>   kernel: ftp invoked oom-killer: gfp_mask=0xd0, order=0, oom_adj=0
>   kernel: Pid: 22217, comm: ftp Not tainted 2.6.35.11-smp #2
...
>   kernel: DMA free:3480kB min:64kB low:80kB high:96kB active_anon:0kB inactive_anon:0kB active_file:12kB inactive_file:52kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15800kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:148kB slab_unreclaimable:12148kB kernel_stack:16kB pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:151 all_unreclaimable? yes
>   kernel: lowmem_reserve[]: 0 865 2991 2991
>   kernel: Normal free:3856kB min:3728kB low:4660kB high:5592kB active_anon:0kB inactive_anon:0kB active_file:916kB inactive_file:1068kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:885944kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:7572kB slab_unreclaimable:797376kB kernel_stack:3136kB pagetables:36kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:3616 all_unreclaimable? yes
>   kernel: lowmem_reserve[]: 0 0 17014 17014

This allocation cannot allocate in highmem, it needs to be allocated from 
ZONE_NORMAL above.  Notice how your free watermark, 3856KB, is below the 
min watermark, 3728KB.  This indicates you've simply exhausted the amount 
of memory on the system.

Notice also that the amount of RAM this zone has is 865MB and over 90% of 
it is slab.

> slabinfo after 106 days uptime and continuous operation:
> 
> slabinfo - version: 2.1
> # name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables <limit> <batchcount> <sharedfactor> : slabdata <active_slabs> <num_slabs> <sharedavail>
...
> kmalloc-128       1234556 1235168    128   32    1 : tunables    0    0    0 : slabdata  38599  38599      0
> kmalloc-64        1238117 1238144     64   64    1 : tunables    0    0    0 : slabdata  19346  19346      0
> kmalloc-32        1236600 1236608     32  128    1 : tunables    0    0    0 : slabdata   9661   9661      0

You've most certainly got a memory leak here and it's surprising to see it 
over three separate slab caches.

Any investigation that we could do into that leak would at best result in 
a kernel patch to your 2.6.35 kernel; I'm not sure if there is a fix for a 
memory leak that matches your symptoms between 2.6.35.11 and 2.6.35.14.

Better yet would be to try to upgrade these machines to a more recent 
kernel to see if it is already fixed.  Are we allowed to upgrade or at 
least enable kmemleak?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
