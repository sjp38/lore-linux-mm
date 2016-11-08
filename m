Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CFD2C6B0038
	for <linux-mm@kvack.org>; Tue,  8 Nov 2016 11:12:54 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a20so43600238wme.5
        for <linux-mm@kvack.org>; Tue, 08 Nov 2016 08:12:54 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id a127si7753888wmh.83.2016.11.08.08.12.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Nov 2016 08:12:53 -0800 (PST)
Date: Tue, 8 Nov 2016 11:12:45 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161108161245.GA4020@cmpxchg.org>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-2-hannes@cmpxchg.org>
 <20161108095352.GH32353@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108095352.GH32353@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Nov 08, 2016 at 10:53:52AM +0100, Jan Kara wrote:
> On Mon 07-11-16 14:07:36, Johannes Weiner wrote:
> > The radix tree counts valid entries in each tree node. Entries stored
> > in the tree cannot be removed by simpling storing NULL in the slot or
> > the internal counters will be off and the node never gets freed again.
> > 
> > When collapsing a shmem page fails, restore the holes that were filled
> > with radix_tree_insert() with a proper radix tree deletion.
> > 
> > Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
> > Reported-by: Jan Kara <jack@suse.cz>
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > ---
> >  mm/khugepaged.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> > 
> > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > index 728d7790dc2d..eac6f0580e26 100644
> > --- a/mm/khugepaged.c
> > +++ b/mm/khugepaged.c
> > @@ -1520,7 +1520,8 @@ static void collapse_shmem(struct mm_struct *mm,
> >  				if (!nr_none)
> >  					break;
> >  				/* Put holes back where they were */
> > -				radix_tree_replace_slot(slot, NULL);
> > +				radix_tree_delete(&mapping->page_tree,
> > +						  iter.index);
> 
> Hum, but this is inside radix_tree_for_each_slot() iteration. And
> radix_tree_delete() may end up freeing nodes resulting in invalidating
> current slot pointer and the iteration code will do use-after-free.

Good point, we need to do another tree lookup after the deletion.

But there are other instances in the code, where we drop the lock
temporarily and somebody else could delete the node from under us.

In the main collapse path, I *think* this is prevented by the fact
that when we drop the tree lock we still hold the page lock of the
regular page that's in the tree while we isolate and unmap it, thus
pin the node. Even so, it would seem a little hairy to rely on that.

Kirill?

I'll update this patch and prepend another fix to the series that
addresses the other two lock dropping issues.

Thanks Jan.

diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index fed8d5e96978..1e43e77a98da 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1424,6 +1424,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		radix_tree_replace_slot(&mapping->page_tree, slot,
 				new_page + (index % HPAGE_PMD_NR));
 
+		slot = radix_tree_iter_next(&iter);
 		index++;
 		continue;
 out_lru:
@@ -1522,6 +1523,7 @@ static void collapse_shmem(struct mm_struct *mm,
 				/* Put holes back where they were */
 				radix_tree_delete(&mapping->page_tree,
 						  iter.index);
+				slot = radix_tree_iter_next(&iter);
 				nr_none--;
 				continue;
 			}
@@ -1537,6 +1539,7 @@ static void collapse_shmem(struct mm_struct *mm,
 			putback_lru_page(page);
 			unlock_page(page);
 			spin_lock_irq(&mapping->tree_lock);
+			slot = radix_tree_iter_next(&iter);
 		}
 		VM_BUG_ON(nr_none);
 		spin_unlock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
