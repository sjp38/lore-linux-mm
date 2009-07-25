Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 28AED6B009A
	for <linux-mm@kvack.org>; Fri, 24 Jul 2009 23:15:19 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6P3FCvC021438
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 25 Jul 2009 12:15:12 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D451045DE52
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 12:15:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AC88945DE50
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 12:15:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 896311DB8040
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 12:15:11 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 342581DB803E
	for <linux-mm@kvack.org>; Sat, 25 Jul 2009 12:15:11 +0900 (JST)
Message-ID: <9443f91bd4648e6214b32acff4512b97.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: 
     <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
    <1247679064.4089.26.camel@useless.americas.hpqcorp.net>
    <alpine.DEB.2.00.0907161257190.31844@chino.kir.corp.google.com>
    <alpine.DEB.2.00.0907241551070.8573@chino.kir.corp.google.com>
    <20090724160936.a3b8ad29.akpm@linux-foundation.org>
    <337c5d83954b38b14a17f0adf4d357d8.squirrel@webmail-b.css.fujitsu.com>
    <5bb65c0e4c6828b1331d33745f34d9ee.squirrel@webmail-b.css.fujitsu.com>
Date: Sat, 25 Jul 2009 12:15:10 +0900 (JST)
Subject: Re: [BUG] set_mempolicy(MPOL_INTERLEAV) cause kernel panic
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, miaox@cn.fujitsu.com, mingo@elte.hu, a.p.zijlstra@chello.nl, cl@linux-foundation.org, menage@google.com, nickpiggin@yahoo.com.au, y-goto@jp.fujitsu.com, penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> KAMEZAWA Hiroyuki wrote:
> Then, here is a much easier fix. for trusting cpuset more.
>
just a memo about memory hotplug

_Direct_ use of task->mems_allowed is only in cpuset and mempolicy.
If no policy is used, it's not checked.
(See alloc_pages_current())

memory hotplug's notifier just updates top_cpuset's mems_allowed.
But it doesn't update each task's ones.
Then, task's bahavior is

 - tasks which don't use mempolicy will use all nodes, N_HIGH_MEMORY.
 - tasks under cpuset will be controlled under their own cpuset.
 - tasks under mempolicy will use their own policy.
   but no new policy is re-calculated and, then, no new mask.

Now, even if all memory on nodes a removed, pgdat just remains.
Then, cpuset/mempolicy will never access NODE_DATA(nid) which is NULL.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
