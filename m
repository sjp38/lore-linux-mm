Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12436C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:50:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3DB5218D2
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 13:50:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3DB5218D2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C27A6B0005; Wed, 24 Apr 2019 09:50:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 34AFC6B0006; Wed, 24 Apr 2019 09:50:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2138B6B0007; Wed, 24 Apr 2019 09:50:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id ED21E6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 09:49:59 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id w45so4513336qtb.16
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 06:49:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=HwuSGcRM2DIuoEtZ8HV1XXllsAb7Q8eRlbQDoXvCNOA=;
        b=XkQ4DfyGVO+SrUdjCKn5v2XkBTINyN0k9SSPapFph2+tmARoxel+SJmyuETiDoC20/
         +P9OtfEZoPhKXkgM/KEUhlNDJ0Zy3lFCigTuAIKtaXXB46z3egSnqq8coqj3o8b6Z6BS
         3Ua7f3M+9OCAongKfkiSCvJzAhnxApyTPjkhRaPOfYFrXabc24K0COt5JfbgzHCxpPab
         LSHhI8zTBziiN/szqBWSLp8hKJvKQxhj7Wh0c9D0mYzxIvw7ckGQp6TVHhfBS1+0lcty
         byJMvPo49icQ7s8T0SQOuN+JkhlGX3p+OqKYXt/pw5cZUYNoefJicBex66rk2K+Scjt+
         kQzw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUkZwmvqm5tYhxr+IFUINRqvQCRaxq+q56mJwtQ5vB2eg2wPSGw
	Ms+vNU3YeJUD4l177Qv+SeT+uEcs9QIsTbILyIpsEAm5WRzf3N88kdpk/JKwzPeLbBC80K0AVbk
	klo61mwX2lJ75zz5ctwxNZj9Zoak9NzY+ygawJcbcvxsTbcLiF+LeWmHcXWNMzgOg8Q==
X-Received: by 2002:ac8:35ec:: with SMTP id l41mr1892702qtb.109.1556113799646;
        Wed, 24 Apr 2019 06:49:59 -0700 (PDT)
X-Received: by 2002:ac8:35ec:: with SMTP id l41mr1892631qtb.109.1556113798854;
        Wed, 24 Apr 2019 06:49:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556113798; cv=none;
        d=google.com; s=arc-20160816;
        b=uuP081IImmb2RNM29nvEjF4x+FUxQKM7nypz2ZZ46TsNKWjSCpb7hSN2HhXrCQGmwy
         qmFHiW1asV1BMI88VJ/D41GUROVkuuUziAEraPYqS0ATvGl8otezR7sVN7l/5IK0kUkm
         vAEfVy1KTKkuh4j/Qt8wIfgYDvq8oMhxea1A6opsewunO3THArwELfgT/ySA0qbj5EVm
         Mkn1TpfAOMauGcxQxPtwvrNF3/Q0QHXyjlWd6lr4M0VxmPWtHFjLnFiRNnijbAzciWm7
         8FNv/XaO2x1TR4ll/t/dwIHXNPxzmNaVbkx8iG7wJjSZ4l1+XI6SYEutdhHL60Gqwu8x
         FXMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=HwuSGcRM2DIuoEtZ8HV1XXllsAb7Q8eRlbQDoXvCNOA=;
        b=evXb2lo1MFaodpXNYAVKzks3oWTRRbIHZR6mrOLIGweQwerK/l4iF73w0wC9AxgNw5
         NQ1EQVfY6G/RlIyI0q5dsgf/1qh415v5/PyTG6V+1N/oJ3Os3esus46ZVIECWCJ19D8m
         hfXSG8R6eLp2nWswlLHdJaEV4ejeslmKfax7hyWBfrRcXqd5Hhja/GjS+BUOFh4XoC/4
         eDB5AjxQ3rxriP022h1YTYWd9UJUTrwzSpf7fWaGCsFAk4Yo+zV8HZXwUGV0xxwWsZe7
         NA7+LIGSo/Vm4rRuHwek4CP2wBtw7pZr97Ykkrd2SjYCRd7byr0MLh5+KJDIN4+07p8d
         dohg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p13sor25997187qtp.24.2019.04.24.06.49.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Apr 2019 06:49:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwavF4I0GfRzamem636qQb1cKbPLXq6Zr/qwHQav9LdpvsMBc+2nCq8KFAaSJ4iLylIbZg1rQ==
X-Received: by 2002:ac8:1621:: with SMTP id p30mr15629737qtj.23.1556113798434;
        Wed, 24 Apr 2019 06:49:58 -0700 (PDT)
Received: from redhat.com (pool-173-76-105-71.bstnma.fios.verizon.net. [173.76.105.71])
        by smtp.gmail.com with ESMTPSA id o9sm3729249qtq.84.2019.04.24.06.49.56
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 24 Apr 2019 06:49:57 -0700 (PDT)
Date: Wed, 24 Apr 2019 09:49:54 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nadav Amit <namit@vmware.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arnd Bergmann <arnd@arndb.de>, Julien Freche <jfreche@vmware.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	Jason Wang <jasowang@redhat.com>, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Subject: Re: [PATCH v3 1/4] mm/balloon_compaction: list interfaces
Message-ID: <20190424092829-mutt-send-email-mst@kernel.org>
References: <20190423234531.29371-1-namit@vmware.com>
 <20190423234531.29371-2-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190423234531.29371-2-namit@vmware.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 23, 2019 at 04:45:28PM -0700, Nadav Amit wrote:
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


Looks good overall. Two minor comments below.


> ---
>  include/linux/balloon_compaction.h |   4 +
>  mm/balloon_compaction.c            | 144 +++++++++++++++++++++--------
>  2 files changed, 110 insertions(+), 38 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index f111c780ef1d..430b6047cef7 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -64,6 +64,10 @@ extern struct page *balloon_page_alloc(void);
>  extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>  				 struct page *page);
>  extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
> +extern size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
> +				      struct list_head *pages);
> +extern size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
> +				     struct list_head *pages, size_t n_req_pages);
>  
>  static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
>  {
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index ef858d547e2d..a2995002edc2 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -10,6 +10,105 @@
>  #include <linux/export.h>
>  #include <linux/balloon_compaction.h>
>  
> +static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
> +				     struct page *page)
> +{
> +	/*
> +	 * Block others from accessing the 'page' when we get around to
> +	 * establishing additional references. We should be the only one
> +	 * holding a reference to the 'page' at this point. If we are not, then
> +	 * memory corruption is possible and we should stop execution.
> +	 */
> +	BUG_ON(!trylock_page(page));
> +	list_del(&page->lru);
> +	balloon_page_insert(b_dev_info, page);
> +	unlock_page(page);
> +	__count_vm_event(BALLOON_INFLATE);
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
> + *
> + * Return: number of pages that were enqueued.
> + */
> +size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
> +				 struct list_head *pages)
> +{
> +	struct page *page, *tmp;
> +	unsigned long flags;
> +	size_t n_pages = 0;
> +
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	list_for_each_entry_safe(page, tmp, pages, lru) {
> +		balloon_page_enqueue_one(b_dev_info, page);
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
> + * Driver must call this function to properly de-allocate a previous enlisted
> + * balloon pages before definetively releasing it back to the guest system.
> + * This function tries to remove @n_req_pages from the ballooned pages and
> + * return them to the caller in the @pages list.
> + *
> + * Note that this function may fail to dequeue some pages temporarily empty due
> + * to compaction isolated pages.
> + *
> + * Return: number of pages that were added to the @pages list.
> + */
> +size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
> +				 struct list_head *pages, size_t n_req_pages)
> +{
> +	struct page *page, *tmp;
> +	unsigned long flags;
> +	size_t n_pages = 0;
> +
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
> +		if (n_pages == n_req_pages)
> +			break;
> +
> +		/*
> +		 * Block others from accessing the 'page' while we get around

should be "get around to" - same as in other places


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

I'm not sure whether this list_add must be under the page lock,
but enqueue does list_del under page lock, so I think it's
a good idea to keep dequeue consistent, operating in the
reverse order of enqueue.

> +		++n_pages;
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
> @@ -43,17 +142,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
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
>  	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> -	unlock_page(page);
>  }
>  EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>  
> @@ -70,36 +161,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
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
> @@ -112,9 +180,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
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


With above addressed:

Acked-by: Michael S. Tsirkin <mst@redhat.com>

-- 
MST

