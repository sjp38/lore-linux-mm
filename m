Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id B14156B0062
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 10:10:36 -0400 (EDT)
Message-ID: <509282D6.8010808@hp.com>
Date: Thu, 01 Nov 2012 07:10:30 -0700
From: Don Morris <don.morris@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 20/31] sched, numa, mm/mpol: Make mempolicy home-node
 aware
References: <20121025121617.617683848@chello.nl> <20121025124834.012980641@chello.nl> <20121101135813.GX3888@suse.de>
In-Reply-To: <20121101135813.GX3888@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>

On 11/01/2012 06:58 AM, Mel Gorman wrote:
> On Thu, Oct 25, 2012 at 02:16:37PM +0200, Peter Zijlstra wrote:
>> Add another layer of fallback policy to make the home node concept
>> useful from a memory allocation PoV.
>>
>> This changes the mpol order to:
>>
>>  - vma->vm_ops->get_policy	[if applicable]
>>  - vma->vm_policy		[if applicable]
>>  - task->mempolicy
>>  - tsk_home_node() preferred	[NEW]
>>  - default_policy
>>
>> Note that the tsk_home_node() policy has Migrate-on-Fault enabled to
>> facilitate efficient on-demand memory migration.
>>
> 
> Makes sense and it looks like a VMA policy, if set, will still override
> the home_node policy as you'd expect. At some point this may need to cope
> with node hot-remove. Also, at some point this must be dealing with the
> case where mbind() is called but the home_node is not in the nodemask.
> Does that happen somewhere else in the series? (maybe I'll see it later)
> 

I'd expect one of the first things to be done in the sequence of
hot-removing a node would be to take the cpus offline (at least
out of being schedulable). Hence the tasks would be migrated
to other nodes/processors, which should result in a home node
update the same as if the scheduler had simply chosen a better
home for them anyway. The memory would then migrate either
via the home node change by the tasks themselves or via
migration to evacuate the outgoing node (with the preferred
migration target using the new home node).

As long as no one wants to do something crazy like offline
a node before taking the resources away from the scheduler
and memory management, it should all work out.

Don Morris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
