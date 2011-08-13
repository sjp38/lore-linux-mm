Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A0FAF6B016E
	for <linux-mm@kvack.org>; Sat, 13 Aug 2011 00:11:40 -0400 (EDT)
Received: by ywm13 with SMTP id 13so2063929ywm.14
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 21:11:38 -0700 (PDT)
Date: Sat, 13 Aug 2011 13:11:29 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [RFC PATCH 0/3] page count lock for simpler put_page
Message-ID: <20110813041129.GB1905@barrios-desktop>
References: <1312492042-13184-1-git-send-email-walken@google.com>
 <CANN689HpuQ3bAW946c4OeoLLAUXHd6nzp+NVxkrFgZo7k3k0Kg@mail.gmail.com>
 <20110807142532.GC1823@barrios-desktop>
 <CANN689Edai1k4nmyTHZ_2EwWuTXdfmah-JiyibEBvSudcWhv+g@mail.gmail.com>
 <20110812153616.GH7959@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110812153616.GH7959@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>

On Fri, Aug 12, 2011 at 05:36:16PM +0200, Andrea Arcangeli wrote:
> On Tue, Aug 09, 2011 at 04:04:21AM -0700, Michel Lespinasse wrote:
> > - Use my proposed page count lock in order to avoid the race. One
> > would have to convert all get_page_unless_zero() sites to use it. I
> > expect the cost would be low but still measurable.
> 
> I didn't yet focus at your problem after we talked about it at MM
> summit, but I seem to recall I suggested there to just get to the head
> page and always take the lock on it. split_huge_page only works at 2M
> aligned pages, the rest you don't care about. Getting to the head page
> compound_lock should be always safe. And that will still scale
> incredibly better than taking the lru_lock for the whole zone (which
> would also work). And it seems the best way to stop split_huge_page
> without having to alter the put_page fast path when it works on head
> pages (the only thing that gets into put_page complex slow path is the
> release of tail pages after get_user_pages* so it'd be nice if
> put_page fast path still didn't need to take locks).
> 
> > - It'd be sweet if one could somehow record the time a THP page was
> > created, and wait for at least one RCU grace period *starting from the
> > recorded THP creation time* before splitting huge pages. In practice,
> > we would be very unlikely to have to wait since the grace period would
> > be already expired. However, I don't think RCU currently provides such
> > a mechanism - Paul, is this something that would seem easy to
> > implement or not ?
> 
> This looks sweet. We could store a quiescent points generation counter
> in the page[1].something, if the page has the same generation of the
> last RCU quiescent point (vs rcu_read_lock) we synchronize_rcu before
> starting split_huge_page. split_huge_page is serialized through the
> anon_vma lock however, so we'd need to release the anon_vma lock,
> synchronize_rcu and retry and this time the page[1].something sequence
> counter would be older than the rcu generation counter and it'll
> proceed (maybe another thread or process will get there first but
> that's ok).
> 
> I didn't have better ideas than yours above, but I'll keep thinking.
> 
> > > When I make deactivate_page, I didn't consider that honestly.
> > > IMHO, It shouldn't be a problem as deactive_page hold a reference
> > > of page by pagevec_lookup so the page shouldn't be gone under us.
> > 
> > Agree - it seems like you are guaranteed to already hold a reference
> > (but then a straight get_page should be sufficient, right ?)
> 
> I hope this is not an issue because of the fact the page is guaranteed
> not to be THP when get_page_unless_zero runs on it.

Yes. At the moment, it's not a problem as only caller(ie, invalidate_mapping_pages)
hold a reference on the page before calling. But if there is other usecase in future,
caller should keep in mind to prevent this problem.
So I will add comment about that and replace get_page_unless_zero with get_page to
prevent confusing.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
