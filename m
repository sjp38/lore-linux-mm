Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D166F6B017E
	for <linux-mm@kvack.org>; Mon,  1 Nov 2010 23:11:09 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id oA23Ar0I022587
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 20:10:53 -0700
Received: from pwi3 (pwi3.prod.google.com [10.241.219.3])
	by wpaz37.hot.corp.google.com with ESMTP id oA23ApYE025594
	for <linux-mm@kvack.org>; Mon, 1 Nov 2010 20:10:52 -0700
Received: by pwi3 with SMTP id 3so1416164pwi.34
        for <linux-mm@kvack.org>; Mon, 01 Nov 2010 20:10:51 -0700 (PDT)
Date: Mon, 1 Nov 2010 20:10:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH]oom-kill: direct hardware access processes should get
 bonus
In-Reply-To: <1288662213.10103.2.camel@localhost.localdomain>
Message-ID: <alpine.DEB.2.00.1011012008160.9383@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2 Nov 2010, Figo.zhang wrote:

> the victim should not directly access hardware devices like Xorg server,
> because the hardware could be left in an unpredictable state, although 
> user-application can set /proc/pid/oom_score_adj to protect it. so i think
> those processes should get 3% bonus for protection.
> 

Which applications are you referring to that cannot gracefully exit if 
killed?

> Signed-off-by: Figo.zhang <figo1802@gmail.com>
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

LSM's have this bonus for CAP_SYS_ADMIN, but not for CAP_SYS_RAWIO, so 
this comment is incorrect.

>  	 */
> -	if (has_capability_noaudit(p, CAP_SYS_ADMIN))
> +	if (has_capability_noaudit(p, CAP_SYS_ADMIN) ||
> +	    has_capability_noaudit(p, CAP_SYS_RESOURCE) ||
> +	    has_capability_noaudit(p, CAP_SYS_RAWIO))
>  		points -= 30;
>  
>  	/*

CAP_SYS_RAWIO had a much more dramatic impact in the previous heuristic to 
such a point that it would often allow memory hogging tasks to elude the 
oom killer at the expense of innocent tasks.  I'm not sure this is the 
best way to go.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
