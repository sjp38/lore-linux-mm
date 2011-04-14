Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 08299900086
	for <linux-mm@kvack.org>; Thu, 14 Apr 2011 19:37:52 -0400 (EDT)
Received: by iwg8 with SMTP id 8so2644319iwg.14
        for <linux-mm@kvack.org>; Thu, 14 Apr 2011 16:37:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110414211732.GA27761@ca-server1.us.oracle.com>
References: <20110414211732.GA27761@ca-server1.us.oracle.com>
Date: Fri, 15 Apr 2011 08:37:49 +0900
Message-ID: <BANLkTimEbtY8F6bpsfhfQ770ao9Hn7Spww@mail.gmail.com>
Subject: Re: [PATCH V8 4/8] mm/fs: add hooks to support cleancache
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: chris.mason@oracle.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger.kernel@dilger.ca, tytso@mit.edu, mfasheh@suse.com, jlbec@evilplan.org, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, hch@infradead.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, kurt.hackel@oracle.com, npiggin@kernel.dk, dave.mccracken@oracle.com, riel@redhat.com, avi@redhat.com, konrad.wilk@oracle.com, mel@csn.ul.ie, yinghan@google.com, gthelen@google.com, torvalds@linux-foundation.org

Hi Dan,

On Fri, Apr 15, 2011 at 6:17 AM, Dan Magenheimer
<dan.magenheimer@oracle.com> wrote:
> [PATCH V8 4/8] mm/fs: add hooks to support cleancache
>
> This fourth patch of eight in this cleancache series provides the
> core hooks in VFS for: initializing cleancache per filesystem;
> capturing clean pages reclaimed by page cache; attempting to get
> pages from cleancache before filesystem read; and ensuring coherency
> between pagecache, disk, and cleancache. =C2=A0Note that the placement
> of these hooks was stable from 2.6.18 to 2.6.38; a minor semantic
> change was required due to a patchset in 2.6.39.
>
> All hooks become no-ops if CONFIG_CLEANCACHE is unset, or become
> a check of a boolean global if CONFIG_CLEANCACHE is set but no
> cleancache "backend" has claimed cleancache_ops.
>
> Details and a FAQ can be found in Documentation/vm/cleancache.txt
>
> [v8: minchan.kim@gmail.com: adapt to new remove_from_page_cache function]
> Signed-off-by: Chris Mason <chris.mason@oracle.com>
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Jeremy Fitzhardinge <jeremy@goop.org>
> Reviewed-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Al Viro <viro@ZenIV.linux.org.uk>
> Cc: Matthew Wilcox <matthew@wil.cx>
> Cc: Nick Piggin <npiggin@kernel.dk>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Rik Van Riel <riel@redhat.com>
> Cc: Jan Beulich <JBeulich@novell.com>
> Cc: Andreas Dilger <adilger@sun.com>
> Cc: Ted Ts'o <tytso@mit.edu>
> Cc: Mark Fasheh <mfasheh@suse.com>
> Cc: Joel Becker <joel.becker@oracle.com>
> Cc: Nitin Gupta <ngupta@vflare.org>
>
> ---
>
> Diffstat:
> =C2=A0fs/buffer.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A05 +++++
> =C2=A0fs/mpage.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A07 +++++++
> =C2=A0fs/super.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A03 +++
> =C2=A0mm/filemap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 11 +++++++++++
> =C2=A0mm/truncate.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A06 ++++++
> =C2=A05 files changed, 32 insertions(+)
>
> --- linux-2.6.39-rc3/fs/super.c 2011-04-11 18:21:51.000000000 -0600
> +++ linux-2.6.39-rc3-cleancache/fs/super.c =C2=A0 =C2=A0 =C2=A02011-04-13=
 17:08:09.175853426 -0600
> @@ -31,6 +31,7 @@
> =C2=A0#include <linux/mutex.h>
> =C2=A0#include <linux/backing-dev.h>
> =C2=A0#include <linux/rculist_bl.h>
> +#include <linux/cleancache.h>
> =C2=A0#include "internal.h"
>
>
> @@ -112,6 +113,7 @@ static struct super_block *alloc_super(s
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->s_maxbytes =3D =
MAX_NON_LFS;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->s_op =3D &defau=
lt_op;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0s->s_time_gran =3D=
 1000000000;
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s->cleancache_poolid =
=3D -1;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
> =C2=A0out:
> =C2=A0 =C2=A0 =C2=A0 =C2=A0return s;
> @@ -177,6 +179,7 @@ void deactivate_locked_super(struct supe
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct file_system_type *fs =3D s->s_type;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if (atomic_dec_and_test(&s->s_active)) {
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cleancache_flush_fs(s)=
;
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0fs->kill_sb(s);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 * We need to call=
 rcu_barrier so all the delayed rcu free
> --- linux-2.6.39-rc3/fs/buffer.c =C2=A0 =C2=A0 =C2=A0 =C2=A02011-04-11 18=
:21:51.000000000 -0600
> +++ linux-2.6.39-rc3-cleancache/fs/buffer.c =C2=A0 =C2=A0 2011-04-13 17:0=
7:24.700917174 -0600
> @@ -41,6 +41,7 @@
> =C2=A0#include <linux/bitops.h>
> =C2=A0#include <linux/mpage.h>
> =C2=A0#include <linux/bit_spinlock.h>
> +#include <linux/cleancache.h>
>
> =C2=A0static int fsync_buffers_list(spinlock_t *lock, struct list_head *l=
ist);
>
> @@ -269,6 +270,10 @@ void invalidate_bdev(struct block_device
> =C2=A0 =C2=A0 =C2=A0 =C2=A0invalidate_bh_lrus();
> =C2=A0 =C2=A0 =C2=A0 =C2=A0lru_add_drain_all(); =C2=A0 =C2=A0/* make sure=
 all lru add caches are flushed */
> =C2=A0 =C2=A0 =C2=A0 =C2=A0invalidate_mapping_pages(mapping, 0, -1);
> + =C2=A0 =C2=A0 =C2=A0 /* 99% of the time, we don't need to flush the cle=
ancache on the bdev.
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* But, for the strange corners, lets be caut=
ious
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 cleancache_flush_inode(mapping);
> =C2=A0}
> =C2=A0EXPORT_SYMBOL(invalidate_bdev);
>
> --- linux-2.6.39-rc3/fs/mpage.c 2011-04-11 18:21:51.000000000 -0600
> +++ linux-2.6.39-rc3-cleancache/fs/mpage.c =C2=A0 =C2=A0 =C2=A02011-04-13=
 17:07:24.706913410 -0600
> @@ -27,6 +27,7 @@
> =C2=A0#include <linux/writeback.h>
> =C2=A0#include <linux/backing-dev.h>
> =C2=A0#include <linux/pagevec.h>
> +#include <linux/cleancache.h>
>
> =C2=A0/*
> =C2=A0* I/O completion handler for multipage BIOs.
> @@ -271,6 +272,12 @@ do_mpage_readpage(struct bio *bio, struc
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0SetPageMappedToDis=
k(page);
> =C2=A0 =C2=A0 =C2=A0 =C2=A0}
>
> + =C2=A0 =C2=A0 =C2=A0 if (fully_mapped && blocks_per_page =3D=3D 1 && !P=
ageUptodate(page) &&
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cleancache_get_page(page) =3D=3D 0) =
{
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 SetPageUptodate(page);
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 goto confused;
> + =C2=A0 =C2=A0 =C2=A0 }
> +
> =C2=A0 =C2=A0 =C2=A0 =C2=A0/*
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 * This page will go to BIO. =C2=A0Do we need =
to send this BIO off first?
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 */
> --- linux-2.6.39-rc3/mm/filemap.c =C2=A0 =C2=A0 =C2=A0 2011-04-11 18:21:5=
1.000000000 -0600
> +++ linux-2.6.39-rc3-cleancache/mm/filemap.c =C2=A0 =C2=A02011-04-13 17:0=
9:46.367852002 -0600
> @@ -34,6 +34,7 @@
> =C2=A0#include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
> =C2=A0#include <linux/memcontrol.h>
> =C2=A0#include <linux/mm_inline.h> /* for page_is_file_cache() */
> +#include <linux/cleancache.h>
> =C2=A0#include "internal.h"
>
> =C2=A0/*
> @@ -118,6 +119,16 @@ void __delete_from_page_cache(struct pag
> =C2=A0{
> =C2=A0 =C2=A0 =C2=A0 =C2=A0struct address_space *mapping =3D page->mappin=
g;
>
> + =C2=A0 =C2=A0 =C2=A0 /*
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* if we're uptodate, flush out into the clea=
ncache, otherwise
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* invalidate any existing cleancache entries=
. =C2=A0We can't leave
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0* stale data around in the cleancache once o=
ur page is gone
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0*/
> + =C2=A0 =C2=A0 =C2=A0 if (PageUptodate(page) && PageMappedToDisk(page))
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cleancache_put_page(pa=
ge);
> + =C2=A0 =C2=A0 =C2=A0 else
> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 cleancache_flush_page(=
mapping, page);
> +

First of all, thanks for resolving conflict with my patch.

Before I suggested a thing about cleancache_flush_page, cleancache_flush_in=
ode.

what's the meaning of flush's semantic?
I thought it means invalidation.
AFAIC, how about change flush with invalidate?


--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
