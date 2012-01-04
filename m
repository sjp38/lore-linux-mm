Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 1EC056B004D
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 18:33:20 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so18885708obc.14
        for <linux-mm@kvack.org>; Wed, 04 Jan 2012 15:33:19 -0800 (PST)
Message-ID: <4F04E1B8.10109@gmail.com>
Date: Wed, 04 Jan 2012 18:33:12 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm,mlock: drain pagevecs asynchronously
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com> <1325403025-22688-1-git-send-email-kosaki.motohiro@gmail.com> <20120104140547.75d4dd55.akpm@linux-foundation.org>
In-Reply-To: <20120104140547.75d4dd55.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>

(1/4/12 5:05 PM), Andrew Morton wrote:
> On Sun,  1 Jan 2012 02:30:24 -0500
> kosaki.motohiro@gmail.com wrote:
>
>> Because lru_add_drain_all() spent much time.
>
> Those LRU pagevecs are horrid things.  They add high code and
> conceptual complexity, they add pointless uniprocessor overhead and the
> way in which they leave LRU pages floating around not on an LRU is
> rather maddening.
>
> So the best way to fix all of this as well as this problem we're
> observing is, I hope, to completely remove them.
>
> They've been in there for ~10 years and at the time they were quite
> beneficial in reducing lru_lock contention, hold times, acquisition
> frequency, etc.
>
> The approach to take here is to prepare the patches which eliminate
> lru_*_pvecs then identify the problems which occur as a result, via
> code inspection and runtime testing.  Then fix those up.
>
> Many sites which take lru_lock are already batching the operation.
> It's a matter of hunting down those sites which take the lock
> once-per-page and, if they have high frequency, batch them up.
>
> Converting readahead to batch the locking will be pretty simple
> (read_pages(), mpage_readpages(), others).  That will fix pagefaults
> too.
>
> rotate_reclaimable_page() can be batched by batching
> end_page_writeback(): a bio contains many pages already.
>
> deactivate_page() can be batched too - invalidate_mapping_pages() is
> already working on large chunks of pages.
>
> Those three cases are fairly simple - we just didn't try, because the
> lru_*_pvecs were there to do the work for us.

got it. so, let's wait hugh's "mm: take pagevecs off reclaim stack" next spin
and make the patches on top of it.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
