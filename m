Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 12DFE6B0012
	for <linux-mm@kvack.org>; Mon, 23 May 2011 21:58:33 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p4O1wUEQ002026
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:58:30 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz5.hot.corp.google.com with ESMTP id p4O1wSGx023525
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 18:58:29 -0700
Received: by pvc30 with SMTP id 30so3701661pvc.34
        for <linux-mm@kvack.org>; Mon, 23 May 2011 18:58:28 -0700 (PDT)
Date: Mon, 23 May 2011 18:58:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 4/5] oom: don't kill random process
In-Reply-To: <4DDB1028.7000600@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105231856210.18353@chino.kir.corp.google.com>
References: <4DD61F80.1020505@jp.fujitsu.com> <4DD6207E.1070300@jp.fujitsu.com> <alpine.DEB.2.00.1105231529340.17840@chino.kir.corp.google.com> <4DDB0B45.2080507@jp.fujitsu.com> <alpine.DEB.2.00.1105231838420.17729@chino.kir.corp.google.com>
 <4DDB1028.7000600@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, caiqian@redhat.com, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, oleg@redhat.com

On Tue, 24 May 2011, KOSAKI Motohiro wrote:

> > > > This is unnecessary and just makes the oom killer egregiously long.  We
> > > > are already diagnosing problems here at Google where the oom killer
> > > > holds
> > > > tasklist_lock on the readside for far too long, causing other cpus
> > > > waiting
> > > > for a write_lock_irq(&tasklist_lock) to encounter issues when irqs are
> > > > disabled and it is spinning.  A second tasklist scan is simply a
> > > > non-starter.
> > > > 
> > > >    [ This is also one of the reasons why we needed to introduce
> > > >      mm->oom_disable_count to prevent a second, expensive tasklist scan.
> > > > ]
> > > 
> > > You misunderstand the code. Both select_bad_process() and
> > > oom_kill_process()
> > > are under tasklist_lock(). IOW, no change lock holding time.
> > > 
> > 
> > A second iteration through the tasklist in select_bad_process() will
> > extend the time that tasklist_lock is held, which is what your patch does.
> 
> It never happen usual case. Plz think when happen all process score = 1.
> 

I don't care if it happens in the usual case or extremely rare case.  It 
significantly increases the amount of time that tasklist_lock is held 
which causes writelock starvation on other cpus and causes issues, 
especially if the cpu being starved is updating the timer because it has 
irqs disabled, i.e. write_lock_irq(&tasklist_lock) usually in the clone or 
exit path.  We can do better than that, and that's why I proposed my patch 
to CAI that increases the resolution of the scoring and makes the root 
process bonus proportional to the amount of used memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
