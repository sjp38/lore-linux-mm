Subject: Re: Race condition between putback_lru_page and
	mem_cgroup_move_list
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <28c262360808040736u7f364fc0p28d7ceea7303a626@mail.gmail.com>
References: <28c262360808040736u7f364fc0p28d7ceea7303a626@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Date: Mon, 04 Aug 2008 11:31:10 -0400
Message-Id: <1217863870.7065.62.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MinChan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2008-08-04 at 23:36 +0900, MinChan Kim wrote:
> I think this is a race condition if mem_cgroup_move_lists's comment isn't right.
> I am not sure that it was already known problem.
> 
> mem_cgroup_move_lists assume the appropriate zone's lru lock is already held.
> but putback_lru_page calls mem_cgroup_move_lists without holding lru_lock.
> 

Hmmm, the comment on mem_cgroup_move_lists() does say this.  Although,
reading thru' the code, I can't see why it requires this.  But then it's
Monday, here...


> Repeatedly, spin_[un/lock]_irq use in mem_cgroup_move_list have a big overhead
> while doing list iteration.
> 
> Do we have to use pagevec ?

This shouldn't be necessary, IMO.  putback_lru_page() is used as
follows:

1) in vmscan.c [shrink_*_list()] when an unevictable page is
encountered.  This should be relatively rare.  Once vmscan sees an
unevictable page, it parks it on the unevictable lru list where it
[vmscan] won't see the page again until it becomes reclaimable.

2) as a replacement for move_to_lru() in page migration as the inverse
to isolate_lru_page().  We did this to catch patches that became
unevictable or, more importantly, evictable while page migration held
them isolated.  move_to_lru() already grabbed and released the zone lru
lock on each page migrated.

3) In m[un]lock_vma_page() and clear_page_mlock(), new with in the
"mlocked pages are unevictable" series.  This one can result in a storm
of zone lru traffic--e.g., mlock()ing or munlocking() a large segment or
mlockall() of a task with a lot of mapped address space.  Again, this is
probably a very rare event--unless you're stressing [stressing over?]
mlock(), as I've been doing :)--and often involves a major fault [page
allocation], per page anyway.

Ii>>? originally did have a pagevec for the unevictable lru but it
complicated ensuring that we don't strand evictable pages on the
unevictable list.  See the retry logic in putback_lru_page().

As for the !UNEVICTABLE_LRU version, the only place this should be
called is from page migration as none of the other call sites are
compiled in or reachable when !UNEVICTABLE_LRU.

Thoughts?

Lee
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
