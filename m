Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98C9CC76191
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 16:02:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DE4C2083B
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 16:02:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="qPRDkybI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DE4C2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFAA08E0012; Sun, 21 Jul 2019 12:02:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C843D8E0010; Sun, 21 Jul 2019 12:02:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4BF98E0012; Sun, 21 Jul 2019 12:02:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 78A818E0010
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 12:02:08 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 71so18354887pld.1
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 09:02:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=5yrKtv7lLSBoGJQSfoUzlzXTf1lEOx7ratjEmiAYLgE=;
        b=nJxm/zevIj/0NbAGHGGWNBPSCttl2Mhn0pMqm3QlPrml3DT4Mdkj0OQn78WTPtYDEN
         FWJnesSXOu37X9K6F3ZyhbM4lOmGq7dvaopZTfEOp3nuCJl+47zRkmc+cr2hAkjxKfU9
         diPednJXlpVXuaDZxndMNxhd25GXV1G2tRDI8Cx7uDw6DfNFj4nTpJrQmY5aq6ndHmtG
         PCCBDjQeNvAXaALmAvlXikWJPgeLMW2I/vEtT0uKznPKpCNsbg2Nwn2967lQqlT2483S
         4JVlE4PG+U3a8VOL3K6VK2bqGvR1ACF3aRVhbY3AnoijmodoH5I7hx1wymCbtAKZl6BK
         1kzg==
X-Gm-Message-State: APjAAAX9s7i5/w34h+m1hDTCUXvODXOy4GjWSJ5Az/2LwibDIIGdD86L
	JYn/t4q9g+wndBZ3gmReLsJ4o2QycwhNepB9i9n8kabxX4RB57F6JgGBuHZ6BBBa8F76ixNR7ze
	3917uXCxZIYidmYZnRQjqxSA3HKP7Vc6IbceWSKi1w7ttvamkowvRMlRQjmmzRbTJWA==
X-Received: by 2002:a17:902:e210:: with SMTP id ce16mr71299771plb.335.1563724928112;
        Sun, 21 Jul 2019 09:02:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzV1L+kG/+MlC56b92DtYaqss5uwMGybjDjEASFOmVmUMSPmjbjjENA1hOUuVIX4ILJMnsl
X-Received: by 2002:a17:902:e210:: with SMTP id ce16mr71299723plb.335.1563724927418;
        Sun, 21 Jul 2019 09:02:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563724927; cv=none;
        d=google.com; s=arc-20160816;
        b=eckCQhdbng1ucUqxvIxs4HEiQUVer6xfuCF4CqRiAkGp4wYRzHUPxsMImN/vjAWJSE
         6cOKJMEK1++qhRxZTUSPCJn1mdb+xhGzWhMOSbLrkobECvOnPeXziGSWLO6fEyt1KK00
         G57gz4aZFfYJ/4Gw3mi29rvw7pXUp2yg7ZKX1Je+IHvscu5UPRlGQUpjVrYBjjzVF6HU
         RS3aiF+yMSocS93yE5gVq6g0F1AEDNgmmSLYFna3cV5VNV0+PiAByESj6PEYV1gCpgHL
         1ertsaHygxBghtOzyuBekmBpUvT354tLaUUF7WjMHxiGlmRiKiXHWQLV7zPXXedvaK3B
         MJwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=5yrKtv7lLSBoGJQSfoUzlzXTf1lEOx7ratjEmiAYLgE=;
        b=JkC39H9MS/xQxCEiozU0RY4pgFJjqrHn12cftw1btHcQGjowUi8WAAVVZJZ6OdpfcR
         k+GyTfxNDJ31NGcxBl5FBmiv6vG9UjXzZDiXqTkwOvEDlq3T/pS8N5r+QfzA7WAf08tV
         C5D4lqa++19ZvFrSfBRF2JBkrPTT80or/AzTRGfpdtqGd4725zCL/Kks92rX2E008lGh
         j5xT8gckoAUYvjQjlHkUOuKk02dObADP907XhH+mqTix24MgOjN7euQ4MLEYbmaSEVWX
         jGa2g1gHdZUnIuQp4lL1tFQ5upJF/j/HUfW/EP2KiuxDQd53lpl/jIVN7SDT3zINkmfm
         CwFg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qPRDkybI;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f96si9409082plb.339.2019.07.21.09.02.07
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 09:02:07 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=qPRDkybI;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=5yrKtv7lLSBoGJQSfoUzlzXTf1lEOx7ratjEmiAYLgE=; b=qPRDkybIjsnEQrqVrMLPTBeEH
	g+yoZazgqTczET0c+OjZrudOmnCNNeeKYrkwA6aEmtn9mQjTqHx23bAenOjrh5jk0rGjghmlHvPSH
	a7pDftoHUDwwSpZ5FCb9oX8CJ4xUnrxzWvxMdQSXrud25gn/yG0qirKbx7XIAZybfZG7c0MH4ooM7
	TipoxwgxcNCmg7bWEMFLr81d+DTEAz7ouRpLwdkuQ5H+g7hOFjEaN+dVUPtfRaL9l7n6lrqT/ICrm
	a1qJk1F43VL+LYKSCijf7WKx7NIWMiToeOij1hHUySurmdqgN6Bfm7qW++/mWEMjDzENV5o+uaCEI
	b4R188mbQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hpEHk-00011f-FV; Sun, 21 Jul 2019 16:02:04 +0000
Date: Sun, 21 Jul 2019 09:02:04 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>,
	Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@linux.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Pekka Enberg <penberg@kernel.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v2 1/3] mm: document zone device struct page field usage
Message-ID: <20190721160204.GB363@bombadil.infradead.org>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-2-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190719192955.30462-2-rcampbell@nvidia.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 19, 2019 at 12:29:53PM -0700, Ralph Campbell wrote:
> Struct page for ZONE_DEVICE private pages uses the page->mapping and
> and page->index fields while the source anonymous pages are migrated to
> device private memory. This is so rmap_walk() can find the page when
> migrating the ZONE_DEVICE private page back to system memory.
> ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
> page->index fields when files are mapped into a process address space.
> 
> Restructure struct page and add comments to make this more clear.

NAK.  I just got rid of this kind of foolishness from struct page,
and you're making it harder to understand, not easier.  The comments
could be improved, but don't lay it out like this again.

> @@ -76,13 +76,35 @@ struct page {
>  	 * avoid collision and false-positive PageTail().
>  	 */
>  	union {
> -		struct {	/* Page cache and anonymous pages */
> -			/**
> -			 * @lru: Pageout list, eg. active_list protected by
> -			 * pgdat->lru_lock.  Sometimes used as a generic list
> -			 * by the page owner.
> -			 */
> -			struct list_head lru;
> +		struct {	/* Page cache, anonymous, ZONE_DEVICE pages */
> +			union {
> +				/**
> +				 * @lru: Pageout list, e.g., active_list
> +				 * protected by pgdat->lru_lock. Sometimes
> +				 * used as a generic list by the page owner.
> +				 */
> +				struct list_head lru;
> +				/**
> +				 * ZONE_DEVICE pages are never on the lru
> +				 * list so they reuse the list space.
> +				 * ZONE_DEVICE private pages are counted as
> +				 * being mapped so the @mapping and @index
> +				 * fields are used while the page is migrated
> +				 * to device private memory.
> +				 * ZONE_DEVICE MEMORY_DEVICE_FS_DAX pages also
> +				 * use the @mapping and @index fields when pmem
> +				 * backed DAX files are mapped.
> +				 */
> +				struct {
> +					/**
> +					 * @pgmap: Points to the hosting
> +					 * device page map.
> +					 */
> +					struct dev_pagemap *pgmap;
> +					/** @zone_device_data: opaque data. */
> +					void *zone_device_data;
> +				};
> +			};
>  			/* See page-flags.h for PAGE_MAPPING_FLAGS */
>  			struct address_space *mapping;
>  			pgoff_t index;		/* Our offset within mapping. */
> @@ -155,12 +177,6 @@ struct page {
>  			spinlock_t ptl;
>  #endif
>  		};
> -		struct {	/* ZONE_DEVICE pages */
> -			/** @pgmap: Points to the hosting device page map. */
> -			struct dev_pagemap *pgmap;
> -			void *zone_device_data;
> -			unsigned long _zd_pad_1;	/* uses mapping */
> -		};
>  
>  		/** @rcu_head: You can use this to free a page by RCU. */
>  		struct rcu_head rcu_head;
> -- 
> 2.20.1
> 

