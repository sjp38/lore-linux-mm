Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6D73B8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 18:27:01 -0400 (EDT)
Received: by qyk30 with SMTP id 30so5347413qyk.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 15:26:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTim8nHe1jXagKg-5g0ZLh7J61LzAi0ww__Kgaerx@mail.gmail.com>
References: <AANLkTim8nHe1jXagKg-5g0ZLh7J61LzAi0ww__Kgaerx@mail.gmail.com>
Date: Mon, 14 Mar 2011 23:26:58 +0100
Message-ID: <AANLkTi=C-LRv_aRAc9mpdMJXkyGEQLtYQ_E82hwYUjgi@mail.gmail.com>
Subject: Re: [RFC][PATCH v2 21/23] (um) __vmalloc: add gfp flags variant of
 pte and pmd allocation
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Prasad Joshi <prasadjoshi124@gmail.com>
Cc: Jeff Dike <jdike@addtoit.com>, Tejun Heo <tj@kernel.org>, user-mode-linux-devel@lists.sourceforge.net, UML Mailing List <user-mode-linux-user@lists.sourceforge.net>, Anand Mitra <mitra@kqinfotech.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org

On Mon, Mar 14, 2011 at 7:12 PM, Prasad Joshi <prasadjoshi124@gmail.com> wr=
ote:
> diff --git a/arch/um/include/asm/pgalloc.h b/arch/um/include/asm/pgalloc.=
h
> index 32c8ce4..8b6257e 100644
> --- a/arch/um/include/asm/pgalloc.h
> +++ b/arch/um/include/asm/pgalloc.h
> @@ -27,6 +27,7 @@ extern pgd_t *pgd_alloc(struct mm_struct *);
> =A0extern void pgd_free(struct mm_struct *mm, pgd_t *pgd);
>
> =A0extern pte_t *pte_alloc_one_kernel(struct mm_struct *, unsigned long);
> +extern pte_t *__pte_alloc_one_kernel(struct mm_struct *, unsigned long, =
gfp_t);
> =A0extern pgtable_t pte_alloc_one(struct mm_struct *, unsigned long);
>
> =A0static inline void pte_free_kernel(struct mm_struct *mm, pte_t *pte)
> diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
> index 8137ccc..e4caf17 100644
> --- a/arch/um/kernel/mem.c
> +++ b/arch/um/kernel/mem.c
> @@ -284,12 +284,15 @@ void pgd_free(struct mm_struct *mm, pgd_t *pgd)
> =A0 =A0free_page((unsigned long) pgd);
> =A0}
>
> -pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
> +pte_t *
> +__pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address,
> gfp_t gfp_mask)
> =A0{
> - =A0 pte_t *pte;
> + =A0 return (pte_t *)__get_free_page(gfp_mask | __GFP_ZERO);
> +}
>
> - =A0 pte =3D (pte_t *)__get_free_page(GFP_KERNEL|__GFP_REPEAT|__GFP_ZERO=
);
> - =A0 return pte;
> +pte_t *pte_alloc_one_kernel(struct mm_struct *mm, unsigned long address)
> +{
> + =A0 return __pte_alloc_one_kernel(mm, address, GFP_KERNEL | __GFP_REPEA=
T);
> =A0}
>
> =A0pgtable_t pte_alloc_one(struct mm_struct *mm, unsigned long address)
> @@ -303,15 +306,21 @@ pgtable_t pte_alloc_one(struct mm_struct *mm,
> unsigned long address)
> =A0}
>
> =A0#ifdef CONFIG_3_LEVEL_PGTABLES
> -pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
> +pmd_t *
> +__pmd_alloc_one(struct mm_struct *mm, unsigned long address, gfp_t gfp_m=
ask)
> =A0{
> - =A0 pmd_t *pmd =3D (pmd_t *) __get_free_page(GFP_KERNEL);
> + =A0 pmd_t *pmd =3D (pmd_t *) __get_free_page(gfp_mask);
>
> =A0 =A0if (pmd)
> =A0 =A0 =A0 =A0memset(pmd, 0, PAGE_SIZE);
>
> =A0 =A0return pmd;
> =A0}
> +
> +pmd_t *pmd_alloc_one(struct mm_struct *mm, unsigned long address)
> +{
> + =A0 return __pmd_alloc_one(mm, address, GFP_KERNEL);
> +}
> =A0#endif
>
> =A0void *uml_kmalloc(int size, int flags)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>

Sorry, this patch seems damaged.

--=20
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
