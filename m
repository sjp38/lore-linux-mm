Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A695F6B004D
	for <linux-mm@kvack.org>; Tue, 19 May 2009 08:28:03 -0400 (EDT)
Received: by yx-out-1718.google.com with SMTP id 36so1921266yxh.26
        for <linux-mm@kvack.org>; Tue, 19 May 2009 05:28:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090519085354.GB2121@localhost>
References: <20090519161756.4EE4.A69D9226@jp.fujitsu.com>
	 <20090519074925.GA690@localhost>
	 <20090519170208.742C.A69D9226@jp.fujitsu.com>
	 <20090519085354.GB2121@localhost>
Date: Tue, 19 May 2009 21:28:28 +0900
Message-ID: <2f11576a0905190528n5eb29e3fme42785a76eed3551@mail.gmail.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
	citizen
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Hi

2009/5/19 Wu Fengguang <fengguang.wu@intel.com>:
> On Tue, May 19, 2009 at 04:06:35PM +0800, KOSAKI Motohiro wrote:
>> > > > Like the console mode, the absolute nr_mapped drops considerably -=
 to 1/13 of
>> > > > the original size - during the streaming IO.
>> > > >
>> > > > The delta of pgmajfault is 3 vs 107 during IO, or 236 vs 393 durin=
g the whole
>> > > > process.
>> > >
>> > > hmmm.
>> > >
>> > > about 100 page fault don't match Elladan's problem, I think.
>> > > perhaps We missed any addional reproduce condition?
>> >
>> > Elladan's case is not the point of this test.
>> > Elladan's IO is use-once, so probably not a caching problem at all.
>> >
>> > This test case is specifically devised to confirm whether this patch
>> > works as expected. Conclusion: it is.
>>
>> Dejection ;-)
>>
>> The number should address the patch is useful or not. confirming as expe=
cted
>> is not so great.
>
> OK, let's make the conclusion in this way:
>
> The changelog analyzed the possible beneficial situation, and this
> test backs that theory with real numbers, ie: it successfully stops
> major faults when the active file list is slowly scanned when there
> are partially cache hot streaming IO.
>
> Another (amazing) finding of the test is, only around 1/10 mapped pages
> are actively referenced in the absence of user activities.
>
> Shall we protect the remaining 9/10 inactive ones? This is a question ;-)

Unfortunately, I don't reproduce again.
I don't apply your patch yet. but mapped ratio is reduced only very little.

I think smem can show which library evicted.  Can you try it?

download:  http://www.selenic.com/smem/
usage:   ./smem -m -r --abbreviate


We can't decide 9/10 is important or not. we need know actual evicted file =
list.

Thanks.


> Or, shall we take the "protect active VM_EXEC mapped pages" approach,
> or Christoph's "protect all mapped pages all time, unless they grow
> too large" attitude? =A0I still prefer the best effort VM_EXEC heuristics=
.
>
> 1) the partially cache hot streaming IO is far more likely to happen
> =A0 on (file) servers. For them, evicting the 9/10 inactive mapped
> =A0 pages over night should be acceptable for sysadms.
>
> 2) for use-once IO on desktop, we have Rik's active file list
> =A0 protection heuristics, so nothing to worry at all.
>
> 3) for big working set small memory desktop, the active list will
> =A0 still be scanned, in this situation, why not evict some of the
> =A0 inactive mapped pages? If they have not been accessed for 1 minute,
> =A0 they are not likely be the user focus, and the tight memory
> =A0 constraint can only afford to cache the user focused working set.
>
> Does that make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
