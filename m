Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6757B6B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 07:23:07 -0500 (EST)
Received: by iwn40 with SMTP id 40so2581464iwn.14
        for <linux-mm@kvack.org>; Fri, 14 Jan 2011 04:23:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110114120931.GP23189@cmpxchg.org>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114190909.d396cdf4.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114120931.GP23189@cmpxchg.org>
Date: Fri, 14 Jan 2011 21:23:05 +0900
Message-ID: <AANLkTimRQ25xbCA4hFxsYfiO2Z7RJZUhJuhYei5Twy1N@mail.gmail.com>
Subject: Re: [PATCH 2/4] [BUGFIX] dont set USED bit on tail pages
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Thank you for review.

2011/1/14 Johannes Weiner <hannes@cmpxchg.org>:
> On Fri, Jan 14, 2011 at 07:09:09PM +0900, KAMEZAWA Hiroyuki wrote:
>> --- mmotm-0107.orig/mm/memcontrol.c
>> +++ mmotm-0107/mm/memcontrol.c
>
>> @@ -2154,6 +2139,23 @@ static void __mem_cgroup_commit_charge(s
>> =A0 =A0 =A0 =A0*/
>> =A0 =A0 =A0 memcg_check_events(mem, pc->page);
>> =A0}
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +/*
>> + * Because tail pages are not mared as "used", set it. We're under
>
> marked
>
will fix.

>> + * compund_lock and don't need to take care of races.
>> + * Statistics are updated properly at charging. We just mark Used bits.
>> + */
>> +void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail)
>> +{
>> + =A0 =A0 struct page_cgroup *hpc =3D lookup_page_cgroup(head);
>> + =A0 =A0 struct page_cgroup *tpc =3D lookup_page_cgroup(tail);
>
> I have trouble reading the code fluently with those names as they are
> just very similar random letter sequences. =A0Could you rename them so
> that they're better to discriminate? =A0headpc and tailpc perhaps?
>
ok. I'll use headpc,tailpc.

>> + =A0 =A0 tpc->mem_cgroup =3D hpc->mem_cgroup;
>> + =A0 =A0 smp_wmb(); /* see __commit_charge() */
>> + =A0 =A0 SetPageCgroupUsed(tpc);
>> + =A0 =A0 VM_BUG_ON(PageCgroupCache(hpc));
>
> Right now, this would be a bug due to other circumstances, but this
> function does not require the page to be anon to function correctly,
> does it?

No.

> =A0I don't think we should encode a made up dependency here.
>
Ok, I'll remove BUG_ON.


>> @@ -2602,8 +2603,7 @@ __mem_cgroup_uncharge_common(struct page
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 for (i =3D 0; i < count; i++)
>> - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_charge_statistics(mem, file, -1);
>> + =A0 =A0 mem_cgroup_charge_statistics(mem, file, -count);
>
> Pass PageCgroupCache(pc) instead, ditch the `file' variable?
>
will do.

>> =A0 =A0 =A0 ClearPageCgroupUsed(pc);
>> =A0 =A0 =A0 /*
>> Index: mmotm-0107/include/linux/memcontrol.h
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- mmotm-0107.orig/include/linux/memcontrol.h
>> +++ mmotm-0107/include/linux/memcontrol.h
>> @@ -146,6 +146,10 @@ unsigned long mem_cgroup_soft_limit_recl
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 gfp_t gfp_mask);
>> =A0u64 mem_cgroup_get_limit(struct mem_cgroup *mem);
>>
>> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> +void mem_cgroup_split_huge_fixup(struct page *head, struct page *tail);
>> +#endif
>> +
>> =A0#else /* CONFIG_CGROUP_MEM_RES_CTLR */
>> =A0struct mem_cgroup;
>>
>> Index: mmotm-0107/mm/huge_memory.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- mmotm-0107.orig/mm/huge_memory.c
>> +++ mmotm-0107/mm/huge_memory.c
>> @@ -1203,6 +1203,8 @@ static void __split_huge_page_refcount(s
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!PageDirty(page_tail));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(!PageSwapBacked(page_tail));
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_split_huge_fixup(page, page_tail);
>
> You need to provide a dummy for non-memcg configurations.

Ahhh, yes. I'll add one.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
