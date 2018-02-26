Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63D536B0005
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 00:41:11 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id j3so8022169itf.6
        for <linux-mm@kvack.org>; Sun, 25 Feb 2018 21:41:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j123sor813608ioe.289.2018.02.25.21.41.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 25 Feb 2018 21:41:10 -0800 (PST)
Date: Mon, 26 Feb 2018 14:41:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RESEND 1/2] mm: swap: clean up swap readahead
Message-ID: <20180226054104.GC112402@rodete-desktop-imager.corp.google.com>
References: <20180220085249.151400-1-minchan@kernel.org>
 <20180220085249.151400-2-minchan@kernel.org>
 <874lm83zho.fsf@yhuang-dev.intel.com>
 <20180226045617.GA112402@rodete-desktop-imager.corp.google.com>
 <87d10stjk5.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87d10stjk5.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Feb 26, 2018 at 01:18:50PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > On Fri, Feb 23, 2018 at 04:02:27PM +0800, Huang, Ying wrote:
> >> <minchan@kernel.org> writes:
> >> [snip]
> >> 
> >> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> >> > index 39ae7cfad90f..c56cce64b2c3 100644
> >> > --- a/mm/swap_state.c
> >> > +++ b/mm/swap_state.c
> >> > @@ -332,32 +332,38 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
> >> >  			       unsigned long addr)
> >> >  {
> >> >  	struct page *page;
> >> > -	unsigned long ra_info;
> >> > -	int win, hits, readahead;
> >> >  
> >> >  	page = find_get_page(swap_address_space(entry), swp_offset(entry));
> >> >  
> >> >  	INC_CACHE_INFO(find_total);
> >> >  	if (page) {
> >> > +		bool vma_ra = swap_use_vma_readahead();
> >> > +		bool readahead = TestClearPageReadahead(page);
> >> > +
> >> 
> >> TestClearPageReadahead() cannot be called for compound page.  As in
> >> 
> >> PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> >> 	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> >> 
> >> >  		INC_CACHE_INFO(find_success);
> >> >  		if (unlikely(PageTransCompound(page)))
> >> >  			return page;
> >> > -		readahead = TestClearPageReadahead(page);
> >> 
> >> So we can only call it here after checking whether page is compound.
> >
> > Hi Huang,
> >
> > Thanks for cathing this.
> > However, I don't see the reason we should rule out THP page for
> > readahead marker. Could't we relax the rule?
> >
> > I hope we can do so that we could remove PageTransCompound check
> > for readahead marker, which makes code ugly.
> >
> > From 748b084d5c3960ec2418d8c51a678aada30f1072 Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan@kernel.org>
> > Date: Mon, 26 Feb 2018 13:46:43 +0900
> > Subject: [PATCH] mm: relax policy for PG_readahead
> >
> > This flag is in use for anon THP page so let's relax it.
> >
> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/page-flags.h | 4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > index e34a27727b9a..f12d4dfae580 100644
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -318,8 +318,8 @@ PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
> >  /* PG_readahead is only used for reads; PG_reclaim is only for writes */
> >  PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
> >  	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_TAIL)
> > -PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> > -	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
> > +PAGEFLAG(Readahead, reclaim, PF_NO_TAIL)
> > +	TESTCLEARFLAG(Readahead, reclaim, PF_NO_TAIL)
> >  
> >  #ifdef CONFIG_HIGHMEM
> >  /*
> 
> We never set Readahead bit for THP in reality.  The original code acts
> as document for this.  I don't think it is a good idea to change this
> without a good reason.

I don't like such divergence so that we don't need to care about whether
the page is THP or not. However, there is pointless to confuse ra stat
counters, too. How about this?

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 8dde719e973c..e169d137d27c 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -348,12 +348,17 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
 	INC_CACHE_INFO(find_total);
 	if (page) {
 		bool vma_ra = swap_use_vma_readahead();
-		bool readahead = TestClearPageReadahead(page);
+		bool readahead;
 
 		INC_CACHE_INFO(find_success);
+		/*
+		 * At the moment, we doesn't support PG_readahead for anon THP
+		 * so let's bail out rather than confusing the readahead stat.
+		 */
 		if (unlikely(PageTransCompound(page)))
 			return page;
 
+		readahead = TestClearPageReadahead(page);
 		if (vma && vma_ra) {
 			unsigned long ra_val;
 			int win, hits;
@@ -608,8 +613,7 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			continue;
 		if (page_allocated) {
 			swap_readpage(page, false);
-			if (offset != entry_offset &&
-			    likely(!PageTransCompound(page))) {
+			if (offset != entry_offset) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
 			}
@@ -772,8 +776,7 @@ struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
 			continue;
 		if (page_allocated) {
 			swap_readpage(page, false);
-			if (i != ra_info.offset &&
-			    likely(!PageTransCompound(page))) {
+			if (i != ra_info.offset) {
 				SetPageReadahead(page);
 				count_vm_event(SWAP_RA);
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
