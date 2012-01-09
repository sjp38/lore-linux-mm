Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 1DE5A6B005A
	for <linux-mm@kvack.org>; Mon,  9 Jan 2012 17:25:26 -0500 (EST)
Received: by iacb35 with SMTP id b35so9027808iac.14
        for <linux-mm@kvack.org>; Mon, 09 Jan 2012 14:25:25 -0800 (PST)
Date: Mon, 9 Jan 2012 14:25:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 2/2] SHM_UNLOCK: fix Unevictable pages stranded after
 swap
In-Reply-To: <4F0B5146.6090200@gmail.com>
Message-ID: <alpine.LSU.2.00.1201091342300.1272@eggly.anvils>
References: <alpine.LSU.2.00.1201061303320.12082@eggly.anvils> <alpine.LSU.2.00.1201061310340.12082@eggly.anvils> <4F0B5146.6090200@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 9 Jan 2012, KOSAKI Motohiro wrote:
> 2012/1/6 Hugh Dickins <hughd@google.com>:

[ check_move_unevictable_page(s) ]

> > 
> > Leave out the "rotate unevictable list" block: that's a leftover
> > from when this was used for /proc/sys/vm/scan_unevictable_pages,
> > whose flawed handling involved looking at pages at tail of LRU.
> > 
> > Was there significance to the sequence first ClearPageUnevictable,
> > then test page_evictable, then SetPageUnevictable here?  I think
> > not, we're under LRU lock, and have no barriers between those.
> 
> If I understand correctly, this is not exactly correct. Because of,

Thank you for giving it serious thought:
such races are hard work to think about.

> PG_mlocked operation is not protected by LRU lock. So, I think we

Right.  But I don't see that I've made a significant change there.

I may be being lazy, and rushing back to answer you, without giving
constructive thought to what the precise race is that you see, and
how we might fix it.  If the case you have in mind is easy for you
to describe in detail, please do so; but don't hesitate to tell me
to my own work for myself!

Since the original code didn't have any barriers in it (in the
!page_evictable path, in the global case: I think that's true of the
memcg case also, but that is more complicated), how did it differ from

retry:
	if (page_evictable)
		blah blah blah;
	else if (page_evictable)
		goto retry;

which could be made even "safer" ;) if it were replaced by

retry:
	if (page_evictable)
		blah blah blah;
	else if (page_evictable)
		goto retry;
	else if (page_evictable)
		goto retry;

putback_lru_page() goes through similar doubts as to whether it's made
the right decision ("Oh, did I leave the oven on?"), but it does contain
an explicit smp_mb() and comment.

I am being lazy, I haven't even stopped to convince myself that that
smp_mb() is correctly placed (I'm not saying it isn't, I just haven't
done the thinking).

> have three choice.
> 
> 1) check_move_unevictable_pages() aimed retry logic and put pages back
>    into correct lru.

I think we'd need more than just the old retry.

> 2) check_move_unevictable_pages() unconditionally move the pages into
>    evictable lru, and vmacan put them back into correct lru later.

That's a good thought: these are all pages which we allowed to be found
Unevictable lazily in the first place, so why should be so anxious to
assign them right now.  Ah, but if they are still unevictable, then it's
because they're Mlocked, and we do make much more effort to account the
Mlocked pages right.  We'd probably best keep on trying.

> 3) To protect PG_mlock operation by lru lock.

Surely not if we can avoid it.  Certainly not to bolster my cleanup.

> 
> other parts looks fine to me.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
