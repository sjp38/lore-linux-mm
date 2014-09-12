Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 1F71A6B0037
	for <linux-mm@kvack.org>; Thu, 11 Sep 2014 21:24:12 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id y10so64395pdj.22
        for <linux-mm@kvack.org>; Thu, 11 Sep 2014 18:24:11 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ns7si4637248pbc.179.2014.09.11.18.24.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 11 Sep 2014 18:24:11 -0700 (PDT)
Message-ID: <54124AC9.2040308@huawei.com>
Date: Fri, 12 Sep 2014 09:22:17 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] oom: break after selecting process to kill
References: <20140911213338.GA4098@localhost.localdomain>
In-Reply-To: <20140911213338.GA4098@localhost.localdomain>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Niv Yehezkel <executerx@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, mhocko@suse.cz, hannes@cmpxchg.org, oleg@redhat.com, wangnan0@huawei.com

On 2014/9/12 5:33, Niv Yehezkel wrote:
> There is no need to fallback and continue computing
> badness for each running process after we have found a
> process currently performing the swapoff syscall. We ought to
> immediately select this process for killing.
> 
> Signed-off-by: Niv Yehezkel <executerx@gmail.com>
> ---
>  mm/oom_kill.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1e11df8..68ac30e 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -305,6 +305,7 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  	struct task_struct *g, *p;
>  	struct task_struct *chosen = NULL;
>  	unsigned long chosen_points = 0;
> +	bool process_selected = false;
>  
>  	rcu_read_lock();
>  	for_each_process_thread(g, p) {
> @@ -315,7 +316,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		case OOM_SCAN_SELECT:
>  			chosen = p;
>  			chosen_points = ULONG_MAX;
> -			/* fall through */
> +			process_selected = true;
> +			break;
>  		case OOM_SCAN_CONTINUE:
>  			continue;
>  		case OOM_SCAN_ABORT:
> @@ -324,6 +326,8 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		case OOM_SCAN_OK:
>  			break;
>  		};
> +		if (process_selected)
> +			break;

Hi,
The following comment shows that we prefer thread group leaders for display purposes.
If we break here and two threads in a thread group are performing the swapoff syscall, maybe we can not get thread
group leaders.

Thanks!

>  		points = oom_badness(p, NULL, nodemask, totalpages);
>  		if (!points || points < chosen_points)
>  			continue;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
