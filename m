Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 2EA7C6B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 15:13:23 -0500 (EST)
Received: by dadv6 with SMTP id v6so8888118dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 12:13:22 -0800 (PST)
Date: Tue, 21 Feb 2012 12:12:58 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 9/10] mm/memcg: move lru_lock into lruvec
In-Reply-To: <4F434300.3080001@openvz.org>
Message-ID: <alpine.LSU.2.00.1202211205280.1858@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201537040.23274@eggly.anvils> <4F434300.3080001@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 21 Feb 2012, Konstantin Khlebnikov wrote:
> 
> On lumpy/compaction isolate you do:
> 
> if (!PageLRU(page))
> 	continue
> 
> __isolate_lru_page()
> 
> page_relock_rcu_vec()
> 	rcu_read_lock()
> 	rcu_dereference()...
> 	spin_lock()...
> 	rcu_read_unlock()
> 
> You protect page_relock_rcu_vec with switching pointers back to root.
> 
> I do:
> 
> catch_page_lru()
> 	rcu_read_lock()
> 	if (!PageLRU(page))
> 		return false
> 	rcu_dereference()...
> 	spin_lock()...
> 	rcu_read_unlock()
> 	if (PageLRU())
> 		return true
> if true
> 	__isolate_lru_page()
> 
> I protect my catch_page_lruvec() with PageLRU() under single rcu-interval
> with locking.
> Thus my code is better, because it not requires switching pointers back to
> root memcg.

That sounds much better, yes - if it does work reliably.

I'll have to come back to think about your locking later too;
or maybe that's exactly where I need to look, when investigating
the mm_inline.h:41 BUG.

But at first sight, I have to say I'm very suspicious: I've never found
PageLRU a good enough test for whether we need such a lock, because of
races with those pages on percpu lruvec about to be put on the lru.

But maybe once I look closer, I'll find that's handled by your changes
away from lruvec; though I'd have thought the same issue exists,
independent of whether the pending pages are in vector or list.

Hugh

> 
> Meanwhile after seeing your patches, I realized that this rcu-protection is
> required only for lock-by-pfn in lumpy/compaction isolation.
> Thus my locking should be simplified and optimized.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
