Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id CD3806B002C
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 04:56:41 -0400 (EDT)
Message-ID: <4E9BEDA9.6000908@parallels.com>
Date: Mon, 17 Oct 2011 12:56:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 4/4] memcg: Document kernel memory accounting.
References: <1318639110-27714-1-git-send-email-ssouhlal@FreeBSD.org> <1318639110-27714-2-git-send-email-ssouhlal@FreeBSD.org> <1318639110-27714-3-git-send-email-ssouhlal@FreeBSD.org> <1318639110-27714-4-git-send-email-ssouhlal@FreeBSD.org> <1318639110-27714-5-git-send-email-ssouhlal@FreeBSD.org>
In-Reply-To: <1318639110-27714-5-git-send-email-ssouhlal@FreeBSD.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@FreeBSD.org>
Cc: gthelen@google.com, yinghan@google.com, kamezawa.hiroyu@jp.fujitsu.com, jbottomley@parallels.com, suleiman@google.com, linux-mm@kvack.org

On 10/15/2011 04:38 AM, Suleiman Souhlal wrote:
> Signed-off-by: Suleiman Souhlal<suleiman@google.com>
> ---
>   Documentation/cgroups/memory.txt |   33 ++++++++++++++++++++++++++++++++-
>   1 files changed, 32 insertions(+), 1 deletions(-)
>
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 06eb6d9..277cf25 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -220,7 +220,37 @@ caches are dropped. But as mentioned above, global LRU can do swapout memory
>   from it for sanity of the system's memory management state. You can't forbid
>   it by cgroup.
>
> -2.5 Reclaim
> +2.5 Kernel Memory
> +
> +A cgroup's kernel memory is accounted into its memory.usage_in_bytes and
> +is also shown in memory.stat as kernel_memory. Kernel memory does not get
> +counted towards the root cgroup's memory.usage_in_bytes, but still
> +appears in its kernel_memory.
> +
> +Upon cgroup deletion, all the remaining kernel memory gets moved to the
> +root cgroup.
> +
> +An accounted kernel memory allocation may trigger reclaim in that cgroup,
> +and may also OOM.
> +
> +Currently only slab memory allocated without __GFP_NOACCOUNT and
> +__GFP_NOFAIL gets accounted to the current process' cgroup.
> +
> +2.5.1 Slab
> +
> +Slab gets accounted on a per-page basis, which is done by using per-cgroup
> +kmem_caches. These per-cgroup kmem_caches get created on-demand, the first
> +time a specific kmem_cache gets used by a cgroup.

Well, let me first start with some general comments:

I think the approach I've taken, which is, allowing the cache creators 
to register themselves for cgroup usage, is better than scanning the 
list of existing caches. Couple of key reasons:

1) We then don't need another flag. _GFP_NOACCOUNT => doing nothing.
2) Less polution in the slab structure itself, which makes it have
higher chances of inclusion, and less duplicate work in the slub.
3) Easier to do per-cache tuning if we ever want to.

About, on-demand creation, I think it is a nice idea. But it may impact 
allocation latency on caches that we are sure to be used, like the 
dentry cache. So that gives us:

4) If the cache creator is registering itself, it can specify which 
behavior it wants. On-Demand creation vs Straight creation.

> +Slab memory that cannot be attributed to a cgroup gets charged to the root
> +cgroup.
> +
> +A per-cgroup kmem_cache is named like the original, with the cgroup's name
> +in parethesis.

I used the address for simplicity, but I like names better. Agree here.
Extending it: If a task resides in the cgroup itself, I think it should 
see its cache only, in /proc/slabinfo (selectable, take a look at 
https://lkml.org/lkml/2011/10/6/132 for more details)

> +When a kmem_cache gets migrated to the root cgroup, "dead" is appended to
> +its name, to indicated that it is not going to be used for new allocations.

Why not just remove it?

> +2.6 Reclaim
>
>   Each cgroup maintains a per cgroup LRU which has the same structure as
>   global VM. When a cgroup goes over its limit, we first try
> @@ -396,6 +426,7 @@ active_anon	- # of bytes of anonymous and swap cache memory on active
>   inactive_file	- # of bytes of file-backed memory on inactive LRU list.
>   active_file	- # of bytes of file-backed memory on active LRU list.
>   unevictable	- # of bytes of memory that cannot be reclaimed (mlocked etc).
> +kernel_memory   - # of bytes of kernel memory.
>
>   # status considering hierarchy (see memory.use_hierarchy settings)
>

Another

* I think usage of res_counters is better than relying on slab fields to 
impose limits,
* We still need the ability to restrict kernel memory usage separately 
from user memory, dependent on a selectable, as we already discussed here.
* I think we should do everything in our power to reduce overhead for 
the special case in which only the root cgroup exist . Take a look at 
what happened with the following thread: 
https://lkml.org/lkml/2011/10/13/201. To be honest, I think it is an 
idea we should least consider: not to account *anything* to the root 
cgroup (make a selectable if we want to conserve behaviour), user 
memory, kernel memory. Then we can keep native performance for 
non-cgroup users. (But that's another discussion anyway)

All in all, this is a good start. Both our approaches have a lot in 
common (well, which is not strange, given that we discussed them a lot 
on the past month =p, and I did like some concepts)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
