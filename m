Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 66A0E6B038A
	for <linux-mm@kvack.org>; Sun, 22 Aug 2010 21:58:11 -0400 (EDT)
Received: by iwn33 with SMTP id 33so3810232iwn.14
        for <linux-mm@kvack.org>; Sun, 22 Aug 2010 18:58:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100822232316.GA339@localhost>
References: <20100817111018.GQ19797@csn.ul.ie>
	<4385155269B445AEAF27DC8639A953D7@rainbow>
	<20100818154130.GC9431@localhost>
	<565A4EE71DAC4B1A820B2748F56ABF73@rainbow>
	<20100819160006.GG6805@barrios-desktop>
	<AA3F2D89535A431DB91FE3032EDCB9EA@rainbow>
	<20100820053447.GA13406@localhost>
	<20100820093558.GG19797@csn.ul.ie>
	<AANLkTimVmoomDjGMCfKvNrS+v-mMnfeq6JDZzx7fjZi+@mail.gmail.com>
	<20100822153121.GA29389@barrios-desktop>
	<20100822232316.GA339@localhost>
Date: Mon, 23 Aug 2010 10:58:09 +0900
Message-ID: <AANLkTim8c5C+vH1HUx-GsScirmnVoJXenLST1qQgk2bp@mail.gmail.com>
Subject: Re: compaction: trying to understand the code
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Iram Shahzad <iram.shahzad@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, Aug 23, 2010 at 8:23 AM, Wu Fengguang <fengguang.wu@intel.com> wrot=
e:
>> From: Minchan Kim <minchan.kim@gmail.com>
>> Date: Mon, 23 Aug 2010 00:20:44 +0900
>> Subject: [PATCH] compaction: handle active and inactive fairly in too_ma=
ny_isolated
>>
>> Iram reported compaction's too_many_isolated loops forever.
>> (http://www.spinics.net/lists/linux-mm/msg08123.html)
>>
>> The meminfo of situation happened was inactive anon is zero.
>> That's because the system has no memory pressure until then.
>> While all anon pages was in active lru, compaction could select
>> active lru as well as inactive lru. That's different things
>> with vmscan's isolated. So we has been two too_many_isolated.
>>
>> While compaction can isolated pages in both active and inactive,
>> current implementation of too_many_isolated only considers inactive.
>> It made Iram's problem.
>>
>> This patch handles active and inactie with fair.
>> That's because we can't expect where from and how many compaction would
>> isolated pages.
>>
>> This patch changes (nr_isolated > nr_inactive) with
>> nr_isolated > (nr_active + nr_inactive) / 2.
>
> The change looks good, thanks. However I'm not sure if it's enough.

Thanks.

>
> I wonder where the >40MB isolated pages come about. =A0inactive_anon
> remains 0 and free remains high over a long time, so it seems there
> are no concurrent direct reclaims at all. Are the pages isolated by
> the compaction process itself?

Agree. I wonder too.

Now compaction isolates page per 32 until reaching pageblock_nr_pages,
So I can't understand how 40MB isolated pages come out.

Iram. How do you execute test_app?

1) synchronous test
1.1 start test_app
1.2 wait test_app job done (ie, wait memory is fragment)
1.3 echo 1 > /proc/sys/vm/compact_memory

2) asynchronous test
2.1 start test_app
2.2 not wait test_app job done
2.3 echo 1 > /proc/sys/vm/compact_memory(Maybe your test app and
compaction were executed parallel)

Which one is your scenario?


>
> Thanks,
> Fengguang
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
