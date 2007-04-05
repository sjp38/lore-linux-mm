Subject: Re: [rfc] no ZERO_PAGE?
In-Reply-To: Your message of "Wed, 04 Apr 2007 17:27:31 PDT."
             <Pine.LNX.4.64.0704041724280.6730@woody.linux-foundation.org>
From: Valdis.Kletnieks@vt.edu
References: <20070329075805.GA6852@wotan.suse.de> <Pine.LNX.4.64.0703291324090.21577@blonde.wat.veritas.com> <20070330024048.GG19407@wotan.suse.de> <20070404033726.GE18507@wotan.suse.de> <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org> <6701.1175724355@turing-police.cc.vt.edu>
            <Pine.LNX.4.64.0704041724280.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1175736312_5833P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Wed, 04 Apr 2007 21:25:12 -0400
Message-ID: <5946.1175736312@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, tee@sgi.com, holt@sgi.com, Andrea Arcangeli <andrea@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1175736312_5833P
Content-Type: text/plain; charset=us-ascii

On Wed, 04 Apr 2007 17:27:31 PDT, Linus Torvalds said:

> Sure you do. If glibc used mmap() or brk(), it *knows* the new data is 
> zero. So if you use calloc(), for example, it's entirely possible that 
> a good libc wouldn't waste time zeroing it.

Right.  However, the *user* code usually has no idea about the previous
history - so if it uses malloc(), it should be doing something like:

	ptr = malloc(my_size*sizeof(whatever));
	memset(ptr, my_size*sizeof(), 0);

So malloc does something clever to guarantee that it's zero, and then userspace
undoes the cleverness because it has no easy way to *know* that cleverness
happened.

Admittedly, calloc() *can* get away with being clever.  I know we have some
glibc experts lurking here - any of them want to comment on how smart calloc()
actually is, or how smart it can become without needing major changes to the
rest of the malloc() and friends?


--==_Exmh_1175736312_5833P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFGFE/4cC3lWbTT17ARAm55AKDw8yO8HMO7dx3xeKcFEUgA0yt9kQCgsxS9
d1S1ea1UlHgGKfmocznM6Ek=
=gfGW
-----END PGP SIGNATURE-----

--==_Exmh_1175736312_5833P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
