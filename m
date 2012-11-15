Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id B6A296B009A
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 04:31:02 -0500 (EST)
Date: Thu, 15 Nov 2012 11:32:09 +0200
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH v5 08/11] thp: setup huge zero page on non-write page
 fault
Message-ID: <20121115093209.GF9676@otc-wbsnb-06>
References: <1352300463-12627-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1352300463-12627-9-git-send-email-kirill.shutemov@linux.intel.com>
 <alpine.DEB.2.00.1211141531110.22537@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="R6sEYoIZpp9JErk7"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1211141531110.22537@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>


--R6sEYoIZpp9JErk7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 14, 2012 at 03:33:16PM -0800, David Rientjes wrote:
> On Wed, 7 Nov 2012, Kirill A. Shutemov wrote:
>=20
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index f36bc7d..41f05f1 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -726,6 +726,16 @@ int do_huge_pmd_anonymous_page(struct mm_struct *m=
m, struct vm_area_struct *vma,
> >  			return VM_FAULT_OOM;
> >  		if (unlikely(khugepaged_enter(vma)))
> >  			return VM_FAULT_OOM;
> > +		if (!(flags & FAULT_FLAG_WRITE)) {
> > +			pgtable_t pgtable;
> > +			pgtable =3D pte_alloc_one(mm, haddr);
> > +			if (unlikely(!pgtable))
> > +				goto out;
>=20
> No use in retrying, just return VM_FAULT_OOM.

Hm. It's consistent with non-hzp path: if pte_alloc_one() in
__do_huge_pmd_anonymous_page() fails __do_huge_pmd_anonymous_page()
returns VM_FAULT_OOM which leads to "goto out".

Should it be fixed too?

>=20
> > +			spin_lock(&mm->page_table_lock);
> > +			set_huge_zero_page(pgtable, mm, vma, haddr, pmd);
> > +			spin_unlock(&mm->page_table_lock);
> > +			return 0;
> > +		}
> >  		page =3D alloc_hugepage_vma(transparent_hugepage_defrag(vma),
> >  					  vma, haddr, numa_node_id(), 0);
> >  		if (unlikely(!page)) {

--=20
 Kirill A. Shutemov

--R6sEYoIZpp9JErk7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQpLaZAAoJEAd+omnVudOMd2UP/2a0TlYQG+m0yNRbGoFpV9EB
n6VTm/l8RbmQM9EXsYG8V0gaUxQvFPwuyEY4xxvd7CBlPz4CBcQA8s8hSuIlLyxX
zbeDzUficvPQPWWCKb0l5K/ASa8+4WRdMCr7mot1fq3Az5cdDbluOTtdQqF3pr2W
xhK6T26DPKxUSBjExdPS1i30V3UQfurJFDmKs7FB6hg8Svrd8G9DXyNTZA5XJZSW
JDh2YGP3A8L/XU89LcwsxIL8q7xebvCY+onGVxZipPkzLfkLFfYX9x+Gz+Iobi8t
5qnWdDwY4i+Yg9Z4MnaR+8ZE9J/VO2mHmE41TJg8wDmQ6t+x0fVhNeJwBJh2R26S
1HP6XiE15drc8VY//0Nj0Cpyh93YRo4wif/mxdlWQaY9HYJaIYTsc23mr0MXXrgO
HnQJKNedowhW5df1n6usPbUd79YFuN6IrtCDEZY50J1+9XhCpiPfH+FBLTTo7W+J
emuFuOw7Mp3asO43SoNyq94pvQ9aJMBdeKRI1GCmf/MitcwxaGyaGq/YyHwic4CS
2mNWO4T7SaVYOde9SlATkEBNGyppH0jtzsgzcICUwdP+5w937VcNqqW2TD1LSC3d
E/ba0czRfmY2AGlXviV3qnMm6yWyF1ejQkMsSfHNxF0huOkxilLRIMrDhc2QyspT
7OhzpBozUYmAAIjk7YlX
=dJsM
-----END PGP SIGNATURE-----

--R6sEYoIZpp9JErk7--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
