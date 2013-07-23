Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 3C1D76B0033
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 07:09:50 -0400 (EDT)
Date: Tue, 23 Jul 2013 06:09:47 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
Message-ID: <20130723110947.GF3421@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <1373594635-131067-5-git-send-email-holt@sgi.com>
 <CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com>
 <20130715174551.GA58640@asylum.americas.sgi.com>
 <51E4375E.1010704@zytor.com>
 <20130715182615.GF3421@sgi.com>
 <51E43F91.1040906@zytor.com>
 <20130723083211.GE16088@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130723083211.GE16088@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Yinghai Lu <yinghai@kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On Tue, Jul 23, 2013 at 10:32:11AM +0200, Ingo Molnar wrote:
> 
> * H. Peter Anvin <hpa@zytor.com> wrote:
> 
> > On 07/15/2013 11:26 AM, Robin Holt wrote:
> >
> > > Is there a fairly cheap way to determine definitively that the struct 
> > > page is not initialized?
> > 
> > By definition I would assume no.  The only way I can think of would be 
> > to unmap the memory associated with the struct page in the TLB and 
> > initialize the struct pages at trap time.
> 
> But ... the only fastpath impact I can see of delayed initialization right 
> now is this piece of logic in prep_new_page():
> 
> @@ -903,6 +964,10 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
> 
>         for (i = 0; i < (1 << order); i++) {
>                 struct page *p = page + i;
> +
> +               if (PageUninitialized2Mib(p))
> +                       expand_page_initialization(page);
> +
>                 if (unlikely(check_new_page(p)))
>                         return 1;
> 
> That is where I think it can be made zero overhead in the 
> already-initialized case, because page-flags are already used in 
> check_new_page():

The problem I see here is that the page flags we need to check for the
uninitialized flag are in the "other" page for the page aligned at the
2MiB virtual address, not the page currently being referenced.

Let me try a version of the patch where we set the PG_unintialized_2m
flag on all pages, including the aligned pages and see what that does
to performance.

Robin

> 
> static inline int check_new_page(struct page *page)
> {
>         if (unlikely(page_mapcount(page) |
>                 (page->mapping != NULL)  |
>                 (atomic_read(&page->_count) != 0)  |
>                 (page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
>                 (mem_cgroup_bad_page_check(page)))) {
>                 bad_page(page);
>                 return 1;
> 
> see that PAGE_FLAGS_CHECK_AT_PREP flag? That always gets checked for every 
> struct page on allocation.
> 
> We can micro-optimize that low overhead to zero-overhead, by integrating 
> the PageUninitialized2Mib() check into check_new_page(). This can be done 
> by adding PG_uninitialized2mib to PAGE_FLAGS_CHECK_AT_PREP and doing:
> 
> 
> 	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
> 		if (PageUninitialized2Mib(p))
> 			expand_page_initialization(page);
> 		...
> 	}
> 
>         if (unlikely(page_mapcount(page) |
>                 (page->mapping != NULL)  |
>                 (atomic_read(&page->_count) != 0)  |
>                 (mem_cgroup_bad_page_check(page)))) {
>                 bad_page(page);
> 
>                 return 1;
> 
> this will result in making it essentially zero-overhead, the 
> expand_page_initialization() logic is now in a slowpath.
> 
> Am I missing anything here?
> 
> Thanks,
> 
> 	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
