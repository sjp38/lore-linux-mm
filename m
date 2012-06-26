Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 45F2D6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 16:38:15 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so685797pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 13:38:14 -0700 (PDT)
Date: Tue, 26 Jun 2012 13:38:12 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to iterate
 only over its own threads
In-Reply-To: <4FE94968.6010500@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 26 Jun 2012, Kamezawa Hiroyuki wrote:

> > This still requires tasklist_lock for the tasklist dump, iterating
> > children of the selected process, and killing all other threads on the
> > system sharing the same memory as the selected victim.  So while this
> > isn't a complete solution to tasklist_lock starvation, it significantly
> > reduces the amount of time that it is held.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> This seems good. Thank you!
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 

Thanks for the ack!

It's still not a perfect solution for the above reason.  We need 
tasklist_lock for oom_kill_process() for a few reasons:

 (1) if /proc/sys/vm/oom_dump_tasks is enabled, which is the default, 
     to iterate the tasklist

 (2) to iterate the selected process's children, and

 (3) to iterate the tasklist to kill all other processes sharing the 
     same memory.

I'm hoping we can avoid taking tasklist_lock entirely for memcg ooms to 
avoid the starvation problem at all.  We definitely still need to do (3) 
to avoid mm->mmap_sem deadlock if another thread sharing the same memory 
is holding the semaphore trying to allocate memory and waiting for current 
to exit, which needs the semaphore itself.  That can be done with 
rcu_read_lock(), however, and doesn't require tasklist_lock.

(1) can be done with rcu_read_lock() as well but I'm wondering if there 
would be a significant advantage doing this by a cgroup iterator as well.  
It may not be worth it just for the sanity of the code.

We can do (2) if we change to list_for_each_entry_rcu().

So I think I'll add another patch on top of this series to split up 
tasklist_lock handling even for the global oom killer and take references 
on task_struct like it is done in this patchset which should make avoiding 
taking tasklist_lock at all for memcg ooms much easier.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
