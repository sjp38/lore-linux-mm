Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 49ED66B0012
	for <linux-mm@kvack.org>; Tue, 10 May 2011 19:22:41 -0400 (EDT)
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id p4ANMZxg019534
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:22:39 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by kpbe16.cbf.corp.google.com with ESMTP id p4ANMXtg032031
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 May 2011 16:22:34 -0700
Received: by pzk1 with SMTP id 1so3281800pzk.30
        for <linux-mm@kvack.org>; Tue, 10 May 2011 16:22:32 -0700 (PDT)
Date: Tue, 10 May 2011 16:22:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: OOM Killer don't works at all if the system have >gigabytes
 memory (was Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable())
In-Reply-To: <20110510171335.16A7.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1105101607200.12477@chino.kir.corp.google.com>
References: <1491537913.283996.1304930866703.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com> <20110509182110.167F.A69D9226@jp.fujitsu.com> <20110510171335.16A7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: CAI Qian <caiqian@redhat.com>, avagin@gmail.com, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>

On Tue, 10 May 2011, KOSAKI Motohiro wrote:

> OK. That's known issue. Current OOM logic doesn't works if you have
> gigabytes RAM. because _all_ process have the exactly same score (=1).
> then oom killer just fallback to random process killer. It was made
> commit a63d83f427 (oom: badness heuristic rewrite). I pointed out
> it at least three times. You have to blame Google folks. :-/
> 

If all threads have the same badness score, which by definition must be 1 
since that is the lowest badness score possible for an eligible thread, 
then each thread is using < 0.2% of RAM.

The granularity of the badness score doesn't differentiate between threads  
using 0.1% of RAM in terms of priority for kill (in this case, 16MB).  The 
largest consumers of memory from CAI's log have an rss of 336MB, which is 
~2% of system RAM.  The problem is that these are forked by root and 
therefore get a 3% bonus, making their badness score 1 instead of 2.

 [ You also don't have to blame "Google folks," I rewrote the oom
   killer. ]

> 
> The problems are three.
> 
> 1) if two processes have the same oom score, we should kill younger process.
>    but current logic kill older. Oldest processes are typicall system daemons.

Agreed, that seems advantageous to prefer killing threads that have done 
the least amount of work (defined as those with the least runtime compared 
to others in the tasklist order) over others.

> 2) Current logic use 'unsigned int' for internal score calculation. (exactly says,
>    it only use 0-1000 value). its very low precision calculation makes a lot of
>    same oom score and kill an ineligible process.

The range of 0-1000 allows us to differentiate tasks up to 0.1% of system 
RAM from each other when making oom kill decisions.  If we really want to 
increase this granularity, we could increase the value to 10000 and then 
multiple oom_score_adj values by 10.

> 3) Current logic give 3% of SystemRAM to root processes. It obviously too big
>    if you have plenty memory. Now, your fork-bomb processes have 500MB OOM immune
>    bonus. then your fork-bomb never ever be killed.
> 

I agree that a constant proportion for root processes is probably not 
ideal, especially in situations where there are many small threads that 
only use about 1% of system RAM, such as in CAI's case.  I don't agree 
that we need to guard against forkbombs created by root, however.  The 
worst case scenario is that the continuous killing of non-root threads 
will allow the admin to fix his or her error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
