Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id BBF076B0074
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 20:49:10 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1A86E3EE0AE
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:49:08 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D66FE45DEB3
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:49:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BC1A645DEA6
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:49:07 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF4621DB8042
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:49:07 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 56DFD1DB8040
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 10:49:07 +0900 (JST)
Date: Wed, 7 Dec 2011 10:48:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
Message-Id: <20111207104800.d1851f78.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112061506360.2111@sister.anvils>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20111202120849.GA1295@cmpxchg.org>
	<20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112051552210.3938@sister.anvils>
	<20111206095825.69426eb2.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112052258510.28015@sister.anvils>
	<20111206192101.8ea75558.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112061506360.2111@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 6 Dec 2011 15:50:33 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Tue, 6 Dec 2011, KAMEZAWA Hiroyuki wrote:
> > On Mon, 5 Dec 2011 23:36:34 -0800 (PST)
> > Hugh Dickins <hughd@google.com> wrote:
> > 
> > Hmm, at first glance at the patch, it seems far complicated than
> > I expected
> 
> Right, this is just a rollup of assorted changes,
> yet to be presented properly as an understandable series.
> 
> > and added much checks and hooks to lru path...
> 
> Actually, I think it removes more than it adds; while trying not
> to increase the overhead of lookup_page_cgroup()s and locking.
> 
> > > Okay, here it is: my usual mix of cleanup and functional changes.
> > > There's work by Ying and others in here - will apportion authorship
> > > more fairly when splitting.  If you're looking through it at all,
> > > the place to start would be memcontrol.c's lock_page_lru_irqsave().
> > > 
> > 
> > Thank you. This seems inetersting patch. Hmm...what I think of now is..
> > In most case, pages are newly allocated and charged ,and then, added to LRU.
> > pc->mem_cgroup never changes while pages are on LRU.
> > 
> > I have a fix for corner cases as to do
> > 
> > 	1. lock lru
> > 	2. remove-page-from-lru
> > 	3. overwrite pc->mem_cgroup
> > 	4. add page to lru again
> > 	5. unlock lru
> 
> That is indeed the sequence which __mem_cgroup_commit_charge() follows
> after the patch.
> 
> But it optimizes out the majority of cases when no such lru operations
> are needed (optimizations best presented in a separate patch), while
> being careful about the tricky case when the page is on lru_add_pvecs,
> and may get on to an lru at any moment.
> 
> And since it uses a separate lock for each memcg-zone's set of lrus,
> must take care that both lock and lru in 4 and 5 are different from
> those in 1 and 2.
> 

yes, after per-zone-per-memcg lock, Above sequence should take some care.

With naive solution,

	1. get lruvec-1 from target pc->mem_cgroup
	2. get lruvec-2 from target memcg to be charged.
	3. lock lruvec-x lock
	4. lock lruvec-y lock   (x and y order is determined by css_id ?)
	5. remove from LRU.
	6. overwrite pc->mem_cgroup
	7. add page to lru again
	8. unlock lruvec-y
	9. unlokc lruvec-x

Hm, maybe there are another clever way..


> > 
> > And blindly believe pc->mem_cgroup regardless of PCG_USED bit at LRU handling.
> 
> That's right.  The difficulty comes when Used is cleared while
> the page is off lru, or page removed from lru while Used is clear:
> once lock is dropped, we have no hold on the memcg, and must move
> to root lru lest the old memcg get deleted.
> 
> The old Used + AcctLRU + pc->mem_cgroup puppetry used to achieve that
> quite cleverly; but in distributing zone lru_locks over memcgs, we went
> through a lot of crashes before we understood the subtlety of it; and
> in most places were just fighting the way it shifted underneath us.
> 
> Now mem_cgroup_move_uncharged_to_root() makes the move explicit,
> in just a few places.
> 
> > 
> > Hm, per-zone-per-memcg lru locking is much easier if
> >  - we igonore PCG_USED bit at lru handling
> 
> I may or may not agree with you, depending on what you mean!
> 
Ah, after my patch, 

	mem_cgroup_lru_add(zone, page) {
		pc = lookup_page_cgroup(page);
		memcg = pc->mem_cgroup;
		lruvec = lruvec(memcg, zone)
		update zone stat for memcg
	}
Then, no flag check at handling lru.

> >  - we never overwrite pc->mem_cgroup if the page is on LRU.
> 
> That's not the way I was thinking of it, but I think that's what we're doing.
> 
I do this by a new rule 

"If page may be on LRU at commit_charge, lru_lock should be held and PageLRU
 must be cleared."


> >  - if page may be added to LRU by pagevec etc.. while we overwrite
> >    pc->mem_cgroup, we always take lru_lock. This is our corner case.
> 
> Yes, the tricky case I mention above.
> 
> > 
> > isn't it ? I posted a series of patch. I'm glad if you give me a
> > quick review.
> 
> I haven't glanced yet, will do so after an hour or two.
> 

I think Johannes's chages of removing page_cgroup->lru allows us
various chances of optimization/simplification.

Thanks,
-Kame

 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
