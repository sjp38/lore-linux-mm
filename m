Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 833D56B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 20:24:14 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id p5so1151576lag.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 17:24:12 -0700 (PDT)
Date: Sun, 21 Oct 2012 06:24:02 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121021062402.7c4c4cb8@sacrilege>
In-Reply-To: <20121021044540.12e8f4b7@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
	<20121021044540.12e8f4b7@sacrilege>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/EUBLhir7Zkto6lgopXsP61Y"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/EUBLhir7Zkto6lgopXsP61Y
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun, 21 Oct 2012 04:45:40 +0600
Mike Kazantsev <mk.fraggod@gmail.com> wrote:

>=20
> kmemleak mechanism seem to provide stack traces and interesting calls
> for debugging of whatever is allocating the non-freed objects, so guess
> I'll see if I can get more definitive (to my ignorant eye) "look here"
> hint from it, and might drop one more mail with data from there.
>=20

kmemleak finds a lot (dozens megabytes of stack traces) of identical
paths leading to a leaks:

(for IPv6 packets)
unreferenced object 0xffff88002fa25b00 (size 56):
  comm "softirq", pid 0, jiffies 4295009073 (age 295.620s)
  hex dump (first 32 bytes):
    01 00 00 00 01 00 00 00 00 fc 6e 30 00 88 ff ff  ..........n0....
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff814cfa2b>] kmemleak_alloc+0x21/0x3e
    [<ffffffff810d9445>] kmem_cache_alloc+0xa5/0xb1
    [<ffffffff8147dd35>] secpath_dup+0x1b/0x5a
    [<ffffffff8147df39>] xfrm_input+0x64/0x484
    [<ffffffff814b1d2c>] xfrm6_rcv_spi+0x19/0x1b
    [<ffffffff814b1d4e>] xfrm6_rcv+0x20/0x22
    [<ffffffff8148c19f>] ip6_input_finish+0x203/0x31b
    [<ffffffff8148c622>] ip6_input+0x1e/0x50
    [<ffffffff8148c31c>] ip6_rcv_finish+0x65/0x69
    [<ffffffff8148c5a3>] ipv6_rcv+0x283/0x2e4
    [<ffffffff813ff8ba>] __netif_receive_skb+0x599/0x64c
    [<ffffffff813ffb08>] netif_receive_skb+0x47/0x78
    [<ffffffff81400644>] napi_skb_finish+0x21/0x53
    [<ffffffff81400778>] napi_gro_receive+0x102/0x10e
    [<ffffffff8136978b>] rtl8169_poll+0x326/0x4f9
    [<ffffffff813ffcda>] net_rx_action+0x9f/0x175

(for IPv4 packets)
unreferenced object 0xffff88003387e000 (size 56):
  comm "softirq", pid 0, jiffies 4294915803 (age 563.583s)
  hex dump (first 32 bytes):
    01 00 00 00 01 00 00 00 00 48 be 30 00 88 ff ff  .........H.0....
    6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
  backtrace:
    [<ffffffff814cfa2b>] kmemleak_alloc+0x21/0x3e
    [<ffffffff810d9445>] kmem_cache_alloc+0xa5/0xb1
    [<ffffffff8147dd35>] secpath_dup+0x1b/0x5a
    [<ffffffff8147df39>] xfrm_input+0x64/0x484
    [<ffffffff81474f7b>] xfrm4_rcv_encap+0x17/0x19
    [<ffffffff81474f9c>] xfrm4_rcv+0x1f/0x21
    [<ffffffff81430514>] ip_local_deliver_finish+0x170/0x22a
    [<ffffffff81430706>] ip_local_deliver+0x46/0x78
    [<ffffffff8143038d>] ip_rcv_finish+0x2bd/0x2d4
    [<ffffffff81430969>] ip_rcv+0x231/0x28c
    [<ffffffff813ff8ba>] __netif_receive_skb+0x599/0x64c
    [<ffffffff813ffb08>] netif_receive_skb+0x47/0x78
    [<ffffffff81400644>] napi_skb_finish+0x21/0x53
    [<ffffffff81400778>] napi_gro_receive+0x102/0x10e
    [<ffffffff8136978b>] rtl8169_poll+0x326/0x4f9
    [<ffffffff813ffcda>] net_rx_action+0x9f/0x175

Object at the top and trace seem to be the same (between same
IP-family) everywhere, just ages and addresses are different.

IPv6 usage seem to be one important detail which I failed to mention.
IPv4 traces seem to be really rare (only several of them), but that
might be understandable because rsync was ran over IPv6.

Still wasn't able to figure out what might cause the get's/put's
disbalance with that commit, but was able to revert it, without
anything bad happening (so far), using the patch below (in case
issue might bite someone else before proper fix is found).


--

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 6e04b1f..52a9d40 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -427,26 +427,8 @@ struct sk_buff *__netdev_alloc_skb(struct net_device *=
dev,
 				   unsigned int length, gfp_t gfp_mask)
 {
 	struct sk_buff *skb =3D NULL;
-	unsigned int fragsz =3D SKB_DATA_ALIGN(length + NET_SKB_PAD) +
-			      SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
-
-	if (fragsz <=3D PAGE_SIZE && !(gfp_mask & (__GFP_WAIT | GFP_DMA))) {
-		void *data;
-
-		if (sk_memalloc_socks())
-			gfp_mask |=3D __GFP_MEMALLOC;
-
-		data =3D __netdev_alloc_frag(fragsz, gfp_mask);
-
-		if (likely(data)) {
-			skb =3D build_skb(data, fragsz);
-			if (unlikely(!skb))
-				put_page(virt_to_head_page(data));
-		}
-	} else {
-		skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask,
+	skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask,
 				  SKB_ALLOC_RX, NUMA_NO_NODE);
-	}
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev =3D dev;


--=20
Mike Kazantsev // fraggod.net

--Sig_/EUBLhir7Zkto6lgopXsP61Y
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCDQKYACgkQASbOZpzyXnFBHwCfVAT7N2AyDnWZQkI3KTohlnb1
Bb0AoOz8FT7YxN7FXYccXvDdihPWGu1S
=VVET
-----END PGP SIGNATURE-----

--Sig_/EUBLhir7Zkto6lgopXsP61Y--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
