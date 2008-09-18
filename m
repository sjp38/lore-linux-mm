Received: by nf-out-0910.google.com with SMTP id c10so61164nfd.6
        for <linux-mm@kvack.org>; Thu, 18 Sep 2008 13:57:10 -0700 (PDT)
Message-ID: <48D2C0A2.4070203@gmail.com>
Date: Thu, 18 Sep 2008 22:57:06 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] memrlimit: fix task_lock() recursive locking
References: <48D29485.5010900@gmail.com> <48D2A21E.7050806@linux.vnet.ibm.com> <48D2B69D.8080404@gmail.com>
In-Reply-To: <48D2B69D.8080404@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrea Righi wrote:
>  static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct cgroup *old_cgrp,
> @@ -246,9 +246,9 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct task_struct *p)
>  {
>  	struct memrlimit_cgroup *memrcg, *old_memrcg;
> -	struct mm_struct *mm = get_task_mm(p);
> +	struct mm_struct *mm = p->mm;
>  
> -	BUG_ON(!mm);
> +	BUG_ON(!mm || (p->flags & PF_KTHREAD));
>  
>  	/*
>  	 * If we don't have a new cgroup, we just uncharge from the old one.

My bad! mmput() must be removed at the end of this function! (just hit
another bug).

Ignore this one and sorry for the noise. I'll send a new patch.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
