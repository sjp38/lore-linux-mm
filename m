Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id k1OFhtPd004704
	for <linux-mm@kvack.org>; Fri, 24 Feb 2006 10:43:55 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k1OFhtAf243600
	for <linux-mm@kvack.org>; Fri, 24 Feb 2006 10:43:55 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id k1OFhsCM029025
	for <linux-mm@kvack.org>; Fri, 24 Feb 2006 10:43:55 -0500
Subject: Re: [PATCH] [RFC] for_each_page_in_zone [1/1]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 24 Feb 2006 07:43:45 -0800
Message-Id: <1140795826.8697.86.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Pavel Machek <pavel@suse.cz>, Mike Kravetz <kravetz@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-02-24 at 17:15 +0900, KAMEZAWA Hiroyuki wrote:
> +struct page *next_page_in_zone(struct page *page, struct zone *zone)
> +{
> +       unsigned long pfn = page_to_pfn(page);
> +
> +       if (!populated_zone(zone))
> +               return NULL;
> +
> +       pfn = next_valid_pfn(pfn, zone->zone_start_pfn + zone->spanned_pages);
> +
> +       if (pfn == END_PFN)
> +               return NULL;
> +
> +       return pfn_to_page(pfn);
> +} 

If there can be a case where a node spans other nodes, then I don't
think this patch will work.  The next_valid_pfn() could be a pfn in
another zone.  I believe that you may have to do a pfn_to_page() and
check the zone on each one.  

There are some ppc64 machines which have memory laid out like this:

  0-100 MB Node0
100-200 MB Node1
200-300 MB Node0

Node0's ZONE_DMA has a start_pfn of 0, a spanned_pages of 300MB and a
present_pages of 200MB.  The next_valid_pfn() after the first 100MB is a
page in Node1.

Sorry if I missed this on the first go around.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
