Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 6601C6B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 19:19:27 -0500 (EST)
Received: by iacb35 with SMTP id b35so40348176iac.14
        for <linux-mm@kvack.org>; Wed, 04 Jan 2012 16:19:26 -0800 (PST)
Date: Wed, 4 Jan 2012 16:19:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] mm,mlock: drain pagevecs asynchronously
In-Reply-To: <4F04E1B8.10109@gmail.com>
Message-ID: <alpine.LSU.2.00.1201041549410.1267@eggly.anvils>
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <1325403025-22688-1-git-send-email-kosaki.motohiro@gmail.com> <20120104140547.75d4dd55.akpm@linux-foundation.org> <4F04E1B8.10109@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>

On Wed, 4 Jan 2012, KOSAKI Motohiro wrote:
> (1/4/12 5:05 PM), Andrew Morton wrote:
> > On Sun,  1 Jan 2012 02:30:24 -0500
> > kosaki.motohiro@gmail.com wrote:
> > 
> > > Because lru_add_drain_all() spent much time.
> > 
> > Those LRU pagevecs are horrid things.  They add high code and
> > conceptual complexity, they add pointless uniprocessor overhead and the
> > way in which they leave LRU pages floating around not on an LRU is
> > rather maddening.

Yes, we continue to have difficulties with not-quite-PageLRU-yet pages.

> > 
> > So the best way to fix all of this as well as this problem we're
> > observing is, I hope, to completely remove them.

Nice aim, sounds like a dirty job.  I wonder how far we could get using
lru_add_drain, avoiding lru_add_drain_all, and flushing pvec when pre-empted.

> ...
> 
> got it. so, let's wait hugh's "mm: take pagevecs off reclaim stack" next spin
> and make the patches on top of it.

Don't wait on me, I wasn't intending another spin, with Andrew's last
word on it today:

> If we already have the latency problem at the isolate_lru_pages() stage
> then I suppose we can assume that nobody is noticing it, so we'll
> probably be OK.
> 
> For a while.  Someone will complain at some stage and we'll probably
> end up busting this work into chunks.

and mm-commits does presently have my
mm-rearrange-putback-inactive-pages.patch in on top of it.

Besides, these free_hot_cold_page_list() users are already avoiding
the lru add pagevecs which Andrew is nudging towards removing above,
so there shouldn't be much overlap.

Or maybe you're thinking of my observation that it could avoid the
!page_evictable putback_lru_page special case now: yes, I'd like to
make that change sometime, but moved away to other things for now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
