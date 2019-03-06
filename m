Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA292C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 05:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73B0020675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 05:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73B0020675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C4EF38E0003; Wed,  6 Mar 2019 00:53:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BFF668E0001; Wed,  6 Mar 2019 00:53:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B158F8E0003; Wed,  6 Mar 2019 00:53:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82D628E0001
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 00:53:24 -0500 (EST)
Received: by mail-vk1-f198.google.com with SMTP id 5so6270810vkg.20
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 21:53:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=5aK54sKmgAyjaaVEZhznIENPtXyWgxpUm7XMt5oi31s=;
        b=LJGeMf4vA3TZtkQzeX086uNZ8MC3fJCZ2moXMgqGc4cD8b3d/O+SkNzdQ9TXnzQ2xq
         5dSxIQIBUFp7iJD9UxDIlr6nl/6kJKpf8pKIahfs2IxsdkZdnHsFyQ7KSUbmwyzYv2Q2
         GkL0w6yPcIgqY1gjbJJV/vN8zCp4RuBnM5lvKeIezPmSQ/GlIAdbgrL4Mdhmz9O7Gz/h
         Gp5+qAMiIAZhoxdoHmN36EO/5Yc9oYDOrJ7zrnRdEFg1L7mFd4Xsisi5gbR6Zhv7xktW
         RaNCesaQdLzq8O/BdrjE9wNPUI8we61K1YNznBy8kVlLf38T7HZVL6HNy5zcYyyIXjdU
         pDGA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAWyEL5EphfCa7LwgzrzF6ZDZ0ffznMaI9XvZ0oLYU6L9nIkbneC
	JmMLv49Z3sHGTTyTJoMh16q9EIbOF03VwCFGfL7xAtSzEN/xcPd8iBWStzouRdrWA6SdaF+VFoG
	yVuyy3YpZmR3GGQSVBUCfP/Ui5MoR/AdhT7Vc9qZTkrDnbJSw+xOHnCpjex4H8H8PVA==
X-Received: by 2002:ab0:6451:: with SMTP id j17mr3214681uap.103.1551851604187;
        Tue, 05 Mar 2019 21:53:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqxLzHd5Bhqf5OZEfxyoKgkrg+das82A1W9JomrVLYs/wMUagFahP+1wbPa6nbXCr7uixBsW
X-Received: by 2002:ab0:6451:: with SMTP id j17mr3214655uap.103.1551851602964;
        Tue, 05 Mar 2019 21:53:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551851602; cv=none;
        d=google.com; s=arc-20160816;
        b=IrUE/dWqa+RnCXphOQhWZTw+M45/eLGptTiop0BsUITeiVFKTZ5RPo5daC2DtsJtuu
         uE3U/u+JNIbtZGKjyh6aU9gY+TCC0EmNdEKZt2fsmQtwNUid/03hY813hiVvwTxTumz9
         YSyvRopgltB5ipQ0787dGsCWkBGIjUfi0ZwhuCVq+luoKWBVR+fH05gg3wc6AVzeOvKJ
         HpF3hb6EI9AsKNay8qGI8m6VlAjXC+Y3NVlEIO0YA671P++4rPk9GcUsIkcPU1oAVDju
         ikGC6KLQu+gFfZm/OoH9osRfdhnUwfLOZqhXcS3odSljT3m4Gu6eYAgYXel7uMO8HhdD
         PVCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=5aK54sKmgAyjaaVEZhznIENPtXyWgxpUm7XMt5oi31s=;
        b=j6oAub3iFsE29HP2K7SrXRLNs+QelmlvR59nYZlhHVsHTMOcc5Nhd1K18gC460V92d
         6GeoRErrPc4sZDZm9xIhcND+QYRLZKaeB3jlrbJnoPeDP7uN38GPRCFsvMtGGYq4cgHo
         YLVx3DpVeh0U0u3SBW+NVlBn3iqHUIpKIEdCR2g8DAg7MwtCt6wM4y5+nPYYAtXR3fP4
         ETIL2gr/QKq+Vo7ZtEYJ+8FfUUV+89t+qUX0DbdS1DG7kk0WXZwvFn/FOOs2FHab0yqx
         o5A/eJjBay0Mnoc5W7ttEj/gbCnmChAZxCpFHS5GfOnpYyrk6AQqjpdrz9blEcV/mSdb
         F26g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id s21si271957vsk.18.2019.03.05.21.53.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 21:53:22 -0800 (PST)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS411-HUB.china.huawei.com (unknown [172.30.72.60])
	by Forcepoint Email with ESMTP id 7CB2C4973B1BD611F823;
	Wed,  6 Mar 2019 13:53:18 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS411-HUB.china.huawei.com
 (10.3.19.211) with Microsoft SMTP Server id 14.3.408.0; Wed, 6 Mar 2019
 13:53:13 +0800
Message-ID: <5C7F6048.2050802@huawei.com>
Date: Wed, 6 Mar 2019 13:53:12 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Andrea Arcangeli <aarcange@redhat.com>
CC: Dmitry Vyukov <dvyukov@google.com>, syzbot
	<syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>, Michal Hocko
	<mhocko@kernel.org>, <cgroups@vger.kernel.org>, Johannes Weiner
	<hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM
	<linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
	Vladimir Davydov <vdavydov.dev@gmail.com>, David Rientjes
	<rientjes@google.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox
	<willy@infradead.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka
	<vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Peter Xu
	<peterx@redhat.com>
Subject: Re: KASAN: use-after-free Read in get_mem_cgroup_from_mm
References: <00000000000006457e057c341ff8@google.com> <5C7BFE94.6070500@huawei.com> <CACT4Y+Z+CH0UTdSz-w_woMPrBwg-GuobV1Su4qd9ReffTkyfVg@mail.gmail.com> <5C7D2F82.40907@huawei.com> <CACT4Y+agwaszODNGJHCqn4fSk4Le9exn3Cau0nornJ0RaTpDJw@mail.gmail.com> <5C7D4500.3070607@huawei.com> <CACT4Y+b6y_3gTpR8LvNREHOV0TP7jB=Zp1L03dzpaz_SaeESng@mail.gmail.com> <5C7E1A38.2060906@huawei.com> <20190306020540.GA23850@redhat.com>
In-Reply-To: <20190306020540.GA23850@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/3/6 10:05, Andrea Arcangeli wrote:
> Hello everyone,
>
> [ CC'ed Mike and Peter ]
>
> On Tue, Mar 05, 2019 at 02:42:00PM +0800, zhong jiang wrote:
>> On 2019/3/5 14:26, Dmitry Vyukov wrote:
>>> On Mon, Mar 4, 2019 at 4:32 PM zhong jiang <zhongjiang@huawei.com> wrote:
>>>> On 2019/3/4 22:11, Dmitry Vyukov wrote:
>>>>> On Mon, Mar 4, 2019 at 3:00 PM zhong jiang <zhongjiang@huawei.com> wrote:
>>>>>> On 2019/3/4 15:40, Dmitry Vyukov wrote:
>>>>>>> On Sun, Mar 3, 2019 at 5:19 PM zhong jiang <zhongjiang@huawei.com> wrote:
>>>>>>>> Hi, guys
>>>>>>>>
>>>>>>>> I also hit the following issue. but it fails to reproduce the issue by the log.
>>>>>>>>
>>>>>>>> it seems to the case that we access the mm->owner and deference it will result in the UAF.
>>>>>>>> But it should not be possible that we specify the incomplete process to be the mm->owner.
>>>>>>>>
>>>>>>>> Any thoughts?
>>>>>>> FWIW syzbot was able to reproduce this with this reproducer.
>>>>>>> This looks like a very subtle race (threaded reproducer that runs
>>>>>>> repeatedly in multiple processes), so most likely we are looking for
>>>>>>> something like few instructions inconsistency window.
>>>>>>>
>>>>>> I has a little doubtful about the instrustions inconsistency window.
>>>>>>
>>>>>> I guess that you mean some smb barriers should be taken into account.:-)
>>>>>>
>>>>>> Because IMO, It should not be the lock case to result in the issue.
>>>>> Since the crash was triggered on x86 _most likley_ this is not a
>>>>> missed barrier. What I meant is that one thread needs to executed some
>>>>> code, while another thread is stopped within few instructions.
>>>>>
>>>>>
>>>> It is weird and I can not find any relationship you had said with the issue.:-(
>>>>
>>>> Because It is the cause that mm->owner has been freed, whereas we still deference it.
>>>>
>>>> From the lastest freed task call trace, It fails to create process.
>>>>
>>>> Am I miss something or I misunderstand your meaning. Please correct me.
>>> Your analysis looks correct. I am just saying that the root cause of
>>> this use-after-free seems to be a race condition.
>>>
>>>
>>>
>> Yep, Indeed,  I can not figure out how the race works. I will dig up further.
> Yes it's a race condition.
>
> We were aware about the non-cooperative fork userfaultfd feature
> creating userfaultfd file descriptor that gets reported to the parent
> uffd, despite they belong to mm created by failed forks.
>
> https://www.spinics.net/lists/linux-mm/msg136357.html
>
> The fork failure in my testcase happened because of signal pending
> that interrupted fork after the failed-fork uffd context, was already
> pushed to the userfaultfd reader/monitor. CRIU then takes care of
> filtering the failed fork cases so we didn't want to make the fork
> code more complicated just for userfaultfd.
>
> In reality if MEMCG is enabled at build time, mm->owner maintainance
> code now creates a race condition in the above case, with any fork
> failure.
>
> I pinged Mike yesterday to ask if my theory could be true for this bug
> and one solution he suggested is to do the userfaultfd_dup at a point
> where fork cannot fail anymore. That's precisely what we were
> wondering to do back then to avoid the failed fork reports to the
> non cooperative uffd monitor.
>
> That will solve the false positive deliveries that CRIU manager
> currently filters out too. From a theoretical standpoint it's also
> quite strange to even allow any uffd ioctl to run on a otherwise long
> gone mm created for a process that in the end wasn't even created (the
> mm got temporarily fully created, but no child task really ever used
> such mm). However that mm is on its way to exit_mmap as soon as the
> ioclt returns and this only ever happens during race conditions, so
> the way CRIU monitor works there wasn't anything fundamentally
> concerning about this detail, despite it's remarkably "strange". Our
> priority was to keep the fork code as simple as possible and keep
> userfaultfd as non intrusive as possible.

Hi, Andrea

I still not clear why uffd ioctl can use the incomplete process as the mm->owner.
and how to produce the race.

From your above explainations,   My underdtanding is that the process handling do_exexve
will have a temporary mm,  which will be used by the UUFD ioctl.

Thanks,
zhong jiang
> One alternative solution I'm wondering about for this memcg issue is
> to free the task struct with RCU also when fork has failed and to add
> the mm_update_next_owner before mmput. That will still report failed
> forks to the uffd monitor, so it's not the ideal fix, but since it's
> probably simpler I'm posting it below. Also I couldn't reproduce the
> problem with the testcase here yet.
>
> >From 6cbf9d377b705476e5226704422357176f79e32c Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Tue, 5 Mar 2019 19:21:37 -0500
> Subject: [PATCH 1/1] userfaultfd: use RCU to free the task struct when fork
>  fails if MEMCG
>
> MEMCG depends on the task structure not to be freed under
> rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
> mm->owner.
>
> A better fix would be to avoid registering forked vmas in userfaultfd
> contexts reported to the monitor, if case fork ends up failing.
>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  kernel/fork.c | 34 ++++++++++++++++++++++++++++++++--
>  1 file changed, 32 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index eb9953c82104..3bcbb361ffbc 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -953,6 +953,15 @@ static void mm_init_aio(struct mm_struct *mm)
>  #endif
>  }
>  
> +static __always_inline void mm_clear_owner(struct mm_struct *mm,
> +					   struct task_struct *p)
> +{
> +#ifdef CONFIG_MEMCG
> +	if (mm->owner == p)
> +		mm->owner = NULL;
> +#endif
> +}
> +
>  static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
>  {
>  #ifdef CONFIG_MEMCG
> @@ -1345,6 +1354,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
>  free_pt:
>  	/* don't put binfmt in mmput, we haven't got module yet */
>  	mm->binfmt = NULL;
> +	mm_init_owner(mm, NULL);
>  	mmput(mm);
>  
>  fail_nomem:
> @@ -1676,6 +1686,24 @@ static inline void rcu_copy_process(struct task_struct *p)
>  #endif /* #ifdef CONFIG_TASKS_RCU */
>  }
>  
> +#ifdef CONFIG_MEMCG
> +static void __delayed_free_task(struct rcu_head *rhp)
> +{
> +	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
> +
> +	free_task(tsk);
> +}
> +#endif /* CONFIG_MEMCG */
> +
> +static __always_inline void delayed_free_task(struct task_struct *tsk)
> +{
> +#ifdef CONFIG_MEMCG
> +	call_rcu(&tsk->rcu, __delayed_free_task);
> +#else /* CONFIG_MEMCG */
> +	free_task(tsk);
> +#endif /* CONFIG_MEMCG */
> +}
> +
>  /*
>   * This creates a new process as a copy of the old one,
>   * but does not actually start it yet.
> @@ -2137,8 +2165,10 @@ static __latent_entropy struct task_struct *copy_process(
>  bad_fork_cleanup_namespaces:
>  	exit_task_namespaces(p);
>  bad_fork_cleanup_mm:
> -	if (p->mm)
> +	if (p->mm) {
> +		mm_clear_owner(p->mm, p);
>  		mmput(p->mm);
> +	}
>  bad_fork_cleanup_signal:
>  	if (!(clone_flags & CLONE_THREAD))
>  		free_signal_struct(p->signal);
> @@ -2169,7 +2199,7 @@ static __latent_entropy struct task_struct *copy_process(
>  bad_fork_free:
>  	p->state = TASK_DEAD;
>  	put_task_stack(p);
> -	free_task(p);
> +	delayed_free_task(p);
>  fork_out:
>  	spin_lock_irq(&current->sighand->siglock);
>  	hlist_del_init(&delayed.node);
>
> .
>


