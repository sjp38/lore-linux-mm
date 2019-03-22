Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE138C43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:40:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78EB021904
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 14:40:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78EB021904
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13DCA6B0007; Fri, 22 Mar 2019 10:40:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C7EB6B0008; Fri, 22 Mar 2019 10:40:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E82F56B000A; Fri, 22 Mar 2019 10:40:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A78526B0007
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:40:25 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n10so2339707pgp.21
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 07:40:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=2wUU8qzDB4tO837W93j0Cn/SAdFYvDZS3PORjd6Bk/c=;
        b=TdNPm1/nEtzCGLWi5gCAMxlYJm0aYwjXJ+skxF5ZrDFNu4MJzqOSZLRGiM3R5hH0Vd
         JRuqx3Xnu+hzylCLFPd8ievfqy69rwXXvUry8dw3Q7xVKxAqSAQIId6rWNiafCJCK6gh
         1FJDyJ+nNcGiAFQ9Jdn8fzcmskKMxsAjpTTdSGOxA3Y7k9zUGUNUHg8dVk6HFVMiRj3O
         3lzQKFTHk1HUMm+EbrzgJVeHD5iHfywznhRL4UWK0OsZ05aakH5vLix6kvYjezDDnbOg
         ntIjV9Hw+FNUDGqeMyTz5JQMhwE/2cfooLwt51hSMAhF6wL4MqU4ikThe0WGtuMLCNOW
         6t1g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVSBZUkpQcqWWXRuNkaR+myuf5o7wiyq33LQe4PhA/N5cWTPbbg
	VSSIwjalmy++xLbREzMZEC8c3SAXiFPcrKvet2bdM30PTFp8U1xPvQY+NQim4licnmtkyu7hQuC
	GL4yi1V9X9kEJXovaHXs8MCQ1c0nV47XlrdXXb1tuWMVAVJMpOvPdO7+/43ZfQNtuqg==
X-Received: by 2002:a17:902:142:: with SMTP id 60mr9869073plb.191.1553265625173;
        Fri, 22 Mar 2019 07:40:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyWRMglRJODtqHaWtILSdM05rwKoqGYEWcT30KYcSp6cvCJxAnhSLKLhNfuu8eUYeIIYn6h
X-Received: by 2002:a17:902:142:: with SMTP id 60mr9869011plb.191.1553265624478;
        Fri, 22 Mar 2019 07:40:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553265624; cv=none;
        d=google.com; s=arc-20160816;
        b=ZAMH4uTAyeiiuMiMS2OEraskdycqRdkepkqGhnSFX7oX0dluyd7UbuorrW/83x4WTo
         kqdaf9GoabJJ/bMLkcyOuX/OsSVRiqrwtJC/ABztHbpXw5xosuIDfiON4Z3ZFeXcvhU+
         rkjDlnFtevS0T2uCck3kWnJJ8CXZ/uKh0XziFFyzd+Kv6VRTgTu4MAuxbjfFZnAEaItr
         hQ4NLvdmPEt0kEsdaCJNPh9xzSk98TvJreRaWSmbe4ICz3usMka/wnbKHk4zuu8Rvw6z
         oGw0gYlJtR5L4PH2dCmu72RCfc1p7pOSfI66L1XNClFRRLaOAvEi0z6YUPf6JqnnWhWS
         lLhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=2wUU8qzDB4tO837W93j0Cn/SAdFYvDZS3PORjd6Bk/c=;
        b=qxzmChAmCdCTgeHoUh/C8Zp4xTWqg5Omp/XdtVCn8a2iwMpPaRzskCZC/qrxlCf12V
         Haai2dnTUFEtbO8cl6E6hyJjv66r7SQcmqBKtGyqQkncpU+TvYA59+rTk1Q4QTDL0SF8
         XazrGZ/h3bUqfLZUoViKpZlqWIuwhCZ4wj7k3tZ+teOBtZ35GRPJg2+ZLcF3qigwjHDV
         4W65835C61rDrch2X48RKNpnheCDRbH5nfRqSWej3vdgPZ5JC3vs8JnTZcqPxBukSQv4
         yatkDJkAYikprnF27HNk7VnlqBXu4Zz7GaB11uFEw59ZQvVbrERi+nzMIFjwn3RbO5K2
         0KrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j16si6676210pfa.197.2019.03.22.07.40.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 07:40:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by fmsmga101.fm.intel.com with ESMTP; 22 Mar 2019 07:40:20 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="154819997"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga004.fm.intel.com with ESMTP; 22 Mar 2019 07:40:19 -0700
Date: Fri, 22 Mar 2019 08:41:21 -0600
From: Keith Busch <keith.busch@intel.com>
To: Zi Yan <ziy@nvidia.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-nvdimm@lists.01.org, Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	"Kirill A. Shutemov" <kirill@shutemov.name>,
	John Hubbard <jhubbard@nvidia.com>, Michal Hocko <mhocko@suse.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [PATCH 0/5] Page demotion for memory reclaim
Message-ID: <20190322144120.GB29817@localhost.localdomain>
References: <20190321200157.29678-1-keith.busch@intel.com>
 <5B5EFBC2-2979-4B9F-A43A-1A14F16ACCE1@nvidia.com>
 <20190321223706.GA29817@localhost.localdomain>
 <F33CDC43-745B-4555-B8E0-D50D8024C727@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <F33CDC43-745B-4555-B8E0-D50D8024C727@nvidia.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 21, 2019 at 05:12:33PM -0700, Zi Yan wrote:
> > Yes, we may not want to migrate everything in the shrink_page_list()
> > pages. We might want to keep a page, so we have to do those checks first. At
> > the point we know we want to attempt migration, the page is already
> > locked and not in a list, so it is just easier to directly invoke the
> > new __unmap_and_move_locked() that migrate_pages() eventually also calls.
> 
> Right, I understand that you want to only migrate small pages to begin with. My question is
> why not using the existing migrate_pages() in your patch 3. Like:
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index a5ad0b35ab8e..0a0753af357f 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1261,6 +1261,20 @@ static unsigned long shrink_page_list(struct list_head *page_list,
>                         ; /* try to reclaim the page below */
>                 }
> 
> +               if (!PageCompound(page)) {
> +                       int next_nid = next_migration_node(page);
> +                       int err;
> +
> +                       if (next_nid != TERMINAL_NODE) {
> +                               LIST_HEAD(migrate_list);
> +                               list_add(&migrate_list, &page->lru);
> +                               err = migrate_pages(&migrate_list, alloc_new_node_page, NULL,
> +                                       next_nid, MIGRATE_ASYNC, MR_DEMOTION);
> +                               if (err)
> +                                       putback_movable_pages(&migrate_list);
> +                       }
> +               }
> +
>                 /*
>                  * Anonymous process memory has backing store?
>                  * Try to allocate it some swap space here.
> 
> Because your new migrate_demote_mapping() basically does the same thing as the code above.
> If you are not OK with the gfp flags in alloc_new_node_page(), you can just write your own
> alloc_new_node_page(). :)

The page is already locked, you can't call migrate_pages()
with locked pages. You'd have to surround migrate_pages with
unlock_page/try_lock_page, and I thought that looked odd. Further,
it changes the flow if the subsequent try lock fails, and I'm trying to
be careful about not introducing different behavior if migration fails.

Patch 2/5 is included here so we can reuse the necessary code from a
locked page context.

