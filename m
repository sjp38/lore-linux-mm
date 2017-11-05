Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 443906B0033
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 20:28:28 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v2so6776890pfa.10
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 17:28:28 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e13sor2948740pln.139.2017.11.04.17.28.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 Nov 2017 17:28:26 -0700 (PDT)
Date: Sat, 4 Nov 2017 17:28:05 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] shmem: drop lru_add_drain_all from
 shmem_wait_for_pins
In-Reply-To: <20171103082417.7rwns74txzzoyzyv@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1711041713400.5450@eggly.anvils>
References: <20171102093613.3616-1-mhocko@kernel.org> <20171102093613.3616-2-mhocko@kernel.org> <alpine.LSU.2.11.1711030004260.4821@eggly.anvils> <20171103082417.7rwns74txzzoyzyv@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Herrmann <dh.herrmann@gmail.com>

On Fri, 3 Nov 2017, Michal Hocko wrote:
> On Fri 03-11-17 00:46:18, Hugh Dickins wrote:
> > 
> > NAK.  shmem_wait_for_pins() is waiting for temporary pins on the pages
> > to go away, and using lru_add_drain_all() in the usual way, to lower
> > the refcount of pages temporarily pinned in a pagevec somewhere.  Page
> > count is touched by draining pagevecs: I'm surprised to see you say
> > that it isn't - or have pagevec page references been eliminated by
> > a recent commit that I missed?
> 
> I must be missing something here. __pagevec_lru_add_fn merely about
> moving the page into the appropriate LRU list, pagevec_move_tail only
> rotates, lru_deactivate_file_fn moves from active to inactive LRUs,
> lru_lazyfree_fn moves from anon to file LRUs and activate_page_drain
> just moves to the active list. None of those operations touch the page
> count AFAICS. So I would agree that some pages might be pinned outside
> of the LRU (lru_add_pvec) and thus unreclaimable but does this really
> matter. Or what else I am missing?

Line 213 of mm/swap.c?  Where pagevec_lru_move_fn() calls release_pages()
to release the extra references (which each page came in with when added).
Think about it, the mayhem that would follow from a page being freed while
on pagevec: of course it must hold a reference.  The only surprise is that
the extra reference is not needed while on LRU: one can think of PageLRU
as an extension of the page count.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
