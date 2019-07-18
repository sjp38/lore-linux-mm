Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C6DFC76195
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 04:31:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FEF72077C
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 04:31:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FEF72077C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B1536B000A; Thu, 18 Jul 2019 00:31:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83B916B000C; Thu, 18 Jul 2019 00:31:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6B51D8E0001; Thu, 18 Jul 2019 00:31:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 45FC76B000A
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 00:31:47 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id z13so22107819qka.15
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 21:31:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to;
        bh=lcwsxrCQhUeZcwZEXVzgNK1TxystRqZwAGqT9JOfSX0=;
        b=N6JBm1Bnbtl0UhIBuPofBnbniMzuYk5r7KFL0P/X4TLfO4wsC1mUmIsYyF9NbljKKy
         4+QlBM++ginary/Z6WJ/Bw/aYglzXtm9ci8DPMUKd9y7uEYV9c5zBm7or5i2gGZgqUVn
         MhOxzFc/XcslzWl5DUptAobXtH3K+q3+pIbDKmxOraPplIDpUT6lkE1ORQLwTzCCPNKw
         tR93fyGJO6TSeYk0ywxtBZbks7Vlc/5sS+6Jp+cDTuM6YYDzdGhLjN+y2FN/HEsWIcj6
         uNn1SxD68b0XckIHX5NMBhyP8fVmHx/weAleRvqsQHP0zKAmOILhbkHRbV16xcBjgFGC
         9ehg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUQxmXrUqF279xiglQ0xfID1rcNDQU+UmHrOqpJc8GY9UbCQC61
	xf31695kk2PTllIPOzlPUYmtudP4TqDSjzOCM4LXQC8gUowvnt8WSpzdN0BbsBVVq3EtWEn719f
	ZgifrVBj3MIKAsAh6TswDwh4wUziDU6hW4f8veMEsB1wbllEWCpdQEOqrVwHaC4GkWw==
X-Received: by 2002:ac8:16ac:: with SMTP id r41mr30594324qtj.346.1563424307060;
        Wed, 17 Jul 2019 21:31:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2c48SBkfTNcNCCZo2UlBYOfdqlngUqqXI3LkLYjh4dRHawOFaulv4uQ8975bELN+sbpLP
X-Received: by 2002:ac8:16ac:: with SMTP id r41mr30594294qtj.346.1563424306489;
        Wed, 17 Jul 2019 21:31:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563424306; cv=none;
        d=google.com; s=arc-20160816;
        b=K49Ncl1GOtfDbv3bo8eGnDwo3OpmS1lDSLyoCTsVUIvUcCNEKyblgoi6ZJxRYy3WWc
         ICsBQGgegL0l9aO6Yccj8B8wPldsw89uxUbXVazPlx5pQ8xRta4OabHQOaN2YSLdeuQb
         cCindTOSoFVPLi7v9EpGuQhUCHDRl9lgwldvqzwX98dFW78fQvSBZ/k+k9dErooORiX/
         e5gJXLOe0EaQheN2XeddsLhH/1/FHBUpe0RUeQN1gwzp9LkF6SZyojNitHn27RVrwhEN
         l9Vyg49CY84l4/DVd1mIVtU3wrspaCoED+ORHFlkpPhkxhndk2JSNYKV+mf05EYtgV7L
         F+cQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date;
        bh=lcwsxrCQhUeZcwZEXVzgNK1TxystRqZwAGqT9JOfSX0=;
        b=07eZaDjFtnSzMYTeOnSMaEn+DI2WtK6l4jhArDrXVK6KQv6JiaA3iZ0IJ9Iamm2Po4
         OCZfjOCVse90IDlRETozZ26Jhts6mn1uI6PmnEPxATvG8ju0vP30lKoIftonAyrAStVm
         yE7IfZ1HMHalTRjrUKweRmr4Fm+cJbAcZYcs0pw0DEvtzzwaHWOdL5YQFiGSZcbzr7QI
         VdbNDVmGh/ojA1dmhWLVkcri9GccgOecx4i9j7b//8nnzGiVLU/e50/j3QLGEDnZ+n/Z
         HF3iMvZFvWyktcsYk8YC1KB1tURngh97L2b1HGNXWIIZoaIqmctz9HLSSY+L/hczPhsh
         cJKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k18si6198161qvg.102.2019.07.17.21.31.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 21:31:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mst@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=mst@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 73314308FBA9;
	Thu, 18 Jul 2019 04:31:45 +0000 (UTC)
Received: from redhat.com (ovpn-120-147.rdu2.redhat.com [10.10.120.147])
	by smtp.corp.redhat.com (Postfix) with SMTP id 87DBA5D71D;
	Thu, 18 Jul 2019 04:31:33 +0000 (UTC)
Date: Thu, 18 Jul 2019 00:31:31 -0400
From: "Michael S. Tsirkin" <mst@redhat.com>
To: Wei Wang <wei.w.wang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org,
	xdeguillard@vmware.com, namit@vmware.com, akpm@linux-foundation.org,
	pagupta@redhat.com, riel@surriel.com, dave.hansen@intel.com,
	david@redhat.com, konrad.wilk@oracle.com, yang.zhang.wz@gmail.com,
	nitesh@redhat.com, lcapitulino@redhat.com, aarcange@redhat.com,
	pbonzini@redhat.com, alexander.h.duyck@linux.intel.com,
	dan.j.williams@intel.com
Subject: Re: [PATCH v1] mm/balloon_compaction: avoid duplicate page removal
Message-ID: <20190718001605-mutt-send-email-mst@kernel.org>
References: <1563416610-11045-1-git-send-email-wei.w.wang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1563416610-11045-1-git-send-email-wei.w.wang@intel.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 18 Jul 2019 04:31:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 10:23:30AM +0800, Wei Wang wrote:
> Fixes: 418a3ab1e778 (mm/balloon_compaction: List interfaces)
> 
> A #GP is reported in the guest when requesting balloon inflation via
> virtio-balloon. The reason is that the virtio-balloon driver has
> removed the page from its internal page list (via balloon_page_pop),
> but balloon_page_enqueue_one also calls "list_del"  to do the removal.

I would add here "this is necessary when it's used from
balloon_page_enqueue_list but not when it's called
from balloon_page_enqueue".

> So remove the list_del in balloon_page_enqueue_one, and have the callers
> do the page removal from their own page lists.
> 
> Signed-off-by: Wei Wang <wei.w.wang@intel.com>

Patch is good but comments need some work.

> ---
>  mm/balloon_compaction.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
> index 83a7b61..1a5ddc4 100644
> --- a/mm/balloon_compaction.c
> +++ b/mm/balloon_compaction.c
> @@ -11,6 +11,7 @@
>  #include <linux/export.h>
>  #include <linux/balloon_compaction.h>
>  
> +/* Callers ensure that @page has been removed from its original list. */

This comment does not make sense. E.g. balloon_page_enqueue
does nothing to ensure this. And drivers are not supposed
to care how the page lists are managed. Pls drop.

Instead please add the following to balloon_page_enqueue:


	Note: drivers must not call balloon_page_list_enqueue on
	pages that have been pushed to a list with balloon_page_push
	before removing them with balloon_page_pop.
	To all pages on a list, use balloon_page_list_enqueue instead.

>  static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
>  				     struct page *page)
>  {
> @@ -21,7 +22,6 @@ static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_info,
>  	 * memory corruption is possible and we should stop execution.
>  	 */
>  	BUG_ON(!trylock_page(page));
> -	list_del(&page->lru);
>  	balloon_page_insert(b_dev_info, page);
>  	unlock_page(page);
>  	__count_vm_event(BALLOON_INFLATE);
> @@ -47,6 +47,7 @@ size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
>  
>  	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>  	list_for_each_entry_safe(page, tmp, pages, lru) {
> +		list_del(&page->lru);
>  		balloon_page_enqueue_one(b_dev_info, page);
>  		n_pages++;
>  	}
> -- 
> 2.7.4

