Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E826B8D0001
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 22:43:36 -0400 (EDT)
Received: by qyk5 with SMTP id 5so2016337qyk.14
        for <linux-mm@kvack.org>; Thu, 04 Nov 2010 19:43:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101104015249.GD19646@google.com>
References: <20101028191523.GA14972@google.com>
	<20101101012322.605C.A69D9226@jp.fujitsu.com>
	<20101101182416.GB31189@google.com>
	<AANLkTimCjUgy9sN5QzxwW960v9eNWAjMBdq3H6P20NUa@mail.gmail.com>
	<20101104015249.GD19646@google.com>
Date: Fri, 5 Nov 2010 11:36:05 +0900
Message-ID: <AANLkTim45zjeVoeb3xGFxGa=UzZAz_pV_qUv8o0P_274@mail.gmail.com>
Subject: Re: [PATCH] RFC: vmscan: add min_filelist_kbytes sysctl for
 protecting the working set
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mandeep Singh Baines <msb@chromium.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wad@chromium.org, olofj@chromium.org, hughd@chromium.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 4, 2010 at 10:52 AM, Mandeep Singh Baines <msb@chromium.org> wrote:
> Minchan Kim (minchan.kim@gmail.com) wrote:
>> On Tue, Nov 2, 2010 at 3:24 AM, Mandeep Singh Baines <msb@chromium.org> wrote:
>> > I see memcg more as an isolation mechanism but I guess you could use it to
>> > isolate the working set from anon browser tab data as Kamezawa suggests.
>>
>>
>> I don't think current VM behavior has a problem.
>> Current problem is that you use up many memory than real memory.
>> As system memory without swap is low, VM doesn't have a many choice.
>> It ends up evict your working set to meet for user request. It's very
>> natural result for greedy user.
>>
>> Rather than OOM notifier, what we need is memory notifier.
>> AFAIR, before some years ago, KOSAKI tried similar thing .
>> http://lwn.net/Articles/268732/
>
> Thanks! This is perfect. I wonder why its not merged. Was a different
> solution eventually implemented? Is there another way of doing the
> same thing?

If my remember is right, there was timing issue.
When the application is notified, it was too late to handle it.
Mabye KOSAKI can explain more detail problem.

I think we need some leveling mechanism.
For example, user can set the limits 30M, 20M, 10M, 5M.

If free memory is low below 30M, master application can require
freeing of extra memory of background sleeping application.
If free memory is low below 20M, master application can require
existing of background sleeping application.
If free memory is low below 10M, master application can kill
none-critical application.
If free memory is low below 5M, master application can require freeing
of memory of critical application.

I think this mechanism would be useful memcg, too.

>
>> (I can't remember why KOSAKI quit it exactly, AFAIR, some signal time
>> can't meet yours requirement. I mean when the user receive the memory
>> low signal, it's too late. Maybe there are other causes for KOSAKi to
>> quit it.)
>> Anyway, If the system memory is low, your intelligent middleware can
>> control it very well than VM.
>
> Agree.
>
>> In this chance, how about improving it?
>> Mandeep, Could you feel needing this feature?
>>
>
> mem_notify seems perfect.

BTW, Regardless of mem_notify, I think this patch is useful in general
system, too.
We have to progress this patch.

>
>>
>>
>> > Regards,
>> > Mandeep
>> >
>> >> Thanks.
>> >>
>> >>
>> >>
>> >
>>
>>
>>
>> --
>> Kind regards,
>> Minchan Kim
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
