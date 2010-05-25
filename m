Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 713D26008F9
	for <linux-mm@kvack.org>; Tue, 25 May 2010 06:07:58 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o4PA7rGW006899
	for <linux-mm@kvack.org>; Tue, 25 May 2010 03:07:54 -0700
Received: from pwj1 (pwj1.prod.google.com [10.241.219.65])
	by wpaz24.hot.corp.google.com with ESMTP id o4PA7q5x015816
	for <linux-mm@kvack.org>; Tue, 25 May 2010 03:07:52 -0700
Received: by pwj1 with SMTP id 1so429484pwj.39
        for <linux-mm@kvack.org>; Tue, 25 May 2010 03:07:51 -0700 (PDT)
Date: Tue, 25 May 2010 03:07:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC V2 SLEB 00/14] The Enhanced(hopefully) Slab Allocator
In-Reply-To: <20100525081634.GE5087@laptop>
Message-ID: <alpine.DEB.2.00.1005250303040.8045@chino.kir.corp.google.com>
References: <20100521211452.659982351@quilx.com> <20100524070309.GU2516@laptop> <alpine.DEB.2.00.1005240852580.5045@router.home> <20100525020629.GA5087@laptop> <AANLkTik2O-_Fbh-dq0sSLFJyLU7PZi4DHm85lCo4sugS@mail.gmail.com> <20100525070734.GC5087@laptop>
 <AANLkTimhTfz_mMWNh_r18yapNxSDjA7wRDnFM6L5aIdE@mail.gmail.com> <20100525081634.GE5087@laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Tue, 25 May 2010, Nick Piggin wrote:

> I don't think SLUB ever proved itself very well. The selling points
> were some untestable handwaving about how queueing is bad and jitter
> is bad, ignoring the fact that queues could be shortened and periodic
> reaping disabled at runtime with SLAB style of allocator. It also
> has relied heavily on higher order allocations which put great strain
> on hugepage allocations and page reclaim (witness the big slowdown
> in low memory conditions when tmpfs was using higher order allocations
> via SLUB).
> 

I agree that the higher order allocations is a major problem and slub 
relies heavily on them for being able to utilize both the allocation and 
freeing fastpaths for a number of caches.  For systems with a very large 
amount of memory that isn't fully utilized and fragmentation isn't an 
issue, this works fine, but for users who use all their memory and do some 
amount of reclaim it comes at a significant cost.  The cpu slab thrashing 
problem that I identified with the netperf TCP_RR benchmark can be heavily 
reduced by tuning certain kmalloc caches to allocate higher order slabs, 
but that makes it very difficult to run with hugepages and the allocation 
slowpath even slower.  There are commandline workarounds to prevent slub 
from using these higher order allocations, but the performance of the 
allocator then suffers as a result.

> SLUB has not been able to displace SLAB for a long timedue to
> performance and higher order allocation problems.
> 

Completely agreed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
