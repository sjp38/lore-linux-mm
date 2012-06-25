Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D92FD6B03BD
	for <linux-mm@kvack.org>; Mon, 25 Jun 2012 19:31:39 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so2395587wib.8
        for <linux-mm@kvack.org>; Mon, 25 Jun 2012 16:31:38 -0700 (PDT)
MIME-Version: 1.0
Reply-To: konrad@darnok.org
In-Reply-To: <7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com>
References: <cover.1340665087.git.aquini@redhat.com>
	<7f83427b3894af7969c67acc0f27ab5aa68b4279.1340665087.git.aquini@redhat.com>
Date: Mon, 25 Jun 2012 19:31:38 -0400
Message-ID: <CAPbh3rvN0U=xVuqb=7wHkbEAgM=dC67uG-1=m=8GAv9MNX7LWg@mail.gmail.com>
Subject: Re: [PATCH 1/4] mm: introduce compaction and migration for virtio
 ballooned pages
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>

On Mon, Jun 25, 2012 at 7:25 PM, Rafael Aquini <aquini@redhat.com> wrote:
> This patch introduces helper functions that teach compaction and migratio=
n bits
> how to cope with pages which are part of a guest memory balloon, in order=
 to
> make them movable by memory compaction procedures.
>

Should the names that are exported be prefixed with kvm_?

> Signed-off-by: Rafael Aquini <aquini@redhat.com>
> ---
> =A0include/linux/mm.h | =A0 17 +++++++++++++
> =A0mm/compaction.c =A0 =A0| =A0 72 ++++++++++++++++++++++++++++++++++++++=
++++++++++++++
> =A0mm/migrate.c =A0 =A0 =A0 | =A0 30 +++++++++++++++++++++-
> =A03 files changed, 118 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b36d08c..360656e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1629,5 +1629,22 @@ static inline unsigned int debug_guardpage_minorde=
r(void) { return 0; }
> =A0static inline bool page_is_guard(struct page *page) { return false; }
> =A0#endif /* CONFIG_DEBUG_PAGEALLOC */
>
> +#if (defined(CONFIG_VIRTIO_BALLOON) || \
> + =A0 =A0 =A0 defined(CONFIG_VIRTIO_BALLOON_MODULE)) && defined(CONFIG_CO=
MPACTION)
> +extern int is_balloon_page(struct page *);
> +extern int isolate_balloon_page(struct page *);
> +extern int putback_balloon_page(struct page *);
> +
> +/* return 1 if page is part of a guest's memory balloon, 0 otherwise */
> +static inline int PageBalloon(struct page *page)
> +{
> + =A0 =A0 =A0 return is_balloon_page(page);
> +}
> +#else
> +static inline int PageBalloon(struct page *page) =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 { return 0; }
> +static inline int isolate_balloon_page(struct page *page) =A0 =A0 =A0{ r=
eturn 0; }
> +static inline int putback_balloon_page(struct page *page) =A0 =A0 =A0{ r=
eturn 0; }
> +#endif /* (VIRTIO_BALLOON || VIRTIO_BALLOON_MODULE) && COMPACTION */
> +
> =A0#endif /* __KERNEL__ */
> =A0#endif /* _LINUX_MM_H */
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 7ea259d..8835d55 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -14,6 +14,7 @@
> =A0#include <linux/backing-dev.h>
> =A0#include <linux/sysctl.h>
> =A0#include <linux/sysfs.h>
> +#include <linux/export.h>
> =A0#include "internal.h"
>
> =A0#if defined CONFIG_COMPACTION || defined CONFIG_CMA
> @@ -312,6 +313,14 @@ isolate_migratepages_range(struct zone *zone, struct=
 compact_control *cc,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* For ballooned pages, we need to isolat=
e them before testing
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* for PageLRU, as well as skip the LRU p=
age isolation steps.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageBalloon(page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (isolate_balloon_page(pa=
ge))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto isolat=
ed_balloon_page;
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!PageLRU(page))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>
> @@ -338,6 +347,7 @@ isolate_migratepages_range(struct zone *zone, struct =
compact_control *cc,
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Successfully isolated */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0del_page_from_lru_list(page, lruvec, page_=
lru(page));
> +isolated_balloon_page:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_add(&page->lru, migratelist);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cc->nr_migratepages++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0nr_isolated++;
> @@ -903,4 +913,66 @@ void compaction_unregister_node(struct node *node)
> =A0}
> =A0#endif /* CONFIG_SYSFS && CONFIG_NUMA */
>
> +#if defined(CONFIG_VIRTIO_BALLOON) || defined(CONFIG_VIRTIO_BALLOON_MODU=
LE)
> +/*
> + * Balloon pages special page->mapping.
> + * users must properly allocate and initiliaze an instance of balloon_ma=
pping,
> + * and set it as the page->mapping for balloon enlisted page instances.
> + *
> + * address_space_operations necessary methods for ballooned pages:
> + * =A0 .migratepage =A0 =A0- used to perform balloon's page migration (a=
s is)
> + * =A0 .invalidatepage - used to isolate a page from balloon's page list
> + * =A0 .freepage =A0 =A0 =A0 - used to reinsert an isolated page to ball=
oon's page list
> + */
> +struct address_space *balloon_mapping;
> +EXPORT_SYMBOL(balloon_mapping);
> +
> +/* ballooned page id check */
> +int is_balloon_page(struct page *page)
> +{
> + =A0 =A0 =A0 struct address_space *mapping =3D page->mapping;
> + =A0 =A0 =A0 if (mapping =3D=3D balloon_mapping)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* __isolate_lru_page() counterpart for a ballooned page */
> +int isolate_balloon_page(struct page *page)
> +{
> + =A0 =A0 =A0 struct address_space *mapping =3D page->mapping;
> + =A0 =A0 =A0 if (mapping->a_ops->invalidatepage) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We can race against move_to_new_page()=
 and stumble across a
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* locked 'newpage'. If we succeed on iso=
lating it, the result
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* tends to be disastrous. So, we sanely =
skip PageLocked here.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (likely(!PageLocked(page) && get_page_un=
less_zero(page))) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* A ballooned page, by d=
efault, has just one refcount.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Prevent concurrent com=
paction threads from isolating
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* an already isolated ba=
lloon page.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_count(page) =3D=3D=
 2) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->a_=
ops->invalidatepage(page, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Drop refcount taken for =
this already isolated page */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +
> +/* putback_lru_page() counterpart for a ballooned page */
> +int putback_balloon_page(struct page *page)
> +{
> + =A0 =A0 =A0 struct address_space *mapping =3D page->mapping;
> + =A0 =A0 =A0 if (mapping->a_ops->freepage) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->a_ops->freepage(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> +}
> +#endif /* CONFIG_VIRTIO_BALLOON || CONFIG_VIRTIO_BALLOON_MODULE */
> =A0#endif /* CONFIG_COMPACTION */
> diff --git a/mm/migrate.c b/mm/migrate.c
> index be26d5c..ffc02a4 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -78,7 +78,10 @@ void putback_lru_pages(struct list_head *l)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del(&page->lru);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dec_zone_page_state(page, NR_ISOLATED_ANON=
 +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page_is_fi=
le_cache(page));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 putback_lru_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (unlikely(PageBalloon(page)))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(!putback_balloon_=
page(page));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 putback_lru_page(page);
> =A0 =A0 =A0 =A0}
> =A0}
>
> @@ -783,6 +786,17 @@ static int __unmap_and_move(struct page *page, struc=
t page *newpage,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
>
> + =A0 =A0 =A0 if (PageBalloon(page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* A ballooned page does not need any spe=
cial attention from
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* physical to virtual reverse mapping pr=
ocedures.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* To avoid burning cycles at rmap level,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* skip attempts to unmap PTEs or remap s=
wapcache.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 remap_swapcache =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto skip_unmap;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Corner case handling:
> =A0 =A0 =A0 =A0 * 1. When a new swap-cache page is read into, it is added=
 to the LRU
> @@ -852,6 +866,20 @@ static int unmap_and_move(new_page_t get_new_page, u=
nsigned long private,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> =A0 =A0 =A0 =A0rc =3D __unmap_and_move(page, newpage, force, offlining, m=
ode);
> +
> + =A0 =A0 =A0 if (PageBalloon(newpage)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* A ballooned page has been migrated alr=
eady. Now, it is the
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* time to wrap-up counters, handle the o=
ld page back to Buddy
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* and return.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_zone_page_state(page, NR_ISOLATED_ANON =
+
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pag=
e_is_file_cache(page));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_page(page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return rc;
> + =A0 =A0 =A0 }
> =A0out:
> =A0 =A0 =A0 =A0if (rc !=3D -EAGAIN) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> --
> 1.7.10.2
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
