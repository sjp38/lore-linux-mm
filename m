Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id EE247900137
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 03:04:10 -0400 (EDT)
Received: by qwa26 with SMTP id 26so1997001qwa.14
        for <linux-mm@kvack.org>; Fri, 12 Aug 2011 00:04:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110812065858.GA6916@redhat.com>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
	<1313094715-31187-2-git-send-email-jweiner@redhat.com>
	<CAEwNFnBp7JBWpuaT=ZKDyfQTQqOe_mT0CLFAw9LWo10GoXaFnQ@mail.gmail.com>
	<20110812065858.GA6916@redhat.com>
Date: Fri, 12 Aug 2011 16:04:08 +0900
Message-ID: <CAEwNFnDHdPKLrN0aDxd1RTYZT-ua=yTpYVQqAunNaqkr8ok4nQ@mail.gmail.com>
Subject: Re: [patch 2/2] mm: vmscan: drop nr_force_scan[] from get_scan_count
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Fri, Aug 12, 2011 at 3:58 PM, Johannes Weiner <jweiner@redhat.com> wrote=
:
> On Fri, Aug 12, 2011 at 08:44:34AM +0900, Minchan Kim wrote:
>> On Fri, Aug 12, 2011 at 5:31 AM, Johannes Weiner <jweiner@redhat.com> wr=
ote:
>> > The nr_force_scan[] tuple holds the effective scan numbers for anon
>> > and file pages in case the situation called for a forced scan and the
>> > regularly calculated scan numbers turned out zero.
>> >
>> > However, the effective scan number can always be assumed to be
>> > SWAP_CLUSTER_MAX right before the division into anon and file. =C2=A0T=
he
>> > numerators and denominator are properly set up for all cases, be it
>> > force scan for just file, just anon, or both, to do the right thing.
>> >
>> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
>>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>
> Thanks.
>
>> There is a nitpick at below.
>
>> > @@ -1927,20 +1917,10 @@ out:
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scan =3D zone_n=
r_lru_pages(zone, sc, l);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0if (priority ||=
 noswap) {
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0scan >>=3D priority;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 if (!scan && force_scan)
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 scan =3D SWAP_CLUSTER_MAX;
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0scan =3D div64_u64(scan * fraction[file], denominator);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>> > -
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If zone is =
small or memcg is small, nr[l] can be 0.
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* This result=
s no-scan on this priority and priority drop down.
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* For global =
direct reclaim, it can visit next zone and tend
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* not to have=
 problems. For global kswapd, it's for zone
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* balancing a=
nd it need to scan a small amounts. When using
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* memcg, prio=
rity drop can cause big latency. So, it's better
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* to scan sma=
ll amount. See may_noscan above.
>> > - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>>
>> Please move this comment with tidy-up at where making force_scan true.
>> Of course, we can find it by git log[246e87a9393] but as I looked the
>> git log, it explain this comment indirectly and it's not
>> understandable to newbies. I think this comment is more understandable
>> than changelog in git.
>
> I guess you are right, I am a bit overeager when deleting comments.
> How is this?
>
> ---
> From: Johannes Weiner <jweiner@redhat.com>
> Subject: [patch] mm: vmscan: drop nr_force_scan[] from get_scan_count
>
> The nr_force_scan[] tuple holds the effective scan numbers for anon
> and file pages in case the situation called for a forced scan and the
> regularly calculated scan numbers turned out zero.
>
> However, the effective scan number can always be assumed to be
> SWAP_CLUSTER_MAX right before the division into anon and file. =C2=A0The
> numerators and denominator are properly set up for all cases, be it
> force scan for just file, just anon, or both, to do the right thing.
>
> Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks, Hannes.
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
