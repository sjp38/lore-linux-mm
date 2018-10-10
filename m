Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5E49A6B000D
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 11:16:00 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id b192-v6so3054466ywe.9
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 08:16:00 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j8-v6sor2698096ywi.132.2018.10.10.08.15.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 08:15:52 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:15:49 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] mm: zero-seek shrinkers
Message-ID: <20181010151549.GC2527@cmpxchg.org>
References: <20181009184732.762-1-hannes@cmpxchg.org>
 <20181009184732.762-5-hannes@cmpxchg.org>
 <e01c4f441e24bb31816a3080389dcae7b49cc1ff.camel@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e01c4f441e24bb31816a3080389dcae7b49cc1ff.camel@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>

On Wed, Oct 10, 2018 at 01:03:50AM +0000, Rik van Riel wrote:
> On Tue, 2018-10-09 at 14:47 -0400, Johannes Weiner wrote:
> 
> > These workloads also deal with tens of thousands of open files and
> > use
> > /proc for introspection, which ends up growing the proc_inode_cache
> > to
> > absurdly large sizes - again at the cost of valuable cache space,
> > which isn't a reasonable trade-off, given that proc inodes can be
> > re-created without involving the disk.
> > 
> > This patch implements a "zero-seek" setting for shrinkers that
> > results
> > in a target ratio of 0:1 between their objects and IO-backed
> > caches. This allows such virtual caches to grow when memory is
> > available (they do cache/avoid CPU work after all), but effectively
> > disables them as soon as IO-backed objects are under pressure.
> > 
> > It then switches the shrinkers for procfs and sysfs metadata, as well
> > as excess page cache shadow nodes, to the new zero-seek setting.
> 
> This patch looks like a great step in the right
> direction, though I do not know whether it is
> aggressive enough.
> 
> Given that internal slab fragmentation will
> prevent the slab cache from returning a slab to
> the VM if just one object in that slab is still
> in use, there may well be workloads where we
> should just put a hard cap on the number of
> freeable items these slabs, and reclaim them
> preemptively.
> 
> However, I do not know for sure, and this patch
> seems like a big improvement over what we had
> before, so ...

Fully agreed, fragmentation is still a concern. I'm still working on
that part, but artificial caps and pro-active reclaim are trickier to
get right than prioritization, and since these patches here are useful
on their own I didn't want to hold them back.

> > Reported-by: Domas Mituzas <dmituzas@fb.com>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Reviewed-by: Rik van Riel <riel@surriel.com>

Thanks!
