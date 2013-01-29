Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 94B8C6B002D
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 05:40:07 -0500 (EST)
Date: Tue, 29 Jan 2013 11:40:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: simplify lock of memcg page stat accounting
Message-ID: <20130129103940.GA29574@dhcp22.suse.cz>
References: <1359198756-3752-1-git-send-email-handai.szj@taobao.com>
 <51071AA1.7000207@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51071AA1.7000207@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Sha Zhengju <handai.szj@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, gthelen@google.com, hannes@cmpxchg.org, hughd@google.com, Sha Zhengju <handai.szj@taobao.com>

On Tue 29-01-13 09:41:05, KAMEZAWA Hiroyuki wrote:
> (2013/01/26 20:12), Sha Zhengju wrote:
[...]
> > So in order to make the lock simpler and clearer and also avoid the 'nesting'
> > problem, a choice may be:
> > (CPU-A does "page stat accounting" and CPU-B does "move")
> > 
> >         CPU-A                        CPU-B
> > 
> > move_lock_mem_cgroup()
> > memcg = pc->mem_cgroup
> > TestSetPageDirty(page)
> > move_unlock_mem_cgroup()
> >                               move_lock_mem_cgroup()
> >                               if (PageDirty) {
> >                                    old_memcg->nr_dirty --;
> >                                    new_memcg->nr_dirty ++;
> >                               }
> >                               pc->mem_cgroup = new_memcg
> >                               move_unlock_mem_cgroup()
> > 
> > memcg->nr_dirty ++
> > 
> 
> Hmm. no race with file truncate ?

Shouldn't pte lock protect us in page_{add_file,remove}_rmap?

[...]
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 59b0dca..0d74c48 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1112,13 +1112,25 @@ void page_add_file_rmap(struct page *page)
> >   {
> >   	bool locked;
> >   	unsigned long flags;
> > +	bool ret;
> > +	struct mem_cgroup *memcg = NULL;
> > +	struct cgroup_subsys_state *css = NULL;
> >   
> >   	mem_cgroup_begin_update_page_stat(page, &locked, &flags);
> > -	if (atomic_inc_and_test(&page->_mapcount)) {
> > +	memcg = try_get_mem_cgroup_from_page(page);
> 
> Toooooo heavy ! I can say NACK to this patch only because of this try_get().

Agreed.

> To hold memcg alive, rcu_read_lock() will work (as current code does).
> 
> BTW, does this patch fixes the nested-lock problem ?

Because set_page_drity is called outside of mem_cgroup_{begin,end}_update_page_stat.
That confused me too.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
