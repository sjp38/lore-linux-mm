Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F14D36B025E
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 09:54:37 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so14402902wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 06:54:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 62si20249132wmv.71.2016.07.19.06.54.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 06:54:36 -0700 (PDT)
Date: Tue, 19 Jul 2016 09:54:26 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
Message-ID: <20160719135426.GA31229@cmpxchg.org>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468831285-27242-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, Michal Hocko <mhocko@suse.com>

On Mon, Jul 18, 2016 at 10:41:24AM +0200, Michal Hocko wrote:
> The original intention of f9054c70d28b was to help with the OOM
> situations where the oom victim depends on mempool allocation to make a
> forward progress. We can handle that case in a different way, though. We
> can check whether the current task has access to memory reserves ad an
> OOM victim (TIF_MEMDIE) and drop __GFP_NOMEMALLOC protection if the pool
> is empty.
> 
> David Rientjes was objecting that such an approach wouldn't help if the
> oom victim was blocked on a lock held by process doing mempool_alloc. This
> is very similar to other oom deadlock situations and we have oom_reaper
> to deal with them so it is reasonable to rely on the same mechanism
> rather inventing a different one which has negative side effects.

I don't understand how this scenario wouldn't be a flat-out bug.

Mempool guarantees forward progress by having all necessary memory
objects for the guaranteed operation in reserve. Think about it this
way: you should be able to delete the pool->alloc() call entirely and
still make reliable forward progress. It would kill concurrency and be
super slow, but how could it be affected by a system OOM situation?

If our mempool_alloc() is waiting for an object that an OOM victim is
holding, where could that OOM victim get stuck before giving it back?
As I asked in the previous thread, surely you wouldn't do a mempool
allocation first and then rely on an unguarded page allocation to make
forward progress, right? It would defeat the purpose of using mempools
in the first place. And surely the OOM victim wouldn't be waiting for
a lock that somebody doing mempool_alloc() *against the same mempool*
is holding. That'd be an obvious ABBA deadlock.

So maybe I'm just dense, but could somebody please outline the exact
deadlock diagram? Who is doing what, and how are they getting stuck?

cpu0:                     cpu1:
                          mempool_alloc(pool0)
mempool_alloc(pool0)
  wait for cpu1
                          not allocating memory - would defeat mempool
                          not taking locks held by cpu0* - would ABBA
                          ???
                          mempool_free(pool0)

Thanks

* or any other task that does mempool_alloc(pool0) before unlock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
