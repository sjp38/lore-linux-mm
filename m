Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 90F8B6B0095
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 09:50:53 -0500 (EST)
Received: by gwb17 with SMTP id 17so2239787gwb.30
        for <linux-mm@kvack.org>; Thu, 16 Dec 2010 06:50:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1012142020030.12693@tigran.mtv.corp.google.com>
References: <20101130194945.58962c44@xenia.leun.net>
	<alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com>
	<E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu>
	<20101201124528.6809c539@xenia.leun.net>
	<E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
	<20101202084159.6bff7355@xenia.leun.net>
	<20101202091552.4a63f717@xenia.leun.net>
	<E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu>
	<20101202115722.1c00afd5@xenia.leun.net>
	<20101203085350.55f94057@xenia.leun.net>
	<E1PPaIw-0004pW-Mk@pomaz-ex.szeredi.hu>
	<20101206204303.1de6277b@xenia.leun.net>
	<E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu>
	<20101213142059.643f8080.akpm@linux-foundation.org>
	<E1PSSO8-0003sy-Vr@pomaz-ex.szeredi.hu>
	<alpine.LSU.2.00.1012142020030.12693@tigran.mtv.corp.google.com>
Date: Thu, 16 Dec 2010 15:50:50 +0100
Message-ID: <AANLkTim-WizK2PrfGM0zJ1=_VQkJao-D7oAcQ_et7-fi@mail.gmail.com>
Subject: Re: kernel BUG at mm/truncate.c:475!
From: =?UTF-8?B?Um9iZXJ0IMWad2nEmWNraQ==?= <robert@swiecki.net>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, Andrew Morton <akpm@linux-foundation.org>, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>
> Yes, this looks to me like what is needed for now.
>
> I'd feel rather happier about it if I thought it would also fix
> Robert's kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
> but I've still not found time to explain that one.
>
> Robert, you said yours is usually repeatable in 12 hours - any chance
> you could give iknowthis a run with the patch below, to see if it
> makes any difference to yours? =C2=A0(I admit I don't see how it would.)

Hi Hugh,

Do you still want me to do that?

> Thanks,
> Hugh
>
>>
>> ---
> =C2=A0fs/gfs2/main.c =C2=A0 =C2=A0 | =C2=A0 =C2=A09 +--------
> =C2=A0fs/inode.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 22 +++++++++++++++-=
------
> =C2=A0fs/nilfs2/btnode.c | =C2=A0 =C2=A05 -----
> =C2=A0fs/nilfs2/btnode.h | =C2=A0 =C2=A01 -
> =C2=A0fs/nilfs2/mdt.c =C2=A0 =C2=A0| =C2=A0 =C2=A04 ++--
> =C2=A0fs/nilfs2/page.c =C2=A0 | =C2=A0 13 -------------
> =C2=A0fs/nilfs2/page.h =C2=A0 | =C2=A0 =C2=A01 -
> =C2=A0fs/nilfs2/super.c =C2=A0| =C2=A0 =C2=A02 +-
> =C2=A0include/linux/fs.h | =C2=A0 =C2=A02 ++
> =C2=A0mm/memory.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A02 ++
> =C2=A010 files changed, 23 insertions(+), 38 deletions(-)
>
> Index: linux.git/mm/memory.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/mm/memory.c =C2=A02010-12-11 14:09:55.000000000 +0100
> +++ linux.git/mm/memory.c =C2=A0 =C2=A0 =C2=A0 2010-12-14 11:20:47.000000=
000 +0100
> @@ -2572,6 +2572,7 @@ void unmap_mapping_range(struct address_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0details.last_index=
 =3D ULONG_MAX;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0details.i_mmap_lock =3D &mapping->i_mmap_lock;
>
> + =C2=A0 =C2=A0 =C2=A0 mutex_lock(&mapping->unmap_mutex);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_lock(&mapping->i_mmap_lock);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/* Protect against endless unmapping loops */
> @@ -2588,6 +2589,7 @@ void unmap_mapping_range(struct address_
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (unlikely(!list_empty(&mapping->i_mmap_nonl=
inear)))
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0unmap_mapping_rang=
e_list(&mapping->i_mmap_nonlinear, &details);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&mapping->i_mmap_lock);Hi,
> + =C2=A0 =C2=A0 =C2=A0 mutex_unlock(&mapping->unmap_mutex);
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(unmap_mapping_range);
>
> Index: linux.git/fs/gfs2/main.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/gfs2/main.c =C2=A0 =C2=A0 =C2=A0 2010-11-26 10:52:1=
6.000000000 +0100
> +++ linux.git/fs/gfs2/main.c =C2=A0 =C2=A02010-12-14 11:15:53.000000000 +=
0100
> @@ -59,14 +59,7 @@ static void gfs2_init_gl_aspace_once(voi
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space *mapping =3D (struct addr=
ess_space *)(gl + 1);
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0gfs2_init_glock_once(gl);
> - =C2=A0 =C2=A0 =C2=A0 memset(mapping, 0, sizeof(*mapping));
> - =C2=A0 =C2=A0 =C2=A0 INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->tree_lock);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->i_mmap_lock);
> - =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&mapping->private_list);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->private_lock);
> - =C2=A0 =C2=A0 =C2=A0 INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
> - =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
> + =C2=A0 =C2=A0 =C2=A0 address_space_init_once(mapping);
> =C2=A0}
>
> =C2=A0/**
> Index: linux.git/fs/inode.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/inode.c =C2=A0 2010-11-26 10:52:16.000000000 +0100
> +++ linux.git/fs/inode.c =C2=A0 =C2=A0 =C2=A0 =C2=A02010-12-14 11:21:49.0=
00000000 +0100
> @@ -280,6 +280,20 @@ static void destroy_inode(struct inode *
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0kmem_cache_free(in=
ode_cachep, (inode));
> =C2=A0}
>
> +void address_space_init_once(struct address_space *mapping)
> +{
> + =C2=A0 =C2=A0 =C2=A0 memset(mapping, 0, sizeof(*mapping));
> + =C2=A0 =C2=A0 =C2=A0 INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->tree_lock);
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->i_mmap_lock);
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&mapping->private_list);
> + =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->private_lock);
> + =C2=A0 =C2=A0 =C2=A0 INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
> + =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
> + =C2=A0 =C2=A0 =C2=A0 mutex_init(&mapping->unmap_mutex);
> +}
> +EXPORT_SYMBOL(address_space_init_once);
> +
> =C2=A0/*
> =C2=A0* These are initializations that only need to be done
> =C2=A0* once, because the fields are idempotent across use
> @@ -293,13 +307,7 @@ void inode_init_once(struct inode *inode
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&inode->i_devices);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&inode->i_wb_list);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&inode->i_lru);
> - =C2=A0 =C2=A0 =C2=A0 INIT_RADIX_TREE(&inode->i_data.page_tree, GFP_ATOM=
IC);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&inode->i_data.tree_lock);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&inode->i_data.i_mmap_lock);
> - =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&inode->i_data.private_list);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&inode->i_data.private_lock);
> - =C2=A0 =C2=A0 =C2=A0 INIT_RAW_PRIO_TREE_ROOT(&inode->i_data.i_mmap);
> - =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&inode->i_data.i_mmap_nonlinear);
> + =C2=A0 =C2=A0 =C2=A0 address_space_init_once(&inode->i_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0i_size_ordered_init(inode);
> =C2=A0#ifdef CONFIG_FSNOTIFY
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_HLIST_HEAD(&inode->i_fsnotify_marks);
> Index: linux.git/fs/nilfs2/btnode.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/nilfs2/btnode.c =C2=A0 2010-11-26 10:52:17.00000000=
0 +0100
> +++ linux.git/fs/nilfs2/btnode.c =C2=A0 =C2=A0 =C2=A0 =C2=A02010-12-14 11=
:19:52.000000000 +0100
> @@ -35,11 +35,6 @@
> =C2=A0#include "btnode.h"
>
>
> -void nilfs_btnode_cache_init_once(struct address_space *btnc)
> -{
> - =C2=A0 =C2=A0 =C2=A0 nilfs_mapping_init_once(btnc);
> -}
> -
> =C2=A0static const struct address_space_operations def_btnode_aops =3D {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0.sync_page =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0=3D block_sync_page,
> =C2=A0};
> Index: linux.git/fs/nilfs2/btnode.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/nilfs2/btnode.h =C2=A0 2010-10-05 18:49:12.00000000=
0 +0200
> +++ linux.git/fs/nilfs2/btnode.h =C2=A0 =C2=A0 =C2=A0 =C2=A02010-12-14 11=
:20:01.000000000 +0100
> @@ -37,7 +37,6 @@ struct nilfs_btnode_chkey_ctxt {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct buffer_head *newbh;
> =C2=A0};
>
> -void nilfs_btnode_cache_init_once(struct address_space *);
> =C2=A0void nilfs_btnode_cache_init(struct address_space *, struct backing=
_dev_info *);
> =C2=A0void nilfs_btnode_cache_clear(struct address_space *);
> =C2=A0struct buffer_head *nilfs_btnode_create_block(struct address_space =
*btnc,
> Index: linux.git/fs/nilfs2/mdt.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/nilfs2/mdt.c =C2=A0 =C2=A0 =C2=A02010-11-26 10:52:1=
7.000000000 +0100
> +++ linux.git/fs/nilfs2/mdt.c =C2=A0 2010-12-14 11:18:18.000000000 +0100
> @@ -460,9 +460,9 @@ int nilfs_mdt_setup_shadow_map(struct in
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct backing_dev_info *bdi =3D inode->i_sb->=
s_bdi;
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0INIT_LIST_HEAD(&shadow->frozen_buffers);
> - =C2=A0 =C2=A0 =C2=A0 nilfs_mapping_init_once(&shadow->frozen_data);
> + =C2=A0 =C2=A0 =C2=A0 address_space_init_once(&shadow->frozen_data);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nilfs_mapping_init(&shadow->frozen_data, bdi, =
&shadow_map_aops);
> - =C2=A0 =C2=A0 =C2=A0 nilfs_mapping_init_once(&shadow->frozen_btnodes);
> + =C2=A0 =C2=A0 =C2=A0 address_space_init_once(&shadow->frozen_btnodes);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0nilfs_mapping_init(&shadow->frozen_btnodes, bd=
i, &shadow_map_aops);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0mi->mi_shadow =3D shadow;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return 0;
> Index: linux.git/fs/nilfs2/page.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/nilfs2/page.c =C2=A0 =C2=A0 2010-11-26 10:52:17.000=
000000 +0100
> +++ linux.git/fs/nilfs2/page.c =C2=A02010-12-14 11:17:26.000000000 +0100
> @@ -492,19 +492,6 @@ unsigned nilfs_page_count_clean_buffers(
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return nc;
> =C2=A0}
>
> -void nilfs_mapping_init_once(struct address_space *mapping)
> -{
> - =C2=A0 =C2=A0 =C2=A0 memset(mapping, 0, sizeof(*mapping));
> - =C2=A0 =C2=A0 =C2=A0 INIT_RADIX_TREE(&mapping->page_tree, GFP_ATOMIC);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->tree_lock);
> - =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&mapping->private_list);
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->private_lock);
> -
> - =C2=A0 =C2=A0 =C2=A0 spin_lock_init(&mapping->i_mmap_lock);
> - =C2=A0 =C2=A0 =C2=A0 INIT_RAW_PRIO_TREE_ROOT(&mapping->i_mmap);
> - =C2=A0 =C2=A0 =C2=A0 INIT_LIST_HEAD(&mapping->i_mmap_nonlinear);
> -}
> -
> =C2=A0void nilfs_mapping_init(struct address_space *mapping,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct backing_dev_info *bdi,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0const struct address_space_operations *aops)
> Index: linux.git/fs/nilfs2/page.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/nilfs2/page.h =C2=A0 =C2=A0 2010-11-26 10:52:17.000=
000000 +0100
> +++ linux.git/fs/nilfs2/page.h =C2=A02010-12-14 11:17:35.000000000 +0100
> @@ -61,7 +61,6 @@ void nilfs_free_private_page(struct page
> =C2=A0int nilfs_copy_dirty_pages(struct address_space *, struct address_s=
pace *);
> =C2=A0void nilfs_copy_back_pages(struct address_space *, struct address_s=
pace *);
> =C2=A0void nilfs_clear_dirty_pages(struct address_space *);
> -void nilfs_mapping_init_once(struct address_space *mapping);
> =C2=A0void nilfs_mapping_init(struct address_space *mapping,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0struct backing_dev_info *bdi,
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0const struct address_space_operations *aops);
> Index: linux.git/fs/nilfs2/super.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/fs/nilfs2/super.c =C2=A0 =C2=A02010-11-26 10:52:17.000=
000000 +0100
> +++ linux.git/fs/nilfs2/super.c 2010-12-14 11:20:19.000000000 +0100
> @@ -1262,7 +1262,7 @@ static void nilfs_inode_init_once(void *
> =C2=A0#ifdef CONFIG_NILFS_XATTR
> =C2=A0 =C2=A0 =C2=A0 =C2=A0init_rwsem(&ii->xattr_sem);
> =C2=A0#endif
> - =C2=A0 =C2=A0 =C2=A0 nilfs_btnode_cache_init_once(&ii->i_btnode_cache);
> + =C2=A0 =C2=A0 =C2=A0 address_space_init_once(&ii->i_btnode_cache);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0ii->i_bmap =3D &ii->i_bmap_data;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0inode_init_once(&ii->vfs_inode);
> =C2=A0}
> Index: linux.git/include/linux/fs.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux.git.orig/include/linux/fs.h =C2=A0 2010-12-07 20:17:55.00000000=
0 +0100
> +++ linux.git/include/linux/fs.h =C2=A0 =C2=A0 =C2=A0 =C2=A02010-12-14 11=
:21:30.000000000 +0100
> @@ -645,6 +645,7 @@ struct address_space {
> =C2=A0 =C2=A0 =C2=A0 =C2=A0spinlock_t =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0private_lock; =C2=A0 /* for use by the address_space */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct list_head =C2=A0 =C2=A0 =C2=A0 =C2=A0pr=
ivate_list; =C2=A0 /* ditto */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space =C2=A0 =C2=A0*assoc_mappi=
ng; /* ditto */
> + =C2=A0 =C2=A0 =C2=A0 struct mutex =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0unmap_mutex; =C2=A0 =C2=A0/* to protect unmapping */
> =C2=A0} __attribute__((aligned(sizeof(long))));
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * On most architectures that alignment is alr=
eady the case; but
> @@ -2205,6 +2206,7 @@ extern loff_t vfs_llseek(struct file *fi
>
> =C2=A0extern int inode_init_always(struct super_block *, struct inode *);
> =C2=A0extern void inode_init_once(struct inode *);
> +extern void address_space_init_once(struct address_space *mapping);
> =C2=A0extern void ihold(struct inode * inode);
> =C2=A0extern void iput(struct inode *);
> =C2=A0extern struct inode * igrab(struct inode *);
>



--=20
Robert =C5=9Awi=C4=99cki

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
