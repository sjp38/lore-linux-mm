Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id B01A46B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 07:55:10 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id yl2so154178353pac.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 04:55:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z6si27994595paa.60.2016.05.27.04.55.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 May 2016 04:55:09 -0700 (PDT)
Subject: Re: [PATCH 1/6] mm, oom: do not loop over all tasks if there are no external tasks sharing mm
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160526153532.GG23675@dhcp22.suse.cz>
	<201605270114.IEI48969.MFFtFOJLQOOHSV@I-love.SAKURA.ne.jp>
	<20160527064510.GA27686@dhcp22.suse.cz>
	<20160527071507.GC27686@dhcp22.suse.cz>
	<20160527080319.GD27686@dhcp22.suse.cz>
In-Reply-To: <20160527080319.GD27686@dhcp22.suse.cz>
Message-Id: <201605271915.FHC65667.SMFHOFOQOLtFJV@I-love.SAKURA.ne.jp>
Date: Fri, 27 May 2016 19:15:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

Michal Hocko wrote:
> +bool task_has_external_users(struct task_struct *p)
> +{
> +	struct mm_struct *mm = NULL;
> +	struct task_struct *t;
> +	int active_threads = 0;
> +	bool ret = true;	/* be pessimistic */
> +
> +	rcu_read_lock();
> +	for_each_thread(p, t) {
> +		task_lock(t);
> +		if (likely(t->mm)) {
> +			active_threads++;
> +			if (!mm) {
> +				mm = t->mm;
> +				atomic_inc(&mm->mm_count);
> +			}
> +		}
> +		task_unlock(t);
> +	}
> +	rcu_read_unlock();
> +

I don't like this. We might sleep here long enough to change mm_users.

> +	if (mm) {
> +		if (atomic_read(&mm->mm_users) <= active_threads)
> +			ret = false;
> +		mmdrop(mm);
> +	}
> +	return ret;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
