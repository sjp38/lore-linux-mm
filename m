Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DEE8A6B00A1
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 05:41:42 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oA9AfesE010661
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Nov 2010 19:41:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 609FB45DE4E
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:41:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BC0E45DE53
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:41:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C45721DB8018
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:41:38 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 585341DB8014
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 19:41:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH]oom-kill: direct hardware access processes should get bonus
In-Reply-To: <1288662213.10103.2.camel@localhost.localdomain>
References: <1288662213.10103.2.camel@localhost.localdomain>
Message-Id: <20101109193913.BC98.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  9 Nov 2010 19:41:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <figo1802@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, "rientjes@google.com" <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> 
> the victim should not directly access hardware devices like Xorg server,
> because the hardware could be left in an unpredictable state, although 
> user-application can set /proc/pid/oom_score_adj to protect it. so i think
> those processes should get 3% bonus for protection.
> 
> Signed-off-by: Figo.zhang <figo1802@gmail.com>

I was surprised this issue is still there. This was pointed out half year 
ago already :-/


> ---
> mm/oom_kill.c |    8 +++++---
>  1 files changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 4029583..df6a9da 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -195,10 +195,12 @@ unsigned int oom_badness(struct task_struct *p, struct mem_cgroup *mem,
>  	task_unlock(p);
>  
>  	/*
> -	 * Root processes get 3% bonus, just like the __vm_enough_memory()
> -	 * implementation used by LSMs.
> +	 * Root and direct hardware access processes get 3% bonus, just like the
> +	 * __vm_enough_memory() implementation used by LSMs.
>  	 */

This comment is incorrect. LSM is care only CAP_SYS_ADMIN.

> -	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> +	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
> +	    has_capability_noaudit(p, CAP_SYS_RAWIO))
>  		points -= 30;

But yes. OOM need to care both CAP_SYS_RESOURCE and CAP_SYS_RAWIO.

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
