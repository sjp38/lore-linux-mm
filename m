Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id E78566B0069
	for <linux-mm@kvack.org>; Thu, 14 Jun 2012 12:11:09 -0400 (EDT)
Received: by yhr47 with SMTP id 47so2068018yhr.14
        for <linux-mm@kvack.org>; Thu, 14 Jun 2012 09:11:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120614145716.GA2097@barrios>
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com> <20120614145716.GA2097@barrios>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 14 Jun 2012 12:10:47 -0400
Message-ID: <CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com>
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On Thu, Jun 14, 2012 at 10:57 AM, Minchan Kim <minchan@kernel.org> wrote:
> Hi KOSAKI,
>
> Sorry for late response.
> Let me ask a question about description.
>
> On Thu, Jun 14, 2012 at 04:13:12AM -0400, kosaki.motohiro@gmail.com wrote=
:
>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>
>> Currently, do_try_to_free_pages() can enter livelock. Because of,
>> now vmscan has two conflicted policies.
>>
>> 1) kswapd sleep when it couldn't reclaim any page when reaching
>> =A0 =A0priority 0. This is because to avoid kswapd() infinite
>> =A0 =A0loop. That said, kswapd assume direct reclaim makes enough
>> =A0 =A0free pages to use either regular page reclaim or oom-killer.
>> =A0 =A0This logic makes kswapd -> direct-reclaim dependency.
>> 2) direct reclaim continue to reclaim without oom-killer until
>> =A0 =A0kswapd turn on zone->all_unreclaimble. This is because
>> =A0 =A0to avoid too early oom-kill.
>> =A0 =A0This logic makes direct-reclaim -> kswapd dependency.
>>
>> In worst case, direct-reclaim may continue to page reclaim forever
>> when kswapd sleeps forever.
>
> I have tried imagined scenario you mentioned above with code level but
> unfortunately I got failed.
> If kswapd can't meet high watermark on order-0, it doesn't sleep if I don=
't miss something.

pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
if node has multiple zones. Hm ok, I realized my descriptions was
slightly misleading. priority 0 is not needed. bakance_pddat() calls
pgdat_balanced()
every priority. Most easy case is, movable zone has a lot of free pages and
normal zone has no reclaimable page.

btw, current pgdat_balanced() logic seems not correct. kswapd should
sleep only if every zones have much free pages than high water mark
_and_ 25% of present pages in node are free.



> So if kswapd sleeps, it means we already have enough order-0 free pages.
> Hmm, could you describe scenario you found in detail with code level?
>
> Anyway, as I look at your patch, I can't find any problem.
> I just want to understand scenario you mentioned completely in my head.
> Maybe It can help making description clear.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
