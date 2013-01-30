Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id A7EA36B0005
	for <linux-mm@kvack.org>; Wed, 30 Jan 2013 04:12:33 -0500 (EST)
Date: Wed, 30 Jan 2013 10:12:29 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: simplify lock of memcg page stat accounting
Message-ID: <20130130091229.GA16098@dhcp22.suse.cz>
References: <1359198756-3752-1-git-send-email-handai.szj@taobao.com>
 <51071AA1.7000207@jp.fujitsu.com>
 <CAFj3OHXyWN+zUMAaSEOz2gCP7Bm6v4Zex=Rq=7A9CkHTp3j1UQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFj3OHXyWN+zUMAaSEOz2gCP7Bm6v4Zex=Rq=7A9CkHTp3j1UQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com, hannes@cmpxchg.org, hughd@google.com, Sha Zhengju <handai.szj@taobao.com>

On Tue 29-01-13 23:29:35, Sha Zhengju wrote:
> On Tue, Jan 29, 2013 at 8:41 AM, Kamezawa Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > (2013/01/26 20:12), Sha Zhengju wrote:
> >> From: Sha Zhengju <handai.szj@taobao.com>
> >>
> >> After removing duplicated information like PCG_*
> >> flags in 'struct page_cgroup'(commit 2ff76f1193), there's a problem
> >> between "move" and "page stat accounting"(only FILE_MAPPED is supported
> >> now but other stats will be added in future):
> >> assume CPU-A does "page stat accounting" and CPU-B does "move"
> >>
> >> CPU-A                        CPU-B
> >> TestSet PG_dirty
> >> (delay)               move_lock_mem_cgroup()
> >>                          if (PageDirty(page)) {
> >>                               old_memcg->nr_dirty --
> >>                               new_memcg->nr_dirty++
> >>                          }
> >>                          pc->mem_cgroup = new_memcg;
> >>                          move_unlock_mem_cgroup()
> >>
> >> move_lock_mem_cgroup()
> >> memcg = pc->mem_cgroup
> >> memcg->nr_dirty++
> >> move_unlock_mem_cgroup()
> >>
> >> while accounting information of new_memcg may be double-counted. So we
> >> use a bigger lock to solve this problem:  (commit: 89c06bd52f)
> >>
> >>        move_lock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
> >>        TestSetPageDirty(page)
> >>        update page stats (without any checks)
> >>        move_unlock_mem_cgroup() <-- mem_cgroup_begin_update_page_stat()
> >>
> >>
> >> But this method also has its pros and cons: at present we use two layers
> >> of lock avoidance(memcg_moving and memcg->moving_account) then spinlock
> >> on memcg (see mem_cgroup_begin_update_page_stat()), but the lock granularity
> >> is a little bigger that not only the critical section but also some code
> >> logic is in the range of locking which may be deadlock prone. As dirty
> >> writeack stats are added, it gets into further difficulty with the page
> >> cache radix tree lock and it seems that the lock requires nesting.
> >> (https://lkml.org/lkml/2013/1/2/48)
> >>
> >> So in order to make the lock simpler and clearer and also avoid the 'nesting'
> >> problem, a choice may be:
> >> (CPU-A does "page stat accounting" and CPU-B does "move")
> >>
> >>         CPU-A                        CPU-B
> >>
> >> move_lock_mem_cgroup()
> >> memcg = pc->mem_cgroup
> >> TestSetPageDirty(page)
> >> move_unlock_mem_cgroup()
> >>                               move_lock_mem_cgroup()
> >>                               if (PageDirty) {
> >>                                    old_memcg->nr_dirty --;
> >>                                    new_memcg->nr_dirty ++;
> >>                               }
> >>                               pc->mem_cgroup = new_memcg
> >>                               move_unlock_mem_cgroup()
> >>
> >> memcg->nr_dirty ++
> >>
> >
> > Hmm. no race with file truncate ?
> >
> 
> Do you mean "dirty page accounting" racing with truncate?  Yes, if
> another one do truncate and set page->mapping=NULL just before CPU-A's
> 'memcg->nr_dirty ++', then it'll have no change to correct the figure
> back. So my rough idea now is to have some small changes to
> __set_page_dirty/__set_page_dirty_nobuffers that do SetDirtyPage
> inside ->tree_lock.
> 
> But, in current codes, is there any chance that
> mem_cgroup_move_account() racing with truncate that PageAnon is
> false(since page->mapping is cleared) but later in page_remove_rmap()
> the new memcg stats is over decrement...?

We are not checking page->mapping but rather page_mapped() which
checks page->_mapcount and that is protected from races with
mem_cgroup_move_account by mem_cgroup_begin_update_page_stat locking.
Makes sense?

> Call me silly...but I really get dizzy by those locks now, need to
> have a run to refresh my head... : (

Yeah, that part is funny for a certain reading of the word funny ;)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
