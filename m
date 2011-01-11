Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB9C6B00E7
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 22:18:52 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p0B3IedT031693
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 19:18:41 -0800
Received: from pvd12 (pvd12.prod.google.com [10.241.209.204])
	by wpaz17.hot.corp.google.com with ESMTP id p0B3IcFP005887
	for <linux-mm@kvack.org>; Mon, 10 Jan 2011 19:18:39 -0800
Received: by pvd12 with SMTP id 12so3673988pvd.34
        for <linux-mm@kvack.org>; Mon, 10 Jan 2011 19:18:38 -0800 (PST)
Date: Mon, 10 Jan 2011 19:18:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: known oom issues on numa in -mm tree?
In-Reply-To: <1378144890.40011.1294709803962.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Message-ID: <alpine.DEB.2.00.1101101914560.13327@chino.kir.corp.google.com>
References: <1378144890.40011.1294709803962.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 10 Jan 2011, CAI Qian wrote:

> Node 0 DMA free:15888kB min:12kB low:12kB high:16kB active_anon:0kB 
> inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB 
> isolated(anon):0kB isolated(file):0kB present:15664kB mlocked:0kB 
> dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB 
> slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB unstable:0kB 
> bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 3255 8053 8053
> Node 0 DMA32 free:2201196kB min:3276kB low:4092kB high:4912kB 
> active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB 
> unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3333976kB 
> mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB 
> slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB 
> pagetables:0kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? no
> lowmem_reserve[]: 0 0 4797 4797
> Node 0 Normal free:4605172kB min:4828kB low:6032kB high:7240kB 
> active_anon:10688kB inactive_anon:6100kB active_file:3964kB 
> inactive_file:13696kB unevictable:0kB isolated(anon):0kB 
> isolated(file):0kB present:4912640kB mlocked:0kB dirty:12kB 
> writeback:0kB mapped:3416kB shmem:204kB slab_reclaimable:22992kB 
> slab_unreclaimable:169848kB kernel_stack:960kB pagetables:1784kB 
> unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 
> all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> Node 1 Normal free:7960kB min:8136kB low:10168kB high:12204kB 
> active_anon:7968052kB inactive_anon:32kB active_file:52kB 
> inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB 
> present:8273920kB mlocked:0kB dirty:0kB writeback:0kB mapped:8kB 
> shmem:0kB slab_reclaimable:36240kB slab_unreclaimable:219672kB 
> kernel_stack:224kB pagetables:17200kB unstable:0kB bounce:0kB 
> writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0

[snip]

> > > oom02 R running task 0 2057 2053 0x00000088
> > >  0000000000000282 ffffffffffffff10 ffffffff81098272 0000000000000010
> > >  0000000000000202 ffff8802159d7a18 0000000000000018 ffffffff81098252
> > >  01ff8802159d7a28 0000000000000000 0000000000000000 ffffffff810ffd60
> > > Call Trace:
> > >  [<ffffffff81098272>] ? smp_call_function_many+0x1b2/0x210
> > >  [<ffffffff81098252>] ? smp_call_function_many+0x192/0x210
> > >  [<ffffffff810ffd60>] ? drain_local_pages+0x0/0x20
> > >  [<ffffffff810982f2>] ? smp_call_function+0x22/0x30
> > >  [<ffffffff81067df4>] ? on_each_cpu+0x24/0x50
> > >  [<ffffffff810fdbec>] ? drain_all_pages+0x1c/0x20
> > 
> > This suggests we're in the direct reclaim path and not currently
> > considered to be in the hopeless situation of oom.
> The question here is why it was taking so long (can't oom after tens' of
> minutes) even swap devices disabled. As you can also see from the above
> sysrq-m output, the test did exhaust the Node 1 Normal zone.
> 

I'm assuming you've setup a cpuset with cpuset.mems == 1 if you're citing 
the fact that node 1 is exhausted (please confirm this since your initial 
post said this was an issue with both cpusets and memcg, but failed to 
give details on the actual configuration).  ZONE_NORMAL for that node has 
its all_unreclaimable flag still off, so it indicates it's still possible 
to free memory before killing a task.  You may also want to ensure that no 
other tasks are dying in the background because the oom killer will 
silently give them access to memory reserves so they can quietly and 
quickly exit rather than killing something else in its place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
