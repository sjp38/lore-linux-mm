Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 17C399000C1
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 04:13:29 -0400 (EDT)
Received: by vxk20 with SMTP id 20so1622658vxk.14
        for <linux-mm@kvack.org>; Wed, 27 Apr 2011 01:13:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1d9791f27df2341cb6750f5d6279b804151f57f9.1303833417.git.minchan.kim@gmail.com>
References: <cover.1303833415.git.minchan.kim@gmail.com>
	<1d9791f27df2341cb6750f5d6279b804151f57f9.1303833417.git.minchan.kim@gmail.com>
Date: Wed, 27 Apr 2011 17:13:27 +0900
Message-ID: <BANLkTi=Hh03JeQO+oBx1rJ8wP--a=iHgDw@mail.gmail.com>
Subject: Re: [RFC 1/8] Only isolate page we can handle
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

On Wed, Apr 27, 2011 at 1:25 AM, Minchan Kim <minchan.kim@gmail.com> wrote:
> There are some places to isolate lru page and I believe
> users of isolate_lru_page will be growing.
> The purpose of them is each different so part of isolated pages
> should put back to LRU, again.
>
> The problem is when we put back the page into LRU,
> we lose LRU ordering and the page is inserted at head of LRU list.
> It makes unnecessary LRU churning so that vm can evict working set pages
> rather than idle pages.
>
> This patch adds new filter mask when we isolate page in LRU.
> So, we don't isolate pages if we can't handle it.
> It could reduce LRU churning.
>
> This patch shouldn't change old behavior.
> It's just used by next patches.
>
> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
> =C2=A0include/linux/swap.h | =C2=A0 =C2=A03 ++-
> =C2=A0mm/compaction.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0mm/memcontrol.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0mm/vmscan.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 26 +++++++++=
+++++++++++------
> =C2=A04 files changed, 24 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 384eb5f..baef4ad 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -259,7 +259,8 @@ extern unsigned long mem_cgroup_shrink_node_zone(stru=
ct mem_cgroup *mem,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0unsigned int swappiness,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0struct zone *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0unsigned long *nr_scanned);
> -extern int __isolate_lru_page(struct page *page, int mode, int file);
> +extern int __isolate_lru_page(struct page *page, int mode, int file,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not_mapped);
> =C2=A0extern unsigned long shrink_all_memory(unsigned long nr_pages);
> =C2=A0extern int vm_swappiness;
> =C2=A0extern int remove_mapping(struct address_space *mapping, struct pag=
e *page);
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 021a296..dea32e3 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -335,7 +335,7 @@ static unsigned long isolate_migratepages(struct zone=
 *zone,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Try isolate the=
 page */
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page=
(page, ISOLATE_BOTH, 0) !=3D 0)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (__isolate_lru_page=
(page, ISOLATE_BOTH, 0, 0, 0) !=3D 0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0VM_BUG_ON(PageTran=
sCompound(page));
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index c2776f1..471e7fd 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1193,7 +1193,7 @@ unsigned long mem_cgroup_isolate_pages(unsigned lon=
g nr_to_scan,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0continue;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0scan++;
> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __isolate_lru_=
page(page, mode, file);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ret =3D __isolate_lru_=
page(page, mode, file, 0, 0);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0switch (ret) {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0case 0:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0list_move(&page->lru, dst);
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index b3a569f..71d2da9 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -954,10 +954,13 @@ keep_lumpy:
> =C2=A0*
> =C2=A0* page: =C2=A0 =C2=A0 =C2=A0 page to consider
> =C2=A0* mode: =C2=A0 =C2=A0 =C2=A0 one of the LRU isolation modes defined=
 above
> - *
> + * file: =C2=A0 =C2=A0 =C2=A0 page be on a file LRU
> + * not_dirty: =C2=A0page should be not dirty or not writeback
> + * not_mapped: page should be not mapped
> =C2=A0* returns 0 on success, -ve errno on failure.
> =C2=A0*/
> -int __isolate_lru_page(struct page *page, int mode, int file)
> +int __isolate_lru_page(struct page *page, int mode, int file,
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 int not_dirty, int not_mapped)
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0int ret =3D -EINVAL;
>
> @@ -976,6 +979,12 @@ int __isolate_lru_page(struct page *page, int mode, =
int file)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (mode !=3D ISOLATE_BOTH && page_is_file_cac=
he(page) !=3D file)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return ret;
>
> + =C2=A0 =C2=A0 =C2=A0 if (not_dirty)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (PageDirty(page) ||=
 PageWriteback(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return ret;
> + =C2=A0 =C2=A0 =C2=A0 if (not_mapped)
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (page_mapped(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 return ret;

I should have fixed this return value.
Now caller regards -EINVAL with BUG.
I will fix it in next version.

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
