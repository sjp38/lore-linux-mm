Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79C946B0005
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 03:14:24 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id t24-v6so1773321edq.13
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 00:14:24 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25-v6si1541550edf.328.2018.08.09.00.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 00:14:22 -0700 (PDT)
Date: Thu, 9 Aug 2018 09:14:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC v2 02/10] mm: Make shrink_slab() lockless
Message-ID: <20180809071418.GA24884@dhcp22.suse.cz>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
 <4ceb948c-7ce7-0db3-17d8-82ef1e6e47cc@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ceb948c-7ce7-0db3-17d8-82ef1e6e47cc@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed 08-08-18 16:20:54, Kirill Tkhai wrote:
> [Added two more places needed srcu_dereference(). All ->shrinker_map
>  dereferences must be under SRCU, and this v2 adds missed in previous]
> 
> The patch makes shrinker list and shrinker_idr SRCU-safe
> for readers. This requires synchronize_srcu() on finalize
> stage unregistering stage, which waits till all parallel
> shrink_slab() are finished
> 
> Note, that patch removes rwsem_is_contended() checks from
> the code, and this does not result in delays during
> registration, since there is no waiting at all. Unregistration
> case may be optimized by splitting unregister_shrinker()
> in tho stages, and this is made in next patches.
>     
> Also, keep in mind, that in case of SRCU is not allowed
> to make unconditional (which is done in previous patch),
> it is possible to use percpu_rw_semaphore instead of it.
> percpu_down_read() will be used in shrink_slab_memcg()
> and in shrink_slab(), and consecutive calls
> 
>         percpu_down_write(percpu_rwsem);
>         percpu_up_write(percpu_rwsem);
> 
> will be used instead of synchronize_srcu().

An obvious question. Why didn't you go that way? What are pros/cons of
both approaches?
-- 
Michal Hocko
SUSE Labs
