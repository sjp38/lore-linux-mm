Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C69356B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:13:51 -0500 (EST)
Received: by pwi1 with SMTP id 1so2911423pwi.6
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 17:13:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091215090441.CDB0.A69D9226@jp.fujitsu.com>
References: <20091214213026.BBBD.A69D9226@jp.fujitsu.com>
	 <20091215084636.c7790658.minchan.kim@barrios-desktop>
	 <20091215090441.CDB0.A69D9226@jp.fujitsu.com>
Date: Tue, 15 Dec 2009 10:13:48 +0900
Message-ID: <28c262360912141713t6e0e5915m3bb30aa099914c40@mail.gmail.com>
Subject: Re: [PATCH 5/8] Use io_schedule() instead schedule()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, lwoodman@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Dec 15, 2009 at 9:56 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> On Mon, 14 Dec 2009 21:30:54 +0900 (JST)
>> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>
>> > All task sleeping point in vmscan (e.g. congestion_wait) use
>> > io_schedule. then shrink_zone_begin use it too.
>> >
>> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > ---
>> > =C2=A0mm/vmscan.c | =C2=A0 =C2=A02 +-
>> > =C2=A01 files changed, 1 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 3562a2d..0880668 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -1624,7 +1624,7 @@ static int shrink_zone_begin(struct zone *zone, =
struct scan_control *sc)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 max_zone_concu=
rrent_reclaimers)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
break;
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 schedule();
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 io_schedule();
>>
>> Hmm. We have many cond_resched which is not io_schedule in vmscan.c.
>
> cond_resched don't mean sleep on wait queue. it's similar to yield.

I confused it.
Thanks for correcting me. :)

>
>> In addition, if system doesn't have swap device space and out of page ca=
che
>> due to heavy memory pressue, VM might scan & drop pages until priority i=
s zero
>> or zone is unreclaimable.
>>
>> I think it would be not a IO wait.
>
> two point.
> 1. For long time, Administrator usually watch iowait% at heavy memory pre=
ssure. I
> don't hope change this without reasonable reason. 2. iowait makes schedul=
er
> bonus a bit, vmscan task should have many time slice than memory consume
> task. it improve VM stabilization.

AFAIK, CFS scheduler doesn't give the bonus to I/O wait task any more.

>
> but I agree the benefit isn't so big. if we have reasonable reason, I
> don't oppose use schedule().
>
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
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
