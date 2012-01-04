Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 5D71A6B004F
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 17:05:49 -0500 (EST)
Date: Wed, 4 Jan 2012 14:05:47 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,mlock: drain pagevecs asynchronously
Message-Id: <20120104140547.75d4dd55.akpm@linux-foundation.org>
In-Reply-To: <1325403025-22688-1-git-send-email-kosaki.motohiro@gmail.com>
References: <CAHGf_=qA3Pnb00n_smhJVKDDCDDr0d-a3E03Rrhnb-S4xK8_fQ@mail.gmail.com>
	<1325403025-22688-1-git-send-email-kosaki.motohiro@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kosaki.motohiro@gmail.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>

On Sun,  1 Jan 2012 02:30:24 -0500
kosaki.motohiro@gmail.com wrote:

> Because lru_add_drain_all() spent much time.

Those LRU pagevecs are horrid things.  They add high code and
conceptual complexity, they add pointless uniprocessor overhead and the
way in which they leave LRU pages floating around not on an LRU is
rather maddening.

So the best way to fix all of this as well as this problem we're
observing is, I hope, to completely remove them.

They've been in there for ~10 years and at the time they were quite
beneficial in reducing lru_lock contention, hold times, acquisition
frequency, etc.

The approach to take here is to prepare the patches which eliminate
lru_*_pvecs then identify the problems which occur as a result, via
code inspection and runtime testing.  Then fix those up.

Many sites which take lru_lock are already batching the operation. 
It's a matter of hunting down those sites which take the lock
once-per-page and, if they have high frequency, batch them up.

Converting readahead to batch the locking will be pretty simple
(read_pages(), mpage_readpages(), others).  That will fix pagefaults
too.  

rotate_reclaimable_page() can be batched by batching
end_page_writeback(): a bio contains many pages already.

deactivate_page() can be batched too - invalidate_mapping_pages() is
already working on large chunks of pages.

Those three cases are fairly simple - we just didn't try, because the
lru_*_pvecs were there to do the work for us.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
