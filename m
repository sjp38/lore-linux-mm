Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EEDA16B016B
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 18:05:45 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p6QM5RK7016848
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 15:05:27 -0700
Received: from pzk32 (pzk32.prod.google.com [10.243.19.160])
	by kpbe19.cbf.corp.google.com with ESMTP id p6QM5PBk020665
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Jul 2011 15:05:26 -0700
Received: by pzk32 with SMTP id 32so1872908pzk.35
        for <linux-mm@kvack.org>; Tue, 26 Jul 2011 15:05:25 -0700 (PDT)
Date: Tue, 26 Jul 2011 15:05:23 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] oom: avoid killing kthreads if they assume the oom killed
 thread's mm
In-Reply-To: <20110726152724.GE17958@tiehlicka.suse.cz>
Message-ID: <alpine.DEB.2.00.1107261502410.19338@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1107251711460.26480@chino.kir.corp.google.com> <20110726152724.GE17958@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

On Tue, 26 Jul 2011, Michal Hocko wrote:

> > After selecting a task to kill, the oom killer iterates all processes and
> > kills all other threads that share the same mm_struct in different thread
> > groups.  It would not otherwise be helpful to kill a thread if its memory
> > would not be subsequently freed.
> > 
> > A kernel thread, however, may assume a user thread's mm by using
> > use_mm().  This is only temporary and should not result in sending a
> > SIGKILL to that kthread.
> 
> Good catch. Have you ever seen this happening?
> 

No, this is just another patch to make the kernel more use_mm()-friendly.  
Before that capability was introduced, it was possible to assume that a 
kthread would always have a NULL mm pointer, so it wasn't previously 
required for this code.

> > This patch ensures that only user threads and not kthreads are sent a
> > SIGKILL if they share the same mm_struct as the oom killed task.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
