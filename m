Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 70AAD6B0035
	for <linux-mm@kvack.org>; Fri,  4 Jul 2014 09:43:01 -0400 (EDT)
Received: by mail-we0-f171.google.com with SMTP id q58so1717033wes.16
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 06:43:00 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id i5si17075242wie.61.2014.07.04.06.43.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Jul 2014 06:43:00 -0700 (PDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so13096287wib.17
        for <linux-mm@kvack.org>; Fri, 04 Jul 2014 06:43:00 -0700 (PDT)
Date: Fri, 4 Jul 2014 15:42:57 +0200
From: Thierry Reding <thierry.reding@gmail.com>
Subject: Re: [PATCHv4 4/5] arm: use genalloc for the atomic pool
Message-ID: <20140704134254.GA4142@ulmo>
References: <1404324218-4743-1-git-send-email-lauraa@codeaurora.org>
 <1404324218-4743-5-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ew6BAiZeqk4r7MaW"
Content-Disposition: inline
In-Reply-To: <1404324218-4743-5-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, David Riley <davidriley@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Ritesh Harjain <ritesh.harjani@gmail.com>, linux-arm-kernel@lists.infradead.org


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 02, 2014 at 11:03:37AM -0700, Laura Abbott wrote:
[...]
> diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
[...]
> index f5190ac..02a1939 100644
> --- a/arch/arm/mm/dma-mapping.c
> +++ b/arch/arm/mm/dma-mapping.c
> @@ -26,6 +26,7 @@
>  #include <linux/io.h>
>  #include <linux/vmalloc.h>
>  #include <linux/sizes.h>
> +#include <linux/genalloc.h>

Includes should be sorted alphabetically. I realize that's not the case
for this particular file, but the downside of that is that your patch no
longer applies cleanly on top of linux-next because some other patch did
add linux/cma.h at the same location.

>  static int __init early_coherent_pool(char *p)
>  {
> -	atomic_pool.size =3D memparse(p, &p);
> +	atomic_pool_size =3D memparse(p, &p);
>  	return 0;
>  }
>  early_param("coherent_pool", early_coherent_pool);
> =20
> +

There's a gratuituous blank line her.

I also need the below hunk on top of you patch to make this compile on
ARM.

Thierry

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index b323032f0850..460aaf965a87 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1250,11 +1250,13 @@ static int __iommu_remove_mapping(struct device *de=
v, dma_addr_t iova, size_t si
=20
 static struct page **__atomic_get_pages(void *addr)
 {
-	struct dma_pool *pool =3D &atomic_pool;
-	struct page **pages =3D pool->pages;
-	int offs =3D (addr - pool->vaddr) >> PAGE_SHIFT;
+	struct page *page;
+	phys_addr_t phys;
+
+	phys =3D gen_pool_virt_to_phys(atomic_pool, (unsigned long)addr);
+	page =3D phys_to_page(phys);
=20
-	return pages + offs;
+	return (struct page **)page;
 }
=20
 static struct page **__iommu_get_pages(void *cpu_addr, struct dma_attrs *a=
ttrs)
diff --git a/arch/arm64/mm/dma-mapping.c b/arch/arm64/mm/dma-mapping.c
index a2487f12b2fc..764f53565958 100644
--- a/arch/arm64/mm/dma-mapping.c
+++ b/arch/arm64/mm/dma-mapping.c
@@ -441,7 +441,6 @@ remove_mapping:
 	dma_common_free_remap(addr, atomic_pool_size, VM_USERMAP);
 destroy_genpool:
 	gen_pool_destroy(atomic_pool);
-	atomic_pool =3D=3D NULL;
 free_page:
 	if (!dma_release_from_contiguous(NULL, page, nr_pages))
 		__free_pages(page, get_order(atomic_pool_size));

--ew6BAiZeqk4r7MaW
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJTtq9eAAoJEN0jrNd/PrOhpXMQAL0++4Vz+tGUrju08/GKR5AN
vqM3c6pBzLxlwwBEfaSdzTy+xyy6exaYMp3vo67stXvIwLzaGvnn8GYKyAurpXtK
ssiL2nW5EkV0GiYWZJcXbrKmOdZcBMEuhimKjdwKBSA8jnCNEWdLxEmldemjvJGj
S9NM1i3MVTFlEoVd+EcYy5aURy51rrlNG4Kb4IY4Qcpjykax24gjFNMt37NihSE0
a75MQgyjMFveYpn8XPtQoPmjzu3NycRp9UbfD+/Z3+Y3zVuN+hsmkU75inTYA/44
+R01xMBxygFL6xTJtfqgW5obH3TkAyIWOkgBFuNM5o38F+7o0/nxp++Pd+2UGaYe
GIPjZnibpei/PT+q7Z21J7BG4hf5Z/RpNzWWzAFq29B4Yw9wVPVKeBMIET9q+8s0
6HZV9wESozFawqLTH/qUnJG7iPGQzInwjKQjFmqT2xn/BHyg+wyZdqoGSTFAEm0B
EqTM3iuGQKqdlTBoOwwLvdeZZpUB1mrULndi+Dq0tILiS3HS8VFaOzd745lb+6Nu
BcQzxi4s7YwlhhMe5NXjwH/OB+rOM9aQk0GCwRv9iLBFV3xfTAZbri9UiqxfmjCc
bfc5Cic2g739npdrQ2uuvfi42XVSTBK0mPLfs/6NTPCIUdcyK30uNOTmigs17tt+
ABfo1C2Wknj2COhzhGAu
=bc4p
-----END PGP SIGNATURE-----

--ew6BAiZeqk4r7MaW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
