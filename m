Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id EB3666B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 00:16:29 -0500 (EST)
Received: by obbta7 with SMTP id ta7so6631144obb.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 21:16:29 -0800 (PST)
Date: Wed, 18 Jan 2012 21:16:09 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG] kernel BUG at mm/memcontrol.c:1074!
In-Reply-To: <20120119130353.0ca97435.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1201182100010.2830@eggly.anvils>
References: <1326949826.5016.5.camel@lappy> <20120119122354.66eb9820.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1201181932040.2287@eggly.anvils> <20120119130353.0ca97435.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, hannes <hannes@cmpxchg.org>, mhocko@suse.cz, bsingharora@gmail.com, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Jan 2012, KAMEZAWA Hiroyuki wrote:
> On Wed, 18 Jan 2012 19:41:44 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> > 
> > I notice that, unlike Linus's git, this linux-next still has
> > mm-isolate-pages-for-immediate-reclaim-on-their-own-lru.patch in.
> > 
> > I think that was well capable of oopsing in mem_cgroup_lru_del_list(),
> > since it didn't always know which lru a page belongs to.
> > 
> > I'm going to be optimistic and assume that was the cause.
> > 
> Hmm, because the log hits !memcg at lru "del", the page should be added
> to LRU somewhere and the lru must be determined by pc->mem_cgroup.
> 
> Once set, pc->mem_cgroup is not cleared, just overwritten. AFAIK, there is
> only one chance to set pc->mem_cgroup as NULL... initalization.
> I wonder why it hits lru_del() rather than lru_add()...
> ................
> 
> Ahhhh, ok, it seems you are right. the patch has following kinds of codes
> ==
> +static void pagevec_putback_immediate_fn(struct page *page, void *arg)
> +{
> +       struct zone *zone = page_zone(page);
> +
> +       if (PageLRU(page)) {
> +               enum lru_list lru = page_lru(page);
> +               list_move(&page->lru, &zone->lru[lru].list);
> +       }
> +}
> ==
> ..this will bypass mem_cgroup_lru_add(), and we can see bug in lru_del()
> rather than lru_add()..

I've not thought it through in detail (and your questioning reminds me
that the worst I saw from that patch was updating of the wrong counts,
leading to underflow, then livelock from the mismatch between empty list
and enormous count: I never saw an oops from it, and may be mistaken).

> 
> Another question is who pushes pages to LRU before setting pc->mem_cgroup..
> Anyway, I think we need to fix memcg to be LRU_IMMEDIATE aware.

I don't think so: Mel agreed that the patch could not go forward as is,
without an additional pageflag, and asked Andrew to drop it from mmotm
in mail on 29th December (I didn't notice an mm-commits message to say
akpm did drop it, and marc is blacked out in protest for today, so I
cannot check: but certainly akpm left it out of his push to Linus).

Oh, and Mel noticed another bug in it on the 30th, that the PageLRU
check in the function you quote above is wrong: see PATCH 11/11 thread.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
