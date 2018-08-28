Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5EBB6B45CB
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 06:54:04 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id g5-v6so938911pgq.5
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 03:54:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 7-v6si776028pgw.207.2018.08.28.03.54.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 03:54:03 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180820105336.GJ29735@dhcp22.suse.cz>
 <1341c62b-cb21-a592-f062-d162da01f912@i-love.sakura.ne.jp>
 <20180820111015.GL29735@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <8d6bed06-456c-eabc-d7be-413ac1e0e2f4@I-love.SAKURA.ne.jp>
Date: Tue, 28 Aug 2018 19:20:32 +0900
MIME-Version: 1.0
In-Reply-To: <20180820111015.GL29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On 2018/08/20 20:10, Michal Hocko wrote:
> On Mon 20-08-18 20:02:30, Tetsuo Handa wrote:
>> On 2018/08/20 19:53, Michal Hocko wrote:
>>> On Mon 20-08-18 19:37:45, Tetsuo Handa wrote:
>>>> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
>>>> oom_reaped tasks") changed to select next OOM victim as soon as
>>>> MMF_OOM_SKIP is set. But since OOM victims can try ALLOC_OOM allocation
>>>> and then give up (if !memcg OOM) or can use forced charge and then retry
>>>> (if memcg OOM), OOM victims do not need to select next OOM victim unless
>>>> they are doing __GFP_NOFAIL allocations.
>>>
>>> I do not like this at all. It seems hackish to say the least. And more
>>> importantly...
>>>
>>>> This is a quick mitigation because syzbot is hitting WARN(1) caused by
>>>> this race window [1]. More robust fix (e.g. make it possible to reclaim
>>>> more memory before MMF_OOM_SKIP is set, wait for some more after
>>>> MMF_OOM_SKIP is set) is a future work.
>>>
>>> .. there is already a patch (by Johannes) for that warning IIRC.
>>
>> You mean http://lkml.kernel.org/r/20180808144515.GA9276@cmpxchg.org ?
> 
> Yes
> 
>> But I can't find that patch in linux-next.git . And as far as I know,
>> no patch was sent to linux.git for handling this problem. Therefore,
>> I wrote this patch so that we can apply for 4.19-rc1.
> 
> I am pretty sure Johannes will post them later after merge window
> closes.
> 

But Johannes' patch will not prevent the OOM killer from needlessly selecting
next OOM victim, will it? I still think we can apply my patch in order to prevent
the OOM killer from needlessly selecting next OOM victim.
