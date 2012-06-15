Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id C5D7E6B005C
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 03:27:02 -0400 (EDT)
Message-ID: <4FDAE3CC.60801@kernel.org>
Date: Fri, 15 Jun 2012 16:27:08 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com> <20120614145716.GA2097@barrios> <CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com>
In-Reply-To: <CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>

On 06/15/2012 01:10 AM, KOSAKI Motohiro wrote:

> On Thu, Jun 14, 2012 at 10:57 AM, Minchan Kim <minchan@kernel.org> wrote:
>> Hi KOSAKI,
>>
>> Sorry for late response.
>> Let me ask a question about description.
>>
>> On Thu, Jun 14, 2012 at 04:13:12AM -0400, kosaki.motohiro@gmail.com wrote:
>>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>
>>> Currently, do_try_to_free_pages() can enter livelock. Because of,
>>> now vmscan has two conflicted policies.
>>>
>>> 1) kswapd sleep when it couldn't reclaim any page when reaching
>>>    priority 0. This is because to avoid kswapd() infinite
>>>    loop. That said, kswapd assume direct reclaim makes enough
>>>    free pages to use either regular page reclaim or oom-killer.
>>>    This logic makes kswapd -> direct-reclaim dependency.
>>> 2) direct reclaim continue to reclaim without oom-killer until
>>>    kswapd turn on zone->all_unreclaimble. This is because
>>>    to avoid too early oom-kill.
>>>    This logic makes direct-reclaim -> kswapd dependency.
>>>
>>> In worst case, direct-reclaim may continue to page reclaim forever
>>> when kswapd sleeps forever.
>>
>> I have tried imagined scenario you mentioned above with code level but
>> unfortunately I got failed.
>> If kswapd can't meet high watermark on order-0, it doesn't sleep if I don't miss something.
> 
> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
> if node has multiple zones. Hm ok, I realized my descriptions was
> slightly misleading. priority 0 is not needed. bakance_pddat() calls
> pgdat_balanced()
> every priority. Most easy case is, movable zone has a lot of free pages and
> normal zone has no reclaimable page.
> 
> btw, current pgdat_balanced() logic seems not correct. kswapd should
> sleep only if every zones have much free pages than high water mark
> _and_ 25% of present pages in node are free.
> 


Sorry. I can't understand your point.
Current kswapd doesn't sleep if relevant zones don't have free pages above high watermark.
It seems I am missing your point.
Please anybody correct me.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
