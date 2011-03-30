Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B5D408D0040
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 07:38:14 -0400 (EDT)
Subject: Re: kmemleak for MIPS
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTi=vcn5jHpk0O8XS9XJ8s5k-mCnzUwu70mFTx4=g@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	 <AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
	 <1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTim139fpJsMJFLiyUYvFgGMz-Ljgd_yDrks-tqhE@mail.gmail.com>
	 <1301395206.583.53.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTim-4v5Cbp6+wHoXjgKXoS0axk1cgQ5AHF_zot80@mail.gmail.com>
	 <1301399454.583.66.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTin0_gT0E3=oGyfMwk+1quqonYBExeN9a3=v=Lob@mail.gmail.com>
	 <AANLkTi=gMP6jQuQFovfsOX=7p-SSnwXoVLO_DVEpV63h@mail.gmail.com>
	 <1301476505.29074.47.camel@e102109-lin.cambridge.arm.com>
	 <AANLkTi=YB+nBG7BYuuU+rB9TC-BbWcJ6mVfkxq0iUype@mail.gmail.com>
	 <AANLkTi=L0zqwQ869khH1efFUghGeJjoyTaBXs-O2icaM@mail.gmail.com>
	 <AANLkTi=vcn5jHpk0O8XS9XJ8s5k-mCnzUwu70mFTx4=g@mail.gmail.com>
Date: Wed, 30 Mar 2011 12:38:05 +0100
Message-ID: <1301485085.29074.61.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Cc: Maxin John <maxin.john@gmail.com>, naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>

On Wed, 2011-03-30 at 12:24 +0100, Daniel Baluta wrote:
> We have:
>=20
> > UDP hash table entries: 128 (order: 0, 4096 bytes)
> > CONFIG_BASE_SMALL=3D0
>=20
> udp_table_init looks like:
>=20
>         if (!CONFIG_BASE_SMALL)
>                 table->hash =3D alloc_large_system_hash(name, .. &table->=
mask);
>         /*
>          * Make sure hash table has the minimum size
>          */
>=20
> Since CONFIG_BASE_SMALL is 0, we are allocating the hash using
> alloc_large_system
> Then:
>         if (CONFIG_BASE_SMALL || table->mask < UDP_HTABLE_SIZE_MIN - 1) {
>                 table->hash =3D kmalloc();
>=20
> table->mask is 127, and UDP_HTABLE_SIZE_MIN is 256, so we are allocating =
again
> table->hash without freeing already allocated memory.

Indeed (on my ARM system the reported UDP hash table entries is 512, so
I don't get the memory leak).

> We could free table->hash, before allocating the memory with kmalloc.
> I don't fully understand the condition table->mask < UDP_HTABLE_SIZE_MIN =
- 1.

We don't have the equivalent of free_large_system_hash(). Reordering the
'if' blocks may be better.

--=20
Catalin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
