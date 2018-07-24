Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id EBF0D6B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 19:10:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so3894810ply.12
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 16:10:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h18-v6si11651197pfn.158.2018.07.24.16.10.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 16:10:38 -0700 (PDT)
Subject: Re: [patch v4] mm, oom: fix unnecessary killing of additional
 processes
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
 <d19d44c3-c8cf-70a1-9b15-c98df233d5f0@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807181317540.49359@chino.kir.corp.google.com>
 <a78fb992-ad59-0cdb-3c38-8284b2245f21@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807200133310.119737@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807201314230.231119@chino.kir.corp.google.com>
 <ca34b123-5c81-569f-85ea-4851bc569962@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807201505550.38399@chino.kir.corp.google.com>
 <f8d24892-b05e-73a8-36d5-4fe278f84c44@i-love.sakura.ne.jp>
 <alpine.DEB.2.21.1807241444370.206335@chino.kir.corp.google.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <05dbc69a-1c26-adec-15c6-f7192f8d2ae0@i-love.sakura.ne.jp>
Date: Wed, 25 Jul 2018 07:31:24 +0900
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1807241444370.206335@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/07/25 6:45, David Rientjes wrote:
> On Sat, 21 Jul 2018, Tetsuo Handa wrote:
> 
>> You can't apply "[patch v4] mm, oom: fix unnecessary killing of additional processes"
>> because Michal's patch which removes oom_lock serialization was added to -mm tree.
>>
> 
> I've rebased the patch to linux-next and posted a v5.
> 
>> You might worry about situations where __oom_reap_task_mm() is a no-op.
>> But that is not always true. There is no point with emitting
>>
>>   pr_info("oom_reaper: unable to reap pid:%d (%s)\n", ...);
>>   debug_show_all_locks();
>>
>> noise and doing
>>
>>   set_bit(MMF_OOM_SKIP, &mm->flags);
>>
>> because exit_mmap() will not release oom_lock until __oom_reap_task_mm()
>> completes. That is, except extra noise, there is no difference with
>> current behavior which sets set_bit(MMF_OOM_SKIP, &mm->flags) after
>> returning from __oom_reap_task_mm().
>>
> 
> v5 has restructured how exit_mmap() serializes its unmapping with the oom 
> reaper.  It sets MMF_OOM_SKIP while holding mm->mmap_sem.
> 

I think that v5 is still wrong. exit_mmap() keeps mmap_sem held for write does
not prevent oom_reap_task() from emitting the noise and setting MMF_OOM_SKIP
after timeout. Since your purpose is to wait for release of memory which could
not be reclaimed by __oom_reap_task_mm(), what if __oom_reap_task_mm() was no-op and
exit_mmap() was preempted immediately after returning from __oom_reap_task_mm() ?

Also, I believe that userspace visible knob is not needed.
