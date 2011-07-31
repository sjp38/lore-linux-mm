Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8A3FD900137
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 17:55:30 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p6VLtPkB021602
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 14:55:28 -0700
Received: from iym1 (iym1.prod.google.com [10.241.52.1])
	by kpbe11.cbf.corp.google.com with ESMTP id p6VLtMLo001781
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 31 Jul 2011 14:55:24 -0700
Received: by iym1 with SMTP id 1so6503014iym.15
        for <linux-mm@kvack.org>; Sun, 31 Jul 2011 14:55:22 -0700 (PDT)
Date: Sun, 31 Jul 2011 14:55:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [GIT PULL] Lockless SLUB slowpaths for v3.1-rc1
In-Reply-To: <1312145146.24862.97.camel@jaguar>
Message-ID: <alpine.DEB.2.00.1107311426001.944@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107290145080.3279@tiger> <alpine.DEB.2.00.1107291002570.16178@router.home> <alpine.DEB.2.00.1107311136150.12538@chino.kir.corp.google.com> <alpine.DEB.2.00.1107311253560.12538@chino.kir.corp.google.com>
 <1312145146.24862.97.camel@jaguar>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, hughd@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 31 Jul 2011, Pekka Enberg wrote:

> > And although slub is definitely heading in the right direction regarding 
> > the netperf benchmark, it's still a non-starter for anybody using large 
> > NUMA machines for networking performance.  On my 16-core, 4 node, 64GB 
> > client/server machines running netperf TCP_RR with various thread counts 
> > for 60 seconds each on 3.0:
> > 
> > 	threads		SLUB		SLAB		diff
> > 	 16		76345		74973		- 1.8%
> > 	 32		116380		116272		- 0.1%
> > 	 48		150509		153703		+ 2.1%
> > 	 64		187984		189750		+ 0.9%
> > 	 80		216853		224471		+ 3.5%
> > 	 96		236640		249184		+ 5.3%
> > 	112		256540		275464		+ 7.4%
> > 	128		273027		296014		+ 8.4%
> > 	144		281441		314791		+11.8%
> > 	160		287225		326941		+13.8%
> 
> That looks like a pretty nasty scaling issue. David, would it be
> possible to see 'perf report' for the 160 case? [ Maybe even 'perf
> annotate' for the interesting SLUB functions. ]
> 

More interesting than the perf report (which just shows kfree, 
kmem_cache_free, kmem_cache_alloc dominating) is the statistics that are 
exported by slub itself, it shows the "slab thrashing" issue that I 
described several times over the past few years.  It's difficult to 
address because it's a result of slub's design.  From the client side of 
160 netperf TCP_RR threads for 60 seconds:

	cache		alloc_fastpath		alloc_slowpath
	kmalloc-256	10937512 (62.8%)	6490753
	kmalloc-1024	17121172 (98.3%)	303547
	kmalloc-4096	5526281			11910454 (68.3%)

	cache		free_fastpath		free_slowpath
	kmalloc-256	15469			17412798 (99.9%)
	kmalloc-1024	11604742 (66.6%)	5819973
	kmalloc-4096	14848			17421902 (99.9%)

With those stats, there's no way that slub will even be able to compete 
with slab because it's not optimized for the slowpath.  There are ways to 
mitigate that, like with my slab thrashing patchset from a couple years 
ago that you tracked for a while that improved performance 3-4% at the 
overhead of an increment in the fastpath, but everything else requires 
more memory.  You could preallocate the slabs on the partial list, 
increase the per-node min_partial, increase the order of the slabs 
themselves so you hit the free fastpath much more often, etc, but they all 
come at a considerable cost in memory.

I'm very confident that slub could beat slab on any system if you throw 
enough memory at it because its fastpaths are extremely efficient, but 
there's no business case for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
