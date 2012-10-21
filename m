Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 965436B0062
	for <linux-mm@kvack.org>; Sun, 21 Oct 2012 18:58:57 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id k6so1536308lbo.14
        for <linux-mm@kvack.org>; Sun, 21 Oct 2012 15:58:55 -0700 (PDT)
Date: Mon, 22 Oct 2012 04:58:50 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121022045850.788df346@sacrilege>
In-Reply-To: <1350856053.8609.217.camel@edumazet-glaptop>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
	<20121021044540.12e8f4b7@sacrilege>
	<20121021062402.7c4c4cb8@sacrilege>
	<1350826183.13333.2243.camel@edumazet-glaptop>
	<20121021195701.7a5872e7@sacrilege>
	<20121022004332.7e3f3f29@sacrilege>
	<20121022015134.4de457b9@sacrilege>
	<1350856053.8609.217.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/KJEwoBm/Z5od+QgN2ZibF=E"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Paul Moore <paul@paul-moore.com>, netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/KJEwoBm/Z5od+QgN2ZibF=E
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 21 Oct 2012 23:47:33 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

>=20
> OK, so  some layer seems to have a bug if the skb->head is exactly
> allocated, instead of having extra tailroom (because of kmalloc-powerof2
> alignment)
>=20
> Or some layer overwrites past skb->cb[] array
>=20
> If you try to move sp field in sk_buff, does it change something ?
>=20
...
>=20
> Also try to increase tailroom in __netdev_alloc_skb()
>=20

Applied both patches, but unfortunately, the problem seem to be still
there.

This time the leaking objects seem to show up as kmalloc-64.

  OBJS ACTIVE  USE OBJ SIZE  SLABS OBJ/SLAB CACHE SIZE NAME                =
  =20
266760 265333  99%    0.30K  10260       26     82080K kmemleak_object
157440 157440 100%    0.06K   2460       64      9840K kmalloc-64
 94458  94458 100%    0.10K   2422       39      9688K buffer_head
 27573  27573 100%    0.19K   1313       21      5252K dentry


kmemleak traces:

unreferenced object 0xffff88002f38ec80 (size 64):
  comm "softirq", pid 0, jiffies 4294900815 (age 142.346s)
  hex dump (first 32 bytes):
    01 00 00 00 01 00 00 00 00 08 03 2e 00 88 ff ff  ................
    2b 6f a0 ca 28 b2 4a f1 0a 74 33 74 5a 76 18 cb  +o..(.J..t3tZv..
  backtrace:
    [<ffffffff814da4e3>] kmemleak_alloc+0x21/0x3e
    [<ffffffff810dc1f7>] kmem_cache_alloc+0xa5/0xb1
    [<ffffffff81487bf5>] secpath_dup+0x1b/0x5a
    [<ffffffff81487df9>] xfrm_input+0x64/0x484
    [<ffffffff8147eec3>] xfrm4_rcv_encap+0x17/0x19
    [<ffffffff8147eee4>] xfrm4_rcv+0x1f/0x21
    [<ffffffff8143b4e4>] ip_local_deliver_finish+0x170/0x22a
    [<ffffffff8143b6d6>] ip_local_deliver+0x46/0x78
    [<ffffffff8143b35d>] ip_rcv_finish+0x295/0x2ac
    [<ffffffff8143b936>] ip_rcv+0x22e/0x288
    [<ffffffff8140a65d>] __netif_receive_skb+0x5ba/0x65a
    [<ffffffff8140a898>] netif_receive_skb+0x47/0x78
    [<ffffffff8140b4c3>] napi_skb_finish+0x21/0x54
    [<ffffffff8140b5f3>] napi_gro_receive+0xfd/0x10a
    [<ffffffff81372b47>] rtl8169_poll+0x326/0x4fc
    [<ffffffff8140ad48>] net_rx_action+0x9f/0x188

unreferenced object 0xffff880029b47580 (size 64):
  comm "softirq", pid 0, jiffies 4294926900 (age 143.946s)
  hex dump (first 32 bytes):
    01 00 00 00 01 00 00 00 00 88 07 2e 00 88 ff ff  ................
    00 00 00 00 2f 6f 72 67 2f 66 72 65 65 64 65 73  ..../org/freedes
  backtrace:
    [<ffffffff814da4e3>] kmemleak_alloc+0x21/0x3e
    [<ffffffff810dc1f7>] kmem_cache_alloc+0xa5/0xb1
    [<ffffffff81487bf5>] secpath_dup+0x1b/0x5a
    [<ffffffff81487df9>] xfrm_input+0x64/0x484
    [<ffffffff814bbd74>] xfrm6_rcv_spi+0x19/0x1b
    [<ffffffff814bbd96>] xfrm6_rcv+0x20/0x22
    [<ffffffff814960c7>] ip6_input_finish+0x203/0x31b
    [<ffffffff81496546>] ip6_input+0x1e/0x50
    [<ffffffff81496244>] ip6_rcv_finish+0x65/0x69
    [<ffffffff814964c7>] ipv6_rcv+0x27f/0x2e0
    [<ffffffff8140a65d>] __netif_receive_skb+0x5ba/0x65a
    [<ffffffff8140a898>] netif_receive_skb+0x47/0x78
    [<ffffffff8140b4c3>] napi_skb_finish+0x21/0x54
    [<ffffffff8140b5f3>] napi_gro_receive+0xfd/0x10a
    [<ffffffff81372b47>] rtl8169_poll+0x326/0x4fc
    [<ffffffff8140ad48>] net_rx_action+0x9f/0x188

I've grepped for "/org/free" specifically and sure enough, same scraps
of data seem to be in some of the (varied) dumps there.


--=20
Mike Kazantsev // fraggod.net

--Sig_/KJEwoBm/Z5od+QgN2ZibF=E
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCEfioACgkQASbOZpzyXnEqogCbBQd43a//LI/p2waYJ4GCCUFr
anAAoLRDzyOqgLtjQgKyrr4O9SMA35PN
=PXfG
-----END PGP SIGNATURE-----

--Sig_/KJEwoBm/Z5od+QgN2ZibF=E--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
