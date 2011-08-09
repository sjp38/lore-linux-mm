Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 08C976B016D
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 05:38:23 -0400 (EDT)
Received: by vwm42 with SMTP id 42so4319378vwm.14
        for <linux-mm@kvack.org>; Tue, 09 Aug 2011 02:38:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1312860783.2531.31.camel@edumazet-laptop>
References: <1312709438-7608-1-git-send-email-akinobu.mita@gmail.com>
	<1312859440.2531.20.camel@edumazet-laptop>
	<1312860783.2531.31.camel@edumazet-laptop>
Date: Tue, 9 Aug 2011 18:38:21 +0900
Message-ID: <CAC5umyhLuhNK55WDXTii2SFsqPNau1B9F1z+E0r0CaLNkGZfDg@mail.gmail.com>
Subject: Re: [PATCH] slub: fix check_bytes() for slub debugging
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org

2011/8/9 Eric Dumazet <eric.dumazet@gmail.com>:

>> > diff --git a/mm/slub.c b/mm/slub.c
>> > index eb5a8f9..5695f92 100644
>> > --- a/mm/slub.c
>> > +++ b/mm/slub.c
>> > @@ -701,7 +701,7 @@ static u8 *check_bytes(u8 *start, u8 value, unsign=
ed int bytes)
>> > =A0 =A0 =A0 =A0 =A0 =A0 return check_bytes8(start, value, bytes);
>> >
>> > =A0 =A0 value64 =3D value | value << 8 | value << 16 | value << 24;
>> > - =A0 value64 =3D value64 | value64 << 32;
>> > + =A0 value64 =3D (value64 & 0xffffffff) | value64 << 32;
>> > =A0 =A0 prefix =3D 8 - ((unsigned long)start) % 8;
>> >
>> > =A0 =A0 if (prefix) {
>>
>> Still buggy I am afraid. Could we use the following ?
>>
>>
>> =A0 =A0 =A0 value64 =3D value;
>> =A0 =A0 =A0 value64 |=3D value64 << 8;
>> =A0 =A0 =A0 value64 |=3D value64 << 16;
>> =A0 =A0 =A0 value64 |=3D value64 << 32;
>>
>>
>
> Well, 'buggy' was not well chosen.
>
> Another possibility would be to use a multiply if arch has a fast
> multiplier...
>
>
> =A0 =A0 =A0 =A0value64 =3D value;
> #if defined(ARCH_HAS_FAST_MULTIPLIER) && BITS_PER_LONG =3D=3D 64
> =A0 =A0 =A0 =A0value64 *=3D 0x0101010101010101;
> #elif defined(ARCH_HAS_FAST_MULTIPLIER)
> =A0 =A0 =A0 =A0value64 *=3D 0x01010101;
> =A0 =A0 =A0 =A0value64 |=3D value64 << 32;
> #else
> =A0 =A0 =A0 =A0value64 |=3D value64 << 8;
> =A0 =A0 =A0 =A0value64 |=3D value64 << 16;
> =A0 =A0 =A0 =A0value64 |=3D value64 << 32;
> #endif

I don't really care about which one should be used.  So tell me if I need
to resend it with this improvement.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
