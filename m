Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 486D26B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:44:52 -0500 (EST)
Received: by iwn10 with SMTP id 10so1026107iwn.14
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 23:44:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20101122231558.57b6e04c.akpm@linux-foundation.org>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101122141449.9de58a2c.akpm@linux-foundation.org>
	<AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com>
	<20101122210132.be9962c7.akpm@linux-foundation.org>
	<AANLkTin62R1=2P+Sh0YKJ3=KAa6RfLQLKJcn2VEtoZfG@mail.gmail.com>
	<20101122212220.ae26d9a5.akpm@linux-foundation.org>
	<AANLkTinTp2N3_uLEm7nf0=Xu2f9Rjqg9Mjjxw-3YVCcw@mail.gmail.com>
	<20101122214814.36c209a6.akpm@linux-foundation.org>
	<AANLkTimpfZuKW-hXjXknn3ESKP81AN3BaXO=qG81Lrae@mail.gmail.com>
	<20101122231558.57b6e04c.akpm@linux-foundation.org>
Date: Tue, 23 Nov 2010 16:44:50 +0900
Message-ID: <AANLkTin9AFFDu1ShVNn2SDyTTOMczURuyZVGSjOxPq7E@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 4:15 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 23 Nov 2010 15:05:39 +0900 Minchan Kim <minchan.kim@gmail.com> wr=
ote:
>
>> On Tue, Nov 23, 2010 at 2:48 PM, Andrew Morton
>> >> > move it to the head of the LRU anyway. __But given that the user ha=
s
>> >>
>> >> Why does it move into head of LRU?
>> >> If the page which isn't mapped doesn't have PG_referenced, it would b=
e
>> >> reclaimed.
>> >
>> > If it's dirty or under writeback it can't be reclaimed!
>>
>> I see your point. And it's why I add it to head of inactive list.
>
> But that *guarantees* that the page will get a full trip around the
> inactive list. =A0And this will guarantee that potentially useful pages
> are reclaimed before the pages which we *know* the user doesn't want!
> Bad!
>
> Whereas if we queue it to the tail, it will only get that full trip if
> reclaim happens to run before the page is cleaned. =A0And we just agreed
> that reclaim isn't likely to run immediately, because pages are being
> freed.
>
> So we face a choice between guaranteed eviction of potentially-useful
> pages (which are very expensive to reestablish) versus a *possible*
> need to move an unreclaimable page to the head of the LRU, which is
> cheap.

How about flagging SetPageReclaim when we add it to head of inactive?
If page write is complete, end_page_writeback would move it to tail of
inactive.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
