Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C058D6B0007
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 21:37:40 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id e1-v6so11196702pld.23
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 18:37:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d132-v6sor4061245pga.336.2018.07.09.18.37.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 09 Jul 2018 18:37:39 -0700 (PDT)
Date: Mon, 9 Jul 2018 18:37:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmacache: hash addresses based on pmd
In-Reply-To: <20180709180841.ebfb6cf70bd8dc08b269c0d9@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1807091822460.130281@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1807091749150.114630@chino.kir.corp.google.com> <20180709180841.ebfb6cf70bd8dc08b269c0d9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jul 2018, Andrew Morton wrote:

> > When perf profiling a wide variety of different workloads, it was found
> > that vmacache_find() had higher than expected cost: up to 0.08% of cpu
> > utilization in some cases.  This was found to rival other core VM
> > functions such as alloc_pages_vma() with thp enabled and default
> > mempolicy, and the conditionals in __get_vma_policy().
> > 
> > VMACACHE_HASH() determines which of the four per-task_struct slots a vma
> > is cached for a particular address.  This currently depends on the pfn,
> > so pfn 5212 occupies a different vmacache slot than its neighboring
> > pfn 5213.
> > 
> > vmacache_find() iterates through all four of current's vmacache slots
> > when looking up an address.  Hashing based on pfn, an address has
> > ~1/VMACACHE_SIZE chance of being cached in the first vmacache slot, or
> > about 25%, *if* the vma is cached.
> > 
> > This patch hashes an address by its pmd instead of pte to optimize for
> > workloads with good spatial locality.  This results in a higher
> > probability of vmas being cached in the first slot that is checked:
> > normally ~70% on the same workloads instead of 25%.
> 
> Was the improvement quantifiable?
> 

I've run page fault testing to answer this question on Haswell since the 
initial profiling was done over a wide variety of user-controlled 
workloads and there's no guarantee that such profiling would be a fair 
comparison either way.  For page faulting it's either falling below our 
testing levels of 0.02%, or is right at 0.02%.  Running without the patch 
it's 0.05-0.06% overhead.

> Surprised.  That little array will all be in CPU cache and that loop
> should execute pretty quickly?  If it's *that* sensitive then let's zap
> the no-longer-needed WARN_ON.  And we could hide all the event counting
> behind some developer-only ifdef.
> 

Those vmevents are only defined for CONFIG_DEBUG_VM_VMACACHE, so no change 
needed there.  The WARN_ON() could be moved under the same config option.  
I assume that if such a config option exists that at least somebody is 
interested in debugging mm/vmacache.c once in a while.

> Did you consider LRU-sorting the array instead?
> 

It adds 40 bytes to struct task_struct, but I'm not sure the least 
recently used is the first preferred check.  If I do 
madvise(MADV_DONTNEED) from a malloc implementation where I don't control 
what is free()'d and I'm constantly freeing back to the same hugepages, 
for example, I may always get first slot cache hits with this patch as 
opposed to the 25% chance that the current implementation has (and perhaps 
an lru would as well).

I'm sure that I could construct a workload where LRU would be better and 
could show that the added footprint were worthwhile, but I could also 
construct a workload where the current implementation based on pfn would 
outperform all of these.  It simply turns out that on the user-controlled 
workloads that I was profiling that hashing based on pmd was the win.
