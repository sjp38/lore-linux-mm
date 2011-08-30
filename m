Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 089CD6B016B
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 18:06:57 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p7UM6tYG003330
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 15:06:55 -0700
Received: from pzk34 (pzk34.prod.google.com [10.243.19.162])
	by wpaz37.hot.corp.google.com with ESMTP id p7UM67or027867
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 15:06:54 -0700
Received: by pzk34 with SMTP id 34so215010pzk.7
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 15:06:53 -0700 (PDT)
Date: Tue, 30 Aug 2011 15:06:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] oom: remove oom_disable_count
In-Reply-To: <20110830152856.GA22754@redhat.com>
Message-ID: <alpine.DEB.2.00.1108301503510.2730@chino.kir.corp.google.com>
References: <20110727175624.GA3950@redhat.com> <20110728154324.GA22864@redhat.com> <alpine.DEB.2.00.1107281341060.16093@chino.kir.corp.google.com> <20110729141431.GA3501@redhat.com> <20110730143426.GA6061@redhat.com> <20110730152238.GA17424@redhat.com>
 <4E369372.80105@jp.fujitsu.com> <20110829183743.GA15216@redhat.com> <alpine.DEB.2.00.1108291611070.32495@chino.kir.corp.google.com> <alpine.DEB.2.00.1108300040490.21066@chino.kir.corp.google.com> <20110830152856.GA22754@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 30 Aug 2011, Oleg Nesterov wrote:

> > @@ -447,6 +431,9 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
> >  	for_each_process(q)
> >  		if (q->mm == mm && !same_thread_group(q, p) &&
> >  		    !(q->flags & PF_KTHREAD)) {
> 
> (I guess this is on top of -mm patch)
> 

Yes, it's based on 
oom-avoid-killing-kthreads-if-they-assume-the-oom-killed-threads-mm.patch 
which I thought would be pushed for the 3.1 rc series, we certainly don't 
want to SIGKILL kthreads :)

> > +			if (q->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> > +				continue;
> > +
> 
> Afaics, this is the only change apart from "removes mm->oom_disable_count
> entirely", looks reasonable to me.
> 

Yeah, it's necessary because this loop in oom_kill_task() kills all 
user threads in different thread groups unconditionally if they share the 
same mm, so we need to ensure that we aren't sending a SIGKILL to anything 
that is actually oom disabled.  Before, the check in oom_badness() would 
have prevented the task (`p' in this function) from being chosen in the 
first place.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
