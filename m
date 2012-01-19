Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id CEE2F6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 02:01:17 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 64AB93EE0C5
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:01:16 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4407845DE59
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:01:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2135E45DE56
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:01:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0DF771DB8052
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:01:16 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id AEB951DB8042
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 16:01:15 +0900 (JST)
Date: Thu, 19 Jan 2012 15:59:54 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] kernel BUG at mm/memcontrol.c:1074!
Message-Id: <20120119155954.f95b25b0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119142934.40f22386.kamezawa.hiroyu@jp.fujitsu.com>
References: <1326949826.5016.5.camel@lappy>
	<20120119122354.66eb9820.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1201181932040.2287@eggly.anvils>
	<20120119130353.0ca97435.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1201182100010.2830@eggly.anvils>
	<20120119142934.40f22386.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, hannes <hannes@cmpxchg.org>, mhocko@suse.cz, bsingharora@gmail.com, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, 19 Jan 2012 14:29:34 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Wed, 18 Jan 2012 21:16:09 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > On Thu, 19 Jan 2012, KAMEZAWA Hiroyuki wrote:
> > > On Wed, 18 Jan 2012 19:41:44 -0800 (PST)
> > > Hugh Dickins <hughd@google.com> wrote:
> > > > 
> > > > I notice that, unlike Linus's git, this linux-next still has
> > > > mm-isolate-pages-for-immediate-reclaim-on-their-own-lru.patch in.
> > > > 
> > > > I think that was well capable of oopsing in mem_cgroup_lru_del_list(),
> > > > since it didn't always know which lru a page belongs to.
> > > > 
> > > > I'm going to be optimistic and assume that was the cause.
> > > > 
> > > Hmm, because the log hits !memcg at lru "del", the page should be added
> > > to LRU somewhere and the lru must be determined by pc->mem_cgroup.
> > > 
> > > Once set, pc->mem_cgroup is not cleared, just overwritten. AFAIK, there is
> > > only one chance to set pc->mem_cgroup as NULL... initalization.
> > > I wonder why it hits lru_del() rather than lru_add()...
> > > ................
> > > 
> > > Ahhhh, ok, it seems you are right. the patch has following kinds of codes
> > > ==
> > > +static void pagevec_putback_immediate_fn(struct page *page, void *arg)
> > > +{
> > > +       struct zone *zone = page_zone(page);
> > > +
> > > +       if (PageLRU(page)) {
> > > +               enum lru_list lru = page_lru(page);
> > > +               list_move(&page->lru, &zone->lru[lru].list);
> > > +       }
> > > +}
> > > ==
> > > ..this will bypass mem_cgroup_lru_add(), and we can see bug in lru_del()
> > > rather than lru_add()..
> > 
> > I've not thought it through in detail (and your questioning reminds me
> > that the worst I saw from that patch was updating of the wrong counts,
> > leading to underflow, then livelock from the mismatch between empty list
> > and enormous count: I never saw an oops from it, and may be mistaken).
> > 
> > > 
> > > Another question is who pushes pages to LRU before setting pc->mem_cgroup..
> > > Anyway, I think we need to fix memcg to be LRU_IMMEDIATE aware.
> > 
> > I don't think so: Mel agreed that the patch could not go forward as is,
> > without an additional pageflag, and asked Andrew to drop it from mmotm
> > in mail on 29th December (I didn't notice an mm-commits message to say
> > akpm did drop it, and marc is blacked out in protest for today, so I
> > cannot check: but certainly akpm left it out of his push to Linus).
> > 
> > Oh, and Mel noticed another bug in it on the 30th, that the PageLRU
> > check in the function you quote above is wrong: see PATCH 11/11 thread.
> 
> Sure.
> 
> Hm, what I need to find is a path which adds page to LRU bypassing memcg's check...
> 
Sorry, I misunderstand the problem at all.
Now, I think reverting the patch will help this case.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
