Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD20CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:19:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7271920863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:19:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7271920863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 023A76B000A; Tue, 26 Mar 2019 04:19:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F15846B000C; Tue, 26 Mar 2019 04:19:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E05EA6B000D; Tue, 26 Mar 2019 04:19:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7A74B6B000A
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:19:53 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id s7so3627620lja.16
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:19:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=LLwxVbQBIBXrvjYgCS/+0JPeZNrMPwUzQ3SnQUjdhkE=;
        b=hSQYI/SVL12SOatWppKy/dskP6hgQVZhmutnw6D/oIqJQ7031nYu0cRQIFnDpbigd0
         B1IKRMIl+JWKwYrZYpglwS7yYV8MVPOMb12ZabZ/2YlqRX5+Q2yUE6GWkT/MB8Et/brP
         am50mtQrOA5Ug3yRQ1YEIcHXCq16DdDr6QEBRH+EpJtxNnzEa6WehNT1K3jmSppn2G5y
         OYWPMiEKjdWoE9dm7wVJn6uwSvYlczpnkPGoDhYrVWFSpftVADqcv4el3P7naRW4wJrz
         bbvGd39q8ELm4st8bK+nNVwNMdI9EE5dEG1t9j6P3p8srfusyqjnMeiSv3gK8XIQvE3y
         +8KQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVbWsglnWvBDCHVqErSoKYzY00JIa4fzCC2OmKxlcUDt8kKLeY6
	MPLoFArc6ZDDFqIQA/FTMCwodAdDExOvWzZk5w65EaI9f9tRFJxkM1mARHLBJx8Pgfm8qguxRcF
	Wzwy2DL0Vu09hxr8jPv042gMADKP/IgdAofo0lMDzf24nHhOTltx15h15R4t3LXtMnw==
X-Received: by 2002:a2e:6c0f:: with SMTP id h15mr15397901ljc.155.1553588392962;
        Tue, 26 Mar 2019 01:19:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwG24h99r801df4fu+OnfyT23t7Xp/r/hK4IjtcRjns2VmVhkdKxZoL0bNRCJEr8sHrUap0
X-Received: by 2002:a2e:6c0f:: with SMTP id h15mr15397856ljc.155.1553588392068;
        Tue, 26 Mar 2019 01:19:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553588392; cv=none;
        d=google.com; s=arc-20160816;
        b=jvonxcFdar05WnzKt06YNjk2a0DWeKqzqrTv+bWIAyl7wp55qiyKaXwBYMJqxHlBxc
         2vOGUsOfmRmkiFVQ0H3hcUgSrCIO1FKyPh4PaHerZFfiBYw8HidSP+mB9Cj4WnhJZrvT
         9KCRYTh0Kn3RGysW9tau/P3bz9sBOKSMJdIblQ4N1buBFtRfZtJvyrUT/vtjbMCiHaEQ
         RgPCOy1rrVQ4G3umQNKcSlvQ0x7Keeca7QNgG0penbiHMpRmrGl1MtveRJJ/+S/M0tup
         dPoWt3WpizyAY11ya4bjjwpE072zpEGzu7m0MaItrG1Vyh9nv2RGNi58VWBNS0CQoXb9
         120A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=LLwxVbQBIBXrvjYgCS/+0JPeZNrMPwUzQ3SnQUjdhkE=;
        b=Lv0sx8oXpQCqfA/E0gULgMnHWNQtBipvaHKIlh/0DvAbaeT3un+j9dQ5QXXidjJsFN
         sEqXs6v97i0SHkRMd+85dtxRVl7p5U/9kIwZxuR6j5LI+0hctvQSwR+mFidDgmTKaMyP
         s1VINVkDf4TMkzeRhHceJnMCPkVYKH9jlJXLUdKBBkikAEQFddSQlmfFC3eWa+Ht8nGd
         h+Jg45FUAcckgAoAnEluyqEaLIvSIEvBff9KcFbRvb+aNCZWJI3zyom35QmSzuuLIUfe
         CLhbJPELqFEkA2hw06XKKMXXmYNEKXTpQCXoT5HGE1hQZUH9Ua70us0907R1hCySaU1Z
         Jiyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l6si9843773ljh.184.2019.03.26.01.19.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 01:19:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h8hJB-00082L-TY; Tue, 26 Mar 2019 11:19:46 +0300
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
 <303ae124-dc01-0989-7cca-39ec7331d1be@virtuozzo.com>
Message-ID: <b6e5cda0-1134-8a42-3985-ec6728edab43@virtuozzo.com>
Date: Tue, 26 Mar 2019 11:19:45 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <303ae124-dc01-0989-7cca-39ec7331d1be@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.03.2019 11:18, Kirill Tkhai wrote:
> On 26.03.2019 11:07, Kirill Tkhai wrote:
>> On 26.03.2019 01:56, Andrea Arcangeli wrote:
>>> MEMCG depends on the task structure not to be freed under
>>> rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
>>> mm->owner.
>>>
>>> An alternate possible fix would be to defer the delivery of the
>>> userfaultfd contexts to the monitor until after fork() is guaranteed
>>> to succeed. Such a change would require more changes because it would
>>> create a strict ordering dependency where the uffd methods would need
>>> to be called beyond the last potentially failing branch in order to be
>>> safe. This solution as opposed only adds the dependency to common code
>>> to set mm->owner to NULL and to free the task struct that was pointed
>>> by mm->owner with RCU, if fork ends up failing. The userfaultfd
>>> methods can still be called anywhere during the fork runtime and the
>>> monitor will keep discarding orphaned "mm" coming from failed forks in
>>> userland.
>>>
>>> This race condition couldn't trigger if CONFIG_MEMCG was set =n at
>>> build time.
>>>
>>> Fixes: 893e26e61d04 ("userfaultfd: non-cooperative: Add fork() event")
>>> Cc: stable@kernel.org
>>> Tested-by: zhong jiang <zhongjiang@huawei.com>
>>> Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
>>> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
>>> ---
>>>  kernel/fork.c | 34 ++++++++++++++++++++++++++++++++--
>>>  1 file changed, 32 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/kernel/fork.c b/kernel/fork.c
>>> index 9dcd18aa210b..a19790e27afd 100644
>>> --- a/kernel/fork.c
>>> +++ b/kernel/fork.c
>>> @@ -952,6 +952,15 @@ static void mm_init_aio(struct mm_struct *mm)
>>>  #endif
>>>  }
>>>  
>>> +static __always_inline void mm_clear_owner(struct mm_struct *mm,
>>> +					   struct task_struct *p)
>>> +{
>>> +#ifdef CONFIG_MEMCG
>>> +	if (mm->owner == p)
>>> +		WRITE_ONCE(mm->owner, NULL);
>>> +#endif
>>> +}
>>> +
>>>  static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
>>>  {
>>>  #ifdef CONFIG_MEMCG
>>> @@ -1331,6 +1340,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
>>>  free_pt:
>>>  	/* don't put binfmt in mmput, we haven't got module yet */
>>>  	mm->binfmt = NULL;
>>> +	mm_init_owner(mm, NULL);
>>>  	mmput(mm);
>>>  
>>>  fail_nomem:
>>> @@ -1662,6 +1672,24 @@ static inline void rcu_copy_process(struct task_struct *p)
>>>  #endif /* #ifdef CONFIG_TASKS_RCU */
>>>  }
>>>  
>>> +#ifdef CONFIG_MEMCG
>>> +static void __delayed_free_task(struct rcu_head *rhp)
>>> +{
>>> +	struct task_struct *tsk = container_of(rhp, struct task_struct, rcu);
>>> +
>>> +	free_task(tsk);
>>> +}
>>> +#endif /* CONFIG_MEMCG */
>>> +
>>> +static __always_inline void delayed_free_task(struct task_struct *tsk)
>>> +{
>>> +#ifdef CONFIG_MEMCG
>>> +	call_rcu(&tsk->rcu, __delayed_free_task);
>>> +#else /* CONFIG_MEMCG */
>>> +	free_task(tsk);
>>> +#endif /* CONFIG_MEMCG */
>>> +}
>>> +
>>>  /*
>>>   * This creates a new process as a copy of the old one,
>>>   * but does not actually start it yet.
>>> @@ -2123,8 +2151,10 @@ static __latent_entropy struct task_struct *copy_process(
>>>  bad_fork_cleanup_namespaces:
>>>  	exit_task_namespaces(p);
>>>  bad_fork_cleanup_mm:
>>> -	if (p->mm)
>>> +	if (p->mm) {
>>> +		mm_clear_owner(p->mm, p);
>>>  		mmput(p->mm);
>>> +	}
>>>  bad_fork_cleanup_signal:
>>>  	if (!(clone_flags & CLONE_THREAD))
>>>  		free_signal_struct(p->signal);
>>> @@ -2155,7 +2185,7 @@ static __latent_entropy struct task_struct *copy_process(
>>>  bad_fork_free:
>>>  	p->state = TASK_DEAD;
>>>  	put_task_stack(p);
>>> -	free_task(p);
>>> +	delayed_free_task(p);
>>
>> Can't call_rcu(&p->rcu, delayed_put_task_struct) be used instead this?
> 
> I mean:
> 
> refcount_set(&tsk->usage, 2);

I.e., refcount_set(&tsk->usage, 1);

> call_rcu(&p->rcu, delayed_put_task_struct);
> 
> And:
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 3c516c6f7ce4..27cdf61b51a1 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -715,7 +715,9 @@ static inline void put_signal_struct(struct signal_struct *sig)
>  
>  void __put_task_struct(struct task_struct *tsk)
>  {
> -	WARN_ON(!tsk->exit_state);
> +	if (!tsk->exit_state)
> +	/* Cleanup of copy_process() */
> +		goto free;
>  	WARN_ON(refcount_read(&tsk->usage));
>  	WARN_ON(tsk == current);
>  
> @@ -727,6 +729,7 @@ void __put_task_struct(struct task_struct *tsk)
>  	put_signal_struct(tsk->signal);
>  
>  	if (!profile_handoff_task(tsk))
> +free:
>  		free_task(tsk);
>  }
>  EXPORT_SYMBOL_GPL(__put_task_struct);
> 

