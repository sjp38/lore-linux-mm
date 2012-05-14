Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 4DE596B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 19:06:30 -0400 (EDT)
Received: by yhr47 with SMTP id 47so6965083yhr.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 16:06:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120514133210.GE29102@suse.de>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
 <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 14 May 2012 19:06:09 -0400
Message-ID: <CAHGf_=pDmydwMF9LxuSbmKk23j6+vKMnM4E_dX=qinNxz6je3w@mail.gmail.com>
Subject: Re: Allow migration of mlocked page?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

>> >If CMA decide they want to alter mlocked pages in this way, it's sortof
>> >ok. While CMA is being used, there are no expectations on the RT
>> >behaviour of the system - stalls are expected. In their use cases, CMA
>> >failing is far worse than access latency to an mlocked page being
>> >variable while CMA is running.
>>
>> That's strange. CMA caller can't know the altered page is under mlock or not.
>> and almost all CMA user is in embedded world. ie RT realm.
>
> Embedded does not imply realtime constraints.

True. but much overwrapped.


>> So, I don't think
>> CMA and compaction are significantly different.
>
> CMA is used in cases such as a mobile phone needing to allocate a large
> contiguous range of memory for video decoding. Compaction is used by
> features such as THP with khugepaged potentially using it frequently on
> x86-64 machines. The use cases are different and compaction is used by
> THP a lot more than CMA is used by anything.

Fair point. usecase frequency is clearly different.


> If compaction can move mlocked pages then khugepaged can introduce unexpected
> latencies on mlocked anonymous regions of memory.

Yes, it can. Then, the problem depend on how much applications assume
mlock provide no minor fault. right?

My claim was, I suspect such applications certainly exist, but very
few. Automatic
moving makes 99.9% applications happy. example, modern distro  have >1000
utility commands and I suspect _all_ command don't care minor fault.

OK, a few high end and hpc applications certainly care it. but is it majority?


>> >Compaction on the other hand is during the normal operation of the
>> >machine. There are applications that assume that if anonymous memory
>> >is mlocked() then access to it is close to zero latency. They are
>> >not RT-critical processes (or they would disable THP) but depend on
>> >this. Allowing compaction to migrate mlocked() pages will result in bugs
>> >being reported by these people.
>> >
>> >I've received one bug this year about access latency to mlocked() regions but
>> >it turned out to be a file-backed region and related to when the write-fault
>> >is incurred. The ultimate fix was in the application but we'll get new bug
>> >reports if anonymous mlocked pages do not preserve the current guarantees
>> >on access latency.
>>
>> Can you please tell us your opinion about autonuma?
>
> I think it will have the same problem as THP using compaction. If
> mlocked pages can move then there may be unexpected latencies accessing
> mlocked anonymous regions.
>
>> I doubt we can keep such
>> mlock guarantee. I think we need to suggest application fix. maybe to introduce
>> MADV_UNMOVABLE is good start. it seems to solve autonuma issue too.
>
> That'll regress existing applications. It would be preferable to me that
> it be the other way around to not move mlocked pages unless the user says
> it's allowed.

My conclusion is different but I don't disagree your point. see above. I know
you are right too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
