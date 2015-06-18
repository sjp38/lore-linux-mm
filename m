Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 829B66B0081
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 16:30:51 -0400 (EDT)
Received: by paceq1 with SMTP id eq1so44122093pac.3
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 13:30:51 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id mq6si12691817pbb.191.2015.06.18.13.30.49
        for <linux-mm@kvack.org>;
        Thu, 18 Jun 2015 13:30:50 -0700 (PDT)
Date: Thu, 18 Jun 2015 16:30:48 -0400
From: Eric B Munson <emunson@akamai.com>
Subject: Re: [RESEND PATCH V2 1/3] Add mmap flag to request pages are locked
 after page fault
Message-ID: <20150618203048.GB2329@akamai.com>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
 <1433942810-7852-2-git-send-email-emunson@akamai.com>
 <20150618152907.GG5858@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="WhfpMioaduB5tiZL"
Content-Disposition: inline
In-Reply-To: <20150618152907.GG5858@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org


--WhfpMioaduB5tiZL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, 18 Jun 2015, Michal Hocko wrote:

> [Sorry for the late reply - I meant to answer in the previous threads
>  but something always preempted me from that]
>=20
> On Wed 10-06-15 09:26:48, Eric B Munson wrote:
> > The cost of faulting in all memory to be locked can be very high when
> > working with large mappings.  If only portions of the mapping will be
> > used this can incur a high penalty for locking.
> >=20
> > For the example of a large file, this is the usage pattern for a large
> > statical language model (probably applies to other statical or graphical
> > models as well).  For the security example, any application transacting
> > in data that cannot be swapped out (credit card data, medical records,
> > etc).
>=20
> Such a use case makes some sense to me but I am not sure the way you
> implement it is the right one. This is another mlock related flag for
> mmap with a different semantic. You do not want to prefault but e.g. is
> the readahead or fault around acceptable? I do not see anything in your
> patch to handle those...

We haven't bumped into readahead or fault around causing performance
problems for us.  If they cause problems for users when LOCKONFAULT is
in use then we can address them.

>=20
> Wouldn't it be much more reasonable and straightforward to have
> MAP_FAULTPOPULATE as a counterpart for MAP_POPULATE which would
> explicitly disallow any form of pre-faulting? It would be usable for
> other usecases than with MAP_LOCKED combination.

I don't see a clear case for it being more reasonable, it is one
possible way to solve the problem.  But I think it leaves us in an even
more akward state WRT VMA flags.  As you noted in your fix for the
mmap() man page, one can get into a state where a VMA is VM_LOCKED, but
not present.  Having VM_LOCKONFAULT states that this was intentional, if
we go to using MAP_FAULTPOPULATE instead of MAP_LOCKONFAULT, we no
longer set VM_LOCKONFAULT (unless we want to start mapping it to the
presence of two MAP_ flags).  This can make detecting the MAP_LOCKED +
populate failure state harder.

If this is the preferred path for mmap(), I am fine with that.  However,
I would like to see the new system calls that Andrew mentioned (and that
I am testing patches for) go in as well.  That way we give users the
ability to request VM_LOCKONFAULT for memory allocated using something
other than mmap.

>=20
> > This patch introduces the ability to request that pages are not
> > pre-faulted, but are placed on the unevictable LRU when they are finally
> > faulted in.
> >=20
> > To keep accounting checks out of the page fault path, users are billed
> > for the entire mapping lock as if MAP_LOCKED was used.
> >=20
> > Signed-off-by: Eric B Munson <emunson@akamai.com>
> > Cc: Michal Hocko <mhocko@suse.cz>
> > Cc: linux-alpha@vger.kernel.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mips@linux-mips.org
> > Cc: linux-parisc@vger.kernel.org
> > Cc: linuxppc-dev@lists.ozlabs.org
> > Cc: sparclinux@vger.kernel.org
> > Cc: linux-xtensa@linux-xtensa.org
> > Cc: linux-mm@kvack.org
> > Cc: linux-arch@vger.kernel.org
> > Cc: linux-api@vger.kernel.org
> > ---
> >  arch/alpha/include/uapi/asm/mman.h   | 1 +
> >  arch/mips/include/uapi/asm/mman.h    | 1 +
> >  arch/parisc/include/uapi/asm/mman.h  | 1 +
> >  arch/powerpc/include/uapi/asm/mman.h | 1 +
> >  arch/sparc/include/uapi/asm/mman.h   | 1 +
> >  arch/tile/include/uapi/asm/mman.h    | 1 +
> >  arch/xtensa/include/uapi/asm/mman.h  | 1 +
> >  include/linux/mm.h                   | 1 +
> >  include/linux/mman.h                 | 3 ++-
> >  include/uapi/asm-generic/mman.h      | 1 +
> >  mm/mmap.c                            | 4 ++--
> >  mm/swap.c                            | 3 ++-
> >  12 files changed, 15 insertions(+), 4 deletions(-)
> >=20
> > diff --git a/arch/alpha/include/uapi/asm/mman.h b/arch/alpha/include/ua=
pi/asm/mman.h
> > index 0086b47..15e96e1 100644
> > --- a/arch/alpha/include/uapi/asm/mman.h
> > +++ b/arch/alpha/include/uapi/asm/mman.h
> > @@ -30,6 +30,7 @@
> >  #define MAP_NONBLOCK	0x40000		/* do not block on IO */
> >  #define MAP_STACK	0x80000		/* give out an address that is best suited =
for process/thread stacks */
> >  #define MAP_HUGETLB	0x100000	/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x200000	/* Lock pages after they are faulted =
in, do not prefault */
> > =20
> >  #define MS_ASYNC	1		/* sync memory asynchronously */
> >  #define MS_SYNC		2		/* synchronous memory sync */
> > diff --git a/arch/mips/include/uapi/asm/mman.h b/arch/mips/include/uapi=
/asm/mman.h
> > index cfcb876..47846a5 100644
> > --- a/arch/mips/include/uapi/asm/mman.h
> > +++ b/arch/mips/include/uapi/asm/mman.h
> > @@ -48,6 +48,7 @@
> >  #define MAP_NONBLOCK	0x20000		/* do not block on IO */
> >  #define MAP_STACK	0x40000		/* give out an address that is best suited =
for process/thread stacks */
> >  #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x100000	/* Lock pages after they are faulted =
in, do not prefault */
> > =20
> >  /*
> >   * Flags for msync
> > diff --git a/arch/parisc/include/uapi/asm/mman.h b/arch/parisc/include/=
uapi/asm/mman.h
> > index 294d251..1514cd7 100644
> > --- a/arch/parisc/include/uapi/asm/mman.h
> > +++ b/arch/parisc/include/uapi/asm/mman.h
> > @@ -24,6 +24,7 @@
> >  #define MAP_NONBLOCK	0x20000		/* do not block on IO */
> >  #define MAP_STACK	0x40000		/* give out an address that is best suited =
for process/thread stacks */
> >  #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x100000	/* Lock pages after they are faulted =
in, do not prefault */
> > =20
> >  #define MS_SYNC		1		/* synchronous memory sync */
> >  #define MS_ASYNC	2		/* sync memory asynchronously */
> > diff --git a/arch/powerpc/include/uapi/asm/mman.h b/arch/powerpc/includ=
e/uapi/asm/mman.h
> > index 6ea26df..fce74fe 100644
> > --- a/arch/powerpc/include/uapi/asm/mman.h
> > +++ b/arch/powerpc/include/uapi/asm/mman.h
> > @@ -27,5 +27,6 @@
> >  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
> >  #define MAP_STACK	0x20000		/* give out an address that is best suited =
for process/thread stacks */
> >  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x80000		/* Lock pages after they are faulted =
in, do not prefault */
> > =20
> >  #endif /* _UAPI_ASM_POWERPC_MMAN_H */
> > diff --git a/arch/sparc/include/uapi/asm/mman.h b/arch/sparc/include/ua=
pi/asm/mman.h
> > index 0b14df3..12425d8 100644
> > --- a/arch/sparc/include/uapi/asm/mman.h
> > +++ b/arch/sparc/include/uapi/asm/mman.h
> > @@ -22,6 +22,7 @@
> >  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
> >  #define MAP_STACK	0x20000		/* give out an address that is best suited =
for process/thread stacks */
> >  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x80000		/* Lock pages after they are faulted =
in, do not prefault */
> > =20
> > =20
> >  #endif /* _UAPI__SPARC_MMAN_H__ */
> > diff --git a/arch/tile/include/uapi/asm/mman.h b/arch/tile/include/uapi=
/asm/mman.h
> > index 81b8fc3..ec04eaf 100644
> > --- a/arch/tile/include/uapi/asm/mman.h
> > +++ b/arch/tile/include/uapi/asm/mman.h
> > @@ -29,6 +29,7 @@
> >  #define MAP_DENYWRITE	0x0800		/* ETXTBSY */
> >  #define MAP_EXECUTABLE	0x1000		/* mark it as an executable */
> >  #define MAP_HUGETLB	0x4000		/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x8000		/* Lock pages after they are faulted i=
n, do not prefault */
> > =20
> > =20
> >  /*
> > diff --git a/arch/xtensa/include/uapi/asm/mman.h b/arch/xtensa/include/=
uapi/asm/mman.h
> > index 201aec0..42d43cc 100644
> > --- a/arch/xtensa/include/uapi/asm/mman.h
> > +++ b/arch/xtensa/include/uapi/asm/mman.h
> > @@ -55,6 +55,7 @@
> >  #define MAP_NONBLOCK	0x20000		/* do not block on IO */
> >  #define MAP_STACK	0x40000		/* give out an address that is best suited =
for process/thread stacks */
> >  #define MAP_HUGETLB	0x80000		/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x100000	/* Lock pages after they are faulted =
in, do not prefault */
> >  #ifdef CONFIG_MMAP_ALLOW_UNINITIALIZED
> >  # define MAP_UNINITIALIZED 0x4000000	/* For anonymous mmap, memory cou=
ld be
> >  					 * uninitialized */
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 0755b9f..3e31457 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -126,6 +126,7 @@ extern unsigned int kobjsize(const void *objp);
> >  #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct pa=
ge", just pure PFN */
> >  #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
> > =20
> > +#define VM_LOCKONFAULT	0x00001000	/* Lock the pages covered when they =
are faulted in */
> >  #define VM_LOCKED	0x00002000
> >  #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
> > =20
> > diff --git a/include/linux/mman.h b/include/linux/mman.h
> > index 16373c8..437264b 100644
> > --- a/include/linux/mman.h
> > +++ b/include/linux/mman.h
> > @@ -86,7 +86,8 @@ calc_vm_flag_bits(unsigned long flags)
> >  {
> >  	return _calc_vm_trans(flags, MAP_GROWSDOWN,  VM_GROWSDOWN ) |
> >  	       _calc_vm_trans(flags, MAP_DENYWRITE,  VM_DENYWRITE ) |
> > -	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    );
> > +	       _calc_vm_trans(flags, MAP_LOCKED,     VM_LOCKED    ) |
> > +	       _calc_vm_trans(flags, MAP_LOCKONFAULT,VM_LOCKONFAULT);
> >  }
> > =20
> >  unsigned long vm_commit_limit(void);
> > diff --git a/include/uapi/asm-generic/mman.h b/include/uapi/asm-generic=
/mman.h
> > index e9fe6fd..fc4e586 100644
> > --- a/include/uapi/asm-generic/mman.h
> > +++ b/include/uapi/asm-generic/mman.h
> > @@ -12,6 +12,7 @@
> >  #define MAP_NONBLOCK	0x10000		/* do not block on IO */
> >  #define MAP_STACK	0x20000		/* give out an address that is best suited =
for process/thread stacks */
> >  #define MAP_HUGETLB	0x40000		/* create a huge page mapping */
> > +#define MAP_LOCKONFAULT	0x80000		/* Lock pages after they are faulted =
in, do not prefault */
> > =20
> >  /* Bits [26:31] are reserved, see mman-common.h for MAP_HUGETLB usage =
*/
> > =20
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index bb50cac..ba1a6bf 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -1233,7 +1233,7 @@ static inline int mlock_future_check(struct mm_st=
ruct *mm,
> >  	unsigned long locked, lock_limit;
> > =20
> >  	/*  mlock MCL_FUTURE? */
> > -	if (flags & VM_LOCKED) {
> > +	if (flags & (VM_LOCKED | VM_LOCKONFAULT)) {
> >  		locked =3D len >> PAGE_SHIFT;
> >  		locked +=3D mm->locked_vm;
> >  		lock_limit =3D rlimit(RLIMIT_MEMLOCK);
> > @@ -1301,7 +1301,7 @@ unsigned long do_mmap_pgoff(struct file *file, un=
signed long addr,
> >  	vm_flags =3D calc_vm_prot_bits(prot) | calc_vm_flag_bits(flags) |
> >  			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
> > =20
> > -	if (flags & MAP_LOCKED)
> > +	if (flags & (MAP_LOCKED | MAP_LOCKONFAULT))
> >  		if (!can_do_mlock())
> >  			return -EPERM;
> > =20
> > diff --git a/mm/swap.c b/mm/swap.c
> > index a7251a8..07c905e 100644
> > --- a/mm/swap.c
> > +++ b/mm/swap.c
> > @@ -711,7 +711,8 @@ void lru_cache_add_active_or_unevictable(struct pag=
e *page,
> >  {
> >  	VM_BUG_ON_PAGE(PageLRU(page), page);
> > =20
> > -	if (likely((vma->vm_flags & (VM_LOCKED | VM_SPECIAL)) !=3D VM_LOCKED)=
) {
> > +	if (likely((vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) =3D=3D 0) ||
> > +		   (vma->vm_flags & VM_SPECIAL)) {
> >  		SetPageActive(page);
> >  		lru_cache_add(page);
> >  		return;
> > --=20
> > 1.9.1
> >=20
>=20
> --=20
> Michal Hocko
> SUSE Labs

--WhfpMioaduB5tiZL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVgyp4AAoJELbVsDOpoOa9kdsQAJZLqaF1u5hI3XO+tpM5P/hk
Aa1VfdcpEBg27WM9YEVF6bwEOTEGmu50fzkMURr71dqw0SQIkXXxn+IKBF309tF2
CCqll9Yau9+XHZmuvABXGr6WSBKl5Vo7JSZ9OUiGvDYN44Qj1Qc1npw29rDss5OF
FV537cKdnrcaiX12TLFIyfl/tOQEl26ZUyewH+V6FPQsDblP+Um5UOJmjz0B5RT6
pBk8Guz36NYtCUouOMuPSy0aI/Lmss9LQIDNJJ3P3cFC04duWXKCNXyX8dV7YBbT
uLJZSrTBI4bkIzO6h4iQQEJ/ZApI9A0PaB43uypsehjnbnsS4TIc47yNIcnNWVi/
0+8KcUGdruh4SANSQdgCoQW51v8R3rhjAF1P/oqsZhL4yRffp6jJ03/olkR5myi5
mLvW+P0+TrnCTAqYp7ztV66pCagufjSA+JI1ZKe6Sm68dIzdGEA47nftVuLRwSe5
26QMiMMdyIibK0M01Uy50DOJi9CNBny3o2hStcRz+IbbhFh8qegUBJDEXQkGKy4k
MzjcLRihmWO5dNNLjmdsu7tMcYD95VJtWDFpvGszt1coKPkuyQmD6eL+YoIbfuOs
Zahv7yrHDLq32DZBvJ3z6HnH0F9HttksnsnZYkABLmJv8DLj5HJjSg85dC1+1nGo
W38/v4H0T6dmB/3AN1Q3
=kvxI
-----END PGP SIGNATURE-----

--WhfpMioaduB5tiZL--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
