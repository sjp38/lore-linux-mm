Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C91E6B0005
	for <linux-mm@kvack.org>; Fri, 20 May 2016 08:09:57 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id ne4so46106453lbc.1
        for <linux-mm@kvack.org>; Fri, 20 May 2016 05:09:57 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id i7si25348355wju.140.2016.05.20.05.09.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 05:09:55 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id q62so512431wmg.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 05:09:55 -0700 (PDT)
Date: Fri, 20 May 2016 14:09:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-ID: <20160520120954.GA5215@dhcp22.suse.cz>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160518125138.GH21654@dhcp22.suse.cz>
 <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
 <20160520075035.GF19172@dhcp22.suse.cz>
 <201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605202051.EBC82806.QLVMOtJOOFFFSH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

On Fri 20-05-16 20:51:56, Tetsuo Handa wrote:
[...]
> +static bool has_pending_victim(struct task_struct *p)
> +{
> +	struct task_struct *t;
> +	bool ret = false;
> +
> +	rcu_read_lock();
> +	for_each_thread(p, t) {
> +		if (test_tsk_thread_flag(t, TIF_MEMDIE)) {
> +			ret = true;
> +			break;
> +		}
> +	}
> +	rcu_read_unlock();
> +	return ret;
> +}

And so you do not speed up anything in the end because you have to
iterate all threads anyway yet you add quite some code on top. No I do
not like it. This is no longer a cleanup...

[...]
> Note that "[PATCH v3] mm,oom: speed up select_bad_process() loop." temporarily
> broke oom_task_origin(task) case, for oom_select_bad_process() might select
> a task without mm because oom_badness() which checks for mm != NULL will not be
> called.

How can we have oom_task_origin without mm? The flag is set explicitly
while doing swapoff resp. writing to ksm. We clear the flag before
exiting.

[...]

> By the way, I noticed that mem_cgroup_out_of_memory() might have a bug about its
> return value. It returns true if hit OOM_SCAN_ABORT after chosen != NULL, false
> if hit OOM_SCAN_ABORT before chosen != NULL. Which is expected return value?

true. Care to send a patch?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
