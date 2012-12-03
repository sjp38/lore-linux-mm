Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 91B9B6B005D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2012 04:51:58 -0500 (EST)
Date: Mon, 3 Dec 2012 11:53:16 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 05/11] thp: change_huge_pmd(): keep huge zero page
 write-protected
Message-ID: <20121203095316.GA16630@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-6-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141512400.22537@chino.kir.corp.google.com>
 <20121115084635.GC9676@otc-wbsnb-06>
 <alpine.DEB.2.00.1211151344100.27188@chino.kir.corp.google.com>
 <20121116181321.GA18313@otc-wbsnb-06>
 <alpine.DEB.2.00.1211161208120.2788@chino.kir.corp.google.com>
 <20121120160040.GA15401@otc-wbsnb-06>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="dDRMvlgZJXvWKvBx"
Content-Disposition: inline
In-Reply-To: <20121120160040.GA15401@otc-wbsnb-06>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--dDRMvlgZJXvWKvBx
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Nov 20, 2012 at 06:00:40PM +0200, Kirill A. Shutemov wrote:
> On Fri, Nov 16, 2012 at 12:10:39PM -0800, David Rientjes wrote:
> > On Fri, 16 Nov 2012, Kirill A. Shutemov wrote:
> >=20
> > > > > > > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > > > > > > index d767a7c..05490b3 100644
> > > > > > > --- a/mm/huge_memory.c
> > > > > > > +++ b/mm/huge_memory.c
> > > > > > > @@ -1259,6 +1259,8 @@ int change_huge_pmd(struct vm_area_stru=
ct *vma, pmd_t *pmd,
> > > > > > >  		pmd_t entry;
> > > > > > >  		entry =3D pmdp_get_and_clear(mm, addr, pmd);
> > > > > > >  		entry =3D pmd_modify(entry, newprot);
> > > > > > > +		if (is_huge_zero_pmd(entry))
> > > > > > > +			entry =3D pmd_wrprotect(entry);
> > > > > > >  		set_pmd_at(mm, addr, pmd, entry);
> > > > > > >  		spin_unlock(&vma->vm_mm->page_table_lock);
> > > > > > >  		ret =3D 1;
> > > > > >=20
> > > > > > Nack, this should be handled in pmd_modify().
> > > > >=20
> > > > > I disagree. It means we will have to enable hzp per arch. Bad ide=
a.
> > > > >=20
> > > >=20
> > > > pmd_modify() only exists for those architectures with thp support a=
lready,=20
> > > > so you've already implicitly enabled for all the necessary architec=
tures=20
> > > > with your patchset.
> > >=20
> > > Now we have huge zero page fully implemented inside mm/huge_memory.c.=
 Push
> > > this logic to pmd_modify() means we expose hzp implementation details=
 to
> > > arch code. Looks ugly for me.
> > >=20
> >=20
> > So you are suggesting that anybody who ever does pmd_modify() in the=20
> > future is responsible for knowing about the zero page and to protect=20
> > against giving it write permission in the calling code??
>=20
> Looks like we don't need the patch at all.
>=20
> IIUC, if you ask for PROT_WRITE vm_get_page_prot() will translate it to
> _PAGE_COPY or similar and you'll only get the page writable on pagefault.
>=20
> Could anybody confirm that it's correct?
>=20
> --=20
>  Kirill A. Shutemov

Andrew, please drop the patch or replace it with the patch below, if you
wish.

=46rom 048e3d4c97202cfecab55ead2a816421dce4b382 Mon Sep 17 00:00:00 2001
=46rom: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Date: Tue, 7 Aug 2012 06:09:56 -0700
Subject: [PATCH] thp: change_huge_pmd(): make sure we don't try to make a
 page writable

mprotect core never tries to make page writable using change_huge_pmd().
Let's add an assert that the assumption is true. It's important to be
sure we will not make huge zero page writable.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/huge_memory.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index f5589c0..5fba83b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1245,6 +1245,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd_t=
 *pmd,
 		pmd_t entry;
 		entry =3D pmdp_get_and_clear(mm, addr, pmd);
 		entry =3D pmd_modify(entry, newprot);
+		BUG_ON(pmd_write(entry));
 		set_pmd_at(mm, addr, pmd, entry);
 		spin_unlock(&vma->vm_mm->page_table_lock);
 		ret =3D 1;
--=20
 Kirill A. Shutemov

--dDRMvlgZJXvWKvBx
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQvHaMAAoJEAd+omnVudOMQsgP/07sICwPKwcv5Gz5fKuF+zM8
aWysH2PmgmKRG6sgytwvWknjdEI704Qfa/suQ/keaoQmmT+JbamgOC5ZGln5F7vC
ebDWAh3+wTK1oTKeg4b3KOUBRFuf6Gb4AD57ZVwa8O2jKdAxrbbCUGB9JlFbVdU7
otwB3fBmOpuLUnD8spRJBmF4TxkUMe5mhvatqdS161GHMSg3At4zuwf8x1crG6DV
2FsKDk/XazqwaECcScbf9UEObC0nR5tM8hqiNRNDs+RSt9TXIZI+/6ywcTckRJo1
xu4OSUMbPW+00ZtHOvTShP48vSpZTK/RmHODBOJPVyDiJiQRX0gFBs636uVws+kv
ZwVSFK30rCIq8ppW2Vas0Q3tHFjVvE5bZRwBNtQ1HkAY4YY2y9GxgukDs9qqahPC
HNeeY8c7iLCbFQX3VChG6o4NoFj3wGsQkYdaXxbcowPQfmaiOKV2LgLl4P2hzB6L
vS4CQPaklj2VD1nQRCmkl911uHxVtv0gHnaWEqABP1oMqfdwPUZvzskoZj23rgX6
Tf0qGwfKzWEGm46FZBoq1NFrKU2in9ddLG4JpPMQ0WPK6G9fdWPqA2biUs5W0w0w
IIfNW3t4PLdZcNEQdRk0LBD2JViFCpGwJoD64wngaIz91gJxFuhBTPclWOd1DhO7
rBfCzovBdsrLZztcbsvP
=Lv6W
-----END PGP SIGNATURE-----

--dDRMvlgZJXvWKvBx--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
