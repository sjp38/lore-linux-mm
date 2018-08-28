Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 390C96B4820
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 17:17:38 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w12-v6so2271939oie.12
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 14:17:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g79-v6si1375885oic.422.2018.08.28.14.17.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Aug 2018 14:17:36 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180828124030.GB12564@cmpxchg.org>
 <58e0bd2d-71bd-cf46-0929-ef5eb0c6c2bc@i-love.sakura.ne.jp>
 <20180828135105.GB10349@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <88703635-bd8a-41d5-ff57-ea865e2680e7@i-love.sakura.ne.jp>
Date: Wed, 29 Aug 2018 06:17:15 +0900
MIME-Version: 1.0
In-Reply-To: <20180828135105.GB10349@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On 2018/08/28 22:51, Michal Hocko wrote:
> On Tue 28-08-18 22:29:56, Tetsuo Handa wrote:
> [...]
>> The OOM reaper may set MMF_OOM_SKIP without reclaiming any memory (due
>> to e.g. mlock()ed memory, shared memory, unable to grab mmap_sem for read).
>> We haven't reached to the point where the OOM reaper reclaims all memory
>> nor allocating threads wait some more after setting MMF_OOM_SKIP.
>> Therefore, this
>>
>>   if (tsk_is_oom_victim(current) && !(oc->gfp_mask & __GFP_NOFAIL))
>>       return true;
>>
>> is the simplest mitigation we can do now.
> 
> But this is adding a mess because you pretend to make a forward progress
> even the OOM path didn't do anything at all and rely on another kludge
> elsewhere to work.

I'm not pretending to make a forward progress. If current thread is an OOM
victim, it is guaranteed to make forward progress (unless __GFP_NOFAIL) by
failing that allocation attempt after trying memory reserves. The OOM path
does not need to do anything at all.
