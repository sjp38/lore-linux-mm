Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79D2FC282DD
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:54:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B8212177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 22:54:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="hOjBNbxm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B8212177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF2C36B0003; Thu, 23 May 2019 18:54:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B7CB36B0005; Thu, 23 May 2019 18:54:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A1C1F6B0006; Thu, 23 May 2019 18:54:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C1B76B0003
	for <linux-mm@kvack.org>; Thu, 23 May 2019 18:54:13 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id n76so6593227ybf.20
        for <linux-mm@kvack.org>; Thu, 23 May 2019 15:54:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=O/RiGmoYGRmC02sjlkIu6qvEn5MHd+ORmeaARAOsB+c=;
        b=ez/yr+pWdetsN5/VEqV74W6aJ8wokqDfSb/WucqjK/B25wBslLjJ0B3Ku6Tq0nXvkF
         PbEuAS73lXXj4o41xTYYTPE/MPBrFeJlGUqAHptDS6PWTWUfGewXFsHWzAQfFOWP5m9Q
         PvfmbuuPt6OaEzrmyn3LfoiU7bdQ90w/Ysfh3ijdjOviIsl72WPabHZEh5/xtP/AwRrV
         wy5ojGX4OXqE4/sI+vNcm6K1mvKiIJBxLn+A1pdqUYb/WKT49Bb3oYMvH1lqVmoW/h8S
         lJNbRCF2RCmhxK5dHf87durizBz4Mkss/mFEnrYke42U1JL1IFH6nfhttuXYGrRN92tu
         5WDQ==
X-Gm-Message-State: APjAAAWEDaa+r1BuksvUfFGMtWd1YQt/bdU2zZT0iZlO6qs4TNbb/PKU
	4CERp7vs2Fb49Pu4AJ1II0TJ1kGUfD5eu7muBKkHto+5Lkvh5K1jeD46c83STpjfCdDPsaXZVsZ
	UItb9lPtirUg/wGdZEK2udr34CoWWStqFWnFa4n/zG7dQ7nWGs1gUJMq2GCVVl+rNpw==
X-Received: by 2002:a25:cfca:: with SMTP id f193mr21443238ybg.478.1558652053284;
        Thu, 23 May 2019 15:54:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyr4N/6ehaQ4RYsehD6fIKgLh+OKz52Vdr1zOFANAWNacCAIxgVgf+K2vqCfCGSZqx69VCv
X-Received: by 2002:a25:cfca:: with SMTP id f193mr21443227ybg.478.1558652052816;
        Thu, 23 May 2019 15:54:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558652052; cv=none;
        d=google.com; s=arc-20160816;
        b=cw1/PuoEQkdoOINjLve/dBkZwFQEcQEmEiPWHaAKLKNO1oCszi2UfLLtNi1fGc0epB
         F6rHt84TW8LYbQ/vUJQ0IM6pFLz4VKJqAdRabpJmZY4IgTom4v3Hf6TR8gXKx5VTkPzC
         q/9NaY+H9KfcKaXigu1lOBe/51013q0+QQuG/VZjhRPVtm7VBXl+siHVSSSnUMoEluLo
         7Pkwxsn6Wp0pKITZ0YlriGj4ysOYKs887CiqmsJK8nKmvfF0sOscE0BnoXr5BtftC7ZJ
         QrpVDBrsgdePth+CIp92uXtpOxJRBP4Y0FILh8web6WzJEu5CWFdgvE2xSQJNl8WCXRv
         kL6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=O/RiGmoYGRmC02sjlkIu6qvEn5MHd+ORmeaARAOsB+c=;
        b=GHY+2q5Lsk3KsOb6nl551ItwYDAS+wLdNIefEKd3w9Go+hyS1qAAOLKxd1WhLpIHrd
         jjWkPiu7anRCXEsY95Kwhl9hXIJk64iDAyNx++dIAc5HT8P7+xGs2T52RC7h7qL1c5dS
         41xd9fpKYATsKo5ZWMgU3Y7KGmtNaoKxU7NwzlmPFhzkx+bS/W+SWSjXWkU3u07R97iu
         AM5uPbsE3oP+QYDGkyGjpoXBHlRO5CEL8jWZhXtkPxyhUE+xh3+H2UBx/YMPJw2Qmsrd
         HWufCm5MEAwOHPk8bBxZNy+o5QfG3MCUTmRj1mwe2FCvZLR41pmAG/iHqcjVGjZU3WXM
         pyRQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hOjBNbxm;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id e76si223205yba.136.2019.05.23.15.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 May 2019 15:54:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=hOjBNbxm;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5ce7248f0000>; Thu, 23 May 2019 15:54:07 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 23 May 2019 15:54:11 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 23 May 2019 15:54:11 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 23 May
 2019 22:54:08 +0000
Subject: Re: [PATCH 1/1] infiniband/mm: convert put_page() to put_user_page*()
From: John Hubbard <jhubbard@nvidia.com>
To: Ira Weiny <ira.weiny@intel.com>
CC: Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
	<akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML
	<linux-kernel@vger.kernel.org>, "linux-rdma@vger.kernel.org"
	<linux-rdma@vger.kernel.org>, "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>, Doug Ledford <dledford@redhat.com>, "Mike
 Marciniszyn" <mike.marciniszyn@intel.com>, Dennis Dalessandro
	<dennis.dalessandro@intel.com>, Christian Benvenuti <benve@cisco.com>, "Jan
 Kara" <jack@suse.cz>
References: <20190523072537.31940-1-jhubbard@nvidia.com>
 <20190523072537.31940-2-jhubbard@nvidia.com>
 <20190523172852.GA27175@iweiny-DESK2.sc.intel.com>
 <20190523173222.GH12145@mellanox.com>
 <fa6d7d7c-13a3-0586-6384-768ebb7f0561@nvidia.com>
 <20190523190423.GA19578@iweiny-DESK2.sc.intel.com>
 <0bd9859f-8eb0-9148-6209-08ae42665626@nvidia.com>
 <20190523223701.GA15048@iweiny-DESK2.sc.intel.com>
 <050f56d0-1dda-036e-e508-3a7255ac7b59@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <6a18af65-7071-2531-d767-42ba74ad82c4@nvidia.com>
Date: Thu, 23 May 2019 15:54:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <050f56d0-1dda-036e-e508-3a7255ac7b59@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1558652047; bh=O/RiGmoYGRmC02sjlkIu6qvEn5MHd+ORmeaARAOsB+c=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=hOjBNbxmo0Oua+svsnfjV4ODR+jjb3kNvpchAZldU4CjYjIIRn76kDjdTnLmZWS/Q
	 rTepf8lEmxnjtuHNh6CwoqckUUQWi5NM6Bzy/QtAzpqAyI4rCnP1ihCjCufoUDn4JM
	 w87ysqq3taZlo9/bkfNVXF8tMnsv/6JwLwp1TY0us7ggJQu2tS1lCfzEbyHYapAsdm
	 82gMkvowgkra8cxbWzoj/m+QlJQl0G9muFCquiUNeV+GNpegaXHpUGgM+FPmV0ZeTD
	 1+bD8kWAHnGrJho7YtPlzT81sgio8SilaAgeKlDcYXGWeE+iv7CbDwd0LC5tHm3wwE
	 1xBP0KgrUEWtg==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/23/19 3:50 PM, John Hubbard wrote:
> [...] 
> I was thinking of it as a temporary measure, only up until, but not including the
> point where put_user_pages() becomes active. That is, the point when put_user_pages
> starts decrementing GUP_PIN_COUNTING_BIAS, instead of just forwarding to put_page().
> 
> (For other readers, that's this patch:
> 
>     "mm/gup: debug tracking of get_user_pages() references"
> 
> ...in https://github.com/johnhubbard/linux/tree/gup_dma_core )
> 

Arggh, correction, I meant this patch:

    "mm/gup: track gup-pinned pages"

...sorry for any confusion there.

thanks,
-- 
John Hubbard
NVIDIA

