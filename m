Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 294DE6B0031
	for <linux-mm@kvack.org>; Sun, 16 Feb 2014 18:42:50 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so14505054pab.17
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 15:42:49 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id ui8si12774284pac.264.2014.02.16.15.42.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 16 Feb 2014 15:42:48 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so14404788pab.5
        for <linux-mm@kvack.org>; Sun, 16 Feb 2014 15:42:47 -0800 (PST)
Date: Sun, 16 Feb 2014 15:42:46 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Recent 3.x kernels: Memory leak causing OOMs
In-Reply-To: <20140216225000.GO30257@n2100.arm.linux.org.uk>
Message-ID: <alpine.DEB.2.02.1402161531380.10992@chino.kir.corp.google.com>
References: <20140216200503.GN30257@n2100.arm.linux.org.uk> <alpine.DEB.2.02.1402161406120.26926@chino.kir.corp.google.com> <20140216225000.GO30257@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Sun, 16 Feb 2014, Russell King - ARM Linux wrote:

> However, that doesn't negate the point which I brought up in my other
> mail - I have been chasing a memory leak elsewhere, and I so far have
> two dumps off a different machine - both of these logs are from the
> same machine, which took 41 days to OOM.
> 
> http://www.home.arm.linux.org.uk/~rmk/misc/log-20131228.txt
> http://www.home.arm.linux.org.uk/~rmk/misc/log-20140208.txt
> 

You actually have free memory in both of these, the problem is 
fragmentation: the first log shows oom kills where order=2 and the second 
long shows oom kills where order=3.

If I look at an example from the second log:

Normal free:35052kB min:1416kB low:1768kB high:2124kB active_anon:28kB 
inactive_anon:60kB active_file:140kB inactive_file:140kB unevictable:0kB 
isolated(anon):0kB isolated(file):0kB present:131072kB managed:125848kB 
mlocked:0kB dirty:0kB writeback:40kB mapped:0kB shmem:0kB 
slab_reclaimable:3024kB slab_unreclaimable:9036kB kernel_stack:1248kB 
pagetables:1696kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB 
pages_scanned:574 all_unreclaimable? yes

you definitely are missing memory somewhere, but I'm not sure it's going 
to be detected by kmemleak since the slab stats aren't very high.  The 
system has ~123MB of memory, ~34.5MB is user or free memory, ~12MB is 
slab, and ~3MB for stack and pagetables means you're missing over half of 
your memory somewhere.  There's types of memory that isn't shown here for 
things like vmalloc(), things that call alloc_pages() directly, hugepages, 
etc.

You also have a lot of swap available:

Free swap  = 1011476kB
Total swap = 1049256kB

These ooms are coming from the high-order sk_page_frag_refill() which has 
been changed recently to fallback without calling the oom killer, you'll 
need commit ed98df3361f0 ("net: use __GFP_NORETRY for high order 
allocations") that Linus merged about 1.5 weeks ago.

So I'd recommend forgetting about kmemleak here, try a kernel with that 
commit to avoid the oom killing, and then capture /proc/meminfo at regular 
intervals to see if something continuously grows that isn't captured in 
the oom log.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
