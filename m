Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id m8IIm8TW017185
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 04:48:08 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8IIlsil188422
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 04:47:54 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8IIlsld017312
	for <linux-mm@kvack.org>; Fri, 19 Sep 2008 04:47:54 +1000
Message-ID: <48D2A21E.7050806@linux.vnet.ibm.com>
Date: Thu, 18 Sep 2008 11:46:54 -0700
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm] memrlimit: fix task_lock() recursive locking
References: <48D29485.5010900@gmail.com>
In-Reply-To: <48D29485.5010900@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, containers@lists.linux-foundation.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Andrea Righi wrote:
> cgroup_mm_owner_callbacks() can be called with task_lock() held in
> mm_update_next_owner(), and all the .mm_owner_changed callbacks seem to
> be *always* called with task_lock() held.
> 
> Actually, memrlimit is using task_lock() via get_task_mm() in
> memrlimit_cgroup_mm_owner_changed(), raising the following recursive locking
> trace:

[snip]

Thanks for the BUG report()

[snip]

>  static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct cgroup *old_cgrp,
> @@ -246,7 +246,7 @@ static void memrlimit_cgroup_mm_owner_changed(struct cgroup_subsys *ss,
>  						struct task_struct *p)
>  {
>  	struct memrlimit_cgroup *memrcg, *old_memrcg;
> -	struct mm_struct *mm = get_task_mm(p);
> +	struct mm_struct *mm = get_task_mm_task_locked(p);
> 

Since we hold task_lock(), we know that p->mm cannot change and we don't have to
worry about incrementing mm_users. I think using just p->mm will work, we do
have checks to make sure we don't pick a kernel thread. I vote for going down
that road.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
