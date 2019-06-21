Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1FABC43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 18:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98F5F2075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 18:13:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98F5F2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 358296B0003; Fri, 21 Jun 2019 14:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 308CA8E0002; Fri, 21 Jun 2019 14:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F80E8E0001; Fri, 21 Jun 2019 14:13:53 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id DD8836B0003
	for <Linux-mm@kvack.org>; Fri, 21 Jun 2019 14:13:52 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id j191so4288576pge.1
        for <Linux-mm@kvack.org>; Fri, 21 Jun 2019 11:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=BqsGaWe41DsQ/TNoNBo+fQIRxVfl9O3E6eYzpRtwi5k=;
        b=rlR8Fe4OTuzqObB9uu6BiqomZbjIcAr7nCTrCZn7CKEnHeh25PhMKWUYFl7kIYQv0T
         36SdiKiXH94LnrPe+X9c++Xi26btyHx2h+//3L0HKyo5gRnZjWenylpT8yLmiY4aVpFT
         rniOJIAHykUvTWM1QRphMSkvaIIK3dQLBN42CO2WlpaGGti4p7uvHqyCPGYFQ7LyXGDh
         TJSre6uo6fE+3I9jkWK2lVcgPXqOxt0oqpmXHBwQSGi3vAT53vjtLGejJ8y87ZfQxXNK
         +YiCxBlIMRh/sLspp49UxPVkABJ7uGQjUOCWav3NVyuBtB5IeTNtJaGdb56y1DSNqsHA
         Pw3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXEhFX8zaNekdlb95+CYNkIvEOIkSCTifQWBLAw7+6LpB5zFzor
	Hm6CRJKMOQfJYHfrpQqi34zNx4KuyIVPpN75eTUAyzyL0UctnP8+LMY11xYDrEDbqu6Zxd1oTF5
	K43kw8JbN2Q2/U8+bEycNZJ9Gjc8RLcSTtybaZ2cjpxQcppAZklUIHEuRoDp28wcoQQ==
X-Received: by 2002:a63:2206:: with SMTP id i6mr20310158pgi.349.1561140832509;
        Fri, 21 Jun 2019 11:13:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyi8CLpSNrt1NCuoG8E6LMaI6DE9ND8szQCwn2Br7lub2EFBYnOJt6hH9hTjGQorI8Wj7Yr
X-Received: by 2002:a63:2206:: with SMTP id i6mr20310077pgi.349.1561140831601;
        Fri, 21 Jun 2019 11:13:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561140831; cv=none;
        d=google.com; s=arc-20160816;
        b=EAfg35BtUIehnyUwNLIhKeRwComee6+SEcGJrR7wMvZpiBYbPhwF8Yu5joQdl6QZcM
         8NY0PXJK0oe5xLE9WQJ9uyQ12KkITC72pv71cX01WQ6MHUs7OZSSeSuXnLwzhJHJMcf+
         E6GlWnS4nbLtx0FcF+kwko6gLA8AwO1rGYoc5AvIwOK3NXfD83D1pIbd8tF1nb37JEII
         go/2J0t84mfxi9EMv8zOHFBWzBb55KMTNBlekrxqWnjrSWYh7Q48UurOubzelvnauM5/
         PC49nUu8qN0cgbW4ZNLPBCZptFV39ihYAlF12vT2plhXiIAGpMVDwr07CkuV4vzBJ+Ht
         +90A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=BqsGaWe41DsQ/TNoNBo+fQIRxVfl9O3E6eYzpRtwi5k=;
        b=e/hYjCrL/5UcZUJokXJRXZmrxONHvIYDgwLu48FCBwbIiWIUdKfH6JICsfgMo9oM15
         tAHFEgjAOVHv8VgreuxGZ/SGYR/oUenpGHC82DpCKA5t3Zo5olxrKAV0ctX3bYVxqt26
         HlxLHtVLMmjFWdC0ekin58GD8S0tyc/NJTvB7Gh/TuI/OaPUcdFQJRAJLdx04TOiSLUO
         KiJhupmi93pJnObhCmpnQGVFNKDiPGDcxfWD9E+vI7HLUOV3PoJQy+bFYmP0UaHngbe9
         t8+s3zeQGskEheN1x20QULXmR5pTM3LB7UHg4FfIK1EAlThqNUlVkI/ENLmjH9+Tl7iL
         8WZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id m7si3305498pjs.63.2019.06.21.11.13.51
        for <Linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 11:13:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Jun 2019 11:13:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,401,1557212400"; 
   d="scan'208";a="162947849"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga003.jf.intel.com with ESMTP; 21 Jun 2019 11:13:50 -0700
Date: Fri, 21 Jun 2019 11:13:50 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Pingfan Liu <kernelfans@gmail.com>
Cc: Linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>, Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/gup: speed up check_and_migrate_cma_pages() on huge
 page
Message-ID: <20190621181349.GA21680@iweiny-DESK2.sc.intel.com>
References: <1561112116-23072-1-git-send-email-kernelfans@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561112116-23072-1-git-send-email-kernelfans@gmail.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 21, 2019 at 06:15:16PM +0800, Pingfan Liu wrote:
> Both hugetlb and thp locate on the same migration type of pageblock, since
> they are allocated from a free_list[]. Based on this fact, it is enough to
> check on a single subpage to decide the migration type of the whole huge
> page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
> similar on other archs.
> 
> Furthermore, when executing isolate_huge_page(), it avoid taking global
> hugetlb_lock many times, and meanless remove/add to the local link list
> cma_page_list.
> 
> Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ira Weiny <ira.weiny@intel.com>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Christoph Hellwig <hch@lst.de>
> Cc: Keith Busch <keith.busch@intel.com>
> Cc: Mike Kravetz <mike.kravetz@oracle.com>
> Cc: Linux-kernel@vger.kernel.org
> ---
>  mm/gup.c | 13 +++++++++----
>  1 file changed, 9 insertions(+), 4 deletions(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index ddde097..2eecb16 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1342,16 +1342,19 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  	LIST_HEAD(cma_page_list);
>  
>  check_again:
> -	for (i = 0; i < nr_pages; i++) {
> +	for (i = 0; i < nr_pages;) {
> +
> +		struct page *head = compound_head(pages[i]);
> +		long step = 1;
> +
> +		if (PageCompound(head))
> +			step = compound_order(head) - (pages[i] - head);
>  		/*
>  		 * If we get a page from the CMA zone, since we are going to
>  		 * be pinning these entries, we might as well move them out
>  		 * of the CMA zone if possible.
>  		 */
>  		if (is_migrate_cma_page(pages[i])) {

I like this but I think for consistency I would change this pages[i] to be
head.  Even though it is not required.

Ira

> -
> -			struct page *head = compound_head(pages[i]);
> -
>  			if (PageHuge(head)) {
>  				isolate_huge_page(head, &cma_page_list);
>  			} else {
> @@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
>  				}
>  			}
>  		}
> +
> +		i += step;
>  	}
>  
>  	if (!list_empty(&cma_page_list)) {
> -- 
> 2.7.5
> 

