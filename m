Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1C0BC6B0005
	for <linux-mm@kvack.org>; Wed,  4 May 2016 10:39:16 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id n2so108206204obo.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 07:39:16 -0700 (PDT)
Received: from mail-oi0-x22e.google.com (mail-oi0-x22e.google.com. [2607:f8b0:4003:c06::22e])
        by mx.google.com with ESMTPS id x194si1782468oia.185.2016.05.04.07.39.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 07:39:15 -0700 (PDT)
Received: by mail-oi0-x22e.google.com with SMTP id v145so67275808oie.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 07:39:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160504085307.GD29978@dhcp22.suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
	<1461181647-8039-13-git-send-email-mhocko@kernel.org>
	<20160504060123.GB10899@js1304-P5Q-DELUXE>
	<20160504085307.GD29978@dhcp22.suse.cz>
Date: Wed, 4 May 2016 23:39:14 +0900
Message-ID: <CAAmzW4MBC4tVJA1T3Py3ZwFmVPxE=X4+W6J5OQSp8aDu_YmboQ@mail.gmail.com>
Subject: Re: [PATCH 12/14] mm, oom: protect !costly allocations some more
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-05-04 17:53 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 04-05-16 15:01:24, Joonsoo Kim wrote:
>> On Wed, Apr 20, 2016 at 03:47:25PM -0400, Michal Hocko wrote:
> [...]
>
> Please try to trim your responses it makes it much easier to follow the
> discussion

Okay.

>> > +static inline bool
>> > +should_compact_retry(unsigned int order, enum compact_result compact_result,
>> > +                enum migrate_mode *migrate_mode,
>> > +                int compaction_retries)
>> > +{
>> > +   if (!order)
>> > +           return false;
>> > +
>> > +   /*
>> > +    * compaction considers all the zone as desperately out of memory
>> > +    * so it doesn't really make much sense to retry except when the
>> > +    * failure could be caused by weak migration mode.
>> > +    */
>> > +   if (compaction_failed(compact_result)) {
>>
>> IIUC, this compaction_failed() means that at least one zone is
>> compacted and failed. This is not same with your assumption in the
>> comment. If compaction is done and failed on ZONE_DMA, it would be
>> premature decision.
>
> Not really, because if other zones are making some progress then their
> result will override COMPACT_COMPLETE

Think about the situation that DMA zone fails to compact and
the other zones are deferred or skipped. In this case, COMPACT_COMPLETE
will be returned as a final result and should_compact_retry() return false.
I don't think that it means all the zones are desperately out of memory.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
