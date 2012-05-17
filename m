Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 0440B6B0083
	for <linux-mm@kvack.org>; Thu, 17 May 2012 17:09:01 -0400 (EDT)
Date: Thu, 17 May 2012 23:08:49 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/5] refault distance-based file cache sizing
Message-ID: <20120517210849.GE1800@cmpxchg.org>
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org>
 <4FB33A4E.1010208@gmail.com>
 <20120516065132.GC1769@cmpxchg.org>
 <4FB3A416.9010703@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FB3A416.9010703@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "nai.xia" <nai.xia@gmail.com>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, May 16, 2012 at 08:56:54PM +0800, nai.xia wrote:
> On 2012/05/16 14:51, Johannes Weiner wrote:
> >There may have been improvements from clock-pro, but it's hard to get
> >code merged that does not behave as expected in theory with nobody
> >understanding what's going on.

Damn, that sounded way harsher and arrogant than I wanted it to sound.
And it's only based on what I gathered from the discussions on the
list archives.  Sorry :(

> OK, I assume that you do aware that the system you constructed with
> this simple and understandable idea looks like a so called "feedback
> system"? Or in other words, I think theoretically the refault-distance
> of a page before and after your algorithm is applied is not the same.
> And this changed refault-distance pattern is then feed as input into
> your algorithm. A feedback system may be hard(and may be simple) to
> analyze but may also work well magically.

I'm with you on that, but I can't see an alternative in this case.  We
can't predict future page accesses very well, so we have to take
speculative shots and be considerate about the consequences.

And BECAUSE we may get it wrong, the algorithm does not rely on the
decisions it makes to be correct.  For example, it does not activate
pages based on refault distance, but requires the refaulted page to
win the race against an actual active page.  Likewise, pages are not
evicted from the active list directly, instead they get a chance at
re-activation when challenged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
