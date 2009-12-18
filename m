Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 6E9C36B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 05:28:04 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBIAS1ds007585
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 18 Dec 2009 19:28:01 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 351EE45DE4F
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 19:28:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 00E2845DE52
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 19:28:01 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D056A1DB8060
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 19:28:00 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7455E1DB805A
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 19:28:00 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] vmscan: limit concurrent reclaimers in shrink_zone
In-Reply-To: <4B2A22C0.8080001@redhat.com>
References: <20091217193818.9FA9.A69D9226@jp.fujitsu.com> <4B2A22C0.8080001@redhat.com>
Message-Id: <20091218184046.6547.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 18 Dec 2009 19:27:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: lwoodman@redhat.com
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> KOSAKI Motohiro wrote:
> > (offlist)
> >
> > Larry, May I ask current status of following your issue?
> > I don't reproduce it. and I don't hope to keep lots patch are up in the air.
> >   
> 
> Yes, sorry for the delay but I dont have direct or exclusive access to 
> these large systems
> and workloads.  As far as I can tell this patch series does help prevent 
> total system
> hangs running AIM7.  I did have trouble with the early postings mostly 
> due to using sleep_on()
> and wakeup() but those appear to be fixed. 
> 
> However, I did add more debug code and see ~10000 processes blocked in 
> shrink_zone_begin().
> This is expected but bothersome, practically all of the processes remain 
> runnable for the entire
> duration of these AIM runs.  Collectively all these runnable processes 
> overwhelm the VM system. 
> There are many more runnable processes now than were ever seen before, 
> ~10000 now versus
> ~100 on RHEL5(2.6.18 based).  So, we have also been experimenting around 
> with some of the
> CFS scheduler tunables to see of this is responsible... 

What point you bother? throughput, latency or somethingelse? Actually, 
unfairness itself is right thing from VM view. because perfectly fairness
VM easily makes livelock. (e.g. process-A swap out process-B's page, parocess-B
swap out process-A's page). swap token solve above simplest case. but run
many process easily makes similar circulation dependency. recovering from
heavy memory pressure need lots unfairness.

Of cource, if the unfairness makes performance regression, it's bug. it should be
fixed.


> The only problem I noticed with the page_referenced patch was an 
> increase in the
> try_to_unmap() failures which causes more re-activations.  This is very 
> obvious with
> the using tracepoints I have posted over the past few months but they 
> were never
> included. I didnt get a chance to figure out the exact cause due to 
> access to the hardware
> and workload.  This patch series also seems to help the overall stalls 
> in the VM system.

I (and many VM developer) don't forget your tracepoint effort. we only
hope to solve the regression at first.


> >> Rik, the latest patch appears to have a problem although I dont know
> >> what the problem is yet.  When the system ran out of memory we see
> >> thousands of runnable processes and 100% system time:
> >>
> >>
> >>  9420  2  29824  79856  62676  19564    0    0     0     0 8054  379  0 
> >> 100  0  0  0
> >> 9420  2  29824  79368  62292  19564    0    0     0     0 8691  413  0 
> >> 100  0  0  0
> >> 9421  1  29824  79780  61780  19820    0    0     0     0 8928  408  0 
> >> 100  0  0  0
> >>
> >> The system would not respond so I dont know whats going on yet.  I'll
> >> add debug code to figure out why its in that state as soon as I get
> >> access to the hardware.
> >>     
> 
> This was in response to Rik's first patch and seems to be fixed by the 
> latest path set.
> 
> Finally, having said all that, the system still struggles reclaiming 
> memory with
> ~10000 processes trying at the same time, you fix one bottleneck and it 
> moves
> somewhere else.  The latest run showed all but one running process 
> spinning in
> page_lock_anon_vma() trying for the anon_vma_lock.  I noticed that there 
> are
> ~5000 vma's linked to one anon_vma, this seems excessive!!!
> 
> I changed the anon_vma->lock to a rwlock_t and page_lock_anon_vma() to use
> read_lock() so multiple callers could execute the page_reference_anon code.
> This seems to help quite a bit.

Ug. no. rw-spinlock is evil. please don't use it. rw-spinlock has bad 
performance characteristics, plenty read_lock block write_lock for very
long time.

and I would like to confirm one thing. anon_vma design didn't change
for long year. Is this really performance regression? Do we strike
right regression point?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
