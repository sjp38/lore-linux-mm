Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D591C6B0047
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 20:48:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o860mr0W027989
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 6 Sep 2010 09:48:54 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B331F45DE4F
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:48:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3BB3345DE52
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:48:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BB9781DB8044
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:48:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 729391DB803C
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 09:48:52 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] mm: oom_kill: use IS_ERR() instead of strict checking
In-Reply-To: <1283711592-7669-1-git-send-email-segooon@gmail.com>
References: <1283711592-7669-1-git-send-email-segooon@gmail.com>
Message-Id: <20100906094555.C8BB.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  6 Sep 2010 09:48:51 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Kulikov Vasiliy <segooon@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, kernel-janitors@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> From: Vasiliy Kulikov <segooon@gmail.com>
> 
> Use IS_ERR() instead of strict checking.

Umm...

I don't like this. IS_ERR() imply an argument is error code. but in
this case, we don't use error code. -1 mean oom special purpose meaning
value.

So, if we take this direction, It would be better to use EAGAIN or something
instead -1.



> 
> Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
> ---
>  Compile tested.
> 
>  mm/oom_kill.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index fc81cb2..2ee3350 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -514,7 +514,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
>  	read_lock(&tasklist_lock);
>  retry:
>  	p = select_bad_process(&points, limit, mem, NULL);
> -	if (!p || PTR_ERR(p) == -1UL)
> +	if (IS_ERR_OR_NULL(p))
>  		goto out;
>  
>  	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem, NULL,
> @@ -691,7 +691,7 @@ retry:
>  	p = select_bad_process(&points, totalpages, NULL,
>  			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
>  								 NULL);
> -	if (PTR_ERR(p) == -1UL)
> +	if (IS_ERR(p))
>  		goto out;
>  
>  	/* Found nothing?!?! Either we hang forever, or we panic. */
> -- 
> 1.7.0.4
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
