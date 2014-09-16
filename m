Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 170E76B00AF
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 20:33:27 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kq14so7490299pab.19
        for <linux-mm@kvack.org>; Mon, 15 Sep 2014 17:33:26 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id gr5si26071374pbc.131.2014.09.15.17.33.24
        for <linux-mm@kvack.org>;
        Mon, 15 Sep 2014 17:33:25 -0700 (PDT)
Date: Tue, 16 Sep 2014 09:33:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/3] mm: add swap_get_free hint for zram
Message-ID: <20140916003336.GD10912@bbox>
References: <1409794786-10951-1-git-send-email-minchan@kernel.org>
 <1409794786-10951-3-git-send-email-minchan@kernel.org>
 <CALZtONCortZodFfVU5-oXUdGShhjFOg+FesxMFCdsyhsnnkmZw@mail.gmail.com>
 <20140915003015.GF2160@bbox>
 <CALZtONBghSTAbgXLrgmNV+EEKaJnx96TRuXorM-J_JFEKC88=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CALZtONBghSTAbgXLrgmNV+EEKaJnx96TRuXorM-J_JFEKC88=Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, Luigi Semenzato <semenzato@google.com>

On Mon, Sep 15, 2014 at 10:53:01AM -0400, Dan Streetman wrote:
> On Sun, Sep 14, 2014 at 8:30 PM, Minchan Kim <minchan@kernel.org> wrote:
> > On Sat, Sep 13, 2014 at 03:01:47PM -0400, Dan Streetman wrote:
> >> On Wed, Sep 3, 2014 at 9:39 PM, Minchan Kim <minchan@kernel.org> wrote:
> >> > VM uses nr_swap_pages as one of information when it does
> >> > anonymous reclaim so that VM is able to throttle amount of swap.
> >> >
> >> > Normally, the nr_swap_pages is equal to freeable space of swap disk
> >> > but for zram, it doesn't match because zram can limit memory usage
> >> > by knob(ie, mem_limit) so although VM can see lots of free space
> >> > from zram disk, zram can make fail intentionally once the allocated
> >> > space is over to limit. If it happens, VM should notice it and
> >> > stop reclaimaing until zram can obtain more free space but there
> >> > is a good way to do at the moment.
> >> >
> >> > This patch adds new hint SWAP_GET_FREE which zram can return how
> >> > many of freeable space it has. With using that, this patch adds
> >> > __swap_full which returns true if the zram is full and substract
> >> > remained freeable space of the zram-swap from nr_swap_pages.
> >> > IOW, VM sees there is no more swap space of zram so that it stops
> >> > anonymous reclaiming until swap_entry_free free a page and increase
> >> > nr_swap_pages again.
> >> >
> >> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> >> > ---
> >> >  include/linux/blkdev.h |  1 +
> >> >  mm/swapfile.c          | 45 +++++++++++++++++++++++++++++++++++++++++++--
> >> >  2 files changed, 44 insertions(+), 2 deletions(-)
> >> >
> >> > diff --git a/include/linux/blkdev.h b/include/linux/blkdev.h
> >> > index 17437b2c18e4..c1199806e0f1 100644
> >> > --- a/include/linux/blkdev.h
> >> > +++ b/include/linux/blkdev.h
> >> > @@ -1611,6 +1611,7 @@ static inline bool blk_integrity_is_initialized(struct gendisk *g)
> >> >
> >> >  enum swap_blk_hint {
> >> >         SWAP_SLOT_FREE,
> >> > +       SWAP_GET_FREE,
> >> >  };
> >> >
> >> >  struct block_device_operations {
> >> > diff --git a/mm/swapfile.c b/mm/swapfile.c
> >> > index 4bff521e649a..72737e6dd5e5 100644
> >> > --- a/mm/swapfile.c
> >> > +++ b/mm/swapfile.c
> >> > @@ -484,6 +484,22 @@ new_cluster:
> >> >         *scan_base = tmp;
> >> >  }
> >> >
> >> > +static bool __swap_full(struct swap_info_struct *si)
> >> > +{
> >> > +       if (si->flags & SWP_BLKDEV) {
> >> > +               long free;
> >> > +               struct gendisk *disk = si->bdev->bd_disk;
> >> > +
> >> > +               if (disk->fops->swap_hint)
> >> > +                       if (!disk->fops->swap_hint(si->bdev,
> >> > +                                               SWAP_GET_FREE,
> >> > +                                               &free))
> >> > +                               return free <= 0;
> >> > +       }
> >> > +
> >> > +       return si->inuse_pages == si->pages;
> >> > +}
> >> > +
> >> >  static unsigned long scan_swap_map(struct swap_info_struct *si,
> >> >                                    unsigned char usage)
> >> >  {
> >> > @@ -583,11 +599,21 @@ checks:
> >> >         if (offset == si->highest_bit)
> >> >                 si->highest_bit--;
> >> >         si->inuse_pages++;
> >> > -       if (si->inuse_pages == si->pages) {
> >> > +       if (__swap_full(si)) {
> >>
> >> This check is done after an available offset has already been
> >> selected.  So if the variable-size blkdev is full at this point, then
> >> this is incorrect, as swap will try to store a page at the current
> >> selected offset.
> >
> > So the result is just fail of a write then what happens?
> > Page become redirty and keep it in memory so there is no harm.
> 
> Happening once, it's not a big deal.  But it's not as good as not
> happening at all.

With your suggestion, we should check full whevever we need new
swap slot. To me, it's more concern than just a write fail.

> 
> >
> >>
> >> > +               struct gendisk *disk = si->bdev->bd_disk;
> >> > +
> >> >                 si->lowest_bit = si->max;
> >> >                 si->highest_bit = 0;
> >> >                 spin_lock(&swap_avail_lock);
> >> >                 plist_del(&si->avail_list, &swap_avail_head);
> >> > +               /*
> >> > +                * If zram is full, it decreases nr_swap_pages
> >> > +                * for stopping anonymous page reclaim until
> >> > +                * zram has free space. Look at swap_entry_free
> >> > +                */
> >> > +               if (disk->fops->swap_hint)
> >>
> >> Simply checking for the existence of swap_hint isn't enough to know
> >> we're using zram...
> >
> > Yes but acutally the hint have been used for only zram for several years.
> > If other user is coming in future, we would add more checks if we really
> > need it at that time.
> > Do you have another idea?
> 
> Well if this hint == zram just rename it zram.  Especially if it's now
> going to be explicitly used to mean it == zram.  But I don't think
> that is necessary.

I'd like to clarify your comment. So, are you okay without any change?

> 
> >
> >>
> >> > +                       atomic_long_sub(si->pages - si->inuse_pages,
> >> > +                               &nr_swap_pages);
> >> >                 spin_unlock(&swap_avail_lock);
> >> >         }
> >> >         si->swap_map[offset] = usage;
> >> > @@ -796,6 +822,7 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
> >> >
> >> >         /* free if no reference */
> >> >         if (!usage) {
> >> > +               struct gendisk *disk = p->bdev->bd_disk;
> >> >                 dec_cluster_info_page(p, p->cluster_info, offset);
> >> >                 if (offset < p->lowest_bit)
> >> >                         p->lowest_bit = offset;
> >> > @@ -808,6 +835,21 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
> >> >                                 if (plist_node_empty(&p->avail_list))
> >> >                                         plist_add(&p->avail_list,
> >> >                                                   &swap_avail_head);
> >> > +                               if ((p->flags & SWP_BLKDEV) &&
> >> > +                                       disk->fops->swap_hint) {
> >>
> >> freeing an entry from a full variable-size blkdev doesn't mean it's
> >> not still full.  In this case with zsmalloc, freeing one handle
> >> doesn't actually free any memory unless it was the only handle left in
> >> its containing zspage, and therefore it's possible that it is still
> >> full at this point.
> >
> > No need to free a zspage in zsmalloc.
> > If we free a page in zspage, it means we have free space in zspage
> > so user can give a chance to user for writing out new page.
> 
> That's not actually true, since zsmalloc has 255 different class
> sizes, freeing one page means the next page to be compressed has a
> 1/255 chance that it will be the same size as the just-freed page
> (assuming random page compressability).

I said "a chance" so if we have a possiblity, I'd like to try it.
Pz, don't tie your thought into zsmalloc's internal. It's facility
to communitcate with swap/zram, not zram allocator.
IOW, We could change allocator of zram potentially
(ex, historically, we have already done) and the (imaginary allocator/
or enhanced zsmalloc) could have a technique to handle it.

> 
> >
> >>
> >> > +                                       atomic_long_add(p->pages -
> >> > +                                                       p->inuse_pages,
> >> > +                                                       &nr_swap_pages);
> >> > +                                       /*
> >> > +                                        * reset [highest|lowest]_bit to avoid
> >> > +                                        * scan_swap_map infinite looping if
> >> > +                                        * cached free cluster's index by
> >> > +                                        * scan_swap_map_try_ssd_cluster is
> >> > +                                        * above p->highest_bit.
> >> > +                                        */
> >> > +                                       p->highest_bit = p->max - 1;
> >> > +                                       p->lowest_bit = 1;
> >>
> >> lowest_bit and highest_bit are likely to remain at those extremes for
> >> a long time, until 1 or max-1 is freed and re-allocated.
> >>
> >>
> >> By adding variable-size blkdev support to swap, I don't think
> >> highest_bit can be re-used as a "full" flag anymore.
> >>
> >> Instead, I suggest that you add a "full" flag to struct
> >> swap_info_struct.  Then put a swap_hint GET_FREE check at the top of
> >> scan_swap_map(), and if full simply turn "full" on, remove the
> >> swap_info_struct from the avail list, reduce nr_swap_pages
> >> appropriately, and return failure.  Don't mess with lowest_bit or
> >> highest_bit at all.
> >
> > Could you explain what logic in your suggestion prevent the problem
> > I mentioned(ie, scan_swap_map infinite looping)?
> 
> scan_swap_map would immediately exit since the GET_FREE (or IS_FULL)
> check is done at its start.  And it wouldn't be called again with that
> swap_info_struct until non-full since it is removed from the
> avail_list.

Sorry for being not clear. I don't mean it.
Please consider the situation where swap is not full any more
by swap_entry_free. Newly scan_swap_map can select the slot index which
is higher than p->highest_bit because we have cached free_cluster so
scan_swap_map will reset it with p->lowest_bit and scan again and finally
pick the slot index just freed by swap_entry_free and checks again.
Then, it could be conflict by scan_swap_map_ssd_cluster_conflict so
scan_swap_map_try_ssd_cluster will reset offset, scan_base to free_cluster_head
but unfortunately, offset is higher than p->highest_bit so again it is reset
to p->lowest_bit. It loops forever :(

I'd like to solve this problem without many hooking in swap layer and
any overhead for !zram case.

> 
> >
> >>
> >> Then in swap_entry_free(), do something like:
> >>
> >>     dec_cluster_info_page(p, p->cluster_info, offset);
> >>     if (offset < p->lowest_bit)
> >>       p->lowest_bit = offset;
> >> -   if (offset > p->highest_bit) {
> >> -     bool was_full = !p->highest_bit;
> >> +   if (offset > p->highest_bit)
> >>       p->highest_bit = offset;
> >> -     if (was_full && (p->flags & SWP_WRITEOK)) {
> >> +   if (p->full && p->flags & SWP_WRITEOK) {
> >> +     bool is_var_size_blkdev = is_variable_size_blkdev(p);
> >> +     bool blkdev_full = is_variable_size_blkdev_full(p);
> >> +
> >> +     if (!is_var_size_blkdev || !blkdev_full) {
> >> +       if (is_var_size_blkdev)
> >> +         atomic_long_add(p->pages - p->inuse_pages, &nr_swap_pages);
> >> +       p->full = false;
> >>         spin_lock(&swap_avail_lock);
> >>         WARN_ON(!plist_node_empty(&p->avail_list));
> >>         if (plist_node_empty(&p->avail_list))
> >>           plist_add(&p->avail_list,
> >>              &swap_avail_head);
> >>         spin_unlock(&swap_avail_lock);
> >> +     } else if (blkdev_full) {
> >> +       /* still full, so this page isn't actually
> >> +        * available yet to use; once non-full,
> >> +        * pages-inuse_pages will be the correct
> >> +        * number to add (above) since below will
> >> +        * inuse_pages--
> >> +        */
> >> +       atomic_long_dec(&nr_swap_pages);
> >>       }
> >>     }
> >>     atomic_long_inc(&nr_swap_pages);
> >>
> >>
> >>
> >> > @@ -815,7 +857,6 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
> >> >                 p->inuse_pages--;
> >> >                 frontswap_invalidate_page(p->type, offset);
> >> >                 if (p->flags & SWP_BLKDEV) {
> >> > -                       struct gendisk *disk = p->bdev->bd_disk;
> >> >                         if (disk->fops->swap_hint)
> >> >                                 disk->fops->swap_hint(p->bdev,
> >> >                                                 SWAP_SLOT_FREE,
> >> > --
> >> > 2.0.0
> >> >
> >>
> >> --
> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> >> the body to majordomo@kvack.org.  For more info on Linux MM,
> >> see: http://www.linux-mm.org/ .
> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >
> > --
> > Kind regards,
> > Minchan Kim
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
