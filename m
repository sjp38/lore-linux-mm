Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 43A666B0007
	for <linux-mm@kvack.org>; Thu, 14 Feb 2013 20:48:05 -0500 (EST)
Message-ID: <1360892876.5374.332.camel@deadeye.wl.decadent.org.uk>
Subject: Re: [PATCH] mm: Try harder to allocate vmemmap blocks
From: Ben Hutchings <ben@decadent.org.uk>
Date: Fri, 15 Feb 2013 01:47:56 +0000
In-Reply-To: <20130214064048.GB8372@cmpxchg.org>
References: <1360816468.5374.285.camel@deadeye.wl.decadent.org.uk>
	 <20130214064048.GB8372@cmpxchg.org>
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-BcSc6EkT8ptcWItClZFW"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org


--=-BcSc6EkT8ptcWItClZFW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-02-14 at 01:40 -0500, Johannes Weiner wrote:
> On Thu, Feb 14, 2013 at 04:34:28AM +0000, Ben Hutchings wrote:
> > Hot-adding memory on x86_64 normally requires huge page allocation.
> > When this is done to a VM guest, it's usually because the system is
> > already tight on memory, so the request tends to fail.  Try to avoid
> > this by adding __GFP_REPEAT to the allocation flags.
> >=20
> > Reported-and-tested-by: Bernhard Schmidt <Bernhard.Schmidt@lrz.de>
> > Reference: http://bugs.debian.org/699913
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
>=20
> > We could go even further and use __GFP_NOFAIL, but I'm not sure
> > whether that would be a good idea.
>=20
> If __GFP_REPEAT is not enough, I'd rather fall back to regular page
> backing at this point:

Oh yes, I had considered doing that before settling on __GFP_REPEAT.  It
does seem worth doing.  Perhaps you could also log a specific warning,
as the use of 4K page entries for this could have a significant
performance impact.

Ben.

> diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
> index 2ead3c8..1f5301d 100644
> --- a/arch/x86/mm/init_64.c
> +++ b/arch/x86/mm/init_64.c
> @@ -919,6 +919,7 @@ vmemmap_populate(struct page *start_page, unsigned lo=
ng size, int node)
>  {
>  	unsigned long addr =3D (unsigned long)start_page;
>  	unsigned long end =3D (unsigned long)(start_page + size);
> +	int use_huge =3D cpu_has_pse;
>  	unsigned long next;
>  	pgd_t *pgd;
>  	pud_t *pud;
> @@ -934,8 +935,8 @@ vmemmap_populate(struct page *start_page, unsigned lo=
ng size, int node)
>  		pud =3D vmemmap_pud_populate(pgd, addr, node);
>  		if (!pud)
>  			return -ENOMEM;
> -
> -		if (!cpu_has_pse) {
> +retry_pmd:
> +		if (!use_huge) {
>  			next =3D (addr + PAGE_SIZE) & PAGE_MASK;
>  			pmd =3D vmemmap_pmd_populate(pud, addr, node);
> =20
> @@ -957,8 +958,10 @@ vmemmap_populate(struct page *start_page, unsigned l=
ong size, int node)
>  				pte_t entry;
> =20
>  				p =3D vmemmap_alloc_block_buf(PMD_SIZE, node);
> -				if (!p)
> -					return -ENOMEM;
> +				if (!p) {
> +					use_huge =3D 0;
> +					goto retry_pmd;
> +				}
> =20
>  				entry =3D pfn_pte(__pa(p) >> PAGE_SHIFT,
>  						PAGE_KERNEL_LARGE);
>=20

--=20
Ben Hutchings
Absolutum obsoletum. (If it works, it's out of date.) - Stafford Beer

--=-BcSc6EkT8ptcWItClZFW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUR2TzOe/yOyVhhEJAQrHLxAAvig8MTSrx6d2mMUkdCG08QeyGWmVkW7b
1R2aCnmNexKdV/lRsu4FT2Fjm9BHhESJd3tv8IMMBfosRffnS+faYnZO7MDzBFRM
JzTQZ1WQY8BAdCPEloQ8LllD9F8xlMiriZrqP+BzUK+AGi4gpAImN7RzQtZPxXkf
aYSSTHPwy7zTq2jn1y6Jt/7digJicGNUU3g4dC3L3d0ZZuw4+epnMV1wyZQyiQ9J
/6YxAFA3C/+mgVH3uuDKH2PX8+3oNPHIOmGkdaGQ/4KQLTNMaRqD3GCYn6IsMboT
czbk33Jtja1ttH9RJorjsOePlTCvAeRAfPMgUy++VuBB/mi+40c8FWH+geAu6M+u
BJQ1Y0HgUjVt2GHZVgQt3bUDWoic0xxk3Qfvov46zX8b/7PNTRcTwBv5r6ogZ9ac
+BO/bk3TWNsyyrsB/CknO46/INn6Y206ixl7hJlA++NyYKQQIBeLBv/n8hEB8H1+
lvyCW10Gybk+W3R5gfau7zt/LFSsef60Lldtwmc5i71BHzLE2VdWU+X5rU0C68zW
UKaawrxV2W+oTnz5nRb887FevgABeOzE1fR63t2wG/LE+wsLpqzaJXNsVW4VBgcU
y3ggbwgCnGmOhFKgW8OySeCrZeqekHx/G/q/Ocdv0k6tfkPdvseHA1wg35G5oyF4
eiwMB+08le0=
=siSQ
-----END PGP SIGNATURE-----

--=-BcSc6EkT8ptcWItClZFW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
