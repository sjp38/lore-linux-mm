Subject: Re: [PATCH][RFC] dirty balancing for cgroups
In-Reply-To: Your message of "Thu, 07 Aug 2008 15:36:08 +0200"
	<1218116168.8625.38.camel@twins>
References: <1218116168.8625.38.camel@twins>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080813071505.930965A75@siro.lan>
Date: Wed, 13 Aug 2008 16:15:05 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, menage@google.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

hi,

> > @@ -485,7 +502,10 @@ unsigned long mem_cgroup_isolate_pages(unsigned long nr_to_scan,
> >  		if (PageUnevictable(page) ||
> >  		    (PageActive(page) && !active) ||
> >  		    (!PageActive(page) && active)) {
> > -			__mem_cgroup_move_lists(pc, page_lru(page));
> > +			if (try_lock_page_cgroup(page)) {
> > +				__mem_cgroup_move_lists(pc, page_lru(page));
> > +				unlock_page_cgroup(page);
> > +			}
> >  			continue;
> >  		}
> 
> This chunk seems unrelated and lost....

it's necessary to protect from mem_cgroup_{set,clear}_dirty
which modify pc->flags without holding mz->lru_lock.

> I presonally dislike the != 0, == 0 comparisons for bitmask operations,
> they seem to make it harder to read somewhow. I prefer to write !(flags
> & mask) and (flags & mask), instead.
> 
> I guess taste differs,...

yes, it seems different. :)

YAMAMOTO Takashi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
