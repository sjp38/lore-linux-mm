Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6CD436B0260
	for <linux-mm@kvack.org>; Tue, 10 May 2016 03:07:15 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id i75so14779287ioa.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:07:15 -0700 (PDT)
Received: from mail-ob0-x22f.google.com (mail-ob0-x22f.google.com. [2607:f8b0:4003:c01::22f])
        by mx.google.com with ESMTPS id p64si262540oia.8.2016.05.10.00.07.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 00:07:14 -0700 (PDT)
Received: by mail-ob0-x22f.google.com with SMTP id x1so1870925obt.0
        for <linux-mm@kvack.org>; Tue, 10 May 2016 00:07:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160504194019.GE21490@dhcp22.suse.cz>
References: <1462252984-8524-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1462252984-8524-7-git-send-email-iamjoonsoo.kim@lge.com>
	<20160503085356.GD28039@dhcp22.suse.cz>
	<20160504021449.GA10256@js1304-P5Q-DELUXE>
	<20160504092133.GG29978@dhcp22.suse.cz>
	<CAAmzW4NYWaNvC5MPR8RwQSiKP2b2Z5wVy9nnNxc+sTVWvQ6BGA@mail.gmail.com>
	<20160504194019.GE21490@dhcp22.suse.cz>
Date: Tue, 10 May 2016 16:07:14 +0900
Message-ID: <CAAmzW4N1UocTRaX+K=-2OtaARPOu+WjsBLCayzr20pP15GNo4g@mail.gmail.com>
Subject: Re: [PATCH 6/6] mm/page_owner: use stackdepot to store stacktrace
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Minchan Kim <minchan@kernel.org>, Alexander Potapenko <glider@google.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-05-05 4:40 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Thu 05-05-16 00:30:35, Joonsoo Kim wrote:
>> 2016-05-04 18:21 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> [...]
>> > Do we really consume 512B of stack during reclaim. That sounds more than
>> > worrying to me.
>>
>> Hmm...I checked it by ./script/stackusage and result is as below.
>>
>> shrink_zone() 128
>> shrink_zone_memcg() 248
>> shrink_active_list() 176
>>
>> We have a call path that shrink_zone() -> shrink_zone_memcg() ->
>> shrink_active_list().
>> I'm not sure whether it is the deepest path or not.
>
> This is definitely not the deepest path. Slab shrinkers can take more
> but 512B is still a lot. Some call paths are already too deep when
> calling into the allocator and some of them already use GFP_NOFS to
> prevent from potentially deep callchain slab shrinkers. Anyway worth
> exploring for better solutions.
>
> And I believe it would be better to solve this in the stackdepot
> directly so other users do not have to invent their own ways around the
> same issue. I have just checked the code and set_track uses save_stack
> which does the same thing and it seems to be called from the slab
> allocator. I have missed this usage before so the problem already does
> exist. It would be unfair to request you to fix that in order to add a
> new user. It would be great if this got addressed though.

Yes, fixing it in stackdepot looks more reasonable.
Then, I will just change PAGE_OWNER_STACK_DEPTH from 64 to 16 and
leave the code as is for now. With this change, we will just consume 128B stack
and would not cause stack problem. If anyone has an objection,
please let me know.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
