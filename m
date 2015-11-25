Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9E7E56B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 15:08:19 -0500 (EST)
Received: by wmvv187 with SMTP id v187so2389371wmv.1
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 12:08:19 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id vx5si36773492wjc.219.2015.11.25.12.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Nov 2015 12:08:18 -0800 (PST)
Date: Wed, 25 Nov 2015 15:08:06 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH] mm, oom: introduce oom reaper
Message-ID: <20151125200806.GA13388@cmpxchg.org>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Hi Michal,

I think whatever we end up doing to smoothen things for the "common
case" (as much as OOM kills can be considered common), we need a plan
to resolve the memory deadlock situations in a finite amount of time.

Eventually we have to attempt killing another task. Or kill all of
them to save the kernel.

It just strikes me as odd to start with smoothening the common case,
rather than making it functionally correct first.

On Wed, Nov 25, 2015 at 04:56:58PM +0100, Michal Hocko wrote:
> A kernel thread has been chosen because we need a reliable way of
> invocation so workqueue context is not appropriate because all the
> workers might be busy (e.g. allocating memory). Kswapd which sounds
> like another good fit is not appropriate as well because it might get
> blocked on locks during reclaim as well.

Why not do it directly from the allocating context? I.e. when entering
the OOM killer and finding a lingering TIF_MEMDIE from a previous kill
just reap its memory directly then and there. It's not like the
allocating task has anything else to do in the meantime...

> @@ -1123,7 +1126,7 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
>  			continue;
>  		}
>  		/* If details->check_mapping, we leave swap entries. */
> -		if (unlikely(details))
> +		if (unlikely(details || !details->check_swap_entries))
>  			continue;

&&

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
