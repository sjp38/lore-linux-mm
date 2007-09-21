Date: Fri, 21 Sep 2007 11:56:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] hotplug cpu: move tasks in empty cpusets to parent
In-Reply-To: <20070921164255.44676149779@attica.americas.sgi.com>
Message-ID: <alpine.DEB.0.9999.0709211150450.11391@chino.kir.corp.google.com>
References: <20070921164255.44676149779@attica.americas.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Cliff Wickman <cpw@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 21 Sep 2007, Cliff Wickman wrote:

> This patch corrects a situation that occurs when one disables all the cpus
> in a cpuset.
> 
> Currently, the disabled (cpu-less) cpuset inherits the cpus of its parent,
> which may overlap its exclusive sibling.
> (You will get non-removable cpusets -- "Invalid argument")
> 
> Tasks of an empty cpuset should be moved to the cpuset which is the parent
> of their current cpuset. Or if the parent cpuset has no cpus, to its
> parent, etc.
> 

It looks like your patch is doing this for tasks that lose all of their 
mems too, but it seems like the better alternative is to prevent the user 
from doing echo -n > /dev/cpuset/my_cpuset/mems by returning -EINVAL in 
update_nodemask().  Are you trying to enable some functionality for node 
hot-unplug here?  If so, that needs documentation in the description.

> And the empty cpuset should be removed (if it is flagged notify_on_release).
> 

notify_on_release simply calls a userspace agent when the last task is 
removed, it doesn't necessarily specify that a cpuset should automatically 
be removed; that's up to the userspace agent.

There doesn't appear to be any support for memory_migrate cpusets in your 
patch, either, so that memory that is allocated on a cpuset's mems is 
automatically migrated to its new cpuset's mems when it loses all of its 
cpus.

		David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
