Return-Path: <SRS0=jH+M=QO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D66EC282CC
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:32:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA0AD218D3
	for <linux-mm@archiver.kernel.org>; Thu,  7 Feb 2019 00:32:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA0AD218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 517498E000B; Wed,  6 Feb 2019 19:32:15 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49F4F8E0002; Wed,  6 Feb 2019 19:32:15 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3409D8E000B; Wed,  6 Feb 2019 19:32:15 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 033A18E0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2019 19:32:15 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id q3so8697274qtq.15
        for <linux-mm@kvack.org>; Wed, 06 Feb 2019 16:32:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=mJiAmqKLP+LsOgdhOiSYPaIcGciOfiP0fbVs2zwov5I=;
        b=PPXLV/+egQ7WlRPlzgC7X/5REcqmyqejXzn7sVgWMyY9f+AXpknF7igAworQN6/M/B
         NxUR0+ZXblkajkyIkI/A2dgm1+OXprB4seuOoRUO2SucN4XCvSb+CF53ATDDmm4qtHWb
         p7A/UNnyIwa7vO9f8a6SWV3CUtA5Iai7bU7FBzWWPEWN4bRXsFMZJPpQcv4+z1uiM6aW
         0Sn0aCGTv34x5YpgJvySXRVkTz5JCDZeyGlh1JljpdGh0QIWYngl1iMDu2gWmB/scv+/
         31P8KaHyAUXtyzwpJJ/dZG3+xPrOuYCOVnv4irvW52tPfa0fvhRd7mSwnn1YH8pCBUAs
         EHCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubzuSoPOGc3G5rYLsIwIGc85+wujFrGGoISF6UX388sXz+yKB9i
	jHVQ7guioXgG5Ji757IxribNpQzECFidwyU565Rpx8vADvBtlO34ZEkyw8pOhxqwfKs9RaWzQbT
	Q4mgDo2XYruVRqqx5uO3hCW0QNMueJA0+mt6Peh4Mf7uiMeL7aAMd5fBxtk3dBLXB4Q==
X-Received: by 2002:a0c:ef88:: with SMTP id w8mr9948212qvr.25.1549499534764;
        Wed, 06 Feb 2019 16:32:14 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6W+hPGSmEwr/BfRhTMwNGrJq6nSGKpkm2xTG9JApMVXE0Ev0YcCbBrBoxzXICNuBrI98l
X-Received: by 2002:a0c:ef88:: with SMTP id w8mr9948162qvr.25.1549499533919;
        Wed, 06 Feb 2019 16:32:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549499533; cv=none;
        d=google.com; s=arc-20160816;
        b=F5uCP6utmq9Dhs2MTEj9C58+8g5zS/Hc0u7iXIMQJVE709r4tbXhTqqSIZxhztRse2
         5L+3wQOh/eHKRnr/CT0VxSbhA1gEYBJzSbSMhnDzIfUTcqtOEHPL/e8CWrCAUZf48nit
         aAkqgw8kEUs/hWxTZKnifNc83ja2Etdl81Q+5sLQZU59fHdYoG+x4skDSj+MwEp2P14d
         vnvBWcjcNSTXnPOCXIFOutIodaUAkBkuUaU3qRVavIXo4WPTH5WcohBQBWN36ToAI5eR
         bNUNoVTDbZ1CNfB16v40G6gDZUwUCcf00PPKcOlcRgxcwqY7Gww+B+Z0H+7usfRs0euM
         52Lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=mJiAmqKLP+LsOgdhOiSYPaIcGciOfiP0fbVs2zwov5I=;
        b=S5bGW6aDwUPANv5FhHwXGWw1qC3tXBnbo9jyUhtQyELhcURdBEFW77LqDOzfZUAMEP
         DqG1mySdeTs6MpyMmrjEJehyc/jWu6pYV/aJ9uo1kJzgicGIj/BNOpUIfurP9oxUiBF+
         nxitfnkVRpEb9cLj8yFL9G41rkAC6R8fkWMEpWNukw4Zfp6pEvVhj9Zqj0E8pcVpp90J
         lXnjl3BmagAvhNGcU9tdneMGD0ZugGxwVpx6W9j+kZDV3l3Bk/b18x3xNyzZuLcumMup
         Zwz3Whob1Z5mWN7SqZ0ZKIIsAISMEYFkS8Aubw/JQ4gvugGLBw/tcwEy1XsplTOAbJ4+
         5nKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r26si2718866qtf.323.2019.02.06.16.32.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Feb 2019 16:32:13 -0800 (PST)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EBA1E2551;
	Thu,  7 Feb 2019 00:32:12 +0000 (UTC)
Received: from redhat.com (ovpn-120-253.rdu2.redhat.com [10.10.120.253])
	by smtp.corp.redhat.com (Postfix) with SMTP id C7EB21001F54;
	Thu,  7 Feb 2019 00:32:11 +0000 (UTC)
Date: Wed, 6 Feb 2019 19:32:11 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Nadav Amit <namit@vmware.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org,
	Julien Freche <jfreche@vmware.com>,
	Jason Wang <jasowang@redhat.com>, linux-mm@kvack.org,
	virtualization@lists.linux-foundation.org
Subject: Re: [PATCH 3/6] mm/balloon_compaction: list interfaces
Message-ID: <20190206191936-mutt-send-email-mst@kernel.org>
References: <20190206235706.4851-1-namit@vmware.com>
 <20190206235706.4851-4-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190206235706.4851-4-namit@vmware.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 07 Feb 2019 00:32:13 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 06, 2019 at 03:57:03PM -0800, Nadav Amit wrote:
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
>  mm/balloon_compaction.c            | 139 +++++++++++++++++++++--------
>  2 files changed, 105 insertions(+), 38 deletions(-)
> 
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index 53051f3d8f25..2c5a8e09e413 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -72,6 +72,10 @@ extern struct page *balloon_page_alloc(void);
>  extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>  				 struct page *page);
>  extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info);
> +extern void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
> +				      struct list_head *pages);
> +extern int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
> +				     struct list_head *pages, int n_req_pages);
>  
>  static inline void balloon_devinfo_init(struct balloon_dev_info *balloon)
>  {
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index ef858d547e2d..b8e82864f82c 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -10,6 +10,100 @@
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
> + */
> +void balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
> +			       struct list_head *pages)
> +{
> +	struct page *page, *tmp;
> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> +	list_for_each_entry_safe(page, tmp, pages, lru)
> +		balloon_page_enqueue_one(b_dev_info, page);
> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);

As this is scanning pages one by one anyway, it will be useful
to have this return the # of pages enqueued.

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
> +int balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
> +			       struct list_head *pages, int n_req_pages)

Are we sure this int never overflows? Why not just use u64
or size_t straight away?

> +{
> +	struct page *page, *tmp;
> +	unsigned long flags;
> +	int n_pages = 0;
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

This looks quite reasonable. In fact virtio can be reworked to use
this too and then the original one can be dropped.

Have the time?

>  /*
>   * balloon_page_alloc - allocates a new page for insertion into the balloon
>   *			  page list.
> @@ -43,17 +137,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
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
> @@ -70,36 +156,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
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
> @@ -112,9 +175,9 @@ struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
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
> 2.17.1

