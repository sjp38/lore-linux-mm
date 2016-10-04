Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA0786B0069
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 09:14:21 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id x79so10408426lff.2
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 06:14:21 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id d193si1984645lfg.277.2016.10.04.06.14.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 06:14:20 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id b75so2768706lfg.3
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 06:14:19 -0700 (PDT)
Date: Tue, 4 Oct 2016 16:14:17 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating
 per-memcg caches
Message-ID: <20161004131417.GC1862@esperanza>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
 <20161003120641.GC26768@dhcp22.suse.cz>
 <20161003123505.GA1862@esperanza>
 <20161003131930.GE26768@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161003131930.GE26768@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Oct 03, 2016 at 03:19:31PM +0200, Michal Hocko wrote:
> On Mon 03-10-16 15:35:06, Vladimir Davydov wrote:
> > On Mon, Oct 03, 2016 at 02:06:42PM +0200, Michal Hocko wrote:
> > > On Sat 01-10-16 16:56:47, Vladimir Davydov wrote:
> > > > Creating a lot of cgroups at the same time might stall all worker
> > > > threads with kmem cache creation works, because kmem cache creation is
> > > > done with the slab_mutex held. To prevent that from happening, let's use
> > > > a special workqueue for kmem cache creation with max in-flight work
> > > > items equal to 1.
> > > > 
> > > > Link: https://bugzilla.kernel.org/show_bug.cgi?id=172981
> > > 
> > > This looks like a regression but I am not really sure I understand what
> > > has caused it. We had the WQ based cache creation since kmem was
> > > introduced more or less. So is it 801faf0db894 ("mm/slab: lockless
> > > decision to grow cache") which was pointed by bisection that changed the
> > > timing resp. relaxed the cache creation to the point that would allow
> > > this runaway?
> > 
> > It is in case of SLAB. For SLUB the issue was caused by commit
> > 81ae6d03952c ("mm/slub.c: replace kick_all_cpus_sync() with
> > synchronize_sched() in kmem_cache_shrink()").
> 
> OK, thanks for the confirmation. This would be useful in the changelog
> imho.
> 
> > > This would be really useful for the stable backport
> > > consideration.
> > > 
> > > Also, if I understand the fix correctly, now we do limit the number of
> > > workers to 1 thread. Is this really what we want? Wouldn't it be
> > > possible that few memcgs could starve others fromm having their cache
> > > created? What would be the result, missed charges?
> > 
> > Now kmem caches are created in FIFO order, i.e. if one memcg called
> > kmem_cache_alloc on a non-existent cache before another, it will be
> > served first.
> 
> I do not see where this FIFO is guaranteed.
> __memcg_schedule_kmem_cache_create doesn't seem to be using ordered WQ.

Yeah, you're right - I thought max_active implies ordering, but it
doesn't. Then we can use an ordered workqueue. Here's the updated
patch:
