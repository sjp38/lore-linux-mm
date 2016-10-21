Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18F356B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:39:31 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id m193so20510108lfm.7
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:39:31 -0700 (PDT)
Received: from mail-lf0-f65.google.com (mail-lf0-f65.google.com. [209.85.215.65])
        by mx.google.com with ESMTPS id v64si533396lfi.365.2016.10.20.23.39.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Oct 2016 23:39:29 -0700 (PDT)
Received: by mail-lf0-f65.google.com with SMTP id x79so3932747lff.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:39:29 -0700 (PDT)
Date: Fri, 21 Oct 2016 08:39:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: memcontrol: use special workqueue for creating
 per-memcg caches
Message-ID: <20161021063928.GC6045@dhcp22.suse.cz>
References: <c509c51d47b387c3d8e879678aca0b5e881b4613.1475329751.git.vdavydov.dev@gmail.com>
 <20161003120641.GC26768@dhcp22.suse.cz>
 <20161003123505.GA1862@esperanza>
 <20161003131930.GE26768@dhcp22.suse.cz>
 <20161004131417.GC1862@esperanza>
 <20161020204435.5e0ffca43c7b6ab5f69d692a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161020204435.5e0ffca43c7b6ab5f69d692a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-10-16 20:44:35, Andrew Morton wrote:
> On Tue, 4 Oct 2016 16:14:17 +0300 Vladimir Davydov <vdavydov.dev@gmail.com> wrote:
> 
> > Creating a lot of cgroups at the same time might stall all worker
> > threads with kmem cache creation works, because kmem cache creation is
> > done with the slab_mutex held. The problem was amplified by commits
> > 801faf0db894 ("mm/slab: lockless decision to grow cache") in case of
> > SLAB and 81ae6d03952c ("mm/slub.c: replace kick_all_cpus_sync() with
> > synchronize_sched() in kmem_cache_shrink()") in case of SLUB, which
> > increased the maximal time the slab_mutex can be held.
> > 
> > To prevent that from happening, let's use a special ordered single
> > threaded workqueue for kmem cache creation. This shouldn't introduce any
> > functional changes regarding how kmem caches are created, as the work
> > function holds the global slab_mutex during its whole runtime anyway,
> > making it impossible to run more than one work at a time. By using a
> > single threaded workqueue, we just avoid creating a thread per each
> > work. Ordering is required to avoid a situation when a cgroup's work is
> > put off indefinitely because there are other cgroups to serve, in other
> > words to guarantee fairness.
> 
> I'm having trouble working out the urgency of this patch?

Seeing thousands of kernel threads is certainly annoying so I think we
want to merge it sooner rather than later and have it backported to
stable as well.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
