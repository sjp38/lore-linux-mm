Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 729526B00A2
	for <linux-mm@kvack.org>; Fri, 12 Oct 2012 10:04:19 -0400 (EDT)
Message-ID: <50782344.3030209@redhat.com>
Date: Fri, 12 Oct 2012 10:03:48 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15/33] autonuma: alloc/free/init task_autonuma
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <1349308275-2174-16-git-send-email-aarcange@redhat.com> <20121011155302.GA3317@csn.ul.ie> <50770314.7060800@redhat.com> <20121011175953.GT1818@redhat.com>
In-Reply-To: <20121011175953.GT1818@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On 10/11/2012 01:59 PM, Andrea Arcangeli wrote:
> On Thu, Oct 11, 2012 at 01:34:12PM -0400, Rik van Riel wrote:

>> That is indeed a future optimization I have suggested
>> in the past. Allocation of this struct could be deferred
>> until the first time knuma_scand unmaps pages from the
>> process to generate NUMA page faults.
>
> I already tried this, and quickly noticed that for mm_autonuma we
> can't, or we wouldn't have memory to queue the "mm" into knuma_scand
> in the first place.
>
> For task_autonuma we could, but then we wouldn't be able to inherit
> the task_autonuma->task_autonuma_nid across clone/fork which kind of
> makes sense to me (and it's done by default without knob at the
> moment). It's actually more important for clone than for fork but it
> might be good for fork too if it doesn't exec immediately.
>
> Another option is to move task_autonuma_nid in the task_structure
> (it's in the stack so it won't cost RAM). Then I probably can defer
> the task_autonuma if I remove the child_inheritance knob.
>
> In knuma_scand we don't have the task pointer, so task_autonuma would
> need to be allocated in the NUMA page faults, the first time it fires.

One thing that could be done is have the (few) mm and
task specific bits directly in the mm and task structs,
and have the sized-by-number-of-nodes statistics in
a separate numa_stats struct.

At that point, the numa_stats struct could be lazily
allocated, reducing the memory allocations at fork
time by 2 (and the frees at exit time, for short lived
processes).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
