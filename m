Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A98696B004D
	for <linux-mm@kvack.org>; Tue, 20 Dec 2011 19:15:01 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 500643EE0BC
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:15:00 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3425445DE68
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:15:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1119F45DD74
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:15:00 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F3BAC1DB803F
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:14:59 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A1671DB803A
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 09:14:59 +0900 (JST)
Date: Wed, 21 Dec 2011 09:13:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: reset to root_mem_cgroup at bypassing
Message-Id: <20111221091347.4f1a10d8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <CABEgKgrk4X13V2Ra_g+V5J0echpj2YZfK20zaFRKP-PhWRWiYQ@mail.gmail.com>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112191218350.3639@eggly.anvils>
	<CABEgKgrk4X13V2Ra_g+V5J0echpj2YZfK20zaFRKP-PhWRWiYQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Cc: Hugh Dickins <hughd@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On Tue, 20 Dec 2011 09:24:47 +0900
Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com> wrote:

> 2011/12/20 Hugh Dickins <hughd@google.com>:
> > On Mon, 19 Dec 2011, KAMEZAWA Hiroyuki wrote:
> >> From d620ff605a3a592c2b1de3a046498ce5cd3d3c50 Mon Sep 17 00:00:00 2001
> >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> Date: Mon, 19 Dec 2011 16:55:10 +0900
> >> Subject: [PATCH 2/2] memcg: reset lru to root_mem_cgroup in special cases.
> >>
> >> This patch is a fix for memcg-simplify-lru-handling-by-new-rule.patch
> >>
> >> After the patch, all pages which will be onto LRU must have sane
> >> pc->mem_cgroup. But, in special case, it's not set.
> >>
> >> If task->mm is NULL or task is TIF_MEMDIE or fatal_signal_pending(),
> >> try_charge() is bypassed and the new charge will not be charged. And
> >> pc->mem_cgroup is unset even if the page will be used/mapped and added
> >> to LRU. To avoid this, A this patch charges such pages to root_mem_cgroup,
> >> then, pc->mem_cgroup will be handled correctly.
> >>
> >> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> ---
> >> A mm/memcontrol.c | A  A 2 +-
> >> A 1 files changed, 1 insertions(+), 1 deletions(-)
> >>
> >> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> >> index 0d6d21c..9268e8e 100644
> >> --- a/mm/memcontrol.c
> >> +++ b/mm/memcontrol.c
> >> @@ -2324,7 +2324,7 @@ nomem:
> >> A  A  A  *ptr = NULL;
> >> A  A  A  return -ENOMEM;
> >> A bypass:
> >> - A  A  *ptr = NULL;
> >> + A  A  *ptr = root_mem_cgroup;
> >> A  A  A  return 0;
> >> A }
> >>
> >> --
> >
> Thank you for review.
> 
> > I'm dubious about this patch: certainly you have not fully justified it.
> >
> I sometimes see panics (in !pc->mem_cgroup check in lru code)
> when I stops test programs by Ctrl-C or some. That was because
> of this path. I checked this by adding a debug code to make
> pc->mem_cgroup = NULL in prep_new_page.
> 
> > I speak from experience: I did *exactly* the same at "bypass" when
> > I introduced our mem_cgroup_reset_page(), which corresponds to your
> > mem_cgroup_reset_owner(); it seemed right to me that a successful
> > (return 0) call to try_charge() should provide a good *ptr.
> >
> ok.
> 
> > But others (Ying and Greg) pointed out that it changes the semantics
> > of __mem_cgroup_try_charge() in this case, so you need to justify the
> > change to all those places which do something like "if (ret || !memcg)"
> > after calling it. A Perhaps it is a good change everywhere, but that's
> > not obvious, so we chose caution.
> >
> 
> > Doesn't it lead to bypass pages being marked as charged to root, so
> > they don't get charged to the right owner next time they're touched?
> >
> Yes. You're right.
> Hm. So, it seems I should add reset_owner() to the !memcg path
> rather than here.
> 
Considering this again..

Now, we catch 'charge' event only once in lifetime of anon/file page.
So, it doesn't depend on that it's marked as PCG_USED or not.




> > In our internal kernel, I restored "bypass" to set *ptr = NULL as
> > before, but routed those callers that need it to continue on to
> > __mem_cgroup_commit_charge() when it's NULL, and let that do a
> > quick little mem_cgroup_reset_page() to root_mem_cgroup for this.
> >
> Yes, I'll prepare v2.
> 

But ok, I'll go this way with some more description.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
