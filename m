Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 582706B00A7
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 18:41:51 -0500 (EST)
Received: by iyj17 with SMTP id 17so1181266iyj.14
        for <linux-mm@kvack.org>; Wed, 15 Dec 2010 15:41:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
References: <E1PStc6-0006Cd-0Z@pomaz-ex.szeredi.hu>
Date: Thu, 16 Dec 2010 08:22:55 +0900
Message-ID: <AANLkTikXQmsgZ8Ea-GoQ4k2St6yCJj8Z3XthuBQ9u+EV@mail.gmail.com>
Subject: Re: [PATCH] mm: add replace_page_cache_page() function
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 12:49 AM, Miklos Szeredi <miklos@szeredi.hu> wrote:
> From: Miklos Szeredi <mszeredi@suse.cz>
>
> This function basically does:
>
> =A0 =A0 remove_from_page_cache(old);
> =A0 =A0 page_cache_release(old);
> =A0 =A0 add_to_page_cache_locked(new);
>
> Except it does this atomically, so there's no possibility for the
> "add" to fail because of a race.
>
> This is used by fuse to move pages into the page cache.

Please write down why fuse need this new atomic function in description.

>
> Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
> ---
> =A0fs/fuse/dev.c =A0 =A0 =A0 =A0 =A0 | =A0 10 ++++------
> =A0include/linux/pagemap.h | =A0 =A01 +
> =A0mm/filemap.c =A0 =A0 =A0 =A0 =A0 =A0| =A0 41 +++++++++++++++++++++++++=
++++++++++++++++
> =A03 files changed, 46 insertions(+), 6 deletions(-)
>
> Index: linux-2.6/mm/filemap.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/mm/filemap.c 2010-12-15 16:39:55.000000000 +0100
> +++ linux-2.6/mm/filemap.c =A0 =A0 =A02010-12-15 16:41:24.000000000 +0100
> @@ -389,6 +389,47 @@ int filemap_write_and_wait_range(struct
> =A0}
> =A0EXPORT_SYMBOL(filemap_write_and_wait_range);
>

This function is exported.
Please, add function description

> +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gf=
p_mask)
> +{
> + =A0 =A0 =A0 int error;
> +
> + =A0 =A0 =A0 VM_BUG_ON(!PageLocked(old));
> + =A0 =A0 =A0 VM_BUG_ON(!PageLocked(new));
> + =A0 =A0 =A0 VM_BUG_ON(new->mapping);
> +
> + =A0 =A0 =A0 error =3D mem_cgroup_cache_charge(new, current->mm,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 gfp_mask & GFP_RECLAIM_MASK);
> + =A0 =A0 =A0 if (error)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
> +
> + =A0 =A0 =A0 error =3D radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
> + =A0 =A0 =A0 if (error =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct address_space *mapping =3D old->mapp=
ing;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pgoff_t offset =3D old->index;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_get(new);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->mapping =3D mapping;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 new->index =3D offset;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock_irq(&mapping->tree_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __remove_from_page_cache(old);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 error =3D radix_tree_insert(&mapping->page_=
tree, offset, new);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BUG_ON(error);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping->nrpages++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(new, NR_FILE_PAGES);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageSwapBacked(new))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __inc_zone_page_state(new, =
NR_SHMEM);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock_irq(&mapping->tree_lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 radix_tree_preload_end();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_uncharge_cache_page(old);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(old);

Why do you release reference of old?

> + =A0 =A0 =A0 } else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_uncharge_cache_page(new);
> +out:
> + =A0 =A0 =A0 return error;
> +}
> +EXPORT_SYMBOL_GPL(replace_page_cache_page);
> +
> =A0/**
> =A0* add_to_page_cache_locked - add a locked page to the pagecache
> =A0* @page: =A0 =A0 =A0page to add
> Index: linux-2.6/include/linux/pagemap.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/pagemap.h =A0 =A0 =A02010-12-15 16:39:39=
.000000000 +0100
> +++ linux-2.6/include/linux/pagemap.h =A0 2010-12-15 16:41:24.000000000 +=
0100
> @@ -457,6 +457,7 @@ int add_to_page_cache_lru(struct page *p
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pgoff_t in=
dex, gfp_t gfp_mask);
> =A0extern void remove_from_page_cache(struct page *page);
> =A0extern void __remove_from_page_cache(struct page *page);
> +int replace_page_cache_page(struct page *old, struct page *new, gfp_t gf=
p_mask);
>
> =A0/*
> =A0* Like add_to_page_cache_locked, but used to add newly allocated pages=
:
> Index: linux-2.6/fs/fuse/dev.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/fs/fuse/dev.c =A0 =A0 =A0 =A02010-12-15 16:39:39.00000=
0000 +0100
> +++ linux-2.6/fs/fuse/dev.c =A0 =A0 2010-12-15 16:41:24.000000000 +0100
> @@ -729,14 +729,12 @@ static int fuse_try_move_page(struct fus
> =A0 =A0 =A0 =A0if (WARN_ON(PageMlocked(oldpage)))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out_fallback_unlock;
>
> - =A0 =A0 =A0 remove_from_page_cache(oldpage);
> - =A0 =A0 =A0 page_cache_release(oldpage);
> -
> - =A0 =A0 =A0 err =3D add_to_page_cache_locked(newpage, mapping, index, G=
FP_KERNEL);
> + =A0 =A0 =A0 err =3D replace_page_cache_page(oldpage, newpage, GFP_KERNE=
L);
> =A0 =A0 =A0 =A0if (err) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "fuse_try_move_page: fa=
iled to add page");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_fallback_unlock;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page(newpage);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return err;
> =A0 =A0 =A0 =A0}
> +
> =A0 =A0 =A0 =A0page_cache_get(newpage);
>
> =A0 =A0 =A0 =A0if (!(buf->flags & PIPE_BUF_FLAG_LRU))
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
