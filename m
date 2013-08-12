Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 990AD6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 17:49:43 -0400 (EDT)
Date: Mon, 12 Aug 2013 17:49:37 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH] mm: fix special swap entry handling on copy mm
Message-ID: <20130812214936.GA6373@redhat.com>
References: <1376322204-20659-1-git-send-email-j.glisse@gmail.com>
 <1376343400-jbl12uc3-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376343400-jbl12uc3-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: j.glisse@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 12, 2013 at 05:36:40PM -0400, Naoya Horiguchi wrote:
> Hi Jerome,
> 
> On Mon, Aug 12, 2013 at 11:43:24AM -0400, j.glisse@gmail.com wrote:
> > From: Jerome Glisse <jglisse@redhat.com>
> > 
> > Prior to this copy_one_pte will never reach the special swap file
> > handling code because swap_duplicate will return invalid value.
> > 
> > Note this is not fatal so nothing bad ever happen because of that.
> > Reason is that copy_pte_range would break of its loop and call
> > add_swap_count_continuation which would see its a special swap
> > file and return 0 triggering copy_pte_range to try again. Because
> > we try again there is a huge chance that the temporarily special
> > migration pte is now again valid and pointing to a new valid page.
> > 
> > This patch just split handling of special swap entry from regular
> > one inside copy_one_pte.
> > 
> > (Note i spotted that while reading code i haven't tested my theory.)
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> 
> non_swap_entry() means not only migration entry, but also hwpoison entry,
> so it seems to me that simply moving the swap_duplicate() into the
> if(!non_swap_entry) block can change the behavior for hwpoison entry.
> Would it be nice to add check for such a case?
> 
> Thanks,
> Naoya Horiguchi

Well if my reading of the code is right for hwpoison entry current code will
loop indefinitly inside the kernel on fork if one entry is set to hwpoison.

My patch does not handle hwpoison because it seems useless as there is nothing
to do for hwpoison pte beside giving setting the new pte to hwpoison to. So
the fork child will also have a pte with hwpoison. My patch do just that.

So change in behavior is current kernel loop indefinitly in kernel with hwpoison
pte on fork, vs child get hwpoison pte with my patch. Meaning that both child
and father can live as long as they dont access the hwpoisoned ptes.

Cheers,
Jerome

> 
> > ---
> >  mm/memory.c | 26 +++++++++++++-------------
> >  1 file changed, 13 insertions(+), 13 deletions(-)
> > 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 1ce2e2a..9f907dd 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -833,20 +833,20 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
> >  		if (!pte_file(pte)) {
> >  			swp_entry_t entry = pte_to_swp_entry(pte);
> >  
> > -			if (swap_duplicate(entry) < 0)
> > -				return entry.val;
> > -
> > -			/* make sure dst_mm is on swapoff's mmlist. */
> > -			if (unlikely(list_empty(&dst_mm->mmlist))) {
> > -				spin_lock(&mmlist_lock);
> > -				if (list_empty(&dst_mm->mmlist))
> > -					list_add(&dst_mm->mmlist,
> > -						 &src_mm->mmlist);
> > -				spin_unlock(&mmlist_lock);
> > -			}
> > -			if (likely(!non_swap_entry(entry)))
> > +			if (likely(!non_swap_entry(entry))) {
> > +				if (swap_duplicate(entry) < 0)
> > +					return entry.val;
> > +
> > +				/* make sure dst_mm is on swapoff's mmlist. */
> > +				if (unlikely(list_empty(&dst_mm->mmlist))) {
> > +					spin_lock(&mmlist_lock);
> > +					if (list_empty(&dst_mm->mmlist))
> > +						list_add(&dst_mm->mmlist,
> > +							 &src_mm->mmlist);
> > +					spin_unlock(&mmlist_lock);
> > +				}
> >  				rss[MM_SWAPENTS]++;
> > -			else if (is_migration_entry(entry)) {
> > +			} else if (is_migration_entry(entry)) {
> >  				page = migration_entry_to_page(entry);
> >  
> >  				if (PageAnon(page))
> > -- 
> > 1.8.3.1
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
