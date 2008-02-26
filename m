Date: Tue, 26 Feb 2008 03:23:17 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 14/15] memcg: simplify force_empty and move_lists
In-Reply-To: <20080226104834.5bbd7f20.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0802260256320.14896@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
 <Pine.LNX.4.64.0802252349100.27067@blonde.site>
 <20080226104834.5bbd7f20.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 26 Feb 2008, KAMEZAWA Hiroyuki wrote:
> > +		get_page(page);
> How about this?
> > +		spin_unlock_irqrestore(&mz->lru_lock, flags);
> 		local_irq_save(flags):
> 		if (TestSetPageLocked(page)) {

I think you meant !TestSetPageLocked ;)

> 	> +		mem_cgroup_uncharge_page(page);
> 	> +		put_page(page);
> 	> +		if (--count <= 0) {
> 	> +			count = FORCE_UNCHARGE_BATCH;
> 	> +			cond_resched();
> 	>  		}
> 	> +		spin_lock_irqsave(&mz->lru_lock, flags);
> 			unlock_page(page);
> 		}
> 		local_irq_restore(flags);
> 
> page's lock bit guarantees 100% safe against page migration.
> (And most of other charging/uncharging callers.)

That simply doesn't solve any problem I've observed yet.  It appears
(so far!) that I can safely run for hours with 1-15/15, doing random
page migrations and force_empties concurrently (commenting out the
EBUSY check on mem->css.cgroup->count).

The problem with force_empty is that it leaves the pages it touched
in a state inconsistent with normality, not that it's racy while it's
touching them.

If your TestSetPageLocked actually solves some problem, we could add
that; though it'd be the first reference to PageLocked in that source
file, and you're adding a long busy loop there while a page is locked
(broken by cond_resched, but still burning cpu).  Hmm, on top of that,
add_to_page_cache puts the page on the mem_cgroup lru a few instants
before it does its SetPageLocked.  So I'd certainly want you to show
what you're solving with this before we should add it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
