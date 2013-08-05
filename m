Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 4E1ED6B0031
	for <linux-mm@kvack.org>; Sun,  4 Aug 2013 20:29:44 -0400 (EDT)
Date: Mon, 5 Aug 2013 10:29:17 +1000
From: NeilBrown <neilb@suse.de>
Subject: Re: [PATCH 15/23] mm, fs: avoid page allocation beyond i_size on
 read
Message-ID: <20130805102917.315976e5@notabene.brown>
In-Reply-To: <1375582645-29274-16-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1375582645-29274-16-git-send-email-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/TN0Ce_QHwvPupUYNU45S851"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill  A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

--Sig_/TN0Ce_QHwvPupUYNU45S851
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Sun,  4 Aug 2013 05:17:17 +0300 "Kirill A. Shutemov"
<kirill.shutemov@linux.intel.com> wrote:

> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>=20
> I've noticed that we allocated unneeded page for cache on read beyond
> i_size. Simple test case (I checked it on ramfs):
>=20
> $ touch testfile
> $ cat testfile
>=20
> It triggers 'no_cached_page' code path in do_generic_file_read().
>=20
> Looks like it's regression since commit a32ea1e. Let's fix it.
>=20
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: NeilBrown <neilb@suse.de>
> ---
>  mm/filemap.c | 4 ++++
>  1 file changed, 4 insertions(+)
>=20
> diff --git a/mm/filemap.c b/mm/filemap.c
> index 066bbff..c31d296 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -1163,6 +1163,10 @@ static void do_generic_file_read(struct file *filp=
, loff_t *ppos,
>  		loff_t isize;
>  		unsigned long nr, ret;
> =20
> +		isize =3D i_size_read(inode);
> +		if (!isize || index > (isize - 1) >> PAGE_CACHE_SHIFT)
> +			goto out;
> +
>  		cond_resched();
>  find_page:
>  		page =3D find_get_page(mapping, index);

Looks good to me.

Acked-by: NeilBrown <neilb@suse.de>

Thanks,
NeilBrown

--Sig_/TN0Ce_QHwvPupUYNU45S851
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUf7x3Tnsnt1WYoG5AQKnxA//Xeu579goDJa3UAOJn8qIIfXGnCI6T24M
hRmhG+FPLHVm8FwfD6WzoLNXy/Y8VIqKCIP1y36DocTxHcNzlKkJvlvrhJJezt7E
0Owc6T1shHaxs3wYCr6KwJZWPddJT2piq+PSLe8fV0L3PmTTOsKcNbP+e/tLt0uk
fW+YL7BoShQiOPs+Bmj9VRntqTLBMZiIBkNmCTJPDluAkSb/dGuWsMiWy+G8jLMi
vVkEkvDTi1qQ6sv97nMZWQC9Sj4p7+qLg/ZUSnINz5bVno8A6EEx8MVu29khhiKw
bQwuQCY6uYDIvmu1oHQVI8xK495YkUsiMTA9DOQ+Bua+UXI0TFa+LKHzAoE/g6Ok
axI56Bimq39xjl5DwzjUhSbfqFds4iLcbccw9w1Jin0Oh7wc1FHQOc0V6PfisESw
m5iidTB75AtMVjDiTXtXUOppUTA5Z2Lz34sFU0NQAKkozaBfzoY4IhZHNXuBgjOd
Ya/smkoCwXIKWDqAnZHl1WvG+OKQw/wZcsTx00RYQ87JVOJ99T/Pyg8NuoQ41J3x
77JuCnY8R3hahGVO3/EgrrVt1CkX2Bm4GhisgbyRMehur/Hm8sQUOq3q3fdjX0vd
JX5D3O5I8oAjZVasV68NPhT0kMnPglSAZBwJV35Nb7vA0v4babiedViVk8JfQzAk
y7WLUMDnbT0=
=h+wg
-----END PGP SIGNATURE-----

--Sig_/TN0Ce_QHwvPupUYNU45S851--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
