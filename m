Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id C36456B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 10:27:48 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <514C9C84.2010806@sr71.net>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1363283435-7666-16-git-send-email-kirill.shutemov@linux.intel.com>
 <514C9C84.2010806@sr71.net>
Subject: Re: [PATCHv2, RFC 15/30] thp, libfs: initial support of thp in
 simple_read/write_begin/write_end
Content-Transfer-Encoding: 7bit
Message-Id: <20130328142936.18CA8E0085@blue.fi.intel.com>
Date: Thu, 28 Mar 2013 16:29:36 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave wrote:
> On 03/14/2013 10:50 AM, Kirill A. Shutemov wrote:
> > @@ -383,7 +383,10 @@ EXPORT_SYMBOL(simple_setattr);
> >  
> >  int simple_readpage(struct file *file, struct page *page)
> >  {
> > -	clear_highpage(page);
> > +	if (PageTransHuge(page))
> > +		zero_huge_user(page, 0, HPAGE_PMD_SIZE);
> > +	else
> > +		clear_highpage(page);
> 
> This makes me really wonder on which level we want to be hooking in this
> code.  The fact that we're doing it in simple_readpage() seems to mean
> that we'll have to go explicitly and widely modify every fs that wants
> to support this.
> 
> It seems to me that we either want to hide this behind clear_highpage()
> itself, _or_ make a clear_pagecache_page() function that does it.

clear_pagecache_page() is a good idea.

> BTW, didn't you have a HUGE_PAGE_CACHE_SIZE macro somewhere?  Shouldn't
> that get used here?

No. If we have a huge page in page cache it's always HPAGE_PMD_SIZE.

All these PAGE_CACHE_* are really annoying. page cache page size is always
equal to small page size and the macros only confuses, especially on
border between fs/pagecache and rest mm.

I want to get rid of them eventually.

> 
> >  	flush_dcache_page(page);
> >  	SetPageUptodate(page);
> >  	unlock_page(page);
> > @@ -394,21 +397,41 @@ int simple_write_begin(struct file *file, struct address_space *mapping,
> >  			loff_t pos, unsigned len, unsigned flags,
> >  			struct page **pagep, void **fsdata)
> >  {
> > -	struct page *page;
> > +	struct page *page = NULL;
> >  	pgoff_t index;
> >  
> >  	index = pos >> PAGE_CACHE_SHIFT;
> >  
> > -	page = grab_cache_page_write_begin(mapping, index, flags);
> > +	/* XXX: too weak condition. Good enough for initial testing */
> > +	if (mapping_can_have_hugepages(mapping)) {
> > +		page = grab_cache_huge_page_write_begin(mapping,
> > +				index & ~HPAGE_CACHE_INDEX_MASK, flags);
> > +		/* fallback to small page */
> > +		if (!page || !PageTransHuge(page)) {
> > +			unsigned long offset;
> > +			offset = pos & ~PAGE_CACHE_MASK;
> > +			len = min_t(unsigned long,
> > +					len, PAGE_CACHE_SIZE - offset);
> > +		}
> > +	}
> > +	if (!page)
> > +		page = grab_cache_page_write_begin(mapping, index, flags);
> 
> Same thing goes here.  Can/should we hide the
> grab_cache_huge_page_write_begin() call inside
> grab_cache_page_write_begin()?

No. I want to keep it open coded. fs, not page cache, should decide
whether it wants huge page or not.

> >  	if (!page)
> >  		return -ENOMEM;
> > -
> >  	*pagep = page;
> >  
> > -	if (!PageUptodate(page) && (len != PAGE_CACHE_SIZE)) {
> > -		unsigned from = pos & (PAGE_CACHE_SIZE - 1);
> > -
> > -		zero_user_segments(page, 0, from, from + len, PAGE_CACHE_SIZE);
> > +	if (!PageUptodate(page)) {
> > +		unsigned from;
> > +
> > +		if (PageTransHuge(page) && len != HPAGE_PMD_SIZE) {
> > +			from = pos & ~HPAGE_PMD_MASK;
> > +			zero_huge_user_segments(page, 0, from,
> > +					from + len, HPAGE_PMD_SIZE);
> > +		} else if (len != PAGE_CACHE_SIZE) {
> > +			from = pos & ~PAGE_CACHE_MASK;
> > +			zero_user_segments(page, 0, from,
> > +					from + len, PAGE_CACHE_SIZE);
> > +		}
> >  	}
> 
> Let's say you introduced two new functions:  page_cache_size(page) and
> page_cache_mask(page), and hid the zero_huge_user_segments() inside
> zero_user_segments().  This code would end up looking like this:
> 
> 	if (len != page_cache_size(page)) {
> 		from = pos & ~page_cache_mask(page)
> 		zero_user_segments(page, 0, from,
> 				from + len, page_cache_size(page));
> 	}
> 
> It would also compile down to exactly what was there before without
> having to _explicitly_ put a case in for THP.

I would keep it as is for now. There are not that many places where we
have to check for THP. It can change when (if) we implement it for other
fs'es. We can generalize it later if needed.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
