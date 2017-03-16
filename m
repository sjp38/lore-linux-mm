Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38C2E6B0388
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 10:48:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w37so8922199wrc.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 07:48:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s5si2438940wmd.18.2017.03.16.07.48.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Mar 2017 07:48:34 -0700 (PDT)
Date: Thu, 16 Mar 2017 15:48:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: MAP_POPULATE vs. MADV_HUGEPAGES
Message-ID: <20170316144832.GJ30501@dhcp22.suse.cz>
References: <e134e521-54eb-9ae0-f379-26f38703478e@scylladb.com>
 <20170316123449.GE30508@dhcp22.suse.cz>
 <4e1011d9-aef3-5cd7-1424-b81aa79128cb@scylladb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4e1011d9-aef3-5cd7-1424-b81aa79128cb@scylladb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@scylladb.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 16-03-17 15:26:54, Avi Kivity wrote:
> 
> 
> On 03/16/2017 02:34 PM, Michal Hocko wrote:
> >On Wed 15-03-17 18:50:32, Avi Kivity wrote:
> >>A user is trying to allocate 1TB of anonymous memory in parallel on 48 cores
> >>(4 NUMA nodes).  The kernel ends up spinning in isolate_freepages_block().
> >Which kernel version is that?
> 
> A good question; it was 3.10.something-el.something.  The user mentioned
> above updated to 4.4, and the problem was gone, so it looks like it is a Red
> Hat specific problem.  I would really like the 3.10.something kernel to
> handle this workload well, but I understand that's not this list's concern.
> 
> >What is the THP defrag mode
> >(/sys/kernel/mm/transparent_hugepage/defrag)?
> 
> The default (always).

the default has changed since then because the THP faul latencies were
just too large. Currently we only allow madvised VMAs to go stall and
even then we try hard to back off sooner rather than later. See
444eb2a449ef ("mm: thp: set THP defrag by default to madvise and add a
stall-free defrag option") merged in 4.4
 
> >>I thought to help it along by using MAP_POPULATE, but then my MADV_HUGEPAGE
> >>won't be seen until after mmap() completes, with pages already populated.
> >>Are MAP_POPULATE and MADV_HUGEPAGE mutually exclusive?
> >Why do you need MADV_HUGEPAGE?
> 
> So that I get huge pages even if transparent_hugepage/enabled=madvise.  I'm
> allocating almost all of the memory of that machine to be used as a giant
> cache, so I want it backed by hugepages.

Is there any strong reason to not use hugetlb then? You probably want
that memory reclaimable, right?

> >>Is my only option to serialize those memory allocations, and fault in those
> >>pages manually?  Or perhaps use mlock()?
> >I am still not 100% sure I see what you are trying to achieve, though.
> >So you do not want all those processes to contend inside the compaction
> >while still allocate as many huge pages as possible?
> 
> Since the process starts with all of that memory free, there should not be
> any compaction going on (or perhaps very minimal eviction/movement of a few
> pages here and there).  And since it's fixed in later kernels, it looks like
> the contention was not really mandated by the workload, just an artifact of
> the implementation.

It is possible. A lot has changed since 3.10 times.

> To explain the workload again, the process starts, clones as many threads as
> there are logical processors, and each of those threads mmap()s (and
> mbind()s) a chunk of memory and then proceeds to touch it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
