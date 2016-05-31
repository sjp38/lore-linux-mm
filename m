Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA216B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 17:43:43 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id e93so385241352qgf.3
        for <linux-mm@kvack.org>; Tue, 31 May 2016 14:43:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p11si1942134qgp.50.2016.05.31.14.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 14:43:42 -0700 (PDT)
Date: Tue, 31 May 2016 23:43:38 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Message-ID: <20160531214338.GB26582@redhat.com>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-5-git-send-email-mhocko@kernel.org>
 <20160530192856.GA25696@redhat.com>
 <20160531074247.GC26128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531074247.GC26128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 05/31, Michal Hocko wrote:
>
> On Mon 30-05-16 21:28:57, Oleg Nesterov wrote:
> >
> > I don't think we can trust vfork_done != NULL.
> >
> > copy_process() doesn't disallow CLONE_VFORK without CLONE_VM, so with this patch
> > it would be trivial to make the exploit which hides a memory hog from oom-killer.
>
> OK, I wasn't aware of this possibility.

Neither was me ;) I noticed this during this review.

> > Or I am totally confused?
>
> I cannot judge I am afraid. You are definitely much more familiar with
> all these subtle details than me.

OK, I just verified that clone(CLONE_VFORK|SIGCHLD) really works to be sure.

> +/* expects to be called with task_lock held */
> +static inline bool in_vfork(struct task_struct *tsk)
> +{
> +	bool ret;
> +
> +	/*
> +	 * need RCU to access ->real_parent if CLONE_VM was used along with
> +	 * CLONE_PARENT
> +	 */
> +	rcu_read_lock();
> +	ret = tsk->vfork_done && tsk->real_parent->mm == tsk->mm;
> +	rcu_read_unlock();
> +
> +	return ret;
> +}

Yes, but may I ask to add a comment? And note that "expects to be called with
task_lock held" looks misleading, we do not need the "stable" tsk->vfork_done
since we only need to check if it is NULL or not.

It would be nice to explain that

	1. we check real_parent->mm == tsk->mm because CLONE_VFORK does not
	   imply CLONE_VM

	2. CLONE_VFORK can be used with CLONE_PARENT/CLONE_THREAD and thus
	   ->real_parent is not necessarily the task doing vfork(), so in
	   theory we can't rely on task_lock() if we want to dereference it.

	   And in this case we can't trust the real_parent->mm == tsk->mm
	   check, it can be false negative. But we do not care, if init or
	   another oom-unkillable task does this it should blame itself.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
