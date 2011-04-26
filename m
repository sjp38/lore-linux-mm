Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3699000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:39:48 -0400 (EDT)
Received: by wyf19 with SMTP id 19so384396wyf.14
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:39:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTikkUq7rg4umYQ5yt9ve+q34Pf+=Ag@mail.gmail.com>
References: <20110426085953.GA12389@darkstar>
	<BANLkTikkUq7rg4umYQ5yt9ve+q34Pf+=Ag@mail.gmail.com>
Date: Tue, 26 Apr 2011 17:39:47 +0800
Message-ID: <BANLkTin0wj3AhCtR5ZD=N_LUKjE1etBcFg@mail.gmail.com>
Subject: Re: [PATCH v2] virtio_balloon: disable oom killer when fill balloon
From: Dave Young <hidave.darkstar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>

On Tue, Apr 26, 2011 at 5:28 PM, Minchan Kim <minchan.kim@gmail.com> wrote:
> Please resend this with [2/2] to linux-mm.
>
> On Tue, Apr 26, 2011 at 5:59 PM, Dave Young <hidave.darkstar@gmail.com> w=
rote:
>> When memory pressure is high, virtio ballooning will probably cause oom =
killing.
>> Even if alloc_page with GFP_NORETRY itself does not directly trigger oom=
 it
>> will make memory becoming low then memory alloc of other processes will =
trigger
>> oom killing. It is not desired behaviour.
>
> I can't understand why it is undesirable.
> Why do we have to handle it specially?
>

Suppose user run some random memory hogging process while ballooning
it will be undesirable.

>
>>
>> Here disable oom killer in fill_balloon to address this issue.
>> Add code comment as KOSAKI Motohiro's suggestion.
>>
>> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
>> ---
>> =C2=A0drivers/virtio/virtio_balloon.c | =C2=A0 =C2=A08 ++++++++
>> =C2=A01 file changed, 8 insertions(+)
>>
>> --- linux-2.6.orig/drivers/virtio/virtio_balloon.c =C2=A0 =C2=A0 =C2=A02=
011-04-26 11:39:14.053118406 +0800
>> +++ linux-2.6/drivers/virtio/virtio_balloon.c =C2=A0 2011-04-26 16:54:56=
.419741542 +0800
>> @@ -25,6 +25,7 @@
>> =C2=A0#include <linux/freezer.h>
>> =C2=A0#include <linux/delay.h>
>> =C2=A0#include <linux/slab.h>
>> +#include <linux/oom.h>
>>
>> =C2=A0struct virtio_balloon
>> =C2=A0{
>> @@ -102,6 +103,12 @@ static void fill_balloon(struct virtio_b
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We can only do one array worth at a time. =
*/
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0num =3D min(num, ARRAY_SIZE(vb->pfns));
>>
>> + =C2=A0 =C2=A0 =C2=A0 /* Disable oom killer for indirect oom due to our=
 memory consuming
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Currently only hibernation code use oom_k=
iller_disable,
>
> Hmm, Please look at current mmotm. Now oom_killer_disabled is used by
> do_try_to_free_pages in mmotm so it could make unnecessary oom kill.
>
> BTW, I can't understand why we need to handle virtio by special.
> Could you explain it in detail? :)
>
>
>
> --
> Kind regards,
> Minchan Kim
>



--=20
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
