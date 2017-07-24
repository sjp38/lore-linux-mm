Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80F126B0292
	for <linux-mm@kvack.org>; Mon, 24 Jul 2017 03:03:36 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id v17so82360390ywh.15
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 00:03:36 -0700 (PDT)
Received: from mail-yw0-x22d.google.com (mail-yw0-x22d.google.com. [2607:f8b0:4002:c05::22d])
        by mx.google.com with ESMTPS id h64si2454732ybc.279.2017.07.24.00.03.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jul 2017 00:03:35 -0700 (PDT)
Received: by mail-yw0-x22d.google.com with SMTP id i6so9486087ywb.1
        for <linux-mm@kvack.org>; Mon, 24 Jul 2017 00:03:35 -0700 (PDT)
Date: Mon, 24 Jul 2017 00:03:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
In-Reply-To: <20170720132225.GI9058@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1707240001210.2154@eggly.anvils>
References: <20170710074842.23175-1-mhocko@kernel.org> <alpine.LSU.2.11.1707191823190.2445@eggly.anvils> <20170720132225.GI9058@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, 20 Jul 2017, Michal Hocko wrote:
> On Wed 19-07-17 18:54:40, Hugh Dickins wrote:
> [...]
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
> > 
> > But that was on a different kernel, and there I did have to make sure
> > that PF_MEMALLOC always prevented us from nesting: I'm not certain of
> > that in the current kernel (but do remember Johannes changing the memcg
> > end to make it use PF_MEMALLOC too).  I offer the preview above, to see
> > if you're interested in that alternative: if you are, then I'll go ahead
> > and make it into an actual patch against v4.13-rc.
> 
> I would rather get rid of any additional locking here and my ultimate
> goal is to make throttling at the page allocator layer rather than
> inside the reclaim.

Fair enough, I'm certainly in no hurry to send the patch,
but thought it worth mentioning.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
