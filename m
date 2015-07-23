Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 475756B025F
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 01:43:09 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so79453314pab.2
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 22:43:09 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id m2si9176578pdi.162.2015.07.22.22.43.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 22:43:08 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 1/2] mm, page_isolation: remove bogus tests for isolated
 pages
Date: Thu, 23 Jul 2015 05:41:28 +0000
Message-ID: <20150723054127.GA25423@hori1.linux.bs1.fc.nec.co.jp>
References: <55969822.9060907@suse.cz>
 <1437483218-18703-1-git-send-email-vbabka@suse.cz>
In-Reply-To: <1437483218-18703-1-git-send-email-vbabka@suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <A94DAB6290250A4A9766498B8B199369@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minkyung88.kim" <minkyung88.kim@lge.com>, "kmk3210@gmail.com" <kmk3210@gmail.com>, Seungho Park <seungho1.park@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On Tue, Jul 21, 2015 at 02:53:37PM +0200, Vlastimil Babka wrote:
> The __test_page_isolated_in_pageblock() is used to verify whether all pag=
es
> in pageblock were either successfully isolated, or are hwpoisoned. Two of=
 the
> possible state of pages, that are tested, are however bogus and misleadin=
g.
>=20
> Both tests rely on get_freepage_migratetype(page), which however has no
> guarantees about pages on freelists. Specifically, it doesn't guarantee t=
hat
> the migratetype returned by the function actually matches the migratetype=
 of
> the freelist that the page is on. Such guarantee is not its purpose and w=
ould
> have negative impact on allocator performance.
>=20
> The first test checks whether the freepage_migratetype equals MIGRATE_ISO=
LATE,
> supposedly to catch races between page isolation and allocator activity. =
These
> races should be fixed nowadays with 51bb1a4093 ("mm/page_alloc: add freep=
age
> on isolate pageblock to correct buddy list") and related patches. As expl=
ained
> above, the check wouldn't be able to catch them reliably anyway. For the =
same
> reason false positives can happen, although they are harmless, as the
> move_freepages() call would just move the page to the same freelist it's
> already on. So removing the test is not a bug fix, just cleanup. After th=
is
> patch, we assume that all PageBuddy pages are on the correct freelist and=
 that
> the races were really fixed. A truly reliable verification in the form of=
 e.g.
> VM_BUG_ON() would be complicated and is arguably not needed.
>=20
> The second test (page_count(page) =3D=3D 0 && get_freepage_migratetype(pa=
ge)
> =3D=3D MIGRATE_ISOLATE) is probably supposed (the code comes from a big m=
emory
> isolation patch from 2007) to catch pages on MIGRATE_ISOLATE pcplists.
> However, pcplists don't contain MIGRATE_ISOLATE freepages nowadays, those=
 are
> freed directly to free lists, so the check is obsolete. Remove it as well=
.
>=20
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Laura Abbott <lauraa@codeaurora.org>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Looks good to me.

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
