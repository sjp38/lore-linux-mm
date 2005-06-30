Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j5UIOAkT002772
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 14:24:10 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j5UIO9rL249372
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 14:24:09 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j5UIO8in029791
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 14:24:08 -0400
Subject: Re: [ckrm-tech] [PATCH 4/6] CKRM: Add guarantee support for mem
	controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1120155104.14910.36.camel@linuxchandra>
References: <1119651942.5105.21.camel@linuxchandra>
	 <1120110730.479552.4689.nullmailer@yamt.dyndns.org>
	 <1120155104.14910.36.camel@linuxchandra>
Content-Type: text/plain
Date: Thu, 30 Jun 2005 11:23:45 -0700
Message-Id: <1120155826.12143.61.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chandra S. Seetharaman [imap]" <sekharan@us.ibm.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-30 at 11:11 -0700, Chandra Seetharaman wrote:
> On Thu, 2005-06-30 at 14:52 +0900, YAMAMOTO Takashi wrote:
> > > +static inline void
> > > +ckrm_clear_page_class(struct page *page)
> > > +{
> > > +	struct ckrm_zone *czone = page_ckrmzone(page);
> > > +	if (czone == NULL)
> > > +		return;
> > > +	sub_use_count(czone->memcls, 0, page_zonenum(page), 1);
> > > +	kref_put(&czone->memcls->nr_users, memclass_release);
> > > +	set_page_ckrmzone(page, NULL);
> > >  }
> > 
> > are you sure if it's safe?
> > this function is called with zone->lock held,
> > and memclass_release calls kfree.
> 
> i don't understand why you think it is a problem to call kfree with lock
> held( i agree calling kmalloc with wait flag when a lock is being held
> is not correct).

kfree->__cache_free
	->cache_flusharray
	->free_block
	->slab_destroy
	->kmem_freepages
	->free_pages
	->__free_pages
	->__free_pages_ok
	->free_pages_bulk:

	spin_lock_irqsave(&zone->lock, flags);

Deadlock.

Whew!!!

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
