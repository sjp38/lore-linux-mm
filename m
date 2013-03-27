Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id A60E26B0002
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 10:19:24 -0400 (EDT)
Date: Wed, 27 Mar 2013 15:19:21 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 09/10] memory-hotplug: enable memory hotplug to handle
 hugepage
Message-ID: <20130327141921.GJ16579@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-10-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325150952.GA2154@dhcp22.suse.cz>
 <1364322204-ah777uqs-mutt-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1364322204-ah777uqs-mutt-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Tue 26-03-13 14:23:24, Naoya Horiguchi wrote:
> On Mon, Mar 25, 2013 at 04:09:52PM +0100, Michal Hocko wrote:
> > On Fri 22-03-13 16:23:54, Naoya Horiguchi wrote:
> ...
> > > index d9d3dd7..ef79871 100644
> > > --- v3.9-rc3.orig/mm/hugetlb.c
> > > +++ v3.9-rc3/mm/hugetlb.c
> > > @@ -844,6 +844,36 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
> > >  	return ret;
> > >  }
> > >  
> > > +/* Dissolve a given free hugepage into free pages. */
> > > +static void dissolve_free_huge_page(struct page *page)
> > > +{
> > > +	spin_lock(&hugetlb_lock);
> > > +	if (PageHuge(page) && !page_count(page)) {
> > > +		struct hstate *h = page_hstate(page);
> > > +		int nid = page_to_nid(page);
> > > +		list_del(&page->lru);
> > > +		h->free_huge_pages--;
> > > +		h->free_huge_pages_node[nid]--;
> > > +		update_and_free_page(h, page);
> > > +	}
> > 
> > What about surplus pages?
> 
> This function is only for free hugepage, not for surplus hugepages
> (which are considered as in-use hugepages.)

How do you want to get rid of those then? You cannot offline the node if
there are any pages...

> dissolve_free_huge_pages() can be called only when all source hugepages
> are free (all in-use hugepages are successfully migrated.)
> 
[...]
> > > +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> > > +bool is_hugepage_movable(struct page *hpage)
> > > +{
> > > +	struct page *page;
> > > +	struct hstate *h;
> > > +	bool ret = false;
> > > +
> > > +	VM_BUG_ON(!PageHuge(hpage));
> > > +	/*
> > > +	 * This function can be called for a tail page because memory hotplug
> > > +	 * scans movability of pages by pfn range of a memory block.
> > > +	 * Larger hugepages (1GB for x86_64) are larger than memory block, so
> > > +	 * the scan can start at the tail page of larger hugepages.
> > > +	 * 1GB hugepage is not movable now, so we return with false for now.
> > > +	 */
> > > +	if (PageTail(hpage))
> > > +		return false;
> > > +	h = page_hstate(hpage);
> > > +	spin_lock(&hugetlb_lock);
> > > +	list_for_each_entry(page, &h->hugepage_activelist, lru)
> > > +		if (page == hpage) {
> > > +			ret = true;
> > > +			break;
> > > +		}
> > 
> > Why are you checking that the page is active?
> 
> This is the counterpart to doing PageLRU check for normal pages.
> 
> > It doesn't make much sense
> > to me because nothing prevents it from being freed/allocated right after
> > you release hugetlb_lock.
> 
> Such a race can also happen for normal pages because scan_movable_pages()
> just check PageLRU flags without holding any lock.
> But the caller, __offline_pages(), repeats to call scan_movable_pages()
> until no page in the memblock are judged as movable, and in the repeat loop
> do_migrate_range() does nothing for free (unmovable) pages.
> So there is no behavioral problem even if the movable page is freed just
> after the if(PageLRU) check in scan_movable_page().

yes

> Note that in this loop, allocating pages in the memblock is forbidden
> because we already do set_migratetype_isolate() for them, so we don't have
> to worry about being allocated just after scan_movable_pages().

yes

> I want the same thing to be the case for hugepage. As you pointed out,
> is_hugepage_movable() is not safe from such a race, but in "being freed
> just after is_hugepage_movable() returns true" case we have no problem
> for the same reason described above.
 
yes, this was my point, sorry for not being clear about that. I meant
the costly test is pointless because it doesn't prevent any races and
doesn't tell us much.
If we made sure that all page on the hugepage_freelists have reference
0 (which is now not the case and it is yet another source of confusion)
then the whole loop could be replaced by page_count check.

> However, in "being allocated just after is_hugepage_movable() returns false"
> case, it seems to be possible to hot-remove an active hugepage.

check_pages_isolated should catch this but it is still racy.

> I think we can avoid this by adding migratetype check in
> alloc_huge_page().

I think dequeue_huge_page_vma should be sufficient, because we are going
through page allocator otherwise and that one is aware of migrate types.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
