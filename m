Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1ECDC76188
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:06:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C60B2085A
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 15:06:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ybO7AB+a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C60B2085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 164578E000E; Sun, 21 Jul 2019 11:06:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 115B88E0005; Sun, 21 Jul 2019 11:06:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1F3C8E000E; Sun, 21 Jul 2019 11:06:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id D3B528E0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 11:06:41 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k21so40635576ioj.3
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 08:06:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Xzf3C3a2m6td7Np6fZ3Mj/D4mc5h5cUfrrEHhJ1w5sk=;
        b=A9ZYMV88oPGuob6lL0l67jeWA2GJj6QSLpBGFTyq+X7VungUVByX6PHC1E4Z3cQHic
         T0WOHGDJgtk63wVt5jP3xUalqAGjsLfqRo9OuX699OridSTr9GdI3gk0mxv+FHvPExSN
         UkLNr+tTW9Hahv+ClvoKOZuOYmL5d7HlO1T8IVZ62E1Phu2iwZDbzWQrpMmxUSlHbmyd
         vbJ3WQYJrakhBM7a7IIQ6OXm+rgYRJxa8XCe16gyzaVs5BhFr4YFBbPTfK70KOwqI2mp
         Efvki8OcPKqUctHAncaK+kuHHaciOuvBjNHc+3xdvrfOLPL6w/gXcbRIoriwYhYiwdQk
         6syw==
X-Gm-Message-State: APjAAAWgbrr/ggjZlGA0xc+LSGti3cj5oi2ik741tk0lqVG/GCldRhBj
	eWYnPsFpcrQfW7dJkppkPvUCGtsyGtMiOr0SjlCyETJV/qfT++jSC50nvX2asfCt8KdrNzwDNpu
	YpqykxfDZVBAHKoS0CFiOJ2DqeVF99APW7tcTQYt8kY0D/ZXMknS4RHuyk0re+fJ7fw==
X-Received: by 2002:a6b:b602:: with SMTP id g2mr59630852iof.54.1563721601549;
        Sun, 21 Jul 2019 08:06:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysnRwxwPOBRxXSQ2nv1kptih2wwqo4VLnHRdtEwzLkrKDtHFavfWSkR/JB9JenoYkMUYM7
X-Received: by 2002:a6b:b602:: with SMTP id g2mr59630802iof.54.1563721600754;
        Sun, 21 Jul 2019 08:06:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563721600; cv=none;
        d=google.com; s=arc-20160816;
        b=jsgtiUT2W1oPbkknYVAbilF+/GCmakeA4QPjH2QbymTxvOLIdckYEY6jwmTR+FbsJD
         15XzD+T32ctqXMpZoG94x3aMjySV8c+cnjKJpR7YsR09DMFeLpEktFKHvQJEj9f4zUt9
         75tV1Chpwt5dqt4Hh//fuA1mEoS9/yFW4knkcotqoT0fyvYnAiRoKN+j8aYRCOIxPLzR
         uaTjCkwRqjZAfMPCj8JTTCrDZ/YPWBNrWVStNU+mkp6zVfZpm9l5BDGvEVFBnM7K/cxC
         DDE3QGAbdql01jOeu5dSInHX0DGfvRcbV4ja+06Bc0opPqcamWddmxjXlpioXdhsrZbo
         Oqxg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=Xzf3C3a2m6td7Np6fZ3Mj/D4mc5h5cUfrrEHhJ1w5sk=;
        b=CjiP5oQeG75ZPlyziW0ysMHX4rrBbipCGmXvYSOk5IT1ULTEksZqKWZ1zoWOfO4YVZ
         E3iif/T8QEzI/SdnIkQRKAftf2lSlCwuWJUkjQCR7YLoV0uY9JLmbc5Ca104+ahPIJDZ
         zD8aWv1ps9b5vQ1xVJq24zWFYbmmANr8zu+VoYVGjw3w+MRXMIyU4WnKxxWM6rgLGtAI
         cQ6+q/UjJ65HFb5ihHXPzoHU1MkYSZxrbT+O+qzGeovzM69OA15DcHBCupBNpdJBOcGM
         Rm5V7yiaAiymTIP4kemYyVLA+9ttB3BSXGzYX0+7Mt+nBqbkVsmufLvWXCPRemDxFSIL
         lCUQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ybO7AB+a;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id o4si58509734jao.68.2019.07.21.08.06.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 08:06:38 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=ybO7AB+a;
       spf=pass (google.com: best guess record for domain of rdunlap@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=rdunlap@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Transfer-Encoding:Content-Type:
	In-Reply-To:MIME-Version:Date:Message-ID:From:References:Cc:To:Subject:Sender
	:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Xzf3C3a2m6td7Np6fZ3Mj/D4mc5h5cUfrrEHhJ1w5sk=; b=ybO7AB+aHQJpYmgqpoN0bIIAj9
	u8x82O73QHbfDJ1wvx1bEdwvAqOO6ExiffXJBAwE4i7HLHGHFywDY6OUZbRayXrjc1ZvKoyb0zc+y
	CtqS4oR3WH+7l9qty9Tj5mca5yoX+3zuegc466ZVbYItE16/I9HpmBfHGvMnioVARdSC/WWZ8r2ZF
	oHuJiUf6/LTP0LbQhOE1fcFtbT+LvHtV1qGHwv6gYaWzCn/WfcpM0AQ6kI+BOftxCgPsUacwAGcHC
	UAhPHtmWxiFT4v6hy24Hkq+se1RU63eV4Wl7wwQcJF5cFgRBimLrIAZtcTnHHM/UgVKXiamx5gADN
	jfvqxzSg==;
Received: from static-50-53-52-16.bvtn.or.frontiernet.net ([50.53.52.16] helo=[192.168.1.17])
	by merlin.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hpDPT-0001P0-07; Sun, 21 Jul 2019 15:05:59 +0000
Subject: Re: [PATCH v2 1/3] mm: document zone device struct page field usage
To: Ralph Campbell <rcampbell@nvidia.com>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, John Hubbard <jhubbard@nvidia.com>,
 Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>,
 Christoph Lameter <cl@linux.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Lai Jiangshan <jiangshanlai@gmail.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Pekka Enberg <penberg@kernel.org>, Andrey Ryabinin
 <aryabinin@virtuozzo.com>, Christoph Hellwig <hch@lst.de>,
 Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
 <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
References: <20190719192955.30462-1-rcampbell@nvidia.com>
 <20190719192955.30462-2-rcampbell@nvidia.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <7002a29c-6fd0-5938-ad0e-807442e6c3cd@infradead.org>
Date: Sun, 21 Jul 2019 08:05:55 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190719192955.30462-2-rcampbell@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On 7/19/19 12:29 PM, Ralph Campbell wrote:
> Struct page for ZONE_DEVICE private pages uses the page->mapping and
> and page->index fields while the source anonymous pages are migrated to
> device private memory. This is so rmap_walk() can find the page when
> migrating the ZONE_DEVICE private page back to system memory.
> ZONE_DEVICE pmem backed fsdax pages also use the page->mapping and
> page->index fields when files are mapped into a process address space.
> 
> Restructure struct page and add comments to make this more clear.
> 
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Reviewed-by: John Hubbard <jhubbard@nvidia.com>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Christoph Lameter <cl@linux.com>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Lai Jiangshan <jiangshanlai@gmail.com>
> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
> Cc: Pekka Enberg <penberg@kernel.org>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  include/linux/mm_types.h | 42 +++++++++++++++++++++++++++-------------
>  1 file changed, 29 insertions(+), 13 deletions(-)
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 3a37a89eb7a7..f6c52e44d40c 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
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

Did you run this through 'make htmldocs' or anything similar?
The reason I ask is that the "/**" comment below is not in kernel-doc format AFAICT.
I would expect an error or warning, but I haven't tested it.

Thanks.

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
> 


-- 
~Randy

