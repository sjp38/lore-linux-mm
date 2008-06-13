Subject: Re: [PATCH] fix double unlock_page() in 2.6.26-rc5-mm3 kernel BUG at mm/filemap.c:575!
In-Reply-To: Your message of "Fri, 13 Jun 2008 10:44:44 +0900."
             <20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
From: Valdis.Kletnieks@vt.edu
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org> <4850E1E5.90806@linux.vnet.ibm.com> <20080612015746.172c4b56.akpm@linux-foundation.org> <20080612202003.db871cac.kamezawa.hiroyu@jp.fujitsu.com>
            <20080613104444.63bd242f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1213331673_4969P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Fri, 13 Jun 2008 00:34:33 -0400
Message-ID: <5289.1213331673@turing-police.cc.vt.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>, "riel@redhat.com" <riel@redhat.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

--==_Exmh_1213331673_4969P
Content-Type: text/plain; charset=us-ascii

On Fri, 13 Jun 2008 10:44:44 +0900, KAMEZAWA Hiroyuki said:

> quick fix for double unlock_page();
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamewzawa.hiroyu@jp.fujitsu.com>
> Index: linux-2.6.26-rc5-mm3/mm/truncate.c
> ===================================================================
> --- linux-2.6.26-rc5-mm3.orig/mm/truncate.c
> +++ linux-2.6.26-rc5-mm3/mm/truncate.c
> @@ -104,8 +104,8 @@ truncate_complete_page(struct address_sp
>  
>  	cancel_dirty_page(page, PAGE_CACHE_SIZE);
>  
> -	remove_from_page_cache(page);
>  	clear_page_mlock(page);
> +	remove_from_page_cache(page);
>  	ClearPageUptodate(page);
>  	ClearPageMappedToDisk(page);
>  	page_cache_release(page);	/* pagecache ref */

Confirming this quick fix works on my laptop that was hitting this crash -
am now up and running on -rc5-mm3.

--==_Exmh_1213331673_4969P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFIUfjZcC3lWbTT17ARAl94AJkBoB3dPLHaq1a+dfK29jmkGakJigCfaIDJ
B55Awuo3IiE4YPeXEEoK928=
=ioU1
-----END PGP SIGNATURE-----

--==_Exmh_1213331673_4969P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
