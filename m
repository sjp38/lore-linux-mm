Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8DFF88D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 21:15:54 -0500 (EST)
Date: Tue, 8 Mar 2011 21:15:25 -0500
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH 0/6] enable writing to /proc/pid/mem
Message-ID: <20110309021524.GA4838@fibrous.localdomain>
References: <1299631343-4499-1-git-send-email-wilsons@start.ca> <20110309013017.GY22723@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110309013017.GY22723@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>, Matt Mackall <mpm@selenic.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@kernel.dk>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org

On Wed, Mar 09, 2011 at 01:30:17AM +0000, Al Viro wrote:
> On Tue, Mar 08, 2011 at 07:42:17PM -0500, Stephen Wilson wrote:
> > This patch series enables safe writes to /proc/pid/mem.  The principle strategy
> > is to get a reference to the target task's mm before the permission check, and
> > to hold that reference until after the write completes.
> 
> One note: I'd rather prefer approach similar to mm_for_maps().  IOW, instead
> of "check, then get mm, then check _again_ to decide if we are allowed to
> use it", just turn check_mm_permissions() into a function that returns
> you a safe mm or gives you NULL (or, better yet, ERR_PTR(...)).  With all
> checks done within that sucker.

OK.  That certainly makes a lot of sense.  That can easily be added as
an additional patch to the series so that it is perfectly clear as to
what has been changed and how.

I think we could also remove the intermediate copy in both mem_read() and
mem_write() as well, but I think such optimizations could be left for
follow on patches.

> Then mem_read() and mem_write() wouldn't need to recheck anything again
> and the same helper would be usable for other things as well.  I mean
> something like this: (*WARNING* - completely untested)

Will work this into the series, test it, etc.


Thanks!


-- 
steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
