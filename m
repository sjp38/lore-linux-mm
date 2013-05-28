Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id DA5DE6B0036
	for <linux-mm@kvack.org>; Tue, 28 May 2013 08:25:43 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <519BD595.5040405@sr71.net>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1368321816-17719-15-git-send-email-kirill.shutemov@linux.intel.com>
 <519BD595.5040405@sr71.net>
Subject: Re: [PATCHv4 14/39] thp, mm: rewrite delete_from_page_cache() to
 support huge pages
Content-Transfer-Encoding: 7bit
Message-Id: <20130528122812.0D624E0090@blue.fi.intel.com>
Date: Tue, 28 May 2013 15:28:12 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Dave Hansen wrote:
> On 05/11/2013 06:23 PM, Kirill A. Shutemov wrote:
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > 
> > As with add_to_page_cache_locked() we handle HPAGE_CACHE_NR pages a
> > time.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  mm/filemap.c |   31 +++++++++++++++++++++++++------
> >  1 file changed, 25 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index b0c7c8c..657ce82 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -115,6 +115,9 @@
> >  void __delete_from_page_cache(struct page *page)
> >  {
> >  	struct address_space *mapping = page->mapping;
> > +	bool thp = PageTransHuge(page) &&
> > +		IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE);
> > +	int nr;
> 
> Is that check for the config option really necessary?  How would we get
> a page with PageTransHuge() set without it being enabled?

I'll drop it and use hpagecache_nr_page() instead.

> I like to rewrite your code. :)

It's nice. Thanks.

> Which reminds me...  Why do we handle their reference counts differently? :)
> 
> It seems like we could easily put a for loop in delete_from_page_cache()
> that will release their reference counts along with the head page.
> Wouldn't that make the code less special-cased for tail pages?

delete_from_page_cache() is not the only user of
__delete_from_page_cache()...

It seems I did it wrong in add_to_page_cache_locked(). We shouldn't take
references on tail pages there, only one on head. On split it will be
distributed properly.

> >  	/* Leave page->index set: truncation lookup relies upon it */
> > -	mapping->nrpages--;
> > -	__dec_zone_page_state(page, NR_FILE_PAGES);
> > +	mapping->nrpages -= nr;
> > +	__mod_zone_page_state(page_zone(page), NR_FILE_PAGES, -nr);
> >  	if (PageSwapBacked(page))
> > -		__dec_zone_page_state(page, NR_SHMEM);
> > +		__mod_zone_page_state(page_zone(page), NR_SHMEM, -nr);
> >  	BUG_ON(page_mapped(page));
> 
> Man, we suck:
> 
> 	__dec_zone_page_state()
> and
> 	__mod_zone_page_state()
> 
> take a differently-typed first argument.  <sigh>
> 
> Would there be any good to making __dec_zone_page_state() check to see
> if the page we passed in _is_ a compound page, and adjusting its
> behaviour accordingly?

Yeah, it would be better but I think it outside the scope of the patchset.
Probably, later.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
