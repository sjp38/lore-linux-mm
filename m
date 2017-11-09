Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id D9F7C44043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 20:07:10 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a20so2324424wrc.1
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 17:07:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c39sor2206237wra.4.2017.11.08.17.07.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 17:07:09 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171109000735.GA9883@bbox>
References: <20171108173740.115166-1-shakeelb@google.com> <20171109000735.GA9883@bbox>
From: Shakeel Butt <shakeelb@google.com>
Date: Wed, 8 Nov 2017 17:07:08 -0800
Message-ID: <CALvZod4ercfnebabcMEfxmwcRwdpu7xsPhjX4oyRHh2+5U8h1A@mail.gmail.com>
Subject: Re: [PATCH v2] mm, shrinker: make shrinker_list lockless
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Huang Ying <ying.huang@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Nov 8, 2017 at 4:07 PM, Minchan Kim <minchan@kernel.org> wrote:
> Hi,
>
> On Wed, Nov 08, 2017 at 09:37:40AM -0800, Shakeel Butt wrote:
>> In our production, we have observed that the job loader gets stuck for
>> 10s of seconds while doing mount operation. It turns out that it was
>> stuck in register_shrinker() and some unrelated job was under memory
>> pressure and spending time in shrink_slab(). Our machines have a lot
>> of shrinkers registered and jobs under memory pressure has to traverse
>> all of those memcg-aware shrinkers and do affect unrelated jobs which
>> want to register their own shrinkers.
>>
>> This patch has made the shrinker_list traversal lockless and shrinker
>> register remain fast. For the shrinker unregister, atomic counter
>> has been introduced to avoid synchronize_rcu() call. The fields of
>
> So, do you want to enhance unregister shrinker path as well as registering?
>

Yes, I don't want to add delay to unregister_shrinker for the normal
case where there isn't any readers (i.e. unconditional
synchronize_rcu).

>> struct shrinker has been rearraged to make sure that the size does
>> not increase for x86_64.
>>
>> The shrinker functions are allowed to reschedule() and thus can not
>> be called with rcu read lock. One way to resolve that is to use
>> srcu read lock but then ifdefs has to be used as SRCU is behind
>> CONFIG_SRCU. Another way is to just release the rcu read lock before
>> calling the shrinker and reacquire on the return. The atomic counter
>> will make sure that the shrinker entry will not be freed under us.
>
> Instead of adding new lock, could we simply release shrinker_rwsem read-side
> lock in list traveral periodically to give a chance to hold a write-side
> lock?
>

Greg has already pointed out that this patch is still not right/safe
and now I am getting to the opinion that without changing the shrinker
API, it might not be possible to do lockless shrinker traversal and
unregister shrinker without synchronize_rcu().

Regarding your suggestion, do you mean to add periodic release lock
and reacquire using down_read_trylock() or down_read()?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
