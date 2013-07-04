Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 4F2276B0034
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 09:08:19 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Jul 2013 09:08:18 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F2DA038C8045
	for <linux-mm@kvack.org>; Thu,  4 Jul 2013 09:08:14 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r64D7OAp58785886
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 09:07:24 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r64D7Mug019044
	for <linux-mm@kvack.org>; Thu, 4 Jul 2013 09:07:23 -0400
Date: Thu, 4 Jul 2013 18:37:19 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 13/13] sched: Account for the number of preferred tasks
 running on a node when selecting a preferred node
Message-ID: <20130704130719.GC29916@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1372861300-9973-1-git-send-email-mgorman@suse.de>
 <1372861300-9973-14-git-send-email-mgorman@suse.de>
 <20130703183243.GB18898@dyad.programming.kicks-ass.net>
 <20130704093716.GO1875@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130704093716.GO1875@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

>  static void task_numa_placement(struct task_struct *p)
>  {
>  	int seq, nid, max_nid = 0;
> @@ -897,7 +924,7 @@ static void task_numa_placement(struct task_struct *p)
> 
>  		/* Find maximum private faults */
>  		faults = p->numa_faults[task_faults_idx(nid, 1)];
> -		if (faults > max_faults) {
> +		if (faults > max_faults && !sched_numa_overloaded(nid)) {

Should we take the other approach of setting the preferred nid but not 
moving the task to the node?

So if some task moves out of the preferred node, then we should still be
able to move this task there. 

However your current approach has an advantage that it atleast runs on
second preferred choice if not the first.

Also should sched_numa_overloaded() also consider pinned tasks?

>  			max_faults = faults;
>  			max_nid = nid;
>  		}
> @@ -923,9 +950,7 @@ static void task_numa_placement(struct task_struct *p)
>  							     max_nid);
>  		}
> 
> -		/* Update the preferred nid and migrate task if possible */
> -		p->numa_preferred_nid = max_nid;
> -		p->numa_migrate_seq = 0;
> +		sched_setnuma(p, max_nid, preferred_cpu);
>  		migrate_task_to(p, preferred_cpu);
> 
>  		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
