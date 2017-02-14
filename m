Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14F016B0387
	for <linux-mm@kvack.org>; Mon, 13 Feb 2017 22:58:57 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id j82so191072719ybg.0
        for <linux-mm@kvack.org>; Mon, 13 Feb 2017 19:58:56 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id 20si11859215pfu.287.2017.02.13.19.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 Feb 2017 19:58:55 -0800 (PST)
Message-ID: <1487044732.21048.23.camel@neuling.org>
Subject: Re: [PATCH 1/2] mm/autonuma: Let architecture override how the
 write bit should be stashed in a protnone pte.
From: Michael Neuling <mikey@neuling.org>
Date: Tue, 14 Feb 2017 14:58:52 +1100
In-Reply-To: <1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: 
	<1486609259-6796-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

On Thu, 2017-02-09 at 08:30 +0530, Aneesh Kumar K.V wrote:
> Autonuma preserves the write permission across numa fault to avoid taking
> a writefault after a numa fault (Commit: b191f9b106ea " mm: numa: preserv=
e PTE
> write permissions across a NUMA hinting fault"). Architecture can impleme=
nt
> protnone in different ways and some may choose to implement that by clear=
ing
> Read/
> Write/Exec bit of pte. Setting the write bit on such pte can result in wr=
ong
> behaviour. Fix this up by allowing arch to override how to save the write=
 bit
> on a protnone pte.
>=20
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

FWIW this is pretty simple and helps with us in powerpc...

Acked-By: Michael Neuling <mikey@neuling.org>

> ---
> =C2=A0include/asm-generic/pgtable.h | 16 ++++++++++++++++
> =C2=A0mm/huge_memory.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A04 ++--
> =C2=A0mm/memory.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A02 =
+-
> =C2=A0mm/mprotect.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0|=C2=A0=C2=A04 ++--
> =C2=A04 files changed, 21 insertions(+), 5 deletions(-)
>=20
> diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.=
h
> index 18af2bcefe6a..b6f3a8a4b738 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -192,6 +192,22 @@ static inline void ptep_set_wrprotect(struct mm_stru=
ct
> *mm, unsigned long addres
> =C2=A0}
> =C2=A0#endif
> =C2=A0
> +#ifndef pte_savedwrite
> +#define pte_savedwrite pte_write
> +#endif
> +
> +#ifndef pte_mk_savedwrite
> +#define pte_mk_savedwrite pte_mkwrite
> +#endif
> +
> +#ifndef pmd_savedwrite
> +#define pmd_savedwrite pmd_write
> +#endif
> +
> +#ifndef pmd_mk_savedwrite
> +#define pmd_mk_savedwrite pmd_mkwrite
> +#endif
> +
> =C2=A0#ifndef __HAVE_ARCH_PMDP_SET_WRPROTECT
> =C2=A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> =C2=A0static inline void pmdp_set_wrprotect(struct mm_struct *mm,
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9a6bd6c8d55a..2f0f855ec911 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1300,7 +1300,7 @@ int do_huge_pmd_numa_page(struct vm_fault *vmf, pmd=
_t
> pmd)
> =C2=A0	goto out;
> =C2=A0clear_pmdnuma:
> =C2=A0	BUG_ON(!PageLocked(page));
> -	was_writable =3D pmd_write(pmd);
> +	was_writable =3D pmd_savedwrite(pmd);
> =C2=A0	pmd =3D pmd_modify(pmd, vma->vm_page_prot);
> =C2=A0	pmd =3D pmd_mkyoung(pmd);
> =C2=A0	if (was_writable)
> @@ -1555,7 +1555,7 @@ int change_huge_pmd(struct vm_area_struct *vma, pmd=
_t
> *pmd,
> =C2=A0			entry =3D pmdp_huge_get_and_clear_notify(mm, addr,
> pmd);
> =C2=A0			entry =3D pmd_modify(entry, newprot);
> =C2=A0			if (preserve_write)
> -				entry =3D pmd_mkwrite(entry);
> +				entry =3D pmd_mk_savedwrite(entry);
> =C2=A0			ret =3D HPAGE_PMD_NR;
> =C2=A0			set_pmd_at(mm, addr, pmd, entry);
> =C2=A0			BUG_ON(vma_is_anonymous(vma) && !preserve_write &&
> diff --git a/mm/memory.c b/mm/memory.c
> index e78bf72f30dd..88c24f89d6d3 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -3388,7 +3388,7 @@ static int do_numa_page(struct vm_fault *vmf)
> =C2=A0	int target_nid;
> =C2=A0	bool migrated =3D false;
> =C2=A0	pte_t pte;
> -	bool was_writable =3D pte_write(vmf->orig_pte);
> +	bool was_writable =3D pte_savedwrite(vmf->orig_pte);
> =C2=A0	int flags =3D 0;
> =C2=A0
> =C2=A0	/*
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index f9c07f54dd62..15f5c174a7c1 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -113,13 +113,13 @@ static unsigned long change_pte_range(struct
> vm_area_struct *vma, pmd_t *pmd,
> =C2=A0			ptent =3D ptep_modify_prot_start(mm, addr, pte);
> =C2=A0			ptent =3D pte_modify(ptent, newprot);
> =C2=A0			if (preserve_write)
> -				ptent =3D pte_mkwrite(ptent);
> +				ptent =3D pte_mk_savedwrite(ptent);
> =C2=A0
> =C2=A0			/* Avoid taking write faults for known dirty pages */
> =C2=A0			if (dirty_accountable && pte_dirty(ptent) &&
> =C2=A0					(pte_soft_dirty(ptent) ||
> =C2=A0					=C2=A0!(vma->vm_flags & VM_SOFTDIRTY))) {
> -				ptent =3D pte_mkwrite(ptent);
> +				ptent =3D pte_mk_savedwrite(ptent);
> =C2=A0			}
> =C2=A0			ptep_modify_prot_commit(mm, addr, pte, ptent);
> =C2=A0			pages++;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
