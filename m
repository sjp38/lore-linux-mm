Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 765AF6B00CE
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 22:52:49 -0400 (EDT)
Received: by iwn1 with SMTP id 1so2058332iwn.14
        for <linux-mm@kvack.org>; Mon, 18 Oct 2010 19:52:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101019023537.GB8310@localhost>
References: <20101019093142.509d6947@notabene>
	<20101018154137.90f5325f.akpm@linux-foundation.org>
	<20101019095144.A1B0.A69D9226@jp.fujitsu.com>
	<AANLkTin38qJ-U3B7XwMh-3aR9zRs21LgR1yHfqYifxrn@mail.gmail.com>
	<20101019023537.GB8310@localhost>
Date: Tue, 19 Oct 2010 11:52:47 +0900
Message-ID: <AANLkTikHxDyjOGgM8-X6FNT15Hr3s4NaA-=+FRhma+3D@mail.gmail.com>
Subject: Re: Deadlock possibly caused by too_many_isolated.
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Neil Brown <neilb@suse.de>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Li, Shaohua" <shaohua.li@intel.com>
List-ID: <linux-mm.kvack.org>

Hi Wu,

On Tue, Oct 19, 2010 at 11:35 AM, Wu Fengguang <fengguang.wu@intel.com> wro=
te:
>> @@ -2054,10 +2069,11 @@ rebalance:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto got_pg;
>>
>> =A0 =A0 =A0 =A0 /*
>> - =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming, then we=
 are
>> - =A0 =A0 =A0 =A0* running out of options and have to consider going OOM
>> + =A0 =A0 =A0 =A0* If we failed to make any progress reclaiming and ther=
e aren't
>> + =A0 =A0 =A0 =A0* many parallel reclaiming, then we are unning out of o=
ptions and
>> + =A0 =A0 =A0 =A0* have to consider going OOM
>> =A0 =A0 =A0 =A0 =A0*/
>> - =A0 =A0 =A0 if (!did_some_progress) {
>> + =A0 =A0 =A0 if (!did_some_progress && !too_many_isolated_zone(preferre=
d_zone)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((gfp_mask & __GFP_FS) && !(gfp_mask =
& __GFP_NORETRY)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (oom_killer_disabled)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto nop=
age;
>
> This is simply wrong.
>
> It disabled this block for 99% system because there won't be enough
> tasks to make (!too_many_isolated_zone =3D=3D true). As a result the LRU
> will be scanned like mad and no task get OOMed when it should be.

If !too_many_isolated_zone is false, it means there are already many
direct reclaiming tasks.
So they could exit reclaim path and !too_many_isolated_zone will be true.
What am I missing now?


> Thanks,
> Fengguang
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
