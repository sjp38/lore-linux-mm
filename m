Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 2969C6B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 23:44:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4846477dak.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 20:44:48 -0700 (PDT)
Message-ID: <4FB5C5A7.6080000@gmail.com>
Date: Fri, 18 May 2012 11:44:39 +0800
From: Nai Xia <nai.xia@gmail.com>
Reply-To: nai.xia@gmail.com
MIME-Version: 1.0
Subject: Re: [patch 0/5] refault distance-based file cache sizing
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org> <4FB33A4E.1010208@gmail.com> <20120516065132.GC1769@cmpxchg.org> <4FB3A416.9010703@gmail.com> <20120517210849.GE1800@cmpxchg.org>
In-Reply-To: <20120517210849.GE1800@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org



On 2012/05/18 05:08, Johannes Weiner wrote:
> On Wed, May 16, 2012 at 08:56:54PM +0800, nai.xia wrote:
>> On 2012/05/16 14:51, Johannes Weiner wrote:
>>> There may have been improvements from clock-pro, but it's hard to get
>>> code merged that does not behave as expected in theory with nobody
>>> understanding what's going on.
>
> Damn, that sounded way harsher and arrogant than I wanted it to sound.
> And it's only based on what I gathered from the discussions on the
> list archives.  Sorry :(

No harm done, man. I just understood your words in this way. :)

But I do think that Clock-pro deserves its credit, since after all
it's that research work firstly brought the idea of "refault/reuse
distance" to the kernel community. Further more, it's also good
to let the researchers and the community to together have some
brain-storm of this problem if it's really hard to deal with in
reality.

>
>> OK, I assume that you do aware that the system you constructed with
>> this simple and understandable idea looks like a so called "feedback
>> system"? Or in other words, I think theoretically the refault-distance
>> of a page before and after your algorithm is applied is not the same.
>> And this changed refault-distance pattern is then feed as input into
>> your algorithm. A feedback system may be hard(and may be simple) to
>> analyze but may also work well magically.
>
> I'm with you on that, but I can't see an alternative in this case.  We

I trend to agree, I once tried to deal with an anti-LRU pattern(e.g. the
big loop like you said) of a app from kernel space and failed. Seems
it's hard to gather a very accurate information of a program's real memory
footprint in mixed workloads with only the help of pte bits...(but also
may due to my lack of skills in tweaking the reclaiming code...)

> can't predict future page accesses very well, so we have to take
> speculative shots and be considerate about the consequences.
>
> And BECAUSE we may get it wrong, the algorithm does not rely on the
> decisions it makes to be correct.  For example, it does not activate
> pages based on refault distance, but requires the refaulted page to
> win the race against an actual active page.  Likewise, pages are not
> evicted from the active list directly, instead they get a chance at
> re-activation when challenged.

Yes. That sounds a smart handling.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
