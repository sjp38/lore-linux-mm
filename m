Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 764A16B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 08:57:07 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1559888pbb.14
        for <linux-mm@kvack.org>; Wed, 16 May 2012 05:57:06 -0700 (PDT)
Message-ID: <4FB3A416.9010703@gmail.com>
Date: Wed, 16 May 2012 20:56:54 +0800
From: "nai.xia" <nai.xia@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch 0/5] refault distance-based file cache sizing
References: <1335861713-4573-1-git-send-email-hannes@cmpxchg.org> <4FB33A4E.1010208@gmail.com> <20120516065132.GC1769@cmpxchg.org>
In-Reply-To: <20120516065132.GC1769@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hi,

On 2012/05/16 14:51, Johannes Weiner wrote:
> Hi Nai,
>
> On Wed, May 16, 2012 at 01:25:34PM +0800, nai.xia wrote:
>> Hi Johannes,
>>
>> Just out of curiosity(since I didn't study deep into the
>> reclaiming algorithms), I can recall from here that around 2005,
>> there was an(or some?) implementation of the "Clock-pro" algorithm
>> which also have the idea of "reuse distance", but it seems that algo
>> did not work well enough to get merged? Does this patch series finally
>> solve the problem(s) with "Clock-pro" or totally doesn't have to worry
>> about the similar problems?
>
> As far as I understood, clock-pro set out to solve more problems than
> my patch set and it failed to satisfy everybody.
>
> The main error case was that it could not partially cache data of a
> set that was bigger than memory.  Instead, looping over the file
> repeatedly always has to read every single page because the most
> recent page allocations would push out the pages needed in the nearest
> future.  I never promised to solve this problem in the first place.
> But giving more memory to the big looping load is not useful in our
> current situation, and at least my code protects smaller sets of
> active cache from these loops.  So it's not optimal, but it sucks only
> half as much :)

Yep, I see ;)

>
> There may have been improvements from clock-pro, but it's hard to get
> code merged that does not behave as expected in theory with nobody
> understanding what's going on.
>
> My code is fairly simple, works for the tests I've done and the
> behaviour observed so far is understood (at least by me).

OK, I assume that you do aware that the system you constructed with
this simple and understandable idea looks like a so called "feedback
system"? Or in other words, I think theoretically the refault-distance
of a page before and after your algorithm is applied is not the same.
And this changed refault-distance pattern is then feed as input into
your algorithm. A feedback system may be hard(and may be simple) to
analyze but may also work well magically.

Well, again I confess I've not done enough course in this area. Just hope
that my words can help you think more comprehensively. :)


Thanks,

Nai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
