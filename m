Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1129003C7
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:11:35 -0400 (EDT)
Received: by qkdl129 with SMTP id l129so153827177qkd.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 07:11:35 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id z89si1790956qge.29.2015.07.22.07.11.33
        for <linux-mm@kvack.org>;
        Wed, 22 Jul 2015 07:11:34 -0700 (PDT)
Date: Wed, 22 Jul 2015 10:11:33 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V4 3/6] mm: gup: Add mm_lock_present()
Message-ID: <20150722141133.GC2859@akamai.com>
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-4-git-send-email-emunson@akamai.com>
 <20150722111317.GB8630@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fig2xvG2VGoz8o/s"
Content-Disposition: inline
In-Reply-To: <20150722111317.GB8630@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


--Fig2xvG2VGoz8o/s
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 22 Jul 2015, Kirill A. Shutemov wrote:

> On Tue, Jul 21, 2015 at 03:59:38PM -0400, Eric B Munson wrote:
> > The upcoming mlock(MLOCK_ONFAULT) implementation will need a way to
> > request that all present pages in a range are locked without faulting in
> > pages that are not present.  This logic is very close to what the
> > __mm_populate() call handles without faulting pages so the patch pulls
> > out the pieces that can be shared and adds mm_lock_present() to gup.c.
> > The following patch will call it from do_mlock() when MLOCK_ONFAULT is
> > specified.
> >=20
> > Signed-off-by: Eric B Munson <emunson@akamai.com>
> > Cc: Jonathan Corbet <corbet@lwn.net>
> > Cc: Vlastimil Babka <vbabka@suse.cz>
> > Cc: linux-mm@kvack.org
> > Cc: linux-kernel@vger.kernel.org
> > ---
> >  mm/gup.c | 172 +++++++++++++++++++++++++++++++++++++++++++++++++++++++=
++------
> >  1 file changed, 157 insertions(+), 15 deletions(-)
>=20
> I don't like that you've copy-pasted a lot of code. I think it can be
> solved with new foll flags.
>=20
> Totally untested patch below split out mlock part of FOLL_POPULATE into
> new FOLL_MLOCK flag. FOLL_POPULATE | FOLL_MLOCK will do what currently
> FOLL_POPULATE does. The new MLOCK_ONFAULT can use just FOLL_MLOCK. It will
> not trigger fault in.

I originally tried to do this by adding a check for VM_LOCKONFAULT in
__get_user_pages() before the call to faultin_page() which would goto
next_page if LOCKONFAULT was specified.  With the early out in
__get_user_pages(), all of the tests using lock on fault failed to lock
pages.  I will try with a new FOLL flag and see if that can work out.

>=20
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index c3a2b37365f6..c3834cddfcc7 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -2002,6 +2002,7 @@ static inline struct page *follow_page(struct vm_ar=
ea_struct *vma,
>  #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
>  #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry=
 */
>  #define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
> +#define FOLL_MLOCK	0x1000	/* mlock the page if the VMA is VM_LOCKED */
> =20
>  typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>  			void *data);
> diff --git a/mm/gup.c b/mm/gup.c
> index a798293fc648..4c7ff23947b9 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -129,7 +129,7 @@ retry:
>  		 */
>  		mark_page_accessed(page);
>  	}
> -	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
> +	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
>  		/*
>  		 * The preliminary mapping check is mainly to avoid the
>  		 * pointless overhead of lock_page on the ZERO_PAGE
> @@ -299,6 +299,9 @@ static int faultin_page(struct task_struct *tsk, stru=
ct vm_area_struct *vma,
>  	unsigned int fault_flags =3D 0;
>  	int ret;
> =20
> +	/* mlock present pages, but not fault in new one */
> +	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) =3D=3D FOLL_MLOCK)
> +		return -ENOENT;
>  	/* For mm_populate(), just skip the stack guard page. */
>  	if ((*flags & FOLL_POPULATE) &&
>  			(stack_guard_page_start(vma, address) ||
> @@ -890,7 +893,7 @@ long populate_vma_page_range(struct vm_area_struct *v=
ma,
>  	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
>  	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
> =20
> -	gup_flags =3D FOLL_TOUCH | FOLL_POPULATE;
> +	gup_flags =3D FOLL_TOUCH | FOLL_POPULATE | FOLL_MLOCK;
>  	/*
>  	 * We want to touch writable mappings with a write fault in order
>  	 * to break COW, except for shared mappings because these don't COW
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 8f9a334a6c66..9eeb3bd304fc 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1306,7 +1306,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_s=
truct *vma,
>  					  pmd, _pmd,  1))
>  			update_mmu_cache_pmd(vma, addr, pmd);
>  	}
> -	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
> +	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
>  		if (page->mapping && trylock_page(page)) {
>  			lru_add_drain();
>  			if (page->mapping)
>=20
> --=20
>  Kirill A. Shutemov

--Fig2xvG2VGoz8o/s
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVr6SVAAoJELbVsDOpoOa9j8kP/RJLC+EZgFfMxCpFlIXKvwjU
yuYXY2Hzf6P5NWo5XtiC2WhM5KGiEs016MULrVVLasaJ2gADceLqfW/UjP+l2KZF
jj7FPV1WQ+PBtRCKhjh/tsbMJwEtWvgPx+dbNC9zdQRnO1QLz5N/KOB7fE4qvg/g
tyV3wNGbIVOLmqB13KdEX5gOk9CDeVb/wOJhHtnUdSycZzG2+SqVpYhVmUBNrUE0
CLxV7PU/Ip054O8g8ZXbTPL8cmfI6+zNO4n1fehM4+OTmctiZ7/jkcMiCmp14GBV
Cstqv6ib7u9aH/pGHMMSo9NiAaPwsorA92zPZRQJFIerDU+xVg8TQoTuIAW8EeJd
Whm263bLbHTSIwS4YMnI9PM2Q4syY6umP5LASdCNxfQH6KuqeFdbmLHpSmuAAnDa
svhZ4xnhsBx3Q7xDu5p+UzREBAk0wPHctr15W7ZIDuIqolwFr922CsQZj4fwmTov
ZR1OtQrxFgySOt2NcvZlOlkkPTv4XCoA7kbwSrhjp9KdXuGph2S/vP+6xUWuif/L
JfLuN8aFz4ToHk44j9CbR0s4w27ANSmX4AETUk3X1N6yLguh2u6MsZ3TrZiNoeQ7
3Ljl5NWq9CEDRRI5OG0h7913qEyeOq3qKfBnek830vYSWzgklh7lixV1UF6C7wxi
ugXxVvbSI9TmLop+N+kO
=aE18
-----END PGP SIGNATURE-----

--Fig2xvG2VGoz8o/s--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
