Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 175E26B4699
	for <linux-mm@kvack.org>; Tue, 27 Nov 2018 02:49:24 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id o21so7039828edq.4
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 23:49:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z51sor1919752edd.15.2018.11.26.23.49.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 23:49:22 -0800 (PST)
Date: Tue, 27 Nov 2018 08:49:18 +0100
From: Daniel Vetter <daniel@ffwll.ch>
Subject: Re: [PATCH 3/3] mm, notifier: Add a lockdep map for
 invalidate_range_start
Message-ID: <20181127074918.GT4266@phenom.ffwll.local>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
 <20181122165106.18238-4-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181122165106.18238-4-daniel.vetter@ffwll.ch>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Daniel Vetter <daniel.vetter@intel.com>

On Thu, Nov 22, 2018 at 05:51:06PM +0100, Daniel Vetter wrote:
> This is a similar idea to the fs_reclaim fake lockdep lock. It's
> fairly easy to provoke a specific notifier to be run on a specific
> range: Just prep it, and then munmap() it.
> 
> A bit harder, but still doable, is to provoke the mmu notifiers for
> all the various callchains that might lead to them. But both at the
> same time is really hard to reliable hit, especially when you want to
> exercise paths like direct reclaim or compaction, where it's not
> easy to control what exactly will be unmapped.
> 
> By introducing a lockdep map to tie them all together we allow lockdep
> to see a lot more dependencies, without having to actually hit them
> in a single challchain while testing.
> 
> Aside: Since I typed this to test i915 mmu notifiers I've only rolled
> this out for the invaliate_range_start callback. If there's
> interest, we should probably roll this out to all of them. But my
> undestanding of core mm is seriously lacking, and I'm not clear on
> whether we need a lockdep map for each callback, or whether some can
> be shared.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "J�r�me Glisse" <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Christian K�nig" <christian.koenig@amd.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>

Any comments on this one here? This is really the main ingredient for
catching deadlocks in mmu notifier callbacks. The other two patches are
more the icing on the cake.

Thanks, Daniel

> ---
>  include/linux/mmu_notifier.h | 7 +++++++
>  mm/mmu_notifier.c            | 7 +++++++
>  2 files changed, 14 insertions(+)
> 
> diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
> index 9893a6432adf..a39ba218dbbe 100644
> --- a/include/linux/mmu_notifier.h
> +++ b/include/linux/mmu_notifier.h
> @@ -12,6 +12,10 @@ struct mmu_notifier_ops;
>  
>  #ifdef CONFIG_MMU_NOTIFIER
>  
> +#ifdef CONFIG_LOCKDEP
> +extern struct lockdep_map __mmu_notifier_invalidate_range_start_map;
> +#endif
> +
>  /*
>   * The mmu notifier_mm structure is allocated and installed in
>   * mm->mmu_notifier_mm inside the mm_take_all_locks() protected
> @@ -267,8 +271,11 @@ static inline void mmu_notifier_change_pte(struct mm_struct *mm,
>  static inline void mmu_notifier_invalidate_range_start(struct mm_struct *mm,
>  				  unsigned long start, unsigned long end)
>  {
> +	mutex_acquire(&__mmu_notifier_invalidate_range_start_map, 0, 0,
> +		      _RET_IP_);
>  	if (mm_has_notifiers(mm))
>  		__mmu_notifier_invalidate_range_start(mm, start, end, true);
> +	mutex_release(&__mmu_notifier_invalidate_range_start_map, 1, _RET_IP_);
>  }
>  
>  static inline int mmu_notifier_invalidate_range_start_nonblock(struct mm_struct *mm,
> diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
> index 4d282cfb296e..c6e797927376 100644
> --- a/mm/mmu_notifier.c
> +++ b/mm/mmu_notifier.c
> @@ -23,6 +23,13 @@
>  /* global SRCU for all MMs */
>  DEFINE_STATIC_SRCU(srcu);
>  
> +#ifdef CONFIG_LOCKDEP
> +struct lockdep_map __mmu_notifier_invalidate_range_start_map = {
> +	.name = "mmu_notifier_invalidate_range_start"
> +};
> +EXPORT_SYMBOL_GPL(__mmu_notifier_invalidate_range_start_map);
> +#endif
> +
>  /*
>   * This function allows mmu_notifier::release callback to delay a call to
>   * a function that will free appropriate resources. The function must be
> -- 
> 2.19.1
> 

-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch
