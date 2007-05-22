Date: Tue, 22 May 2007 11:52:11 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [Patch] memory unplug v3 [3/4] page removal
In-Reply-To: <20070522160733.964e531b.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0705221150100.29456@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
 <20070522160733.964e531b.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:

> +static int
> +do_migrate_range(unsigned long start_pfn, unsigned long end_pfn)
> +{
> +	unsigned long pfn;
> +	struct page *page;
> +	int move_pages = NR_OFFLINE_AT_ONCE_PAGES;
> +	int not_managed = 0;
> +	int ret = 0;
> +	LIST_HEAD(source);
> +
> +	for (pfn = start_pfn; pfn < end_pfn && move_pages > 0; pfn++) {
> +		if (!pfn_valid(pfn))
> +			continue;
> +		page = pfn_to_page(pfn);
> +		/* page is isolated or being freed ? */
> +		if ((page_count(page) == 0) || PageReserved(page))
> +			continue;

The check above is not necessary. A Page count = 0 page is not on the LRU 
neither is a Reserved page.

> +	/* this function returns # of failed pages */
> +	ret = migrate_pages_nocontext(&source, hotremove_migrate_alloc, 0);

You have no context so the last parameter should be 1?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
