Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id A84206B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 06:33:03 -0400 (EDT)
Date: Fri, 10 Aug 2012 13:33:04 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH, RFC 0/9] Introduce huge zero page
Message-ID: <20120810103304.GA3915@otc-wbsnb-06>
References: <1344503300-9507-1-git-send-email-kirill.shutemov@linux.intel.com>
 <20120810034912.GA31071@hacker.(null)>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IJpNTDwzlM2Ie8A6"
Content-Disposition: inline
In-Reply-To: <20120810034912.GA31071@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, Gavin Shan <shangw@linux.vnet.ibm.com>


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 10, 2012 at 11:49:12AM +0800, Wanpeng Li wrote:
> On Thu, Aug 09, 2012 at 12:08:11PM +0300, Kirill A. Shutemov wrote:
> >From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >
> >During testing I noticed big (up to 2.5 times) memory consumption overhe=
ad
> >on some workloads (e.g. ft.A from NPB) if THP is enabled.
> >
> >The main reason for that big difference is lacking zero page in THP case.
> >We have to allocate a real page on read page fault.
> >
> >A program to demonstrate the issue:
> >#include <assert.h>
> >#include <stdlib.h>
> >#include <unistd.h>
> >
> >#define MB 1024*1024
> >
> >int main(int argc, char **argv)
> >{
> >        char *p;
> >        int i;
> >
> >        posix_memalign((void **)&p, 2 * MB, 200 * MB);
> >        for (i =3D 0; i < 200 * MB; i+=3D 4096)
> >                assert(p[i] =3D=3D 0);
> >        pause();
> >        return 0;
> >}
> >
> >With thp-never RSS is about 400k, but with thp-always it's 200M.
> >After the patcheset thp-always RSS is 400k too.
> >
> Hi Kirill,=20
>=20
> Thank you for your patchset, I have some questions to ask.
>=20
> 1. In your patchset, if read page fault, the pmd will be populated by huge
> zero page, IIUC, assert(p[i] =3D=3D 0) is a read operation, so why thp-al=
ways
> RSS is 400K ? You allocate 100 pages, why each cost 4K? I think the
> right overhead should be 2MB for the huge zero page instead of 400K, where
> I missing ?

400k comes not from the allocation, but from libc runtime. The test
program consumes about the same without any allocation at all.

Zero page is a global resource. System owns it. It's not accounted to any
process.

>=20
> 2. If the user hope to allocate 200MB, total 100 pages needed. The codes=
=20
> will allocate one 2MB huge zero page and populate to all associated pmd
> in your patchset logic. When the user attempt to write pages, wp will be=
=20
> triggered, and if allocate huge page failed will fallback to
> do_huge_pmd_wp_zero_page_fallback in your patch logic, but you just
> create a new table and set pte around fault address to the newly
> allocated page, all other ptes set to normal zero page. In this scene=20
> user only get one 4K page and all other zero pages, how the codes can
> cotinue to work? Why not fallback to allocate normal page even if not=20
> physical continuous.

Since we allocate 4k page around the fault address the fault is handled.
Userspace can use it.

If the process will try to write to any other 4k page of this area a new
fault will be triggered and do_wp_page() will allocate a real page.

It's not reasonable to allocate all 4k pages in the fallback path. We can
postpone it until userspace will really want to use them. This way we reduce
memory pressure in fallback path.

> 3. In your patchset logic:
> "In fallback path we create a new table and set pte around fault address
> to the newly allocated page. All other ptes set to normal zero page."
> When these zero pages will be replaced by real pages and add memcg charge?

I guess I've answered the question above.

> Look forward to your detail response, thank you! :)

Thanks for your questions.

--=20
 Kirill A. Shutemov

--IJpNTDwzlM2Ie8A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQJONfAAoJEAd+omnVudOMGVYP/0q8qLqr/z7zHB3UWp+HNUUU
VMyZfofyrWzdIvyv1w9cM66Frel5nwWfVIU3TZtLFEAQPslmkAJijQcoaQ1MnMd+
dDD+ExeL8PcA8TFBzqR+BwL9zgQyXXUgAZiRkHqeKsaxMkrcnP6fYnQyCDczfUqC
F7MwOdXEP1EPUuAgBHf5dYncMdIqeA+uI+vsaMHZSme8qE+n3qR4x86GdPJRIGY0
ZJTSL0f6a1vDcCI0RyCLpTALVtZa7AFFrp0jH20sPaeTnLjqPFbjv8JUX4mMGAnq
P+BlTzRkdDGM6CKNCagIEUecbabXC04QQz59i1J86dhaupyWSxSKN7d0R/S43kJN
kDWGHdrqDIcVUxzlqvLQd7SKJPLMMv6ke9VXj/DIgoSbpaIDgoD/3f7haSFcA8rL
r9EiaVaGjtietOwsHSS8qnvn6VlEndvZqVsArIbAT9vIclgJZzZ8sM9AN8nB1mXx
veZ0kqU2Ik84VLWhlEY/MvRLZqg2pABQC3RhJ2ZdCqG4c5eFitsp+T9GPvs51j9n
a2rlhehPqADaM6D1MpJYobOlWzNYYFyouk0/drmTY8IqhSfvO+y/oJmFpeBk5ev9
DDk1lK4ZSxN3HxymZ+CvdptbPECOh5DYC6JNjEEtazM1IbGZbgX46/YOFqE2hKeS
zwjK7kipnPUrmebVatV9
=I99G
-----END PGP SIGNATURE-----

--IJpNTDwzlM2Ie8A6--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
