Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 9D04D6B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 04:57:09 -0400 (EDT)
Received: by qyk2 with SMTP id 2so1626484qyk.14
        for <linux-mm@kvack.org>; Tue, 24 May 2011 01:57:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DDB6F48.1010809@jp.fujitsu.com>
References: <4DCDA347.9080207@cray.com>
	<BANLkTikiXUzbsUkzaKZsZg+5ugruA2JdMA@mail.gmail.com>
	<4DD2991B.5040707@cray.com>
	<BANLkTimYEs315jjY9OZsL6--mRq3O_zbDA@mail.gmail.com>
	<20110520164924.GB2386@barrios-desktop>
	<4DDB3A1E.6090206@jp.fujitsu.com>
	<BANLkTinkcu5j1H8tHNT4aTmOL-GXfSwPQw@mail.gmail.com>
	<4DDB6F48.1010809@jp.fujitsu.com>
Date: Tue, 24 May 2011 17:57:07 +0900
Message-ID: <BANLkTimbu0pDNb1cHGu0B6P-foRHQ2uiWw@mail.gmail.com>
Subject: Re: Unending loop in __alloc_pages_slowpath following OOM-kill; rfc: patch.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: abarry@cray.com, akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@suse.de, riel@redhat.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com

On Tue, May 24, 2011 at 5:41 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>>> I'm sorry I missed this thread long time.
>>
>> No problem. It would be better than not review.
>
> thx.
>
>
>>> In this case, I think we should call drain_all_pages(). then following
>>> patch is better.
>>
>> Strictly speaking, this problem isn't related to drain_all_pages.
>> This problem caused by lru empty but I admit it could work well if
>> your patch applied.
>> So yours could help, too.
>>
>>> However I also think your patch is valuable. because while the task is
>>> sleeping in wait_iff_congested(), an another task may free some pages.
>>> thus, rebalance path should try to get free pages. iow, you makes sense=
.
>>
>> Yes.
>> Off-topic.
>> I would like to move cond_resched below get_page_from_freelist in
>> __alloc_pages_direct_reclaim. Otherwise, it is likely we can be stolen
>> pages to other processes.
>> One more benefit is that if it's apparently OOM path(ie,
>> did_some_progress =3D 0), we can reduce OOM kill latency due to remove
>> unnecessary cond_resched.
>
> I agree. Can you please mind to send a patch?

I had but at that time, Andrew had a concern.
I will resend it when I have a time. Let's discuss, again.

>
>
>>> So, I'd like to propose to merge both your and my patch.
>>
>> Recently, there was discussion on drain_all_pages with Wu.
>> He saw much overhead in 8-core system, AFAIR.
>> I Cced Wu.
>>
>> How about checking per-cpu before calling drain_all_pages() than
>> unconditional calling?
>> if (per_cpu_ptr(zone->pageset, smp_processor_id())
>> =C2=A0 =C2=A0 drain_all_pages();
>>
>> Of course, It can miss other CPU free pages. But above routine assume
>> local cpu direct reclaim is successful but it failed by per-cpu. So I
>> think it works.
>
> Can you please tell me previous discussion url or mail subject?
> I mean, if it is costly and performance degression risk, we don't have to
> take my idea.

Yes. You could see it by https://lkml.org/lkml/2011/4/30/81.

>
> Thanks.
>
>
>>
>> Thanks for good suggestion and Reviewed-by, KOSAKI.
>
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
