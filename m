Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id AC7036B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 18:57:00 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C8C4D3EE0BD
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:56:58 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AA93A45DE54
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:56:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 82D5C45DE50
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:56:58 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 74D0C1DB802F
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:56:58 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1C3F41DB803B
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 08:56:58 +0900 (JST)
Date: Fri, 20 Jan 2012 08:55:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: remove PCG_CACHE page_cgroup flag
Message-Id: <20120120085542.8056b4d3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120119133035.GO24386@cmpxchg.org>
References: <20120119181711.8d697a6b.kamezawa.hiroyu@jp.fujitsu.com>
	<20120119133035.GO24386@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>

On Thu, 19 Jan 2012 14:30:35 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Thu, Jan 19, 2012 at 06:17:11PM +0900, KAMEZAWA Hiroyuki wrote:
> > @@ -4,7 +4,6 @@
> >  enum {
> >  	/* flags for mem_cgroup */
> >  	PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
> > -	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> >  	PCG_MIGRATION, /* under page migration */
> >  	/* flags for mem_cgroup and file and I/O status */
> 
> Me gusta.
> 
> > @@ -606,11 +606,16 @@ static unsigned long mem_cgroup_read_events(struct mem_cgroup *memcg,
> >  }
> >  
> >  static void mem_cgroup_charge_statistics(struct mem_cgroup *memcg,
> > -					 bool file, int nr_pages)
> > +					 bool not_rss, int nr_pages)
> >  {
> >  	preempt_disable();
> >  
> > -	if (file)
> > +	/*
> > +	 * Here, RSS means 'mapped anon' and anon's SwapCache. Unlike LRU,
> > +	 * Shmem is not included to Anon. It' counted as 'file cache'
> > +	 * which tends to be shared between memcgs.
> > +	 */
> > +	if (not_rss)
> 
> Could you invert that boolean and call it "anon"?
> 

Sure. I wondered whta name is good other than 'file'.


> > @@ -2343,6 +2348,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
> >  				       struct page_cgroup *pc,
> >  				       enum charge_type ctype)
> >  {
> > +	bool not_rss;
> > +
> >  	lock_page_cgroup(pc);
> >  	if (unlikely(PageCgroupUsed(pc))) {
> >  		unlock_page_cgroup(pc);
> > @@ -2362,21 +2369,15 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
> >  	 * See mem_cgroup_add_lru_list(), etc.
> >   	 */
> >  	smp_wmb();
> > -	switch (ctype) {
> > -	case MEM_CGROUP_CHARGE_TYPE_CACHE:
> > -	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
> > -		SetPageCgroupCache(pc);
> > -		SetPageCgroupUsed(pc);
> > -		break;
> > -	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> > -		ClearPageCgroupCache(pc);
> > -		SetPageCgroupUsed(pc);
> > -		break;
> > -	default:
> > -		break;
> > -	}
> >  
> > -	mem_cgroup_charge_statistics(memcg, PageCgroupCache(pc), nr_pages);
> > +	SetPageCgroupUsed(pc);
> > +	if ((ctype == MEM_CGROUP_CHARGE_TYPE_CACHE) ||
> > +	    (ctype == MEM_CGROUP_CHARGE_TYPE_SHMEM))
> > +		not_rss = true;
> > +	else
> > +		not_rss = false;
> > +
> > +	mem_cgroup_charge_statistics(memcg, not_rss, nr_pages);
> 
> 	mem_cgroup_charge_statistics(memcg,
> 				     ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED,
> 				     nr_pages);
> 
> and save even more lines, without sacrificing clarity! :)
> 
> > @@ -2908,9 +2915,15 @@ void mem_cgroup_uncharge_page(struct page *page)
> >  
> >  void mem_cgroup_uncharge_cache_page(struct page *page)
> >  {
> > +	int ctype;
> > +
> >  	VM_BUG_ON(page_mapped(page));
> >  	VM_BUG_ON(page->mapping);
> > -	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
> > +	if (page_is_file_cache(page))
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_CACHE;
> > +	else
> > +		ctype = MEM_CGROUP_CHARGE_TYPE_SHMEM;
> > +	__mem_cgroup_uncharge_common(page, ctype);
> 
> Looks like an unrelated bugfix on one hand, but on the other hand we
> do not differentiate cache from shmem anywhere, afaik, and you do not
> introduce anything that does.  Could you just leave this out?
> 

Ok. I'll remove.
I inserted this just for clarifying what we do.
will post v3.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
