Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B5FBA6B0068
	for <linux-mm@kvack.org>; Fri, 11 Jan 2013 22:36:01 -0500 (EST)
Date: Sat, 12 Jan 2013 05:36:59 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: huge zero page vs FOLL_DUMP
Message-ID: <20130112033659.GA26890@otc-wbsnb-06>
References: <CANN689E5iw=UHfG1r82c91cZVqhX9xrxttKw3SCy=ZSgcAicNQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wRRV7LY7NUeQGEoC"
Content-Disposition: inline
In-Reply-To: <CANN689E5iw=UHfG1r82c91cZVqhX9xrxttKw3SCy=ZSgcAicNQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>


--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Jan 11, 2013 at 03:53:34PM -0800, Michel Lespinasse wrote:
> Hi,
>=20
> follow_page() has code to return ERR_PTR(-EFAULT) when it encounters
> the zero page and FOLL_DUMP flag is passed - this is used to avoid
> dumping the zero page to disk when doing core dumps, and also by
> munlock to avoid having potentially large number of threads trying to
> munlock the zero page at once, which we can't reclaim anyway.
>=20
> We don't have the corresponding logic when follow_page() encounters a
> huge zero page. I think we should, preferably before 3.8. However, I
> am slightly confused as to what to do for the munlock case, as the
> huge zero page actually does seem to be reclaimable. My guess is that
> we could still skip the munlocks, until the zero page is actually
> reclaimed at which point we should check if we can munlock it.
>=20
> Kirill, is this something you would have time to look into ?

Nice catch! Thank you.

I don't think we should do anything about mlock(). Huge zero page cannot
be mlocked -- it will not pass page->mapping check in
follow_trans_huge_pmd(). And it's not reclaimable if it's mapped to
anywhere.

Could you tese the patch?

=46rom 062a9b670ede9fe5fca1d1947b42990b6b0642a4 Mon Sep 17 00:00:00 2001
=46rom: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Sat, 12 Jan 2013 05:18:58 +0200
Subject: [PATCH] thp: Avoid dumping huge zero page

No reason to preserve huge zero page in core dump.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Michel Lespinasse <walken@google.com>
---
 mm/huge_memory.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 6001ee6..b5783d8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1257,6 +1257,10 @@ struct page *follow_trans_huge_pmd(struct vm_area_st=
ruct *vma,
 	if (flags & FOLL_WRITE && !pmd_write(*pmd))
 		goto out;
=20
+	/* Avoid dumping huge zero page */
+	if ((flags & FOLL_DUMP) && is_huge_zero_pmd(*pmd))
+		return ERR_PTR(-EFAULT);
+
 	page =3D pmd_page(*pmd);
 	VM_BUG_ON(!PageHead(page));
 	if (flags & FOLL_TOUCH) {
--=20
1.8.1

--=20
 Kirill A. Shutemov

--wRRV7LY7NUeQGEoC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQ8NpbAAoJEAd+omnVudOMrZwQAKJMtMb/sX7nRgyUUesr466k
YrGJdmYFH/UBxfb6cNOQqLmusaYu/4l/oXCv2Er5Tr3bAWwqneplaBhPu1IJPm0m
YVRtV+UbsA0ND1591Qvt9F6eftUTbYl8xUzBdRYn7ETvaNMPFlqSik+xoW84Ji0c
wJ/2BkVTNhKl3GZuW1kFzt4RVpfP649wqDNEmawpfdBWLLjCYpuSJiG+hVYriDYO
sDou4mtey1MVbXa8/lRewsLrEAfEtE0npq5RJDUs6TK5aPPW1RZzXRk/o515Macv
De8ZSEok8KUg8PmVLflEu0pCYRs2gNbhTPdyd1pBtc4ySyQcrckl+1x90yeqUcEU
XuXWePo+inrjCMWDAytO3NAVu8hRxV6/Y9ebuxhVBvNdNqfhGVDcZYKvaXnnnNIp
UkyfgZ7PCEs1IexCr0okwT2jpc3mpBATdElWYl9ka3RDqflRONY3eV5VOZsuMF88
QD09m3ZVMt8c67jLBBkXybo2L3YcD9fqVeXE8YWSc7uFhvg9MVfqUhJNLRKpYwcC
g0aqlRZjYvEyNJ493cYru4FwjgSOYgGl5U59VhjWQCuW+I6PB10ORqkQNBjrd7Hl
wWmKMcEXNnXIp3oiNVMWMdZtcEvg8q0vxqioGT2CKadRUZAIWswfLvMh5tjVPBEP
3hS0JYn5VfS3OqjIXoTU
=c4g8
-----END PGP SIGNATURE-----

--wRRV7LY7NUeQGEoC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
