Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 4B0A96B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 22:14:56 -0400 (EDT)
Message-ID: <4FB1BC3E.3070107@kernel.org>
Date: Tue, 15 May 2012 11:15:26 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Allow migration of mlocked page?
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de> <4FB08920.4010001@kernel.org> <20120514133944.GF29102@suse.de>
In-Reply-To: <20120514133944.GF29102@suse.de>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

On 05/14/2012 10:39 PM, Mel Gorman wrote:

> On Mon, May 14, 2012 at 01:25:04PM +0900, Minchan Kim wrote:
>>> <SNIP>
>>>
>>> If CMA decide they want to alter mlocked pages in this way, it's sortof
>>> ok. While CMA is being used, there are no expectations on the RT
>>> behaviour of the system - stalls are expected. In their use cases, CMA
>>> failing is far worse than access latency to an mlocked page being
>>> variable while CMA is running.
>>>
>>> Compaction on the other hand is during the normal operation of the
>>> machine. There are applications that assume that if anonymous memory
>>> is mlocked() then access to it is close to zero latency. They are
>>> not RT-critical processes (or they would disable THP) but depend on
>>> this. Allowing compaction to migrate mlocked() pages will result in bugs
>>> being reported by these people.
>>>
>>> I've received one bug this year about access latency to mlocked() regions but
>>> it turned out to be a file-backed region and related to when the write-fault
>>> is incurred. The ultimate fix was in the application but we'll get new bug
>>> reports if anonymous mlocked pages do not preserve the current guarantees
>>> on access latency.
>>>
>>
>> If so, what do you think about migration of mlocked pages by migrate_pages, cpuset_migrate_mm and memcg?
> 
> migrate_pages() is a core function used by a variety of different callers. It
> *optionally* could move mlocked pages and it would be up to the caller to
> specify if that was allowed.


Sorry I meant SYSCALL_DEFINE4(migrate_pages..);

> 
> cpuset_migrate_mm() should be allowed to move mlocked() pages because it's
> called in a path where the pages are on a node that should not longer be
> accessible to the processes. In this case, the latency hit is unavoidable
> and a bug reporter that says "there is an unexpected latency accessing memory
> while a process moves memory to another node" will be told to get a clue.


The point is that others except compaction already have migrated mlocked pages.

> 
> Where does memcg call migrate_pages()?


I don't know internal of memcg but just saw the code following as,
__unmap_and_move
{
	mem_cgroup_prepare_migration;
	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
	mem_cgroup_end_migration;
}

So I thougt memcg can migrate mlocked page, too.

> 
>> I think they all is done by under user's control while compaction happens regardless of user.
>> So do you think that's why compaction shouldn't migrate mlocked page?
>>
> 
> Yes. If the user takes an explicit action that causes latencies when
> accessing an mlocked anonymous region while the pages are migrated, that's
> fine. I still do not think that THP and khugepaged should cause unexpected
> latencies accessing mlocked anonymous regions because it is beyond the
> control of the application.
> 


Okay. Let's summary opinions in this thread until now.

1. mlock doesn't have pinning's semantic by definition of opengroup.
2. man page says "No page fault". It's bad. Maybe need fix up of man page.
3. Thera are several places which already have migrate mlocked pages but it's okay because
   it's done under user's control while compaction/khugepagd doesn't.
3. Many application already used mlock by semantic of 2. So let's break legacy application if possible.
4. CMA consider getting of free contiguos memory as top priority so latency may be okay in CMA
   while THP consider latency as top priority.
5. Let's define new API which would be 
   5.1 mlock(SOFT) - it can gaurantee memory-resident.
   5.2 mlock(HARD) - it can gaurantee 1 and pinning.
   Current mlock could be 5.1, then we should implement 5.2. Or
   Current mlock could be 5.2, then we should implement 5.1
   We can implement it by PG_pinned or vma flags.

One of clear point is that it's okay to migrate mlocked page in CMA.
And we can migrate mlocked anonymous pages and mlocked file pages by MIGRATE_ASYNC mode in compaction 
if we all agree Peter who says "mlocked mean NO MAJOR FAULT".


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
