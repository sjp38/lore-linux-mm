Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 94C49900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 19:32:20 -0400 (EDT)
Received: by iyh42 with SMTP id 42so6471210iyh.14
        for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:32:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikZcTj9GAGrsTnMMCq1b9HjnDnGWA@mail.gmail.com>
References: <1302909815-4362-1-git-send-email-yinghan@google.com>
	<1302909815-4362-7-git-send-email-yinghan@google.com>
	<BANLkTi=2yQZXhHrDxjPvpKJ-KpmQ242cVQ@mail.gmail.com>
	<BANLkTikZcTj9GAGrsTnMMCq1b9HjnDnGWA@mail.gmail.com>
Date: Tue, 19 Apr 2011 08:32:18 +0900
Message-ID: <BANLkTi=pyRWb9npHe_SJdYXR-TbrtVtLRg@mail.gmail.com>
Subject: Re: [PATCH V5 06/10] Per-memcg background reclaim.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, Apr 19, 2011 at 6:38 AM, Ying Han <yinghan@google.com> wrote:
>
>
> On Sun, Apr 17, 2011 at 8:51 PM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>>
>> On Sat, Apr 16, 2011 at 8:23 AM, Ying Han <yinghan@google.com> wrote:
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sc->nr_scanned =3D =
0;
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 shrink_zone(priorit=
y, zone, sc);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total_scanned +=3D =
sc->nr_scanned;
>> > +
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* If we've do=
ne a decent amount of scanning and
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* the reclaim=
 ratio is low, start doing writepage
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* even in lap=
top mode
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (total_scanned >=
 SWAP_CLUSTER_MAX * 2 &&
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 total=
_scanned > sc->nr_reclaimed + sc->nr_reclaimed
>> > / 2) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 sc->may_writepage =3D 1;
>>
>> I don't want to add more random write any more although we don't have
>> a trouble of real memory shortage.
>
>
>>
>> Do you have any reason to reclaim memory urgently as writing dirty pages=
?
>> Maybe if we wait a little bit of time, flusher would write out the page.
>
> We would like to reduce the writing dirty pages from page reclaim,
> especially from direct reclaim. AFAIK, the=C2=A0try_to_free_mem_cgroup_pa=
ges()
> still need to write dirty pages when there is a need. removing this from =
the
> per-memcg kswap will only add more pressure to the per-memcg direct recla=
im,
> which seems to be worse. (stack overflow as one example which we would li=
ke
> to get rid of)
>

Stack overflow would be another topic.

Normal situation :

The softlimit memory pressure of memcg isn't real memory shortage and
if we have gap between hardlimit and softlimit, periodic writeback of
flusher would write it out before reaching the hardlimit. In the end,
direct reclaim don't need to write it out.

Exceptional situation :

Of course, it doesn't work well in congestion of bdi, sudden big
memory consumption in memcg in wrong [hard/soft]limit(small gap)
configuration of administrator.

I think we have to design it by normal situation.
The point is that softlimit isn't real memory shortage so that we are
not urgent.

How about adding new function which checks global memory pressure and
if we have a trouble by global memory pressure, we can change
may_write with 1 dynamically in memcg_kswapd?

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
