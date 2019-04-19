Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 72B79C282E0
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 22:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 11071217F9
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 22:07:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 11071217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6C46D6B0003; Fri, 19 Apr 2019 18:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64BEB6B0006; Fri, 19 Apr 2019 18:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 514E86B0007; Fri, 19 Apr 2019 18:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C4FA6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 18:07:31 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so6006076qtz.14
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 15:07:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=RJ1z5T/u2h4UsDydlnnlTPgBa1W7RfPMizPcX3N6M/A=;
        b=bKw40HhwCVbSXSS7At6bwV9cGqTh5CyWf2XVen7uNnXPUqRqhkU52HvDPCjrEOxwSM
         2mCKXagyycCTfKbzUVvLiJk3/Km/hUN5MnACmm52l0jJtvBrcartp+2hIh99xelfiYqS
         kis44Tpm34S7GBJZbeLKnZBynoPgHK2nOTnhc7FDs333aD559FMFJVBc1tjd5nHH0SFA
         tN+BnZiK3DTJOcgK5UO3xVFQ1zwM9eM7rlLmnnC1giEj/zgEzWO14OCx1CZG6TVvg4Ts
         3z7ZRRZimKC+GNnVZ/lLNPWAKsc/aAyJ2tR1qaLUBPKb2IHtqzfJdqD9BLwq+9kT+tnT
         9I7w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW+2pOAUdc/gi81dmDtUN5leaicZ+PXpSwAFolkt8L6xxoEuCY4
	Vm/PJFCq1I2F6gBCoaVbaY1Gp9Y1DqCGiPuJJDQop0r//0nMR5fqHTQibr/Au0FoE+ERZyJH2Ks
	vFGmB60wn9F3kMNerBZCcOmjmOQo+PXytrQRFVRvW1Yx3hbP1zaDkq1spwmgWpOLlgA==
X-Received: by 2002:ae9:d886:: with SMTP id u128mr2826683qkf.279.1555711650907;
        Fri, 19 Apr 2019 15:07:30 -0700 (PDT)
X-Received: by 2002:ae9:d886:: with SMTP id u128mr2826635qkf.279.1555711650110;
        Fri, 19 Apr 2019 15:07:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555711650; cv=none;
        d=google.com; s=arc-20160816;
        b=syIL7sbx+UvwiOhs6HeR5Q1BcrztO3eGtaCOiuXJp7vMPvwXu3rHiCatHNjSnyZEI2
         Sy6/bnntuhgxeYPcrieUysLZyLHb+ZsErGSKAGFen45bcMbe2ZdWDmMr/NJ2Dh5y2vUf
         9LH2AFNR9jR66t3MEPe+a7i9VVqmvKmicwByj2b0FxJPVkL/gNMKk4I1e8HUlXBBNoDX
         5R4Kyj6shuB4AYIKLw52hpScacQH3zERGo4gd8LvkaaZcGVDNXOQPciprOLyprRxPW+n
         4LBIMTTBSHw43600/GbP4M5himxuRQMDBbL1GffvU8BIipbBUdxxMHIU/V2ZRGD7SYdB
         Q/1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=RJ1z5T/u2h4UsDydlnnlTPgBa1W7RfPMizPcX3N6M/A=;
        b=mTJlsJ7CotAzyL9gPKAP/OZmELhxzP6UzMmxaS/bhUfBj77cQikEJHA7zfnFdFMdVq
         /PkNG8Hg54i+vacGFCDsU3fXyYnj5LenX+oYiAoM95JHNhUVVnxeAvDmW7S4vJxU4yNc
         w29pan9MK0D/tiaKo+5rreLfcnPrHxJj1GO8BWLU17Q9BdQUSyBjxRROvYmy2lA7RAvM
         oybVEVy0S+ffn7HHyHEZ73WjvwPAYyaMykwm7YFIJ+YtHv5HcE/AWVEgTmsJQB6wmskU
         F5KnHzEJKl0rcM1E6YAiABQknBBlvYIx7PJcSZeXv4ODZ5P52wRUUkbDSjoo5JGm3S+T
         tWNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y17sor5587593qvc.28.2019.04.19.15.07.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Apr 2019 15:07:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzKKzg0NpLfTNo6ZxJKpkZ3tLEmycdVD6SIpQ6z26RBZa9fp5qdweEsTbcLLA6o+VPlDj2r3Q==
X-Received: by 2002:a0c:b5c2:: with SMTP id o2mr5324719qvf.58.1555711649798;
        Fri, 19 Apr 2019 15:07:29 -0700 (PDT)
Received: from redhat.com (pool-173-76-246-42.bstnma.fios.verizon.net. [173.76.246.42])
        by smtp.gmail.com with ESMTPSA id j93sm3334393qtd.82.2019.04.19.15.07.27
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 19 Apr 2019 15:07:28 -0700 (PDT)
Date: Fri, 19 Apr 2019 18:07:26 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nadav Amit <namit@vmware.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arnd Bergmann <arnd@arndb.de>, Jason Wang <jasowang@redhat.com>,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	"VMware, Inc." <pv-drivers@vmware.com>,
	Julien Freche <jfreche@vmware.com>,
	Nadav Amit <nadav.amit@gmail.com>
Subject: Re: [PATCH v2 1/4] mm/balloon_compaction: list interfaces
Message-ID: <20190419174452-mutt-send-email-mst@kernel.org>
References: <20190328010718.2248-1-namit@vmware.com>
 <20190328010718.2248-2-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190328010718.2248-2-namit@vmware.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 01:07:15AM +0000, Nadav Amit wrote:
> Introduce interfaces for ballooning enqueueing and dequeueing of a list
> of pages. These interfaces reduce the overhead of storing and restoring
> IRQs by batching the operations. In addition they do not panic if the
> list of pages is empty.
> 
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: virtualization@lists.linux-foundation.org
> Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
> Signed-off-by: Nadav Amit <namit@vmware.com>
> ---
>  include/linux/balloon_compaction.h |   4 +
>  mm/balloon_compaction.c            | 145 +++++++++++++++++++++--------
>  2 files changed, 111 insertions(+), 38 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index f111c780ef1d..1da79edadb69 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -64,6 +64,10 @@ extern struct page *balloon_page_alloc(void);
>  extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>  				 struct page *page);
>  extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
> +extern size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
> +				      struct list_head *pages);
> +extern size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
> +				     struct list_head *pages, int n_req_pages);
>  

Why size_t I wonder? It can never be > n_req_pages which is int.
Callers also seem to assume int.

>  static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
>  {


> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index ef858d547e2d..88d5d9a01072 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -10,6 +10,106 @@
>  #include <linux/export.h>
>  #include <linux/balloon_compaction.h>
>  
> +static int balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
> +				     struct page *page)
> +{
> +	/*
> +	 * Block others from accessing the 'page' when we get around to
> +	 * establishing additional references. We should be the only one
> +	 * holding a reference to the 'page' at this point.
> +	 */
> +	if (!trylock_page(page)) {
> +		WARN_ONCE(1, "balloon inflation failed to enqueue page\n");
> +		return -EFAULT;

Looks like all callers bug on a failure. So let's just do it here,
and then make this void?

> +	}
> +	list_del(&page->lru);
> +	balloon_page_insert(b_dev_info, page);
> +	unlock_page(page);
> +	__count_vm_event(BALLOON_INFLATE);
> +	return 0;
> +}
> +
> +/**
> + * balloon_page_list_enqueue() - inserts a list of pages into the balloon page
> + *				 list.
> + * @b_dev_info: balloon device descriptor where we will insert a new page to
> + * @pages: pages to enqueue - allocated using balloon_page_alloc.
> + *
> + * Driver must call it to properly enqueue a balloon pages before definitively
> + * removing it from the guest system.

A bunch of grammar error here. Pls fix for clarify.
Also - document that nothing must lock the pages? More assumptions?
What is "it" in this context? All pages? And what does removing from
guest mean? Really adding to the balloon?

> + *
> + * Return: number of pages that were enqueued.
> + */
> +size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
> +			       struct list_head *pages)
> +{
> +	struct page *page, *tmp;
> +	unsigned long flags;
> +	size_t n_pages = 0;
> +
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	list_for_each_entry_safe(page, tmp, pages, lru) {
> +		balloon_page_enqueue_one(b_dev_info, page);

Do we want to do something about an error here?

> +		n_pages++;
> +	}
> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +	return n_pages;
> +}
> +EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
> +
> +/**
> + * balloon_page_list_dequeue() - removes pages from balloon's page list and
> + *				 returns a list of the pages.
> + * @b_dev_info: balloon device decriptor where we will grab a page from.
> + * @pages: pointer to the list of pages that would be returned to the caller.
> + * @n_req_pages: number of requested pages.
> + *
> + * Driver must call it to properly de-allocate a previous enlisted balloon pages
> + * before definetively releasing it back to the guest system. This function
> + * tries to remove @n_req_pages from the ballooned pages and return it to the
> + * caller in the @pages list.
> + *
> + * Note that this function may fail to dequeue some pages temporarily empty due
> + * to compaction isolated pages.
> + *
> + * Return: number of pages that were added to the @pages list.
> + */
> +size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
> +				 struct list_head *pages, int n_req_pages)
> +{
> +	struct page *page, *tmp;
> +	unsigned long flags;
> +	size_t n_pages = 0;
> +
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
> +		/*
> +		 * Block others from accessing the 'page' while we get around
> +		 * establishing additional references and preparing the 'page'
> +		 * to be released by the balloon driver.
> +		 */
> +		if (!trylock_page(page))
> +			continue;
> +
> +		if (IS_ENABLED(CONFIG_BALLOON_COMPACTION) &&
> +		    PageIsolated(page)) {
> +			/* raced with isolation */
> +			unlock_page(page);
> +			continue;
> +		}
> +		balloon_page_delete(page);
> +		__count_vm_event(BALLOON_DEFLATE);
> +		unlock_page(page);
> +		list_add(&page->lru, pages);
> +		if (++n_pages >= n_req_pages)
> +			break;
> +	}
> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +
> +	return n_pages;
> +}
> +EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
> +
>  /*
>   * balloon_page_alloc - allocates a new page for insertion into the balloon
>   *			  page list.
> @@ -43,17 +143,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>  {
>  	unsigned long flags;
>  
> -	/*
> -	 * Block others from accessing the 'page' when we get around to
> -	 * establishing additional references. We should be the only one
> -	 * holding a reference to the 'page' at this point.
> -	 */
> -	BUG_ON(!trylock_page(page));
>  	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> -	balloon_page_insert(b_dev_info, page);
> -	__count_vm_event(BALLOON_INFLATE);
> +	balloon_page_enqueue_one(b_dev_info, page);

We used to bug on failure to lock page, now we
silently ignore this error. Why?


>  	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> -	unlock_page(page);
>  }
>  EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>  
> @@ -70,36 +162,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>   */
>  struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
>  {
> -	struct page *page, *tmp;
>  	unsigned long flags;
> -	bool dequeued_page;
> +	LIST_HEAD(pages);
> +	int n_pages;
>  
> -	dequeued_page = false;
> -	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> -	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
> -		/*
> -		 * Block others from accessing the 'page' while we get around
> -		 * establishing additional references and preparing the 'page'
> -		 * to be released by the balloon driver.
> -		 */
> -		if (trylock_page(page)) {
> -#ifdef CONFIG_BALLOON_COMPACTION
> -			if (PageIsolated(page)) {
> -				/* raced with isolation */
> -				unlock_page(page);
> -				continue;
> -			}
> -#endif
> -			balloon_page_delete(page);
> -			__count_vm_event(BALLOON_DEFLATE);
> -			unlock_page(page);
> -			dequeued_page = true;
> -			break;
> -		}
> -	}
> -	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> +	n_pages = balloon_page_list_dequeue(b_dev_info, &pages, 1);
>  
> -	if (!dequeued_page) {
> +	if (n_pages != 1) {
>  		/*
>  		 * If we are unable to dequeue a balloon page because the page
>  		 * list is empty and there is no isolated pages, then something
> @@ -112,9 +181,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
>  			     !b_dev_info->isolated_pages))
>  			BUG();
>  		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> -		page = NULL;
> +		return NULL;
>  	}
> -	return page;
> +	return list_first_entry(&pages, struct page, lru);
>  }
>  EXPORT_SYMBOL_GPL(balloon_page_dequeue);
>  
> -- 
> 2.19.1

