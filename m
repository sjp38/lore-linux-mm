Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 536EF8E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 16:30:06 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id l11-v6so22125594qkk.0
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 13:30:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q78-v6sor7429840qka.24.2018.09.11.13.30.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Sep 2018 13:30:05 -0700 (PDT)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH] mm, thp: Fix mlocking THP page with migration enabled
Date: Tue, 11 Sep 2018 16:30:02 -0400
Message-ID: <5E196C27-3D56-4D76-B361-0665CB3790BF@cs.rutgers.edu>
In-Reply-To: <20180911103403.38086-1-kirill.shutemov@linux.intel.com>
References: <20180911103403.38086-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_F56E6C2A-13C4-4D7A-96AB-E3BCB22C8184_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vegard Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_F56E6C2A-13C4-4D7A-96AB-E3BCB22C8184_=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Kirill,

On 11 Sep 2018, at 6:34, Kirill A. Shutemov wrote:

> A transparent huge page is represented by a single entry on an LRU list=
=2E
> Therefore, we can only make unevictable an entire compound page, not
> individual subpages.
>
> If a user tries to mlock() part of a huge page, we want the rest of the=

> page to be reclaimable.
>
> We handle this by keeping PTE-mapped huge pages on normal LRU lists: th=
e
> PMD on border of VM_LOCKED VMA will be split into PTE table.
>
> Introduction of THP migration breaks the rules around mlocking THP
> pages. If we had a single PMD mapping of the page in mlocked VMA, the
> page will get mlocked, regardless of PTE mappings of the page.
>
> For tmpfs/shmem it's easy to fix by checking PageDoubleMap() in
> remove_migration_pmd().
>
> Anon THP pages can only be shared between processes via fork(). Mlocked=

> page can only be shared if parent mlocked it before forking, otherwise
> CoW will be triggered on mlock().
>
> For Anon-THP, we can fix the issue by munlocking the page on removing P=
TE
> migration entry for the page. PTEs for the page will always come after
> mlocked PMD: rmap walks VMAs from oldest to newest.
>
> Test-case:
>
> 	#include <unistd.h>
> 	#include <sys/mman.h>
> 	#include <sys/wait.h>
> 	#include <linux/mempolicy.h>
> 	#include <numaif.h>
>
> 	int main(void)
> 	{
> 	        unsigned long nodemask =3D 4;
> 	        void *addr;
>
> 		addr =3D mmap((void *)0x20000000UL, 2UL << 20, PROT_READ | PROT_WRITE=
,
> 			MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKED, -1, 0);
>
> 	        if (fork()) {
> 			wait(NULL);
> 			return 0;
> 	        }
>
> 	        mlock(addr, 4UL << 10);
> 	        mbind(addr, 2UL << 20, MPOL_PREFERRED | MPOL_F_RELATIVE_NODES,=

> 	                &nodemask, 4, MPOL_MF_MOVE | MPOL_MF_MOVE_ALL);
>
> 	        return 0;
> 	}
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
> Fixes: 616b8371539a ("mm: thp: enable thp migration in generic path")
> Cc: <stable@vger.kernel.org> [v4.14+]
> Cc: Zi Yan <zi.yan@cs.rutgers.edu>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/huge_memory.c | 2 +-
>  mm/migrate.c     | 3 +++
>  2 files changed, 4 insertions(+), 1 deletion(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 533f9b00147d..00704060b7f7 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2931,7 +2931,7 @@ void remove_migration_pmd(struct page_vma_mapped_=
walk *pvmw, struct page *new)
>  	else
>  		page_add_file_rmap(new, true);
>  	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
> -	if (vma->vm_flags & VM_LOCKED)
> +	if ((vma->vm_flags & VM_LOCKED) && !PageDoubleMap(new))
>  		mlock_vma_page(new);
>  	update_mmu_cache_pmd(vma, address, pvmw->pmd);
>  }
> diff --git a/mm/migrate.c b/mm/migrate.c
> index d6a2e89b086a..01dad96b25b5 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -275,6 +275,9 @@ static bool remove_migration_pte(struct page *page,=
 struct vm_area_struct *vma,
>  		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
>  			mlock_vma_page(new);
>
> +		if (PageTransCompound(new) && PageMlocked(page))
> +			clear_page_mlock(page);
> +
>  		/* No need to invalidate - it was non-present before */
>  		update_mmu_cache(vma, pvmw.address, pvmw.pte);
>  	}
> -- =

> 2.18.0

Thanks for your patch. It fixes the mlock problem demonstrated by your te=
st program.

I want to understand the Anon THP part of the problem more clearly. For A=
non THPs,
you said, PTEs for the page will always come after mlocked PMD. I just wo=
nder that if
a process forks a child1 which forks its own child2 and the child1 mlocks=
 a subpage causing
split_pmd_page() and migrates its PTE-mapped THP, will the kernel see the=
 sequence of PMD-mapped THP,
PTE-mapped THP, and PMD-mapped THP while walking VMAs? Will the second PM=
D-mapped THP
reset the mlock on the page?

In addition, I also discover that PageDoubleMap is not set for double map=
ped Anon THPs after migration,
the following patch fixes it. Do you want me to send it separately or you=
 can merge it
with your patch?

diff --git a/mm/rmap.c b/mm/rmap.c
index eb477809a5c0..defe8fc265e3 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1121,6 +1121,16 @@ void do_page_add_anon_rmap(struct page *page,
                 */
                if (compound)
                        __inc_node_page_state(page, NR_ANON_THPS);
+               else {
+                       if (PageTransCompound(page) && compound_mapcount(=
page) > 0) {
+                               struct page *head =3D compound_head(page)=
;
+                               int i;
+
+                               SetPageDoubleMap(head);
+                               for (i =3D 0; i < HPAGE_PMD_NR; i++)
+                                       atomic_inc(&head[i]._mapcount);
+                       }
+               }
                __mod_node_page_state(page_pgdat(page), NR_ANON_MAPPED, n=
r);
        }
        if (unlikely(PageKsm(page)))

=E2=80=94
Best Regards,
Yan Zi

--=_MailMate_F56E6C2A-13C4-4D7A-96AB-E3BCB22C8184_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----

iQFKBAEBCgA0FiEEOXBxLIohamfZUwd5QYsvEZxOpswFAluYJcoWHHppLnlhbkBj
cy5ydXRnZXJzLmVkdQAKCRBBiy8RnE6mzBKSB/9rtfp7XzaFZe4W1J/lzjPZvoy2
xisHmr4+5FNTaEfdiev9t4e/TYtpHr/1IgCtn59dzwXUtQnsEFF0fWLvGqTgJP5/
6KULctGIlJfzHTBxWckD4Jz7aqFuRe9L2abMqr2zlegAdpDsGQGLKZhm7oQ7Pq+Q
1MVM6GNizdJfyRpIrdaq3pfrYk0emj07K6d+WwGR+VKSbiMMIDWK/GqPwOL8pCCv
zFpl6aTeZKda5TS4nXsF5pHCrVb4Ig2Cpgeoo5AiKOFTSxlhf7oDHUK4SG96TQxe
XgX33CllJX7kKRxpMvJEorH/tCAXxWVqE7KCj0XYpeJr7mhd4CK/njSpK4wn
=9ZTQ
-----END PGP SIGNATURE-----

--=_MailMate_F56E6C2A-13C4-4D7A-96AB-E3BCB22C8184_=--
