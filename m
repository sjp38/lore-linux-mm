Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 83A289000C1
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 05:34:24 -0400 (EDT)
Received: by wwi36 with SMTP id 36so360661wwi.26
        for <linux-mm@kvack.org>; Tue, 26 Apr 2011 02:34:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110426085953.GA12389@darkstar>
References: <20110426085953.GA12389@darkstar>
Date: Tue, 26 Apr 2011 18:28:01 +0900
Message-ID: <BANLkTikkUq7rg4umYQ5yt9ve+q34Pf+=Ag@mail.gmail.com>
Subject: Re: [PATCH v2] virtio_balloon: disable oom killer when fill balloon
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Young <hidave.darkstar@gmail.com>
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>

Please resend this with [2/2] to linux-mm.

On Tue, Apr 26, 2011 at 5:59 PM, Dave Young <hidave.darkstar@gmail.com> wro=
te:
> When memory pressure is high, virtio ballooning will probably cause oom k=
illing.
> Even if alloc_page with GFP_NORETRY itself does not directly trigger oom =
it
> will make memory becoming low then memory alloc of other processes will t=
rigger
> oom killing. It is not desired behaviour.

I can't understand why it is undesirable.
Why do we have to handle it specially?


>
> Here disable oom killer in fill_balloon to address this issue.
> Add code comment as KOSAKI Motohiro's suggestion.
>
> Signed-off-by: Dave Young <hidave.darkstar@gmail.com>
> ---
> =C2=A0drivers/virtio/virtio_balloon.c | =C2=A0 =C2=A08 ++++++++
> =C2=A01 file changed, 8 insertions(+)
>
> --- linux-2.6.orig/drivers/virtio/virtio_balloon.c =C2=A0 =C2=A0 =C2=A020=
11-04-26 11:39:14.053118406 +0800
> +++ linux-2.6/drivers/virtio/virtio_balloon.c =C2=A0 2011-04-26 16:54:56.=
419741542 +0800
> @@ -25,6 +25,7 @@
> =C2=A0#include <linux/freezer.h>
> =C2=A0#include <linux/delay.h>
> =C2=A0#include <linux/slab.h>
> +#include <linux/oom.h>
>
> =C2=A0struct virtio_balloon
> =C2=A0{
> @@ -102,6 +103,12 @@ static void fill_balloon(struct virtio_b
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* We can only do one array worth at a time. *=
/
> =C2=A0 =C2=A0 =C2=A0 =C2=A0num =3D min(num, ARRAY_SIZE(vb->pfns));
>
> + =C2=A0 =C2=A0 =C2=A0 /* Disable oom killer for indirect oom due to our =
memory consuming
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* Currently only hibernation code use oom_ki=
ller_disable,

Hmm, Please look at current mmotm. Now oom_killer_disabled is used by
do_try_to_free_pages in mmotm so it could make unnecessary oom kill.

BTW, I can't understand why we need to handle virtio by special.
Could you explain it in detail? :)



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
