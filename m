Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE116B01AC
	for <linux-mm@kvack.org>; Wed, 26 May 2010 17:29:06 -0400 (EDT)
Subject: Re: [PATCH 0/3] mm: Swap checksum
In-Reply-To: Your message of "Thu, 27 May 2010 00:31:44 +0900."
             <20100526153144.GA3650@barrios-desktop>
From: Valdis.Kletnieks@vt.edu
References: <4BF81D87.6010506@cesarb.net> <20100523140348.GA10843@barrios-desktop> <4BF974D5.30207@cesarb.net> <AANLkTil1kwOHAcBpsZ_MdtjLmCAFByvF4xvm8JJ7r7dH@mail.gmail.com> <4BF9CF00.2030704@cesarb.net> <AANLkTin_BV6nWlmX6aXTaHvzH-DnsFIVxP5hz4aZYlqH@mail.gmail.com> <4BFA59F7.2020606@cesarb.net> <AANLkTikMTwzXt7-vQf9AG2VhwFIGs1jX-1uFoYAKSco7@mail.gmail.com> <4BFCF645.2050400@cesarb.net>
            <20100526153144.GA3650@barrios-desktop>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1274909335_4200P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 26 May 2010 17:28:55 -0400
Message-ID: <22942.1274909335@localhost>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Cesar Eduardo Barros <cesarb@cesarb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1274909335_4200P
Content-Type: text/plain; charset=us-ascii

On Thu, 27 May 2010 00:31:44 +0900, Minchan Kim said:
> On Wed, May 26, 2010 at 07:21:57AM -0300, Cesar Eduardo Barros wrote:
> > far as I can see, does nothing against the disk simply failing to
> > write and later returning stale data, since the stale checksum would
> > match the stale data.
> 
> Sorry. I can't understand your point. 
> Who makes stale data? If any layer makes data as stale, integrity is up to 
> the layer. Maybe I am missing your point. 
> Could you explain more detail?

I'm pretty sure that what Cesar meant was that the following could happen:

1) Write block 11983 on the disk, checksum 34FE9B72.
(... time passes.. maybe weeks)
2) Attempt to write block 11983 on disk with checksum AE9F3581. The write fails
due to a power failure or something.
(... more time passes...)
3) Read block 11983, get back data with checksum 34FE9B72. Checksum matches,
and there's no indication that the write in (2) ever failed. The program
proceeds thinking it's just read back the most recently written data, when in
fact it's just read an older version of that block. Problems can ensue if the
data just read is now out of sync with *other* blocks of data - instant data
corruption.

To be fair, we currently have the "read a stale block" problem after crashes
already.  The issue is that BLK_DEV_INTEGRITY can't provide a solution here,
but most users will form a mental image that it *is* in fact giving them
that guarantee.  The resulting mismatch between reality and expectations
cannot end well.




--==_Exmh_1274909335_4200P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL/ZKXcC3lWbTT17ARArvwAKDjdDRSG9nZPYMxp17U2yny93bRzACfeypD
iMS08wX2QITrbRCgAw3QBIk=
=H4Sf
-----END PGP SIGNATURE-----

--==_Exmh_1274909335_4200P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
