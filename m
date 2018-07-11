Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id D90C16B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 19:43:57 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n17-v6so17242139pff.10
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 16:43:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n59-v6sor6795095plb.0.2018.07.11.16.43.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 11 Jul 2018 16:43:56 -0700 (PDT)
Date: Wed, 11 Jul 2018 16:43:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, vmacache: hash addresses based on pmd
In-Reply-To: <20180711161030.b5ae2f5b1210150c13b1a832@linux-foundation.org>
Message-ID: <alpine.DEB.2.21.1807111637050.254865@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1807091749150.114630@chino.kir.corp.google.com> <20180709180841.ebfb6cf70bd8dc08b269c0d9@linux-foundation.org> <alpine.DEB.2.21.1807091822460.130281@chino.kir.corp.google.com>
 <20180711161030.b5ae2f5b1210150c13b1a832@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Davidlohr Bueso <dave@stgolabs.net>, Alexey Dobriyan <adobriyan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 11 Jul 2018, Andrew Morton wrote:

> > > Did you consider LRU-sorting the array instead?
> > > 
> > 
> > It adds 40 bytes to struct task_struct,
> 
> What does?  LRU sort?  It's a 4-entry array, just do it in place, like
> bh_lru_install(). Confused.
> 

I was imagining an optimized sort rather than adding an iteration to 
vmacache_update() of the same form that causes vmacache_find() to show up 
on my perf reports in the first place.

> > but I'm not sure the least 
> > recently used is the first preferred check.  If I do 
> > madvise(MADV_DONTNEED) from a malloc implementation where I don't control 
> > what is free()'d and I'm constantly freeing back to the same hugepages, 
> > for example, I may always get first slot cache hits with this patch as 
> > opposed to the 25% chance that the current implementation has (and perhaps 
> > an lru would as well).
> > 
> > I'm sure that I could construct a workload where LRU would be better and 
> > could show that the added footprint were worthwhile, but I could also 
> > construct a workload where the current implementation based on pfn would 
> > outperform all of these.  It simply turns out that on the user-controlled 
> > workloads that I was profiling that hashing based on pmd was the win.
> 
> That leaves us nowhere to go.  Zapping the WARN_ON seems a no-brainer
> though?
> 

I would suggest it goes under CONFIG_DEBUG_VM_VMACACHE.

My implementation for the optimized vmacache_find() is based on the 
premise that spatial locality matters, and in practice on random 
user-controlled workloads this yields a faster lookup than the current 
implementation.  Of course, any caching technique can be defeated by 
workloads, artifical or otherwise, but I suggest that as a general 
principle caching based on PMD_SHIFT rather than pfn has a greater 
likelihood of avoiding the iteration in vmacache_find() because of spatial 
locality for anything that iterates over a range of memory.
