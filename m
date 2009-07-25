Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 625A56B009E
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 10:40:21 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6PEeMGa030728
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 25 Jul 2009 23:40:22 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1777145DE54
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 23:40:22 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BB74645DE53
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 23:40:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AD071DB805F
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 23:40:21 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B59DE1800E
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 23:40:17 +0900 (JST)
Message-ID: <f39a7fd56408054bebd11e40b7dd4db6.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <2f11576a0907250621w3696fdc0pe61638c8c935c981@mail.gmail.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
    <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
    <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
    <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
    <20090724160936.a3b8ad29.akpm@linux-foundation.org>
    <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com>
    <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com>
    <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
    <2f11576a0907250621w3696fdc0pe61638c8c935c981@mail.gmail.com>
Date: Sat, 25 Jul 2009 23:40:16 +0900 (JST)
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, lee.schermerhorn@hp.com, miaox@cn.fujitsu.com, mingo@elte.hu, a.p.zijlstra@chello.nl, cl@linux-foundation.org, menage@google.com, nickpiggin@yahoo.com.au, y-goto@jp.fujitsu.com, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> 2009/07/25 12:15 に KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com> さんは
> 書きました:
>> KAMEZAWA Hiroyuki wrote:
>>> KAMEZAWA Hiroyuki wrote:
>>> Then, here is a much easier fix. for trusting cpuset more.
>>>
>> just a memo about memory hotplug
>>
>> _Direct_ use of task->mems_allowed is only in cpuset and mempolicy.
>> If no policy is used, it's not checked.
>> (See alloc_pages_current())
>>
>> memory hotplug's notifier just updates top_cpuset's mems_allowed.
>> But it doesn't update each task's ones.
>> Then, task's bahavior is
>>
>>  - tasks which don't use mempolicy will use all nodes, N_HIGH_MEMORY.
>>  - tasks under cpuset will be controlled under their own cpuset.
>>  - tasks under mempolicy will use their own policy.
>>   but no new policy is re-calculated and, then, no new mask.
>>
>> Now, even if all memory on nodes a removed, pgdat just remains.
>> Then, cpuset/mempolicy will never access NODE_DATA(nid) which is NULL.
>
> Umm..
> I don't think this is optimal behavior. but if hotplug guys agree
> this, I agree this too.
>
This behavior itself is not very bad.
And all hotplug thing is just a side story of this bugfix.


To update nodemask,  user's mask should be saved in the policy
even when the mask is not relative and v.node should be calculated
again, at event. IIUC, rather than per-policy update by notifer,
some new implemenation for policy will be necessary.

If you mention about the fact that NODE_DATA(nid) is not removed
at node removal. I have no idea, now. copied zonelist is a problem.


Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
