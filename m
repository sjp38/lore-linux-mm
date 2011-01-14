Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id E3EDD6B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 07:07:12 -0500 (EST)
Received: by iwn40 with SMTP id 40so2569550iwn.14
        for <linux-mm@kvack.org>; Fri, 14 Jan 2011 04:07:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110114115121.GO23189@cmpxchg.org>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114190644.a222f60d.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114115121.GO23189@cmpxchg.org>
Date: Fri, 14 Jan 2011 21:07:08 +0900
Message-ID: <AANLkTinKFDn5oQE=xqjXC4XXO_sA3Xb_NOEXz_pU7FKn@mail.gmail.com>
Subject: Re: [PATCH 1/4] [BUGFIX] enhance charge_statistics function for
 fixising issues
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2011/1/14 Johannes Weiner <hannes@cmpxchg.org>:
> On Fri, Jan 14, 2011 at 07:06:44PM +0900, KAMEZAWA Hiroyuki wrote:
>> mem_cgroup_charge_staistics() was designed for charging a page but
>> now, we have transparent hugepage. To fix problems (in following patch)
>> it's required to change the function to get the number of pages
>> as its arguments.
>>
>> The new function gets following as argument.
>> =A0 - type of page rather than 'pc'
>> =A0 - size of page which is accounted.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> I agree with the patch in general, below are only a few nitpicks.
>
Thanks, I think details should be updated, too.


>> --- mmotm-0107.orig/mm/memcontrol.c
>> +++ mmotm-0107/mm/memcontrol.c
>> @@ -600,23 +600,23 @@ static void mem_cgroup_swap_statistics(s
>> =A0}
>>
>> =A0static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct page_cgroup *pc,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0bool charge)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0bool file,
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0int pages)
>
> I think 'nr_pages' would be a better name. =A0This makes me think of a
> 'struct page *[]'.
>
ok.

>> =A0{
>> - =A0 =A0 int val =3D (charge) ? 1 : -1;
>> -
>> =A0 =A0 =A0 preempt_disable();
>>
>> - =A0 =A0 if (PageCgroupCache(pc))
>> - =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STA=
T_CACHE], val);
>> + =A0 =A0 if (file)
>> + =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STA=
T_CACHE], pages);
>> =A0 =A0 =A0 else
>> - =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STA=
T_RSS], val);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_STA=
T_RSS], pages);
>>
>> - =A0 =A0 if (charge)
>> + =A0 =A0 /* pagein of a big page is an event. So, ignore page size */
>> + =A0 =A0 if (pages > 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_inc(mem->stat->count[MEM_CGROUP_S=
TAT_PGPGIN_COUNT]);
>> =A0 =A0 =A0 else
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_inc(mem->stat->count[MEM_CGROUP_S=
TAT_PGPGOUT_COUNT]);
>> - =A0 =A0 __this_cpu_inc(mem->stat->count[MEM_CGROUP_EVENTS]);
>> +
>> + =A0 =A0 __this_cpu_add(mem->stat->count[MEM_CGROUP_EVENTS], pages);
>>
>> =A0 =A0 =A0 preempt_enable();
>> =A0}
>> @@ -2092,6 +2092,7 @@ static void ____mem_cgroup_commit_charge
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0struct page_cgroup *pc,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0enum charge_type ctype)
>> =A0{
>> + =A0 =A0 bool file =3D false;
>> =A0 =A0 =A0 pc->mem_cgroup =3D mem;
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* We access a page_cgroup asynchronously without lock_pag=
e_cgroup().
>> @@ -2106,6 +2107,7 @@ static void ____mem_cgroup_commit_charge
>> =A0 =A0 =A0 case MEM_CGROUP_CHARGE_TYPE_SHMEM:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageCgroupCache(pc);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageCgroupUsed(pc);
>> + =A0 =A0 =A0 =A0 =A0 =A0 file =3D true;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 case MEM_CGROUP_CHARGE_TYPE_MAPPED:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ClearPageCgroupCache(pc);
>> @@ -2115,7 +2117,7 @@ static void ____mem_cgroup_commit_charge
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
>> =A0 =A0 =A0 }
>>
>> - =A0 =A0 mem_cgroup_charge_statistics(mem, pc, true);
>> + =A0 =A0 mem_cgroup_charge_statistics(mem, file, 1);
>
> The extra local variable is a bit awkward, since there are already
> several sources of this information (ctype and pc->flags).
>
> Could you keep it like the other sites, just pass PageCgroupCache()
> here as well?
>
Ok.

>> @@ -2186,14 +2188,14 @@ static void __mem_cgroup_move_account(st
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_inc(to->stat->count[MEM_CGROUP_ST=
AT_FILE_MAPPED]);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable();
>> =A0 =A0 =A0 }
>> - =A0 =A0 mem_cgroup_charge_statistics(from, pc, false);
>> + =A0 =A0 mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -1);
>> =A0 =A0 =A0 if (uncharge)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This is not "cancel", but cancel_charge d=
oes all we need. */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_cancel_charge(from, PAGE_SIZE);
>>
>> =A0 =A0 =A0 /* caller should have done css_get */
>> =A0 =A0 =A0 pc->mem_cgroup =3D to;
>> - =A0 =A0 mem_cgroup_charge_statistics(to, pc, true);
>> + =A0 =A0 mem_cgroup_charge_statistics(to, PageCgroupCache(pc), 1);
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* We charges against "to" which may not have any tasks. T=
hen, "to"
>> =A0 =A0 =A0 =A0* can be under rmdir(). But in current implementation, ca=
ller of
>> @@ -2551,6 +2553,7 @@ __mem_cgroup_uncharge_common(struct page
>> =A0 =A0 =A0 struct page_cgroup *pc;
>> =A0 =A0 =A0 struct mem_cgroup *mem =3D NULL;
>> =A0 =A0 =A0 int page_size =3D PAGE_SIZE;
>> + =A0 =A0 bool file =3D false;
>>
>> =A0 =A0 =A0 if (mem_cgroup_disabled())
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> @@ -2578,6 +2581,9 @@ __mem_cgroup_uncharge_common(struct page
>> =A0 =A0 =A0 if (!PageCgroupUsed(pc))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto unlock_out;
>>
>> + =A0 =A0 if (PageCgroupCache(pc))
>> + =A0 =A0 =A0 =A0 =A0 =A0 file =3D true;
>> +
>> =A0 =A0 =A0 switch (ctype) {
>> =A0 =A0 =A0 case MEM_CGROUP_CHARGE_TYPE_MAPPED:
>> =A0 =A0 =A0 case MEM_CGROUP_CHARGE_TYPE_DROP:
>> @@ -2597,7 +2603,7 @@ __mem_cgroup_uncharge_common(struct page
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 for (i =3D 0; i < count; i++)
>> - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_charge_statistics(mem, pc + i, fals=
e);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_charge_statistics(mem, file, -1);
>
> I see you get rid of this loop in the next patch, anyway. =A0Can you
> just use PageCgroupCache() instead of the extra variable?

will do.
Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
