Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 719326B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 07:38:52 -0400 (EDT)
Received: by qabg27 with SMTP id g27so309506qab.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 04:38:51 -0700 (PDT)
Date: Fri, 27 Apr 2012 13:38:45 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH 17/23] kmem controller charge/uncharge infrastructure
Message-ID: <20120427113841.GB3514@somewhere.redhat.com>
References: <1334959051-18203-1-git-send-email-glommer@parallels.com>
 <1335138820-26590-6-git-send-email-glommer@parallels.com>
 <alpine.DEB.2.00.1204231522320.13535@chino.kir.corp.google.com>
 <20120424142232.GC8626@somewhere>
 <alpine.DEB.2.00.1204241319360.753@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1204241319360.753@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@openvz.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, Apr 24, 2012 at 01:21:43PM -0700, David Rientjes wrote:
> On Tue, 24 Apr 2012, Frederic Weisbecker wrote:
> 
> > > This seems horribly inconsistent with memcg charging of user memory since 
> > > it charges to p->mm->owner and you're charging to p.  So a thread attached 
> > > to a memcg can charge user memory to one memcg while charging slab to 
> > > another memcg?
> > 
> > Charging to the thread rather than the process seem to me the right behaviour:
> > you can have two threads of a same process attached to different cgroups.
> > 
> > Perhaps it is the user memory memcg that needs to be fixed?
> > 
> 
> No, because memory is represented by mm_struct, not task_struct, so you 
> must charge to p->mm->owner to allow for moving threads amongst memcgs 
> later for memory.move_charge_at_immigrate.  You shouldn't be able to 
> charge two different memcgs for memory represented by a single mm.

The idea I had was more that only the memcg of the thread that does the allocation
is charged. But the problem is that this allocation can be later deallocated
from another thread. So probably charging the owner is indeed the only sane
way to go with user memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
