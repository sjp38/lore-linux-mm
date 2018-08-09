Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 53C986B0008
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 17:05:43 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id w23-v6so5238966iob.18
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 14:05:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g201-v6si5027124ioe.132.2018.08.09.14.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 14:05:41 -0700 (PDT)
Subject: Re: WARNING in try_charge
References: <0000000000005e979605729c1564@google.com>
 <e2869136-9f59-9ce8-8b9f-f75b157ee31d@I-love.SAKURA.ne.jp>
 <20180809150735.GA15611@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <56c95100-d7f9-b715-bdec-e8bb112e2630@i-love.sakura.ne.jp>
Date: Fri, 10 Aug 2018 06:05:19 +0900
MIME-Version: 1.0
In-Reply-To: <20180809150735.GA15611@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, Andrew Morton <akpm@linux-foundation.org>

On 2018/08/10 0:07, Michal Hocko wrote:
> On Thu 09-08-18 22:57:43, Tetsuo Handa wrote:
>> >From b1f38168f14397c7af9c122cd8207663d96e02ec Mon Sep 17 00:00:00 2001
>> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Date: Thu, 9 Aug 2018 22:49:40 +0900
>> Subject: [PATCH] mm, oom: task_will_free_mem(current) should retry until
>>  memory reserve fails
>>
>> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
>> oom_reaped tasks") changed to select next OOM victim as soon as
>> MMF_OOM_SKIP is set. But we don't need to select next OOM victim as
>> long as ALLOC_OOM allocation can succeed. And syzbot is hitting WARN(1)
>> caused by this race window [1].
> 
> It is not because the syzbot was exercising a completely different code
> path (memcg charge rather than the page allocator).

I know syzbot is hitting memcg charge path.

> 
>> Since memcg OOM case uses forced charge if current thread is killed,
>> out_of_memory() can return true without selecting next OOM victim.
>> Therefore, this patch changes task_will_free_mem(current) to ignore
>> MMF_OOM_SKIP unless ALLOC_OOM allocation failed.
> 
> And the patch is simply wrong for memcg.
> 

Why? I think I should have done

-+	page = __alloc_pages_may_oom(gfp_mask, order, alloc_flags == ALLOC_OOM
-+				     || (gfp_mask & __GFP_NOMEMALLOC), ac,
-+				     &did_some_progress);
++	page = __alloc_pages_may_oom(gfp_mask, order, alloc_flags == ALLOC_OOM,
++				     ac, &did_some_progress);

because nobody will use __GFP_NOMEMALLOC | __GFP_NOFAIL. But for memcg charge
path, task_will_free_mem(current, false) == true and out_of_memory() will return
true, which avoids unnecessary OOM killing.

Of course, this patch cannot avoid unnecessary OOM killing if out_of_memory()
is called by not yet killed process. But to mitigate it, what can we do other
than defer setting MMF_OOM_SKIP using a timeout based mechanism? Making
the OOM reaper unconditionally reclaim all memory is not a valid answer.
