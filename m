Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A6E42803B4
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 00:33:00 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t193so28556095pgc.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 21:33:00 -0700 (PDT)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id m1si2291050pld.69.2017.08.23.21.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 21:32:56 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 1/4] mm: madvise: read loop's step size beforehand
 in madvise_inject_error(), prepare for THP support.
Date: Thu, 24 Aug 2017 04:26:10 +0000
Message-ID: <20170824042608.GA30150@hori1.linux.bs1.fc.nec.co.jp>
References: <20170815015216.31827-1-zi.yan@sent.com>
 <20170815015216.31827-2-zi.yan@sent.com>
 <20170823074933.GA3527@hori1.linux.bs1.fc.nec.co.jp>
 <41F3B393-6FDA-4CF9-A790-A1B4B4FDFA58@sent.com>
In-Reply-To: <41F3B393-6FDA-4CF9-A790-A1B4B4FDFA58@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <69C161DC7DF5E545A5EF9DD66C313892@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Aug 23, 2017 at 10:20:02AM -0400, Zi Yan wrote:
> On 23 Aug 2017, at 3:49, Naoya Horiguchi wrote:
>=20
> > On Mon, Aug 14, 2017 at 09:52:13PM -0400, Zi Yan wrote:
> >> From: Zi Yan <zi.yan@cs.rutgers.edu>
> >>
> >> The loop in madvise_inject_error() reads its step size from a page
> >> after it is soft-offlined. It works because the page is:
> >> 1) a hugetlb page: the page size does not change;
> >> 2) a base page: the page size does not change;
> >> 3) a THP: soft-offline always splits THPs, thus, it is OK to use
> >>    PAGE_SIZE as step size.
> >>
> >> It will be a problem when soft-offline supports THP migrations.
> >> When a THP is migrated without split during soft-offlining, the THP
> >> is split after migration, thus, before and after soft-offlining page
> >> sizes do not match. This causes a THP to be unnecessarily soft-lined,
> >> at most, 511 times, wasting free space.
> >
> > Hi Zi Yan,
> >
> > Thank you for the suggestion.
> >
> > I think that when madvise(MADV_SOFT_OFFLINE) is called with some range
> > over more than one 4kB page, the caller clearly intends to call
> > soft_offline_page() over all 4kB pages within the range in order to
> > simulate the multiple soft-offline events. Please note that the caller
> > only knows that specific pages are half-broken, and expect that all suc=
h
> > pages are offlined. So the end result should be same, whether the given
> > range is backed by thp or not.
> >
>=20
> But if the given virtual address is backed by a THP and the THP is soft-o=
fflined
> without splitting (enabled by following patches), the old for-loop will c=
ause extra
> 511 THPs being soft-offlined.
>=20
> For example, the caller wants to offline VPN 0-511, which is backed by a =
THP whose
> address range is PFN 0-511. In the first iteration of the for-loop,
> get_user_pages_fast(VPN0, ...) will return the THP and soft_offline_page(=
) will offline the THP,
> replacing it with a new THP, say PFN 512-1023, so VPN 0-511 is backed by =
PFN 512-1023.
> But the original THP will be split after it is freed, thus, for-loop will=
 not end
> at this moment, but continues to offline VPN1, which leads to PFN 512-102=
3 being offlined
> and replaced by another THP, say 1024-1535. This will go on and end up wi=
th
> 511 extra THPs are offlined. That is why we need to this patch to tell
> whether the THP is offlined as a whole or just its head page is offlined.

Thanks for elaborating this. I understand your point.
But I still not sure what the best behavior is.

madvise(MADV_SOFT_OFFLINE) is a test feature and giving multi-page range
on the call works like some stress testing. So multiple thp migrations
seem to me an expected behavior. At least it behaves in the same manner
as calling madvise(MADV_SOFT_OFFLINE) 512 times on VPN0-VPN511 separately,
which is consistent.

So I still feel like leaving the current behavior as long as your later
patches work without this change.

Thanks,
Naoya Horiguchi

>=20
> Let me know if it is still not clear to you. Or I missed something.
>=20
> >>
> >> Signed-off-by: Zi Yan <zi.yan@cs.rutgers.edu>
> >> ---
> >>  mm/madvise.c | 21 ++++++++++++++++++---
> >>  1 file changed, 18 insertions(+), 3 deletions(-)
> >>
> >> diff --git a/mm/madvise.c b/mm/madvise.c
> >> index 47d8d8a25eae..49f6774db259 100644
> >> --- a/mm/madvise.c
> >> +++ b/mm/madvise.c
> >> @@ -612,19 +612,22 @@ static long madvise_remove(struct vm_area_struct=
 *vma,
> >>  static int madvise_inject_error(int behavior,
> >>  		unsigned long start, unsigned long end)
> >>  {
> >> -	struct page *page;
> >> +	struct page *page =3D NULL;
> >> +	unsigned long page_size =3D PAGE_SIZE;
> >>
> >>  	if (!capable(CAP_SYS_ADMIN))
> >>  		return -EPERM;
> >>
> >> -	for (; start < end; start +=3D PAGE_SIZE <<
> >> -				compound_order(compound_head(page))) {
> >> +	for (; start < end; start +=3D page_size) {
> >>  		int ret;
> >>
> >>  		ret =3D get_user_pages_fast(start, 1, 0, &page);
> >>  		if (ret !=3D 1)
> >>  			return ret;
> >>
> >> +		page_size =3D (PAGE_SIZE << compound_order(compound_head(page))) -
> >> +			(PAGE_SIZE * (page - compound_head(page)));
> >> +
> >
> > Assigning a value which is not 4kB or some hugepage size into page_size
> > might be confusing because that's not what the name says. You can intro=
duce
> > 'next' virtual address and ALIGN() might be helpful to calculate it.
>=20
> Like:
>=20
> next =3D ALIGN(start, PAGE_SIZE<<compound_order(compound_head(page))) - s=
tart;
>=20
> I think it works. Thanks.
>=20
>=20
> --
> Best Regards
> Yan Zi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
