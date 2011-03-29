Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id EF8FD8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 13:39:36 -0400 (EDT)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p2THdXBP019490
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:39:34 -0700
Received: from gwb19 (gwb19.prod.google.com [10.200.2.19])
	by hpaq2.eem.corp.google.com with ESMTP id p2THcWUC006693
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:39:32 -0700
Received: by gwb19 with SMTP id 19so192976gwb.32
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 10:39:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110329153853.GD2879@balbir.in.ibm.com>
References: <1301292775-4091-1-git-send-email-yinghan@google.com>
	<1301292775-4091-2-git-send-email-yinghan@google.com>
	<20110328163311.127575fa.nishimura@mxp.nes.nec.co.jp>
	<20110329153853.GD2879@balbir.in.ibm.com>
Date: Tue, 29 Mar 2011 10:39:31 -0700
Message-ID: <BANLkTikXHW-yvJp=fw1D-Y3BMRadbLQvsg@mail.gmail.com>
Subject: Re: [PATCH 1/2] check the return value of soft_limit reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Mar 29, 2011 at 8:38 AM, Balbir Singh <balbir@linux.vnet.ibm.com> w=
rote:
> * nishimura@mxp.nes.nec.co.jp <nishimura@mxp.nes.nec.co.jp> [2011-03-28 1=
6:33:11]:
>
>> Hi,
>>
>> This patch looks good to me, except for one nitpick.
>>
>> On Sun, 27 Mar 2011 23:12:54 -0700
>> Ying Han <yinghan@google.com> wrote:
>>
>> > In the global background reclaim, we do soft reclaim before scanning t=
he
>> > per-zone LRU. However, the return value is ignored. This patch adds th=
e logic
>> > where no per-zone reclaim happens if the soft reclaim raise the free p=
ages
>> > above the zone's high_wmark.
>> >
>> > I did notice a similar check exists but instead leaving a "gap" above =
the
>> > high_wmark(the code right after my change in vmscan.c). There are disc=
ussions
>> > on whether or not removing the "gap" which intends to balance pressure=
s across
>> > zones over time. Without fully understand the logic behind, I didn't t=
ry to
>> > merge them into one, but instead adding the condition only for memcg u=
sers
>> > who care a lot on memory isolation.
>> >
>> > Signed-off-by: Ying Han <yinghan@google.com>
>> > ---
>> > =A0mm/vmscan.c | =A0 16 +++++++++++++++-
>> > =A01 files changed, 15 insertions(+), 1 deletions(-)
>> >
>> > diff --git a/mm/vmscan.c b/mm/vmscan.c
>> > index 060e4c1..e4601c5 100644
>> > --- a/mm/vmscan.c
>> > +++ b/mm/vmscan.c
>> > @@ -2320,6 +2320,7 @@ static unsigned long balance_pgdat(pg_data_t *pg=
dat, int order,
>> > =A0 =A0 int end_zone =3D 0; =A0 =A0 =A0 /* Inclusive. =A00 =3D ZONE_DM=
A */
>> > =A0 =A0 unsigned long total_scanned;
>> > =A0 =A0 struct reclaim_state *reclaim_state =3D current->reclaim_state=
;
>> > + =A0 unsigned long nr_soft_reclaimed;
>> > =A0 =A0 struct scan_control sc =3D {
>> > =A0 =A0 =A0 =A0 =A0 =A0 .gfp_mask =3D GFP_KERNEL,
>> > =A0 =A0 =A0 =A0 =A0 =A0 .may_unmap =3D 1,
>> > @@ -2413,7 +2414,20 @@ loop_again:
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Call soft limit reclaim b=
efore calling shrink_zone.
>> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* For now we ignore the ret=
urn value
>>
>> You should remove this comment too.
>>
>> But, Balbir-san, do you remember why did you ignore the return value her=
e ?
>>
>
> We do that since soft limit reclaim cannot help us make a decision from t=
he return value. balance_gap is recomputed following this routine.

I don't fully understand the "balance_gap" at the first place, and
maybe that is something interesting to talk about
in LSF :)


May be it might make sense to increment sc.nr_reclaimed based on the
return value?

Yes, that is how it is implemented now in V3 where we contribute the
sc.nr_scanned and sc.nr_reclaimed from soft_limit reclaim.

Thanks

--Ying

>
> --
> =A0 =A0 =A0 =A0Three Cheers,
> =A0 =A0 =A0 =A0Balbir
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
