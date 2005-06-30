Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5UJ2Li7049798
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 15:02:21 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5UJ2KcC188934
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:02:20 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5UJ2K5l014727
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:02:20 -0600
Subject: Re: [ckrm-tech] [PATCH 4/6] CKRM: Add guarantee support for mem
	controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1120157624.14910.42.camel@linuxchandra>
References: <1119651942.5105.21.camel@linuxchandra>
	 <1120110730.479552.4689.nullmailer@yamt.dyndns.org>
	 <1120155104.14910.36.camel@linuxchandra>
	 <1120155826.12143.61.camel@localhost>
	 <1120157624.14910.42.camel@linuxchandra>
Content-Type: text/plain
Date: Thu, 30 Jun 2005 12:02:04 -0700
Message-Id: <1120158124.12143.68.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chandra S. Seetharaman [imap]" <sekharan@us.ibm.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-30 at 11:53 -0700, Chandra Seetharaman wrote:
> On Thu, 2005-06-30 at 11:23 -0700, Dave Hansen wrote:
> > On Thu, 2005-06-30 at 11:11 -0700, Chandra Seetharaman wrote:
> > > i don't understand why you think it is a problem to call kfree with lock
> > > held( i agree calling kmalloc with wait flag when a lock is being held
> > > is not correct).
> > 
> > kfree->__cache_free
> > 	->cache_flusharray
> > 	->free_block
> > 	->slab_destroy
> > 	->kmem_freepages
> > 	->free_pages
> > 	->__free_pages
> > 	->__free_pages_ok
> > 	->free_pages_bulk:
> > 
> > 	spin_lock_irqsave(&zone->lock, flags);
> > 
> Oh.... I did not realize Takashi was mentioning zone->lock... i assumed
> zone->lru_lock...
> 
> memory controller does not use zone->lock, it only uses zone->lru_lock..
> I 'll look thru to see if that leads to a deadlock...

static int
free_pages_bulk(struct zone *zone, int count,
                struct list_head *list, unsigned int order)
{
...
        spin_lock_irqsave(&zone->lock, flags);
        while (!list_empty(list) && count--) {
		__free_pages_bulk(page, zone, order);

		/* can't call the allocator in here: /*
		ckrm_clear_page_class(page);
        }
        spin_unlock_irqrestore(&zone->lock, flags);
        return ret;
}

See?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
