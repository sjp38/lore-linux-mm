Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id D56E16B0038
	for <linux-mm@kvack.org>; Thu, 10 Nov 2016 19:03:40 -0500 (EST)
Received: by mail-pa0-f70.google.com with SMTP id fp5so1624989pac.6
        for <linux-mm@kvack.org>; Thu, 10 Nov 2016 16:03:40 -0800 (PST)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id i27si7239436pgn.68.2016.11.10.16.03.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Nov 2016 16:03:39 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 09/12] mm: hwpoison: soft offline supports thp
 migration
Date: Thu, 10 Nov 2016 23:58:54 +0000
Message-ID: <20161110235853.GB22792@hori1.linux.bs1.fc.nec.co.jp>
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1478561517-4317-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <6e9aa943-31ea-5b08-8459-2e6a85940546@gmail.com>
In-Reply-To: <6e9aa943-31ea-5b08-8459-2e6a85940546@gmail.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <4D9D0E56B3B998459004EF294D3939B4@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Nov 10, 2016 at 09:31:10PM +1100, Balbir Singh wrote:
>=20
>=20
> On 08/11/16 10:31, Naoya Horiguchi wrote:
> > This patch enables thp migration for soft offline.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/memory-failure.c | 31 ++++++++++++-------------------
> >  1 file changed, 12 insertions(+), 19 deletions(-)
> >=20
> > diff --git v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c v4.9-rc2=
-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
> > index 19e796d..6cc8157 100644
> > --- v4.9-rc2-mmotm-2016-10-27-18-27/mm/memory-failure.c
> > +++ v4.9-rc2-mmotm-2016-10-27-18-27_patched/mm/memory-failure.c
> > @@ -1485,7 +1485,17 @@ static struct page *new_page(struct page *p, uns=
igned long private, int **x)
> >  	if (PageHuge(p))
> >  		return alloc_huge_page_node(page_hstate(compound_head(p)),
> >  						   nid);
> > -	else
> > +	else if (thp_migration_supported() && PageTransHuge(p)) {
> > +		struct page *thp;
> > +
> > +		thp =3D alloc_pages_node(nid,
> > +			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> > +			HPAGE_PMD_ORDER);
> > +		if (!thp)
> > +			return NULL;
>=20
> Just wondering if new_page() fails, migration of that entry fails. Do we =
then
> split and migrate? I guess this applies to THP migration in general.

Yes, that's not implemented yet, but can be helpful.

I think that there are 2 types of callers of page migration,
one is a caller that specifies the target pages individually (like move_pag=
es
and soft offline), and another is a caller that specifies the target pages
by (physical/virtual) address range basis.
Maybe the former ones want to fall back immediately to split and retry if
thp migration fails, and the latter ones want to retry thp migration more.
If this makes sense, we can make some more changes on retry logic to fit
the situation.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
