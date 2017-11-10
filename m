Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B557228028D
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 13:16:17 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o88so5290960wrb.18
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 10:16:17 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r140sor547672wmg.59.2017.11.10.10.16.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 10:16:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <201711100646.IJH39597.HOtMLJVSFOQFOF@I-love.SAKURA.ne.jp>
References: <20171108173740.115166-1-shakeelb@google.com> <2940c150-577a-30a8-fac3-cf59a49b84b4@I-love.SAKURA.ne.jp>
 <CALvZod5NVQO+dWKD0y4pK-JYXdehLLgKm0bfc7ExPzyRLDeqzw@mail.gmail.com> <201711100646.IJH39597.HOtMLJVSFOQFOF@I-love.SAKURA.ne.jp>
From: Shakeel Butt <shakeelb@google.com>
Date: Fri, 10 Nov 2017 10:16:14 -0800
Message-ID: <CALvZod4HAVpmPyE7k_Brme=mzic8SDO8gyAFtDhW9r0oBurN4w@mail.gmail.com>
Subject: Re: [PATCH v2] mm, shrinker: make shrinker_list lockless
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Minchan Kim <minchan@kernel.org>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Nov 9, 2017 at 1:46 PM, Tetsuo Handa
<penguin-kernel@i-love.sakura.ne.jp> wrote:
> Shakeel Butt wrote:
>> > If you can accept serialized register_shrinker()/unregister_shrinker(),
>> > I think that something like shown below can do it.
>>
>> If we assume that we will never do register_shrinker and
>> unregister_shrinker on the same object in parallel then do we still
>> need to do msleep & synchronize_rcu() within mutex?
>
> Doing register_shrinker() and unregister_shrinker() on the same object
> in parallel is wrong. This mutex is to ensure that we do not need to
> worry about ->list.next field. synchronize_rcu() should not be slow.
> If you want to avoid msleep() with mutex held, you can also apply
>
>> > If you want parallel register_shrinker()/unregister_shrinker(), something like
>> > shown below on top of shown above will do it.
>
> change.

Thanks for the explanation. Can you post the patch for others to
review without parallel register/unregister and SHRINKER_PERMANENT (we
can add when we need them)? You can use the motivation for the patch I
mentioned in my patch instead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
