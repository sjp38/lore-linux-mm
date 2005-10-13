Received: from hastur.corp.sgi.com (hastur.corp.sgi.com [198.149.32.33])
	by omx1.americas.sgi.com (8.12.10/8.12.9/linux-outbound_gateway-1.1) with ESMTP id j9DMcbxT028635
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 17:38:38 -0500
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by hastur.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id j9DMcCeS202766246
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 15:38:12 -0700 (PDT)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id j9DMcasT95548564
	for <linux-mm@kvack.org>; Thu, 13 Oct 2005 15:38:36 -0700 (PDT)
Message-ID: <434EDDCA.9010001@austin.ibm.com>
Date: Thu, 13 Oct 2005 17:20:58 -0500
From: Joel Schopp <jschopp@austin.ibm.com>
Reply-To: jschopp@austin.ibm.com
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH] Page eviction support in vmscan.c
References: <Pine.LNX.4.62.0510131109210.14810@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0510131109210.14810@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0510131538290.17853@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

> This patch adds functions that allow the eviction of pages to swap space.
> Page eviction may be useful to migrate pages, suspend programs or for
> ummapping single pages (useful for faulty pages or pages with soft ECC
> failures)

I'm curious what use motivated you to write it.  I think for migration 
it would usually make more sense to let the swapper free up LRU memory 
and then do a memory to memory migration.  But I'm not really a 
migration expert


> swapout_pages does its best to swapout the pages and does multiple passes over the list.
> However, swapout_pages may not be able to evict all pages for a variety of reasons.

Have you thought about using this in combination with the fragmentation 
avoidance patches Mel has been posting?  __GFP_USER flag that adds would 
go a long way toward determining what can and can't be swapped out.  We 
use that for migration with great success.  I'd assume the criteria for 
swapout and migration are pretty similar.

>  /*
> + * Swapout evicts the pages on the list to swap space.
> + * This is essentially a dumbed down version of shrink_list

Have you thought about reusing code from shrink list without duplicating 
it?  That is a whole lot of duplicated code to maintain twice.

> +		if (PageDirty(page)) {
> +			/* Page is dirty, try to write it out here */
> +			switch(pageout(page, mapping)) {
> +			case PAGE_KEEP:
> +			case PAGE_ACTIVATE:
> +				goto retry_later_locked;
> +			case PAGE_SUCCESS:
> +				goto retry_later;
> +			case PAGE_CLEAN:
> +				; /* try to free the page below */
> +			}
> +                }

Tabs vs spaces?

> +
> +		list_del(&page->lru);
> +                unlock_page(page);
> +		put_page(page);
> +                continue;

Tabs vs spaces?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
