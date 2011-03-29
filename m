Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F1DBB8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:02:46 -0400 (EDT)
Received: by iyf13 with SMTP id 13so299231iyf.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 07:02:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329134223.GB3361@tiehlicka.suse.cz>
References: <20110328093957.089007035@suse.cz> <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328114430.GE5693@tiehlicka.suse.cz> <20110329090924.6a565ef3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329073232.GB30671@tiehlicka.suse.cz> <20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329085942.GD30671@tiehlicka.suse.cz> <20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329111858.GF30671@tiehlicka.suse.cz> <AANLkTi=1WA-oF1kraTMMcSgwqvaXqrEiROVGeDfejO45@mail.gmail.com>
 <20110329134223.GB3361@tiehlicka.suse.cz>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Tue, 29 Mar 2011 22:02:23 +0800
Message-ID: <AANLkTimMLieDT2dePRvtUFDvasz1rk=ZgTdeei0BL9P5@mail.gmail.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

2011/3/29 Michal Hocko <mhocko@suse.cz>:
> Isn't this an overhead that would slow the whole thing down. Consider
> that you would need to lookup page_cgroup for every page and touch
> mem_cgroup to get the limit.

Current almost has did such things, say the direct reclaim path:
shrink_inactive_list()
   ->isolate_pages_global()
      ->isolate_lru_pages()
         ->mem_cgroup_del_lru(for each page it wants to isolate)
            and in mem_cgroup_del_lru() we have:
[code]
	pc = lookup_page_cgroup(page);
	/*
	 * Used bit is set without atomic ops but after smp_wmb().
	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
	 */
	smp_rmb();
	/* unused or root page is not rotated. */
	if (!PageCgroupUsed(pc) || mem_cgroup_is_root(pc->mem_cgroup))
		return;
[/code]
By calling mem_cgroup_is_root(pc->mem_cgroup) we already brought the
struct mem_cgroup into cache.
So probably things won't get worse at least.

Thanks,
Zhu Yanhai

> The point of the isolation is to not touch the global reclaim path at
> all.
>
>> 3) shrink the cgroups who have set a reserve_limit, and leave them with only
>> the reserve_limit bytes they need. if nr_reclaimed is meet, goto finish.
>> 4) OOM
>>
>> Does it make sense?
>
> It sounds like a good thing - in that regard it is more generic than
> a simple flag - but I am afraid that the implementation wouldn't be
> that easy to preserve the performance and keep the balance between
> groups. But maybe it can be done without too much cost.
>
> Thanks
> --
> Michal Hocko
> SUSE Labs
> SUSE LINUX s.r.o.
> Lihovarska 1060/12
> 190 00 Praha 9
> Czech Republic
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
