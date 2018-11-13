Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A94B6B0005
	for <linux-mm@kvack.org>; Mon, 12 Nov 2018 19:21:29 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id m52so1424374otc.13
        for <linux-mm@kvack.org>; Mon, 12 Nov 2018 16:21:29 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id g2-v6si8952098oiy.28.2018.11.12.16.21.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Nov 2018 16:21:28 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC][PATCH v1 03/11] mm: move definition of
 num_poisoned_pages_inc/dec to include/linux/mm.h
Date: Tue, 13 Nov 2018 00:17:31 +0000
Message-ID: <20181113001730.GB5945@hori1.linux.bs1.fc.nec.co.jp>
References: <1541746035-13408-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1541746035-13408-4-git-send-email-n-horiguchi@ah.jp.nec.com>
 <e4c4ae14-0d55-0738-9257-2c1232acef33@arm.com>
In-Reply-To: <e4c4ae14-0d55-0738-9257-2c1232acef33@arm.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <3EC1247046210940A7F9D6109DB99B08@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>, "xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>, Laurent Dufour <ldufour@linux.vnet.ibm.com>

On Fri, Nov 09, 2018 at 03:58:27PM +0530, Anshuman Khandual wrote:
>=20
>=20
> On 11/09/2018 12:17 PM, Naoya Horiguchi wrote:
> > num_poisoned_pages_inc/dec had better be visible to some file like
> > mm/sparse.c and mm/page_alloc.c (for a subsequent patch). So let's
> > move it to include/linux/mm.h.
> >=20
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  include/linux/mm.h      | 13 ++++++++++++-
> >  include/linux/swapops.h | 16 ----------------
> >  mm/sparse.c             |  2 +-
> >  3 files changed, 13 insertions(+), 18 deletions(-)
> >=20
> > diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h v4.19-mmotm-=
2018-10-30-16-08_patched/include/linux/mm.h
> > index 59df394..22623ba 100644
> > --- v4.19-mmotm-2018-10-30-16-08/include/linux/mm.h
> > +++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/mm.h
> > @@ -2741,7 +2741,7 @@ extern void shake_page(struct page *p, int access=
);
> >  extern atomic_long_t num_poisoned_pages __read_mostly;
> >  extern int soft_offline_page(struct page *page, int flags);
> > =20
> > -
> > +#ifdef CONFIG_MEMORY_FAILURE
> >  /*
> >   * Error handlers for various types of pages.
> >   */
> > @@ -2777,6 +2777,17 @@ enum mf_action_page_type {
> >  	MF_MSG_UNKNOWN,
> >  };
> > =20
> > +static inline void num_poisoned_pages_inc(void)
> > +{
> > +	atomic_long_inc(&num_poisoned_pages);
> > +}
> > +
> > +static inline void num_poisoned_pages_dec(void)
> > +{
> > +	atomic_long_dec(&num_poisoned_pages);
> > +}
> > +#endif
> > +
> >  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
> >  extern void clear_huge_page(struct page *page,
> >  			    unsigned long addr_hint,
> > diff --git v4.19-mmotm-2018-10-30-16-08/include/linux/swapops.h v4.19-m=
motm-2018-10-30-16-08_patched/include/linux/swapops.h
> > index 4d96166..88137e9 100644
> > --- v4.19-mmotm-2018-10-30-16-08/include/linux/swapops.h
> > +++ v4.19-mmotm-2018-10-30-16-08_patched/include/linux/swapops.h
> > @@ -320,8 +320,6 @@ static inline int is_pmd_migration_entry(pmd_t pmd)
> > =20
> >  #ifdef CONFIG_MEMORY_FAILURE
> > =20
> > -extern atomic_long_t num_poisoned_pages __read_mostly;
> > -
> >  /*
> >   * Support for hardware poisoned pages
> >   */
> > @@ -336,16 +334,6 @@ static inline int is_hwpoison_entry(swp_entry_t en=
try)
> >  	return swp_type(entry) =3D=3D SWP_HWPOISON;
> >  }
> > =20
> > -static inline void num_poisoned_pages_inc(void)
> > -{
> > -	atomic_long_inc(&num_poisoned_pages);
> > -}
> > -
> > -static inline void num_poisoned_pages_dec(void)
> > -{
> > -	atomic_long_dec(&num_poisoned_pages);
> > -}
> > -
> >  #else
> > =20
> >  static inline swp_entry_t make_hwpoison_entry(struct page *page)
> > @@ -357,10 +345,6 @@ static inline int is_hwpoison_entry(swp_entry_t sw=
p)
> >  {
> >  	return 0;
> >  }
> > -
> > -static inline void num_poisoned_pages_inc(void)
> > -{
> > -}
>=20
> I hope this was a stray definition and redundant which does not prevent
> build in absence of CONFIG_MEMORY_FAILURE.

You're right :)

> >  #endif
> > =20
> >  #if defined(CONFIG_MEMORY_FAILURE) || defined(CONFIG_MIGRATION)
> > diff --git v4.19-mmotm-2018-10-30-16-08/mm/sparse.c v4.19-mmotm-2018-10=
-30-16-08_patched/mm/sparse.c
> > index 33307fc..7ada2e5 100644
> > --- v4.19-mmotm-2018-10-30-16-08/mm/sparse.c
> > +++ v4.19-mmotm-2018-10-30-16-08_patched/mm/sparse.c
> > @@ -726,7 +726,7 @@ static void clear_hwpoisoned_pages(struct page *mem=
map, int nr_pages)
> > =20
> >  	for (i =3D 0; i < nr_pages; i++) {
> >  		if (PageHWPoison(&memmap[i])) {
> > -			atomic_long_sub(1, &num_poisoned_pages);
> > +			num_poisoned_pages_dec();
> >  			ClearPageHWPoison(&memmap[i]);
> >  		}
> >  	}
> >=20
>=20
> Otherwise looks good.
>=20
> Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

Thanks!
Naoya Horiguchi=
