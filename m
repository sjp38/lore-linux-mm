Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B9386B0027
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:48:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id i14-v6so7342259lfh.1
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 08:48:34 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e13-v6sor421089lfc.36.2018.03.27.08.48.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 08:48:32 -0700 (PDT)
Date: Tue, 27 Mar 2018 18:48:28 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH 01/10] mm: Assign id to every memcg-aware shrinker
Message-ID: <20180327154828.udezpkwkwzcftnqn@esperanza>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163847740.21546.16821490541519326725.stgit@localhost.localdomain>
 <20180324184009.dyjlt4rj4b6y6sz3@esperanza>
 <0db2d93f-12cd-d703-fce7-4c3b8df5bc12@virtuozzo.com>
 <20180327091504.zcqvr3mkuznlgwux@esperanza>
 <5828e99c-74d2-6208-5ec2-3361899dd36a@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5828e99c-74d2-6208-5ec2-3361899dd36a@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On Tue, Mar 27, 2018 at 06:09:20PM +0300, Kirill Tkhai wrote:
> >>>> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >>>> index 8fcd9f8d7390..91b5120b924f 100644
> >>>> --- a/mm/vmscan.c
> >>>> +++ b/mm/vmscan.c
> >>>> @@ -159,6 +159,56 @@ unsigned long vm_total_pages;
> >>>>  static LIST_HEAD(shrinker_list);
> >>>>  static DECLARE_RWSEM(shrinker_rwsem);
> >>>>  
> >>>> +#if defined(CONFIG_MEMCG) && !defined(CONFIG_SLOB)
> >>>> +static DEFINE_IDA(bitmap_id_ida);
> >>>> +static DECLARE_RWSEM(bitmap_rwsem);
> >>>
> >>> Can't we reuse shrinker_rwsem for protecting the ida?
> >>
> >> I think it won't be better, since we allocate memory under this semaphore.
> >> After we use shrinker_rwsem, we'll have to allocate the memory with GFP_ATOMIC,
> >> which does not seems good. Currently, the patchset makes shrinker_rwsem be taken
> >> for a small time, just to assign already allocated memory to maps.
> > 
> > AFAIR it's OK to sleep under an rwsem so GFP_ATOMIC wouldn't be
> > necessary. Anyway, we only need to allocate memory when we extend
> > shrinker bitmaps, which is rare. In fact, there can only be a limited
> > number of such calls, as we never shrink these bitmaps (which is fine
> > by me).
> 
> We take bitmap_rwsem for writing to expand shrinkers maps. If we replace
> it with shrinker_rwsem and the memory allocation get into reclaim, there
> will be deadlock.

Hmm, AFAICS we use down_read_trylock() in shrink_slab() so no deadlock
would be possible. We wouldn't be able to reclaim slabs though, that's
true, but I don't think it would be a problem for small allocations.

That's how I see this. We use shrinker_rwsem to protect IDR mapping
shrink_id => shrinker (I still insist on IDR). It may allocate, but the
allocation size is going to be fairly small so it's OK that we don't
call shrinkers there. After we allocated a shrinker ID, we release
shrinker_rwsem and call mem_cgroup_grow_shrinker_map (or whatever it
will be called), which checks if per-memcg shrinker bitmaps need growing
and if they do it takes its own mutex used exclusively for protecting
the bitmaps and reallocates the bitmaps (we will need the mutex anyway
to synchronize css_online vs shrinker bitmap reallocation as the
shrinker_rwsem is private to vmscan.c and we don't want to export it
to memcontrol.c).
