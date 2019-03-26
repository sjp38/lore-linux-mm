Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C950C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:07:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC90E20856
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 08:07:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC90E20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BA586B0007; Tue, 26 Mar 2019 04:07:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 669AD6B0008; Tue, 26 Mar 2019 04:07:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50BB26B000A; Tue, 26 Mar 2019 04:07:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id D4F0C6B0007
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 04:07:51 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id t17so3616378ljt.21
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 01:07:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/eGgeYDEm0frWF/bB4DNtq0frq7rlUOFZFDF2VMnyck=;
        b=LTe0cLoX1aXywLu3CyKka/o1Ve0wsUFDi+30cR2zKMgqJRkNpvimkUyCwyNuuiR7b2
         cEMGGwM9uMT8j1AsSKko9NJcaQzfIuCQW6o4vPw7J/YsYQZpOBtVKZ6v4CCyqqBj2yq+
         186qD8+79+jJJc5WRxJ3gXI0v6Y90EYj9tl1wgvetQmCc/34sgg6Tc1acNQsYo/EpAY8
         mOPBqeWQnm/JxxhGc/GkoAnixerfgK7tiJXl989bpz0UCce/DygiYi7HYeWTPWJcjy2e
         4rcdk5uqxULUTrC4YUVse9KqI0B1OHAKQHDICWJ1k2vctv9LeaWVyjE6daxrSO8Iw81a
         324A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAX7yWObRhfv8b+Hpe669AswR3Sj0JwHEKaaMrAEt5qwkDp00p+m
	UoWT5D/dGJVBmUOhGJRrpFmaoBGTOwJfqPD+pBGiZrQ3+M3V0WqtCwukl1Qr3k+SE7NyT6RHJIn
	g/QvFBvR9sSqpDHceOBT5KyC0konEDAy4er2VyqUHCRLydQABD7ZU6jyLTuP9c+9R2A==
X-Received: by 2002:a2e:9d45:: with SMTP id y5mr11922472ljj.151.1553587671116;
        Tue, 26 Mar 2019 01:07:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgmXd2+QToDsAqzasH9nuFF5U9bIQik+zt+spPVyeDJ7Eu57KAEf9BKWqOwgWMSlIDSaqp
X-Received: by 2002:a2e:9d45:: with SMTP id y5mr11922421ljj.151.1553587669979;
        Tue, 26 Mar 2019 01:07:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553587669; cv=none;
        d=google.com; s=arc-20160816;
        b=D+F40wFlP1QQXEDIXF6IDb4uJ1qyw3quRM6Pu1qE+NY2z7xIBkgJxI0X3aT4mYz52S
         L3yfZb7do1PVbh1NhEjlFmzVSE8lIBjrk0kM8RCdr/ehZZ4J8rwJXDFiV4vVydNOpPW4
         jj1mzockN3bZ6Zft4GUdGS2fqAz6H7ty6HQRqxY4Wg8xModhwBb32uU/rfdOwfLSiyXo
         BuTojNdTpfzfKf1P2lLqJqAC231Ma/IFy7gWBiV6nQzafF/qSPM8vP0FDoxaHchVSj/l
         +z/4h7NVQYkdUVsDrezQ4oH9mCCEohKbyKQvTyXHcQLIKOAuIcpWx69V+WjwC5q0LBsr
         BrSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/eGgeYDEm0frWF/bB4DNtq0frq7rlUOFZFDF2VMnyck=;
        b=zUJBny9WwjiGm3Z/u6WdyCrTCMK3BdOGb5NTPI4+2sQHVccvLHi8WSZf0scFM7J9A6
         /FZG5/PPnHj17e4lAenAmZRghZXTVI+PLdLgGdfynz2qRYGFA/AquYGLeBzvfO9iN3Wi
         o3grTX9+fhxrGVthP8xB8wgoy050iQBOCNJpwlyIMFkALEqf7Navsvm8ucoz6ouYw47p
         q1yR7nTs8vIibnedwlOe8JALwn/NVYiRnVIzx/JLS10JZaQVW/Vq89b5yEB8kkGtfQ72
         QY0G6zGtQhh8svVP/INPXMK47zLtxrGwsNl0ofqjsZcEuIAuUiygnfg+0d8OSUq1aro5
         pdcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id a8si11794230lfl.70.2019.03.26.01.07.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 01:07:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169]
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1h8h7O-0007sP-1d; Tue, 26 Mar 2019 11:07:34 +0300
Subject: Re: [PATCH 1/2] userfaultfd: use RCU to free the task struct when
 fork fails
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
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <29e5c5ed-5efb-fe02-45a5-97903c88e0ec@virtuozzo.com>
Date: Tue, 26 Mar 2019 11:07:33 +0300
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190325225636.11635-2-aarcange@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.03.2019 01:56, Andrea Arcangeli wrote:
> MEMCG depends on the task structure not to be freed under
> rcu_read_lock() in get_mem_cgroup_from_mm() after it dereferences
> mm->owner.
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
> Fixes: 893e26e61d04 ("userfaultfd: non-cooperative: Add fork() event")
> Cc: stable@kernel.org
> Tested-by: zhong jiang <zhongjiang@huawei.com>
> Reported-by: syzbot+cbb52e396df3e565ab02@syzkaller.appspotmail.com
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  kernel/fork.c | 34 ++++++++++++++++++++++++++++++++--
>  1 file changed, 32 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index 9dcd18aa210b..a19790e27afd 100644
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
> @@ -1662,6 +1672,24 @@ static inline void rcu_copy_process(struct task_struct *p)
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
> @@ -2123,8 +2151,10 @@ static __latent_entropy struct task_struct *copy_process(
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
> @@ -2155,7 +2185,7 @@ static __latent_entropy struct task_struct *copy_process(
>  bad_fork_free:
>  	p->state = TASK_DEAD;
>  	put_task_stack(p);
> -	free_task(p);
> +	delayed_free_task(p);

Can't call_rcu(&p->rcu, delayed_put_task_struct) be used instead this?

Kirill

