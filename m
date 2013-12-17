Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7B70F6B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 16:22:22 -0500 (EST)
Received: by mail-ee0-f54.google.com with SMTP id e51so2666746eek.13
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 13:22:21 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a9si6534786eew.222.2013.12.17.13.22.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 13:22:21 -0800 (PST)
Date: Tue, 17 Dec 2013 21:22:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 5/7] mm: page_alloc: Make zone distribution page aging
 policy configurable
Message-ID: <20131217212216.GK11295@suse.de>
References: <1386943807-29601-1-git-send-email-mgorman@suse.de>
 <1386943807-29601-6-git-send-email-mgorman@suse.de>
 <20131216204215.GA21724@cmpxchg.org>
 <20131217152954.GA24067@suse.de>
 <20131217155435.GE21724@cmpxchg.org>
 <20131217161420.GG11295@suse.de>
 <20131217174302.GF21724@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131217174302.GF21724@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Dec 17, 2013 at 12:43:02PM -0500, Johannes Weiner wrote:
> > > > When looking at this closer I found that sysv is a weird exception. It's
> > > > file-backed as far as most of the VM is concerned but looks anonymous to
> > > > most applications that care. That and MAP_SHARED anonymous pages should
> > > > not be treated like files but we still want tmpfs to be treated as
> > > > files. Details will be in the changelog of the next series.
> > > 
> > > In what sense is it seen as file-backed?
> > 
> > sysv and anonymous pages are backed by an internal shmem mount point. In
> > lots of respects, it's looks like a file and quacks like a file but I expect
> > developers think of it being anonmous and chunks of the VM treats it like
> > it's anonymous. tmpfs uses the same paths and they get treated similar to
> > the VM as anon but users may think that tmpfs should be subject to the
> > fair allocation zone policy "because they're files." It's a sufficently
> > weird case that any action we take there should be deliberate. It'll be
> > a bit clearer when I post the patch that special cases this.
> 
> The line I see here is mostly derived from performance expectations.
> 
> People and programs expect anon, shmem/tmpfs etc. to be fast and avoid
> their reclaim at great costs, so they size this part of their workload
> according to memory size and locality.  Filesystem cache (on-disk) on
> the other hand is expected to be slow on the first fault and after it
> has been displaced by other data, but the kernel is mostly expected to
> maximize the caching effects in a predictable manner.
> 

Part of their performance expectations is that memory referenced from the
local node will be allocated locally. Consider NUMA-aware applications that
partition their data usage appropriately and share that data between threads
using processes and shared memory (some MPI implementations). They have
an expectation that the memory will be local and a further expectation
that it will not be reclaimed because they sized it appropriately.
Automatically interleaving such memory by default will be surprising to
NUMA aware applications even if NUMA-oblivious applications benefit.

Similarly, the pagecache sysctl is documented to affect files, at least
that's how I wrote it. It's inconsistent to explain that as "the sysctl
control files, except for tmpfs ones because ...... whatever".

> The round-robin policy makes the displacement predictable (think of
> the aging artifacts here where random pages do not get displaced
> reliably because they ended up on remote nodes) and it avoids IO by
> maximizing memory utilization.
> 
> I.e. it improves behavior associated with a cache, but I don't expect
> shmem/tmpfs to be typically used as a disk cache.  I could be wrong
> about that, but I figure if you need named shared memory that is
> bigger than your memory capacity (the point where your tmpfs would
> actually turn into a disk cache), you'd be better of using a more
> efficient on-disk filesystem.

I am concerned with semantics like "all files except tmpfs files" or
alternatively regressing performance of NUMA-aware applications and their
use of MAP_SHARED and sysv.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
