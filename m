Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f173.google.com (mail-lb0-f173.google.com [209.85.217.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8362D6B00BC
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:27:34 -0500 (EST)
Received: by mail-lb0-f173.google.com with SMTP id n15so1781353lbi.32
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 14:27:33 -0800 (PST)
Received: from mail-la0-x231.google.com (mail-la0-x231.google.com. [2a00:1450:4010:c03::231])
        by mx.google.com with ESMTPS id oc10si2829585lbb.99.2014.11.04.14.27.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 14:27:33 -0800 (PST)
Received: by mail-la0-f49.google.com with SMTP id ge10so1715048lab.22
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 14:27:32 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: CMA alignment question
In-Reply-To: <CADtm3G7DtGkvPk36Fiunwen8grw-94V6=iv82iusGumfNJkn-g@mail.gmail.com>
References: <CADtm3G7DtGkvPk36Fiunwen8grw-94V6=iv82iusGumfNJkn-g@mail.gmail.com>
Date: Tue, 04 Nov 2014 23:27:28 +0100
Message-ID: <xa1tlhnq7ga7.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gregory Fong <gregory.0xf0@gmail.com>, linux-mm@kvack.org
Cc: lauraa@codeaurora.org, iamjoonsoo.kim@lge.com, Marek Szyprowski <m.szyprowski@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>, Brian Norris <computersforpeace@gmail.com>

On Tue, Nov 04 2014, Gregory Fong wrote:
> The alignment in cma_alloc() is done w.r.t. the bitmap.  This is a
> problem when, for example:
>
> - a device requires 16M (order 12) alignment
> - the CMA region is not 16 M aligned
>
> In such a case, can result with the CMA region starting at, say,
> 0x2f800000 but any allocation you make from there will be aligned from
> there.  Requesting an allocation of 32 M with 16 M alignment, will
> result in an allocation from 0x2f800000 to 0x31800000, which doesn't
> work very well if your strange device requires 16M alignment.
>
> This doesn't have the behavior I would expect, which would be for the
> allocation to be aligned w.r.t. the start of memory.  I realize that
> aligning the CMA region is an option, but don't see why cma_alloc()
> aligns to the start of the CMA region.  Is there a good reason for
> having cma_alloc() alignment work this way?

No, it's a bug.  The alignment should indicate alignment of physical
address not position in CMA region.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
