Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 98E3C6B004D
	for <linux-mm@kvack.org>; Mon, 19 Dec 2011 19:24:49 -0500 (EST)
Received: by eabm6 with SMTP id m6so5171404eab.14
        for <linux-mm@kvack.org>; Mon, 19 Dec 2011 16:24:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1112191218350.3639@eggly.anvils>
References: <20111219165146.4d72f1bb.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112191218350.3639@eggly.anvils>
Date: Tue, 20 Dec 2011 09:24:47 +0900
Message-ID: <CABEgKgrk4X13V2Ra_g+V5J0echpj2YZfK20zaFRKP-PhWRWiYQ@mail.gmail.com>
Subject: Re: [PATCH] memcg: reset to root_mem_cgroup at bypassing
From: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cgroups@vger.kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

2011/12/20 Hugh Dickins <hughd@google.com>:
> On Mon, 19 Dec 2011, KAMEZAWA Hiroyuki wrote:
>> From d620ff605a3a592c2b1de3a046498ce5cd3d3c50 Mon Sep 17 00:00:00 2001
>> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Date: Mon, 19 Dec 2011 16:55:10 +0900
>> Subject: [PATCH 2/2] memcg: reset lru to root_mem_cgroup in special case=
s.
>>
>> This patch is a fix for memcg-simplify-lru-handling-by-new-rule.patch
>>
>> After the patch, all pages which will be onto LRU must have sane
>> pc->mem_cgroup. But, in special case, it's not set.
>>
>> If task->mm is NULL or task is TIF_MEMDIE or fatal_signal_pending(),
>> try_charge() is bypassed and the new charge will not be charged. And
>> pc->mem_cgroup is unset even if the page will be used/mapped and added
>> to LRU. To avoid this, =A0this patch charges such pages to root_mem_cgro=
up,
>> then, pc->mem_cgroup will be handled correctly.
>>
>> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> ---
>> =A0mm/memcontrol.c | =A0 =A02 +-
>> =A01 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
>> index 0d6d21c..9268e8e 100644
>> --- a/mm/memcontrol.c
>> +++ b/mm/memcontrol.c
>> @@ -2324,7 +2324,7 @@ nomem:
>> =A0 =A0 =A0 *ptr =3D NULL;
>> =A0 =A0 =A0 return -ENOMEM;
>> =A0bypass:
>> - =A0 =A0 *ptr =3D NULL;
>> + =A0 =A0 *ptr =3D root_mem_cgroup;
>> =A0 =A0 =A0 return 0;
>> =A0}
>>
>> --
>
Thank you for review.

> I'm dubious about this patch: certainly you have not fully justified it.
>
I sometimes see panics (in !pc->mem_cgroup check in lru code)
when I stops test programs by Ctrl-C or some. That was because
of this path. I checked this by adding a debug code to make
pc->mem_cgroup =3D NULL in prep_new_page.

> I speak from experience: I did *exactly* the same at "bypass" when
> I introduced our mem_cgroup_reset_page(), which corresponds to your
> mem_cgroup_reset_owner(); it seemed right to me that a successful
> (return 0) call to try_charge() should provide a good *ptr.
>
ok.

> But others (Ying and Greg) pointed out that it changes the semantics
> of __mem_cgroup_try_charge() in this case, so you need to justify the
> change to all those places which do something like "if (ret || !memcg)"
> after calling it. =A0Perhaps it is a good change everywhere, but that's
> not obvious, so we chose caution.
>

> Doesn't it lead to bypass pages being marked as charged to root, so
> they don't get charged to the right owner next time they're touched?
>
Yes. You're right.
Hm. So, it seems I should add reset_owner() to the !memcg path
rather than here.

> In our internal kernel, I restored "bypass" to set *ptr =3D NULL as
> before, but routed those callers that need it to continue on to
> __mem_cgroup_commit_charge() when it's NULL, and let that do a
> quick little mem_cgroup_reset_page() to root_mem_cgroup for this.
>
Yes, I'll prepare v2.

> But I was growing tired of mem_cgroup_reset_page() when I prepared
> the rollup I posted two weeks ago, it adds overhead where we don't
> want it, so I found a way to avoid it completely.
>
Hmm.

> What you're doing with mem_cgroup_reset_owner() seems reasonable to
> me as a phase to go through (though there's probably more callsites
> to be found - sorry to be unhelpfully mysterious about that, but
> just because per-memcg-lru-locking needed them doesn't imply that
> your patchset needs them), but I expect to (offer a patch to) remove
> it later.
>
Sure. I'm now considering, finally, after removing pc->flags,
we'll have chance to merge page_cgroup to struct page. If so,
reseting pc->mem_cgroup in prep_new_page() will be a choice.

> I am intending to rebase upon your patches, or at least the ones
> which akpm has already taken in (I've not studied the pcg flag ones,
> more noise than I want at the moment). =A0I'm waiting for those to
> appear in a linux-next, disappointed that they weren't in today's.
>
> (But I'm afraid my patches will then clash with Mel's new lru work.)
>
> I have been running successfully on several machines with an
> approximation to what I expect linux-next to be when it has your
> patches in. =A0Ran very stably on two, but one hangs in reclaim after
> a few hours, that's high on my list to investigate (you made no
> change to vmscan.c, maybe the problem comes from Hannes's earlier
> patches, but I hadn't noticed it with those alone).
>

I saw file caches are not reclaimed at all by force_empty...only once.
I'm now digging it.

Thank you.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
