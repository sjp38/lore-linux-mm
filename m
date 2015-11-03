Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CAE326B0038
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 02:17:23 -0500 (EST)
Received: by wijp11 with SMTP id p11so65661764wij.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 23:17:23 -0800 (PST)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com. [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id az5si68873wjc.7.2015.11.02.23.17.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 23:17:22 -0800 (PST)
Received: by wicfv8 with SMTP id fv8so5573621wic.0
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 23:17:22 -0800 (PST)
Date: Tue, 3 Nov 2015 09:16:50 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151103071650.GA21553@node.shutemov.name>
References: <20151022000648.GD23631@bbox>
 <alpine.LSU.2.11.1510211744380.5219@eggly.anvils>
 <20151022012136.GG23631@bbox>
 <20151022090051.GH23631@bbox>
 <20151029002524.GA12018@node.shutemov.name>
 <20151029075829.GA16099@bbox>
 <20151029095206.GB29870@node.shutemov.name>
 <20151030070350.GB16099@bbox>
 <20151102125749.GB7473@node.shutemov.name>
 <20151103030258.GJ17906@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151103030258.GJ17906@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Tue, Nov 03, 2015 at 12:02:58PM +0900, Minchan Kim wrote:
> Hello Kirill,
> 
> On Mon, Nov 02, 2015 at 02:57:49PM +0200, Kirill A. Shutemov wrote:
> > On Fri, Oct 30, 2015 at 04:03:50PM +0900, Minchan Kim wrote:
> > > On Thu, Oct 29, 2015 at 11:52:06AM +0200, Kirill A. Shutemov wrote:
> > > > On Thu, Oct 29, 2015 at 04:58:29PM +0900, Minchan Kim wrote:
> > > > > On Thu, Oct 29, 2015 at 02:25:24AM +0200, Kirill A. Shutemov wrote:
> > > > > > On Thu, Oct 22, 2015 at 06:00:51PM +0900, Minchan Kim wrote:
> > > > > > > On Thu, Oct 22, 2015 at 10:21:36AM +0900, Minchan Kim wrote:
> > > > > > > > Hello Hugh,
> > > > > > > > 
> > > > > > > > On Wed, Oct 21, 2015 at 05:59:59PM -0700, Hugh Dickins wrote:
> > > > > > > > > On Thu, 22 Oct 2015, Minchan Kim wrote:
> > > > > > > > > > 
> > > > > > > > > > I added the code to check it and queued it again but I had another oops
> > > > > > > > > > in this time but symptom is related to anon_vma, too.
> > > > > > > > > > (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> > > > > > > > > > It seems page_get_anon_vma returns NULL since the page was not page_mapped
> > > > > > > > > > at that time but second check of page_mapped right before try_to_unmap seems
> > > > > > > > > > to be true.
> > > > > > > > > > 
> > > > > > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > > > > > page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> > > > > > > > > > flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> > > > > > > > > > page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
> > > > > > > > > 
> > > > > > > > > That's interesting, that's one I added in my page migration series.
> > > > > > > > > Let me think on it, but it could well relate to the one you got before.
> > > > > > > > 
> > > > > > > > I will roll back to mm/madv_free-v4.3-rc5-mmotm-2015-10-15-15-20
> > > > > > > > instead of next-20151021 to remove noise from your migration cleanup
> > > > > > > > series and will test it again.
> > > > > > > > If it is fixed, I will test again with your migration patchset, then.
> > > > > > > 
> > > > > > > I tested mmotm-2015-10-15-15-20 with test program I attach for a long time.
> > > > > > > Therefore, there is no patchset from Hugh's migration patch in there.
> > > > > > > And I added below debug code with request from Kirill to all test kernels.
> > > > > > 
> > > > > > It took too long time (and a lot of printk()), but I think I track it down
> > > > > > finally.
> > > > > >  
> > > > > > The patch below seems fixes issue for me. It's not yet properly tested, but
> > > > > > looks like it works.
> > > > > > 
> > > > > > The problem was my wrong assumption on how migration works: I thought that
> > > > > > kernel would wait migration to finish on before deconstruction mapping.
> > > > > > 
> > > > > > But turn out that's not true.
> > > > > > 
> > > > > > As result if zap_pte_range() races with split_huge_page(), we can end up
> > > > > > with page which is not mapped anymore but has _count and _mapcount
> > > > > > elevated. The page is on LRU too. So it's still reachable by vmscan and by
> > > > > > pfn scanners (Sasha showed few similar traces from compaction too).
> > > > > > It's likely that page->mapping in this case would point to freed anon_vma.
> > > > > > 
> > > > > > BOOM!
> > > > > > 
> > > > > > The patch modify freeze/unfreeze_page() code to match normal migration
> > > > > > entries logic: on setup we remove page from rmap and drop pin, on removing
> > > > > > we get pin back and put page on rmap. This way even if migration entry
> > > > > > will be removed under us we don't corrupt page's state.
> > > > > > 
> > > > > > Please, test.
> > > > > > 
> > > > > 
> > > > > kernel: On mmotm-2015-10-15-15-20 + pte_mkdirty patch + your new patch, I tested
> > > > > one I sent to you(ie, oops.c + memcg_test.sh)
> > > > > 
> > > > > page:ffffea00016a0000 count:3 mapcount:0 mapping:ffff88007f49d001 index:0x600001800 compound_mapcount: 0
> > > > > flags: 0x4000000000044009(locked|uptodate|head|swapbacked)
> > > > > page dumped because: VM_BUG_ON_PAGE(!page_mapcount(page))
> > > > > page->mem_cgroup:ffff88007f613c00
> > > > 
> > > > Ignore my previous answer. Still sleeping.
> > > > 
> > > > The right way to fix I think is something like:
> > > > 
> > > > diff --git a/mm/rmap.c b/mm/rmap.c
> > > > index 35643176bc15..f2d46792a554 100644
> > > > --- a/mm/rmap.c
> > > > +++ b/mm/rmap.c
> > > > @@ -1173,20 +1173,12 @@ void do_page_add_anon_rmap(struct page *page,
> > > >  	bool compound = flags & RMAP_COMPOUND;
> > > >  	bool first;
> > > >  
> > > > -	if (PageTransCompound(page)) {
> > > > +	if (PageTransCompound(page) && compound) {
> > > > +		atomic_t *mapcount;
> > > >  		VM_BUG_ON_PAGE(!PageLocked(page), page);
> > > > -		if (compound) {
> > > > -			atomic_t *mapcount;
> > > > -
> > > > -			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > > > -			mapcount = compound_mapcount_ptr(page);
> > > > -			first = atomic_inc_and_test(mapcount);
> > > > -		} else {
> > > > -			/* Anon THP always mapped first with PMD */
> > > > -			first = 0;
> > > > -			VM_BUG_ON_PAGE(!page_mapcount(page), page);
> > > > -			atomic_inc(&page->_mapcount);
> > > > -		}
> > > > +		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > > > +		mapcount = compound_mapcount_ptr(page);
> > > > +		first = atomic_inc_and_test(mapcount);
> > > >  	} else {
> > > >  		VM_BUG_ON_PAGE(compound, page);
> > > >  		first = atomic_inc_and_test(&page->_mapcount);
> > > > -- 
> > > 
> > > kernel: On mmotm-2015-10-15-15-20 + pte_mkdirty patch + freeze/unfreeze patch + above patch,
> > > 
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > BUG: Bad rss-counter state mm:ffff880058d2e580 idx:1 val:512
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > 
> > > <SNIP>
> > > 
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > BUG: Bad rss-counter state mm:ffff880046980700 idx:1 val:511
> > > BUG: Bad rss-counter state mm:ffff880046980700 idx:2 val:1
> > 
> > Hm. I was not able to trigger this and don't see anything obviuous what can
> > lead to this kind of missmatch :-/

I managed to trigger this when switched back from MADV_DONTNEED to
MADV_FREE. Hm..

> > I found one more bug: clearing of PageTail can be visible to other CPUs
> > before updated page->flags on the page.
> > 
> > I don't think this bug is connected to what you've reported, but worth
> > testing.
> 
> I'm happy to test but I ask one thing.
> I hope you send new formal all-on-one patch instead of code snippets.
> It can help to test/communicate easy and others understands current
> issues and your approaches.

I'll post patchset with refcounting fixes today.

> And please say what kernel your patch based on.

That's on top of

https://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git since-4.2

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
