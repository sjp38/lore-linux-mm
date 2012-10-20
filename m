Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id BAC496B0062
	for <linux-mm@kvack.org>; Sat, 20 Oct 2012 18:45:51 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id k6so1173953lbo.14
        for <linux-mm@kvack.org>; Sat, 20 Oct 2012 15:45:49 -0700 (PDT)
Date: Sun, 21 Oct 2012 04:45:40 +0600
From: Mike Kazantsev <mk.fraggod@gmail.com>
Subject: Re: PROBLEM: Memory leak (at least with SLUB) from "secpath_dup"
 (xfrm) in 3.5+ kernels
Message-ID: <20121021044540.12e8f4b7@sacrilege>
In-Reply-To: <20121020204958.4bc8e293@sacrilege>
References: <20121019205055.2b258d09@sacrilege>
	<20121019233632.26cf96d8@sacrilege>
	<CAHC9VhQ+gkAaRmwDWqzQd1U-hwH__5yxrxWa5_=koz_XTSXpjQ@mail.gmail.com>
	<20121020204958.4bc8e293@sacrilege>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/ohQ=sCURuH21t1BfZK+M3dd"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Moore <paul@paul-moore.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org

--Sig_/ohQ=sCURuH21t1BfZK+M3dd
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sat, 20 Oct 2012 20:49:58 +0600
Mike Kazantsev <mk.fraggod@gmail.com> wrote:

> On Sat, 20 Oct 2012 08:42:33 -0400
> Paul Moore <paul@paul-moore.com> wrote:
>=20
> > Thanks for the problem report.  I'm not going to be in a position to st=
art
> > looking into this until late Sunday, but hopefully it will be a quick f=
ix.
> >=20
> > Two quick questions (my apologies, I'm not able to dig through your logs
> > right now): do you see this leak on kernels < 3.5.0, and are you using =
any
> > labeled IPsec connections?
> >=20
>=20
> As I understand, labelled connections are only used in SELinux
> and SMACK LSM, which are not enabled (in Kconfig, i.e. not built) in any
> of the kernels I use.
>=20
> The only LSM I have enabled (and actually use on 2/4 of these machines)
> is AppArmor, and though I think it doesn't attach any labels to network
> connections yet (there's a "Wishlist" bug at
> https://bugs.launchpad.net/ubuntu/+source/apparmor/+bug/796588, but I
> can't seem to find an existing implementation).
>=20
> I believe it has started with 3.5.0, according to all available logs I
> have. I'm afraid laziness and other tasks have prevented me from
> looking into and reporting the issue back then, but memory graph trends
> start at the exact time of reboot into 3.5.0 kernels, and before that,
> there're no such trends for slab memory usage.
>=20
> I've been able to ignore and work around the problem for months now, so
> I don't think there's any rush at all ;)
>=20
> But that said, currently I've started git bisect process between v3.5
> and v3.4 tags, so hopefully I'll get good-enough results of it before
> you'll get to it (probably in a few hours to a few days).
>=20
> Also, I've found that switching to "slab" allocator from "slub" doesn't
> help the problem at all, so I guess something doesn't get freed in the
> code indeed, though I hasn't been able to find anything relevant in the
> logs for the sources where secpath_put and secpath_dup are used, and
> decided to try bisect.
>=20

Sorry for yet another mail on the weekend, but I've finished the bisect
and here is the result:

a1c7fff7e18f59e684e07b0f9a770561cd39f395 is the first bad commit
commit a1c7fff7e18f59e684e07b0f9a770561cd39f395
Author: Eric Dumazet <edumazet@google.com>
Date:   Thu May 17 07:34:16 2012 +0000

    net: netdev_alloc_skb() use build_skb()

    netdev_alloc_skb() is used by networks driver in their RX path to
    allocate an skb to receive an incoming frame.

    With recent skb->head_frag infrastructure, it makes sense to change
    netdev_alloc_skb() to use build_skb() and a frag allocator.

    This permits a zero copy splice(socket->pipe), and better GRO or TCP
    coalescing.

    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 17938b1b46bc38aa126cc23b7a7647259297657d 1e29cf65869391eb135=
52c51e0cf288fc7085fec M      net

No skips, all "good" / "bad" decisions were very unambiguous and easy
to make - secpath_cache slabs either stayed at always-constant 20K
cumulative size (~5 of them) and were reported as 10-15% full in "good"
case, or were 99% full and eating memory at hudreds KiB/s (during same
rsync transfer) in "bad" case.

Reverting that commit in 3.6.2 kernel looks like a bad idea and doesn't
seem possible to do cleanly.
Being not a C coder and having only faint idea about how things should
be done with regards to socket buffers, I can't seem to find anything
to tweak based on that commit either.

kmemleak mechanism seem to provide stack traces and interesting calls
for debugging of whatever is allocating the non-freed objects, so guess
I'll see if I can get more definitive (to my ignorant eye) "look here"
hint from it, and might drop one more mail with data from there.


--=20
Mike Kazantsev // fraggod.net

--Sig_/ohQ=sCURuH21t1BfZK+M3dd
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlCDKZcACgkQASbOZpzyXnHunACgm5y+2YW7MO6qBLq82GYcmNK5
pkoAn2A/Hi0c9v+hQqJ0/5w5IPKLg8Oi
=2tyr
-----END PGP SIGNATURE-----

--Sig_/ohQ=sCURuH21t1BfZK+M3dd--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
