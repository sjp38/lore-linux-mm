Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0EB506B0071
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 00:05:38 -0500 (EST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC -v2 PATCH -mm] change anon_vma linking to fix multi-process server scalability issue
In-Reply-To: <20100117222140.0f5b3939@annuminas.surriel.com>
References: <20100117222140.0f5b3939@annuminas.surriel.com>
Message-Id: <20100121133448.73BD.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 21 Jan 2010 14:05:34 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, minchan.kim@gmail.com, lwoodman@redhat.com, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

Hi

> Thanks to some hints from peterz, and a day of debugging this weekend,
> this version boots all the way to udev, then appears to hang. I probably 
> made a silly mistake somewhere.  I am mailing this patch out in the hopes
> that my last silly mistakes will be seen by someone :)
> ----
> 
> The old anon_vma code can lead to scalability issues with heavily
> forking workloads.  Specifically, each anon_vma will be shared
> between the parent process and all its child processes.
> 
> In a workload with 1000 child processes and a VMA with 1000 anonymous
> pages per process that get COWed, this leads to a system with a million
> anonymous pages in the same anon_vma, each of which is mapped in just
> one of the 1000 processes.  However, the current rmap code needs to
> walk them all, leading to O(N) scanning complexity for each page.
> 
> This can result in systems where one CPU is walking the page tables
> of 1000 processes in page_referenced_one, while all other CPUs are
> stuck on the anon_vma lock.  This leads to catastrophic failure for
> a benchmark like AIM7, where the total number of processes can reach
> in the tens of thousands.  Real workloads are still a factor 10 less
> process intensive than AIM7, but they are catching up.
> 
> This patch changes the way anon_vmas and VMAs are linked, which
> allows us to associate multiple anon_vmas with a VMA.  At fork
> time, each child process gets its own anon_vmas, in which its
> COWed pages will be instantiated.  The parents' anon_vma is also
> linked to the VMA, because non-COWed pages could be present in
> any of the children.
> 
> This reduces rmap scanning complexity to O(1) for the pages of
> the 1000 child processes, with O(N) complexity for at most 1/N
> pages in the system.  This reduces the average scanning cost in
> heavily forking workloads from O(N) to 2.
> 
> The only real complexity in this patch stems from the fact that
> linking a VMA to anon_vmas now involves memory allocations. This
> means vma_adjust can fail, if it needs to attach a VMA to anon_vma
> structures. This in turn means error handling needs to be added
> to the calling functions.
> 
> A second source of complexity is that, because there can be
> multiple anon_vmas, the anon_vma linking in vma_adjust can
> no longer be done under "the" anon_vma lock.  To prevent the
> rmap code from walking up an incomplete VMA, this patch
> introduces the VM_LOCK_RMAP VMA flag.  This bit flag uses
> the same slot as the NOMMU VM_MAPPED_COPY, with an ifdef
> in mm.h to make sure it is impossible to compile a kernel
> that needs both symbolic values for the same bitflag.

I've only roughly reviewed this patch. So, perhaps I missed something.
My first impression is, this is slightly large but benefit is only affected
corner case.

If my remember is correct, you said you expect Nick's fair rwlock + Larry's rw-anon-lock
makes good result at some week ago. Why do you make alternative patch?
such way made bad result? or this patch have alternative benefit?

This patch seems to increase fork overhead instead decreasing vmscan overhead.
I'm not sure it is good deal.


[re-read page_referenced_anon() ... ]


Hmm...
Why can't we convert read side anon-vma walk to rcu? It need rcu aware vma
free, but anon_vma is alredy freed by rcu.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
