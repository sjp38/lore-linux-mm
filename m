Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 2196D6B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 01:35:42 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1258209pbb.14
        for <linux-mm@kvack.org>; Tue, 26 Jun 2012 22:35:41 -0700 (PDT)
Date: Tue, 26 Jun 2012 22:35:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [rfc][patch 3/3] mm, memcg: introduce own oom handler to iterate
 only over its own threads
In-Reply-To: <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206262229380.32567@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com> <alpine.DEB.2.00.1206251847180.24838@chino.kir.corp.google.com> <4FE94968.6010500@jp.fujitsu.com> <alpine.DEB.2.00.1206261323260.8673@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Tue, 26 Jun 2012, David Rientjes wrote:

> It's still not a perfect solution for the above reason.  We need 
> tasklist_lock for oom_kill_process() for a few reasons:
> 
>  (1) if /proc/sys/vm/oom_dump_tasks is enabled, which is the default, 
>      to iterate the tasklist
> 
>  (2) to iterate the selected process's children, and
> 
>  (3) to iterate the tasklist to kill all other processes sharing the 
>      same memory.
> 
> I'm hoping we can avoid taking tasklist_lock entirely for memcg ooms to 
> avoid the starvation problem at all.  We definitely still need to do (3) 
> to avoid mm->mmap_sem deadlock if another thread sharing the same memory 
> is holding the semaphore trying to allocate memory and waiting for current 
> to exit, which needs the semaphore itself.  That can be done with 
> rcu_read_lock(), however, and doesn't require tasklist_lock.
> 
> (1) can be done with rcu_read_lock() as well but I'm wondering if there 
> would be a significant advantage doing this by a cgroup iterator as well.  
> It may not be worth it just for the sanity of the code.
> 
> We can do (2) if we change to list_for_each_entry_rcu().
> 

It turns out that task->children is not an rcu-protected list so this 
doesn't work.  Both (1) and (3) can be accomplished with 
rcu_read_{lock,unlock}() that can nest inside the tasklist_lock for the 
global oom killer.  (We could even split the global oom killer tasklist 
locking and optimize it seperately from this patchset.)

So we have a couple of options:

 - allow oom_kill_process() to do

	if (memcg)
		read_lock(&tasklist_lock);
	...
	if (memcg)
		read_unlock(&tasklist_lock);

   around the iteration over the victim's children.  This should solve the 
   issue since any other iteration over the entire tasklist would have 
   triggered the same starvation if it were that bad, or

 - suppress the iteration for memcg ooms and just kill the parent instead.

Comments?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
