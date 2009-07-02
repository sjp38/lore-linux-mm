Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 756456B004F
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 10:03:24 -0400 (EDT)
Received: by pxi33 with SMTP id 33so1511162pxi.12
        for <linux-mm@kvack.org>; Thu, 02 Jul 2009 07:08:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090702124351.GA7488@localhost>
References: <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com>
	 <20090629091741.ab815ae7.minchan.kim@barrios-desktop>
	 <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost>
	 <29432.1246285300@redhat.com>
	 <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com>
	 <20090629160725.GF5065@csn.ul.ie> <24767.1246391867@redhat.com>
	 <20090702164106.76db077b.minchan.kim@barrios-desktop>
	 <20090702124351.GA7488@localhost>
Date: Thu, 2 Jul 2009 23:08:21 +0900
Message-ID: <28c262360907020708l2817c9e6l1f40bb9f96707741@mail.gmail.com>
Subject: Re: Found the commit that causes the OOMs
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: David Howells <dhowells@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 2, 2009 at 9:43 PM, Wu Fengguang<fengguang.wu@intel.com> wrote:
> On Thu, Jul 02, 2009 at 03:41:06PM +0800, Minchan Kim wrote:
>>
>>
>> On Tue, 30 Jun 2009 20:57:47 +0100
>> David Howells <dhowells@redhat.com> wrote:
>>
>> > Minchan Kim <minchan.kim@gmail.com> wrote:
>> >
>> > > David. Doesn't it happen OOM if you revert my patch, still?
>> >
>> > It does happen, and indeed happens in v2.6.30, but requires two adjace=
nt runs
>> > of msgctl11 to trigger, rather than usually triggering on the first ru=
n. =C2=A0If
>> > you interpolate the rest of LTP between the iterations, it doesn't see=
m to
>> > happen at all on v2.6.30. =C2=A0My guess is that with the rest of LTP =
interpolated,
>> > there's either enough time for some cleanup or something triggers a cl=
eanup
>> > (the swapfile tests perhaps?).
>> >
>> > > Befor I go to the trip, I made debugging patch in a hurry. =C2=A0Mel=
 and I
>> > > suspect to put the wrong page in lru list.
>> > >
>> > > This patch's goal is that print page's detail on active anon lru whe=
n it
>> > > happen OOM. =C2=A0Maybe you could expand your log buffer size.
>> >
>> > Do you mean to expand the dmesg buffer? =C2=A0That's probably unnecess=
ary: I capture
>> > the kernel log over a serial port into a file on another machine.
>> >
>> > > Could you show me the information with OOM, please ?
>> >
>> > Attached. =C2=A0It's compressed as there was rather a lot.
>> >
>> > David
>> > ---
>>
>> Hi, David.
>>
>> Sorry for late response.
>>
>> I looked over your captured data when I got home but I didn't find any p=
roblem
>> in lru page moving scheme.
>> As Wu, Kosaki and Rik discussed, I think this issue is also related to p=
rocess fork bomb.
>
> Yes, me think so.
>
>> When I tested msgctl11 in my machine with 2.6.31-rc1, I found that:
>
> Were you testing the no-swap case?

Yes.

>> 2.6.31-rc1
>> real =C2=A00m38.628s
>> user =C2=A00m10.589s
>> sys =C2=A0 1m12.613s
>>
>> vmstat
>>
>> allocstall 3196
>>
>> 2.6.31-rc1-revert-mypatch
>>
>> real =C2=A01m17.396s
>> user =C2=A00m11.193s
>> sys =C2=A0 4m3.803s
>
> It's interesting that (sys > real).

My test environment is quad core. :)

>> vmstat
>>
>> allocstall 584
>>
>> Sometimes I got OOM, sometime not in with 2.6.31-rc1.
>>
>> Anyway, the current kernel's test took a rather short time than my rever=
ted patch.
>> In addition, the current kernel has small allocstall(direct reclaim)
>>
>> As you know, my patch was just to remove calling shrink_active_list in c=
ase of no swap.
>> shrink_active_list function is a big cost function.
>> The old shrink_active_list could throttle to fork processes by chance.
>> But by removing that function with my patch, we have a high
>> probability to make process fork bomb. Wu, KOSAKI and Rik, does it
>> make sense?
>
> Maybe, but I'm not sure on how to explain the time/vmstat numbers :(

I think we can prove it following as.
For example, whenever the each forking 1000 processes from starting msgctl1=
1,
we look at the vmstat and check the elasped time.

I think current kernel may take a very short time but many allocstall .
but reverted one may take a rather long time but small allocstall increasem=
ent
after some time(maybe when inactive_anon_is low).

In addition, we can check shrink_active_list's collpased time when the
inactive_aon_is low.

>
>> So I think you were just lucky with a unnecessary routine.
>> Anyway, AFAIK, Rik is making throttling page reclaim.
>> I think it can solve your problem.
>
> Yes, with good luck :)
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
