Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8H9M1Ds002869
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 19:22:01 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8H9KjIU2998314
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 19:20:45 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8H9KSfi027193
	for <linux-mm@kvack.org>; Mon, 17 Sep 2007 19:20:29 +1000
Message-ID: <46EE46C6.1050607@linux.vnet.ibm.com>
Date: Mon, 17 Sep 2007 14:50:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH/RFC 3/14] Reclaim Scalability:  move isolate_lru_page()
 to vmscan.c
References: <20070914205359.6536.98017.sendpatchset@localhost> <20070914205418.6536.5921.sendpatchset@localhost>
In-Reply-To: <20070914205418.6536.5921.sendpatchset@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn wrote:
> +int isolate_lru_page(struct page *page)
> +{
> +	int ret = -EBUSY;
> +
> +	if (PageLRU(page)) {
> +		struct zone *zone = page_zone(page);
> +
> +		spin_lock_irq(&zone->lru_lock);
> +		if (PageLRU(page)) {
> +			ret = 0;
> +			ClearPageLRU(page);
> +			if (PageActive(page))
> +				del_page_from_active_list(zone, page);
> +			else
> +				del_page_from_inactive_list(zone, page);
> +		}

Wouldn't using a pagelist as an argument and moving to that be easier?
Are there any cases where we just remove from the list and not move it
elsewhere?

> +		spin_unlock_irq(&zone->lru_lock);
> +	}
> +	return ret;
> +}
> +

Any chance we could merge __isolate_lru_page() and isolate_lru_page()?



-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
