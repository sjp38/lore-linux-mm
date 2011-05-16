Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9FD6B0025
	for <linux-mm@kvack.org>; Mon, 16 May 2011 04:59:02 -0400 (EDT)
Received: by qwa26 with SMTP id 26so3110614qwa.14
        for <linux-mm@kvack.org>; Mon, 16 May 2011 01:58:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110516084558.GE5279@suse.de>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
	<1305295404-12129-5-git-send-email-mgorman@suse.de>
	<4DCFAA80.7040109@jp.fujitsu.com>
	<1305519711.4806.7.camel@mulgrave.site>
	<BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
	<20110516084558.GE5279@suse.de>
Date: Mon, 16 May 2011 17:58:59 +0900
Message-ID: <BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Mon, May 16, 2011 at 5:45 PM, Mel Gorman <mgorman@suse.de> wrote:
> On Mon, May 16, 2011 at 02:04:00PM +0900, Minchan Kim wrote:
>> On Mon, May 16, 2011 at 1:21 PM, James Bottomley
>> <James.Bottomley@hansenpartnership.com> wrote:
>> > On Sun, 2011-05-15 at 19:27 +0900, KOSAKI Motohiro wrote:
>> >> (2011/05/13 23:03), Mel Gorman wrote:
>> >> > Under constant allocation pressure, kswapd can be in the situation =
where
>> >> > sleeping_prematurely() will always return true even if kswapd has b=
een
>> >> > running a long time. Check if kswapd needs to be scheduled.
>> >> >
>> >> > Signed-off-by: Mel Gorman<mgorman@suse.de>
>> >> > ---
>> >> > =C2=A0 mm/vmscan.c | =C2=A0 =C2=A04 ++++
>> >> > =C2=A0 1 files changed, 4 insertions(+), 0 deletions(-)
>> >> >
>> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> >> > index af24d1e..4d24828 100644
>> >> > --- a/mm/vmscan.c
>> >> > +++ b/mm/vmscan.c
>> >> > @@ -2251,6 +2251,10 @@ static bool sleeping_prematurely(pg_data_t *=
pgdat, int order, long remaining,
>> >> > =C2=A0 =C2=A0 unsigned long balanced =3D 0;
>> >> > =C2=A0 =C2=A0 bool all_zones_ok =3D true;
>> >> >
>> >> > + =C2=A0 /* If kswapd has been running too long, just sleep */
>> >> > + =C2=A0 if (need_resched())
>> >> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return false;
>> >> > +
>> >>
>> >> Hmm... I don't like this patch so much. because this code does
>> >>
>> >> - don't sleep if kswapd got context switch at shrink_inactive_list
>> >
>> > This isn't entirely true: =C2=A0need_resched() will be false, so we'll=
 follow
>> > the normal path for determining whether to sleep or not, in effect
>> > leaving the current behaviour unchanged.
>> >
>> >> - sleep if kswapd didn't
>> >
>> > This also isn't entirely true: whether need_resched() is true at this
>> > point depends on a whole lot more that whether we did a context switch
>> > in shrink_inactive. It mostly depends on how long we've been running
>> > without giving up the CPU. =C2=A0Generally that will mean we've been r=
ound
>> > the shrinker loop hundreds to thousands of times without sleeping.
>> >
>> >> It seems to be semi random behavior.
>> >
>> > Well, we have to do something. =C2=A0Chris Mason first suspected the h=
ang was
>> > a kswapd rescheduling problem a while ago. =C2=A0We tried putting
>> > cond_rescheds() in several places in the vmscan code, but to no avail.
>>
>> Is it a result of =C2=A0test with patch of Hannes(ie, !pgdat_balanced)?
>>
>> If it isn't, it would be nop regardless of putting cond_reshed at vmscan=
.c.
>> Because, although we complete zone balancing, kswapd doesn't sleep as
>> pgdat_balance returns wrong result. And at last VM calls
>> balance_pgdat. In this case, balance_pgdat returns without any work as
>> kswap couldn't find zones which have not enough free pages and goto
>> out. kswapd could repeat this work infinitely. So you don't have a
>> chance to call cond_resched.
>>
>> But if your test was with Hanne's patch, I am very curious how come
>> kswapd consumes CPU a lot.
>>
>> > The need_resched() in sleeping_prematurely() seems to be about the bes=
t
>> > option. =C2=A0The other option might be just to put a cond_resched() i=
n
>> > kswapd_try_to_sleep(), but that will really have about the same effect=
.
>>
>> I don't oppose it but before that, I think we have to know why kswapd
>> consumes CPU a lot although we applied Hannes' patch.
>>
>
> Because it's still possible for processes to allocate pages at the same
> rate kswapd is freeing them leading to a situation where kswapd does not
> consider the zone balanced for prolonged periods of time.

We have cond_resched in shrink_page_list, shrink_slab and balance_pgdat.
So I think kswapd can be scheduled out although it's scheduled in
after a short time as task scheduled also need page reclaim. Although
all task in system need reclaim, kswapd cpu 99% consumption is a
natural result, I think.
Do I miss something?

>
> --
> Mel Gorman
> SUSE Labs
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
