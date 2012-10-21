Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id C486D6B0062
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 15:51:45 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so1439726lag.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 12:51:43 -0700 (PDT)
Date: Mon, 22 Oct 2012 01:51:34 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121022015134.4de457b9@sacrilege>
In-Reply-To: <20121022004332.7e3f3f29@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
	<20121021044540.12e8f4b7@sacrilege>
	<20121021062402.7c4c4cb8@sacrilege>
	<1350826183.13333.2243.camel@edumazet-glaptop>
	<20121021195701.7a5872e7@sacrilege>
	<20121022004332.7e3f3f29@sacrilege>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/YkuKUKk50/LcW+kp1e9gUQZ"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/YkuKUKk50/LcW+kp1e9gUQZ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 22 Oct 2012 00:43:32 +0600
Mike Kazantsev <mk.fraggod@gmail.com> wrote:

> > On Sun, 21 Oct 2012 15:29:43 +0200
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > >=20
> > > Did you try linux-3.7-rc2 (or linux-3.7-rc1) ?
> > >=20
>=20
> I just built "torvalds/linux-2.6" (v3.7-rc2) and rebooted into it,
> started same rsync-over-net test and got kmalloc-64 leaking (it went up
> to tens of MiB until I stopped rsync, normally these are fixed at ~500
> KiB).
>=20
> Unfortunately, I forgot to add slub_debug option and build kmemleak so
> wasn't able to look at this case further, and when I rebooted with
> these enabled/built, it was secpath_cache again.
>=20
> So previously noted "slabtop showed 'kmalloc-64' being the 99% offender
> in the past, but with recent kernels (3.6.1), it has changed to
> 'secpath_cache'" seem to be incorrect, as it seem to depend not on
> kernel version, but some other factor.
>=20
> Guess I'll try to reboot a few more times to see if I can catch
> kmalloc-64 leaking (instead of secpath_cache) again.
>=20

I haven't been able to catch the aforementioned condition, but noticed
that with v3.7-rc2, "hex dump" part seem to vary in kmemleak
traces, and contain all sorts of random stuff, for example:

unreferenced object 0xffff88002ae2de00 (size 56):
  comm "softirq", pid 0, jiffies 4295006317 (age 213.066s)
  hex dump (first 32 bytes):
    01 00 00 00 01 00 00 00 20 9f f4 28 00 88 ff ff  ........ ..(....
    2f 6f 72 67 2f 66 72 65 65 64 65 73 6b 74 6f 70  /org/freedesktop
  backtrace:
    [<ffffffff814da4e3>] kmemleak_alloc+0x21/0x3e
    [<ffffffff810dc1f7>] kmem_cache_alloc+0xa5/0xb1
    [<ffffffff81487bf1>] secpath_dup+0x1b/0x5a
    [<ffffffff81487df5>] xfrm_input+0x64/0x484
    [<ffffffff814bbd70>] xfrm6_rcv_spi+0x19/0x1b
    [<ffffffff814bbd92>] xfrm6_rcv+0x20/0x22
    [<ffffffff814960c3>] ip6_input_finish+0x203/0x31b
    [<ffffffff81496542>] ip6_input+0x1e/0x50
    [<ffffffff81496240>] ip6_rcv_finish+0x65/0x69
    [<ffffffff814964c3>] ipv6_rcv+0x27f/0x2e0
    [<ffffffff8140a659>] __netif_receive_skb+0x5ba/0x65a
    [<ffffffff8140a894>] netif_receive_skb+0x47/0x78
    [<ffffffff8140b4bf>] napi_skb_finish+0x21/0x54
    [<ffffffff8140b5ef>] napi_gro_receive+0xfd/0x10a
    [<ffffffff81372b47>] rtl8169_poll+0x326/0x4fc
    [<ffffffff8140ad44>] net_rx_action+0x9f/0x188

Not sure if it's relevant though.


--=20
Mike Kazantsev // fraggod.net

--Sig_/YkuKUKk50/LcW+kp1e9gUQZ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCEUkoACgkQASbOZpzyXnFuowCgquhqHAktCHeCWFtCKS4TR+bW
oxAAoMtBBa1zPDZmFhNIhpPqJoSbJ6TK
=KfUX
-----END PGP SIGNATURE-----

--Sig_/YkuKUKk50/LcW+kp1e9gUQZ--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
