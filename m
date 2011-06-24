Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C229E900194
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 03:54:38 -0400 (EDT)
Subject: Re: [PATCH] mm: fix unmap_atomic range checks
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110624025335.21811fef@katamari>
References: <20110624025335.21811fef@katamari>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Fri, 24 Jun 2011 09:53:49 +0200
Message-ID: <1308902029.27849.16.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chuck Ebbert <cebbert@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>

On Fri, 2011-06-24 at 02:53 -0400, Chuck Ebbert wrote:
> Commit 3e4d3af501cccdc8a8cca41bdbe57d54ad7e7e73 ("mm: stack based
> kmap_atomic()", in 2.6.37-rc1) had three places where range checking
> logic was reversed.

Where's the oopses to go along with this?

I think its actually correct, since on both x86 and tile we have:

#define __fix_to_virt(x)        (FIXADDR_TOP - ((x) << PAGE_SHIFT))

Which flips the address space around, ie, END < BEGIN.       =20

> Signed-off-by: Chuck Ebbert <cebbert@redhat.com>
>=20
> --- a/arch/tile/mm/highmem.c
> +++ b/arch/tile/mm/highmem.c
> @@ -235,8 +235,8 @@ void __kunmap_atomic(void *kvaddr)
>  {
>  	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
> =20
> -	if (vaddr >=3D __fix_to_virt(FIX_KMAP_END) &&
> -	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
> +	if (vaddr >=3D __fix_to_virt(FIX_KMAP_BEGIN) &&
> +	    vaddr <=3D __fix_to_virt(FIX_KMAP_END)) {
>  		pte_t *pte =3D kmap_get_pte(vaddr);
>  		pte_t pteval =3D *pte;
>  		int idx, type;
> --- a/arch/x86/mm/highmem_32.c
> +++ b/arch/x86/mm/highmem_32.c
> @@ -70,8 +70,8 @@ void __kunmap_atomic(void *kvaddr)
>  {
>  	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
> =20
> -	if (vaddr >=3D __fix_to_virt(FIX_KMAP_END) &&
> -	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
> +	if (vaddr >=3D __fix_to_virt(FIX_KMAP_BEGIN) &&
> +	    vaddr <=3D __fix_to_virt(FIX_KMAP_END)) {
>  		int idx, type;
> =20
>  		type =3D kmap_atomic_idx();
> --- a/arch/x86/mm/iomap_32.c
> +++ b/arch/x86/mm/iomap_32.c
> @@ -94,8 +94,8 @@ iounmap_atomic(void __iomem *kvaddr)
>  {
>  	unsigned long vaddr =3D (unsigned long) kvaddr & PAGE_MASK;
> =20
> -	if (vaddr >=3D __fix_to_virt(FIX_KMAP_END) &&
> -	    vaddr <=3D __fix_to_virt(FIX_KMAP_BEGIN)) {
> +	if (vaddr >=3D __fix_to_virt(FIX_KMAP_BEGIN) &&
> +	    vaddr <=3D __fix_to_virt(FIX_KMAP_END)) {
>  		int idx, type;
> =20
>  		type =3D kmap_atomic_idx();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
