Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0917A6B0005
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 02:14:13 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id v9-v6so16316490pff.4
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 23:14:13 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id m13-v6si19269886pfd.123.2018.10.07.23.14.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 23:14:11 -0700 (PDT)
Received: from epcas1p2.samsung.com (unknown [182.195.41.46])
	by mailout3.samsung.com (KnoxPortal) with ESMTP id 20181008061409epoutp0386e7f8d7520cf0023af0c87250d6f8f1~bjXk5r5lQ1748617486epoutp03U
	for <linux-mm@kvack.org>; Mon,  8 Oct 2018 06:14:09 +0000 (GMT)
Mime-Version: 1.0
Subject: RE: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find
 processes sharing mm
Reply-To: ytk.lee@samsung.com
From: Yong-Taek Lee <ytk.lee@samsung.com>
In-Reply-To: <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
Message-ID: <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
Date: Mon, 08 Oct 2018 15:14:07 +0900
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="utf-8"
References: <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
	<20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
	<CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p5>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Yong-Taek Lee <ytk.lee@samsung.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

>On 2018/10/08 10:19, Yong-Taek Lee wrote:
>> @@ -1056,6 +1056,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>>         struct mm_struct *mm = NULL;
>>         struct task_struct *task;
>>         int err = 0;
>> +       int mm_users = 0;
>>
>>         task = get_proc_task(file_inode(file));
>>         if (!task)
>> @@ -1092,7 +1093,8 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>>                 struct task_struct *p = find_lock_task_mm(task);
>>
>>                 if (p) {
>> -                       if (atomic_read(&p->mm->mm_users) > 1) {
>> +                       mm_users = atomic_read(&p->mm->mm_users);
>> +                       if ((mm_users > 1) && (mm_users != get_nr_threads(p))) {
>
> How can this work (even before this patch)? When clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
> is requested, copy_process() calls copy_signal() in order to copy sig->oom_score_adj and
> sig->oom_score_adj_min before calling copy_mm() in order to increment mm->mm_users, doesn't it?
> Then, we will get two different "struct signal_struct" with different oom_score_adj/oom_score_adj_min
> but one "struct mm_struct" shared by two thread groups.
>

Are you talking about race between __set_oom_adj and copy_process?
If so, i agree with your opinion. It can not set oom_score_adj properly for copied process if __set_oom_adj
check mm_users before copy_process calls copy_mm after copy_signal. Please correct me if i misunderstood anything.

>>                                 mm = p->mm;
>>                                 atomic_inc(&mm->mm_count);
>>                         }
