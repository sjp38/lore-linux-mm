Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 582C26B0033
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 09:58:29 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id q4so3437068oic.12
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 06:58:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 22si1565138otu.450.2017.10.26.06.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Oct 2017 06:58:28 -0700 (PDT)
Date: Thu, 26 Oct 2017 15:58:25 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] pids: introduce find_get_task_by_vpid helper
Message-ID: <20171026135825.GA16528@redhat.com>
References: <1509023278-20604-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1509023278-20604-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Darren Hart <dvhart@infradead.org>, Balbir Singh <bsingharora@gmail.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On 10/26, Mike Rapoport wrote:
>
> There are several functions that do find_task_by_vpid() followed by
> get_task_struct(). We can use a helper function instead.

Yes, agreed, I was going to do this many times.

> --- a/kernel/futex.c
> +++ b/kernel/futex.c
> @@ -870,12 +870,7 @@ static struct task_struct *futex_find_get_task(pid_t pid)
>  {
>  	struct task_struct *p;
>  
> -	rcu_read_lock();
> -	p = find_task_by_vpid(pid);
> -	if (p)
> -		get_task_struct(p);
> -
> -	rcu_read_unlock();
> +	p = find_get_task_by_vpid(pid);
>  
>  	return p;

OK, but then I think you should remove futex_find_get_task() and convert
it callers to use the new helper.

> @@ -1103,11 +1103,7 @@ static struct task_struct *ptrace_get_task_struct(pid_t pid)
>  {
>  	struct task_struct *child;
>  
> -	rcu_read_lock();
> -	child = find_task_by_vpid(pid);
> -	if (child)
> -		get_task_struct(child);
> -	rcu_read_unlock();
> +	child = find_get_task_by_vpid(pid);
>  
>  	if (!child)
>  		return ERR_PTR(-ESRCH);

The same. ptrace_get_task_struct() should die imo.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
