Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id D39376B0036
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 03:06:34 -0400 (EDT)
Date: Tue, 26 Mar 2013 03:06:18 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364281578-4bs50rjv-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130325133644.GY2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-7-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325133644.GY2154@dhcp22.suse.cz>
Subject: Re: [PATCH 06/10] migrate: add hugepage migration code to
 move_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Mon, Mar 25, 2013 at 02:36:44PM +0100, Michal Hocko wrote:
> On Fri 22-03-13 16:23:51, Naoya Horiguchi wrote:
> > This patch extends move_pages() to handle vma with VM_HUGETLB set.
> > We will be able to migrate hugepage with move_pages(2) after
> > applying the enablement patch which comes later in this series.
> > 
> > We avoid getting refcount on tail pages of hugepage, because unlike thp,
> > hugepage is not split and we need not care about races with splitting.
> > 
> > And migration of larger (1GB for x86_64) hugepage are not enabled.
> > 
> > ChangeLog v2:
> >  - updated description and renamed patch title
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  mm/memory.c  |  6 ++++--
> >  mm/migrate.c | 26 +++++++++++++++++++-------
> >  2 files changed, 23 insertions(+), 9 deletions(-)
> > 
> > diff --git v3.9-rc3.orig/mm/memory.c v3.9-rc3/mm/memory.c
> > index 494526a..3b6ad3d 100644
> > --- v3.9-rc3.orig/mm/memory.c
> > +++ v3.9-rc3/mm/memory.c
> > @@ -1503,7 +1503,8 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >  	if (pud_none(*pud))
> >  		goto no_page_table;
> >  	if (pud_huge(*pud) && vma->vm_flags & VM_HUGETLB) {
> > -		BUG_ON(flags & FOLL_GET);
> > +		if (flags & FOLL_GET)
> > +			goto out;
> 
> 
> >  		page = follow_huge_pud(mm, address, pud, flags & FOLL_WRITE);
> >  		goto out;
> >  	}
> > @@ -1514,8 +1515,9 @@ struct page *follow_page_mask(struct vm_area_struct *vma,
> >  	if (pmd_none(*pmd))
> >  		goto no_page_table;
> >  	if (pmd_huge(*pmd) && vma->vm_flags & VM_HUGETLB) {
> > -		BUG_ON(flags & FOLL_GET);
> >  		page = follow_huge_pmd(mm, address, pmd, flags & FOLL_WRITE);
> > +		if (flags & FOLL_GET && PageHead(page))
> > +			get_page_foll(page);
> 
> Hmm, so the caller gets a non-null page without elevated ref counted
> even when he asked for it. This means that all callers have to check
> PageTail && hugetlb and put_page according to that. That is _really_
> fragile.

I agree. And refcounting of tail pages are already very fragile,
because get_page_foll() does something very tricky on tail pages,
where we use page->_mapcount for refcount.
This seems to be to handle some thp splitting problem,
and is never intended to be used for hugepage.
So I just avoid calling it for tail pages of hugepage in caller's side.

> I think that returning NULL would make more sense in this case.

Sounds nice. I'll do this with some comment.

> >  		goto out;
> >  	}
> >  	if ((flags & FOLL_NUMA) && pmd_numa(*pmd))
> > @@ -1164,6 +1175,12 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
> [...]
> >  				!migrate_all)
> >  			goto put_and_set;
> >  
> > +		if (PageHuge(page)) {
> > +			get_page(page);
> > +			list_move_tail(&page->lru, &pagelist);
> > +			goto put_and_set;
> > +		}
> 
> Why do you take an additional reference here? You have one from
> follow_page already.

For normal pages, follow_page(FOLL_GET) takes a refcount and
isolate_lru_page() takes another one, so I think the same should
be done for hugepages. Refcounting of this function looks tricky,
and I'm not sure why existing code does like that.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
