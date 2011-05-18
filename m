Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DAB776B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 01:44:49 -0400 (EDT)
Received: by qwa26 with SMTP id 26so880754qwa.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 22:44:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4DD31B6E.8040502@jp.fujitsu.com>
References: <1305295404-12129-1-git-send-email-mgorman@suse.de>
	<1305295404-12129-5-git-send-email-mgorman@suse.de>
	<4DCFAA80.7040109@jp.fujitsu.com>
	<1305519711.4806.7.camel@mulgrave.site>
	<BANLkTi=oe4Ties6awwhHFPf42EXCn2U4MQ@mail.gmail.com>
	<20110516084558.GE5279@suse.de>
	<BANLkTinW4s6aT2bZ79sHNgdh5j8VYyJz2w@mail.gmail.com>
	<20110516102753.GF5279@suse.de>
	<BANLkTi=5ON_ttuwFFhFObfoP8EBKPdFgAA@mail.gmail.com>
	<4DD31B6E.8040502@jp.fujitsu.com>
Date: Wed, 18 May 2011 14:44:48 +0900
Message-ID: <BANLkTikLuWPEt7MitUYdJtzqyBSOkz2zxg@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: vmscan: If kswapd has been running too long,
 allow it to sleep
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: mgorman@suse.de, James.Bottomley@hansenpartnership.com, akpm@linux-foundation.org, colin.king@canonical.com, raghu.prabhu13@gmail.com, jack@suse.cz, chris.mason@oracle.com, cl@linux.com, penberg@kernel.org, riel@redhat.com, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ext4@vger.kernel.org

On Wed, May 18, 2011 at 10:05 AM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> It would be better to put cond_resched after balance_pgdat?
>>
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 292582c..61c45d0 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -2753,6 +2753,7 @@ static int kswapd(void *p)
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!ret) {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 trace_mm_vmscan_kswapd_wake(pgdat->node_id,
>> order);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 order =3D balance_pgdat(pgdat,
>> order,&classzone_idx);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 cond_resched();
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 0;
>>
>>>>> While it appears unlikely, there are bad conditions which can result
>>>
>>> in cond_resched() being avoided.
>
> Every reclaim priority decreasing or every shrink_zone() calling makes mo=
re
> fine grained preemption. I think.

It could be.
But in direct reclaim case, I have a concern about losing pages
reclaimed to other tasks by preemption.

Hmm,, anyway, we also needs test.
Hmm,, how long should we bother them(Colins and James)?
First of all, Let's fix one just between us and ask test to them and
send the last patch to akpm.

1. shrink_slab
2. right after balance_pgdat
3. shrink_zone
4. reclaim priority decreasing routine.

Now, I vote 1) and 2).

Mel, KOSAKI?
--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
