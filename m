Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 45F229000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 01:08:20 -0400 (EDT)
Received: by vws4 with SMTP id 4so1487073vws.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 22:08:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110427105031.db203b95.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110426181724.f8cdad57.kamezawa.hiroyu@jp.fujitsu.com>
	<20110426135934.c1992c3e.akpm@linux-foundation.org>
	<20110427105031.db203b95.kamezawa.hiroyu@jp.fujitsu.com>
Date: Wed, 27 Apr 2011 14:08:18 +0900
Message-ID: <BANLkTi=zDFrgqn-Mpo2R1M0F_+aMo-byZg@mail.gmail.com>
Subject: Re: [PATCH v2] fix get_scan_count for working well with small targets
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, Ying Han <yinghan@google.com>

Hi Kame,

On Wed, Apr 27, 2011 at 10:50 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 26 Apr 2011 13:59:34 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
>
>> What about simply removing the nr_saved_scan logic and permitting small
>> scans? =C2=A0That simplifies the code and I bet it makes no measurable
>> performance difference.
>>
>
> ok, v2 here. How this looks ?
> For memcg, I think I should add select_victim_node() for direct reclaim,
> then, we'll be tune big memcg using small memory on a zone case.
>
> =3D=3D
> At memory reclaim, we determine the number of pages to be scanned
> per zone as
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(anon + file) >> priority.
> Assume
> =C2=A0 =C2=A0 =C2=A0 =C2=A0scan =3D (anon + file) >> priority.
>
> If scan < SWAP_CLUSTER_MAX, the scan will be skipped for this time
> and priority gets higher. This has some problems.
>
> =C2=A01. This increases priority as 1 without any scan.
> =C2=A0 =C2=A0 To do scan in this priority, amount of pages should be larg=
er than 512M.
> =C2=A0 =C2=A0 If pages>>priority < SWAP_CLUSTER_MAX, it's recorded and sc=
an will be
> =C2=A0 =C2=A0 batched, later. (But we lose 1 priority.)

Nice catch!  It looks to be much enhance.

> =C2=A0 =C2=A0 But if the amount of pages is smaller than 16M, no scan at =
priority=3D=3D0
> =C2=A0 =C2=A0 forever.

Before reviewing the code, I have a question about this.
Now, in case of (priority =3D 0), we don't do shift operation with priority=
.
So nr_saved_scan would be the number of lru list pages. ie, 16M.
Why no-scan happens in case of (priority =3D=3D 0 and 16M lru pages)?
What am I missing now?

>
> =C2=A02. If zone->all_unreclaimabe=3D=3Dtrue, it's scanned only when prio=
rity=3D=3D0.
> =C2=A0 =C2=A0 So, x86's ZONE_DMA will never be recoverred until the user =
of pages
> =C2=A0 =C2=A0 frees memory by itself.
>
> =C2=A03. With memcg, the limit of memory can be small. When using small m=
emcg,
> =C2=A0 =C2=A0 it gets priority < DEF_PRIORITY-2 very easily and need to c=
all
> =C2=A0 =C2=A0 wait_iff_congested().
> =C2=A0 =C2=A0 For doing scan before priorty=3D9, 64MB of memory should be=
 used.

It makes sense.



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
