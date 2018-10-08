Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0829A6B0005
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 04:39:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id a64-v6so10632558pfg.16
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 01:39:01 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id s17-v6si16960132plq.339.2018.10.08.01.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 01:38:59 -0700 (PDT)
Received: from epcas1p3.samsung.com (unknown [182.195.41.47])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20181008083857epoutp01e96b582c5a220fb560ff3acbeb9616b7~blWAI5pQw1021510215epoutp01U
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 08:38:57 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find
 processes sharing mm
Reply-To: ytk.lee@samsung.com
From: Yong-Taek Lee <ytk.lee@samsung.com>
In-Reply-To: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
Message-ID: <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
Date: Mon, 08 Oct 2018 17:38:55 +0900
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
	<af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
	<20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
	<20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
	<CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Yong-Taek Lee <ytk.lee@samsung.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>
>On 2018/10/08 15:14, Yong-Taek Lee wrote:
>>> On 2018/10/08 10:19, Yong-Taek Lee wrote:
>>>> @@ -1056,6 +1056,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>>>>         struct mm_struct *mm = NULL;
>>>>         struct task_struct *task;
>>>>         int err = 0;
>>>> +       int mm_users = 0;
>>>>
>>>>         task = get_proc_task(file_inode(file));
>>>>         if (!task)
>>>> @@ -1092,7 +1093,8 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>>>>                 struct task_struct *p = find_lock_task_mm(task);
>>>>
>>>>                 if (p) {
>>>> -                       if (atomic_read(&p->mm->mm_users) > 1) {
>>>> +                       mm_users = atomic_read(&p->mm->mm_users);
>>>> +                       if ((mm_users > 1) && (mm_users != get_nr_threads(p))) {
>>>
>>> How can this work (even before this patch)? When clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
>>> is requested, copy_process() calls copy_signal() in order to copy sig->oom_score_adj and
>>> sig->oom_score_adj_min before calling copy_mm() in order to increment mm->mm_users, doesn't it?
>>> Then, we will get two different "struct signal_struct" with different oom_score_adj/oom_score_adj_min
>>> but one "struct mm_struct" shared by two thread groups.
>>>
>>
>> Are you talking about race between __set_oom_adj and copy_process?
>> If so, i agree with your opinion. It can not set oom_score_adj properly for copied process if __set_oom_adj
>> check mm_users before copy_process calls copy_mm after copy_signal. Please correct me if i misunderstood anything.
>
> You understand it correctly.
>
> Reversing copy_signal() and copy_mm() is not sufficient either. We need to use a read/write lock
> (read lock for copy_process() and write lock for __set_oom_adj()) in order to make sure that
> the thread created by clone() becomes reachable from for_each_process() path in __set_oom_adj().
>

Thank you for your suggestion. But i think it would be better to seperate to 2 issues. How about think these
issues separately because there are no dependency between race issue and my patch. As i already explained,
for_each_process path is meaningless if there is only one thread group with many threads(mm_users > 1 but 
no other thread group sharing same mm). Do you have any other idea to avoid meaningless loop ? 

>>
>>>>                                 mm = p->mm;
>>>>                                 atomic_inc(&mm->mm_count);
>>>>                         }
>>
>
