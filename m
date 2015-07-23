Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6C89B6B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 19:17:33 -0400 (EDT)
Received: by igbpg9 with SMTP id pg9so3333938igb.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 16:17:33 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id w185si6255661iod.104.2015.07.23.16.17.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 16:17:32 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v1 4/4] mm/memory-failure: check __PG_HWPOISON
 separately from PAGE_FLAGS_CHECK_AT_*
Date: Thu, 23 Jul 2015 23:13:40 +0000
Message-ID: <20150723231340.GA14329@hori1.linux.bs1.fc.nec.co.jp>
References: <1437010894-10262-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1437010894-10262-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20150723133702.81a9dacc997b25260c44f42d@linux-foundation.org>
In-Reply-To: <20150723133702.81a9dacc997b25260c44f42d@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <82195C359B12ED4DAE5E7A3F20B0B201@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Dean Nelson <dnelson@redhat.com>, Tony Luck <tony.luck@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Thu, Jul 23, 2015 at 01:37:02PM -0700, Andrew Morton wrote:
> On Thu, 16 Jul 2015 01:41:56 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > The race condition addressed in commit add05cecef80 ("mm: soft-offline:=
 don't
> > free target page in successful page migration") was not closed complete=
ly,
> > because that can happen not only for soft-offline, but also for hard-of=
fline.
> > Consider that a slab page is about to be freed into buddy pool, and the=
n an
> > uncorrected memory error hits the page just after entering __free_one_p=
age(),
> > then VM_BUG_ON_PAGE(page->flags & PAGE_FLAGS_CHECK_AT_PREP) is triggere=
d,
> > despite the fact that it's not necessary because the data on the affect=
ed
> > page is not consumed.
> >=20
> > To solve it, this patch drops __PG_HWPOISON from page flag checks at
> > allocation/free time. I think it's justified because __PG_HWPOISON flag=
s is
> > defined to prevent the page from being reused and setting it outside th=
e
> > page's alloc-free cycle is a designed behavior (not a bug.)
> >=20
> > And the patch reverts most of the changes from commit add05cecef80 abou=
t
> > the new refcounting rule of soft-offlined pages, which is no longer nec=
essary.
> >=20
> > ...
> >
> > --- v4.2-rc2.orig/mm/memory-failure.c
> > +++ v4.2-rc2/mm/memory-failure.c
> > @@ -1723,6 +1723,9 @@ int soft_offline_page(struct page *page, int flag=
s)
> > =20
> >  	get_online_mems();
> > =20
> > +	if (get_pageblock_migratetype(page) !=3D MIGRATE_ISOLATE)
> > +		set_migratetype_isolate(page, true);
> > +
> >  	ret =3D get_any_page(page, pfn, flags);
> >  	put_online_mems();
> >  	if (ret > 0) { /* for in-use pages */
>=20
> This patch gets build-broken by your
> mm-page_isolation-make-set-unset_migratetype_isolate-file-local.patch,
> which I shall drop.

I apologize this build failure. At first I planned to add another hwpoison =
patch
after this to remove this migratetype thing separately, but I was not 100% =
sure
of the correctness, so I did not include it in this version.
But Vlastimil's cleanup patch showed me that using MIGRATE_ISOLATE at free =
time
(, which is what soft offline code does now,) is wrong (or not an expected =
usage).
So I shouldn't have reverted the above part.

So I want the patch "mm, page_isolation: make set/unset_migratetype_isolate=
()
file-local" to be merged first, and I'd like to update this hwpoison before
going into mmotm. Could you drop this series from your tree for now?
I'll repost the next version probably next week.

Thanks,
Naoya Horiguchi=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
