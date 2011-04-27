Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 570FF6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 13:56:16 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3RHuCF0012157
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:56:13 -0700
Received: from qwi2 (qwi2.prod.google.com [10.241.195.2])
	by wpaz37.hot.corp.google.com with ESMTP id p3RHo2EY026761
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:56:11 -0700
Received: by qwi2 with SMTP id 2so1373154qwi.8
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 10:56:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTim-U3MTnToFPL11NcVnOCig4zJMAQ@mail.gmail.com>
References: <20110427164708.1143395e.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTin+rDOWGYq9dg-XcCWs+yT8Yw-VMw@mail.gmail.com>
	<20110427174813.8b34df90.kamezawa.hiroyu@jp.fujitsu.com>
	<BANLkTim-U3MTnToFPL11NcVnOCig4zJMAQ@mail.gmail.com>
Date: Wed, 27 Apr 2011 10:56:11 -0700
Message-ID: <BANLkTi=zoFK2HVC64qqeHVO_kq4KOBLOrA@mail.gmail.com>
Subject: Re: [PATCHv3] memcg: fix get_scan_count for small targets
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "mgorman@suse.de" <mgorman@suse.de>

Acked-by: Ying Han <yinghan@google.com>

--Ying
On Wed, Apr 27, 2011 at 2:14 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> On Wed, Apr 27, 2011 at 5:48 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>> On Wed, 27 Apr 2011 17:48:18 +0900
>> Minchan Kim <minchan.kim@gmail.com> wrote:
>>
>>> On Wed, Apr 27, 2011 at 4:47 PM, KAMEZAWA Hiroyuki
>>> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>>> > At memory reclaim, we determine the number of pages to be scanned
>>> > per zone as
>>> > =A0 =A0 =A0 =A0(anon + file) >> priority.
>>> > Assume
>>> > =A0 =A0 =A0 =A0scan =3D (anon + file) >> priority.
>>> >
>>> > If scan < SWAP_CLUSTER_MAX, the scan will be skipped for this time
>>> > and priority gets higher. This has some problems.
>>> >
>>> > =A01. This increases priority as 1 without any scan.
>>> > =A0 =A0 To do scan in this priority, amount of pages should be larger=
 than 512M.
>>> > =A0 =A0 If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and scan=
 will be
>>> > =A0 =A0 batched, later. (But we lose 1 priority.)
>>> > =A0 =A0 If memory size is below 16M, pages >> priority is 0 and no sc=
an in
>>> > =A0 =A0 DEF_PRIORITY forever.
>>> >
>>> > =A02. If zone->all_unreclaimabe=3D=3Dtrue, it's scanned only when pri=
ority=3D=3D0.
>>> > =A0 =A0 So, x86's ZONE_DMA will never be recoverred until the user of=
 pages
>>> > =A0 =A0 frees memory by itself.
>>> >
>>> > =A03. With memcg, the limit of memory can be small. When using small =
memcg,
>>> > =A0 =A0 it gets priority < DEF_PRIORITY-2 very easily and need to cal=
l
>>> > =A0 =A0 wait_iff_congested().
>>> > =A0 =A0 For doing scan before priorty=3D9, 64MB of memory should be u=
sed.
>>> >
>>> > Then, this patch tries to scan SWAP_CLUSTER_MAX of pages in force...w=
hen
>>> >
>>> > =A01. the target is enough small.
>>> > =A02. it's kswapd or memcg reclaim.
>>> >
>>> > Then we can avoid rapid priority drop and may be able to recover
>>> > all_unreclaimable in a small zones. And this patch removes nr_saved_s=
can.
>>> > This will allow scanning in this priority even when pages >> priority
>>> > is very small.
>>> >
>>> > Changelog v2->v3
>>> > =A0- removed nr_saved_scan completely.
>>> >
>>> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>>> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>>>
>>> The patch looks good to me but I have a nitpick about just coding style=
.
>>> How about this? I think below looks better but it's just my private
>>> opinion and I can't insist on my style. If you don't mind it, ignore.
>>>
>>
>> I did this at the 1st try and got bug.....a variable 'file' here is
>> reused and now broken. Renaming it with new variable will be ok, but it
>
> Right you are. I missed that. :)
> Thanks.
>
>
> --
> Kind regards,
> Minchan Kim
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
