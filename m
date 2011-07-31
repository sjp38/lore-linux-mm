Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7A13D900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 16:24:53 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p6VKOmtZ032594
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 13:24:48 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by hpaq2.eem.corp.google.com with ESMTP id p6VKOfrx022830
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 13:24:46 -0700
Received: by pzk37 with SMTP id 37so10467738pzk.29
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 13:24:41 -0700 (PDT)
Date: Sun, 31 Jul 2011 13:24:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 31 Jul 2011, David Rientjes wrote:

> Well, the counters variable is added although it doesn't increase the size 
> of the unaligned struct page because of how it is restructured.  The end 
> result of the alignment for CONFIG_CMPXCHG_LOCAL is that struct page will 
> increase from 56 bytes to 64 bytes on my config.  That's a cost of 128MB 
> on each of my client and server 64GB machines for the netperf benchmark 
> for the ~2.3% speedup.
> 

And although slub is definitely heading in the right direction regarding 
the netperf benchmark, it's still a non-starter for anybody using large 
NUMA machines for networking performance.  On my 16-core, 4 node, 64GB 
client/server machines running netperf TCP_RR with various thread counts 
for 60 seconds each on 3.0:

	threads		SLUB		SLAB		diff
	 16		76345		74973		- 1.8%
	 32		116380		116272		- 0.1%
	 48		150509		153703		+ 2.1%
	 64		187984		189750		+ 0.9%
	 80		216853		224471		+ 3.5%
	 96		236640		249184		+ 5.3%
	112		256540		275464		+ 7.4%
	128		273027		296014		+ 8.4%
	144		281441		314791		+11.8%
	160		287225		326941		+13.8%

I'm much more inclined to use slab because it's performance is so much 
better for heavy networking loads and have an extra 128MB on each of these 
machines.

Now, if I think about this from a Google perspective, we have scheduled 
jobs on shared machines with memory containment allocated in 128MB chunks 
for several years.  So if these numbers are representative of the 
networking performance I can get on our production machines, I'm not only 
far better off selecting slab for its performance, but I can also schedule 
one small job on every machine in our fleet!

Ignoring the netperf results, if you take just the alignment change on 
struct page as a result of cmpxchg16b, I've lost 0.2% of memory from every 
machine in our fleet by selecting slub.  So if we're bound by memory, I've 
just effectively removed 0.2% of machines from our fleet.  That happens to 
be a large number and at a substantial cost every year.

So although I recommended the lockless changes at the memory cost of 
struct page alignment to improve performance by ~2.3%, it's done with the 
premise that I'm not actually going to be using it, so it's more of a 
recommendation for desktops and small systems where others have shown slub 
is better on benchmarks like kernbench, sysbench, aim9, and hackbench.  

 [ I'd love if we had sufficient predicates in the x86 kconfigs to 
   determine what the appropriate allocator to choose would be because 
   it's obvious that slab is light years ahead of the default slub for us. ]

And although I've developed a mutable slab allocator, SLAM, that makes all 
of this irrelevant since it's a drop-in replacement for slab and slub, I 
can't legitimately propose it for inclusion because it lacks the debugging 
capabilities that slub excels in and there's an understanding that Linus 
won't merge another stand-alone allocator until one is removed.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
