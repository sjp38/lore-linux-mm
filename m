Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1532C6B0092
	for <linux-mm@kvack.org>; Fri, 14 Jan 2011 07:28:10 -0500 (EST)
Received: by iyj17 with SMTP id 17so2535442iyj.14
        for <linux-mm@kvack.org>; Fri, 14 Jan 2011 04:28:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110114122131.GR23189@cmpxchg.org>
References: <20110114190412.73362cd7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114191535.309b634c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110114122131.GR23189@cmpxchg.org>
Date: Fri, 14 Jan 2011 21:28:09 +0900
Message-ID: <AANLkTimoSux0Fg6dpiHy24A+4oVW9_74BQ6EC7LhO8Sg@mail.gmail.com>
Subject: Re: [PATCH 4/4] [BUGFIX] fix account leak at force_empty, rmdir with THP
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, aarcange@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

2011/1/14 Johannes Weiner <hannes@cmpxchg.org>:
> On Fri, Jan 14, 2011 at 07:15:35PM +0900, KAMEZAWA Hiroyuki wrote:
>>
>> Now, when THP is enabled, memcg's rmdir() function is broken
>> because move_account() for THP page is not supported.
>>
>> This will cause account leak or -EBUSY issue at rmdir().
>> This patch fixes the issue by supporting move_account() THP pages.
>>
>> And account information will be moved to its parent at rmdir().
>>
>> How to test:
>> =A0 =A079 =A0mount -t cgroup none /cgroup/memory/ -o memory
>> =A0 =A080 =A0mkdir /cgroup/A/
>> =A0 =A081 =A0mkdir /cgroup/memory/A
>> =A0 =A082 =A0mkdir /cgroup/memory/A/B
>> =A0 =A083 =A0cgexec -g memory:A/B ./malloc 128 &
>> =A0 =A084 =A0grep anon /cgroup/memory/A/B/memory.stat
>> =A0 =A085 =A0grep rss /cgroup/memory/A/B/memory.stat
>> =A0 =A086 =A0echo 1728 > /cgroup/memory/A/tasks
>> =A0 =A087 =A0grep rss /cgroup/memory/A/memory.stat
>> =A0 =A088 =A0rmdir /cgroup/memory/A/B/
>> =A0 =A089 =A0grep rss /cgroup/memory/A/memory.stat
>>
>> - Create 2 level directory and exec a task calls malloc(big chunk).
>> - Move a task somewhere (its parent cgroup in above)
>> - rmdir /A/B
>> - check memory.stat in /A/B is moved to /A after rmdir. and confirm
>> =A0 RSS/LRU information includes usages it was charged against /A/B.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0mm/memcontrol.c | =A0 32 ++++++++++++++++++++++----------
>> =A01 file changed, 22 insertions(+), 10 deletions(-)
>>
>> Index: mmotm-0107/mm/memcontrol.c
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> --- mmotm-0107.orig/mm/memcontrol.c
>> +++ mmotm-0107/mm/memcontrol.c
>> @@ -2154,6 +2154,10 @@ void mem_cgroup_split_huge_fixup(struct
>> =A0 =A0 =A0 smp_wmb(); /* see __commit_charge() */
>> =A0 =A0 =A0 SetPageCgroupUsed(tpc);
>> =A0 =A0 =A0 VM_BUG_ON(PageCgroupCache(hpc));
>> + =A0 =A0 /*
>> + =A0 =A0 =A0* Note: if dirty ratio etc..are supported,
>> + =A0 =A0 =A0 =A0 * other flags may need to be copied.
>> + =A0 =A0 =A0 =A0 */
>
> That's a good comment, but it should be in the patch that introduces
> this function and is a bit unrelated in this one.
>
Ok. I'll remove this. This is an alarm for Greg ;)

>> =A0}
>> =A0#endif
>>
>> @@ -2175,8 +2179,11 @@ void mem_cgroup_split_huge_fixup(struct
>> =A0 */
>>
>> =A0static void __mem_cgroup_move_account(struct page_cgroup *pc,
>> - =A0 =A0 struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge)
>> + =A0 =A0 struct mem_cgroup *from, struct mem_cgroup *to, bool uncharge,
>> + =A0 =A0 int charge_size)
>> =A0{
>> + =A0 =A0 int pagenum =3D charge_size >> PAGE_SHIFT;
>
> nr_pages?
>
Ok. replace pagenum <-> nr_pages.


>> +
>> =A0 =A0 =A0 VM_BUG_ON(from =3D=3D to);
>> =A0 =A0 =A0 VM_BUG_ON(PageLRU(pc->page));
>> =A0 =A0 =A0 VM_BUG_ON(!page_is_cgroup_locked(pc));
>> @@ -2190,14 +2197,14 @@ static void __mem_cgroup_move_account(st
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 __this_cpu_inc(to->stat->count[MEM_CGROUP_ST=
AT_FILE_MAPPED]);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 preempt_enable();
>> =A0 =A0 =A0 }
>> - =A0 =A0 mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -1);
>> + =A0 =A0 mem_cgroup_charge_statistics(from, PageCgroupCache(pc), -pagen=
um);
>> =A0 =A0 =A0 if (uncharge)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* This is not "cancel", but cancel_charge d=
oes all we need. */
>> - =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_cancel_charge(from, PAGE_SIZE);
>> + =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_cancel_charge(from, charge_size);
>>
>> =A0 =A0 =A0 /* caller should have done css_get */
>> =A0 =A0 =A0 pc->mem_cgroup =3D to;
>> - =A0 =A0 mem_cgroup_charge_statistics(to, PageCgroupCache(pc), 1);
>> + =A0 =A0 mem_cgroup_charge_statistics(to, PageCgroupCache(pc), pagenum)=
;
>> =A0 =A0 =A0 /*
>> =A0 =A0 =A0 =A0* We charges against "to" which may not have any tasks. T=
hen, "to"
>> =A0 =A0 =A0 =A0* can be under rmdir(). But in current implementation, ca=
ller of
>> @@ -2212,7 +2219,8 @@ static void __mem_cgroup_move_account(st
>> =A0 * __mem_cgroup_move_account()
>> =A0 */
>> =A0static int mem_cgroup_move_account(struct page_cgroup *pc,
>> - =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *from, struct mem_cgroup *to=
, bool uncharge)
>> + =A0 =A0 =A0 =A0 =A0 =A0 struct mem_cgroup *from, struct mem_cgroup *to=
,
>> + =A0 =A0 =A0 =A0 =A0 =A0 bool uncharge, int charge_size)
>> =A0{
>> =A0 =A0 =A0 int ret =3D -EINVAL;
>> =A0 =A0 =A0 unsigned long flags;
>> @@ -2220,7 +2228,7 @@ static int mem_cgroup_move_account(struc
>> =A0 =A0 =A0 lock_page_cgroup(pc);
>> =A0 =A0 =A0 if (PageCgroupUsed(pc) && pc->mem_cgroup =3D=3D from) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_lock_page_cgroup(pc, &flags);
>> - =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_move_account(pc, from, to, unchar=
ge);
>> + =A0 =A0 =A0 =A0 =A0 =A0 __mem_cgroup_move_account(pc, from, to, unchar=
ge, charge_size);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 move_unlock_page_cgroup(pc, &flags);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> =A0 =A0 =A0 }
>> @@ -2245,6 +2253,7 @@ static int mem_cgroup_move_parent(struct
>> =A0 =A0 =A0 struct cgroup *cg =3D child->css.cgroup;
>> =A0 =A0 =A0 struct cgroup *pcg =3D cg->parent;
>> =A0 =A0 =A0 struct mem_cgroup *parent;
>> + =A0 =A0 int charge_size =3D PAGE_SIZE;
>> =A0 =A0 =A0 int ret;
>>
>> =A0 =A0 =A0 /* Is ROOT ? */
>> @@ -2256,16 +2265,19 @@ static int mem_cgroup_move_parent(struct
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 if (isolate_lru_page(page))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto put;
>> + =A0 =A0 /* The page is isolated from LRU and we have no race with spli=
tting */
>> + =A0 =A0 if (PageTransHuge(page))
>> + =A0 =A0 =A0 =A0 =A0 =A0 charge_size =3D PAGE_SIZE << compound_order(pa=
ge);
>
> The same as in the previous patch, compound_order() implicitely
> handles order-0 pages and should do the right thing without an extra
> check.
>
Sure.

> The comment is valuable, though!
>
> Nitpicks aside:
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>

Thank you for quick review!
Updated one will be posted in the next week after some amounts of more test=
s.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
