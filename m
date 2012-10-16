Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 665C46B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 15:03:02 -0400 (EDT)
Message-ID: <507DAF56.9010403@parallels.com>
Date: Tue, 16 Oct 2012 23:02:46 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 14/14] Add documentation about the kmem controller
References: <1350382611-20579-1-git-send-email-glommer@parallels.com> <1350382611-20579-15-git-send-email-glommer@parallels.com> <0000013a6ad26c73-d043cf97-c44a-45c1-9cae-0a962e93a005-000000@email.amazonses.com>
In-Reply-To: <0000013a6ad26c73-d043cf97-c44a-45c1-9cae-0a962e93a005-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, devel@openvz.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Suleiman Souhlal <suleiman@google.com>

On 10/16/2012 10:25 PM, Christoph Lameter wrote:
> On Tue, 16 Oct 2012, Glauber Costa wrote:
> 
>>
>> + memory.kmem.limit_in_bytes      # set/show hard limit for kernel memory
>> + memory.kmem.usage_in_bytes      # show current kernel memory allocation
>> + memory.kmem.failcnt             # show the number of kernel memory usage hits limits
>> + memory.kmem.max_usage_in_bytes  # show max kernel memory usage recorded
> 
> Does it actually make sense to limit kernel memory? 

Yes.

> The user generally has
> no idea how much kernel memory a process is using and kernel changes can
> change the memory footprint. Given the fuzzy accounting in the kernel a
> large cache refill (if someone configures the slab batch count to be
> really big f.e.) can account a lot of memory to the wrong cgroup. The
> allocation could fail.
> 

It heavily depends on the type of the user. The user may not know how
much kernel memory precisely will be used, but he/she usually knows
quite well that it shouldn't be all cgroups together shouldn't use more
than available in the system.

IOW: It is usually safe to overcommit user memory, but not kernel
memory. This is absolutely crucial in any high-density container host,
and we've been doing this in OpenVZ for ages (in an uglier form than this)

> Limiting the total memory use of a process (U+K) would make more sense I
> guess. Only U is probably sufficient? In what way would a limitation on
> kernel memory in use be good?
> 

The kmem counter is also fed into the u counter. If the limit value of
"u" is equal or greater than "k", this is actually what you are doing.

For a lot of application yes, only U is sufficient. This is the default,
btw, since "k" is only even accounted if you set the limit.

All those use cases are detailed a bit below in this file.

A limitation of kernel memory use would be good, for example, to prevent
abuse from non-trusted containers in a high density, shared, container
environment.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
