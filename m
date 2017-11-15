Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4DD5A6B0033
	for <linux-mm@kvack.org>; Wed, 15 Nov 2017 01:28:14 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o14so12309577wrf.6
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 22:28:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z189sor2437848wmc.47.2017.11.14.22.28.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 Nov 2017 22:28:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171115005602.GB23810@bbox>
References: <1510609063-3327-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171115005602.GB23810@bbox>
From: Shakeel Butt <shakeelb@google.com>
Date: Tue, 14 Nov 2017 22:28:10 -0800
Message-ID: <CALvZod44uBUJdaRSqAB4Kym9u9KX0pgitYmWVbM-Ww30HdFpzQ@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Nov 14, 2017 at 4:56 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Tue, Nov 14, 2017 at 06:37:42AM +0900, Tetsuo Handa wrote:
>> When shrinker_rwsem was introduced, it was assumed that
>> register_shrinker()/unregister_shrinker() are really unlikely paths
>> which are called during initialization and tear down. But nowadays,
>> register_shrinker()/unregister_shrinker() might be called regularly.
>> This patch prepares for allowing parallel registration/unregistration
>> of shrinkers.
>>
>> Since do_shrink_slab() can reschedule, we cannot protect shrinker_list
>> using one RCU section. But using atomic_inc()/atomic_dec() for each
>> do_shrink_slab() call will not impact so much.
>>
>> This patch uses polling loop with short sleep for unregister_shrinker()
>> rather than wait_on_atomic_t(), for we can save reader's cost (plain
>> atomic_dec() compared to atomic_dec_and_test()), we can expect that
>> do_shrink_slab() of unregistering shrinker likely returns shortly, and
>> we can avoid khungtaskd warnings when do_shrink_slab() of unregistering
>> shrinker unexpectedly took so long.
>>
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>
> Before reviewing this patch, can't we solve the problem with more
> simple way? Like this.
>
> Shakeel, What do you think?
>

Seems simple enough. I will run my test (running fork bomb in one
memcg and separately time a mount operation) and update if numbers
differ significantly.

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 13d711dd8776..cbb624cb9baa 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -498,6 +498,14 @@ static unsigned long shrink_slab(gfp_t gfp_mask, int nid,
>                         sc.nid = 0;
>
>                 freed += do_shrink_slab(&sc, shrinker, nr_scanned, nr_eligible);
> +               /*
> +                * bail out if someone want to register a new shrinker to prevent
> +                * long time stall by parallel ongoing shrinking.
> +                */
> +               if (rwsem_is_contended(&shrinker_rwsem)) {
> +                       freed = 1;

freed = freed ?: 1;

> +                       break;
> +               }
>         }
>
>         up_read(&shrinker_rwsem);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
