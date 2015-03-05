Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4C9656B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 03:03:05 -0500 (EST)
Received: by pdjp10 with SMTP id p10so27234073pdj.10
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 00:03:05 -0800 (PST)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id ot8si473609pbb.143.2015.03.05.00.03.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Mar 2015 00:03:04 -0800 (PST)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t25830Kr000521
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Thu, 5 Mar 2015 17:03:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: pagewalk: prevent positive return value of
 walk_page_test() from being passed to callers (Re: [PATCH] mm: fix do_mbind
 return value)
Date: Thu, 5 Mar 2015 08:02:27 +0000
Message-ID: <20150305080226.GA28441@hori1.linux.bs1.fc.nec.co.jp>
References: <54F7BD54.5060502@gmail.com>
 <alpine.DEB.2.10.1503042231250.15901@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.10.1503042231250.15901@chino.kir.corp.google.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <58F195083DE8C74CADB8CE7369419EBE@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Kazutomo Yoshii <kazutomo.yoshii@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

# CCed Andrew and linux-mm

On Wed, Mar 04, 2015 at 10:53:27PM -0800, David Rientjes wrote:
> On Wed, 4 Mar 2015, Kazutomo Yoshii wrote:
>=20
> > I noticed that numa_alloc_onnode() failed to allocate memory on a
> > specified node in v4.0-rc1. I added a code to check the return value
> > of walk_page_range() in queue_pages_range() so that do_mbind() only
> > returns an error number or zero.
> >=20
>=20
> I assume this is libnuma-2.0.10?
>=20
> > Signed-off-by: Kazutomo Yoshii <kazutomo.yoshii@gmail.com>
> > ---
> >  mm/mempolicy.c | 6 +++++-
> >  1 file changed, 5 insertions(+), 1 deletion(-)
> >=20
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 4721046..ea79171 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -644,6 +644,7 @@ queue_pages_range(struct mm_struct *mm, unsigned lo=
ng start, unsigned long end,
> >  		.nmask =3D nodes,
> >  		.prev =3D NULL,
> >  	};
> > +	int err;
> >  	struct mm_walk queue_pages_walk =3D {
> >  		.hugetlb_entry =3D queue_pages_hugetlb,
> >  		.pmd_entry =3D queue_pages_pte_range,
> > @@ -652,7 +653,10 @@ queue_pages_range(struct mm_struct *mm, unsigned l=
ong start, unsigned long end,
> >  		.private =3D &qp,
> >  	};
> >  -	return walk_page_range(start, end, &queue_pages_walk);
> > +	err =3D walk_page_range(start, end, &queue_pages_walk);
> > +	if (err < 0)
> > +		return err;
> > +	return 0;
> >  }
> >   /*
>=20
> I'm afraid I don't think this is the right fix, if walk_page_range()=20
> returns a positive value then it should be supplied by one of the=20
> callbacks in the struct mm_walk, which none of these happen to do.  I=20
> think this may be a problem with commit 6f4576e3687b ("mempolicy: apply=20
> page table walker on queue_pages_range()"), so let's add Naoya to the=20
> thread.

Thank you for reporting/forwarding, Yoshii-san and David.

This bug is in the pagewalk's common path, and the following patch should
fix it.

Thanks,
Naoya Horiguchi
---
