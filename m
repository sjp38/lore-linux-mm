Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3F99B6B0003
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 06:38:36 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id u23-v6so33711595iol.22
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 03:38:36 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h63-v6si9691649ith.1.2018.07.16.03.38.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 03:38:34 -0700 (PDT)
Subject: Re: [patch -mm] mm, oom: remove oom_lock from exit_mmap
References: <alpine.DEB.2.21.1807121432370.170100@chino.kir.corp.google.com>
 <20180713142612.GD19960@dhcp22.suse.cz>
 <44d26c25-6e09-49de-5e90-3c16115eb337@i-love.sakura.ne.jp>
 <20180716061317.GA17280@dhcp22.suse.cz>
 <916d7e1d-66ea-00d9-c943-ef3d2e082584@i-love.sakura.ne.jp>
 <20180716074410.GB17280@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f648cbc0-fa8f-5cf5-5e2b-d9ee6d721cf2@i-love.sakura.ne.jp>
Date: Mon, 16 Jul 2018 19:38:21 +0900
MIME-Version: 1.0
In-Reply-To: <20180716074410.GB17280@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2018/07/16 16:44, Michal Hocko wrote:
>> If setting MMF_OOM_SKIP is guarded by oom_lock, we can enforce
>> last second allocation attempt like below.
>>
>>   CPU 0                                   CPU 1
>>   
>>   mutex_trylock(&oom_lock) in __alloc_pages_may_oom() succeeds.
>>   get_page_from_freelist() fails.
>>   Enters out_of_memory().
>>
>>                                           __oom_reap_task_mm() reclaims some memory.
>>                                           mutex_lock(&oom_lock);
>>
>>   select_bad_process() does not select new victim because MMF_OOM_SKIP is not yet set.
>>   Leaves out_of_memory().
>>   mutex_unlock(&oom_lock) in __alloc_pages_may_oom() is called.
>>
>>                                           Sets MMF_OOM_SKIP.
>>                                           mutex_unlock(&oom_lock);
>>
>>   get_page_from_freelist() likely succeeds before reaching __alloc_pages_may_oom() again.
>>   Saved one OOM victim from being needlessly killed.
>>
>> That is, guarding setting MMF_OOM_SKIP works as if synchronize_rcu(); it waits for anybody
>> who already acquired (or started waiting for) oom_lock to release oom_lock, in order to
>> prevent select_bad_process() from needlessly selecting new OOM victim.
> 
> Hmm, is this a practical problem though? Do we really need to have a
> broader locking context just to defeat this race?

Yes, for you think that select_bad_process() might take long time. It is possible
that MMF_OOM_SKIP is set while the owner of oom_lock is preempted. It is not such
a small window that select_bad_process() finds an mm which got MMF_OOM_SKIP
immediately before examining that mm.

>                                                   How about this goes
> into a separate patch with some data justifying it?
> 

No. We won't be able to get data until we let people test using released
kernels. I don't like again getting reports like
http://lkml.kernel.org/r/1495034780-9520-1-git-send-email-guro@fb.com
by not guarding MMF_OOM_SKIP.
