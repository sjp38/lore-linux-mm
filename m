Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BB7E18D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 18:42:19 -0500 (EST)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p24NfkHk029941
	for <linux-mm@kvack.org>; Fri, 4 Mar 2011 15:41:46 -0800
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz37.hot.corp.google.com with ESMTP id p24NfiJ7030489
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 4 Mar 2011 15:41:45 -0800
Received: by pvc30 with SMTP id 30so629555pvc.20
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 15:41:44 -0800 (PST)
Date: Fri, 4 Mar 2011 15:41:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH rh6] mm: skip zombie in OOM-killer
In-Reply-To: <1299274256-2122-1-git-send-email-avagin@openvz.org>
Message-ID: <alpine.DEB.2.00.1103041541040.7795@chino.kir.corp.google.com>
References: <1299274256-2122-1-git-send-email-avagin@openvz.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Vagin <avagin@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 5 Mar 2011, Andrey Vagin wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 7dcca55..2fc554e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -311,7 +311,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		 * blocked waiting for another task which itself is waiting
>  		 * for memory. Is there a better alternative?
>  		 */
> -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE) && p->mm)
>  			return ERR_PTR(-1UL);
>  
>  		/*

I think it would be better to just do

	if (!p->mm)
		continue;

after the check for oom_unkillable_task() because everything that follows 
this really depends on p->mm being non-NULL to actually do anything 
useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
