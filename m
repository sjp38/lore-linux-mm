Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 584346B00DD
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 22:28:22 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so140112waf.22
        for <linux-mm@kvack.org>; Thu, 05 Mar 2009 19:28:20 -0800 (PST)
Date: Fri, 6 Mar 2009 12:28:14 +0900
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH] generic debug pagealloc (-v2)
Message-ID: <20090306032814.GA9874@localhost.localdomain>
References: <20090305145926.GA27015@localhost.localdomain> <20090305143150.136e2708.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090305143150.136e2708.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, mingo@elte.hu, jirislaby@gmail.com, rmk+lkml@arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Thu, Mar 05, 2009 at 02:31:50PM -0800, Andrew Morton wrote:
> > +#include <linux/kernel.h>
> > +#include <linux/mm.h>
> > +
> > +static void poison_page(struct page *page)
> > +{
> > +	void *addr;
> > +
> > +	if (PageHighMem(page))
> > +		return; /* i goofed */
> 
> heh.  A more complete comment would be needed here.
> 
> Also, as this is a kernel bug, perhaps some sort of runtime warning?

It just skips the poisoning for highmem pages.
Any page poisoning can be skipped safely if it doesn't set the page->poison
flag. So I'm going to put

/*
 * skipping the page poisoning for highmem pages
 */

> > +	page->poison = true;
> > +	addr = page_address(page);
> > +	memset(addr, PAGE_POISON, PAGE_SIZE);
> > +}

...

> > +static void unpoison_page(struct page *page)
> > +{
> > +	void *addr;
> > +
> 
> Shouldn't we check PageHighmem() here also?

It should not happen because page->poison flag is not set for highmem pages.
But it's good for sanity checking. So I'll have a BUG_ON here.

> > +	if (!page->poison)
> > +		return;
> > +

	BUG_ON(PageHighMem(page));

> > +	addr = page_address(page);
> > +	check_poison_mem(addr, PAGE_SIZE);
> > +	page->poison = false;
> > +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
