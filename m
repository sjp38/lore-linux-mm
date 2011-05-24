Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 16E066B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:39:56 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4O1dsnK012590
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:39:54 -0700
Received: from pvg3 (pvg3.prod.google.com [10.241.210.131])
	by hpaq3.eem.corp.google.com with ESMTP id p4O1dpjr008826
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:39:52 -0700
Received: by pvg3 with SMTP id 3so3866843pvg.18
        for <linux-mm@kvack.org>; Mon, 23 May 2011 18:39:50 -0700 (PDT)
Date: Mon, 23 May 2011 18:39:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
In-Reply-To: <4DDB0B45.2080507@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105231838420.17729@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com> <4DDB0B45.2080507@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Tue, 24 May 2011, KOSAKI Motohiro wrote:

> > > Also, this patch move finding sacrifice child logic into
> > > select_bad_process(). It's necessary to implement adequate
> > > no root bonus recalculation. and it makes good side effect,
> > > current logic doesn't behave as the doc.
> > > 
> > 
> > This is unnecessary and just makes the oom killer egregiously long.  We
> > are already diagnosing problems here at Google where the oom killer holds
> > tasklist_lock on the readside for far too long, causing other cpus waiting
> > for a write_lock_irq(&tasklist_lock) to encounter issues when irqs are
> > disabled and it is spinning.  A second tasklist scan is simply a
> > non-starter.
> > 
> >   [ This is also one of the reasons why we needed to introduce
> >     mm->oom_disable_count to prevent a second, expensive tasklist scan. ]
> 
> You misunderstand the code. Both select_bad_process() and oom_kill_process()
> are under tasklist_lock(). IOW, no change lock holding time.
> 

A second iteration through the tasklist in select_bad_process() will 
extend the time that tasklist_lock is held, which is what your patch does.  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
