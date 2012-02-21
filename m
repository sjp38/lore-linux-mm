Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 6B7556B004A
	for <linux-mm@kvack.org>; Tue, 21 Feb 2012 15:00:33 -0500 (EST)
Received: by dadv6 with SMTP id v6so8874616dad.14
        for <linux-mm@kvack.org>; Tue, 21 Feb 2012 12:00:32 -0800 (PST)
Date: Tue, 21 Feb 2012 12:00:08 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 6/10] mm/memcg: take care over pc->mem_cgroup
In-Reply-To: <4F433418.3010401@openvz.org>
Message-ID: <alpine.LSU.2.00.1202211140330.1858@eggly.anvils>
References: <alpine.LSU.2.00.1202201518560.23274@eggly.anvils> <alpine.LSU.2.00.1202201533260.23274@eggly.anvils> <4F433418.3010401@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, 21 Feb 2012, Konstantin Khlebnikov wrote:
> > 
> > Be particularly careful in compaction's isolate_migratepages() and
> > vmscan's lumpy handling in isolate_lru_pages(): those approach the
> > page by its physical location, and so can encounter pages which
> > would not be found by any logical lookup.  For those cases we have
> > to change __isolate_lru_page() slightly: it must leave ClearPageLRU
> > to the caller, because compaction and lumpy cannot safely interfere
> > with a page until they have first isolated it and then locked lruvec.
> 
> Yeah, this is most complicated part.

Yes, I found myself leaving this patch until last when commenting.

And was not entirely convinced by what I then said of move_account().
Indeed, I wondered if it might be improved and simplified by taking
lruvec locks itself, in the manner that commit_charge lrucare ends
up doing.

> I found one race here, see below.

Thank you!

> > @@ -386,10 +364,24 @@ static isolate_migrate_t isolate_migrate
> >                          continue;
> > 
> >                  page_relock_lruvec(page,&lruvec);
> 
> Here race with mem_cgroup_move_account() we hold lock for old lruvec,
> while move_account() recharge page and put page back into other lruvec.
> Thus we see PageLRU(), but below we isolate page from wrong lruvec.

I expect you'll prove right on that, but I'm going to think about it
more later.

> 
> In my patch-set this is fixed with __wait_lru_unlock() [ spin_unlock_wait() ]
> in mem_cgroup_move_account()

Right now, after finishing mail, I want to concentrate on getting your
series working under my swapping load.

It's possible that I screwed up rediffing it to my slightly later
base (though the only parts that appeared to need fixing up were as
expected, near update_isolated_counts and move_active_pages_to_lru);
but if so I'd expect that to show up differently.

At present, although it runs fine with cgroup_disable=memory, with memcg
two machines very soon hit that BUG at include/linux/mm_inline.h:41!
when the lru_size or pages_count wraps around; on another it hit that
precisely when I stopped the test.

In all cases it's in release_pages from free_pages_and_swap_cache from
tlb_flush_mmu from tlb_finish_mmu from exit_mmap from mmput from exit_mm
from do_exit (but different processes exiting).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
