Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 19A4F8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:08:23 -0400 (EDT)
Received: by iwg8 with SMTP id 8so300509iwg.14
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 07:08:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTimMLieDT2dePRvtUFDvasz1rk=ZgTdeei0BL9P5@mail.gmail.com>
References: <20110328093957.089007035@suse.cz> <20110328200332.17fb4b78.kamezawa.hiroyu@jp.fujitsu.com>
 <20110328114430.GE5693@tiehlicka.suse.cz> <20110329090924.6a565ef3.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329073232.GB30671@tiehlicka.suse.cz> <20110329165117.179d87f9.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329085942.GD30671@tiehlicka.suse.cz> <20110329184119.219f7d7b.kamezawa.hiroyu@jp.fujitsu.com>
 <20110329111858.GF30671@tiehlicka.suse.cz> <AANLkTi=1WA-oF1kraTMMcSgwqvaXqrEiROVGeDfejO45@mail.gmail.com>
 <20110329134223.GB3361@tiehlicka.suse.cz> <AANLkTimMLieDT2dePRvtUFDvasz1rk=ZgTdeei0BL9P5@mail.gmail.com>
From: Zhu Yanhai <zhu.yanhai@gmail.com>
Date: Tue, 29 Mar 2011 22:08:00 +0800
Message-ID: <AANLkTikk97yR9j4iOHz=Ye0evhnAQkTodL+Df9E-+VeM@mail.gmail.com>
Subject: Re: [RFC 0/3] Implementation of cgroup isolation
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

2011/3/29 Zhu Yanhai <zhu.yanhai@gmail.com>:
> Hi,
>
> 2011/3/29 Michal Hocko <mhocko@suse.cz>:
>> Isn't this an overhead that would slow the whole thing down. Consider
>> that you would need to lookup page_cgroup for every page and touch
>> mem_cgroup to get the limit.
>
> Current almost has did such things, say the direct reclaim path:
> shrink_inactive_list()
> =C2=A0 ->isolate_pages_global()
> =C2=A0 =C2=A0 =C2=A0->isolate_lru_pages()
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 ->mem_cgroup_del_lru(for each page it wants t=
o isolate)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0and in mem_cgroup_del_lru() we h=
ave:
oops, the below code is from mem_cgroup_rotate_lru_list not
mem_cgroup_del_lru, the correct one should be:
[code]
pc =3D lookup_page_cgroup(page);
	/* can happen while we handle swapcache. */
	if (!TestClearPageCgroupAcctLRU(pc))
		return;
	VM_BUG_ON(!pc->mem_cgroup);
	/*
	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
	 * removed from global LRU.
	 */
	mz =3D page_cgroup_zoneinfo(pc);
	MEM_CGROUP_ZSTAT(mz, lru) -=3D 1;
	if (mem_cgroup_is_root(pc->mem_cgroup))
		return;
[/code]
Anyway, the point still stands.

-zyh
> [code]
> =C2=A0 =C2=A0 =C2=A0 =C2=A0pc =3D lookup_page_cgroup(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * Used bit is set without atomic ops but afte=
r smp_wmb().
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * For making pc->mem_cgroup visible, insert s=
mp_rmb() here.
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0smp_rmb();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* unused or root page is not rotated. */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!PageCgroupUsed(pc) || mem_cgroup_is_root(=
pc->mem_cgroup))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return;
> [/code]
> By calling mem_cgroup_is_root(pc->mem_cgroup) we already brought the
> struct mem_cgroup into cache.
> So probably things won't get worse at least.
>
> Thanks,
> Zhu Yanhai
>
>> The point of the isolation is to not touch the global reclaim path at
>> all.
>>
>>> 3) shrink the cgroups who have set a reserve_limit, and leave them with=
 only
>>> the reserve_limit bytes they need. if nr_reclaimed is meet, goto finish=
.
>>> 4) OOM
>>>
>>> Does it make sense?
>>
>> It sounds like a good thing - in that regard it is more generic than
>> a simple flag - but I am afraid that the implementation wouldn't be
>> that easy to preserve the performance and keep the balance between
>> groups. But maybe it can be done without too much cost.
>>
>> Thanks
>> --
>> Michal Hocko
>> SUSE Labs
>> SUSE LINUX s.r.o.
>> Lihovarska 1060/12
>> 190 00 Praha 9
>> Czech Republic
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
