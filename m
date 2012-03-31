Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id 40C5B6B007E
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 08:09:31 -0400 (EDT)
Received: by vcbfk14 with SMTP id fk14so1312504vcb.14
        for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:09:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203301941.q2UJfo11007111@farm-0012.internal.tilera.com>
References: <201203301941.q2UJfo11007111@farm-0012.internal.tilera.com>
Date: Sat, 31 Mar 2012 20:09:29 +0800
Message-ID: <CAJd=RBDWhNmeqPE=PGWmma63LATOY=mhQ14E1j+y9Kxnznrzww@mail.gmail.com>
Subject: Re: [PATCH] arch/tile: support multiple huge page sizes dynamically
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Metcalf <cmetcalf@tilera.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lucas De Marchi <lucas.demarchi@profusion.mobi>, Arnd Bergmann <arnd@arndb.de>, Jiri Kosina <jkosina@suse.cz>, Joe Perches <joe@perches.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Paul E. McKenney" <paul.mckenney@linaro.org>, Josh Triplett <josh@joshtriplett.org>, Andrew Morton <akpm@linux-foundation.org>, Julia Lawall <julia@diku.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>

Hello Chris

On Sat, Mar 31, 2012 at 3:37 AM, Chris Metcalf <cmetcalf@tilera.com> wrote:
> This change adds support for a new "super" bit in the tile PTE, and a
> new arch_make_huge_pte() method called from make_huge_pte().
> The Tilera hypervisor sees the bit set at a given level of the page
> table and gangs together 4, 16, or 64 consecutive pages from
> that level of the hierarchy to create a larger TLB entry.
>
> One extra "super" page size can be specified at each of the
> three levels of the page table hierarchy on tilegx, using the
> "hugepagesz" argument on the boot command line. =C2=A0A new hypervisor
> API is added to allow Linux to tell the hypervisor how many PTEs
> to gang together at each level of the page table.
>
> To allow pre-allocating huge pages larger than the buddy allocator
> can handle, this change modifies the Tilera bootmem support to
> put all of memory on tilegx platforms into bootmem.
>
> As part of this change I eliminate the vestigial CONFIG_HIGHPTE
> support, which never worked anyway, and eliminate the hv_page_size()
> API in favor of the standard vma_kernel_pagesize() API.
>
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
> ---

[...]

> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a876871..4531be2 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2123,6 +2123,9 @@ static pte_t make_huge_pte(struct vm_area_struct *v=
ma, struct page *page,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0 =C2=A0 =C2=A0 =C2=A0entry =3D pte_mkyoung(entry);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0entry =3D pte_mkhuge(entry);
> +#ifdef arch_make_huge_pte
> + =C2=A0 =C2=A0 =C2=A0 entry =3D arch_make_huge_pte(entry, vma, page, wri=
table);
> +#endif
>
Would you please make arch_make_huge_pte() the way
that arch_prepare_hugepage() is implemented, or similar?

> =C2=A0 =C2=A0 =C2=A0 =C2=A0return entry;
> =C2=A0}
> --
> 1.6.5.2
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
