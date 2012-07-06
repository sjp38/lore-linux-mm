Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 54E506B008C
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 16:28:22 -0400 (EDT)
Message-ID: <4FF74A3B.80701@redhat.com>
Date: Fri, 06 Jul 2012 16:27:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 03/26] mm, mpol: add MPOL_MF_LAZY ...
References: <20120316144028.036474157@chello.nl>  <20120316144240.307470041@chello.nl> <20120323115025.GE16573@suse.de>  <4FF7147B.1050001@redhat.com> <1341605099.14051.23.camel@zaphod.localdomain>
In-Reply-To: <1341605099.14051.23.camel@zaphod.localdomain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 07/06/2012 04:04 PM, Lee Schermerhorn wrote:
> On Fri, 2012-07-06 at 12:38 -0400, Rik van Riel wrote:

>> 4. Putting a lot of pages in the swap cache ends up allocating
>>      swap space. This means this NUMA migration scheme will only
>>      work on systems that have a substantial amount of memory
>>      represented by swap space. This is highly unlikely on systems
>>      with memory in the TB range. On smaller systems, it could drive
>>      the system out of memory (to the OOM killer), by "filling up"
>>      the overflow swap with migration pages instead.
>> 5. In the long run, we want the ability to migrate transparent
>>      huge pages as one unit.  The reason is simple, the performance
>>      penalty for running on the wrong NUMA node (10-20%) is on the
>>      same order of magnitude as the performance penalty for running
>>      with 4kB pages instead of 2MB pages (5-15%).
>>
>>      Breaking up large pages into small ones, and having khugepaged
>>      reconstitute them on a random NUMA node later on, will negate
>>      the performance benefits of both NUMA placement and THP.

> When I originally posted the "migrate on fault" series, I posted a
> separate series with a "migration cache" to avoid the use of swap space
> for lazy migration: http://markmail.org/message/xgvvrnn2nk4nsn2e.
>
> The migration cache was originally implemented by Marcello Tosatti for
> the old memory hotplug project:
> http://marc.info/?l=linux-mm&m=109779128211239&w=4.
>
> The idea is that you don't need swap space for lazy migration, just an
> "address_space" where you can park an anon VMA's pte's while they're
> "unmapped" to cause migration faults.  Based on a suggestion from
> Christoph Lameter, I had tried to hide the migration cache behind the
> swap cache interface to minimize changes mainly in do_swap_page and
> vmscan/reclaim.  It seemed to work, but the difference in reference
> count semantics for the mig cache -- entry removed when last pte
> migrated/mapped -- makes coordination with exit teardown, uh, tricky.

That fixes one of the two problems, but using _PTE_NUMA
or _PAGE_PROTNONE looks like it would be both easier,
and solve both.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
