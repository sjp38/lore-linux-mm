Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3C1AC6B00B4
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 00:56:21 -0400 (EDT)
Subject: Re: Re:[PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
In-Reply-To: <alpine.DEB.2.00.1011031952110.28251@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain>
	 <1288827804.2725.0.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1011031646110.7830@chino.kir.corp.google.com>
	 <AANLkTimjfmLzr_9+Sf4gk0xGkFjffQ1VcCnwmCXA88R8@mail.gmail.com>
	 <1288834737.2124.11.camel@myhost>
	 <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
	 <1288836733.2124.18.camel@myhost>
	 <alpine.DEB.2.00.1011031952110.28251@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Nov 2010 12:42:10 +0800
Message-ID: <1288845730.2102.11.camel@myhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-03 at 19:54 -0700, David Rientjes wrote:
> On Thu, 4 Nov 2010, Figo.zhang wrote:
> 
> > In your new heuristic, you also get CAP_SYS_RESOURCE to protection.
> > see fs/proc/base.c, line 1167:
> > 	if (oom_score_adj < task->signal->oom_score_adj &&
> > 			!capable(CAP_SYS_RESOURCE)) {
> > 		err = -EACCES;
> > 		goto err_sighand;
> > 	}
> 
> That's unchanged from the old behavior with oom_adj.
> 
> > so i want to protect some process like normal process not
> > CAP_SYS_RESOUCE, i set a small oom_score_adj , if new oom_score_adj is
> > small than now and it is not limited resource, it will not adjust, that
> > seems not right?
> > 
> 
> Tasks without CAP_SYS_RESOURCE cannot lower their own oom_score_adj, 

CAP_SYS_RESOURCE == 1 means without resource limits just like a
superuser,
CAP_SYS_RESOURCE == 0 means hold resource limits, like normal user,
right?

a new lower oom_score_adj will protect the process, right?

Tasks without CAP_SYS_RESOURCE, means that it is not a superuser, why
user canot protect it by oom_score_adj?

like i want to protect my program such as gnome-terminal which is
without CAP_SYS_RESOURCE (have resource limits), 

[figo@myhost ~]$ ps -ax | grep gnome-ter
Warning: bad ps syntax, perhaps a bogus '-'? See
http://procps.sf.net/faq.html
 2280 ?        Sl     0:01 gnome-terminal
 8839 pts/0    S+     0:00 grep gnome-ter
[figo@myhost ~]$ cat /proc/2280/oom_adj 
3
[figo@myhost ~]$ echo -17 >  /proc/2280/oom_adj 
bash: echo: write error: Permission denied
[figo@myhost ~]$ 

so, i canot protect my program.


> otherwise it can trivially kill other tasks.  They can, however, increase 
> their own oom_score_adj so the oom killer prefers to kill it first.
> 
> I think you may be confused: CAP_SYS_RESOURCE override resource limits.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
