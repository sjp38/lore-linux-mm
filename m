Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4AA476B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 00:23:02 -0500 (EST)
Message-ID: <4B57E442.5060700@redhat.com>
Date: Thu, 21 Jan 2010 00:21:06 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC -v2 PATCH -mm] change anon_vma linking to fix multi-process
 server scalability issue
References: <20100117222140.0f5b3939@annuminas.surriel.com> <20100121133448.73BD.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100121133448.73BD.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, minchan.kim@gmail.com, lwoodman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 01/21/2010 12:05 AM, KOSAKI Motohiro wrote:

>> In a workload with 1000 child processes and a VMA with 1000 anonymous
>> pages per process that get COWed, this leads to a system with a million
>> anonymous pages in the same anon_vma, each of which is mapped in just
>> one of the 1000 processes.  However, the current rmap code needs to
>> walk them all, leading to O(N) scanning complexity for each page.

>> This reduces rmap scanning complexity to O(1) for the pages of
>> the 1000 child processes, with O(N) complexity for at most 1/N
>> pages in the system.  This reduces the average scanning cost in
>> heavily forking workloads from O(N) to 2.

> I've only roughly reviewed this patch. So, perhaps I missed something.
> My first impression is, this is slightly large but benefit is only affected
> corner case.

At the moment it mostly triggers with artificial workloads, but
having 1000 client connections to eg. an Oracle database is not
unheard of.

The reason for wanting to fix the corner case is because it is
so incredibly bad.

> If my remember is correct, you said you expect Nick's fair rwlock + Larry's rw-anon-lock
> makes good result at some week ago. Why do you make alternative patch?
> such way made bad result? or this patch have alternative benefit?

After looking at the complexity figures (above), I suspect that
making a factor 5-10 speedup is not going to fix a factor 1000
increased complexity.

> This patch seems to increase fork overhead instead decreasing vmscan overhead.
> I'm not sure it is good deal.

My hope is that the overhead of adding a few small objects per VMA
will be unnoticable, compared to the overhead of refcounting pages,
handling page tables, etc.

The code looks like it could be a lot of anon_vma_chains, but in
practice the depth is limited because exec() wipes them all out.
Most of the time we will have just 0, 1 or 2 anon_vmas attached to
a VMA - one for the current process and one for the parent.

> Hmm...
> Why can't we convert read side anon-vma walk to rcu? It need rcu aware vma
> free, but anon_vma is alredy freed by rcu.

Changing the locking to RCU does not reduce the amount of work
that needs to be done in page_referenced_anon.  If we have 1000
siblings with 1000 pages each, we still end up scanning all
1000 processes for each of those 1000 pages in the pageout code.

Adding parallelism to that with better locking may speed it up
by the number of CPUs at most, which really may not help much
in these workloads.

Today having 1000 client connections to a forking server is
considered a lot, but I suspect it could be more common in a
few years. I would like Linux to be ready for those kinds of
workloads.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
