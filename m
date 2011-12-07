Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 9E3466B0099
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 01:31:11 -0500 (EST)
Received: by iahk25 with SMTP id k25so531862iah.14
        for <linux-mm@kvack.org>; Tue, 06 Dec 2011 22:31:11 -0800 (PST)
Date: Tue, 6 Dec 2011 22:30:37 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
In-Reply-To: <20111207104800.d1851f78.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LSU.2.00.1112062139300.1260@sister.anvils>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com> <20111202120849.GA1295@cmpxchg.org> <20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1112051552210.3938@sister.anvils> <20111206095825.69426eb2.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.LSU.2.00.1112052258510.28015@sister.anvils> <20111206192101.8ea75558.kamezawa.hiroyu@jp.fujitsu.com> <alpine.LSU.2.00.1112061506360.2111@sister.anvils> <20111207104800.d1851f78.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Wed, 7 Dec 2011, KAMEZAWA Hiroyuki wrote:
> On Tue, 6 Dec 2011 15:50:33 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> > On Tue, 6 Dec 2011, KAMEZAWA Hiroyuki wrote:
> > > 
> > > 	1. lock lru
> > > 	2. remove-page-from-lru
> > > 	3. overwrite pc->mem_cgroup
> > > 	4. add page to lru again
> > > 	5. unlock lru
> > 
> > That is indeed the sequence which __mem_cgroup_commit_charge() follows
> > after the patch.
> > 
> > But it optimizes out the majority of cases when no such lru operations
> > are needed (optimizations best presented in a separate patch), while
> > being careful about the tricky case when the page is on lru_add_pvecs,
> > and may get on to an lru at any moment.
> > 
> > And since it uses a separate lock for each memcg-zone's set of lrus,
> > must take care that both lock and lru in 4 and 5 are different from
> > those in 1 and 2.
> > 
> 
> yes, after per-zone-per-memcg lock, Above sequence should take some care.
> 
> With naive solution,
> 
> 	1. get lruvec-1 from target pc->mem_cgroup
> 	2. get lruvec-2 from target memcg to be charged.
> 	3. lock lruvec-x lock
> 	4. lock lruvec-y lock   (x and y order is determined by css_id ?)
> 	5. remove from LRU.
> 	6. overwrite pc->mem_cgroup
> 	7. add page to lru again
> 	8. unlock lruvec-y
> 	9. unlokc lruvec-x
> 
> Hm, maybe there are another clever way..

Our commit_charge does lock page_cgroup, lock old lru_lock, remove from
old lru, update pc->mem_cgroup, unlock old lru_lock, lock new lru_lock,
add to new lru, unlock page_cgroup.  That's complemented by the way
lock_page_lru_irqsave locks lru_lock and then checks if the lru_lock
it got still matches pc->mem_cgroup, retrying if not.

> > > 
> > > isn't it ? I posted a series of patch. I'm glad if you give me a
> > > quick review.
> > 
> > I haven't glanced yet, will do so after an hour or two.
> > 
> 
> I think Johannes's chages of removing page_cgroup->lru allows us
> various chances of optimization/simplification.

Yes, I like Johannes's changes very much, they do indeed open the
way to a lot of simplification and unification.

I have now taken a quickish look at your patches, and tried running
with them.  They look plausible and elegant.  In some places they do
the same as we have done, in others somewhat the opposite.

You tend to rely on knowing when file, anon, shmem and swap pages
are charged, making simplifications based upon SwapCache or not;
whereas I was more ignorant and more general.  Each approach has
its own merit.

Your lrucare nests page_cgroup lock inside lru_lock, and handles the
page on pagevec case very easily that way; whereas we nest lru_lock
inside page_cgroup lock.  I think your way is fine for now, but that
we shall have to reverse it for per-memcg-zone lru locking.

I am so used to thinking in terms of per-memcg-zone lru locking, that
it's hard for me to remember the easier constraints in your case.
We have to treat pc->mem_cgroup more carefully than you do, because
of it telling where the lock is.

I'm not sure whether you're safe to be leaving stale pc->mem_cgroup
behind, potentially after that memcg has been deleted.  We would not
be safe that way (particularly when lumpy reclaim and compaction
come into play), but perhaps you're okay if you've caught everywhere
that needs mem_cgroup_reset_owner.  Or perhaps not.

I did get one crash when shutting down, stack somewhere in khugepaged:
I didn't take much notice because I thought it would easily happen
again, but actually not the next time.  I expect that would have been
from a stale or null pc->mem_cgroup.

It was amusing to see you inserting "mem_cgroup_reset_owner" calls in
read_swap_cache_async and ksm_does_need_to_copy: yes, that's exactly
where we put some of our "mem_cgroup_reset_page" calls, though last
weekend I reworked the patch to avoid the need for them.

I'll mull over your approach, and try it on other machines overnight.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
