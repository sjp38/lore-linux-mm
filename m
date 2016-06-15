Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id C00F26B025F
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:51:13 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d2so59416433qkg.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:51:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d189si21530270qkb.84.2016.06.15.07.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 07:51:13 -0700 (PDT)
Date: Wed, 15 Jun 2016 16:51:06 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 05/10] mm, oom: skip vforked tasks from being selected
Message-ID: <20160615145106.GC7944@redhat.com>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-6-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465473137-22531-6-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/09, Michal Hocko wrote:
>
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -1883,6 +1883,32 @@ extern int arch_task_struct_size __read_mostly;
>  #define TNF_FAULT_LOCAL	0x08
>  #define TNF_MIGRATE_FAIL 0x10
>  
> +static inline bool in_vfork(struct task_struct *tsk)
> +{
> +	bool ret;
> +
> +	/*
> +	 * need RCU to access ->real_parent if CLONE_VM was used along with
> +	 * CLONE_PARENT.
> +	 *
> +	 * We check real_parent->mm == tsk->mm because CLONE_VFORK does not
> +	 * imply CLONE_VM
> +	 *
> +	 * CLONE_VFORK can be used with CLONE_PARENT/CLONE_THREAD and thus
> +	 * ->real_parent is not necessarily the task doing vfork(), so in
> +	 * theory we can't rely on task_lock() if we want to dereference it.
> +	 *
> +	 * And in this case we can't trust the real_parent->mm == tsk->mm
> +	 * check, it can be false negative. But we do not care, if init or
> +	 * another oom-unkillable task does this it should blame itself.
> +	 */
> +	rcu_read_lock();
> +	ret = tsk->vfork_done && tsk->real_parent->mm == tsk->mm;
> +	rcu_read_unlock();
> +
> +	return ret;
> +}

ACK, but why sched.h ? It has a single caller in oom_kill.c.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
