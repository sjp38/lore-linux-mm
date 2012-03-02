Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 81E036B002C
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 14:53:48 -0500 (EST)
Date: Fri, 2 Mar 2012 13:53:45 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] cpuset: mm: Remove memory barrier damage from the page
 allocator
In-Reply-To: <20120302174349.GB3481@suse.de>
Message-ID: <alpine.DEB.2.00.1203021349020.18523@router.home>
References: <20120302112358.GA3481@suse.de> <alpine.DEB.2.00.1203021018130.15125@router.home> <20120302174349.GB3481@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 2 Mar 2012, Mel Gorman wrote:

> I considered using a seqlock but it isn't cheap. The read side is heavy
> with the possibility that it starts spinning and incurs a read barrier
> (looking at read_seqbegin()) here. The retry block incurs another read
> barrier so basically it would not be no better than what is there currently
> (which at a 4% performance hit, sucks)

Oh. You dont have a read barrier? So your approach is buggy? We could have
read a state before someone else incremented the seq counter, then cached
it, then we read the counter, did the processing and found that the
sequid was not changed?

> In the case of seqlocks, a reader will backoff if a writer is in progress
> but the page allocator doesn't need that which is why I felt it was ok

You can just not use the writer section if you think that is ok. Doubt it
but lets at least start using a known serialization construct that would
allow us to fix it up if we find that we need to update multiple variables
protected by the seqlock.

> Allocation failure is an unusual situation that can trigger application
> exit or an OOM so it's ok to treat it as a slow path. A normal seqlock
> would retry unconditionally and potentially have to handle the case
> where it needs to free the page before retrying which is pointless.

It will only retry as long as the writer hold the "lock". Like a spinlock
the holdoff times depends on the size of the critical section and
initially you could just avoid having write sections.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
