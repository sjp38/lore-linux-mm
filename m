Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B53016B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 00:00:24 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a8so66387290pfg.0
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 21:00:24 -0800 (PST)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id 20si40344750pgk.101.2016.11.08.21.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Nov 2016 21:00:23 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
Date: Wed, 9 Nov 2016 04:59:27 +0000
Message-ID: <20161109045926.GB7770@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <ee20300d-0367-5b2c-71f2-f86bce3d6b90@gmail.com>
In-Reply-To: <ee20300d-0367-5b2c-71f2-f86bce3d6b90@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4FD04AB28C784F478330A49F406C589E@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Wed, Nov 09, 2016 at 01:32:04PM +1100, Balbir Singh wrote:
> On 08/11/16 10:31, Naoya Horiguchi wrote:
> > Hi everyone,
> >=20
> > I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
> > with feedbacks for ver.1.
> >=20
> > General description (no change since ver.1)
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > This patchset enhances page migration functionality to handle thp migra=
tion
> > for various page migration's callers:
> >  - mbind(2)
> >  - move_pages(2)
> >  - migrate_pages(2)
> >  - cgroup/cpuset migration
> >  - memory hotremove
> >  - soft offline
> >=20
> > The main benefit is that we can avoid unnecessary thp splits, which hel=
ps us
> > avoid performance decrease when your applications handles NUMA optimiza=
tion on
> > their own.
> >=20
> > The implementation is similar to that of normal page migration, the key=
 point
> > is that we modify a pmd to a pmd migration entry in swap-entry like for=
mat.
> >=20
> > Changes / Notes
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >=20
> > - pmd_present() in x86 checks _PAGE_PRESENT, _PAGE_PROTNONE and _PAGE_P=
SE
> >   bits together, which makes implementing thp migration a bit hard beca=
use
> >   _PAGE_PSE bit is currently used by soft-dirty in swap-entry format.
> >   I was advised to dropping _PAGE_PSE in pmd_present(), but I don't thi=
nk
> >   of the justification, so I keep it in this version. Instead, my appro=
ach
> >   is to move _PAGE_SWP_SOFT_DIRTY to bit 6 (unused) and reserve bit 7 f=
or
> >   pmd non-present cases.
>=20
> Thanks, IIRC
>=20
> pmd_present =3D _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE
>=20
> AutoNUMA balancing would change it to
>=20
> pmd_present =3D _PAGE_PROTNONE | _PAGE_PSE
>=20
> and PMD_SWP_SOFT_DIRTY would make it
>=20
> pmd_present =3D _PAGE_PSE
>=20
> What you seem to be suggesting in your comment is that
>=20
> pmd_present should be _PAGE_PRESENT | _PAGE_PROTNONE

This (no _PAGE_PSE) was a possibile solution, and as I described I gave up
this solution, because I noticed that what I actually wanted was that
pmd_present() certainly returns false during thp migration and that's done
by moving _PAGE_SWP_SOFT_DIRTY. So

  pmd_present =3D _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE

is still correct in this patchset.

>=20
> Isn't that good enough?
>=20
> For THP migration I guess we use
>=20
> _PAGE_PRESENT | _PAGE_PROTNONE | is_migration_entry(pmd)

Though I might misread your notations, I hope that the following code
seems describe itself well.

  static inline int is_pmd_migration_entry(pmd_t pmd)                      =
     =20
  {                                                                        =
     =20
          return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(p=
md));=20
  }                                                                        =
     =20

Thanks,
Naoya Horiguchi

>=20
>=20
> >=20
> > - this patchset still covers only x86_64. Zi Yan posted a patch for ppc=
64
> >   and I think it's favorably received so that's fine. But there's unsol=
ved
> >   minor suggestion by Aneesh, so I don't include it in this set, expect=
ing
> >   that it will be updated/reposted.
> >=20
> > - pte-mapped thp and doubly-mapped thp were not supported in ver.1, but
> >   this version should work for such kinds of thp.
> >=20
> > - thp page cache is not tested yet, and it's at the head of my todo lis=
t
> >   for future version.
> >=20
> > Any comments or advices are welcomed.
>=20
> Balbir Singh
> =

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
