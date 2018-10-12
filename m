Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB496B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 09:48:57 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e49-v6so3272963edd.20
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 06:48:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k25-v6si749623ejx.72.2018.10.12.06.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 06:48:55 -0700 (PDT)
Subject: Re: [PATCH 4/4] mm: zero-seek shrinkers
References: <20181009184732.762-1-hannes@cmpxchg.org>
 <20181009184732.762-5-hannes@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <ce593e78-e245-6c89-eb91-2ba61b1be855@suse.cz>
Date: Fri, 12 Oct 2018 15:48:52 +0200
MIME-Version: 1.0
In-Reply-To: <20181009184732.762-5-hannes@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 10/9/18 8:47 PM, Johannes Weiner wrote:
> The page cache and most shrinkable slab caches hold data that has been
> read from disk, but there are some caches that only cache CPU work,
> such as the dentry and inode caches of procfs and sysfs, as well as
> the subset of radix tree nodes that track non-resident page cache.
> 
> Currently, all these are shrunk at the same rate: using DEFAULT_SEEKS
> for the shrinker's seeks setting tells the reclaim algorithm that for
> every two page cache pages scanned it should scan one slab object.
> 
> This is a bogus setting. A virtual inode that required no IO to create
> is not twice as valuable as a page cache page; shadow cache entries
> with eviction distances beyond the size of memory aren't either.
> 
> In most cases, the behavior in practice is still fine. Such virtual
> caches don't tend to grow and assert themselves aggressively, and
> usually get picked up before they cause problems. But there are
> scenarios where that's not true.
> 
> Our database workloads suffer from two of those. For one, their file
> workingset is several times bigger than available memory, which has
> the kernel aggressively create shadow page cache entries for the
> non-resident parts of it. The workingset code does tell the VM that
> most of these are expendable, but the VM ends up balancing them 2:1 to
> cache pages as per the seeks setting. This is a huge waste of memory.
> 
> These workloads also deal with tens of thousands of open files and use
> /proc for introspection, which ends up growing the proc_inode_cache to
> absurdly large sizes - again at the cost of valuable cache space,
> which isn't a reasonable trade-off, given that proc inodes can be
> re-created without involving the disk.
> 
> This patch implements a "zero-seek" setting for shrinkers that results
> in a target ratio of 0:1 between their objects and IO-backed
> caches. This allows such virtual caches to grow when memory is
> available (they do cache/avoid CPU work after all), but effectively
> disables them as soon as IO-backed objects are under pressure.
> 
> It then switches the shrinkers for procfs and sysfs metadata, as well
> as excess page cache shadow nodes, to the new zero-seek setting.

AFAIU procfs and sysfs metadata have exclusive slab caches, while the
shadow nodes share 'radix_tree_node' cache with non-shadow ones, right?
To avoid fragmentation, it should be better if they had also separate
cache, since their lifetime becomes different. In case that's feasible
(are non-shadow nodes changing to shadow nodes and vice versa? I guess
they do? That would require reallocation in the other cache.).

Vlastimil
