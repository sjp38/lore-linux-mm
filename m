Date: Wed, 23 May 2007 10:50:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch] memory unplug v3 [3/4] page removal
Message-Id: <20070523105039.c4ed278b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705221150100.29456@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
	<20070522160733.964e531b.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705221150100.29456@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007 11:52:11 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:
> 
> > +static int
> > +do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> > +{
> > +	unsigned long pfn;
> > +	struct page *page;
> > +	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
> > +	int not_managed = 0;
> > +	int ret = 0;
> > +	LIST_HEAD(source);
> > +
> > +	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
> > +		if (!pfn_valid(pfn))
> > +			continue;
> > +		page = pfn_to_page(pfn);
> > +		/* page is isolated or being freed ? */
> > +		if ((page_count(page) == 0) || PageReserved(page))
> > +			continue;
> 
> The check above is not necessary. A Page count = 0 page is not on the LRU 
> neither is a Reserved page.

Ah, ok. but I'm now treating error in isolate_lru_page() as fatal.
This code avoid that isolate_lru_page() returns error by !PageLRU().
I'll consider again this part.

> > +	/* this function returns # of failed pages */
> > +	ret = migrate_pages_nocontext(&source, hotremove_migrate_alloc, 0);
> 
> You have no context so the last parameter should be 1?
>
migrate_pages_noccontest()'s 3rd param is equal to migrate_pages()'s 3rd param 'private'.


-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
