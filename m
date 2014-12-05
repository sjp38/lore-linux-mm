Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D356F6B0032
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 00:55:48 -0500 (EST)
Received: by mail-pd0-f178.google.com with SMTP id g10so26468pdj.23
        for <linux-mm@kvack.org>; Thu, 04 Dec 2014 21:55:48 -0800 (PST)
Received: from ponies.io (mail.ponies.io. [173.255.217.209])
        by mx.google.com with ESMTP id jc4si46176345pbd.35.2014.12.04.21.55.46
        for <linux-mm@kvack.org>;
        Thu, 04 Dec 2014 21:55:47 -0800 (PST)
Received: from cucumber.localdomain (nat-gw2.syd4.anchor.net.au [110.173.144.2])
	by ponies.io (Postfix) with ESMTPSA id 6FC3FA0F5
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 05:55:46 +0000 (UTC)
Date: Fri, 5 Dec 2014 16:55:44 +1100
From: Christian Marie <christian@ponies.io>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141205055544.GB18326@cucumber.syd4.anchor.net.au>
References: <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203075747.GB6276@js1304-P5Q-DELUXE>
 <20141204073045.GA2960@cucumber.anchor.net.au>
 <20141205010733.GA13751@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="OwLcNYc0lM97+oe1"
Content-Disposition: inline
In-Reply-To: <20141205010733.GA13751@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--OwLcNYc0lM97+oe1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Dec 05, 2014 at 10:07:33AM +0900, Joonsoo Kim wrote:
> It looks that there is no stop condition in isolate_freepages(). In
> this period, your system have not enough freepage and many processes
> try to find freepage for compaction. Because there is no stop
> condition, they iterate almost all memory range every time. At the
> bottom of this mail, I attach one more fix although I don't test it
> yet. It will cause a lot of allocation failure that your network layer
> need. It is order 5 allocation request and with __GFP_NOWARN gfp flag,
> so I assume that there is no problem if allocation request is failed,
> but, I'm not sure.
>=20
> watermark check on this patch needs cc->classzone_idx, cc->alloc_flags
> that comes from Vlastimil's recent change. If you want to test it with
> 3.18rc5, please remove it. It doesn't much matter.
>=20
> Anyway, I hope it also helps you.

Thank you, I will try this next week. If it improves the situation do you t=
hink
that we have a good chance of merging it upstream? I should think that
backporting such a fix would be a hard sell.

> By judging from this perf report, my second patch would have no impact
> to your system. I thought that this excessive cpu usage is started from
> the SLUB, but, order 5 kmalloc request is just forwarded to page
> allocator in current SLUB implementation, so patch 2 from me would not
> work on this problem.

I agree with this.

>=20
> By the way, is it common that network layer needs order 5 allocation?
> IMHO, it'd be better to avoid this highorder request, because the kernel
> easily fail to handle this kind of request.

Yes, agreed. I'm trying to sort that issue out concurrently. I'm currently
collaborating on a patch to get Scatter Gather support for the network laye=
r so
that we can avoid these huge allocations. They are large because ipoib in
Connected Mode wants a very large MTU (around 65535) and does not do SG in =
CM.

--OwLcNYc0lM97+oe1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJUgUjgAAoJEMHZnoZn5OShYY0P/2F38/JNKeexOo6JAHIA7/Ee
aBOzXOwXF10H6Hs5Ca/CABoM5t8fae8nvoQtb45oFO1OK6OA03upZTK8HgGRDqsZ
1oMN4SqlYoElULY21/DAkmBTa4Zz3r2/E6beQ+VuUdkkCnSw3n3cgW2Sm+VhNZ6g
l+9EB+Cbtl23znISpE92lAaYX2Ywrv6dneezDzKx/WPxQTMmYQtVQbtwPyXBm2wq
8NqB+anlMBpAYO509d6D0DpM+xrO5/sHnbMYQh8h0Q6+0ErwLP0NRk/9Szjxta5f
YBwMVVG87wAZeWM3Igaw+/ypycaYEQfMZPQGY+Y2VtYW4oqM2Azy+JPpv6eIBSuX
9BeZa6CSbFL2bHIj+ARkP2BXAu11blLG2Pqk+wUxh0eIqj6xIJqlgbIzU9i8CuZw
QPE/BH7ahvgUMkF5/bbSqT/AMFi8Mc2tR+SZ34dnKw2rjbQOpliEYMf8IrqJOkZC
XuKsfCGoDIHV83idYVIhAVBOnrEoH6LJBHQB6eL+mXJxs6MMdC3iyVrrptErGBlE
mFqModO/rEs5jTA1DwJfhfIoSHLVNz2hguTLiEY9L2LuIdzWFndNu4/hqLEid3wW
wkxKnIk1iYT9aY/I0m9AmQ1gs5QohRzcMznfY0blftFD5XcjUEIoX0m7bYF4APVO
98lZIu2AqNz1pv5183io
=Qom8
-----END PGP SIGNATURE-----

--OwLcNYc0lM97+oe1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
