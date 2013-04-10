Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 2D2986B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 04:21:08 -0400 (EDT)
Date: Wed, 10 Apr 2013 09:21:00 +0100
From: Steve Capper <steve.capper@arm.com>
Subject: Re: [PATCH] arm: mm: lockless get_user_pages_fast
Message-ID: <20130410082059.GA12296@e103986-lin>
References: <1360890012-4684-1-git-send-email-chanho61.park@samsung.com>
 <20130405111158.GA13428@e103986-lin>
 <00a201ce35bd$5626fd90$0274f8b0$@samsusng.com>
MIME-Version: 1.0
In-Reply-To: <00a201ce35bd$5626fd90$0274f8b0$@samsusng.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chanho Park <chanho61.park@samsusng.com>
Cc: Steve Capper <Steve.Capper@arm.com>, 'Chanho Park' <chanho61.park@samsung.com>, "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Catalin Marinas <Catalin.Marinas@arm.com>, 'Inki Dae' <inki.dae@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Myungjoo Ham' <myungjoo.ham@samsung.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 'Grazvydas Ignotas' <notasas@gmail.com>

On Wed, Apr 10, 2013 at 08:30:54AM +0100, Chanho Park wrote:
> > Apologies for the tardy response, this patch slipped past me.
>=20
> Never mind.
>=20
> > I've tested this patch out, unfortunately it treats huge pmds as regula=
r
> > pmds and attempts to traverse them rather than fall back to a slow path=
.
> > The fix for this is very minor, please see my suggestion below.
> OK. I'll fix it.
>=20
> >=20
> > As an aside, I would like to extend this fast_gup to include full huge
> > page support and include a __get_user_pages_fast implementation. This w=
ill
> > hopefully fix a problem that was brought to my attention by Grazvydas
> > Ignotas whereby a FUTEX_WAIT on a THP tail page will cause an infinite
> > loop due to the stock implementation of __get_user_pages_fast always
> > returning 0.
>=20
> I'll add the __get_user_pages_fast implementation. BTW, HugeTLB on ARM
> wasn't
> supported yet. There is no problem to add gup_huge_pmd. But I think it ne=
ed
> a test
> for hugepages.
>=20

Thanks, that would be helpful. My plan was to then put the huge page
specific bits in, with another patch. That way I can test it all out
here.

> > I would suggest:
> > =09=09if (pmd_none(*pmdp) || pmd_bad(*pmdp))
> > =09=09=09return 0;
> > as this will pick up pmds that can't be traversed, and fall back to the
> > slow path.
>=20
> Thanks for your suggestion.
> I'll prepare the v2 patch.
>=20

Also, just one more thing. In your gup_pte_range function there is
an smp_rmb() just after the pte is dereferenced. I don't understand
why though?

> Best regards,
> Chanho Park
>=20
>=20

Thanks,
--=20
Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
