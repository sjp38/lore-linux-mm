Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D2F46B000D
	for <linux-mm@kvack.org>; Sun,  7 Oct 2018 22:52:21 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 8-v6so16070215pfr.0
        for <linux-mm@kvack.org>; Sun, 07 Oct 2018 19:52:21 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id z31-v6si13860748pgl.123.2018.10.07.19.52.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Oct 2018 19:52:19 -0700 (PDT)
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
References: <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
Date: Mon, 8 Oct 2018 11:52:09 +0900
MIME-Version: 1.0
In-Reply-To: <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ytk.lee@samsung.com, "mhocko@kernel.org" <mhocko@kernel.org>, "mhocko@suse.com" <mhocko@suse.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 2018/10/08 10:19, Yong-Taek Lee wrote:
> @@ -1056,6 +1056,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>         struct mm_struct *mm = NULL;
>         struct task_struct *task;
>         int err = 0;
> +       int mm_users = 0;
> 
>         task = get_proc_task(file_inode(file));
>         if (!task)
> @@ -1092,7 +1093,8 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
>                 struct task_struct *p = find_lock_task_mm(task);
> 
>                 if (p) {
> -                       if (atomic_read(&p->mm->mm_users) > 1) {
> +                       mm_users = atomic_read(&p->mm->mm_users);
> +                       if ((mm_users > 1) && (mm_users != get_nr_threads(p))) {

How can this work (even before this patch)? When clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
is requested, copy_process() calls copy_signal() in order to copy sig->oom_score_adj and
sig->oom_score_adj_min before calling copy_mm() in order to increment mm->mm_users, doesn't it?
Then, we will get two different "struct signal_struct" with different oom_score_adj/oom_score_adj_min
but one "struct mm_struct" shared by two thread groups.

>                                 mm = p->mm;
>                                 atomic_inc(&mm->mm_count);
>                         }
