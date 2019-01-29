Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4ADA4C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:30:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 159942087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 18:30:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 159942087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE5C78E0003; Tue, 29 Jan 2019 13:30:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A95FD8E0001; Tue, 29 Jan 2019 13:30:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 938238E0003; Tue, 29 Jan 2019 13:30:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 52A878E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:30:27 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so14857821plp.14
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 10:30:27 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Kvykgcx5P0cYGXPI+570bojs50U/deA7Qz53XCWYGcM=;
        b=r9nG5dtjx24FxW/AsrihdmWDStnHqmXrGMk7okPYtpiTOYIoTjZLFVJFYpcSCeYyxF
         oO/p76S3ix2NXDS96UyX9PVb07AytxfNjMTa7al2Qyvkoo31yz98V6ypRnHab8rZewCC
         xO2ZzdAlYcZvS2fTrH/cbT2iXksKUV44h2AOWCVG7zTJAjry8QBEj+X4G4waafFfmZvM
         Pt3xU7e0awMtGVjXjc+WeDYApUfOSOMpuYS+rFuRbLUg3FeOYeKm6t9MwN4Am18ZjwT1
         EvVZSd9GZljE1yvJnOmQ2mDisul7pu1qQUWiE4UayTzioH9cgGJGlsL9Oiz0i9GFnPqL
         5Ggg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AJcUukd9lj1xr6f+AivM0btRmFm6eV/u6zfr9+SN7++h4RqI6T9+LhHw
	JBrUWfUIKL+LFJecOMLmA56+wC9RYJPVef0/AAv/h7Dn0bkcpIBbAO1U3eeuRty7myt5oSgqK0V
	resE8CJFe4PK8e7nMSKzemUHO5jvfnT9kwE4LJpE2FLRhN3XPgMgB4qoDyZcQk67rmA==
X-Received: by 2002:a63:3703:: with SMTP id e3mr24285211pga.348.1548786627024;
        Tue, 29 Jan 2019 10:30:27 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4ZmfZCnpP33vpFWudXCIU8ztUtoMETey8tBRsFkr61s+8BjQm8GIaWaAd6MKp9RpsOZsle
X-Received: by 2002:a63:3703:: with SMTP id e3mr24285176pga.348.1548786626394;
        Tue, 29 Jan 2019 10:30:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548786626; cv=none;
        d=google.com; s=arc-20160816;
        b=BpVtaQswy2alZJaTsdLCC5na3KomIlHVuQiDJmx4BSezoEkZW+Dy1vsGSzmF6lOvZv
         3jdXxEgNccIK4NGMGPtrr6DP0/2/ZEOJiVc/tCQZZBPJcjIBjSvrYqgPcgSNaVB7XEOG
         2GM8JrJu34sjcnASzAj6CrlEjmbEnb9LBkOAIcF86L0CD4EZXoHzImCK8K74FY4Ryvmo
         QLpxIEwRy2BTXmWFTw0vz/Y5/26QRvnDe+2a938zSoTitLzj7KyTggqzCTtplv2z6Ofx
         BNyg9LFG++L6FUd8ZkfvkvkS4q1fohw5SbcTF9PTkoRdv9bL8VJOvwrq9u+7q7mAzeCZ
         saXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Kvykgcx5P0cYGXPI+570bojs50U/deA7Qz53XCWYGcM=;
        b=SC4aCYV0LoNvzZFZc5Sm07KlIr0q10jHjoYk0aQrncgz3LjIfIxzZYbVsOtiZqrMqU
         xFbb6GDiEiV0cO1MDX5CkHHEmkeB90TcKYyB0z8rdSoBnPeD8FdnkT6HIY59IXDRASls
         rLPItQQp8kPTGgRjrs4oC2AjWTRyDVQcN0DpG93eG6fHhMCx89OlEEyHsg0KYvCrRlep
         Z2k21GNz8DZS0I0OeZWogTOS9G7D90+UNqWyLge3t8HC6NgUCaXO2qrW6ibX/0M4JuzT
         YS/9IOrSMI53L6JzS80tomSelpoCuNgUc8QFGnOwxhZYoAawa2BUOf4FlHNEljfzsXID
         fjDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id t75si36423345pfa.170.2019.01.29.10.30.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 10:30:26 -0800 (PST)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 29 Jan 2019 10:30:25 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,537,1539673200"; 
   d="scan'208";a="112066405"
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by orsmga006.jf.intel.com with ESMTP; 29 Jan 2019 10:30:24 -0800
Date: Tue, 29 Jan 2019 10:29:56 -0800
From: Ira Weiny <ira.weiny@intel.com>
To: Joel Nider <joeln@il.ibm.com>
Cc: Jason Gunthorpe <jgg@ziepe.ca>, Leon Romanovsky <leon@kernel.org>,
	Doug Ledford <dledford@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/5] RDMA/uverbs: add owner parameter to ib_umem_get
Message-ID: <20190129182954.GA10129@iweiny-DESK2.sc.intel.com>
References: <1548768386-28289-1-git-send-email-joeln@il.ibm.com>
 <1548768386-28289-4-git-send-email-joeln@il.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1548768386-28289-4-git-send-email-joeln@il.ibm.com>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 29, 2019 at 03:26:24PM +0200, Joel Nider wrote:
> ib_umem_get is a core function used by drivers that support RDMA.
> The 'owner' parameter signifies the process that owns the memory.
> Until now, it was assumed that the owning process was the current
> process. This adds the flexibility to specify a process other than
> the current process. All drivers that call this function are also
> updated, but the default behaviour is to keep backwards
> compatibility by assuming the current process is the owner when
> the 'owner' parameter is NULL.
> 
> Signed-off-by: Joel Nider <joeln@il.ibm.com>
> ---

[snip]

> @@ -183,10 +196,11 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
>  
>  	while (npages) {
>  		down_read(&mm->mmap_sem);
> -		ret = get_user_pages_longterm(cur_base,
> +		ret = get_user_pages_remote_longterm(owner_task,
> +				     mm, cur_base,
>  				     min_t(unsigned long, npages,
> -					   PAGE_SIZE / sizeof (struct page *)),
> -				     gup_flags, page_list, vma_list);
> +				     PAGE_SIZE / sizeof(struct page *)),
> +				     gup_flags, page_list, vma_list, NULL);

qib was recently converted to get_user_pages_longterm.  So qib would need to
be updated as well.

Ira

