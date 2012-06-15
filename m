Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 6E6C86B0069
	for <linux-mm@kvack.org>; Fri, 15 Jun 2012 08:31:51 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so2221822vcb.14
        for <linux-mm@kvack.org>; Fri, 15 Jun 2012 05:31:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FDAE3CC.60801@kernel.org>
References: <1339661592-3915-1-git-send-email-kosaki.motohiro@gmail.com>
	<20120614145716.GA2097@barrios>
	<CAHGf_=qcA5OfuNgk0BiwyshcLftNWoPfOO_VW9H6xQTX2tAbuA@mail.gmail.com>
	<4FDAE3CC.60801@kernel.org>
Date: Fri, 15 Jun 2012 20:31:50 +0800
Message-ID: <CAJd=RBBSa2TuRDVGrY9JT9m3K68N1LWiZKyo3Y1mdQRo5TxBLQ@mail.gmail.com>
Subject: Re: [resend][PATCH] mm, vmscan: fix do_try_to_free_pages() livelock
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Nick Piggin <npiggin@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Minchan and KOSAKI

On Fri, Jun 15, 2012 at 3:27 PM, Minchan Kim <minchan@kernel.org> wrote:
> On 06/15/2012 01:10 AM, KOSAKI Motohiro wrote:
>
>> On Thu, Jun 14, 2012 at 10:57 AM, Minchan Kim <minchan@kernel.org> wrote=
:
>>> Hi KOSAKI,
>>>
>>> Sorry for late response.
>>> Let me ask a question about description.
>>>
>>> On Thu, Jun 14, 2012 at 04:13:12AM -0400, kosaki.motohiro@gmail.com wro=
te:
>>>> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>>>>
>>>> Currently, do_try_to_free_pages() can enter livelock. Because of,
>>>> now vmscan has two conflicted policies.
>>>>
>>>> 1) kswapd sleep when it couldn't reclaim any page when reaching
>>>> =C2=A0 =C2=A0priority 0. This is because to avoid kswapd() infinite
>>>> =C2=A0 =C2=A0loop. That said, kswapd assume direct reclaim makes enoug=
h
>>>> =C2=A0 =C2=A0free pages to use either regular page reclaim or oom-kill=
er.
>>>> =C2=A0 =C2=A0This logic makes kswapd -> direct-reclaim dependency.
>>>> 2) direct reclaim continue to reclaim without oom-killer until
>>>> =C2=A0 =C2=A0kswapd turn on zone->all_unreclaimble. This is because
>>>> =C2=A0 =C2=A0to avoid too early oom-kill.
>>>> =C2=A0 =C2=A0This logic makes direct-reclaim -> kswapd dependency.
>>>>
>>>> In worst case, direct-reclaim may continue to page reclaim forever
>>>> when kswapd sleeps forever.
>>>
>>> I have tried imagined scenario you mentioned above with code level but
>>> unfortunately I got failed.
>>> If kswapd can't meet high watermark on order-0, it doesn't sleep if I d=
on't miss something.
>>
>> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
>> if node has multiple zones. Hm ok, I realized my descriptions was
>> slightly misleading. priority 0 is not needed. bakance_pddat() calls
>> pgdat_balanced()
>> every priority. Most easy case is, movable zone has a lot of free pages =
and
>> normal zone has no reclaimable page.
>>
>> btw, current pgdat_balanced() logic seems not correct. kswapd should
>> sleep only if every zones have much free pages than high water mark
>> _and_ 25% of present pages in node are free.
>>
>
>
> Sorry. I can't understand your point.
> Current kswapd doesn't sleep if relevant zones don't have free pages abov=
e high watermark.
> It seems I am missing your point.
> Please anybody correct me.
>

Who left comment on unreclaimable there, and why?
		/*
		 * balance_pgdat() skips over all_unreclaimable after
		 * DEF_PRIORITY. Effectively, it considers them balanced so
		 * they must be considered balanced here as well if kswapd
		 * is to sleep
		 */

BTW, are you still using prefetch_prev_lru_page?

Good Weekend
Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
