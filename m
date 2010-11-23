Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D34E96B008C
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 04:07:20 -0500 (EST)
Received: by iwn10 with SMTP id 10so1102210iwn.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 01:07:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=XeY5bktanMPm26y4YYbWMWicks9VkmFcaLH9B@mail.gmail.com>
References: <20101123165240.7BC2.A69D9226@jp.fujitsu.com>
	<AANLkTi=ibOd3OUZ5D-V60iaNcP0_eND2VrcJB+PBo8mD@mail.gmail.com>
	<20101123175948.7BD1.A69D9226@jp.fujitsu.com>
	<AANLkTi=XeY5bktanMPm26y4YYbWMWicks9VkmFcaLH9B@mail.gmail.com>
Date: Tue, 23 Nov 2010 18:07:18 +0900
Message-ID: <AANLkTi=E57YMwURbKDWHT+JB+F-6+tOS4BWchw+gC439@mail.gmail.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 23, 2010 at 6:05 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Tue, Nov 23, 2010 at 6:02 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> On Tue, Nov 23, 2010 at 5:01 PM, KOSAKI Motohiro
>>> <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> >> Hi KOSAKI,
>>> >>
>>> >> 2010/11/23 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
>>> >> >> By Other approach, app developer uses POSIX_FADV_DONTNEED.
>>> >> >> But it has a problem. If kernel meets page is writing
>>> >> >> during invalidate_mapping_pages, it can't work.
>>> >> >> It is very hard for application programmer to use it.
>>> >> >> Because they always have to sync data before calling
>>> >> >> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
>>> >> >> be discardable. At last, they can't use deferred write of kernel
>>> >> >> so that they could see performance loss.
>>> >> >> (http://insights.oetiker.ch/linux/fadvise.html)
>>> >> >
>>> >> > If rsync use the above url patch, we don't need your patch.
>>> >> > fdatasync() + POSIX_FADV_DONTNEED should work fine.
>>> >>
>>> >> It works well. But it needs always fdatasync before calling fadvise.
>>> >> For small file, it hurt performance since we can't use the deferred write.
>>> >
>>> > I doubt rsync need to call fdatasync. Why?
>>> >
>>> > If rsync continue to do following loop, some POSIX_FADV_DONTNEED
>>> > may not drop some dirty pages. But they can be dropped at next loop's
>>> > POSIX_FADV_DONTNEED. Then, It doesn't make serious issue.
>>> >
>>> > 1) read
>>> > 2) write
>>> > 3) POSIX_FADV_DONTNEED
>>> > 4) goto 1
>>>
>>> fadvise need pair (offset and len).
>>> if the pair in next turn is different with one's previous turn, it
>>> couldn't be dropped.
>>
>> invalidate_mapping_pages() are using pagevec_lookup() and pagevec_lookup()
>> are using radix tree lookup. Then, Even if rsync always use [0, inf) pair, I don't think
>> it makes much slowdown.
>>
>
> I mean fdatasync causes slowdown, not fadvise.
> if you fadvise(don't need) without fdatasync, you could loss the data.

Oops sorry. Not lose data.
Frequent fdatasync call doesn't use buffered write so that it causes
slowdown than using deferred write.

> --
> Kind regards,
> Minchan Kim
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
