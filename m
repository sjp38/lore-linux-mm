Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id CD8086B0033
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 20:56:25 -0400 (EDT)
Subject: Re: Performance regression from switching lock to rw-sem for
 anon-vma tree
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <1375833325.2134.36.camel@buesod1.americas.hpqcorp.net>
References: <1372366385.22432.185.camel@schen9-DESK>
	 <1372375873.22432.200.camel@schen9-DESK> <20130628093809.GB29205@gmail.com>
	 <1372453461.22432.216.camel@schen9-DESK> <20130629071245.GA5084@gmail.com>
	 <1372710497.22432.224.camel@schen9-DESK> <20130702064538.GB3143@gmail.com>
	 <1373997195.22432.297.camel@schen9-DESK> <20130723094513.GA24522@gmail.com>
	 <20130723095124.GW27075@twins.programming.kicks-ass.net>
	 <20130723095306.GA26174@gmail.com> <1375143209.22432.419.camel@schen9-DESK>
	 <1375833325.2134.36.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 06 Aug 2013 17:56:28 -0700
Message-ID: <1375836988.22432.435.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, "Shi, Alex" <alex.shi@intel.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, "Wilcox, Matthew R" <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On Tue, 2013-08-06 at 16:55 -0700, Davidlohr Bueso wrote:

> I got good numbers, recovering the performance drop I noticed with the
> i_mmap_mutex to rwsem patches.

That's good.  I remembered that the earlier version of the patch not
only recovered the performance drop, but also provide some boost when
you switch from i_mmap_mutex to rwsem for aim7.  Do you see similar
boost with this version?

>  Looking forward to a more upstreamable
> patchset that deals with this work, including the previous patches.
> 
> One thing that's bugging me about this series though is the huge amount
> of duplicated code being introduced to rwsems from mutexes. We can share
> common functionality such as mcs locking (perhaps in a new file under
> lib/), can_spin_on_owner() and owner_running(), perhaps moving those
> functions into sheduler code, were AFAIK they were originally.

I think that MCS locking is worth breaking out as its
own library.  After we've done that, the rest of
the duplication are minimal. It is easier
to keep them separate as there are some rwsem 
specific logic that may require tweaking
to can_spin_on_owner and owner_running.  

Thanks.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
