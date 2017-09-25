Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 93E7F6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:02:05 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b195so9059220wmb.6
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 09:02:05 -0700 (PDT)
Received: from smtp-out4.electric.net (smtp-out4.electric.net. [192.162.216.194])
        by mx.google.com with ESMTPS id c28si4610937eda.147.2017.09.25.09.01.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 09:01:59 -0700 (PDT)
From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] mm: fix RODATA_TEST failure "rodata_test: test data was
 not read only"
Date: Mon, 25 Sep 2017 16:01:55 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD007F58B@AcuExch.aculab.com>
References: <20170921093729.1080368AC1@po15668-vm-win7.idsi0.si.c-s.fr>
 <CAGXu5jJ54+bCcXaPK1ExsxtTDPHNn1+1gywb3TDbe-SEtt1zuQ@mail.gmail.com>
 <20170925073721.GM8421@gate.crashing.org>
In-Reply-To: <20170925073721.GM8421@gate.crashing.org>
Content-Language: en-US
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Segher Boessenkool' <segher@kernel.crashing.org>, Kees Cook <keescook@chromium.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jinbum Park <jinb.park7@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>

From: Segher Boessenkool
> Sent: 25 September 2017 08:37
> On Sun, Sep 24, 2017 at 12:17:51PM -0700, Kees Cook wrote:
> > On Thu, Sep 21, 2017 at 2:37 AM, Christophe Leroy
> > <christophe.leroy@c-s.fr> wrote:
> > > On powerpc, RODATA_TEST fails with message the following messages:
> > >
> > > [    6.199505] Freeing unused kernel memory: 528K
> > > [    6.203935] rodata_test: test data was not read only
> > >
> > > This is because GCC allocates it to .data section:
> > >
> > > c0695034 g     O .data  00000004 rodata_test_data
> >
> > Uuuh... that seems like a compiler bug. It's marked "const" -- it
> > should never end up in .data. I would argue that this has done exactly
> > what it was supposed to do, and shows that something has gone wrong.
> > It should always be const. Adding "static" should just change
> > visibility. (I'm not opposed to the static change, but it seems to
> > paper over a problem with the compiler...)
>=20
> The compiler puts this item in .sdata, for 32-bit.  There is no .srodata,
> so if it wants to use a small data section, it must use .sdata .
>=20
> Non-external, non-referenced symbols are not put in .sdata, that is the
> difference you see with the "static".
>=20
> I don't think there is a bug here.  If you think there is, please open
> a GCC bug.

The .sxxx sections are for 'small' data that can be accessed (typically)
using small offsets from a global register.
This means that all sections must be adjacent in the image.
So you can't really have readonly small data.

My guess is that the linker script is putting .srodata in with .sdata.

	David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
