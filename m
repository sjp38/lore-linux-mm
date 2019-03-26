Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 425DEC10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:18:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0721720830
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:18:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0721720830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C2DB6B0007; Tue, 26 Mar 2019 04:18:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94AC16B0008; Tue, 26 Mar 2019 04:18:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 839E56B000A; Tue, 26 Mar 2019 04:18:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1666B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:18:20 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id s26so1038955lfc.7
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:18:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=Fc7QEnSMJOCWnX0b0b1JDUi3K89Px3teW0qf+Ot4o6U=;
        b=gIhNJPuro+5oVuuUXKpA9VtSxoN3lyeX3Nq42rQnMsiUzbh6/YIq7vmXKiCN6Pr/2r
         nTwG0OeEqeEF42cxkD+XqDwzh7tFJncGyIY6eLxUC5r59dFG9uUZo3FtBxlFJCH647OZ
         5RIghBw0rB+q40N03e0eIzEoS8GbzK3sh00/4UkgBaEfkhIoN/gzcyPN8/qVgVFYbphE
         HTptkLjEjyrROdyrHiGav1cLy++6IbJE/lEyumgaGcprzUpxHksjpVsPBbNs89IgMby1
         kpnarIS9XN+AbH9ByhqqXW/pPH2hiSbzRiTORbtkI40LJz+h8fHh0ba3e84tBBjsR1nd
         1EVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAUZaPdtwNPhavyYc8zbqPmilph8zNR8edgZ0b8yxPHszO3mvxUw
	X+Ds274C+MWxx92EyY+ESqls5erYoru+CLZRNhCFw1CBVjJTPhuEEp2v9a0IMT23nTx5XF5/c5Y
	NblyGhNPfP0bCfv0gy78swWtopBMIvaqTfWWUnd6uMTBocMD0/6JgJhg6DUOZehPyxQ==
X-Received: by 2002:ac2:569b:: with SMTP id 27mr15679581lfr.24.1553588299309;
        Tue, 26 Mar 2019 01:18:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy99+LRr2xof0cfGdqC0H81Q9NcJnCgAFLU82QEmha1f/7sqDeqUbpO3CRIli2iDml0EA33
X-Received: by 2002:ac2:569b:: with SMTP id 27mr15679459lfr.24.1553588296726;
        Tue, 26 Mar 2019 01:18:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553588296; cv=none;
        d=google.com; s=arc-20160816;
        b=tWmVmJ7knzX+aJ306aZ0NP3o+oJ5iPuKgZBnD/o93Jnvi/LJ39wIIEtCZTRmBcZLks
         yuB+zoHlgsFmYJ1JFSTb8P+w/QkQ/X052VyB5W9EiYoGqRviGPwrfDlP/JvCPg7fPIde
         CIN4eOX8T9o+qiu3gk9JAwdwDyXN38WORFgmZYTzxyNYvvypdrfV4nJY9ZP0zj0GwCr6
         e7u40a1dmes07G310D22GNhnqNhgSve6ksYzFcxJacxIRZVGpmtFev9EQdk19IOBR1Wp
         NiAr223X8i3hCBnUWeuLtMAMXbM80tQP7zIa0rcZxBvWV3kjjckZ/sbTkPOFg7Xr3l/U
         YveA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=Fc7QEnSMJOCWnX0b0b1JDUi3K89Px3teW0qf+Ot4o6U=;
        b=ICiCc1AgAQE6vZqrWVnz0nWZtDUR59FTBkbgJBEImFAb1RlRw6mNFCY+OmM2E8mMpz
         FLY4KLvhESEZJwsRVNa/uqP/WVuKd6TIVZbrMkINyNkmUk4B9O2zW02SNxQKrGN/tq0A
         l43MzPbBY8Xq9aUAs41dDaB7xHJYoPg9skECJyjC2sPuGpulJGgZmYOH6BdnUCmkxXuv
         RINuYBAFUhCK42yZ6SjubVqmiyWXxGmYOskiaxXLnXB+tH8rN0aabingZrN/Yi6HEJH4
         vADv1UiwE7O9JrenuZWJZHLfH4HYM9SSeT7AQXJ48miLNAy7nHXYahcvv1Oc5KkzxLzM
         7dTw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id z23si12831979ljj.24.2019.03.26.01.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 01:18:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h8hHb-00080A-6M; Tue, 26 Mar 2019 11:18:07 +0300
Subject: Re: [PATCH 1/2] userfaultfd: use RCU to free the task struct when
 fork fails
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: Andrea Arcangeli <aarcange@redhat.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, zhong jiang <zhongjiang@huawei.com>,
 syzkaller-bugs@googlegroups.com,
 syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com,
 Mike Rapoport <rppt@linux.vnet.ibm.com>,
 Mike Kravetz <mike.kravetz@oracle.com>, Peter Xu <peterx@redhat.com>,
 Dmitry Vyukov <dvyukov@google.com>
References: <20190325225636.11635-1-aarcange@redhat.com>
 <20190325225636.11635-2-aarcange@redhat.com>
 <29e5c5ed-5efb-fe02-45a5-97903c88e0ec@virtuozzo.com>
Message-ID: <303ae124-dc01-0989-7cca-39ec7331d1be@virtuozzo.com>
Date: Tue, 26 Mar 2019 11:18:05 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <29e5c5ed-5efb-fe02-45a5-97903c88e0ec@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.03.2019 11:07, Kirill Tkhai wrote:
> On 26.03.2019 01:56, Andrea Arcangeli wrote:
>> MEMCG depends on the task structure not to be freed under
>> rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
>> mm->owner.
>>
>> An alternate possible fix would be to defer the delivery of the
>> userfaultfd contexts to the monitor until after fork() is guaranteed
>> to succeed. Such a change would require more changes because it would
>> create a strict ordering dependency where the uffd methods would need
>> to be called beyond the last potentially failing branch in order to be
>> safe. This solution as opposed only adds the dependency to common code
>> to set mm->owner to NULL and to free the task struct that was pointed
>> by mm->owner with RCU, if fork ends up failing. The userfaultfd
>> methods can still be called anywhere during the fork runtime and the
>> monitor will keep discarding orphaned "mm" coming from failed forks in
>> userland.
>>
>> This race condition couldn't trigger if CONFIG_MEMCG was set =n at
>> build time.
>>
>> Fixes: 893e26e61d04 ("userfaultfd: non-cooperative: Add fork() event")
>> Cc: stable@kernel.org
>> Tested-by: zhong jiang <zhongjiang@huawei.com>
>> Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>> ---
>>  kernel/fork.c | 34 ++++++++++++++++++++++++++++++++--
>>  1 file changed, 32 insertions(+), 2 deletions(-)
>>
>> diff --git a/kernel/fork.c b/kernel/fork.c
>> index 9dcd18aa210b..a19790e27afd 100644
>> --- a/kernel/fork.c
>> +++ b/kernel/fork.c
>> @@ -952,6 +952,15 @@ static void mm_init_aio(struct mm_struct *mm)
>>  #endif
>>  }
>>  
>> +static __always_inline void mm_clear_owner(struct mm_struct *mm,
>> +					   struct task_struct *p)
>> +{
>> +#ifdef CONFIG_MEMCG
>> +	if (mm->owner == p)
>> +		WRITE_ONCE(mm->owner, NULL);
>> +#endif
>> +}
>> +
>>  static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
>>  {
>>  #ifdef CONFIG_MEMCG
>> @@ -1331,6 +1340,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
>>  free_pt:
>>  	/* don't put binfmt in mmput, we haven't got module yet */
>>  	mm->binfmt = NULL;
>> +	mm_init_owner(mm, NULL);
>>  	mmput(mm);
>>  
>>  fail_nomem:
>> @@ -1662,6 +1672,24 @@ static inline void rcu_copy_process(struct task_struct *p)
>>  #endif /* #ifdef CONFIG_TASKS_RCU */
>>  }
>>  
>> +#ifdef CONFIG_MEMCG
>> +static void __delayed_free_task(struct rcu_head *rhp)
>> +{
>> +	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
>> +
>> +	free_task(tsk);
>> +}
>> +#endif /* CONFIG_MEMCG */
>> +
>> +static __always_inline void delayed_free_task(struct task_struct *tsk)
>> +{
>> +#ifdef CONFIG_MEMCG
>> +	call_rcu(&tsk->rcu, __delayed_free_task);
>> +#else /* CONFIG_MEMCG */
>> +	free_task(tsk);
>> +#endif /* CONFIG_MEMCG */
>> +}
>> +
>>  /*
>>   * This creates a new process as a copy of the old one,
>>   * but does not actually start it yet.
>> @@ -2123,8 +2151,10 @@ static __latent_entropy struct task_struct *copy_process(
>>  bad_fork_cleanup_namespaces:
>>  	exit_task_namespaces(p);
>>  bad_fork_cleanup_mm:
>> -	if (p->mm)
>> +	if (p->mm) {
>> +		mm_clear_owner(p->mm, p);
>>  		mmput(p->mm);
>> +	}
>>  bad_fork_cleanup_signal:
>>  	if (!(clone_flags & CLONE_THREAD))
>>  		free_signal_struct(p->signal);
>> @@ -2155,7 +2185,7 @@ static __latent_entropy struct task_struct *copy_process(
>>  bad_fork_free:
>>  	p->state = TASK_DEAD;
>>  	put_task_stack(p);
>> -	free_task(p);
>> +	delayed_free_task(p);
> 
> Can't call_rcu(&p->rcu, delayed_put_task_struct) be used instead this?

I mean:

refcount_set(&tsk->usage, 2);
call_rcu(&p->rcu, delayed_put_task_struct);

And:

diff --git a/kernel/fork.c b/kernel/fork.c
index 3c516c6f7ce4..27cdf61b51a1 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -715,7 +715,9 @@ static inline void put_signal_struct(struct signal_struct *sig)
 
 void __put_task_struct(struct task_struct *tsk)
 {
-	WARN_ON(!tsk->exit_state);
+	if (!tsk->exit_state)
+	/* Cleanup of copy_process() */
+		goto free;
 	WARN_ON(refcount_read(&tsk->usage));
 	WARN_ON(tsk == current);
 
@@ -727,6 +729,7 @@ void __put_task_struct(struct task_struct *tsk)
 	put_signal_struct(tsk->signal);
 
 	if (!profile_handoff_task(tsk))
+free:
 		free_task(tsk);
 }
 EXPORT_SYMBOL_GPL(__put_task_struct);

