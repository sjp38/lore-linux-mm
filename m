Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 85F9E6B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:12:11 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so18679251wme.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:12:11 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id z75si3023499wmh.1.2016.02.25.01.12.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 01:12:10 -0800 (PST)
Received: by mail-wm0-f48.google.com with SMTP id b205so22650656wmb.1
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:12:10 -0800 (PST)
Subject: Re: [PATCH RFC] ext4: use __GFP_NOFAIL in ext4_free_blocks()
References: <20160224170912.2195.8153.stgit@buzz> <56CEC2EC.5000506@kyup.com>
 <20160225090839.GC17573@dhcp22.suse.cz>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <56CEC568.6080809@kyup.com>
Date: Thu, 25 Feb 2016 11:12:08 +0200
MIME-Version: 1.0
In-Reply-To: <20160225090839.GC17573@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Theodore Ts'o <tytso@mit.edu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dmitry Monakhov <dmonakhov@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org



On 02/25/2016 11:08 AM, Michal Hocko wrote:
> On Thu 25-02-16 11:01:32, Nikolay Borisov wrote:
>>
>>
>> On 02/24/2016 07:09 PM, Konstantin Khlebnikov wrote:
>>> This might be unexpected but pages allocated for sbi->s_buddy_cache are
>>> charged to current memory cgroup. So, GFP_NOFS allocation could fail if
>>> current task has been killed by OOM or if current memory cgroup has no
>>> free memory left. Block allocator cannot handle such failures here yet.
>>>
>>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>
>> Adding new users of GFP_NOFAIL is deprecated.
> 
> This is not true. GFP_NOFAIL should be used where the allocation failure
> is no tolleratable and it is much more preferrable to doing an opencoded
> endless loop over page allocator.

In that case the comments in buffered_rmqueue, and the WARN_ON in
__alloc_pages_may_oom and __alloc_pages_slowpath perhaps should be
removed since they are misleading?

> 
>> Where exactly does the
>> block allocator fail, I skimmed the code and failing ext4_mb_load_buddy
>> seems to be handled at all call sites. There are some BUG_ONs but from
>> the comments there I guess they should occur when we try to find a page
>> and not allocate a new one?
> 
> I have posted a similar patch last year:
> http://lkml.kernel.org/r/1438768284-30927-6-git-send-email-mhocko@kernel.org
> because I could see emergency reboots when GFP_NOFS allocations were
> allowed to fail.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
