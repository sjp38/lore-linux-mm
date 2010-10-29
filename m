Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id A1A7D6B0106
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 00:27:16 -0400 (EDT)
Received: by qwi2 with SMTP id 2so2738265qwi.14
        for <linux-mm@kvack.org>; Thu, 28 Oct 2010 21:27:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4CCA42D0.5090603@redhat.com>
References: <1288200090-23554-1-git-send-email-yinghan@google.com>
	<4CC869F5.2070405@redhat.com>
	<AANLkTikL+v6uzkXg-7J2FGVz-7kc0Myw_cO5s_wYfHHm@mail.gmail.com>
	<AANLkTimLBO7mJugVXH0S=QSnwQ+NDcz3zxmcHmPRjngd@mail.gmail.com>
	<alpine.LSU.2.00.1010271144540.5039@tigran.mtv.corp.google.com>
	<AANLkTim9NBXrAWkMW7C5C6=1sh52OJm=u5HT7ShyC7hv@mail.gmail.com>
	<20101028091158.4de545e9.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikdE---MJ-LSwNHEniCphvwu0T2apkWzGsRQ8i=@mail.gmail.com>
	<20101029114529.4d3a8b9c.kamezawa.hiroyu@jp.fujitsu.com>
	<4CCA42D0.5090603@redhat.com>
Date: Fri, 29 Oct 2010 13:27:15 +0900
Message-ID: <AANLkTiku321ZpSrO4hSLyj7n9NM7QvN+RQ-A73KK4eRa@mail.gmail.com>
Subject: Re: [PATCH] mm: don't flush TLB when propagate PTE access bit to
 struct page.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ken Chen <kenchen@google.com>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2010 at 12:43 PM, Rik van Riel <riel@redhat.com> wrote:
> On 10/28/2010 10:45 PM, KAMEZAWA Hiroyuki wrote:
>
>> Hmm. Without flushing anywhere in memory reclaim path, a process which
>> cause page fault and enter vmscan will not see his own recent access bit
>> on
>> pages in LRU ?
>
> Worse still, because kernel threads do a lazy mmu switch, even
> page faulting in the process will not cause the TLB entries to
> be flushed.
>
>> I think it should be flushed at least once..
>
> A periodic flush may make sense.
>
> Maybe something along the lines of if the TLB has not been
> flushed for over a second (we can see that in timer or scheduler
> code), flush it?

What happens if we don't flush TLB?
It will make for old page to pretend young page.
If it is, how does it affect reclaim?

It makes for old page to promote into active list by page_check_references.
Of couse, It's not good. But for it, we have to keep wrong TLB until
moving head to tail in inactive list. It's very unlikely. That's
because TLB is very smalll and the process will be switching out.

If lumpy happens(ie, not waiting from head to tail in inactive list to
hold a victim page), that's all right since we ignore young bit in
lumpy case.

I think it's no problem unless inactive list is very short.
Remained one is kernel thread's lazy TLB flush.

So how about flushing TLB in kswapd scheduled in?


> --
> All rights reversed
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
