Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9A5676B00A9
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 22:55:02 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id oA42sxo8018582
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 19:55:00 -0700
Received: from pvg4 (pvg4.prod.google.com [10.241.210.132])
	by kpbe17.cbf.corp.google.com with ESMTP id oA42swvU023260
	for <linux-mm@kvack.org>; Wed, 3 Nov 2010 19:54:58 -0700
Received: by pvg4 with SMTP id 4so665829pvg.40
        for <linux-mm@kvack.org>; Wed, 03 Nov 2010 19:54:58 -0700 (PDT)
Date: Wed, 3 Nov 2010 19:54:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Re:[PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
In-Reply-To: <1288836733.2124.18.camel@myhost>
Message-ID: <alpine.DEB.2.00.1011031952110.28251@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain> <1288827804.2725.0.camel@localhost.localdomain> <alpine.DEB.2.00.1011031646110.7830@chino.kir.corp.google.com> <AANLkTimjfmLzr_9+Sf4gk0xGkFjffQ1VcCnwmCXA88R8@mail.gmail.com> <1288834737.2124.11.camel@myhost>
 <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com> <1288836733.2124.18.camel@myhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Cc: figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Thu, 4 Nov 2010, Figo.zhang wrote:

> In your new heuristic, you also get CAP_SYS_RESOURCE to protection.
> see fs/proc/base.c, line 1167:
> 	if (oom_score_adj < task->signal->oom_score_adj &&
> 			!capable(CAP_SYS_RESOURCE)) {
> 		err = -EACCES;
> 		goto err_sighand;
> 	}

That's unchanged from the old behavior with oom_adj.

> so i want to protect some process like normal process not
> CAP_SYS_RESOUCE, i set a small oom_score_adj , if new oom_score_adj is
> small than now and it is not limited resource, it will not adjust, that
> seems not right?
> 

Tasks without CAP_SYS_RESOURCE cannot lower their own oom_score_adj, 
otherwise it can trivially kill other tasks.  They can, however, increase 
their own oom_score_adj so the oom killer prefers to kill it first.

I think you may be confused: CAP_SYS_RESOURCE override resource limits.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
