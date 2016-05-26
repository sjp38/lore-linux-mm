Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id E03F76B0253
	for <linux-mm@kvack.org>; Thu, 26 May 2016 10:42:10 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id fs8so115830473obb.2
        for <linux-mm@kvack.org>; Thu, 26 May 2016 07:42:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h141si3703252oib.188.2016.05.26.07.42.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 May 2016 07:42:10 -0700 (PDT)
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464266415-15558-1-git-send-email-mhocko@kernel.org>
	<1464266415-15558-7-git-send-email-mhocko@kernel.org>
	<201605262311.FFF64092.FFQVtOLOOMJSFH@I-love.SAKURA.ne.jp>
	<20160526142317.GC23675@dhcp22.suse.cz>
In-Reply-To: <20160526142317.GC23675@dhcp22.suse.cz>
Message-Id: <201605262341.GFE48463.OOtLFFMQSVFHOJ@I-love.SAKURA.ne.jp>
Date: Thu, 26 May 2016 23:41:54 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-mm@kvack.org
Cc: rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> +/*
> + * Checks whether the given task is dying or exiting and likely to
> + * release its address space. This means that all threads and processes
> + * sharing the same mm have to be killed or exiting.
> + */
> +static inline bool task_will_free_mem(struct task_struct *task)
> +{
> +	struct mm_struct *mm = NULL;
> +	struct task_struct *p;
> +	bool ret = false;

If atomic_read(&p->mm->mm_users) <= get_nr_threads(p), this returns "false".
According to previous version, I think this is "bool ret = true;".

> +
> +	/*
> +	 * If the process has passed exit_mm we have to skip it because
> +	 * we have lost a link to other tasks sharing this mm, we do not
> +	 * have anything to reap and the task might then get stuck waiting
> +	 * for parent as zombie and we do not want it to hold TIF_MEMDIE
> +	 */
> +	p = find_lock_task_mm(task);
> +	if (!p)
> +		return false;
> +
> +	if (!__task_will_free_mem(p)) {
> +		task_unlock(p);
> +		return false;
> +	}
> +
> +	/*
> +	 * Check whether there are other processes sharing the mm - they all have
> +	 * to be killed or exiting.
> +	 */
> +	if (atomic_read(&p->mm->mm_users) > get_nr_threads(p)) {
> +		mm = p->mm;
> +		/* pin the mm to not get freed and reused */
> +		atomic_inc(&mm->mm_count);
> +	}
> +	task_unlock(p);
> +
> +	if (mm) {
> +		rcu_read_lock();
> +		for_each_process(p) {
> +			bool vfork;
> +
> +			/*
> +			 * skip over vforked tasks because they are mostly
> +			 * independent and will drop the mm soon
> +			 */
> +			task_lock(p);
> +			vfork = p->vfork_done;
> +			task_unlock(p);
> +			if (vfork)
> +				continue;
> +
> +			ret = __task_will_free_mem(p);
> +			if (!ret)
> +				break;
> +		}
> +		rcu_read_unlock();
> +		mmdrop(mm);
> +	}
> +
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
