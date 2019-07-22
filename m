Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C66CC76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 05:13:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 136DF21E6D
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 05:13:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 136DF21E6D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 947AC6B0003; Mon, 22 Jul 2019 01:13:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F8BF6B0006; Mon, 22 Jul 2019 01:13:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E88E8E0001; Mon, 22 Jul 2019 01:13:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4A5836B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:13:48 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id s21so19177973plr.2
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 22:13:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=n8hTk1m/h0M+XPFO8zjKXRqq0S+S9Y26PwMoPCxCNSc=;
        b=aiB7D4KLi6G4cNn2HskRUj4l47T/J/CprWXmQ1nod5qLSvR2oaVQ9Z4XtR+97yyOtz
         Y01iGCVHZkXVoAj2IT4WThQIpSXELklvhgC0JAbg8OeuG3tH/Nw12GjlbCyXkfmc6rDv
         5M1C+L2pGRLfzl1w57pr1M/dgOUqaWa6hQhErR8/beBevdeLrCvxIwJ7Ghd8PWBsl6C8
         pIl0yeCfGWOMKCEGX7y9dTaAKWNiAoLkcdc6p7WnmMgfmwTTzUjOJbk7Uq9c2Jkoqyhy
         4NjwOawbuaAo+g79MFLp1mqEr2qiz4qzj/icx3tUgAK0B+b+4Q5OZQpASB/UorXkwt61
         PFCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW+ocG2Dz2jOhDeO8uH9uJ0Gh47eHhC8l/VO50hToynBbaLLwAf
	uGB7iHgyT5aEh4UzqVvqipzki2tUom/rlPaJB5ZRGt8+a9383LSOhat65wCKUxSb1J5erTcspp+
	3m+AgGiJFymEHrV4X6P6bJrF6YYLWyinLBu62QeVvRwPrQN9rOIpNLiqMd6QTqTS6OA==
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr73328469plb.263.1563772427934;
        Sun, 21 Jul 2019 22:13:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz5fnGg0XOEQb8IbymuSWPNcknrnEB6fYleImY/yUMDaMb38ijOeINk21V7EUUGW9Sd8WlW
X-Received: by 2002:a17:902:e306:: with SMTP id cg6mr73328412plb.263.1563772427071;
        Sun, 21 Jul 2019 22:13:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563772427; cv=none;
        d=google.com; s=arc-20160816;
        b=eDhbcP3DN4hIpTx4LGEi15CpBq0FU4h7j+Wqsn4MBmF6hfMUfFp9mf05YYNFPT4obc
         4qpVDjIECyQI0jQVzTh/j2VaODEr2F0wJ5PyTR1osnjdxx/y+1PbokRb5I5rUv1eyDAF
         o60LItkUaC0CGMdW7AuxMmDWq+RXhmeJNpahIGVnYPO/NHlamsU500Nth7sWsnzZofP4
         epZjKTqpfKutHmwMafRgzbeyaTdXPf8C/7ulvsABpyBUgul0BQeXv/IGsN6XZUmEkkFK
         YC5yVURwTG9/W+7aXNf+tLq4ynRnsoAMFYDyRb1BuIGqS5PRnAWnr8D/AgDjoWWliOlo
         Ab4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=n8hTk1m/h0M+XPFO8zjKXRqq0S+S9Y26PwMoPCxCNSc=;
        b=irIqguUv/tEKlZLwA0zlutm8+TG2BZxfWC/a+Vv6Pqo/ZyuF6bJaWsrKDLPv8nVQQj
         7Ex2w1ZK9w+AwnGJ0LpWffkCBbWTGkffv8Kx0k1WicYlQZRVAGEPJ86hf7CvlRwOyyzs
         r1ExBvdKYPRyqH0UKbK21H0WvTNzsusUdFl/iaCjgsVDswN5nTW+HrNop8UpyKvcxyVk
         ct8W8WAi0MGt0BMfXpyQi6/WLsQRZW+2QerpMYinZnNjnAcPtGd6n8eEWzovRubputm3
         0H47vV6W/99gja98jPKbqfTDWETXzeaaP2IMNQOhNaUHR1ZgUcQUGIq23DzT+LPsS32m
         Xh4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id o21si10615821pgm.453.2019.07.21.22.13.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jul 2019 22:13:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Jul 2019 22:13:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,293,1559545200"; 
   d="scan'208";a="344308827"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga005.jf.intel.com with ESMTP; 21 Jul 2019 22:13:45 -0700
Date: Sun, 21 Jul 2019 22:13:45 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
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
Message-ID: <20190722051345.GB6157@iweiny-DESK2.sc.intel.com>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-2-rcampbell@nvidia.com>
 <20190721160204.GB363@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190721160204.GB363@bombadil.infradead.org>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 21, 2019 at 09:02:04AM -0700, Matthew Wilcox wrote:
> On Fri, Jul 19, 2019 at 12:29:53PM -0700, Ralph Campbell wrote:
> > Struct page for ZONE_DEVICE private pages uses the page->mapping and
> > and page->index fields while the source anonymous pages are migrated to
> > device private memory. This is so rmap_walk() can find the page when
> > migrating the ZONE_DEVICE private page back to system memory.
> > ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
> > page->index fields when files are mapped into a process address space.
> > 
> > Restructure struct page and add comments to make this more clear.
> 
> NAK.  I just got rid of this kind of foolishness from struct page,
> and you're making it harder to understand, not easier.  The comments
> could be improved, but don't lay it out like this again.

Was V1 of Ralphs patch ok?  It seemed ok to me.

Ira

> 
> > @@ -76,13 +76,35 @@ struct page {
> >  	 * avoid collision and false-positive PageTail().
> >  	 */
> >  	union {
> > -		struct {	/* Page cache and anonymous pages */
> > -			/**
> > -			 * @lru: Pageout list, eg. active_list protected by
> > -			 * pgdat->lru_lock.  Sometimes used as a generic list
> > -			 * by the page owner.
> > -			 */
> > -			struct list_head lru;
> > +		struct {	/* Page cache, anonymous, ZONE_DEVICE pages */
> > +			union {
> > +				/**
> > +				 * @lru: Pageout list, e.g., active_list
> > +				 * protected by pgdat->lru_lock. Sometimes
> > +				 * used as a generic list by the page owner.
> > +				 */
> > +				struct list_head lru;
> > +				/**
> > +				 * ZONE_DEVICE pages are never on the lru
> > +				 * list so they reuse the list space.
> > +				 * ZONE_DEVICE private pages are counted as
> > +				 * being mapped so the @mapping and @index
> > +				 * fields are used while the page is migrated
> > +				 * to device private memory.
> > +				 * ZONE_DEVICE MEMORY_DEVICE_FS_DAX pages also
> > +				 * use the @mapping and @index fields when pmem
> > +				 * backed DAX files are mapped.
> > +				 */
> > +				struct {
> > +					/**
> > +					 * @pgmap: Points to the hosting
> > +					 * device page map.
> > +					 */
> > +					struct dev_pagemap *pgmap;
> > +					/** @zone_device_data: opaque data. */
> > +					void *zone_device_data;
> > +				};
> > +			};
> >  			/* See page-flags.h for PAGE_MAPPING_FLAGS */
> >  			struct address_space *mapping;
> >  			pgoff_t index;		/* Our offset within mapping. */
> > @@ -155,12 +177,6 @@ struct page {
> >  			spinlock_t ptl;
> >  #endif
> >  		};
> > -		struct {	/* ZONE_DEVICE pages */
> > -			/** @pgmap: Points to the hosting device page map. */
> > -			struct dev_pagemap *pgmap;
> > -			void *zone_device_data;
> > -			unsigned long _zd_pad_1;	/* uses mapping */
> > -		};
> >  
> >  		/** @rcu_head: You can use this to free a page by RCU. */
> >  		struct rcu_head rcu_head;
> > -- 
> > 2.20.1
> > 
> 

