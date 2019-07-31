Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD51C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:09:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AC643206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 06:09:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AC643206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 52E448E0005; Wed, 31 Jul 2019 02:09:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4DF468E0001; Wed, 31 Jul 2019 02:09:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3A5B58E0005; Wed, 31 Jul 2019 02:09:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 026D98E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 02:09:09 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i26so42453339pfo.22
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 23:09:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=vdm32oLurZ8tx2wYylA7BPqohddJHwpUncmgq/Qdc/4=;
        b=WwxY311Dr8AJmE1TRrbg9ZVMjNVmK+bUYuaRIHXu8LY2qg8ZNNji+URDbT/46ECT+L
         PkNu9cxEansw56DzWFOaXN2GeUPJa9j57oPxOJ7hxBCOXqHE8jv663nSGEVg9Kgc3ENS
         a+8Qkdy8afs74rbg6DcF8txijQfZCVXcUnSxs1BHo+waKEpv5yGcipZpWaF8KPqvSTu4
         BaIVzeiqQQ5Wei1lLgQgC7e8sbYk8WO7LT6mhq/P8EUPsT9OOMmEnod9vmPmG0axg/BW
         T2xos2GH0l8IZpFAyO4/KJMP5w7TLRh7DYuWFXPE4u8DZGD2VJr7cqV2i9uEQYepCpeg
         H0ZA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of bjorn.topel@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=bjorn.topel@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXvsGkXfu6Rwmp0zdr1UDYCutQGCaR8XuYYSvbOVN4jp+4yiMZP
	eldFljbVy7VxNr6Rz3DZBRns5miwT7Qm92jhCm60kKyBkWJksWPfTdPBV2YtjP2xACg1fGnGad4
	TYFlEIGEPqqCMheNg5tnkaCgnTALeE66fbYxHI0OFqRvEPWlZ7R98rEVF7Dbw9Vr3gQ==
X-Received: by 2002:a17:90a:cb81:: with SMTP id a1mr1122535pju.81.1564553348637;
        Tue, 30 Jul 2019 23:09:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzQxkKcJh+60pNaKuKSNLOFq5ADayXKcb7neWwS+ijnjE5Acz4XM1U3nzkcanvrxu9rLlRI
X-Received: by 2002:a17:90a:cb81:: with SMTP id a1mr1122491pju.81.1564553347975;
        Tue, 30 Jul 2019 23:09:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564553347; cv=none;
        d=google.com; s=arc-20160816;
        b=OgdwyouBMBaLciOzouHMO+RxXitTwurY5tyxGawPboLdFbAVQKymFxXVhpgvIer4RB
         M+JFL3JmPXVU4PE+BSvPdGSDLC1PHAwn3xoFumhnC9DgQr23NN9bNRNVyGjUKc3aq6Y8
         yxHr2vLHa8IiiXxiP8+bbnLMJfght19wmgj8a/T4qfRB/nX0RQ7c6LhTFjji1K0l5ChV
         tf5rHkPyRyA9niw96QhqSz42s4GYhXxL/BCNjHox2nS+yglTUtSNyVWp4vHjN35pTYJL
         99OHWJOG5/+HGZt+dgDN4SRvu1GIg6l2PPEcjuwAtEFPo9GbJUGovjKcR26h5ygU317E
         z3yA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=vdm32oLurZ8tx2wYylA7BPqohddJHwpUncmgq/Qdc/4=;
        b=tClNC45q73m1tigHiw58CWSRiWqEcBJQGx4jmqp/y9WeEyBaDLn3lkSNHMs0trIird
         vTE4GPKIH7UiftE4X40tNdIo7Abv0PeI4FYcQIRbvkcZusi4cqxpl4lWmjXpDKNX7f49
         aFDkhw6ELLI2KAXMVUSJxOpUlaLkfYRSbxO8c6DrTnF/1LeLhvTZ6wcj6RV+mwSsHez9
         bWnpKwIUJuN3UzoVN9eqoUC7sDyyZ4tPEpy4ZBbemZNvrfAZVRbxAh1JWiLpXxiGiIT4
         DJEpXF59rDeRSuT30CFNz3Pp0BOST7+45LvZ1DIRVtlnkeEiRKS5hbCf1qPt2NgablWr
         YSuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of bjorn.topel@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=bjorn.topel@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id v10si31457564pgq.17.2019.07.30.23.09.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 23:09:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of bjorn.topel@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of bjorn.topel@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=bjorn.topel@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 Jul 2019 23:09:07 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,328,1559545200"; 
   d="scan'208";a="371975164"
Received: from hzengerx-mobl.ger.corp.intel.com (HELO btopel-mobl.ger.intel.com) ([10.249.33.143])
  by fmsmga006.fm.intel.com with ESMTP; 30 Jul 2019 23:09:00 -0700
Subject: Re: [PATCH v4 3/3] net/xdp: convert put_page() to put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>,
 Christoph Hellwig <hch@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>,
 "Darrick J . Wong" <darrick.wong@oracle.com>,
 Dave Chinner <david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>,
 Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
 Jens Axboe <axboe@kernel.dk>, Jerome Glisse <jglisse@redhat.com>,
 "Kirill A . Shutemov" <kirill@shutemov.name>,
 Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mike Marciniszyn <mike.marciniszyn@intel.com>,
 Mike Rapoport <rppt@linux.ibm.com>, linux-block@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
 linux-xfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 John Hubbard <jhubbard@nvidia.com>,
 Magnus Karlsson <magnus.karlsson@intel.com>,
 "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
References: <20190730205705.9018-1-jhubbard@nvidia.com>
 <20190730205705.9018-4-jhubbard@nvidia.com>
From: =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn.topel@intel.com>
Message-ID: <c1c7b6cd-8f08-0e3f-2f66-557228edabcf@intel.com>
Date: Wed, 31 Jul 2019 08:08:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190730205705.9018-4-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-30 22:57, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Björn Töpel <bjorn.topel@intel.com>
> Cc: Magnus Karlsson <magnus.karlsson@intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>

Acked-by: Björn Töpel <bjorn.topel@intel.com>

> ---
>   net/xdp/xdp_umem.c | 9 +--------
>   1 file changed, 1 insertion(+), 8 deletions(-)
> 
> diff --git a/net/xdp/xdp_umem.c b/net/xdp/xdp_umem.c
> index 83de74ca729a..17c4b3d3dc34 100644
> --- a/net/xdp/xdp_umem.c
> +++ b/net/xdp/xdp_umem.c
> @@ -166,14 +166,7 @@ void xdp_umem_clear_dev(struct xdp_umem *umem)
>   
>   static void xdp_umem_unpin_pages(struct xdp_umem *umem)
>   {
> -	unsigned int i;
> -
> -	for (i = 0; i < umem->npgs; i++) {
> -		struct page *page = umem->pgs[i];
> -
> -		set_page_dirty_lock(page);
> -		put_page(page);
> -	}
> +	put_user_pages_dirty_lock(umem->pgs, umem->npgs, true);
>   
>   	kfree(umem->pgs);
>   	umem->pgs = NULL;
> 

