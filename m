Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB266B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 20:22:10 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so31314805pac.0
        for <linux-mm@kvack.org>; Tue, 12 May 2015 17:22:10 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id hu6si24629131pac.153.2015.05.12.17.22.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 17:22:09 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/4] mm/memory-failure: introduce get_hwpoison_page()
 for consistent refcount handling
Date: Wed, 13 May 2015 00:11:41 +0000
Message-ID: <20150513001141.GA14599@hori1.linux.bs1.fc.nec.co.jp>
References: <1431423998-1939-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1431423998-1939-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150512150017.4172e4b7bd549e16d8772753@linux-foundation.org>
In-Reply-To: <20150512150017.4172e4b7bd549e16d8772753@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <59FF06F49052484D961BCEF018E0B35D@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Tue, May 12, 2015 at 03:00:17PM -0700, Andrew Morton wrote:
> On Tue, 12 May 2015 09:46:47 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > memory_failrue() can run in 2 different mode (specified by MF_COUNT_INC=
REASED)
> > in page refcount perspective. When MF_COUNT_INCREASED is set, memory_fa=
ilrue()
> > assumes that the caller takes a refcount of the target page. And if cle=
ared,
> > memory_failure() takes it in it's own.
> >=20
> > In current code, however, refcounting is done differently in each calle=
r. For
> > example, madvise_hwpoison() uses get_user_pages_fast() and hwpoison_inj=
ect()
> > uses get_page_unless_zero(). So this inconsistent refcounting causes re=
fcount
> > failure especially for thp tail pages. Typical user visible effects are=
 like
> > memory leak or VM_BUG_ON_PAGE(!page_count(page)) in isolate_lru_page().
> >=20
> > To fix this refcounting issue, this patch introduces get_hwpoison_page(=
) to
> > handle thp tail pages in the same manner for each caller of hwpoison co=
de.
> >=20
> > There's a non-trivial change around unpoisoning, which now returns imme=
diately
> > for thp with "MCE: Memory failure is now running on %#lx\n" message. Th=
is is
> > not right when split_huge_page() fails. So this patch also allows
> > unpoison_memory() to handle thp.
> >
> > ...
> >
> >  /*
> > + * Get refcount for memory error handling:
> > + * - @page: raw page
> > + */
> > +inline int get_hwpoison_page(struct page *page)
> > +{
> > +	struct page *head =3D compound_head(page);
> > +
> > +	if (PageHuge(head))
> > +		return get_page_unless_zero(head);
> > +	else if (PageTransHuge(head))
> > +		if (get_page_unless_zero(head)) {
> > +			if (PageTail(page))
> > +				get_page(page);
> > +			return 1;
> > +		} else {
> > +			return 0;
> > +		}
> > +	else
> > +		return get_page_unless_zero(page);
> > +}
>=20
> This function is a bit weird.
>=20
> - The comment looks like kerneldoc but isn't kerneldoc

OK, will fix it.

> - Why the inline?  It isn't fastpath?

No, so I'll drop 'inline'.

> - The layout is rather painful.  It could be
>=20
> 	if (PageHuge(head))
> 		return get_page_unless_zero(head);
>=20
> 	if (PageTransHuge(head)) {
> 		if (get_page_unless_zero(head)) {
> 			if (PageTail(page))
> 				get_page(page);
> 			return 1;
> 		} else {
> 			return 0;
> 		}
> 	}
>=20
> 	return get_page_unless_zero(page);

OK, will do like this.

> - Some illuminating comments would be nice.  In particular that code
>   path where it grabs a ref on the tail page as well as on the head
>   page.  What's going on there?

We can't call get_page_unless_zero() directly for thp tail pages because
that breaks thp's refcounting rule (refcount of tail pages is stored in
->_mapcount.) This code intends to comply with the rule in hwpoison code to=
o.
So I'll comment the point.

Hmm, I found just now that I forget to put_page(head) in if (PageTail) bloc=
k,
which leaks head page after thp split.
So it'll be fixed in the next version.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
