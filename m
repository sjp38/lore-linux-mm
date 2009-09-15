Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 0A38B6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 11:26:19 -0400 (EDT)
Received: by ywh8 with SMTP id 8so6648314ywh.14
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 08:26:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1252971975-15218-1-git-send-email-hannes@cmpxchg.org>
References: <1252971975-15218-1-git-send-email-hannes@cmpxchg.org>
Date: Wed, 16 Sep 2009 00:26:27 +0900
Message-ID: <28c262360909150826s2a0f5f0dpd111640f92d0f5ff@mail.gmail.com>
Subject: Re: [patch] mm: use-once mapped file pages
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi, Hannes.

On Tue, Sep 15, 2009 at 8:46 AM, Johannes Weiner <hannes@cmpxchg.org> wrote=
:
> The eviction code directly activates mapped pages (or pages backing a
> mapped file while being unmapped themselves) when they have been
> referenced from a page table or have their PG_referenced bit set from
> read() or the unmap path.
>
> Anonymous pages start out on the active list and have their initial
> reference cleared on deactivation. =A0But mapped file pages start out
> referenced on the inactive list and are thus garuanteed to be
> activated on first scan.
>
> This has detrimental impact on a common real-world load that maps
> subsequent chunks of a file to calculate its checksum (rtorrent
> hashing). =A0All the mapped file pages get activated even though they
> are never used again. =A0Worse, even already unmapped pages get
> activated because the file itself is still mapped by the chunk that is
> currently hashed.

Yes. I wonder why it is there.
I found it with git.

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/old-2.6-bkcvs.git;a=3D=
commitdiff;h=3Dfe23e022c442bb917815e206c4765cd9150faef5

At that time, Rik added following as.
( I hate wordwrap, but my google webmail will do ;( )

+       /* File is mmap'd by somebody. */
+       if (!list_empty(&mapping->i_mmap) ||
!list_empty(&mapping->i_mmap_shared))
+               return 1;

It made your case worse as you noticed.

>
> When dropping into reclaim, the VM has a hard time making progress
> with these pages dominating. =A0And since all mapped pages are treated
> equally (i.e. anon pages as well), a major part of the anon working
> set is swapped out before the hashing completes as well.
>
> Failing reclaim and swapping show up pretty quickly in decreasing
> overall system interactivity, but also in the throughput of the
> hashing process itself.
>
> This patch implements a use-once strategy for mapped file pages.
>
> For this purpose, mapped file pages with page table references are not
> directly activated at the end of the inactive list anymore but marked
> with PG_referenced and sent on another roundtrip on the inactive list.
> If such a page comes in again, another page table reference activates
> it while the lack thereof leads to its eviction.
>
> The deactivation path does not clear this mark so that a subsequent
> page table reference for a page coming from the active list means
> reactivation as well.

It seems to be good idea. but I have a concern about embedded.
AFAIK, some CPUs don't have accessed bit by hardware.
maybe ARM series.
(Nowadays, Some kinds of CPU series just supports access bit.
but there are still CPUs that doesn't support it)

I am not sure there are others architecture.
Your idea makes mapped page reclaim depend on access bit more tightly.
 :(

>
> By re-using the PG_referenced bit, we trade the following behaviour:
> clean, unmapped pages that are backing a mapped file and have
> PG_referenced set from read() or a page table teardown do no longer
> enjoy the same protection as actually mapped and referenced file pages
> - they are treated just like other unmapped file pages. =A0That could be
> preserved by opting for a different page flag, but we do not see any
> obvious reasons for this special treatment.
>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> =A0mm/rmap.c =A0 | =A0 =A03 --
> =A0mm/vmscan.c | =A0104 +++++++++++++++++++++++++++++++++++++------------=
---------
> =A02 files changed, 66 insertions(+), 41 deletions(-)
>
> The effects for the described load are rather dramatic. =A0rtorrent
> hashing a file bigger than memory on an unpatched kernel makes the
> system almost unusable while with this patch applied, I don't even
> notice it running.
>
> A test that replicates this situation - sha1 hashing a file in mmap'd
> chunks while measuring latency of forks - shows the following results
> for example:
>
> Hashing a 1.5G file on 900M RAM in chunks of 32M, measuring the
> latency of pipe(), fork(), write("done") to pipe (child), read() from
> pipe (parent) cycles every two seconds:
>
> =A0 =A0 =A0 =A0old: latency max=3D1.403658s mean=3D0.325557s stddev=3D0.4=
14985
> =A0 =A0 =A0 =A0hashing 58.655560s thruput=3D27118344.83b/s
>
> =A0 =A0 =A0 =A0new: latency max=3D0.334673s mean=3D0.059005s stddev=3D0.0=
83150
> =A0 =A0 =A0 =A0hashing 25.189077s thruput=3D62914560.00b/s
>

It looks promising.

> While this fixes the problem at hand, it has not yet enjoyed broader
> testing than running on my desktop and my laptop for a few days. =A0If
> it is going to be accepted, it would be good to have it sit in -mm for
> some time.
>
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 28aafe2..0c88813 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -508,9 +508,6 @@ int page_referenced(struct page *page,
> =A0{
> =A0 =A0 =A0 =A0int referenced =3D 0;
>
> - =A0 =A0 =A0 if (TestClearPageReferenced(page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 referenced++;
> -
> =A0 =A0 =A0 =A0*vm_flags =3D 0;
> =A0 =A0 =A0 =A0if (page_mapped(page) && page->mapping) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageAnon(page))
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 4a7b0d5..c8907a8 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -263,27 +263,6 @@ unsigned long shrink_slab(unsigned long scanned, gfp=
_t gfp_mask,
> =A0 =A0 =A0 =A0return ret;
> =A0}
>
> -/* Called without lock on whether page is mapped, so answer is unstable =
*/
> -static inline int page_mapping_inuse(struct page *page)
> -{
> - =A0 =A0 =A0 struct address_space *mapping;
> -
> - =A0 =A0 =A0 /* Page is in somebody's page tables. */
> - =A0 =A0 =A0 if (page_mapped(page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> -
> - =A0 =A0 =A0 /* Be more reluctant to reclaim swapcache than pagecache */
> - =A0 =A0 =A0 if (PageSwapCache(page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> -
> - =A0 =A0 =A0 mapping =3D page_mapping(page);
> - =A0 =A0 =A0 if (!mapping)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 /* File is mmap'd by somebody? */
> - =A0 =A0 =A0 return mapping_mapped(mapping);
> -}
> -
> =A0static inline int is_page_cache_freeable(struct page *page)
> =A0{
> =A0 =A0 =A0 =A0/*
> @@ -570,6 +549,64 @@ redo:
> =A0 =A0 =A0 =A0put_page(page); =A0 =A0 =A0 =A0 /* drop ref from isolate *=
/
> =A0}
>
> +enum page_reference {
> + =A0 =A0 =A0 PAGEREF_RECLAIM,
> + =A0 =A0 =A0 PAGEREF_KEEP,
> + =A0 =A0 =A0 PAGEREF_ACTIVATE,
> +};
> +
> +static enum page_reference page_check_references(struct scan_control *sc=
,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 struct page *page)
> +{
> + =A0 =A0 =A0 unsigned long vm_flags;
> + =A0 =A0 =A0 int pte_ref, page_ref;
> +
> + =A0 =A0 =A0 pte_ref =3D page_referenced(page, 1, sc->mem_cgroup, &vm_fl=
ags);
> + =A0 =A0 =A0 page_ref =3D TestClearPageReferenced(page);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Lumpy reclaim, ignore references.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PAGEREF_RECLAIM;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* If a PG_mlocked page lost the isolation race,
> + =A0 =A0 =A0 =A0* try_to_unmap() moves it to unevictable list.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (vm_flags & VM_LOCKED)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PAGEREF_RECLAIM;
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* All mapped pages start out with page table references.=
 =A0To
> + =A0 =A0 =A0 =A0* keep use-once mapped file pages off the active list, u=
se
> + =A0 =A0 =A0 =A0* PG_referenced to filter them out.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* If we see the page for the first time here, send it on
> + =A0 =A0 =A0 =A0* another roundtrip on the inactive list.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* If we see it again with another page table reference,
> + =A0 =A0 =A0 =A0* activate it.
> + =A0 =A0 =A0 =A0*
> + =A0 =A0 =A0 =A0* The deactivation code won't remove the mark, thus a pa=
ge
> + =A0 =A0 =A0 =A0* table reference after deactivation reactivates the pag=
e
> + =A0 =A0 =A0 =A0* again.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 if (pte_ref) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageAnon(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PAGEREF_ACTIVATE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageReferenced(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_ref)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PAGEREF_ACTIVATE;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PAGEREF_KEEP;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (page_ref && PageDirty(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return PAGEREF_KEEP;
> +
> + =A0 =A0 =A0 return PAGEREF_RECLAIM;
> +}
> +
> =A0/*
> =A0* shrink_page_list() returns the number of reclaimed pages
> =A0*/
> @@ -581,7 +618,6 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
> =A0 =A0 =A0 =A0struct pagevec freed_pvec;
> =A0 =A0 =A0 =A0int pgactivate =3D 0;
> =A0 =A0 =A0 =A0unsigned long nr_reclaimed =3D 0;
> - =A0 =A0 =A0 unsigned long vm_flags;
>
> =A0 =A0 =A0 =A0cond_resched();
>
> @@ -590,7 +626,6 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct address_space *mapping;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int may_enter_fs;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int referenced;
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();
>
> @@ -632,17 +667,14 @@ static unsigned long shrink_page_list(struct list_h=
ead *page_list,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto keep_=
locked;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 referenced =3D page_referenced(page, 1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 sc->mem_cgroup, &vm_flags);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* In active use or really unfreeable? =
=A0Activate it.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If page which have PG_mlocked lost iso=
ltation race,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* try_to_unmap moves it to unevictable l=
ist
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc->order <=3D PAGE_ALLOC_COSTLY_ORDER =
&&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 referenced && page_mapping_inuse(page)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 && !(vm_flags & VM_LOCKED))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (page_check_references(sc, page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PAGEREF_KEEP:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_locked;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PAGEREF_ACTIVATE:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto activate_locked;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case PAGEREF_RECLAIM:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ; /* try to free the page b=
elow */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Anonymous process memory has backing st=
ore?
> @@ -676,8 +708,6 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (PageDirty(page)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sc->order <=3D PAGE_ALL=
OC_COSTLY_ORDER && referenced)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto keep_l=
ocked;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!may_enter_fs)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto keep_=
locked;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!sc->may_writepage)
> @@ -1346,9 +1376,7 @@ static void shrink_active_list(unsigned long nr_pag=
es, struct zone *zone,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* page_referenced clears PageReferenced */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_mapping_inuse(page) &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_referenced(page, 0, sc->mem_cg=
roup, &vm_flags)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_referenced(page, 0, sc->mem_cgroup=
, &vm_flags)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_rotated++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * Identify referenced, fi=
le-backed active pages and
> --
> 1.6.4.13.ge6580
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
