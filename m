Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 5218D6B004D
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 18:54:24 -0400 (EDT)
Received: by iajr24 with SMTP id r24so2287173iaj.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 15:54:23 -0700 (PDT)
Date: Tue, 24 Apr 2012 15:54:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 17/23] kmem controller charge/uncharge infrastructure
In-Reply-To: <4F971CC2.3090109@parallels.com>
Message-ID: <alpine.DEB.2.00.1204241550110.2537@chino.kir.corp.google.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1335138820-26590-6-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204231522320.13535@chino.kir.corp.google.com> <20120424142232.GC8626@somewhere> <4F96BB62.1030900@parallels.com>
 <alpine.DEB.2.00.1204241322390.753@chino.kir.corp.google.com> <4F971CC2.3090109@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 24 Apr 2012, Glauber Costa wrote:

> > Yes, for user memory, I see charging to p->mm->owner as allowing that
> > process to eventually move and be charged to a different memcg and there's
> > no way to do proper accounting if the charge is split amongst different
> > memcgs because of thread membership to a set of memcgs.  This is
> > consistent with charges for shared memory being moved when a thread
> > mapping it moves to a new memcg, as well.
> 
> But that's the problem.
> 
> When we are dealing with kernel memory, we are allocating a whole slab page.
> It is essentially impossible to track, given a page, which task allocated
> which object.
> 

Right, so you have to make the distinction that slab charges cannot be 
migrated by memory.move_charge_at_immigrate (and it's not even specified 
to do anything beyond user pages in Documentation/cgroups/memory.txt), but 
it would be consistent to charge the same memcg for a process's slab 
allocations as the process's user allocations.

My response was why we shouldn't be charging user pages to 
mem_cgroup_from_task(current) rather than 
mem_cgroup_from_task(current->mm->owner) which is what is currently 
implemented.

If that can't be changed so that we can still migrate user memory amongst 
memcgs for memory.move_charge_at_immigrate, then it seems consistent to 
have all allocations done by a task to be charged to the same memcg.  
Hence, I suggested current->mm->owner for slab charging as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
