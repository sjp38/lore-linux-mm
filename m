Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 38F226B0024
	for <linux-mm@kvack.org>; Tue, 10 May 2011 00:39:40 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id p4A4dZEe029008
	for <linux-mm@kvack.org>; Mon, 9 May 2011 21:39:36 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by wpaz24.hot.corp.google.com with ESMTP id p4A4dY1H014199
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 9 May 2011 21:39:34 -0700
Received: by qyk7 with SMTP id 7so4496320qyk.10
        for <linux-mm@kvack.org>; Mon, 09 May 2011 21:39:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110510084923.03a282f1.kamezawa.hiroyu@jp.fujitsu.com>
References: <BANLkTimmpHcSJuO_8+P=GjYf+wB=Nyq=4w@mail.gmail.com>
	<20110503082550.GD18927@tiehlicka.suse.cz>
	<BANLkTikZtOdzsnjH=43AegLCpYc6ecfKsg@mail.gmail.com>
	<20110504085851.GC1375@tiehlicka.suse.cz>
	<BANLkTinxuSaCEvN4_vB=uA1rdGUwCpovog@mail.gmail.com>
	<20110505065901.GC11529@tiehlicka.suse.cz>
	<20110506142834.90e0b363.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTinEEzkpBeTdK9nP2DAxRZbH8Ve=xw@mail.gmail.com>
	<20110509161047.eb674346.kamezawa.hiroyu@jp.fujitsu.com>
	<20110509101817.GB16531@cmpxchg.org>
	<20110509124916.GD4273@tiehlicka.suse.cz>
	<20110510084923.03a282f1.kamezawa.hiroyu@jp.fujitsu.com>
Date: Mon, 9 May 2011 21:39:34 -0700
Message-ID: <BANLkTinpoB_FnpGh=-xmbm5oPT6M2GShCQ@mail.gmail.com>
Subject: Re: [PATCH 1/7] memcg: add high/low watermark to res_counter
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>

On Mon, May 9, 2011 at 4:49 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 9 May 2011 14:49:17 +0200
> Michal Hocko <mhocko@suse.cz> wrote:
>
>> On Mon 09-05-11 12:18:17, Johannes Weiner wrote:
>> > On Mon, May 09, 2011 at 04:10:47PM +0900, KAMEZAWA Hiroyuki wrote:
>> [...]
>> > What I am wondering, though: we already have a limit to push back
>> > memcgs when we need memory, the soft limit. =A0The 'need for memory' i=
s
>> > currently defined as global memory pressure, which we know may be too
>> > late. =A0The problem is not having no limit, the problem is that we wa=
nt
>> > to control the time of when this limit is enforced. =A0So instead of
>> > adding another limit, could we instead add a knob like
>> >
>> > =A0 =A0 memory.force_async_soft_reclaim
>> >
>> > that asynchroneously pushes back to the soft limit instead of having
>> > another, separate limit to configure?
>>
>
> Hmm, ok to me.

I don't have problem of the actual tunable for this, but I don't think
setting the soft_limit as the target for per-memcg background reclaim
is feasible in some cases. That will be too aggressive than it is necessary=
.

>
>> Sound much better than a separate watermark to me. I am just wondering
>> how we would implement soft unlimited groups with background reclaim.
>> Btw. is anybody relying on such configuration? To me it sounds like
>> something should be either limited or unlimited and making it half of
>> both is hacky.
>
> I don't think of soft-unlimited configuration. I don't want to handle it
> in some automatic way.
>
> Anyway, I'll add
> =A0- _automatic_ background reclaim against the limit of memory, which wo=
rks
> =A0 =A0regarless of softlimit.

I agree to have the background reclaim first w/ automatic watermark
setting and then adding a configurable knob on top of that. So I
assume we keep the same concept of high/low_wmarks, and what's the
suggested default value for the watermarks? The default value now is
equal to hard_limit which disables he per-memcg background reclaim.
Under the new scheme which we remove the configurable tunable, we need
to set it internally based on the hard_limit.

--Ying

> =A0- An interface for force softlimit.
>
> Thanks,
> -Kame
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
