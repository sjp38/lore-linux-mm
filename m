Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F07746B01AC
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 22:45:47 -0400 (EDT)
Received: by iwn39 with SMTP id 39so2442782iwn.14
        for <linux-mm@kvack.org>; Mon, 21 Jun 2010 19:45:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20100622112416.B554.A69D9226@jp.fujitsu.com>
References: <20100618093954.FBE7.A69D9226@jp.fujitsu.com>
	<20100621141315.GB2456@barrios-desktop>
	<20100622112416.B554.A69D9226@jp.fujitsu.com>
Date: Tue, 22 Jun 2010 11:45:45 +0900
Message-ID: <AANLkTilN3EcYq400ajA2-rf3Xs4MhD-sKCg44fjzKlX1@mail.gmail.com>
Subject: Re: [Patch] Call cond_resched() at bottom of main look in
	balance_pgdat()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 22, 2010 at 11:24 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> > Subject: [PATCH] Call cond_resched() at bottom of main look in balance=
_pgdat()
>> > From: Larry Woodman <lwoodman@redhat.com>
>> >
>> > We are seeing a problem where kswapd gets stuck and hogs the CPU on a
>> > small single CPU system when an OOM kill should occur. =C2=A0When this
>> > happens swap space has been exhausted and the pagecache has been shrun=
k
>> > to zero. =C2=A0Once kswapd gets the CPU it never gives it up because a=
t least
>> > one zone is below high. =C2=A0Adding a single cond_resched() at the en=
d of
>> > the main loop in balance_pgdat() fixes the problem by allowing the
>> > watchdog and tasks to run and eventually do an OOM kill which frees up
>> > the resources.
>> >
>> > kosaki note: This seems regression caused by commit bb3ab59683
>> > (vmscan: stop kswapd waiting on congestion when the min watermark is
>> > =C2=A0not being met)
>> >
>> > Signed-off-by: Larry Woodman <lwoodman@redhat.com>
>> > Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
>> > ---
>> > =C2=A0mm/vmscan.c | =C2=A0 =C2=A01 +
>> > =C2=A01 files changed, 1 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 9c7e57c..c5c46b7 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -2182,6 +2182,7 @@ loop_again:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sc.nr_reclaimed >=3D SWA=
P_CLUSTER_MAX)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
break;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cond_resched();
>> > =C2=A0 =C2=A0 }
>> > =C2=A0out:
>> > =C2=A0 =C2=A0 /*
>> > --
>> > 1.6.5.2
>>
>> Kosaki's patch's goal is that kswap doesn't yield cpu if the zone doesn'=
t meet its
>> min watermark to avoid failing atomic allocation.
>> But this patch could yield kswapd's time slice at any time.
>> Doesn't the patch break your goal in bb3ab59683?
>
> No. it don't break.
>
> Typically, kswapd periodically call shrink_page_list() and it call
> cond_resched() even if bb3ab59683 case.

Hmm. If it is, bb3ab59683 is effective really?

The bb3ab59683's goal is prevent CPU yield in case of free < min_watermark.
But shrink_page_list can yield cpu from kswapd at any time.
So I am not sure what is bb3ab59683's benefit.
Did you have any number about bb3ab59683's effectiveness?
(Of course, I know it's very hard. Just out of curiosity)

As a matter of fact, when I saw this Larry's patch, I thought it would
be better to revert bb3ab59683. Then congestion_wait could yield CPU
to other process.

What do you think about?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
