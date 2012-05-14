Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 902456B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 00:13:07 -0400 (EDT)
Message-ID: <4FB0866D.4020203@kernel.org>
Date: Mon, 14 May 2012 13:13:33 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: Allow migration of mlocked page?
References: <4FAC9786.9060200@kernel.org> <1336728026.1017.7.camel@twins>
In-Reply-To: <1336728026.1017.7.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On 05/11/2012 06:20 PM, Peter Zijlstra wrote:

> On Fri, 2012-05-11 at 13:37 +0900, Minchan Kim wrote:
>> I hope hear opinion from rt guys, too.
> 
> Its a problem yes, not sure your solution is any good though. As it
> stands mlock() simply doesn't guarantee no faults, all it does is
> guarantee no major faults.


I can't find such definition from man pages
"
       Real-time  processes  that are using mlockall() to prevent delays on page faults should
       reserve enough locked stack pages before entering the time-critical section, so that no
       page fault can be caused by function calls
"
So I didn't expect it. Is your definition popular available on server RT?
At least, embedded guys didn't expect it.


> 
> Are you saying compaction doesn't actually move mlocked pages? I'm


Yes.

> somewhat surprised by that, I've always assumed it would.


It seems everyone assumed it.

> 
> Its sad that mlock() doesn't take a flags argument, so I'd rather
> introduce a new madvise() flag for -rt, something like MADV_UNMOVABLE
> (or whatever) which will basically copy the pages to an un-movable page
> block and really pin the things.


1) We don't have space of vm_flags in 32bit machine and Konstantin
   have sorted out but not sure it's merged. Anyway, Okay. It couldn't be a problem.

2) It needs application's fix and as Mel said, we might get new bug reports about latency.
   Doesn't it break current mlock semantic? - " no page fault can be caused by function calls"
   Otherwise, we should fix man page like your saying -   "no major page fault can be caused by function calls"

 

> That way mlock() can stay what the spec says it is and guarantee
> residency.

> 

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=ilto:"dont@kvack.org"> email@kvack.org </a>
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
