Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6B59E6B003B
	for <linux-mm@kvack.org>; Wed, 30 Oct 2013 11:31:50 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id um1so1554154pbc.0
        for <linux-mm@kvack.org>; Wed, 30 Oct 2013 08:31:50 -0700 (PDT)
Received: from psmtp.com ([74.125.245.179])
        by mx.google.com with SMTP id a10si2257984pac.308.2013.10.30.08.31.48
        for <linux-mm@kvack.org>;
        Wed, 30 Oct 2013 08:31:49 -0700 (PDT)
Date: Wed, 30 Oct 2013 11:31:38 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1383147098-1rzrc5t2-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20131028221126.GA29431@shutemov.name>
References: <20131028221618.4078637F@viggo.jf.intel.com>
 <20131028221620.042323B3@viggo.jf.intel.com>
 <20131028221126.GA29431@shutemov.name>
Subject: Re: [PATCH 2/2] mm: thp: give transparent hugepage code a
 separatecopy_page
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.jiang@intel.com, Mel Gorman <mgorman@suse.de>, akpm@linux-foundation.org, dhillf@gmail.com

On Tue, Oct 29, 2013 at 12:11:26AM +0200, Kirill A. Shutemov wrote:
> On Mon, Oct 28, 2013 at 03:16:20PM -0700, Dave Hansen wrote:
> > 
> > From: Dave Hansen <dave.hansen@linux.intel.com>
> > 
> > Right now, the migration code in migrate_page_copy() uses 
> > copy_huge_page() for hugetlbfs and thp pages:
> > 
> >        if (PageHuge(page) || PageTransHuge(page))
> >                 copy_huge_page(newpage, page);
> > 
> > So, yay for code reuse.  But:
> > 
> > void copy_huge_page(struct page *dst, struct page *src)
> > {
> >         struct hstate *h = page_hstate(src);
> > 
> > and a non-hugetlbfs page has no page_hstate().  This
> > works 99% of the time because page_hstate() determines
> > the hstate from the page order alone.  Since the page
> > order of a THP page matches the default hugetlbfs page
> > order, it works.
> > 
> > But, if you change the default huge page size on the
> > boot command-line (say default_hugepagesz=1G), then
> > we might not even *have* a 2MB hstate so page_hstate()
> > returns null and copy_huge_page() oopses pretty fast
> > since copy_huge_page() dereferences the hstate:
> > 
> > void copy_huge_page(struct page *dst, struct page *src)
> > {
> >         struct hstate *h = page_hstate(src);
> >         if (unlikely(pages_per_huge_page(h) > MAX_ORDER_NR_PAGES)) {
> > ...
> > 
> > This patch creates a copy_high_order_page() which can
> > be used on THP pages.
> 
> We already have copy_user_huge_page() and copy_user_gigantic_page() in
> generic code (mm/memory.c). I think copy_gigantic_page() and
> copy_huge_page() should be moved there too.

I agree this.

> BTW, I think pages_per_huge_page in copy_user_huge_page() is redunand:
> compound_order(page) should be enough, right?

I guess that thp code is very strict on performance, so developers chose
to pass it as an argument instead of calculating compound_order in each call.
I think the performance gain is small (maybe invisible),
but it's not a bad idea to me.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
