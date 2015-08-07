Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f169.google.com (mail-qk0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 86DF46B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 06:33:46 -0400 (EDT)
Received: by qkdg63 with SMTP id g63so35430058qkd.0
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 03:33:46 -0700 (PDT)
Received: from prod-mail-xrelay06.akamai.com (prod-mail-xrelay06.akamai.com. [96.6.114.98])
        by mx.google.com with ESMTP id l66si17233064qgl.9.2015.08.07.03.33.45
        for <linux-mm@kvack.org>;
        Fri, 07 Aug 2015 03:33:45 -0700 (PDT)
Date: Fri, 7 Aug 2015 19:33:37 +0900
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [PATCH V6 3/6] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150807103337.GB4750@akamai.com>
References: <1438184575-10537-1-git-send-email-emunson@akamai.com>
 <1438184575-10537-4-git-send-email-emunson@akamai.com>
 <55C37E62.6020909@suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="PmA2V3Z32TCmWXqI"
Content-Disposition: inline
In-Reply-To: <55C37E62.6020909@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org


--PmA2V3Z32TCmWXqI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 06 Aug 2015, Vlastimil Babka wrote:

=2E..
> >
> >diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> >index ca1e091..38d69fc 100644
> >--- a/fs/proc/task_mmu.c
> >+++ b/fs/proc/task_mmu.c
> >@@ -579,6 +579,7 @@ static void show_smap_vma_flags(struct seq_file *m, =
struct vm_area_struct *vma)
>=20
> This function has the following comment:
>=20
> Don't forget to update Documentation/ on changes.
>=20
> [...]
>=20
> >--- a/mm/gup.c
> >+++ b/mm/gup.c
> >@@ -92,7 +92,7 @@ retry:
> >  		 */
> >  		mark_page_accessed(page);
> >  	}
> >-	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
> >+	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
> >  		/*
> >  		 * The preliminary mapping check is mainly to avoid the
> >  		 * pointless overhead of lock_page on the ZERO_PAGE
> >@@ -265,6 +265,9 @@ static int faultin_page(struct task_struct *tsk, str=
uct vm_area_struct *vma,
> >  	unsigned int fault_flags =3D 0;
> >  	int ret;
> >
> >+	/* mlock all present pages, but do not fault in new pages */
> >+	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) =3D=3D FOLL_MLOCK)
> >+		return -ENOENT;
> >  	/* For mm_populate(), just skip the stack guard page. */
> >  	if ((*flags & FOLL_POPULATE) &&
> >  			(stack_guard_page_start(vma, address) ||
> >@@ -850,7 +853,10 @@ long populate_vma_page_range(struct vm_area_struct =
*vma,
> >  	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
> >  	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
> >
> >-	gup_flags =3D FOLL_TOUCH | FOLL_POPULATE;
> >+	gup_flags =3D FOLL_TOUCH | FOLL_MLOCK;
> >+	if ((vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) =3D=3D VM_LOCKED)
> >+		gup_flags |=3D FOLL_POPULATE;
> >+
> >  	/*
> >  	 * We want to touch writable mappings with a write fault in order
> >  	 * to break COW, except for shared mappings because these don't COW
>=20
> I think this might be breaking the populate part of
> mmap(MAP_POPULATE & ~MAP_LOCKED) case, if I follow the execution
> correctly (it's far from simple...)
>=20
> SYSCALL_DEFINE6(mmap_pgoff... with MAP_POPULATE
>   vm_mmap_pgoff(..., MAP_POPULATE...)
>     do_mmap_pgoff(...MAP_POPULATE... &populate) -> populate =3D=3D TRUE
>     mm_populate()
>       __mm_populate()
>         populate_vma_page_range()
>=20
> Previously, this path would have FOLL_POPULATE in gup_flags and
> continue with __get_user_pages() and faultin_page() (actually
> regardless of FOLL_POPULATE) which would fault in the pages.
>=20
> After your patch, populate_vma_page_range() will set FOLL_MLOCK, but
> since VM_LOCKED is not set, FOLL_POPULATE won't be set either.
> Then faultin_page() will return on the new check:
>=20
> 	flags & (FOLL_POPULATE | FOLL_MLOCK)) =3D=3D FOLL_MLOCK
>=20
>=20

I am on vacation atm but I will try and get to respin this series after
making sure there aren't any more FOLL flag issues.

Thanks for keeping with these :)

Eric

--PmA2V3Z32TCmWXqI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVxImBAAoJELbVsDOpoOa99aYQAMz2BYFE1TQ9i/Bwqi5B2nY4
99AnNaCUJogfUaXufmoe5yskDYie6avS0xELcMAwx4AKQ9l5+Qj9qL8xCGUsjcMy
+z5JciZ6mvxRrOeIxMRnPerUnqQZt5gZBQO1iUTiq1YMGuIKfeXbojTPlGC+FOin
5vB6x46Icy8YWM35eSblh3yhfOupAfcHaOZG0CuZ1Z1mCeiPfXJnv2Jpj5B/GsD+
HHeMTNQrSLNl3fdX+vyV0EtL8rJY764HqcOxk20ugogF2/oObZynmG3zTdZ2Hp3k
WpTXL6//9bkLrV8ogiJIml2o5bZaSVLS4rkDKEMCgksU69Q87P2NvKrWASrGzp2d
XiPV5c+cgT5DRXcgdz0VFT03/cT8nywNfmQwFi+AbzX4KKnq8wJ8sR8Ayp6p0fpL
DGAFEcVun8wUmt3EDuxL/Y5hMxd/oifP2O6xxFE9PMJfpGpU9TT+XScaQnjzp2Qw
pKiFijJGzRk1ouGErCnUUbsOOe1FsQFgDMBf4cGZBhNWfvuwcYIg3BgvJ1VeFf1/
Za9H51pwLQcoM+ix+9/gkFMH7FuTLspTrxoF/bgJLNMeDiVGTXtrDdCUpN3eO0aV
taAJuwBPuAp/LOEp+O9WB4o2OIz6YDTjiy22hh+f/yowP62iBys6YJExpJ1lMbWR
lXiVSOULwU586t/8L0oN
=Ofwh
-----END PGP SIGNATURE-----

--PmA2V3Z32TCmWXqI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
