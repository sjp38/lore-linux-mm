Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9A6656B016A
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 12:10:56 -0400 (EDT)
Date: Fri, 26 Aug 2011 18:10:48 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] thp: tail page refcounting fix #2
Message-ID: <20110826161048.GE23870@redhat.com>
References: <1313740111-27446-1-git-send-email-walken@google.com>
 <20110822213347.GF2507@redhat.com>
 <CANN689HE=TKyr-0yDQgXEoothGJ0Cw0HLB2iOvCKrOXVF2DNww@mail.gmail.com>
 <20110824000914.GH23870@redhat.com>
 <20110824002717.GI23870@redhat.com>
 <20110824133459.GP23870@redhat.com>
 <20110826062436.GA5847@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110826062436.GA5847@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Thu, Aug 25, 2011 at 11:24:36PM -0700, Michel Lespinasse wrote:
> I had never heard before of locked instructions being necessary when a
> straight assignment would do what we want, but after reading the erratas
> you listed, I'm not so sure anymore. Given that, I think the version with
> just one single atomic add is good enough.

spin_unlock sometime is adding the lock prefix too for that reason. So
I feel safer that way.

> (there are also 511 consecutive atomic_sub calls on the head page _count,
> which could just as well be coalesced into a signle one at the end of the
> tail page loop).

That should be safe. It's not like I'm a mood to microoptimize
__split_huge_page_refcount after you found I forgot the
get_page_unless_zero needed to keep the page->flags stable (they're
overwritten by the time the head page is freed, that is why we need it).

> I think your current __get_page_tail() is unsafe when it takes the
> compound lock on the head page, because there is no refcount held on it.
> If the THP page gets broken up before we get the compound lock, the head
> page could get freed. But it looks like you could fix that by doing
> get_page_unless_zero on the head, and you should end up with something
> very much like the put_page() function, which I find incredibly tricky
> but seems to be safe.

Correct, it's enough and we need it for the same reason it is in
put_page. Nothing new or no new fundamental problem with this
approach, just an implementation mistake. At least it could introduced
no regression compared to the previous code.

> I would suggest moving get_page_foll() and __get_page_tail_foll() to
> mm/internal.h so that people writing code outside of mm/ don't get confused
> about which get_page() version they must call.

Good idea. That is for MM internal usage only, only follow_page is
allowed to call it.

> In __get_page_tail(), you could add a VM_BUG_ON(page_mapcount(page) <= 0)
> to reflect the fact that get_page() callers are expected to have already
> gotten a reference on the page through a gup call.

So I could put it just before calling __get_page_tail_foll().

I don't see a way anybody could call get_page on a tail page without
having called gup on it first. So I think it's correct. Any
pfn-scanning code like your working set estimation code has to use
get_page_unless_zero and that will never succeed anymore for tail
pages.

> (not your fault, you just moved that code) The comment above
> reset_page_mapcount() and page_mapcount() mentions that _count starts from -1.
> This does not seem to be accurate anymore - as you see page_count() just
> returns the _count value without adding 1. I guess you could just remove
> ', like _count,' from the comment and that'd make it accurate :)

The comment talks about _mapcount not _count. page_mapcount still adds
1 to _mapcount and _mapcount really still starts from -1.

> The use of _mapcount to store tail page counts should probably be
> documented somewhere - probably in mm_types.h where _mapcount is
> defined, and/or before the page_mapcount accessor function. Or, there
> could be a tail_page_count() accessor function for that so that it's
> evident in all call sites that we're accessing a refcount and not a mapcount:
> 
> static inline int tail_page_count(struct page *page)
> {
> 	VM_BUG_ON(!PageTail(page));
> 	return page_mapcount(page);
> }
> 
> 
> (probably for another commit) I'm not too comfortable with having several
> arch-specific fast gup functions knowning details about how page counts
> are implemented. Linus's tree also adds such support in sparc arch
> (and it doesn't even seem to be correct as it increments the head count
> but not the tail count). This should probably be cleaned up sometime by
> moving such details into generic inline helper functions.
> 
> 
> Besides these comments, overall I like the change a lot & I'm especially
> happy to see get_page() work in all cases again :)

Glad to hear :).

Thanks a lot for pointing out the missing get_page_unless_zero(). I'll
post a #3 version soon with that bit fixed.

I'm undecided of tail_page_count is needed. The only benefit would be
to be able to grep for tail_page_count and see the few call sites, maybe
that makes it worth it. The VM_BUG_ON I doubt is necessary there
considering it's easy to review the callsites and they're so few. It'd
also need to go into internal.h I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
