Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 221696B0033
	for <linux-mm@kvack.org>; Sun,  5 Nov 2017 02:37:37 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id b189so2263319wmd.9
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 00:37:37 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m10si160573eda.449.2017.11.05.00.37.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 05 Nov 2017 00:37:35 -0700 (PDT)
Date: Sun, 5 Nov 2017 08:37:32 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] shmem: drop lru_add_drain_all from
 shmem_wait_for_pins
Message-ID: <20171105073732.yookzui4vjh7cfa7@dhcp22.suse.cz>
References: <20171102093613.3616-1-mhocko@kernel.org>
 <20171102093613.3616-2-mhocko@kernel.org>
 <alpine.LSU.2.11.1711030004260.4821@eggly.anvils>
 <20171103082417.7rwns74txzzoyzyv@dhcp22.suse.cz>
 <alpine.LSU.2.11.1711041713400.5450@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1711041713400.5450@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Herrmann <dh.herrmann@gmail.com>

On Sat 04-11-17 17:28:05, Hugh Dickins wrote:
> On Fri, 3 Nov 2017, Michal Hocko wrote:
> > On Fri 03-11-17 00:46:18, Hugh Dickins wrote:
> > > 
> > > NAK.  shmem_wait_for_pins() is waiting for temporary pins on the pages
> > > to go away, and using lru_add_drain_all() in the usual way, to lower
> > > the refcount of pages temporarily pinned in a pagevec somewhere.  Page
> > > count is touched by draining pagevecs: I'm surprised to see you say
> > > that it isn't - or have pagevec page references been eliminated by
> > > a recent commit that I missed?
> > 
> > I must be missing something here. __pagevec_lru_add_fn merely about
> > moving the page into the appropriate LRU list, pagevec_move_tail only
> > rotates, lru_deactivate_file_fn moves from active to inactive LRUs,
> > lru_lazyfree_fn moves from anon to file LRUs and activate_page_drain
> > just moves to the active list. None of those operations touch the page
> > count AFAICS. So I would agree that some pages might be pinned outside
> > of the LRU (lru_add_pvec) and thus unreclaimable but does this really
> > matter. Or what else I am missing?
> 
> Line 213 of mm/swap.c?  Where pagevec_lru_move_fn() calls release_pages()
> to release the extra references (which each page came in with when added).

I am obviously blind. I was staring at that function many times simply
missing this part. My bad and sorry about not taking a deeper look.
Shame...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
