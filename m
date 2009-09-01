Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 3D6BA6B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 05:24:08 -0400 (EDT)
Date: Tue, 1 Sep 2009 10:23:39 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] swap: Fix swap size in case of block devices
In-Reply-To: <d760cf2d0909010011g75a918c0hedd4b2571afc054c@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0909011011140.12934@sister.anvils>
References: <200908302149.10981.ngupta@vflare.org>
 <Pine.LNX.4.64.0908311151190.16326@sister.anvils>  <4A9C06B2.3040009@vflare.org>
  <Pine.LNX.4.64.0908311959460.13560@sister.anvils>
 <d760cf2d0909010011g75a918c0hedd4b2571afc054c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-790592257-1251797019=:12934"
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Karel Zak <kzak@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-790592257-1251797019=:12934
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 1 Sep 2009, Nitin Gupta wrote:
> On Tue, Sep 1, 2009 at 12:56 AM, Hugh Dickins<hugh.dickins@tiscali.co.uk>=
 wrote:
> > On Mon, 31 Aug 2009, Nitin Gupta wrote:
> >> For block devices, setup_swap_extents() leaves p->pages untouched.
> >> For regular files, it sets p->pages
> >> =C2=A0 =C2=A0 =C2=A0 =3D=3D total usable swap pages (including header =
page) - 1;
> >
> > I think you're overlooking the "page < sis->max" condition
> > in setup_swap_extents()'s loop. =C2=A0So at the end of the loop,
> > if no pages were lost to fragmentation, we have
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sis->max =3D pag=
e_no; =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* no change */
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sis->pages =3D p=
age_no - 1; =C2=A0 =C2=A0 =C2=A0 /* no change */
> >
>=20
> Oh, I missed this loop condition. The variable naming is so bad, I
> find it very hard to follow this part of code.
>=20
> Still, if there is even a single page in swap file that is not usable
> (i.e. non-contiguous on disk) -- which is what usually happens for swap
> files of any practical size -- setup_swap_extents() gives correct value
> in sis->pages =3D=3D total usable pages (including header) - 1;
>=20
> However, if all the file pages are usable, it gives off-by-one error, as
> you noted.

Right, I see your point now: when the regular file is fragmented thus,
setup_swap_extents() would allow it to use the final page of the file,
which would otherwise be (erroneously) disallowed.

But I would reword your "what usually happens" to "what happens in
the general case": perhaps I'm wrong, but I think that usually these
days people are creating swap files on filesystems with 4kB block
size, where there's no issue of intra-page fragmentation lowering
that page count (but there may still be inter-page fragmentation
to make swapping to the file less efficient than to a partition).

>=20
> > Yes, I'd dislike that discrepancy between regular files and block
> > devices, if I could see it.  Though I'd probably still be cautious
> > about the disk partitions.
>=20
> > dd if=3D/dev/zero of=3D/swap bs=3D200k        # says 204800 bytes (205k=
B)
> > mkswap /swap                            # says size =3D 196 KiB
> > swapon /swap                            # dmesg says Adding 192k swap
>=20
> > which is what I've come to expect from the off-by-one,
> > even on regular files.
>=20
> In general, its not correct to compare size repored by mkswap and
> swapon like this. The size reported by mkswap includes pages which
> are not contiguous on disk. While, kernel considers only
> PAGE_SIZE-length, PAGE_SIZE-aligned contiguous run of blocks. So, size
> reported by mkswap and swapon can vary wildly. For e.g.:
>=20
> (on mtdram with ext2 fs)
> dd if=3D/dev/zero of=3Dswap.dd bs=3D1M count=3D10
> mkswap swap.dd # says size =3D 10236 KiB
> swapon swap.dd # says Adding 10112k swap

If the filesystem has block size 1kB or 2kB, yes.

>=20
> =3D=3D=3D=3D
>=20
> So, to summarize:
>=20
> 1. mkswap always behaves correctly: It sets number of pages in swap file
> minus one as 'last_page' in swap header (since this is a 0-based index).
> This same value (total pages - 1) is printed out as size since it knows
> that first page is swap header.
>=20
> 2. swapon() for block devices: off-by-one error causing last swap page
> to remain unused.
>=20
> 3. swapon() for regular files:
>   3.1 off-by-one error if every swap page in this file is usable i.e.
>       every PAGE_SIZE-length, PAGE_SIZE-aligned chunk is contiguous on
>       disk.
>   3.2 correct size value if there is at least one swap page which is
>       unusable -- which is expected from swap file of any practical
>       size.
>=20
>=20
> I will go through swap code again to find other possible off-by-one
> errors. The revised patch will fix these inconsistencies.

Thanks.

Hugh
--8323584-790592257-1251797019=:12934--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
