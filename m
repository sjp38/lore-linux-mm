Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 5B49282F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 03:03:17 -0400 (EDT)
Received: by padhy1 with SMTP id hy1so59606962pad.0
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 00:03:17 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id v10si8689762pbs.184.2015.10.30.00.03.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 30 Oct 2015 00:03:16 -0700 (PDT)
Date: Fri, 30 Oct 2015 16:03:50 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: kernel oops on mmotm-2015-10-15-15-20
Message-ID: <20151030070350.GB16099@bbox>
References: <20151021052836.GB6024@bbox>
 <20151021110723.GC10597@node.shutemov.name>
 <20151022000648.GD23631@bbox>
 <alpine.LSU.2.11.1510211744380.5219@eggly.anvils>
 <20151022012136.GG23631@bbox>
 <20151022090051.GH23631@bbox>
 <20151029002524.GA12018@node.shutemov.name>
 <20151029075829.GA16099@bbox>
 <20151029095206.GB29870@node.shutemov.name>
MIME-Version: 1.0
In-Reply-To: <20151029095206.GB29870@node.shutemov.name>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Oct 29, 2015 at 11:52:06AM +0200, Kirill A. Shutemov wrote:
> On Thu, Oct 29, 2015 at 04:58:29PM +0900, Minchan Kim wrote:
> > On Thu, Oct 29, 2015 at 02:25:24AM +0200, Kirill A. Shutemov wrote:
> > > On Thu, Oct 22, 2015 at 06:00:51PM +0900, Minchan Kim wrote:
> > > > On Thu, Oct 22, 2015 at 10:21:36AM +0900, Minchan Kim wrote:
> > > > > Hello Hugh,
> > > > > 
> > > > > On Wed, Oct 21, 2015 at 05:59:59PM -0700, Hugh Dickins wrote:
> > > > > > On Thu, 22 Oct 2015, Minchan Kim wrote:
> > > > > > > 
> > > > > > > I added the code to check it and queued it again but I had another oops
> > > > > > > in this time but symptom is related to anon_vma, too.
> > > > > > > (kernel is based on recent mmotm + unconditional mkdirty for bug fix)
> > > > > > > It seems page_get_anon_vma returns NULL since the page was not page_mapped
> > > > > > > at that time but second check of page_mapped right before try_to_unmap seems
> > > > > > > to be true.
> > > > > > > 
> > > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > > Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
> > > > > > > page:ffffea0001cfbfc0 count:3 mapcount:1 mapping:ffff88007f1b5f51 index:0x600000aff
> > > > > > > flags: 0x4000000000048019(locked|uptodate|dirty|swapcache|swapbacked)
> > > > > > > page dumped because: VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma)
> > > > > > 
> > > > > > That's interesting, that's one I added in my page migration series.
> > > > > > Let me think on it, but it could well relate to the one you got before.
> > > > > 
> > > > > I will roll back to mm/madv_free-v4.3-rc5-mmotm-2015-10-15-15-20
> > > > > instead of next-20151021 to remove noise from your migration cleanup
> > > > > series and will test it again.
> > > > > If it is fixed, I will test again with your migration patchset, then.
> > > > 
> > > > I tested mmotm-2015-10-15-15-20 with test program I attach for a long time.
> > > > Therefore, there is no patchset from Hugh's migration patch in there.
> > > > And I added below debug code with request from Kirill to all test kernels.
> > > 
> > > It took too long time (and a lot of printk()), but I think I track it down
> > > finally.
> > >  
> > > The patch below seems fixes issue for me. It's not yet properly tested, but
> > > looks like it works.
> > > 
> > > The problem was my wrong assumption on how migration works: I thought that
> > > kernel would wait migration to finish on before deconstruction mapping.
> > > 
> > > But turn out that's not true.
> > > 
> > > As result if zap_pte_range() races with split_huge_page(), we can end up
> > > with page which is not mapped anymore but has _count and _mapcount
> > > elevated. The page is on LRU too. So it's still reachable by vmscan and by
> > > pfn scanners (Sasha showed few similar traces from compaction too).
> > > It's likely that page->mapping in this case would point to freed anon_vma.
> > > 
> > > BOOM!
> > > 
> > > The patch modify freeze/unfreeze_page() code to match normal migration
> > > entries logic: on setup we remove page from rmap and drop pin, on removing
> > > we get pin back and put page on rmap. This way even if migration entry
> > > will be removed under us we don't corrupt page's state.
> > > 
> > > Please, test.
> > > 
> > 
> > kernel: On mmotm-2015-10-15-15-20 + pte_mkdirty patch + your new patch, I tested
> > one I sent to you(ie, oops.c + memcg_test.sh)
> > 
> > page:ffffea00016a0000 count:3 mapcount:0 mapping:ffff88007f49d001 index:0x600001800 compound_mapcount: 0
> > flags: 0x4000000000044009(locked|uptodate|head|swapbacked)
> > page dumped because: VM_BUG_ON_PAGE(!page_mapcount(page))
> > page->mem_cgroup:ffff88007f613c00
> 
> Ignore my previous answer. Still sleeping.
> 
> The right way to fix I think is something like:
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 35643176bc15..f2d46792a554 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1173,20 +1173,12 @@ void do_page_add_anon_rmap(struct page *page,
>  	bool compound = flags & RMAP_COMPOUND;
>  	bool first;
>  
> -	if (PageTransCompound(page)) {
> +	if (PageTransCompound(page) && compound) {
> +		atomic_t *mapcount;
>  		VM_BUG_ON_PAGE(!PageLocked(page), page);
> -		if (compound) {
> -			atomic_t *mapcount;
> -
> -			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> -			mapcount = compound_mapcount_ptr(page);
> -			first = atomic_inc_and_test(mapcount);
> -		} else {
> -			/* Anon THP always mapped first with PMD */
> -			first = 0;
> -			VM_BUG_ON_PAGE(!page_mapcount(page), page);
> -			atomic_inc(&page->_mapcount);
> -		}
> +		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> +		mapcount = compound_mapcount_ptr(page);
> +		first = atomic_inc_and_test(mapcount);
>  	} else {
>  		VM_BUG_ON_PAGE(compound, page);
>  		first = atomic_inc_and_test(&page->_mapcount);
> -- 

kernel: On mmotm-2015-10-15-15-20 + pte_mkdirty patch + freeze/unfreeze patch + above patch,

Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
BUG: Bad rss-counter state mm:ffff880058d2e580 idx:1 val:512
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS

<SNIP>

Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
Adding 4191228k swap on /dev/vda5.  Priority:-1 extents:1 across:4191228k FS
BUG: Bad rss-counter state mm:ffff880046980700 idx:1 val:511
BUG: Bad rss-counter state mm:ffff880046980700 idx:2 val:1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
