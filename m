Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA9F06B000D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 18:15:59 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id t1-v6so2493491plz.17
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 15:15:59 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h63-v6si23756562pfd.228.2018.10.09.15.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 15:15:58 -0700 (PDT)
Date: Tue, 9 Oct 2018 15:15:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: zero-seek shrinkers
Message-Id: <20181009151556.5b0a3c9ae270b7551b3d12e6@linux-foundation.org>
In-Reply-To: <20181009184732.762-5-hannes@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
	<20181009184732.762-5-hannes@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue,  9 Oct 2018 14:47:33 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

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
> 

Seems sane, but I'm somewhat worried about unexpected effects on other
workloads.  So I think I'll hold this over for 4.20.  Or shouldn't I?
