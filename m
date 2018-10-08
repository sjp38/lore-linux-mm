Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA9B46B000A
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 02:22:43 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 87-v6so16151227pfq.8
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 23:22:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id 28-v6si14531923pgy.68.2018.10.07.23.22.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 23:22:42 -0700 (PDT)
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
References: <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
 <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p5>
 <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
Date: Mon, 8 Oct 2018 15:22:37 +0900
MIME-Version: 1.0
In-Reply-To: <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ytk.lee@samsung.com, "mhocko@kernel.org" <mhocko@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 2018/10/08 15:14, Yong-Taek Lee wrote:
>> On 2018/10/08 10:19, Yong-Taek Lee wrote:
>>> @@ -1056,6 +1056,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>>>         struct mm_struct *mm = NULL;
>>>         struct task_struct *task;
>>>         int err = 0;
>>> +       int mm_users = 0;
>>>
>>>         task = get_proc_task(file_inode(file));
>>>         if (!task)
>>> @@ -1092,7 +1093,8 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>>>                 struct task_struct *p = find_lock_task_mm(task);
>>>
>>>                 if (p) {
>>> -                       if (atomic_read(&p->mm->mm_users) > 1) {
>>> +                       mm_users = atomic_read(&p->mm->mm_users);
>>> +                       if ((mm_users > 1) && (mm_users != get_nr_threads(p))) {
>>
>> How can this work (even before this patch)? When clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
>> is requested, copy_process() calls copy_signal() in order to copy sig->oom_score_adj and
>> sig->oom_score_adj_min before calling copy_mm() in order to increment mm->mm_users, doesn't it?
>> Then, we will get two different "struct signal_struct" with different oom_score_adj/oom_score_adj_min
>> but one "struct mm_struct" shared by two thread groups.
>>
> 
> Are you talking about race between __set_oom_adj and copy_process?
> If so, i agree with your opinion. It can not set oom_score_adj properly for copied process if __set_oom_adj
> check mm_users before copy_process calls copy_mm after copy_signal. Please correct me if i misunderstood anything.

You understand it correctly.

Reversing copy_signal() and copy_mm() is not sufficient either. We need to use a read/write lock
(read lock for copy_process() and write lock for __set_oom_adj()) in order to make sure that
the thread created by clone() becomes reachable from for_each_process() path in __set_oom_adj().

> 
>>>                                 mm = p->mm;
>>>                                 atomic_inc(&mm->mm_count);
>>>                         }
> 
