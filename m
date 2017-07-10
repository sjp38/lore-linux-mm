Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9706A44084A
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 09:33:18 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id p64so24263793wrc.8
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 06:33:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t17si4141149wmd.148.2017.07.10.06.33.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 06:33:17 -0700 (PDT)
Date: Mon, 10 Jul 2017 15:33:15 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: printk: Should console related code avoid __GFP_DIRECT_RECLAIM
 memory allocations?
Message-ID: <20170710133314.GK19185@dhcp22.suse.cz>
References: <201707061928.IJI87020.FMQLFOOOHVFSJt@I-love.SAKURA.ne.jp>
 <20170707023601.GA7478@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170707023601.GA7478@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, sergey.senozhatsky@gmail.com, pmladek@suse.com, pavel@ucw.cz, rostedt@goodmis.org, andi@lisas.de, jack@suse.cz, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@ffwll.ch>

On Fri 07-07-17 11:39:18, Sergey Senozhatsky wrote:
[...]
> > void drm_modeset_lock_all(struct drm_device *dev)
> > {
> >         struct drm_mode_config *config = &dev->mode_config;
> >         struct drm_modeset_acquire_ctx *ctx;
> >         int ret;
> > 
> >         ctx = kzalloc(sizeof(*ctx), GFP_KERNEL);
> >         if (WARN_ON(!ctx))
> >                 return;
> 
> hm, this allocation, per se, looks ok to me. can't really blame it.
> what you had is a combination of factors
> 
> 	CPU0			CPU1				CPU2
> 								console_callback()
> 								 console_lock()
> 								 ^^^^^^^^^^^^^
> 	vprintk_emit()		mutex_lock(&par->bo_mutex)
> 				 kzalloc(GFP_KERNEL)
> 	 console_trylock()	  kmem_cache_alloc()		  mutex_lock(&par->bo_mutex)
> 	 ^^^^^^^^^^^^^^^^	   io_schedule_timeout
> 
> // but I haven't seen the logs that you have provided, yet.
> 
> [..]
> > As a result, console was not able to print SysRq-t output.
> > 
> > So, how should we avoid this problem?
> 
> from the top of my head -- console_sem must be replaced with something
> better.

Yeah, absolutely. The current mess just allows basically arbitrary lock
depencies which are not deadlocks because the printk part is careful but
essentially we are deadlocked wrt. functionality.

> but that's a task for years.
> 
> hm...
> 
> > But should fbcon, drm, tty and so on stop using __GFP_DIRECT_RECLAIM
> > memory allocations because consoles should be as responsive as printk() ?
> 
> may be, may be not. like I said, the allocation in question does not
> participate in console output. it's rather hard to imagine how we would
> enforce a !__GFP_DIRECT_RECLAIM requirement here. it's console semaphore
> to blame, I think.

Agreed! Looking at the problem just from the page allocator perspective
is simply wrong. That is where you see your immediate problem because
that is what you are testing I would bet my hat you can find other
interesting scenarios if you try too hard...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
