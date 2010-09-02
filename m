Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 3659D6B004A
	for <linux-mm@kvack.org>; Wed,  1 Sep 2010 20:25:56 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o820Prlj001309
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 2 Sep 2010 09:25:53 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E8B8C3270C3
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:25:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BD0E21EF084
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:25:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5D8111DB8056
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:25:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F12A91DB804A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 09:25:50 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch -mm 2/2] oom: use old_mm for oom_disable_count in exec
In-Reply-To: <alpine.DEB.2.00.1009011659490.14215@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1009011659020.14215@chino.kir.corp.google.com> <alpine.DEB.2.00.1009011659490.14215@chino.kir.corp.google.com>
Message-Id: <20100902092039.D05C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  2 Sep 2010 09:25:50 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> active_mm in the exec() path can be for an unrelated thread, so the 
> oom_disable_count logic should use old_mm instead.
> 
> Reported-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  fs/exec.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/exec.c b/fs/exec.c
> --- a/fs/exec.c
> +++ b/fs/exec.c
> @@ -752,8 +752,8 @@ static int exec_mmap(struct mm_struct *mm)
>  	tsk->mm = mm;
>  	tsk->active_mm = mm;
>  	activate_mm(active_mm, mm);
> -	if (tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> -		atomic_dec(&active_mm->oom_disable_count);
> +	if (old_mm && tsk->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +		atomic_dec(&old_mm->oom_disable_count);
>  		atomic_inc(&tsk->mm->oom_disable_count);

Looks good. However you need to use tsk->signal->oom_adj == OOM_DISABLE because
I removed OOM_SCORE_ADJ_MIN.



>  	}
>  	task_unlock(tsk);
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
