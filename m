Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 817D96B0031
	for <linux-mm@kvack.org>; Wed, 12 Jun 2013 16:42:19 -0400 (EDT)
Received: by mail-ie0-f172.google.com with SMTP id 16so2561414iea.31
        for <linux-mm@kvack.org>; Wed, 12 Jun 2013 13:42:18 -0700 (PDT)
Date: Wed, 12 Jun 2013 15:42:15 -0500
From: Rob Landley <rob@landley.net>
Subject: Re: Slow swap-in with SSD
In-Reply-To: <201306111634.36327.ms@teamix.de> (from ms@teamix.de on Tue Jun
	11 09:34:36 2013)
Message-Id: <1371069735.2776.100@driftwood>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; DelSp=Yes; Format=Flowed
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Steigerwald <ms@teamix.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/11/2013 09:34:36 AM, Martin Steigerwald wrote:
> Hi!
>=20
> Using Linux 3.10-rc5 on an ThinkPad T520 with Intel Sandybridge =20
> i5-2620M,
> 8 GiB RAM and Intel SSD 320. Currently I have Zcache enabled to test =20
> the
> effects of it but I observed similar figures on kernels without =20
> Zcache.
>=20
> If I let the kernel swap out for example with
>=20
> stress -m 1 --vm-keep --vm-bytes 5G
>=20
> or so, then swapping out is pretty fast, I have seen values around
> 100-200 MiB/s
>=20
> But on issuing a swapoff command to swap stuff in again, the swap in =20
> is
> abysmally slow, just a few MiB/s (see below).
>=20
> I wonder why is that so? The SSD is basically idling around on =20
> swap-in.

Transaction granularity. Swapping out can queue up large batches of =20
pages because you can queue up more outgoing pages while the others are =20
still writing. Swapping _in_ you don't know what you need next until =20
you resume the process, so you fault in 4k, schedule DMA, resume the =20
process when it completes, fault on the next page, schedule more DMA, =20
rinse repeat. Programs don't really execute linearly, so you wind up =20
with round trip latency to and from device each time.

The problem with doing readahead on swapin is that programs jump around =20
randomly calling a function here and a function there, so you dunno =20
which other pages it'll need until it requests them. (Speculatively =20
faulting in pages when the system is starved of memory usually just =20
makes the memory shortage worse. This code only runs when there's a =20
shortage of physical pages.)

Having an ssd just exacerbates the problem, because with the device =20
itself sped up the round trip latency from all the tiny transactions =20
comes to dominate.

Rob=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
