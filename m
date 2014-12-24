Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id C9C816B00B3
	for <linux-mm@kvack.org>; Wed, 24 Dec 2014 07:29:52 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so9902723pdb.38
        for <linux-mm@kvack.org>; Wed, 24 Dec 2014 04:29:52 -0800 (PST)
Received: from smtprelay.synopsys.com (smtprelay2.synopsys.com. [198.182.60.111])
        by mx.google.com with ESMTPS id we8si34431112pab.27.2014.12.24.04.29.50
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Dec 2014 04:29:51 -0800 (PST)
From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Subject: Re: [PATCH 10/38] arc: drop _PAGE_FILE and pte_file()-related
 helpers
Date: Wed, 24 Dec 2014 12:29:44 +0000
Message-ID: <C2D7FE5348E1B147BCA15975FBA2307565BC95FE@IN01WEMBXA.internal.synopsys.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1419423766-114457-11-git-send-email-kirill.shutemov@linux.intel.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "peterz@infradead.org" <peterz@infradead.org>, "mingo@kernel.org" <mingo@kernel.org>, "davej@redhat.com" <davej@redhat.com>, "sasha.levin@oracle.com" <sasha.levin@oracle.com>, "hughd@google.com" <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Vineet Gupta <Vineet.Gupta1@synopsys.com>

Hi Kirill,=0A=
=0A=
On Wednesday 24 December 2014 05:54 PM, Kirill A. Shutemov wrote:=0A=
> We've replaced remap_file_pages(2) implementation with emulation.=0A=
> Nobody creates non-linear mapping anymore.=0A=
>=0A=
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>=0A=
> Cc: Vineet Gupta <vgupta@synopsys.com>=0A=
> ---=0A=
>  arch/arc/include/asm/pgtable.h | 15 ++-------------=0A=
>  1 file changed, 2 insertions(+), 13 deletions(-)=0A=
>=0A=
> diff --git a/arch/arc/include/asm/pgtable.h b/arch/arc/include/asm/pgtabl=
e.h=0A=
> index 6b0b7f7ef783..55694ee428d4 100644=0A=
> --- a/arch/arc/include/asm/pgtable.h=0A=
> +++ b/arch/arc/include/asm/pgtable.h=0A=
> @@ -61,7 +61,6 @@=0A=
>  #define _PAGE_WRITE         (1<<4)	/* Page has user write perm (H) */=0A=
>  #define _PAGE_READ          (1<<5)	/* Page has user read perm (H) */=0A=
>  #define _PAGE_MODIFIED      (1<<6)	/* Page modified (dirty) (S) */=0A=
> -#define _PAGE_FILE          (1<<7)	/* page cache/ swap (S) */=0A=
>  #define _PAGE_GLOBAL        (1<<8)	/* Page is global (H) */=0A=
>  #define _PAGE_PRESENT       (1<<10)	/* TLB entry is valid (H) */=0A=
>  =0A=
> @@ -73,7 +72,6 @@=0A=
>  #define _PAGE_READ          (1<<3)	/* Page has user read perm (H) */=0A=
>  #define _PAGE_ACCESSED      (1<<4)	/* Page is accessed (S) */=0A=
>  #define _PAGE_MODIFIED      (1<<5)	/* Page modified (dirty) (S) */=0A=
> -#define _PAGE_FILE          (1<<6)	/* page cache/ swap (S) */=0A=
>  #define _PAGE_GLOBAL        (1<<8)	/* Page is global (H) */=0A=
>  #define _PAGE_PRESENT       (1<<9)	/* TLB entry is valid (H) */=0A=
>  #define _PAGE_SHARED_CODE   (1<<11)	/* Shared Code page with cmn vaddr=
=0A=
> @@ -268,15 +266,6 @@ static inline void pmd_set(pmd_t *pmdp, pte_t *ptep)=
=0A=
>  	pte;								\=0A=
>  })=0A=
>  =0A=
> -/* TBD: Non linear mapping stuff */=0A=
> -static inline int pte_file(pte_t pte)=0A=
> -{=0A=
> -	return pte_val(pte) & _PAGE_FILE;=0A=
> -}=0A=
> -=0A=
> -#define PTE_FILE_MAX_BITS	30=0A=
> -#define pgoff_to_pte(x)         __pte(x)=0A=
> -#define pte_to_pgoff(x)		(pte_val(x) >> 2)=0A=
>  #define pte_pfn(pte)		(pte_val(pte) >> PAGE_SHIFT)=0A=
>  #define pfn_pte(pfn, prot)	(__pte(((pfn) << PAGE_SHIFT) | pgprot_val(pro=
t)))=0A=
>  #define __pte_index(addr)	(((addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1))=
=0A=
> @@ -358,13 +347,13 @@ static inline void set_pte_at(struct mm_struct *mm,=
 unsigned long addr,=0A=
>  #endif=0A=
>  =0A=
>  extern void paging_init(void);=0A=
> -extern pgd_t swapper_pg_dir[] __aligned(PAGE_SIZE);=0A=
> +xtern pgd_t swapper_pg_dir[] __aligned(PAGE_SIZE);=0A=
=0A=
I don't think u intended that. Otherwise=0A=
=0A=
Acked-by: Vineet Gupta <vgupta@synopsys.com>=0A=
=0A=
Thx,=0A=
-Vineet=0A=
=0A=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
