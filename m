Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA6318D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 03:42:35 -0400 (EDT)
Date: Wed, 30 Mar 2011 09:42:31 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Message-ID: <20110330074231.GB15394@tiehlicka.suse.cz>
References: <20110328114430.GE5693@tiehlicka.suse.cz>
 <20110329090924.6a565ef3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329073232.GB30671@tiehlicka.suse.cz>
 <20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329085942.GD30671@tiehlicka.suse.cz>
 <20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329111858.GF30671@tiehlicka.suse.cz>
 <AANLkTi=1WA-oF1kraTMMcSgwqvaXqrEiROVGeDfejO45@mail.gmail.com>
 <20110329134223.GB3361@tiehlicka.suse.cz>
 <AANLkTimMLieDT2dePRvtUFDvasz1rk=ZgTdeei0BL9P5@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimMLieDT2dePRvtUFDvasz1rk=ZgTdeei0BL9P5@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhu Yanhai <zhu.yanhai@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 29-03-11 22:02:23, Zhu Yanhai wrote:
> Hi,
> 
> 2011/3/29 Michal Hocko <mhocko@suse.cz>:
> > Isn't this an overhead that would slow the whole thing down. Consider
> > that you would need to lookup page_cgroup for every page and touch
> > mem_cgroup to get the limit.
> 
> Current almost has did such things, say the direct reclaim path:
> shrink_inactive_list()
>    ->isolate_pages_global()
>       ->isolate_lru_pages()
>          ->mem_cgroup_del_lru(for each page it wants to isolate)
>             and in mem_cgroup_del_lru() we have:
> [code]
> 	pc = lookup_page_cgroup(page);
> 	/*
> 	 * Used bit is set without atomic ops but after smp_wmb().
> 	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
> 	 */
> 	smp_rmb();
> 	/* unused or root page is not rotated. */
> 	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
> 		return;
> [/code]
> By calling mem_cgroup_is_root(pc->mem_cgroup) we already brought the
> struct mem_cgroup into cache.
> So probably things won't get worse at least.

But we would still have to isolate and put back a lot of pages
potentially. If we do not have those pages on the list we will skip them
automatically.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
