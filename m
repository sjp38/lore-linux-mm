Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D32008D0001
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 22:15:39 -0400 (EDT)
Subject: Re: Re:[PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
In-Reply-To: <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
References: <1288662213.10103.2.camel@localhost.localdomain>
	 <1288827804.2725.0.camel@localhost.localdomain>
	 <alpine.DEB.2.00.1011031646110.7830@chino.kir.corp.google.com>
	 <AANLkTimjfmLzr_9+Sf4gk0xGkFjffQ1VcCnwmCXA88R8@mail.gmail.com>
	 <1288834737.2124.11.camel@myhost>
	 <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Nov 2010 10:12:13 +0800
Message-ID: <1288836733.2124.18.camel@myhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-11-03 at 18:50 -0700, David Rientjes wrote:
> On Thu, 4 Nov 2010, Figo.zhang wrote:
> 
> > > > CAP_SYS_RESOURCE also had better get 3% bonus for protection.
> > > >
> > > 
> > > 
> > > Would you like to elaborate as to why?
> > > 
> > > 
> > 
> > process with CAP_SYS_RESOURCE capibility which have system resource
> > limits, like journaling resource on ext3/4 filesystem, RTC clock. so it
> > also the same treatment as process with CAP_SYS_ADMIN.
> > 
> 
> NACK, there's no justification that these tasks should be given a 3% 
> memory bonus in the oom killer heuristic; in fact, since they can allocate 
> without limits it is more important to target these tasks if they are 
> using an egregious amount of memory.  CAP_SYS_RESOURCE threads have the 
> ability to lower their own oom_score_adj values, thus, they should protect 
> themselves if necessary like everything else.

In your new heuristic, you also get CAP_SYS_RESOURCE to protection.
see fs/proc/base.c, line 1167:
	if (oom_score_adj < task->signal->oom_score_adj &&
			!capable(CAP_SYS_RESOURCE)) {
		err = -EACCES;
		goto err_sighand;
	}

so i want to protect some process like normal process not
CAP_SYS_RESOUCE, i set a small oom_score_adj , if new oom_score_adj is
small than now and it is not limited resource, it will not adjust, that
seems not right?





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
