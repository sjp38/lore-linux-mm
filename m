Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DF2A6B000D
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 02:35:46 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id x44-v6so633157edd.17
        for <linux-mm@kvack.org>; Mon, 08 Oct 2018 23:35:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e2-v6si648310ejo.298.2018.10.08.23.35.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Oct 2018 23:35:45 -0700 (PDT)
Date: Tue, 9 Oct 2018 08:35:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
Message-ID: <20181009063541.GB8528@dhcp22.suse.cz>
References: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
 <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
 <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
 <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
 <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
 <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: ytk.lee@samsung.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

[I have only now noticed that the patch has been reposted]

On Mon 08-10-18 18:27:39, Tetsuo Handa wrote:
> On 2018/10/08 17:38, Yong-Taek Lee wrote:
> >>
> >> On 2018/10/08 15:14, Yong-Taek Lee wrote:
> >>>> On 2018/10/08 10:19, Yong-Taek Lee wrote:
> >>>>> @@ -1056,6 +1056,7 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> >>>>>         struct mm_struct *mm = NULL;
> >>>>>         struct task_struct *task;
> >>>>>         int err = 0;
> >>>>> +       int mm_users = 0;
> >>>>>
> >>>>>         task = get_proc_task(file_inode(file));
> >>>>>         if (!task)
> >>>>> @@ -1092,7 +1093,8 @@ static int __set_oom_adj(struct file *file, int oom_adj, bool legacy)
> >>>>>                 struct task_struct *p = find_lock_task_mm(task);
> >>>>>
> >>>>>                 if (p) {
> >>>>> -                       if (atomic_read(&p->mm->mm_users) > 1) {
> >>>>> +                       mm_users = atomic_read(&p->mm->mm_users);
> >>>>> +                       if ((mm_users > 1) && (mm_users != get_nr_threads(p))) {
> >>>>
> >>>> How can this work (even before this patch)? When clone(CLONE_VM without CLONE_THREAD/CLONE_SIGHAND)
> >>>> is requested, copy_process() calls copy_signal() in order to copy sig->oom_score_adj and
> >>>> sig->oom_score_adj_min before calling copy_mm() in order to increment mm->mm_users, doesn't it?
> >>>> Then, we will get two different "struct signal_struct" with different oom_score_adj/oom_score_adj_min
> >>>> but one "struct mm_struct" shared by two thread groups.
> >>>>
> >>>
> >>> Are you talking about race between __set_oom_adj and copy_process?
> >>> If so, i agree with your opinion. It can not set oom_score_adj properly for copied process if __set_oom_adj
> >>> check mm_users before copy_process calls copy_mm after copy_signal. Please correct me if i misunderstood anything.
> >>
> >> You understand it correctly.
> >>
> >> Reversing copy_signal() and copy_mm() is not sufficient either. We need to use a read/write lock
> >> (read lock for copy_process() and write lock for __set_oom_adj()) in order to make sure that
> >> the thread created by clone() becomes reachable from for_each_process() path in __set_oom_adj().
> >>
> > 
> > Thank you for your suggestion. But i think it would be better to seperate to 2 issues. How about think these
> > issues separately because there are no dependency between race issue and my patch. As i already explained,
> > for_each_process path is meaningless if there is only one thread group with many threads(mm_users > 1 but 
> > no other thread group sharing same mm). Do you have any other idea to avoid meaningless loop ? 
> 
> Yes. I suggest reverting commit 44a70adec910d692 ("mm, oom_adj: make sure processes
> sharing mm have same view of oom_score_adj") and commit 97fd49c2355ffded ("mm, oom:
> kill all tasks sharing the mm").

This would require a lot of other work for something as border line as
weird threading model like this. I will think about something more
appropriate - e.g. we can take mmap_sem for read while doing this check
and that should prevent from races with [v]fork.

-- 
Michal Hocko
SUSE Labs
