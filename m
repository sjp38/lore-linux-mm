Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC28D6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 06:44:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j194so1993717oib.15
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 03:44:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d84si5824654oif.169.2017.07.20.03.44.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Jul 2017 03:44:21 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170710074842.23175-1-mhocko@kernel.org>
	<alpine.LSU.2.11.1707191823190.2445@eggly.anvils>
In-Reply-To: <alpine.LSU.2.11.1707191823190.2445@eggly.anvils>
Message-Id: <201707201944.IJI05796.VLFJFFtSQMOOOH@I-love.SAKURA.ne.jp>
Date: Thu, 20 Jul 2017 19:44:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hughd@google.com, mhocko@kernel.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Hugh Dickins wrote:
> You probably won't welcome getting into alternatives at this late stage;
> but after hacking around it one way or another because of its pointless
> lockups, I lost patience with that too_many_isolated() loop a few months
> back (on realizing the enormous number of pages that may be isolated via
> migrate_pages(2)), and we've been running nicely since with something like:
> 
> 	bool got_mutex = false;
> 
> 	if (unlikely(too_many_isolated(pgdat, file, sc))) {
> 		if (mutex_lock_killable(&pgdat->too_many_isolated))
> 			return SWAP_CLUSTER_MAX;
> 		got_mutex = true;
> 	}
> 	...
> 	if (got_mutex)
> 		mutex_unlock(&pgdat->too_many_isolated);
> 
> Using a mutex to provide the intended throttling, without an infinite
> loop or an arbitrary delay; and without having to worry (as we often did)
> about whether those numbers in too_many_isolated() are really appropriate.
> No premature OOMs complained of yet.

Roughly speaking, there is a moment where shrink_inactive_list() acts
like below.

	bool got_mutex = false;

	if (!current_is_kswapd()) {
		if (mutex_lock_killable(&pgdat->too_many_isolated))
			return SWAP_CLUSTER_MAX;
		got_mutex = true;
	}

	// kswapd is blocked here waiting for !current_is_kswapd().

	if (got_mutex)
		mutex_unlock(&pgdat->too_many_isolated);

> 
> But that was on a different kernel, and there I did have to make sure
> that PF_MEMALLOC always prevented us from nesting: I'm not certain of
> that in the current kernel (but do remember Johannes changing the memcg
> end to make it use PF_MEMALLOC too).  I offer the preview above, to see
> if you're interested in that alternative: if you are, then I'll go ahead
> and make it into an actual patch against v4.13-rc.

I don't know what your actual patch looks like, but the problem is that
pgdat->too_many_isolated waits for kswapd while kswapd waits for
pgdat->too_many_isolated; nobody can unlock pgdat->too_many_isolated if
once we hit it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
