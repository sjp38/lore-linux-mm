Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 48AAE6B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 21:35:41 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id r10so19041357pdi.27
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 18:35:41 -0800 (PST)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id xp4si27128382pbb.36.2014.12.04.18.35.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 04 Dec 2014 18:35:39 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 5 Dec 2014 10:35:29 +0800
Subject: RE: [RFC v2] arm:extend the reserved mrmory for initrd to be page
 aligned
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313EA@CNBJMBX05.corpusers.net>
References: <35FD53F367049845BC99AC72306C23D103D6DB491609@CNBJMBX05.corpusers.net>
 <20140915113325.GD12361@n2100.arm.linux.org.uk>
 <20141204120305.GC17783@e104818-lin.cambridge.arm.com>
In-Reply-To: <20141204120305.GC17783@e104818-lin.cambridge.arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Catalin Marinas' <catalin.marinas@arm.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "'linux-mm@kvack.org'" <linux-mm@kvack.org>, Will Deacon <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'linux-arm-msm@vger.kernel.org'" <linux-arm-msm@vger.kernel.org>, Peter Maydell <Peter.Maydell@arm.com>

> -----Original Message-----
> From: Catalin Marinas [mailto:catalin.marinas@arm.com]
> Sent: Thursday, December 04, 2014 8:03 PM
> To: Russell King - ARM Linux
> Cc: Wang, Yalin; 'linux-mm@kvack.org'; Will Deacon; 'linux-
> kernel@vger.kernel.org'; 'linux-arm-kernel@lists.infradead.org'; 'linux-
> arm-msm@vger.kernel.org'; Peter Maydell
> Subject: Re: [RFC v2] arm:extend the reserved mrmory for initrd to be pag=
e
> aligned
>=20
> On Mon, Sep 15, 2014 at 12:33:25PM +0100, Russell King - ARM Linux wrote:
> > On Mon, Sep 15, 2014 at 07:07:20PM +0800, Wang, Yalin wrote:
> > > @@ -636,6 +646,11 @@ static int keep_initrd;  void
> > > free_initrd_mem(unsigned long start, unsigned long end)  {
> > >  	if (!keep_initrd) {
> > > +		if (start =3D=3D initrd_start)
> > > +			start =3D round_down(start, PAGE_SIZE);
> > > +		if (end =3D=3D initrd_end)
> > > +			end =3D round_up(end, PAGE_SIZE);
> > > +
> > >  		poison_init_mem((void *)start, PAGE_ALIGN(end) - start);
> > >  		free_reserved_area((void *)start, (void *)end, -1, "initrd");
> > >  	}
> >
> > is the only bit of code you likely need to achieve your goal.
> >
> > Thinking about this, I think that you are quite right to align these.
> > The memory around the initrd is defined to be system memory, and we
> > already free the pages around it, so it *is* wrong not to free the
> > partial initrd pages.
>=20
> Actually, I think we have a problem, at least on arm64 (raised by Peter
> Maydell). There is no guarantee that the page around start/end of initrd =
is
> free, it may contain the dtb for example. This is even more obvious when =
we
> have a 64KB page kernel (the boot loader doesn't know the page size that
> the kernel is going to use).
>=20
> The bug was there before as we had poison_init_mem() already (not it
> disappeared since free_reserved_area does the poisoning).
>=20
> So as a quick fix I think we need the rounding the other way (and in the
> general case we probably lose a page at the end of initrd):
>=20
> diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c index
> 494297c698ca..39fd080683e7 100644
> --- a/arch/arm64/mm/init.c
> +++ b/arch/arm64/mm/init.c
> @@ -335,9 +335,9 @@ void free_initrd_mem(unsigned long start, unsigned lo=
ng
> end)  {
>  	if (!keep_initrd) {
>  		if (start =3D=3D initrd_start)
> -			start =3D round_down(start, PAGE_SIZE);
> +			start =3D round_up(start, PAGE_SIZE);
>  		if (end =3D=3D initrd_end)
> -			end =3D round_up(end, PAGE_SIZE);
> +			end =3D round_down(end, PAGE_SIZE);
>=20
>  		free_reserved_area((void *)start, (void *)end, 0, "initrd");
>  	}
>=20
> A better fix would be to check what else is around the start/end of initr=
d.
I think a better way is add some head info in Image header,
So that bootloader  can know the kernel CONFIG_PAGE_SIZE ,
For example we can add PAGE_SIZE in zImage header .
How about this way?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
