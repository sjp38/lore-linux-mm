Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 272EAC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 06:36:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA8802087B
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 06:36:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA8802087B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0B92C6B0003; Mon, 29 Apr 2019 02:36:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0999A6B0006; Mon, 29 Apr 2019 02:36:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EC0DB6B0007; Mon, 29 Apr 2019 02:36:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD6246B0003
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 02:36:38 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id a2so5496573otk.13
        for <linux-mm@kvack.org>; Sun, 28 Apr 2019 23:36:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :date:from:user-agent:mime-version:to:cc:subject:references
         :in-reply-to:content-transfer-encoding;
        bh=K0/Rx02ib4tIOP0+YhfrvTX+aM2MX8pJ47m1TEJofSA=;
        b=qDUXBdu9oUUs3KjaLxAHq1Ccm/AIqfrI9VlyUPaxLecixjecybINQQIUBWES0Dp2k8
         DjVAWp7g/C5Hmv8e/Zw71Ao7HbAzbrsuW7sl0INFwsTPE+QEIO6lEwsirafTyFdUI2X6
         Km2I7OVvI8TFtn0BjMrzovVBZcu5BXs9L9gpkr8lR4lGp9ZSsj5PQy+CxpgSnbZPeC7m
         o1GGmu44ukgZ8u+tZQA1/6+jq1HlienAWiKJpP/znSVmUB9Xt9Dox7vX+mwDqvarYrvF
         5tqciYWDBs7Eq29eXRoCgPDuX4bpBQdqydTt4cc+LuW4GR0I4Rw1YXjbaHIR+3Uaqyau
         y4rQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
X-Gm-Message-State: APjAAAWmaSx0y1htFXVllRkl6xmHrtNFkkMlBdbT2MPNR/Uwckx1COpw
	waupldJEg5y6bsTUJpc9FsJfGG0PmeddwUwMRzeMeCPDXhLnvdSd3GU7O6TJ+PpDHEIjxpxxUNC
	ldoU2V78J+aFblgtecbe4yhc4U8oe72c2bUKPiiI5mf0zQLrogt2BtWSjMTqW1nJjFA==
X-Received: by 2002:a9d:5a0d:: with SMTP id v13mr22099177oth.345.1556519798234;
        Sun, 28 Apr 2019 23:36:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqythHv3bsWMjjfEMvo6/kzMOKrSxjCVywXDJCN90EhN35aqjyigHKaD8WK069t2wGEKvmA5
X-Received: by 2002:a9d:5a0d:: with SMTP id v13mr22099147oth.345.1556519797284;
        Sun, 28 Apr 2019 23:36:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556519797; cv=none;
        d=google.com; s=arc-20160816;
        b=u6rsXB3sMZgI//kBxS3qdTkqsF2dvSLZNgPsFi/nMa+MZXbbthgjm04rOonurXUiSM
         EtYl0U4t8h/HxjeLXvhoWcFl4Mu5JSJ/2iRNY2kT2DMAqjzmHWaZ65DLD5lEDn5iZ9fp
         i5ot8/s9ip9iRdWXoRV5/z0YVmvT2aSQCSZbSYrRurbDLO0dqBRmzsO23FqWOk2pNpYc
         nD9eteiHy9ojueBgF7lc6+RxoMdE1STTIXNMFFgK9/JMs+iV8giLDLWy1lItlFnK0HVH
         6mHPW1h/lh/Lz+JEjCigtZM2fQjFVe8SfVoBhC7zcoKOv9TfcIK4jbZxXZTIlUdahmtk
         vEEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:in-reply-to:references:subject:cc:to
         :mime-version:user-agent:from:date:message-id;
        bh=K0/Rx02ib4tIOP0+YhfrvTX+aM2MX8pJ47m1TEJofSA=;
        b=eARMXOZepMSPY6izyh1QyyLQsMtKwE9ibQ68XqLVt7F3yTdvzHhZmDchjGyqgCr6pH
         bSuxoae0XEnKH9DonmRQGtOmawD0NmVUzoqDfZEogLtVGY53GDHmo2LqLDiedVYbKo1H
         h4+2z/DvEO8prIXbv+DJqucXr2UC10XzXpF/OeZuVCLoz2Bts9ewWib8tUhlwRgi92Wl
         gIdnlaHMGmy9ccCwEhkx2FuFA6pP4rsgyHQl9sa9qIw4EE+bV4Uhj6/TwNF/YRWRQ6LJ
         JP+xe/aHFSQ4d6TNtitsaMJibLOpLgPSHH4ME4z5jctcqu65C+aaogRb7BoLRb/GxZlr
         EVNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from huawei.com (szxga04-in.huawei.com. [45.249.212.190])
        by mx.google.com with ESMTPS id q203si17071291oif.179.2019.04.28.23.36.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Apr 2019 23:36:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) client-ip=45.249.212.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of zhongjiang@huawei.com designates 45.249.212.190 as permitted sender) smtp.mailfrom=zhongjiang@huawei.com
Received: from DGGEMS403-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 4B282BDFA7E055B41855;
	Mon, 29 Apr 2019 14:36:33 +0800 (CST)
Received: from [127.0.0.1] (10.177.29.68) by DGGEMS403-HUB.china.huawei.com
 (10.3.19.203) with Microsoft SMTP Server id 14.3.439.0; Mon, 29 Apr 2019
 14:36:29 +0800
Message-ID: <5CC69B6C.9090608@huawei.com>
Date: Mon, 29 Apr 2019 14:36:28 +0800
From: zhong jiang <zhongjiang@huawei.com>
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:12.0) Gecko/20120428 Thunderbird/12.0.1
MIME-Version: 1.0
To: Andrea Arcangeli <aarcange@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
	<mhocko@kernel.org>, <linux-mm@kvack.org>, <syzkaller-bugs@googlegroups.com>,
	<syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com>, Mike Rapoport
	<rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Peter Xu
	<peterx@redhat.com>, Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH 1/1 v2] userfaultfd: use RCU to free the task struct when
 fork fails
References: <20190327084912.GC11927@dhcp22.suse.cz> <20190429035752.4508-1-aarcange@redhat.com>
In-Reply-To: <20190429035752.4508-1-aarcange@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.177.29.68]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

 On 2019/4/29 11:57, Andrea Arcangeli wrote:
> The task structure is freed while get_mem_cgroup_from_mm() holds
> rcu_read_lock() and dereferences mm->owner.
>
> get_mem_cgroup_from_mm()                failing fork()
> ----                                    ---
> task = mm->owner
>                                         mm->owner = NULL;
>                                         free(task)
> if (task) *task; /* use after free */
>
> The fix consists in freeing the task with RCU also in the fork failure
> case, exactly like it always happens for the regular exit(2)
> path. That is enough to make the rcu_read_lock hold in
> get_mem_cgroup_from_mm() (left side above) effective to avoid a use
> after free when dereferencing the task structure.
>
> An alternate possible fix would be to defer the delivery of the
> userfaultfd contexts to the monitor until after fork() is guaranteed
> to succeed. Such a change would require more changes because it would
> create a strict ordering dependency where the uffd methods would need
> to be called beyond the last potentially failing branch in order to be
> safe. This solution as opposed only adds the dependency to common code
> to set mm->owner to NULL and to free the task struct that was pointed
> by mm->owner with RCU, if fork ends up failing. The userfaultfd
> methods can still be called anywhere during the fork runtime and the
> monitor will keep discarding orphaned "mm" coming from failed forks in
> userland.
>
> This race condition couldn't trigger if CONFIG_MEMCG was set =n at
> build time.
>
> v2: improved commit header and reduced #ifdef material suggested by
> Michal Hocko.
>
> Fixes: 893e26e61d04 ("userfaultfd: non-cooperative: Add fork() event")
> Cc: stable@kernel.org
> Tested-by: zhong jiang <zhongjiang@huawei.com>
> Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  kernel/fork.c | 31 +++++++++++++++++++++++++++++--
>  1 file changed, 29 insertions(+), 2 deletions(-)
>
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 9dcd18aa210b..2628f3773ca8 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -952,6 +952,15 @@ static void mm_init_aio(struct mm_struct *mm)
>  #endif
>  }
>  
> +static __always_inline void mm_clear_owner(struct mm_struct *mm,
> +					   struct task_struct *p)
> +{
> +#ifdef CONFIG_MEMCG
> +	if (mm->owner == p)
> +		WRITE_ONCE(mm->owner, NULL);
> +#endif
> +}
> +
>  static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
>  {
>  #ifdef CONFIG_MEMCG
> @@ -1331,6 +1340,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
>  free_pt:
>  	/* don't put binfmt in mmput, we haven't got module yet */
>  	mm->binfmt = NULL;
> +	mm_init_owner(mm, NULL);
>  	mmput(mm);
>  
>  fail_nomem:
> @@ -1662,6 +1672,21 @@ static inline void rcu_copy_process(struct task_struct *p)
>  #endif /* #ifdef CONFIG_TASKS_RCU */
>  }
>  
> +static void __delayed_free_task(struct rcu_head *rhp)
> +{
> +	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
> +
> +	free_task(tsk);
> +}
if we disable the CONFIG_MEMCG,  __delay_free_task will not to be used.

Thanks,
zhong jiang
> +static __always_inline void delayed_free_task(struct task_struct *tsk)
> +{
> +	if (IS_ENABLED(CONFIG_MEMCG))
> +		call_rcu(&tsk->rcu, __delayed_free_task);
> +	else
> +		free_task(tsk);
> +}
> +
>  /*
>   * This creates a new process as a copy of the old one,
>   * but does not actually start it yet.
> @@ -2123,8 +2148,10 @@ static __latent_entropy struct task_struct *copy_process(
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
> @@ -2155,7 +2182,7 @@ static __latent_entropy struct task_struct *copy_process(
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


