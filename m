Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8B56B0069
	for <linux-mm@kvack.org>; Mon, 14 Nov 2016 10:52:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i131so29954869wmf.3
        for <linux-mm@kvack.org>; Mon, 14 Nov 2016 07:52:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id y4si24171754wjq.182.2016.11.14.07.52.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Nov 2016 07:52:57 -0800 (PST)
Date: Mon, 14 Nov 2016 10:52:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161114155250.GB3291@cmpxchg.org>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-2-hannes@cmpxchg.org>
 <20161108095352.GH32353@quack2.suse.cz>
 <20161108161245.GA4020@cmpxchg.org>
 <20161111105921.GC19382@node.shutemov.name>
 <20161111122224.GA5090@quack2.suse.cz>
 <20161111163753.GH19382@node.shutemov.name>
 <20161114080744.GA2524@quack2.suse.cz>
 <20161114142902.GA10455@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161114142902.GA10455@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Nov 14, 2016 at 05:29:02PM +0300, Kirill A. Shutemov wrote:
> On Mon, Nov 14, 2016 at 09:07:44AM +0100, Jan Kara wrote:
> > On Fri 11-11-16 19:37:53, Kirill A. Shutemov wrote:
> > > On Fri, Nov 11, 2016 at 01:22:24PM +0100, Jan Kara wrote:
> > > > On Fri 11-11-16 13:59:21, Kirill A. Shutemov wrote:
> > > > > On Tue, Nov 08, 2016 at 11:12:45AM -0500, Johannes Weiner wrote:
> > > > > > On Tue, Nov 08, 2016 at 10:53:52AM +0100, Jan Kara wrote:
> > > > > > > On Mon 07-11-16 14:07:36, Johannes Weiner wrote:
> > > > > > > > The radix tree counts valid entries in each tree node. Entries stored
> > > > > > > > in the tree cannot be removed by simpling storing NULL in the slot or
> > > > > > > > the internal counters will be off and the node never gets freed again.
> > > > > > > > 
> > > > > > > > When collapsing a shmem page fails, restore the holes that were filled
> > > > > > > > with radix_tree_insert() with a proper radix tree deletion.
> > > > > > > > 
> > > > > > > > Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
> > > > > > > > Reported-by: Jan Kara <jack@suse.cz>
> > > > > > > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > > > > > > ---
> > > > > > > >  mm/khugepaged.c | 3 ++-
> > > > > > > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > > > > > > 
> > > > > > > > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > > > > > > > index 728d7790dc2d..eac6f0580e26 100644
> > > > > > > > --- a/mm/khugepaged.c
> > > > > > > > +++ b/mm/khugepaged.c
> > > > > > > > @@ -1520,7 +1520,8 @@ static void collapse_shmem(struct mm_struct *mm,
> > > > > > > >  				if (!nr_none)
> > > > > > > >  					break;
> > > > > > > >  				/* Put holes back where they were */
> > > > > > > > -				radix_tree_replace_slot(slot, NULL);
> > > > > > > > +				radix_tree_delete(&mapping->page_tree,
> > > > > > > > +						  iter.index);
> > > > > > > 
> > > > > > > Hum, but this is inside radix_tree_for_each_slot() iteration. And
> > > > > > > radix_tree_delete() may end up freeing nodes resulting in invalidating
> > > > > > > current slot pointer and the iteration code will do use-after-free.
> > > > > > 
> > > > > > Good point, we need to do another tree lookup after the deletion.
> > > > > > 
> > > > > > But there are other instances in the code, where we drop the lock
> > > > > > temporarily and somebody else could delete the node from under us.
> > > > > > 
> > > > > > In the main collapse path, I *think* this is prevented by the fact
> > > > > > that when we drop the tree lock we still hold the page lock of the
> > > > > > regular page that's in the tree while we isolate and unmap it, thus
> > > > > > pin the node. Even so, it would seem a little hairy to rely on that.
> > > > > > 
> > > > > > Kirill?
> > > > > 
> > > > > [ sorry for delay ]
> > > > > 
> > > > > Yes, we make sure that locked page still belong to the radix tree and fall
> > > > > off if it's not. Locked page cannot be removed from radix-tree, so we
> > > > > should be fine.
> > > > 
> > > > Well, it cannot be removed from the radix tree but radix tree code is still
> > > > free to collapse / expand the tree nodes as it sees fit (currently the only
> > > > real case is when changing direct page pointer in the tree root to a node
> > > > pointer or vice versa but still...). So code should not really assume that
> > > > the node page is referenced from does not change once tree_lock is dropped.
> > > > It leads to subtle bugs...
> > > 
> > > Hm. Okay.
> > > 
> > > What is the right way re-validate that slot is still valid? Do I need full
> > > look up again? Can I pin node explicitly?
> > 
> > Full lookup is the only way to re-validate the slot. There is no way to pin
> > a radix tree node.
> 
> I guess this should be enough:
> 
> diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> index 728d7790dc2d..c5ef73588676 100644
> --- a/mm/khugepaged.c
> +++ b/mm/khugepaged.c
> @@ -1400,7 +1400,9 @@ static void collapse_shmem(struct mm_struct *mm,
>  					PAGE_SIZE, 0);
>  
>  		spin_lock_irq(&mapping->tree_lock);
> -
> +		slot = radix_tree_lookup_slot(&mapping->page_tree, index);
> +		VM_BUG_ON_PAGE(page != radix_tree_deref_slot_protected(slot,
> +					&mapping->tree_lock), page);
>  		VM_BUG_ON_PAGE(page_mapped(page), page);

That looks good to me. The slot may get relocated, but the content
shouldn't change with the page locked.

Are you going to send a full patch with changelog and sign-off? If so,
please add:

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
