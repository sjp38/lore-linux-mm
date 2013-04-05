Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 7E3456B009F
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:12:07 -0400 (EDT)
Date: Fri, 5 Apr 2013 12:11:59 +0100
From: Steve Capper <steve.capper@arm.com>
Subject: Re: [PATCH] arm: mm: lockless get_user_pages_fast
Message-ID: <20130405111158.GA13428@e103986-lin>
References: <1360890012-4684-1-git-send-email-chanho61.park@samsung.com>
MIME-Version: 1.0
In-Reply-To: <1360890012-4684-1-git-send-email-chanho61.park@samsung.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Park <chanho61.park@samsung.com>
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Catalin Marinas <Catalin.Marinas@arm.com>, Inki Dae <inki.dae@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Kyungmin Park <kyungmin.park@samsung.com>, Myungjoo Ham <myungjoo.ham@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Grazvydas Ignotas <notasas@gmail.com>

Hi Chanho,

Apologies for the tardy response, this patch slipped past me.

On Fri, Feb 15, 2013 at 01:00:12AM +0000, Chanho Park wrote:
> This patch adds get_user_pages_fast(old name is "fast_gup") for ARM.
> The fast_gup can walk pagetable without taking mmap_sem or any locks. If =
there
> is not a pte with the correct permissions for the access, we fall back to=
 slow
> path(get_user_pages) to get remaining pages. This patch is written on ref=
erence
> the x86's gup implementation. Traversing of hugepages is excluded because=
 ARM
> haven't supported hugepages yet[1], just only RFC.
>=20

I've tested this patch out, unfortunately it treats huge pmds as regular
pmds and attempts to traverse them rather than fall back to a slow path.
The fix for this is very minor, please see my suggestion below.

As an aside, I would like to extend this fast_gup to include full huge
page support and include a __get_user_pages_fast implementation. This
will hopefully fix a problem that was brought to my attention by
Grazvydas Ignotas whereby a FUTEX_WAIT on a THP tail page will cause
an infinite loop due to the stock implementation of __get_user_pages_fast
always returning 0.

> diff --git a/arch/arm/mm/gup.c b/arch/arm/mm/gup.c
> new file mode 100644
> index 0000000..ed54fd8

...

> +static int gup_pmd_range(pud_t *pudp, unsigned long addr, unsigned long =
end,
> +=09=09int write, struct page **pages, int *nr)
> +{
> +=09unsigned long next;
> +=09pmd_t *pmdp;
> +
> +=09pmdp =3D pmd_offset(pudp, addr);
> +=09do {
> +=09=09next =3D pmd_addr_end(addr, end);
> +=09=09if (pmd_none(*pmdp))
> +=09=09=09return 0;

I would suggest:
=09=09if (pmd_none(*pmdp) || pmd_bad(*pmdp))
=09=09=09return 0;
as this will pick up pmds that can't be traversed, and fall back to the slo=
w path.

> +=09=09else if (!gup_pte_range(pmdp, addr, next, write, pages, nr))
> +=09=09=09return 0;
> +=09} while (pmdp++, addr =3D next, addr !=3D end);
> +
> +=09return 1;
> +}
> +

Cheers,
--=20
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
