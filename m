Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1553E6B0008
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 03:22:45 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id i11so5316836pgq.10
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 00:22:45 -0800 (PST)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id m62si6439210pfm.41.2018.02.26.00.22.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 00:22:44 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH RESEND 1/2] mm: swap: clean up swap readahead
References: <20180220085249.151400-1-minchan@kernel.org>
	<20180220085249.151400-2-minchan@kernel.org>
	<874lm83zho.fsf@yhuang-dev.intel.com>
	<20180226045617.GA112402@rodete-desktop-imager.corp.google.com>
	<87d10stjk5.fsf@yhuang-dev.intel.com>
	<20180226054104.GC112402@rodete-desktop-imager.corp.google.com>
Date: Mon, 26 Feb 2018 16:22:41 +0800
In-Reply-To: <20180226054104.GC112402@rodete-desktop-imager.corp.google.com>
	(Minchan Kim's message of "Mon, 26 Feb 2018 14:41:04 +0900")
Message-ID: <87zi3wrwha.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Minchan Kim <minchan@kernel.org> writes:

> On Mon, Feb 26, 2018 at 01:18:50PM +0800, Huang, Ying wrote:
>> Minchan Kim <minchan@kernel.org> writes:
>> 
>> > On Fri, Feb 23, 2018 at 04:02:27PM +0800, Huang, Ying wrote:
>> >> <minchan@kernel.org> writes:
>> >> [snip]
>> >> 
>> >> > diff --git a/mm/swap_state.c b/mm/swap_state.c
>> >> > index 39ae7cfad90f..c56cce64b2c3 100644
>> >> > --- a/mm/swap_state.c
>> >> > +++ b/mm/swap_state.c
>> >> > @@ -332,32 +332,38 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>> >> >  			       unsigned long addr)
>> >> >  {
>> >> >  	struct page *page;
>> >> > -	unsigned long ra_info;
>> >> > -	int win, hits, readahead;
>> >> >  
>> >> >  	page = find_get_page(swap_address_space(entry), swp_offset(entry));
>> >> >  
>> >> >  	INC_CACHE_INFO(find_total);
>> >> >  	if (page) {
>> >> > +		bool vma_ra = swap_use_vma_readahead();
>> >> > +		bool readahead = TestClearPageReadahead(page);
>> >> > +
>> >> 
>> >> TestClearPageReadahead() cannot be called for compound page.  As in
>> >> 
>> >> PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
>> >> 	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
>> >> 
>> >> >  		INC_CACHE_INFO(find_success);
>> >> >  		if (unlikely(PageTransCompound(page)))
>> >> >  			return page;
>> >> > -		readahead = TestClearPageReadahead(page);
>> >> 
>> >> So we can only call it here after checking whether page is compound.
>> >
>> > Hi Huang,
>> >
>> > Thanks for cathing this.
>> > However, I don't see the reason we should rule out THP page for
>> > readahead marker. Could't we relax the rule?
>> >
>> > I hope we can do so that we could remove PageTransCompound check
>> > for readahead marker, which makes code ugly.
>> >
>> > From 748b084d5c3960ec2418d8c51a678aada30f1072 Mon Sep 17 00:00:00 2001
>> > From: Minchan Kim <minchan@kernel.org>
>> > Date: Mon, 26 Feb 2018 13:46:43 +0900
>> > Subject: [PATCH] mm: relax policy for PG_readahead
>> >
>> > This flag is in use for anon THP page so let's relax it.
>> >
>> > Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > Signed-off-by: Minchan Kim <minchan@kernel.org>
>> > ---
>> >  include/linux/page-flags.h | 4 ++--
>> >  1 file changed, 2 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>> > index e34a27727b9a..f12d4dfae580 100644
>> > --- a/include/linux/page-flags.h
>> > +++ b/include/linux/page-flags.h
>> > @@ -318,8 +318,8 @@ PAGEFLAG(MappedToDisk, mappedtodisk, PF_NO_TAIL)
>> >  /* PG_readahead is only used for reads; PG_reclaim is only for writes */
>> >  PAGEFLAG(Reclaim, reclaim, PF_NO_TAIL)
>> >  	TESTCLEARFLAG(Reclaim, reclaim, PF_NO_TAIL)
>> > -PAGEFLAG(Readahead, reclaim, PF_NO_COMPOUND)
>> > -	TESTCLEARFLAG(Readahead, reclaim, PF_NO_COMPOUND)
>> > +PAGEFLAG(Readahead, reclaim, PF_NO_TAIL)
>> > +	TESTCLEARFLAG(Readahead, reclaim, PF_NO_TAIL)
>> >  
>> >  #ifdef CONFIG_HIGHMEM
>> >  /*
>> 
>> We never set Readahead bit for THP in reality.  The original code acts
>> as document for this.  I don't think it is a good idea to change this
>> without a good reason.
>
> I don't like such divergence so that we don't need to care about whether
> the page is THP or not. However, there is pointless to confuse ra stat
> counters, too. How about this?
>
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 8dde719e973c..e169d137d27c 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -348,12 +348,17 @@ struct page *lookup_swap_cache(swp_entry_t entry, struct vm_area_struct *vma,
>  	INC_CACHE_INFO(find_total);
>  	if (page) {
>  		bool vma_ra = swap_use_vma_readahead();
> -		bool readahead = TestClearPageReadahead(page);
> +		bool readahead;
>  
>  		INC_CACHE_INFO(find_success);
> +		/*
> +		 * At the moment, we doesn't support PG_readahead for anon THP
> +		 * so let's bail out rather than confusing the readahead stat.
> +		 */
>  		if (unlikely(PageTransCompound(page)))
>  			return page;
>  
> +		readahead = TestClearPageReadahead(page);
>  		if (vma && vma_ra) {
>  			unsigned long ra_val;
>  			int win, hits;
> @@ -608,8 +613,7 @@ struct page *swap_cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
>  			continue;
>  		if (page_allocated) {
>  			swap_readpage(page, false);
> -			if (offset != entry_offset &&
> -			    likely(!PageTransCompound(page))) {
> +			if (offset != entry_offset) {
>  				SetPageReadahead(page);
>  				count_vm_event(SWAP_RA);
>  			}
> @@ -772,8 +776,7 @@ struct page *swap_vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
>  			continue;
>  		if (page_allocated) {
>  			swap_readpage(page, false);
> -			if (i != ra_info.offset &&
> -			    likely(!PageTransCompound(page))) {
> +			if (i != ra_info.offset) {
>  				SetPageReadahead(page);
>  				count_vm_event(SWAP_RA);
>  			}

This looks good for me.  Thanks!

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
