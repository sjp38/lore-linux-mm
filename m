Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 183176B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 03:01:18 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 125so141962511pgi.2
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 00:01:18 -0700 (PDT)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id u15si5018001plk.932.2017.07.24.00.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 00:01:16 -0700 (PDT)
Received: by mail-pf0-x22b.google.com with SMTP id s70so43555387pfs.0
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 00:01:16 -0700 (PDT)
Date: Mon, 24 Jul 2017 00:01:13 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
In-Reply-To: <201707201944.IJI05796.VLFJFFtSQMOOOH@I-love.SAKURA.ne.jp>
Message-ID: <alpine.LSU.2.11.1707232339430.2154@eggly.anvils>
References: <20170710074842.23175-1-mhocko@kernel.org> <alpine.LSU.2.11.1707191823190.2445@eggly.anvils> <201707201944.IJI05796.VLFJFFtSQMOOOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: hughd@google.com, mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Thu, 20 Jul 2017, Tetsuo Handa wrote:
> Hugh Dickins wrote:
> > You probably won't welcome getting into alternatives at this late stage;
> > but after hacking around it one way or another because of its pointless
> > lockups, I lost patience with that too_many_isolated() loop a few months
> > back (on realizing the enormous number of pages that may be isolated via
> > migrate_pages(2)), and we've been running nicely since with something like:
> > 
> > 	bool got_mutex = false;
> > 
> > 	if (unlikely(too_many_isolated(pgdat, file, sc))) {
> > 		if (mutex_lock_killable(&pgdat->too_many_isolated))
> > 			return SWAP_CLUSTER_MAX;
> > 		got_mutex = true;
> > 	}
> > 	...
> > 	if (got_mutex)
> > 		mutex_unlock(&pgdat->too_many_isolated);
> > 
> > Using a mutex to provide the intended throttling, without an infinite
> > loop or an arbitrary delay; and without having to worry (as we often did)
> > about whether those numbers in too_many_isolated() are really appropriate.
> > No premature OOMs complained of yet.
> 
> Roughly speaking, there is a moment where shrink_inactive_list() acts
> like below.
> 
> 	bool got_mutex = false;
> 
> 	if (!current_is_kswapd()) {
> 		if (mutex_lock_killable(&pgdat->too_many_isolated))
> 			return SWAP_CLUSTER_MAX;
> 		got_mutex = true;
> 	}
> 
> 	// kswapd is blocked here waiting for !current_is_kswapd().

That would be a shame, for kswapd to wait for !current_is_kswapd()!

But seriously, I think I understand what you mean by that, you're
thinking that kswapd would be waiting on some other task to clear
the too_many_isolated() condition?

No, it does not work that way: kswapd (never seeing too_many_isolated()
because that always says false when current_is_kswapd()) never tries to
take the pgdat->too_many_isolated mutex itself: it does not wait there
at all, although other tasks may be waiting there at the time.

Perhaps my naming the mutex "too_many_isolated", same as the function,
is actually confusing, when I had intended it to be helpful.

> 
> 	if (got_mutex)
> 		mutex_unlock(&pgdat->too_many_isolated);
> 
> > 
> > But that was on a different kernel, and there I did have to make sure
> > that PF_MEMALLOC always prevented us from nesting: I'm not certain of
> > that in the current kernel (but do remember Johannes changing the memcg
> > end to make it use PF_MEMALLOC too).  I offer the preview above, to see
> > if you're interested in that alternative: if you are, then I'll go ahead
> > and make it into an actual patch against v4.13-rc.
> 
> I don't know what your actual patch looks like, but the problem is that
> pgdat->too_many_isolated waits for kswapd while kswapd waits for
> pgdat->too_many_isolated; nobody can unlock pgdat->too_many_isolated if
> once we hit it.

Not so (and we'd hardly be finding it a useful patch if that were so).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
