Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 0FC0E6B006C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 20:14:04 -0400 (EDT)
Date: Wed, 3 Apr 2013 09:14:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] THP: Use explicit memory barrier
Message-ID: <20130403001401.GC16026@blaptop>
References: <1364773535-26264-1-git-send-email-minchan@kernel.org>
 <alpine.DEB.2.02.1304011634530.21603@chino.kir.corp.google.com>
 <20130402003746.GA30444@blaptop>
 <alpine.LNX.2.00.1304021221240.5808@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1304021221240.5808@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Apr 02, 2013 at 12:30:15PM -0700, Hugh Dickins wrote:
> On Tue, 2 Apr 2013, Minchan Kim wrote:
> > On Mon, Apr 01, 2013 at 04:35:38PM -0700, David Rientjes wrote:
> > > On Mon, 1 Apr 2013, Minchan Kim wrote:
> > > 
> > > > __do_huge_pmd_anonymous_page depends on page_add_new_anon_rmap's
> > > > spinlock for making sure that clear_huge_page write become visible
> > > > after set set_pmd_at() write.
> > > > 
> > > > But lru_cache_add_lru uses pagevec so it could miss spinlock
> > > > easily so above rule was broken so user may see inconsistent data.
> > > > 
> > > > This patch fixes it with using explict barrier rather than depending
> > > > on lru spinlock.
> > > > 
> > > 
> > > Is this the same issue that Andrea responded to in the "thp and memory 
> > > barrier assumptions" thread at http://marc.info/?t=134333512700004 ?
> > 
> > Yes and Peter pointed out further step.
> > Thanks for pointing out.
> > Not that I know that Andrea alreay noticed it, I don't care about this
> > patch.
> > 
> > Remaining question is Kame's one.
> > > Hmm...how about do_anonymous_page() ? there are no comments/locks/barriers.
> > > Users can see non-zero value after page fault in theory ?
> > Isn't there anyone could answer it?
> 
> See Nick's 2008 0ed361dec "mm: fix PageUptodate data race", which gave us
> 
> static inline void __SetPageUptodate(struct page *page)
> {
> 	smp_wmb();
> 	__set_bit(PG_uptodate, &(page)->flags);
> }
> 
> So both do_anonymous_page() and __do_huge_pmd_anonymous_page() look safe
> to me already, though the huge_memory one could do with a fixed comment.

Thanks you very much!
That's one everybody are really missing.

Here it goes!

==================== 8< =====================
