Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D7DFF6B006C
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 03:59:13 -0500 (EST)
Received: by vcbfo1 with SMTP id fo1so4040381vcb.14
        for <linux-mm@kvack.org>; Sat, 19 Nov 2011 00:59:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1321635524-8586-5-git-send-email-mgorman@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
	<1321635524-8586-5-git-send-email-mgorman@suse.de>
Date: Sat, 19 Nov 2011 16:59:10 +0800
Message-ID: <CAPQyPG4GTccLroA2NsdQK_PH1_KB3dD1v3m1FzenCeDW-8qb+g@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be
 migreated without blocking within ->migratepage
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Sat, Nov 19, 2011 at 12:58 AM, Mel Gorman <mgorman@suse.de> wrote:
> Asynchronous compaction is when allocating transparent hugepages to
> avoid blocking for long periods of time. Due to reports of stalling,
> synchronous compaction is never used but this impacts allocation
> success rates. When deciding whether to migrate dirty pages, the
> following check is made
>
> =A0 =A0 =A0 =A0if (PageDirty(page) && !sync &&
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mapping->a_ops->migratepage !=3D migrate_p=
age)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EBUSY;
>
> This skips over all pages using buffer_migrate_page() even though
> it is possible to migrate some of these pages without blocking. This
> patch updates the ->migratepage callback with a "sync" parameter. It
> is the resposibility of the callback to gracefully fail migration of
> the page if it cannot be achieved without blocking.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> ---
> =A0fs/btrfs/disk-io.c =A0 =A0 =A0| =A0 =A02 +-
> =A0fs/nfs/internal.h =A0 =A0 =A0 | =A0 =A02 +-
> =A0fs/nfs/write.c =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A0include/linux/fs.h =A0 =A0 =A0| =A0 =A09 +++-
> =A0include/linux/migrate.h | =A0 =A02 +-
> =A0mm/migrate.c =A0 =A0 =A0 =A0 =A0 =A0| =A0106 +++++++++++++++++++++++++=
+++++++---------------
> =A06 files changed, 83 insertions(+), 42 deletions(-)
>
> diff --git a/fs/btrfs/disk-io.c b/fs/btrfs/disk-io.c
> index 62afe5c..f841f00 100644
> --- a/fs/btrfs/disk-io.c
> +++ b/fs/btrfs/disk-io.c
> @@ -872,7 +872,7 @@ static int btree_submit_bio_hook(struct inode *inode,=
 int rw, struct bio *bio,
>
> =A0#ifdef CONFIG_MIGRATION
> =A0static int btree_migratepage(struct address_space *mapping,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *newpage, struc=
t page *page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *newpage, struc=
t page *page, bool sync)
> =A0{
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * we can't safely write a btree page from here,
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index c1a1bd8..d0c460f 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -328,7 +328,7 @@ void nfs_commit_release_pages(struct nfs_write_data *=
data);
>
> =A0#ifdef CONFIG_MIGRATION
> =A0extern int nfs_migrate_page(struct address_space *,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *, struct page *);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *, struct page *, bool);
> =A0#else
> =A0#define nfs_migrate_page NULL
> =A0#endif
> diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> index 1dda78d..33475df 100644
> --- a/fs/nfs/write.c
> +++ b/fs/nfs/write.c
> @@ -1711,7 +1711,7 @@ out_error:
>
> =A0#ifdef CONFIG_MIGRATION
> =A0int nfs_migrate_page(struct address_space *mapping, struct page *newpa=
ge,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *page, bool sync)
> =A0{
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * If PagePrivate is set, then the page is currently assoc=
iated with
> @@ -1726,7 +1726,7 @@ int nfs_migrate_page(struct address_space *mapping,=
 struct page *newpage,
>
> =A0 =A0 =A0 =A0nfs_fscache_release_page(page, GFP_KERNEL);
>
> - =A0 =A0 =A0 return migrate_page(mapping, newpage, page);
> + =A0 =A0 =A0 return migrate_page(mapping, newpage, page, sync);
> =A0}
> =A0#endif
>
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 0c4df26..67f8e46 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -609,9 +609,12 @@ struct address_space_operations {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0loff_t offset, unsigned lo=
ng nr_segs);
> =A0 =A0 =A0 =A0int (*get_xip_mem)(struct address_space *, pgoff_t, int,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0void **, unsigned long *);
> - =A0 =A0 =A0 /* migrate the contents of a page to the specified target *=
/
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* migrate the contents of a page to the specified target=
. If sync
> + =A0 =A0 =A0 =A0* is false, it must not block. If it needs to block, ret=
urn -EBUSY
> + =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0int (*migratepage) (struct address_space *,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *, struct page =
*);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *, struct page =
*, bool);
> =A0 =A0 =A0 =A0int (*launder_page) (struct page *);
> =A0 =A0 =A0 =A0int (*is_partially_uptodate) (struct page *, read_descript=
or_t *,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0unsigned long);
> @@ -2577,7 +2580,7 @@ extern int generic_check_addressable(unsigned, u64)=
;
>
> =A0#ifdef CONFIG_MIGRATION
> =A0extern int buffer_migrate_page(struct address_space *,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page=
 *, struct page *);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page=
 *, struct page *, bool);
> =A0#else
> =A0#define buffer_migrate_page NULL
> =A0#endif
> diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> index e39aeec..14e6d2a 100644
> --- a/include/linux/migrate.h
> +++ b/include/linux/migrate.h
> @@ -11,7 +11,7 @@ typedef struct page *new_page_t(struct page *, unsigned=
 long private, int **);
>
> =A0extern void putback_lru_pages(struct list_head *l);
> =A0extern int migrate_page(struct address_space *,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *, struct page =
*);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *, struct page =
*, bool);
> =A0extern int migrate_pages(struct list_head *l, new_page_t x,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long private, boo=
l offlining,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bool sync);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 578e291..8395697 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -415,7 +415,7 @@ EXPORT_SYMBOL(fail_migrate_page);
> =A0* Pages are locked upon entry and exit.
> =A0*/
> =A0int migrate_page(struct address_space *mapping,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *newpage, struct page *page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *newpage, struct page *page, bo=
ol sync)
> =A0{
> =A0 =A0 =A0 =A0int rc;
>
> @@ -432,19 +432,60 @@ int migrate_page(struct address_space *mapping,
> =A0EXPORT_SYMBOL(migrate_page);
>
> =A0#ifdef CONFIG_BLOCK
> +
> +/* Returns true if all buffers are successfully locked */
> +bool buffer_migrate_lock_buffers(struct buffer_head *head, bool sync)
> +{
> + =A0 =A0 =A0 struct buffer_head *bh =3D head;
> +
> + =A0 =A0 =A0 /* Simple case, sync compaction */
> + =A0 =A0 =A0 if (sync) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_bh(bh);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_buffer(bh);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh =3D bh->b_this_page;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (bh !=3D head);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return true;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 /* async case, we cannot block on lock_buffer so use tryloc=
k_buffer */
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_bh(bh);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!trylock_buffer(bh)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We failed to lock the =
buffer and cannot stall in
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* async migration. Relea=
se the taken locks
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct buffer_head *failed_=
bh =3D bh;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh =3D head;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_buff=
er(bh);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 put_bh(bh);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh =3D bh->=
b_this_page;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (bh !=3D failed_bh)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh =3D bh->b_this_page;
> + =A0 =A0 =A0 } while (bh !=3D head);
> + =A0 =A0 =A0 return true;
> +}
> +
> =A0/*
> =A0* Migration function for pages with buffers. This function can only be=
 used
> =A0* if the underlying filesystem guarantees that no other references to =
"page"
> =A0* exist.
> =A0*/
> =A0int buffer_migrate_page(struct address_space *mapping,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *newpage, struct page *page)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct page *newpage, struct page *page, bo=
ol sync)
> =A0{
> =A0 =A0 =A0 =A0struct buffer_head *bh, *head;
> =A0 =A0 =A0 =A0int rc;
>
> =A0 =A0 =A0 =A0if (!page_has_buffers(page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return migrate_page(mapping, newpage, page)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return migrate_page(mapping, newpage, page,=
 sync);
>
> =A0 =A0 =A0 =A0head =3D page_buffers(page);
>
> @@ -453,13 +494,18 @@ int buffer_migrate_page(struct address_space *mappi=
ng,
> =A0 =A0 =A0 =A0if (rc)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return rc;
>
> - =A0 =A0 =A0 bh =3D head;
> - =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 get_bh(bh);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_buffer(bh);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 bh =3D bh->b_this_page;
> -
> - =A0 =A0 =A0 } while (bh !=3D head);
> + =A0 =A0 =A0 if (!buffer_migrate_lock_buffers(head, sync)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* We have to revert the radix tree updat=
e. If this returns
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* non-zero, it either means that the pag=
e count changed
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* which "can't happen" or the slot chang=
ed from underneath
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* us in which case someone operated on a=
 page that did not
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* have buffers fully migrated which is a=
larming so warn
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* that it happened.
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 WARN_ON(migrate_page_move_mapping(mapping, =
page, newpage));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;

If this migrate_page_move_mapping() really fails, seems disk IO will be nee=
ded
to bring the previously already cached page back, I wonder if we should mak=
e the
double check for the two conditions of "page refs is ok " and "all bh
trylocked"
before doing radix_tree_replace_slot() ? which I think does not
involve IO on the
error path.


Nai

> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0ClearPagePrivate(page);
> =A0 =A0 =A0 =A0set_page_private(newpage, page_private(page));
> @@ -536,10 +582,13 @@ static int writeout(struct address_space *mapping, =
struct page *page)
> =A0* Default handling if a filesystem does not provide a migration functi=
on.
> =A0*/
> =A0static int fallback_migrate_page(struct address_space *mapping,
> - =A0 =A0 =A0 struct page *newpage, struct page *page)
> + =A0 =A0 =A0 struct page *newpage, struct page *page, bool sync)
> =A0{
> - =A0 =A0 =A0 if (PageDirty(page))
> + =A0 =A0 =A0 if (PageDirty(page)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!sync)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return writeout(mapping, page);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Buffers may be managed in a filesystem specific way.
> @@ -549,7 +598,7 @@ static int fallback_migrate_page(struct address_space=
 *mapping,
> =A0 =A0 =A0 =A0 =A0 =A0!try_to_release_page(page, GFP_KERNEL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EAGAIN;
>
> - =A0 =A0 =A0 return migrate_page(mapping, newpage, page);
> + =A0 =A0 =A0 return migrate_page(mapping, newpage, page, sync);
> =A0}
>
> =A0/*
> @@ -585,29 +634,18 @@ static int move_to_new_page(struct page *newpage, s=
truct page *page,
>
> =A0 =A0 =A0 =A0mapping =3D page_mapping(page);
> =A0 =A0 =A0 =A0if (!mapping)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D migrate_page(mapping, newpage, page)=
;
> - =A0 =A0 =A0 else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D migrate_page(mapping, newpage, page,=
 sync);
> + =A0 =A0 =A0 else if (mapping->a_ops->migratepage)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Do not writeback pages if !sync and mi=
gratepage is
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* not pointing to migrate_page() which i=
s nonblocking
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* (swapcache/tmpfs uses migratepage =3D =
migrate_page).
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Most pages have a mapping and most fil=
esystems provide a
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* migratepage callback. Anonymous pages =
are part of swap
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* space which also has its own migratepa=
ge callback. This
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* is the most common path for page migra=
tion.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageDirty(page) && !sync &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->a_ops->migratepage !=3D mi=
grate_page)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D -EBUSY;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else if (mapping->a_ops->migratepage)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* Most pages have a mapp=
ing and most filesystems
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* should provide a migra=
tion function. Anonymous
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* pages are part of swap=
 space which also has its
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* own migration function=
. This is the most common
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* path for page migratio=
n.
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D mapping->a_ops->migr=
atepage(mapping,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 newpage, page);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D fallback_migrate_pag=
e(mapping, newpage, page);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D mapping->a_ops->migratepage(mapping,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 newpage, page, sync);
> + =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D fallback_migrate_page(mapping, newpa=
ge, page, sync);
>
> =A0 =A0 =A0 =A0if (rc) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0newpage->mapping =3D NULL;
> --
> 1.7.3.4
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter=
.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
