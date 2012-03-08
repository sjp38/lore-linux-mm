Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 820776B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 20:11:57 -0500 (EST)
Date: Wed, 7 Mar 2012 17:11:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] mm, counters: remove task argument to sync_mm_rss
 and __sync_task_rss_stat
Message-Id: <20120307171155.f9bb71b6.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1203061919260.21806@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1203061919260.21806@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 6 Mar 2012 19:21:39 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> -static void __sync_task_rss_stat(struct task_struct *task, struct mm_struct *mm)
> +static void __sync_task_rss_stat(struct mm_struct *mm)
>  {
>  	int i;
>  
>  	for (i = 0; i < NR_MM_COUNTERS; i++) {
> -		if (task->rss_stat.count[i]) {
> -			add_mm_counter(mm, i, task->rss_stat.count[i]);
> -			task->rss_stat.count[i] = 0;
> +		if (current->rss_stat.count[i]) {
> +			add_mm_counter(mm, i, current->rss_stat.count[i]);
> +			current->rss_stat.count[i] = 0;
>  		}
>  	}
> -	task->rss_stat.events = 0;
> +	current->rss_stat.events = 0;
>  }

hm, with my gcc it's beneficial to cache `current' in a local.  But
when I tried that, Weird Things happened, because gcc has gone and
decided to inline __sync_task_rss_stat() into its callers.  I don't see
how that could have been the right thing to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
