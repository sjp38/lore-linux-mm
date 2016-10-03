Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 157356B0069
	for <linux-mm@kvack.org>; Mon,  3 Oct 2016 09:19:34 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l138so92584937wmg.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 06:19:34 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w2si18840876wmw.0.2016.10.03.06.19.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Oct 2016 06:19:32 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id b184so14690801wma.3
        for <linux-mm@kvack.org>; Mon, 03 Oct 2016 06:19:32 -0700 (PDT)
Date: Mon, 3 Oct 2016 15:19:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating
 per-memcg caches
Message-ID: <20161003131930.GE26768@dhcp22.suse.cz>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
 <20161003120641.GC26768@dhcp22.suse.cz>
 <20161003123505.GA1862@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003123505.GA1862@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>

On Mon 03-10-16 15:35:06, Vladimir Davydov wrote:
> On Mon, Oct 03, 2016 at 02:06:42PM +0200, Michal Hocko wrote:
> > On Sat 01-10-16 16:56:47, Vladimir Davydov wrote:
> > > Creating a lot of cgroups at the same time might stall all worker
> > > threads with kmem cache creation works, because kmem cache creation is
> > > done with the slab_mutex held. To prevent that from happening, let's use
> > > a special workqueue for kmem cache creation with max in-flight work
> > > items equal to 1.
> > > 
> > > Link: https://bugzilla.kernel.org/show_bug.cgi?id=172981
> > 
> > This looks like a regression but I am not really sure I understand what
> > has caused it. We had the WQ based cache creation since kmem was
> > introduced more or less. So is it 801faf0db894 ("mm/slab: lockless
> > decision to grow cache") which was pointed by bisection that changed the
> > timing resp. relaxed the cache creation to the point that would allow
> > this runaway?
> 
> It is in case of SLAB. For SLUB the issue was caused by commit
> 81ae6d03952c ("mm/slub.c: replace kick_all_cpus_sync() with
> synchronize_sched() in kmem_cache_shrink()").

OK, thanks for the confirmation. This would be useful in the changelog
imho.

> > This would be really useful for the stable backport
> > consideration.
> > 
> > Also, if I understand the fix correctly, now we do limit the number of
> > workers to 1 thread. Is this really what we want? Wouldn't it be
> > possible that few memcgs could starve others fromm having their cache
> > created? What would be the result, missed charges?
> 
> Now kmem caches are created in FIFO order, i.e. if one memcg called
> kmem_cache_alloc on a non-existent cache before another, it will be
> served first.

I do not see where this FIFO is guaranteed.
__memcg_schedule_kmem_cache_create doesn't seem to be using ordered WQ.

> Since the number of caches that can be created by a single
> memcg is obviously limited,

by the number of existing caches, right?

> I don't see any possibility of starvation.

What I meant was that while now workers can contend on the slab_mutex
with the patch there will be a real ordering in place AFAIU and so an
unlucky memcg can be waiting for N(memcgs) * N (caches) to be served.
Not that the current implementation gives us anything because the
ordering should be more or less scheduling and workers dependent. Or I
am missing something. A per-cache memcg WQ would mitigate to some
extent.

> Actually, this patch doesn't introduce any functional changes regarding
> the order in which kmem caches are created, as the work function holds
> the global slab_mutex during its whole runtime anyway. We only avoid
> creating a thread per each work by making the queue single-threaded.

OK please put this information into the changelog.

That being said I am not opposing the current solution I just wanted to
understand all the consequences and would appreciate more information in
the changelog as this seems like the stable material.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
