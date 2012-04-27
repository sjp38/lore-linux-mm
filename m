Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id BDBFC6B00ED
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:13:34 -0400 (EDT)
Received: by iajr24 with SMTP id r24so1950812iaj.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 11:13:34 -0700 (PDT)
Date: Fri, 27 Apr 2012 11:13:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 17/23] kmem controller charge/uncharge infrastructure
In-Reply-To: <20120427113841.GB3514@somewhere.redhat.com>
Message-ID: <alpine.DEB.2.00.1204271110370.28516@chino.kir.corp.google.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com> <1335138820-26590-6-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204231522320.13535@chino.kir.corp.google.com> <20120424142232.GC8626@somewhere>
 <alpine.DEB.2.00.1204241319360.753@chino.kir.corp.google.com> <20120427113841.GB3514@somewhere.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 27 Apr 2012, Frederic Weisbecker wrote:

> > No, because memory is represented by mm_struct, not task_struct, so you 
> > must charge to p->mm->owner to allow for moving threads amongst memcgs 
> > later for memory.move_charge_at_immigrate.  You shouldn't be able to 
> > charge two different memcgs for memory represented by a single mm.
> 
> The idea I had was more that only the memcg of the thread that does the allocation
> is charged. But the problem is that this allocation can be later deallocated
> from another thread. So probably charging the owner is indeed the only sane
> way to go with user memory.
> 

It's all really the same concept: if we want to move memory of a process, 
willingly free memory in the process itself, or free memory of a process 
by way of the oom killer, we need a way to do that for the entire process 
so the accounting makes sense afterwards.  And since we have that 
requirement for user memory, it makes sense that its consistent with slab 
as well.  I don't think a thread of a process should be able to charge 
slab to one memcg while its user memory is charged to another memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
