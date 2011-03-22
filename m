Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3E4C48D0040
	for <linux-mm@kvack.org>; Tue, 22 Mar 2011 18:58:29 -0400 (EDT)
Received: by iyf13 with SMTP id 13so10893006iyf.14
        for <linux-mm@kvack.org>; Tue, 22 Mar 2011 15:58:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201103222153.p2MLrD0x029642@imap1.linux-foundation.org>
References: <201103222153.p2MLrD0x029642@imap1.linux-foundation.org>
Date: Wed, 23 Mar 2011 07:58:24 +0900
Message-ID: <AANLkTi=1krqzHY1mg2T-k52C-VNruWsnXO33qS7BzeL+@mail.gmail.com>
Subject: Re: + mm-compaction-use-async-migration-for-__gfp_no_kswapd-and-enforce-no-writeback.patch
 added to -mm tree
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>
Cc: mm-commits@vger.kernel.org, arthur.marsh@internode.on.net, cladisch@googlemail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>

Hi Andrea,

I didn't follow up USB stick freeze issue but the patch's concept
looks good to me. But there are some comments about this patch.

1. __GFP_NO_KSWAPD

This patch is based on assumption that hugepage allocation have a good
fallback and now hugepage allocation uses __GFP_NO_KSWAPD.

__GFP_NO_KSWAPD's goal is just prevent unnecessary wakeup kswapd and
only user is just thp now so I can understand why you use it but how
about __GFP_NORETRY?

I think __GFP_NORETRY assume caller has a fallback mechanism(ex, SLUB)
and he think latency is important in such context.

2. LRU churn

By this patch, async migration can't migrate dirty page of normal fs.
It can move the victim page to head of LRU. I hope we can reduce LRU
churning as possible. For it, we can do it when we isolate the LRU
pages.
If compaction mode is async, we can exclude the dirty pages in
isolate_migratepages.


On Wed, Mar 23, 2011 at 6:53 AM,  <akpm@linux-foundation.org> wrote:
>
> The patch titled
> =C2=A0 =C2=A0 mm: compaction: Use async migration for __GFP_NO_KSWAPD and=
 enforce no writeback
> has been added to the -mm tree. =C2=A0Its filename is
> =C2=A0 =C2=A0 mm-compaction-use-async-migration-for-__gfp_no_kswapd-and-e=
nforce-no-writeback.patch
>
> Before you just go and hit "reply", please:
> =C2=A0 a) Consider who else should be cc'ed
> =C2=A0 b) Prefer to cc a suitable mailing list as well
> =C2=A0 c) Ideally: find the original patch on the mailing list and do a
> =C2=A0 =C2=A0 =C2=A0reply-to-all to that, adding suitable additional cc's
>
> *** Remember to use Documentation/SubmitChecklist when testing your code =
***
>
> See http://userweb.kernel.org/~akpm/stuff/added-to-mm.txt to find
> out what to do about this
>
> The current -mm tree may be found at http://userweb.kernel.org/~akpm/mmot=
m/
>
> ------------------------------------------------------
> Subject: mm: compaction: Use async migration for __GFP_NO_KSWAPD and enfo=
rce no writeback
> From: Andrea Arcangeli <aarcange@redhat.com>
>
> __GFP_NO_KSWAPD allocations are usually very expensive and not mandatory
> to succeed as they have graceful fallback. =C2=A0Waiting for I/O in those=
,
> tends to be overkill in terms of latencies, so we can reduce their latenc=
y
> by disabling sync migrate.
>
> Unfortunately, even with async migration it's still possible for the
> process to be blocked waiting for a request slot (e.g. =C2=A0get_request_=
wait
> in the block layer) when ->writepage is called. =C2=A0To prevent
> __GFP_NO_KSWAPD blocking, this patch prevents ->writepage being called on
> dirty page cache for asynchronous migration.
>
> [mel@csn.ul.ie: Avoid writebacks for NFS, retry locked pages, use bool]
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> Cc: Arthur Marsh <arthur.marsh@internode.on.net>
> Cc: Clemens Ladisch <cladisch@googlemail.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Minchan Kim <minchan.kim@gmail.com>
> Signed-off-by: Andrew Morton <>
> ---
>
> =C2=A0mm/migrate.c =C2=A0 =C2=A0| =C2=A0 48 +++++++++++++++++++++++++++++=
++---------------
> =C2=A0mm/page_alloc.c | =C2=A0 =C2=A02 -
> =C2=A02 files changed, 34 insertions(+), 16 deletions(-)
>
> diff -puN mm/migrate.c~mm-compaction-use-async-migration-for-__gfp_no_ksw=
apd-and-enforce-no-writeback mm/migrate.c
> --- a/mm/migrate.c~mm-compaction-use-async-migration-for-__gfp_no_kswapd-=
and-enforce-no-writeback
> +++ a/mm/migrate.c
> @@ -564,7 +564,7 @@ static int fallback_migrate_page(struct
> =C2=A0* =C2=A0=3D=3D 0 - success
> =C2=A0*/
> =C2=A0static int move_to_new_page(struct page *newpage, struct page *page=
,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 int remap_swapcache)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int remap_sw=
apcache, bool sync)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space *mapping;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int rc;
> @@ -586,18 +586,28 @@ static int move_to_new_page(struct page
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mapping =3D page_mapping(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!mapping)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0rc =3D migrate_pag=
e(mapping, newpage, page);
> - =C2=A0 =C2=A0 =C2=A0 else if (mapping->a_ops->migratepage)
> + =C2=A0 =C2=A0 =C2=A0 else {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Most pages hav=
e a mapping and most filesystems
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* should provide=
 a migration function. Anonymous
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* pages are part=
 of swap space which also has its
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* own migration =
function. This is the most common
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* path for page =
migration.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* Do not writeba=
ck pages if !sync and migratepage is
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* not pointing t=
o migrate_page() which is nonblocking
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* (swapcache/tmp=
fs uses migratepage =3D migrate_page).
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D mapping->a_ops-=
>migratepage(mapping,
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 newpage, page);
> - =C2=A0 =C2=A0 =C2=A0 else
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D fallback_migrat=
e_page(mapping, newpage, page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageDirty(page) &&=
 !sync &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mapping-=
>a_ops->migratepage !=3D migrate_page)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 rc =3D -EBUSY;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else if (mapping->a_op=
s->migratepage)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* Most pages have a mapping and most filesystems
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* should provide a migration function. Anonymous
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* pages are part of swap space which also has its
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* own migration function. This is the most common
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0* path for page migration.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 rc =3D mapping->a_ops->migratepage(mapping,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 newpage, page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 rc =3D fallback_migrate_page(mapping, newpage, page);
> + =C2=A0 =C2=A0 =C2=A0 }
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rc) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0newpage->mapping =
=3D NULL;
> @@ -641,7 +651,7 @@ static int unmap_and_move(new_page_t get
> =C2=A0 =C2=A0 =C2=A0 =C2=A0rc =3D -EAGAIN;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!trylock_page(page)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!force)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!force || !sync)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto move_newpage;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> @@ -686,7 +696,15 @@ static int unmap_and_move(new_page_t get
> =C2=A0 =C2=A0 =C2=A0 =C2=A0BUG_ON(charge);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (PageWriteback(page)) {
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!force || !sync)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* For !sync, the=
re is no point retrying as the retry loop
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0* is expected to=
 be too short for PageWriteback to be cleared
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!sync) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 rc =3D -EBUSY;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 goto uncharge;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (!force)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0goto uncharge;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0wait_on_page_write=
back(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> @@ -757,7 +775,7 @@ static int unmap_and_move(new_page_t get
>
> =C2=A0skip_unmap:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page_mapped(page))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D move_to_new_pag=
e(newpage, page, remap_swapcache);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D move_to_new_pag=
e(newpage, page, remap_swapcache, sync);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rc && remap_swapcache)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_migration_p=
tes(page, page);
> @@ -850,7 +868,7 @@ static int unmap_and_move_huge_page(new_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0try_to_unmap(hpage, TTU_MIGRATION|TTU_IGNORE_M=
LOCK|TTU_IGNORE_ACCESS);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (!page_mapped(hpage))
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D move_to_new_pag=
e(new_hpage, hpage, 1);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 rc =3D move_to_new_pag=
e(new_hpage, hpage, 1, sync);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (rc)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0remove_migration_p=
tes(hpage, hpage);
> diff -puN mm/page_alloc.c~mm-compaction-use-async-migration-for-__gfp_no_=
kswapd-and-enforce-no-writeback mm/page_alloc.c
> --- a/mm/page_alloc.c~mm-compaction-use-async-migration-for-__gfp_no_kswa=
pd-and-enforce-no-writeback
> +++ a/mm/page_alloc.c
> @@ -2103,7 +2103,7 @@ rebalance:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0sync_migr=
ation);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (page)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0goto got_pg;
> - =C2=A0 =C2=A0 =C2=A0 sync_migration =3D true;
> + =C2=A0 =C2=A0 =C2=A0 sync_migration =3D !(gfp_mask & __GFP_NO_KSWAPD);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Try direct reclaim and then allocating */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0page =3D __alloc_pages_direct_reclaim(gfp_mask=
, order,
> _
>
> Patches currently in -mm which might be from aarcange@redhat.com are
>
> origin.patch
> mm-compaction-prevent-kswapd-compacting-memory-to-reduce-cpu-usage.patch
> mm-compaction-check-migrate_pagess-return-value-instead-of-list_empty.pat=
ch
> mm-deactivate-invalidated-pages.patch
> memcg-move-memcg-reclaimable-page-into-tail-of-inactive-list.patch
> memcg-move-memcg-reclaimable-page-into-tail-of-inactive-list-fix.patch
> mm-reclaim-invalidated-page-asap.patch
> pagewalk-only-split-huge-pages-when-necessary.patch
> smaps-break-out-smaps_pte_entry-from-smaps_pte_range.patch
> smaps-pass-pte-size-argument-in-to-smaps_pte_entry.patch
> smaps-teach-smaps_pte_range-about-thp-pmds.patch
> smaps-have-smaps-show-transparent-huge-pages.patch
> mm-vmscan-kswapd-should-not-free-an-excessive-number-of-pages-when-balanc=
ing-small-zones.patch
> mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-free-pa=
ges.patch
> mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-f=
or-migration.patch
> mm-compaction-minimise-the-time-irqs-are-disabled-while-isolating-pages-f=
or-migration-fix.patch
> mm-compaction-use-async-migration-for-__gfp_no_kswapd-and-enforce-no-writ=
eback.patch
> mm-add-__gfp_other_node-flag.patch
> mm-use-__gfp_other_node-for-transparent-huge-pages.patch
> ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages.pat=
ch
> ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix=
.patch
> ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix=
-fix.patch
> ksm-add-vm_stat-and-meminfo-entry-to-reflect-pte-mapping-to-ksm-pages-fix=
-fix-fix.patch
> mm-add-vm-counters-for-transparent-hugepages.patch
> memcg-use-native-word-page-statistics-counters-fix-event-counter-breakage=
-with-thp.patch
>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
