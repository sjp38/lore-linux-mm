Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 803556B0087
	for <linux-mm@kvack.org>; Tue, 26 May 2015 12:37:46 -0400 (EDT)
Received: by wghq2 with SMTP id q2so102380065wgh.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 09:37:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id bn2si19104663wib.0.2015.05.26.09.37.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 09:37:44 -0700 (PDT)
Date: Tue, 26 May 2015 18:36:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 3/3] memcg: get rid of mm_struct::owner
Message-ID: <20150526163646.GA29968@redhat.com>
References: <1432641006-8025-1-git-send-email-mhocko@suse.cz> <1432641006-8025-4-git-send-email-mhocko@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1432641006-8025-4-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Vladimir Davydov <vdavydov@parallels.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 05/26, Michal Hocko wrote:
>
> @@ -426,17 +426,7 @@ struct mm_struct {
>  	struct kioctx_table __rcu	*ioctx_table;
>  #endif
>  #ifdef CONFIG_MEMCG
> -	/*
> -	 * "owner" points to a task that is regarded as the canonical
> -	 * user/owner of this mm. All of the following must be true in
> -	 * order for it to be changed:
> -	 *
> -	 * current == mm->owner
> -	 * current->mm != mm
> -	 * new_owner->mm == mm
> -	 * new_owner->alloc_lock is held
> -	 */
> -	struct task_struct __rcu *owner;
> +	struct mem_cgroup __rcu *memcg;

Yes, thanks, this is what I tried to suggest ;)

But I can't review this series. Simply because I know nothing about
memcs. I don't even know how to use it.

Just one question,

> +static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
> +{
> +	if (!p->mm)
> +		return NULL;
> +	return rcu_dereference(p->mm->memcg);
> +}

Probably I missed something, but it seems that the callers do not
expect it can return NULL. Perhaps sock_update_memcg() is fine, but
task_in_mem_cgroup() calls it when find_lock_task_mm() fails, and in
this case ->mm is NULL.

And in fact I can't understand what mem_cgroup_from_task() actually
means, with or without these changes.

And another question. I can't understand what happens when a task
execs... IOW, could you confirm that exec_mmap() does not need
mm_set_memcg(mm, oldmm->memcg) ?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
