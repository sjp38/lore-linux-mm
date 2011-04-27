Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 22A679000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 05:14:58 -0400 (EDT)
Received: by vws4 with SMTP id 4so1658965vws.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 02:14:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427174813.8b34df90.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110427164708.1143395e.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin+rDOWGYq9dg-XcCWs+yT8Yw-VMw@mail.gmail.com>
	<20110427174813.8b34df90.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 18:14:56 +0900
Message-ID: <BANLkTim-U3MTnToFPL11NcVnOCig4zJMAQ@mail.gmail.com>
Subject: Re: [PATCHv3] memcg: fix get_scan_count for small targets
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Ying Han <yinghan@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "mgorman@suse.de" <mgorman@suse.de>

On Wed, Apr 27, 2011 at 5:48 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Wed, 27 Apr 2011 17:48:18 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
>
>> On Wed, Apr 27, 2011 at 4:47 PM, KAMEZAWA Hiroyuki
>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> > At memory reclaim, we determine the number of pages to be scanned
>> > per zone as
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0(anon + file) >> priority.
>> > Assume
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0scan =3D (anon + file) >> priority.
>> >
>> > If scan < SWAP_CLUSTER_MAX, the scan will be skipped for this time
>> > and priority gets higher. This has some problems.
>> >
>> > =C2=A01. This increases priority as 1 without any scan.
>> > =C2=A0 =C2=A0 To do scan in this priority, amount of pages should be l=
arger than 512M.
>> > =C2=A0 =C2=A0 If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and=
 scan will be
>> > =C2=A0 =C2=A0 batched, later. (But we lose 1 priority.)
>> > =C2=A0 =C2=A0 If memory size is below 16M, pages >> priority is 0 and =
no scan in
>> > =C2=A0 =C2=A0 DEF_PRIORITY forever.
>> >
>> > =C2=A02. If zone->all_unreclaimabe=3D=3Dtrue, it's scanned only when p=
riority=3D=3D0.
>> > =C2=A0 =C2=A0 So, x86's ZONE_DMA will never be recoverred until the us=
er of pages
>> > =C2=A0 =C2=A0 frees memory by itself.
>> >
>> > =C2=A03. With memcg, the limit of memory can be small. When using smal=
l memcg,
>> > =C2=A0 =C2=A0 it gets priority < DEF_PRIORITY-2 very easily and need t=
o call
>> > =C2=A0 =C2=A0 wait_iff_congested().
>> > =C2=A0 =C2=A0 For doing scan before priorty=3D9, 64MB of memory should=
 be used.
>> >
>> > Then, this patch tries to scan SWAP_CLUSTER_MAX of pages in force...wh=
en
>> >
>> > =C2=A01. the target is enough small.
>> > =C2=A02. it's kswapd or memcg reclaim.
>> >
>> > Then we can avoid rapid priority drop and may be able to recover
>> > all_unreclaimable in a small zones. And this patch removes nr_saved_sc=
an.
>> > This will allow scanning in this priority even when pages >> priority
>> > is very small.
>> >
>> > Changelog v2->v3
>> > =C2=A0- removed nr_saved_scan completely.
>> >
>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>>
>> The patch looks good to me but I have a nitpick about just coding style.
>> How about this? I think below looks better but it's just my private
>> opinion and I can't insist on my style. If you don't mind it, ignore.
>>
>
> I did this at the 1st try and got bug.....a variable 'file' here is
> reused and now broken. Renaming it with new variable will be ok, but it

Right you are. I missed that. :)
Thanks.


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
