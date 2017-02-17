Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9A244060D
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 11:15:39 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r18so2786041wmd.1
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 08:15:39 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id 73si8246142wrb.31.2017.02.17.08.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 08:15:37 -0800 (PST)
Date: Fri, 17 Feb 2017 11:15:32 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH V3 3/7] mm: reclaim MADV_FREE pages
Message-ID: <20170217161532.GC23735@cmpxchg.org>
References: <cover.1487100204.git.shli@fb.com>
 <cd6a477063c40ad899ad8f4e964c347525ea23a3.1487100204.git.shli@fb.com>
 <20170216184018.GC20791@cmpxchg.org>
 <20170217054108.GA3653@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170217054108.GA3653@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Shaohua Li <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 17, 2017 at 02:41:08PM +0900, Minchan Kim wrote:
> Hi Johannes,
> 
> On Thu, Feb 16, 2017 at 01:40:18PM -0500, Johannes Weiner wrote:
> > On Tue, Feb 14, 2017 at 11:36:09AM -0800, Shaohua Li wrote:
> > > @@ -911,7 +911,7 @@ static void page_check_dirty_writeback(struct page *page,
> > >  	 * Anonymous pages are not handled by flushers and must be written
> > >  	 * from reclaim context. Do not stall reclaim based on them
> > >  	 */
> > > -	if (!page_is_file_cache(page)) {
> > > +	if (!page_is_file_cache(page) || page_is_lazyfree(page)) {
> > 
> > Do we need this? MADV_FREE clears the dirty bit off the page; we could
> > just let them go through with the function without any special-casing.
> 
> I thought some driver potentially can do GUP with FOLL_TOUCH so that the
> lazyfree page can have PG_dirty with !PG_swapbacked. In this case,
> throttling logic of shrink_page_list can be confused?

Yep, agreed. We should filter these pages here.

> > > @@ -1142,7 +1144,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> > >  		 * The page is mapped into the page tables of one or more
> > >  		 * processes. Try to unmap it here.
> > >  		 */
> > > -		if (page_mapped(page) && mapping) {
> > > +		if (page_mapped(page) && (mapping || lazyfree)) {
> > 
> > Do we actually need to filter for mapping || lazyfree? If we fail to
> > allocate swap, we don't reach here. If the page is a truncated file
> > page, ttu returns pretty much instantly with SWAP_AGAIN. We should be
> > able to just check for page_mapped() alone, no?
> 
> try_to_unmap_one assumes every anonymous pages reached will have swp_entry
> so it should be changed to check PageSwapCache if we go to the way.

Yep, I think it should check page_mapping(). To me that would make the
most sense, see other email: "Don't unmap a ram page with valid data
when there is no secondary storage mapping to maintain integrity."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
