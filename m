Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D90C6B0008
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:13:13 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m18so10117523pgu.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:13:13 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id t3si10759156pgs.763.2018.03.26.15.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 15:13:11 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and
 env_start|end in mm_struct
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180326183725.GB27373@bombadil.infradead.org>
 <20180326192132.GE2236@uranus>
 <0bfa8943-a2fe-b0ab-99a2-347094a2bcec@i-love.sakura.ne.jp>
 <20180326212944.GF2236@uranus>
 <201803270700.IJB35465.HJQFSFMVLFOtOO@I-love.SAKURA.ne.jp>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <ceaa72ee-a63a-983b-d040-387886f5599c@linux.alibaba.com>
Date: Mon, 26 Mar 2018 18:12:55 -0400
MIME-Version: 1.0
In-Reply-To: <201803270700.IJB35465.HJQFSFMVLFOtOO@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, gorcunov@gmail.com
Cc: willy@infradead.org, adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 3/26/18 6:00 PM, Tetsuo Handa wrote:
> Cyrill Gorcunov wrote:
>> On Tue, Mar 27, 2018 at 06:10:09AM +0900, Tetsuo Handa wrote:
>>> On 2018/03/27 4:21, Cyrill Gorcunov wrote:
>>>> That said I think using read-lock here would be a bug.
>>> If I understand correctly, the caller can't set both fields atomically, for
>>> prctl() does not receive both fields at one call.
>>>
>>>    prctl(PR_SET_MM, PR_SET_MM_ARG_START xor PR_SET_MM_ARG_END xor PR_SET_MM_ENV_START xor PR_SET_MM_ENV_END, new value, 0, 0);
>>>
>> True, but the key moment is that two/three/four system calls can
>> run simultaneously. And while previously they are ordered by "write",
>> with read lock they are completely unordered and this is really
>> worries me.
> Yes, we need exclusive lock when updating these fields.
>
>>              To be fair I would prefer to drop this old per-field
>> interface completely. This per-field interface was rather an ugly
>> solution from my side.
> But this is userspace visible API and thus we cannot change.
>
>>> Then, I wonder whether reading arg_start|end and env_start|end atomically makes
>>> sense. Just retry reading if arg_start > env_end or env_start > env_end is fine?
>> Tetsuo, let me re-read this code tomorrow, maybe I miss something obvious.
>>
> You are not missing my point. What I thought is
>
> +retry:
> -	down_read(&mm->mmap_sem);
>   	arg_start = mm->arg_start;
>   	arg_end = mm->arg_end;
>   	env_start = mm->env_start;
>   	env_end = mm->env_end;
> -	up_read(&mm->mmap_sem);
>   
> -	BUG_ON(arg_start > arg_end);
> -	BUG_ON(env_start > env_end);
> +	if (unlikely(arg_start > arg_end || env_start > env_end)) {
> +		cond_resched();
> +		goto retry;

Can't it trap into dead loop if the condition is always false?

> +	}
>
> for reading these fields.
>
> By the way, /proc/pid/ readers are serving as a canary who tells something
> mm_mmap related problem is happening. On the other hand, it is sad that
> such canary cannot be terminated by signal due to use of unkillable waits.
> I wish we can use killable waits.

I already proposed patches (https://lkml.org/lkml/2018/2/26/1197) to do 
this a few weeks ago. In the review, akpm suggested mitigate the 
mmap_sem contention instead of using killable version workaround. Then 
the preliminary unmaping by section patches 
(https://lkml.org/lkml/2018/3/20/786) were proposed. In the discussion, 
we decided to eliminate the mmap_sem abuse, this is where the patch came 
from.

Yang
