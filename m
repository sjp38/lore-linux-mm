Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 25C4B6B0032
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 04:32:16 -0400 (EDT)
Received: by mail-ea0-f169.google.com with SMTP id h15so4408111eak.28
        for <linux-mm@kvack.org>; Tue, 23 Jul 2013 01:32:14 -0700 (PDT)
Date: Tue, 23 Jul 2013 10:32:11 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC 4/4] Sparse initialization of struct page array.
Message-ID: <20130723083211.GE16088@gmail.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <1373594635-131067-5-git-send-email-holt@sgi.com>
 <CAE9FiQW1s2UwCY6OjzD3+2wG8SjCr1QyCpajhZbk_XhmnFQW4Q@mail.gmail.com>
 <20130715174551.GA58640@asylum.americas.sgi.com>
 <51E4375E.1010704@zytor.com>
 <20130715182615.GF3421@sgi.com>
 <51E43F91.1040906@zytor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51E43F91.1040906@zytor.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Yinghai Lu <yinghai@kernel.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>


* H. Peter Anvin <hpa@zytor.com> wrote:

> On 07/15/2013 11:26 AM, Robin Holt wrote:
>
> > Is there a fairly cheap way to determine definitively that the struct 
> > page is not initialized?
> 
> By definition I would assume no.  The only way I can think of would be 
> to unmap the memory associated with the struct page in the TLB and 
> initialize the struct pages at trap time.

But ... the only fastpath impact I can see of delayed initialization right 
now is this piece of logic in prep_new_page():

@@ -903,6 +964,10 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)

        for (i = 0; i < (1 << order); i++) {
                struct page *p = page + i;
+
+               if (PageUninitialized2Mib(p))
+                       expand_page_initialization(page);
+
                if (unlikely(check_new_page(p)))
                        return 1;

That is where I think it can be made zero overhead in the 
already-initialized case, because page-flags are already used in 
check_new_page():

static inline int check_new_page(struct page *page)
{
        if (unlikely(page_mapcount(page) |
                (page->mapping != NULL)  |
                (atomic_read(&page->_count) != 0)  |
                (page->flags & PAGE_FLAGS_CHECK_AT_PREP) |
                (mem_cgroup_bad_page_check(page)))) {
                bad_page(page);
                return 1;

see that PAGE_FLAGS_CHECK_AT_PREP flag? That always gets checked for every 
struct page on allocation.

We can micro-optimize that low overhead to zero-overhead, by integrating 
the PageUninitialized2Mib() check into check_new_page(). This can be done 
by adding PG_uninitialized2mib to PAGE_FLAGS_CHECK_AT_PREP and doing:


	if (unlikely(page->flags & PAGE_FLAGS_CHECK_AT_PREP)) {
		if (PageUninitialized2Mib(p))
			expand_page_initialization(page);
		...
	}

        if (unlikely(page_mapcount(page) |
                (page->mapping != NULL)  |
                (atomic_read(&page->_count) != 0)  |
                (mem_cgroup_bad_page_check(page)))) {
                bad_page(page);

                return 1;

this will result in making it essentially zero-overhead, the 
expand_page_initialization() logic is now in a slowpath.

Am I missing anything here?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
