Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 433326B0062
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 06:26:33 -0500 (EST)
From: "Hiremath, Vaibhav" <hvaibhav@ti.com>
Date: Mon, 21 Dec 2009 16:56:19 +0530
Subject: RE: CPU consumption is going as high as 95% on ARM Cortex A8
Message-ID: <19F8576C6E063C45BE387C64729E73940449F43F65@dbde02.ent.ti.com>
References: <19F8576C6E063C45BE387C64729E73940449F43857@dbde02.ent.ti.com>
 <20091217095641.GA399@n2100.arm.linux.org.uk>
 <19F8576C6E063C45BE387C64729E73940449F43E29@dbde02.ent.ti.com>
 <20091221090750.GA11669@n2100.arm.linux.org.uk>
 <19F8576C6E063C45BE387C64729E73940449F43EEE@dbde02.ent.ti.com>
 <20091221105017.GB11669@n2100.arm.linux.org.uk>
In-Reply-To: <20091221105017.GB11669@n2100.arm.linux.org.uk>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


> -----Original Message-----
> From: Russell King - ARM Linux [mailto:linux@arm.linux.org.uk]
> Sent: Monday, December 21, 2009 4:20 PM
> To: Hiremath, Vaibhav
> Cc: linux-arm-kernel@lists.infradead.org; linux-mm@kvack.org; linux-
> omap@vger.kernel.org
> Subject: Re: CPU consumption is going as high as 95% on ARM Cortex
> A8
>=20
> On Mon, Dec 21, 2009 at 02:51:13PM +0530, Hiremath, Vaibhav wrote:
> > > On Mon, Dec 21, 2009 at 11:56:23AM +0530, Hiremath, Vaibhav
> wrote:
<snip>...

> >
> > If I comment the line completely then I am seeing
> > CPU consumption similar to when I was setting
> PAGE_READONLY/PAGE_SHARED
> > flag, which is 25-32%.
> >
> > > I suspect that will "solve" the problem - but you'll then no
> longer
> > > have
> > > DMA coherency with userspace, so its not really a solution.
>=20
> So it _is_ down to purely the amount of time it takes to read from a
> non-cacheable buffer.  I think you need to investigate the userspace
> program and see whether it's doing anything silly - I don't think
> the
> lack of performance is a kernel problem as such.
>=20
[Hiremath, Vaibhav] The User space application program is pretty simple, do=
ing nothing as such -=20

It is a loopback application where the captured frame is copied to display =
buffer -

/*Display buffer mmap*/
display_buff_info[i].start =3D mmap(NULL, buf.length,
			PROT_READ | PROT_WRITE, MAP_SHARED, *display_fd,=20
			buf.m.offset);
/*Capture Buffer mmap*/
capture_buff_info[i].start =3D mmap(NULL, buf.length,
			PROT_READ | PROT_WRITE, MAP_SHARED, *capture_fd,
			buf.m.offset);
while (1)
	DEQUEUE BUFFER (blocking call)

	for (h =3D 0; h < display_fmt.fmt.pix.height; h++) {
		memcpy(dis_ptr, cap_ptr, display_fmt.fmt.pix.width * 2);
		cap_ptr +=3D capture_fmt.fmt.pix.width * 2;
		dis_ptr +=3D display_fmt.fmt.pix.width * 2;
	}

	QUEUE BUFFER
}

I will again review the application one more time and see whether I could g=
et anything.

> How large is this buffer?=20
[Hiremath, Vaibhav] The buffer size is 720x480x2, and we have 3 such buffer=
s used in queue/dequeue operation.

> What userspace program is reading from
> it?
[Hiremath, Vaibhav] Simple loopback application doing memcpy.

> Could the userspace program be unnecessarily re-reading from the
> multiple times for the same frame?
[Hiremath, Vaibhav] Let me re-visit the code for both application and drive=
r with respect to this suggestion, but I don't think application is reading=
 twice.

Thanks,
Vaibhav

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
