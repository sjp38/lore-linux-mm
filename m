Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 608F86B1D8F
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 20:29:56 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id p73-v6so880215itb.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 17:29:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o184-v6sor51799600ito.23.2018.11.19.17.29.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 19 Nov 2018 17:29:54 -0800 (PST)
Date: Mon, 19 Nov 2018 18:29:50 -0700
From: Yu Zhao <yuzhao@google.com>
Subject: Re: [PATCH v2] mm: fix swap offset when replacing shmem page
Message-ID: <20181120012950.GA94981@google.com>
References: <20181119004719.156411-1-yuzhao@google.com>
 <20181119010924.177177-1-yuzhao@google.com>
 <alpine.LSU.2.11.1811191343280.17359@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1811191343280.17359@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 19, 2018 at 02:11:27PM -0800, Hugh Dickins wrote:
> On Sun, 18 Nov 2018, Yu Zhao wrote:
> 
> > We used to have a single swap address space with swp_entry_t.val
> > as its radix tree index. This is not the case anymore. Now Each
> > swp_type() has its own address space and should use swp_offset()
> > as radix tree index.
> > 
> > Signed-off-by: Yu Zhao <yuzhao@google.com>
> 
> This fix is a great find, thank you! But completely mis-described!

Yes, now I remember making swap offset as key was done long after per
swap device radix tree.

> And could you do a smaller patch, keeping swap_index, that can go to
> stable without getting into trouble with the recent xarrifications?
> 
> Fixes: bde05d1ccd51 ("shmem: replace page if mapping excludes its zone")
> Cc: stable@vger.kernel.org # 3.5+
> 
> Seems shmem_replace_page() has been wrong since the day I wrote it:
> good enough to work on swap "type" 0, which is all most people ever use
> (especially those few who need shmem_replace_page() at all), but broken
> once there are any non-0 swp_type bits set in the higher order bits.

But you did get it right when you wrote the function, which was before
the per swap device radix tree. so
Fixes: f6ab1f7f6b2d ("mm, swap: use offset of swap entry as key of swap cache")
looks good?

> > ---
> >  mm/shmem.c | 11 +++++++----
> >  1 file changed, 7 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index d44991ea5ed4..685faa3e0191 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -1509,11 +1509,13 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> >  {
> >  	struct page *oldpage, *newpage;
> >  	struct address_space *swap_mapping;
> > -	pgoff_t swap_index;
> > +	swp_entry_t entry;
> 
> Please keep swap_index as well as adding entry.

Ack.

> >  	int error;
> >  
> > +	VM_BUG_ON(!PageSwapCache(*pagep));
> > +
> 
> I'd prefer you to drop that, it has no bearing on this patch;
> we used to have it, along with lots of other VM_BUG_ONs in here,
> but they outlived their usefulness, and don't need reintroducing -
> they didn't help at all to prevent the actual bug you've found.
> 
> >  	oldpage = *pagep;
> > -	swap_index = page_private(oldpage);
> > +	entry.val = page_private(oldpage);
> 
> entry.val = page_private(oldpage);
> swap_index = swp_offset(entry);
> 
> >  	swap_mapping = page_mapping(oldpage);
> >  
> >  	/*
> > @@ -1532,7 +1534,7 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> >  	__SetPageLocked(newpage);
> >  	__SetPageSwapBacked(newpage);
> >  	SetPageUptodate(newpage);
> > -	set_page_private(newpage, swap_index);
> > +	set_page_private(newpage, entry.val);
> 
> Yes.
> 
> >  	SetPageSwapCache(newpage);
> >  
> >  	/*
> > @@ -1540,7 +1542,8 @@ static int shmem_replace_page(struct page **pagep, gfp_t gfp,
> >  	 * a nice clean interface for us to replace oldpage by newpage there.
> >  	 */
> >  	xa_lock_irq(&swap_mapping->i_pages);
> > -	error = shmem_replace_entry(swap_mapping, swap_index, oldpage, newpage);
> > +	error = shmem_replace_entry(swap_mapping, swp_offset(entry),
> > +				    oldpage, newpage);
> 
> I'd prefer to omit that hunk, to avoid the xa_lock_irq() in the context;
> the patch is just as good if we keep the swap_index variable.
> 
> >  	if (!error) {
> >  		__inc_node_page_state(newpage, NR_FILE_PAGES);
> >  		__dec_node_page_state(oldpage, NR_FILE_PAGES);
> > -- 
> > 2.19.1.1215.g8438c0b245-goog
> 
> Thanks,
> Hugh
