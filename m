Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C709D6B0036
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 21:05:57 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id r10so9522808pdi.11
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 18:05:57 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id gg1si1044108pac.50.2014.09.24.18.05.55
        for <linux-mm@kvack.org>;
        Wed, 24 Sep 2014 18:05:57 -0700 (PDT)
Date: Thu, 25 Sep 2014 10:06:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 3/5] mm: VM can be aware of zram fullness
Message-ID: <20140925010638.GB17364@bbox>
References: <1411344191-2842-1-git-send-email-minchan@kernel.org>
 <1411344191-2842-4-git-send-email-minchan@kernel.org>
 <CALZtOND9YOXPQ0vNKFVrs+yhnkbWkKg8FD78cHmqJWhLyo89Gw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <CALZtOND9YOXPQ0vNKFVrs+yhnkbWkKg8FD78cHmqJWhLyo89Gw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>, juno.choi@lge.com

On Wed, Sep 24, 2014 at 10:12:18AM -0400, Dan Streetman wrote:
> On Sun, Sep 21, 2014 at 8:03 PM, Minchan Kim <minchan@kernel.org> wrote:
> > VM uses nr_swap_pages to throttle amount of swap when it reclaims
> > anonymous pages because the nr_swap_pages means freeable space
> > of swap disk.
> >
> > However, it's a problem for zram because zram can limit memory
> > usage by knob(ie, mem_limit) so that swap out can fail although
> > VM can see lots of free space from zram disk but no more free
> > space in zram by the limit. If it happens, VM should notice it
> > and stop reclaimaing until zram can obtain more free space but
> > we don't have a way to communicate between VM and zram.
> >
> > This patch adds new hint SWAP_FULL so that zram can say to VM
> > "I'm full" from now on. Then VM cannot reclaim annoymous page
> > any more. If VM notice swap is full, it can remove swap_info_struct
> > from swap_avail_head and substract remained freeable space from
> > nr_swap_pages so that VM can think swap is full until VM frees a
> > swap and increase nr_swap_pages again.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/blkdev.h |  1 +
> >  mm/swapfile.c          | 44 ++++++++++++++++++++++++++++++++++++++----=
--
> >  2 files changed, 39 insertions(+), 6 deletions(-)
> >
> > diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> > index c7220409456c..39f074e0acd7 100644
> > --- a/include/linux/blkdev.h
> > +++ b/include/linux/blkdev.h
> > @@ -1611,6 +1611,7 @@ static inline bool blk_integrity_is_initialized(s=
truct gendisk *g)
> >
> >  enum swap_blk_hint {
> >         SWAP_FREE,
> > +       SWAP_FULL,
> >  };
> >
> >  struct block_device_operations {
> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> > index 209112cf8b83..71e3df0431b6 100644
> > --- a/mm/swapfile.c
> > +++ b/mm/swapfile.c
> > @@ -493,6 +493,29 @@ static unsigned long scan_swap_map(struct swap_inf=
o_struct *si,
> >         int latency_ration =3D LATENCY_LIMIT;
> >
> >         /*
> > +        * If zram is full, we don't need to scan and want to stop swap.
> > +        * For it, we removes si from swap_avail_head and decreases
> > +        * nr_swap_pages to prevent further anonymous reclaim so that
> > +        * VM can restart swap out if zram has a free space.
> > +        * Look at swap_entry_free.
> > +        */
> > +       if (si->flags & SWP_BLKDEV) {
> > +               struct gendisk *disk =3D si->bdev->bd_disk;
> > +
> > +               if (disk->fops->swap_hint && disk->fops->swap_hint(
> > +                               si->bdev, SWAP_FULL, NULL)) {
> > +                       spin_lock(&swap_avail_lock);
> > +                       WARN_ON(plist_node_empty(&si->avail_list));
> > +                       plist_del(&si->avail_list, &swap_avail_head);
> > +                       spin_unlock(&swap_avail_lock);
> > +                       atomic_long_sub(si->pages - si->inuse_pages,
> > +                                               &nr_swap_pages);
> > +                       si->full =3D true;
> > +                       return 0;
> > +               }
> > +       }
> > +
> > +       /*
> >          * We try to cluster swap pages by allocating them sequentially
> >          * in swap.  Once we've allocated SWAPFILE_CLUSTER pages this
> >          * way, however, we resort to first-free allocation, starting
> > @@ -798,6 +821,14 @@ static unsigned char swap_entry_free(struct swap_i=
nfo_struct *p,
> >         /* free if no reference */
> >         if (!usage) {
> >                 bool was_full;
> > +               struct gendisk *virt_swap =3D NULL;
> > +
> > +               /* Check virtual swap */
> > +               if (p->flags & SWP_BLKDEV) {
> > +                       virt_swap =3D p->bdev->bd_disk;
> > +                       if (!virt_swap->fops->swap_hint)
>=20
> not a big deal, but can't you just combine these two if's to simplify thi=
s?

Do you want this?

if (p->flags & SWP_BLKDEV && p->bdev->bd_disk->fops->swap_hint)
        virt_swap =3D p->bdev->bd_disk;


=02
>=20
> > +                               virt_swap =3D NULL;
> > +               }
> >
> >                 dec_cluster_info_page(p, p->cluster_info, offset);
> >                 if (offset < p->lowest_bit)
> > @@ -814,17 +845,18 @@ static unsigned char swap_entry_free(struct swap_=
info_struct *p,
> >                                           &swap_avail_head);
> >                         spin_unlock(&swap_avail_lock);
> >                         p->full =3D false;
> > +                       if (virt_swap)
> > +                               atomic_long_add(p->pages -
> > +                                               p->inuse_pages,
> > +                                               &nr_swap_pages);
>=20
> a comment here might be good, to clarify it relies on the check at the
> top of scan_swap_map previously subtracting the same number of pages.

Okay.

>=20
>=20
> >                 }
> >
> >                 atomic_long_inc(&nr_swap_pages);
> >                 p->inuse_pages--;
> >                 frontswap_invalidate_page(p->type, offset);
> > -               if (p->flags & SWP_BLKDEV) {
> > -                       struct gendisk *disk =3D p->bdev->bd_disk;
> > -                       if (disk->fops->swap_hint)
> > -                               disk->fops->swap_hint(p->bdev,
> > -                                               SWAP_FREE, (void *)offs=
et);
> > -               }
> > +               if (virt_swap)
> > +                       virt_swap->fops->swap_hint(p->bdev,
> > +                                       SWAP_FREE, (void *)offset);
> >         }
> >
> >         return usage;
> > --
> > 2.0.0
> >
>=20
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
