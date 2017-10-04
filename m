Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id E37DC6B0069
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 17:24:28 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id k56so3830490qtc.1
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 14:24:28 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y142sor769296yby.2.2017.10.04.14.24.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Oct 2017 14:24:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171004201524.GA4174@castle>
References: <20171004154638.710-1-guro@fb.com> <20171004154638.710-4-guro@fb.com>
 <CALvZod6bwyoSWTv139y0wMidpZm5HcDu8RzVjF8U7GHxAzxSQw@mail.gmail.com> <20171004201524.GA4174@castle>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 4 Oct 2017 14:24:26 -0700
Message-ID: <CALvZod45ObeQwq-pKeqyLe2bNwfKAr0majCbNfqPOEJL+AeiNw@mail.gmail.com>
Subject: Re: [v10 3/6] mm, oom: cgroup-aware OOM killer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, Cgroups <cgroups@vger.kernel.org>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

>> > +               if (memcg_has_children(iter))
>> > +                       continue;
>>
>> && iter != root_mem_cgroup ?
>
> Oh, sure. I had a stupid bug in my test script, which prevented me from
> catching this. Thanks!
>
> This should fix the problem.
> --
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2e82625bd354..b3848bce4c86 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2807,7 +2807,8 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>                  * We don't consider non-leaf non-oom_group memory cgroups
>                  * as OOM victims.
>                  */
> -               if (memcg_has_children(iter) && !mem_cgroup_oom_group(iter))
> +               if (memcg_has_children(iter) && iter != root_mem_cgroup &&
> +                   !mem_cgroup_oom_group(iter))
>                         continue;

I think you are mixing the 3rd and 4th patch. The root_mem_cgroup
check should be in 3rd while oom_group stuff should be in 4th.


>>
>> Shouldn't there be a CSS_ONLINE check? Also instead of css_get at the
>> end why not css_tryget_online() here and css_put for the previous
>> selected one.
>
> Hm, why do we need to check this? I do not see, how we can choose
> an OFFLINE memcg as a victim, tbh. Please, explain the problem.
>

Sorry about the confusion. There are two things. First, should we do a
css_get on the newly selected memcg within the for loop when we still
have a reference to it?

Second, for the OFFLINE memcg, you are right oom_evaluate_memcg() will
return 0 for offlined memcgs. Maybe no need to call
oom_evaluate_memcg() for offlined memcgs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
