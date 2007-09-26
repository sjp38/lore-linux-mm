Date: Tue, 25 Sep 2007 21:24:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm 7/5] oom: filter tasklist dump by mem_cgroup
In-Reply-To: <alpine.DEB.0.9999.0709252104180.30932@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709252119130.32009@chino.kir.corp.google.com>
References: <alpine.DEB.0.9999.0709250035570.11015@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709250037030.11015@chino.kir.corp.google.com> <6599ad830709251100n352028beraddaf2ac33ea8f6c@mail.gmail.com> <20070925181442.aeb7b205.pj@sgi.com>
 <alpine.DEB.0.9999.0709251819400.19627@chino.kir.corp.google.com> <20070925205632.47795637.pj@sgi.com> <alpine.DEB.0.9999.0709252104180.30932@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: menage@google.com, akpm@linux-foundation.org, clameter@sgi.com, balbir@linux.vnet.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Sep 2007, David Rientjes wrote:

> 	void dump_tasks(const struct mem_cgroup *mem)
> 	{
> 		struct task_struct *g, *p;
> 
> 		do_each_thread(g, p) {
> 			...
> 
> 			if (!task_in_mem_cgroup(p, mem)
> 				continue;
> 			if (!cpuset_mems_allowed_intersects(current, p))
> 				continue;
> 
> 			/* show the task information */
> 
> 		} while_each_thread(g, p);
> 	}
> 

By the way, the only reason I didn't code it like this was because tasks 
that overlap nodes in mems_allowed with the OOM-triggering task aren't 
necessarily excluded from being OOM killed, as I mentioned.  In other 
words, coding it like the above opens up the possibility of filtering the 
task that ends up getting killed.  Not a good idea.

Tasks that aren't in the same mem_cgroup, however, are filtered from the 
dump because they are explicitly excluded from being a target.  The check 
for that is actually misplaced and currently appears in badness() when it 
should appear in select_bad_process().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
