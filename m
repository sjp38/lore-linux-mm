Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id A624B6B006C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 16:21:22 -0400 (EDT)
Date: Tue, 29 May 2012 15:21:17 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
In-Reply-To: <4FC52CC6.7020109@parallels.com>
Message-ID: <alpine.DEB.2.00.1205291514090.2504@router.home>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-14-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290932530.4666@router.home> <4FC4F1A7.2010206@parallels.com> <alpine.DEB.2.00.1205291101580.6723@router.home>
 <4FC501E9.60607@parallels.com> <alpine.DEB.2.00.1205291222360.8495@router.home> <4FC506E6.8030108@parallels.com> <alpine.DEB.2.00.1205291424130.8495@router.home> <4FC52612.5060006@parallels.com> <alpine.DEB.2.00.1205291454030.2504@router.home>
 <4FC52CC6.7020109@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Wed, 30 May 2012, Glauber Costa wrote:

> Well, I'd have to dive in the code a bit more, but that the impression that
> the documentation gives me, by saying:
>
> "Cpusets constrain the CPU and Memory placement of tasks to only
> the resources within a task's current cpuset."
>
> is that you can't allocate from a node outside that set. Is this correct?

Basically yes but there are exceptions (like slab queues etc). Look at the
hardwall stuff too that allows more exceptions for kernel allocations to
use memory from other nodes.

> So extrapolating this to memcg, the situation is as follows:
>
> * You can't use more memory than what you are assigned to.
> * In order to do that, you need to account the memory you are using
> * and to account the memory you are using, all objects in the page
>   must belong to you.

Cpusets work at the page boundary and they do not have the requirement you
are mentioning of all objects in the page having to belong to a certain
cpusets. Let that go and things become much easier.

> With a predictable enough workload, this is a recipe for working around the
> very protection we need to establish: one can DoS a physical box full of
> containers, by always allocating in someone else's pages, and pinning kernel
> memory down. Never releasing it, so the shrinkers are useless.

Sure you can construct hyperthetical cases like that. But then that is
true already of other container like logic in the kernel already.

> So I still believe that if a page is allocated to a cgroup, all the objects in
> there belong to it  - unless of course the sharing actually means something -
> and identifying this is just too complicated.

We have never worked container like logic like that in the kernel due to
the complicated logic you would have to put in. The requirement that all
objects in a page come from the same container is not necessary. If you
drop this notion then things become very easy and the patches will become
simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
