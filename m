Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5C51BC32751
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:12:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DCB2214C6
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 22:12:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="bnxLQDCy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DCB2214C6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A18FD6B000A; Mon,  5 Aug 2019 18:12:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C9B56B000C; Mon,  5 Aug 2019 18:12:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DFC36B000D; Mon,  5 Aug 2019 18:12:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E0176B000A
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 18:12:45 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id d2so47072579pla.18
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 15:12:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=LkAiUo1s42CQYX53EPRAoniYSqypvtE8JhgF1ACTWJI=;
        b=JiWVDJXDrDkYcVhTQ3SIe472oBzmFWk7Oz513xhChRaK3e8fck9hxIJG8pvINj9wd4
         MBYet2u2ii1whB/FIifLlnST4Cy14ZClmjsze9fKNrtqoaQHL8JKtxlBBjyIdul4iNZO
         IwHAH9iGYX8H2azFwpx6AHJazGz0KyxRXA9chNJ/liwINFFyDxsnQ359uEWVxgblwvb4
         7UI1GZes7iiNC3kmBV5UTmAJf2cmJcqOwjmoixeCJdKm1X2n4nXxwI/sBHeARmsi6c9J
         lx1cHpfWU3u6yIQ2f6v8o6wKN7GFfLpRVm84QJXluAnos4x9Li6Fd/5kpI61Ljpb9SLk
         DPqw==
X-Gm-Message-State: APjAAAU7rocc7Ma9wFrk3xsE8tZMGU9+CyBBeLhPB+O6Srl3ygfvRCnb
	4ZrxYMrV0zKoGvDAnl/sESSvkQymXm13XMqz8Qjm5Ckk71k3aqAWpbX5wh1h3JQQVUx81HTs7VJ
	MT7OzBsewpY7AZdPHqRAIEr68VqXiy5oWDKCqlgK3USO4+uCnGtPwylpZ1txn8G9ZnQ==
X-Received: by 2002:a63:9249:: with SMTP id s9mr97092pgn.356.1565043164755;
        Mon, 05 Aug 2019 15:12:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyVDDsZQ5E81eU2hvUVQPZ6cbVpxlUoIipEOG/eRTdVBmIYngfnASmmGzFlTH7T5bHpSmAV
X-Received: by 2002:a63:9249:: with SMTP id s9mr97040pgn.356.1565043163895;
        Mon, 05 Aug 2019 15:12:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565043163; cv=none;
        d=google.com; s=arc-20160816;
        b=gUdhALcw9O7j92Xrd/1+ogkyzFoGYN5U056MKpEWlybme9mKjezHbPEItAoAz9ecI1
         YWyZ1CzO4Wq9UcDmnq/UAErMDD9tEAgvbYcof0DuymEXjv5LRX1xhR1yBkIPQmRhVfnA
         IFAN2/BFcIpGk2aa3zmf2XG7TT0ZH/+kYAXXr7evS/3QwGKpr2WFgSdj9ujXZqd8EZh1
         eu7cZ4tB9D9CynJr+v280lLt86lWKv0jpGMIb45iGZgA8/rrMsDThC0KeasRrdiEUCzl
         qzZjyduetKyUhsstwkpfv07QXj7xGsHq0zwkFjVvyVI3CHrPb13Du5AGYb7/1JgTJBdd
         nrtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=LkAiUo1s42CQYX53EPRAoniYSqypvtE8JhgF1ACTWJI=;
        b=nAlna8kg/yRJXpODPYl4GLYghZ1l1bv/FGoOD9Ssrqnbij4bGk/pHIR7QKk6RBNI8G
         v0obnQNGCpamQGW8n+PwEIwnyymXKEwZ5BDs0oClJ3LY0ph0hBvKO9wIHuQ2RfFg8BTu
         WaTsLYTLrh1zOF4QQCaReb7oLSBmGNlDYahhCzhZGpLsh2ciSaLerS4g53HqOmGe29IG
         9RUBQyGzUMsLF8Aw2mdfI5qtIZAr0R6eDzuIFhW9vmM1+au2oqgm0VfS9V7oXOD24DOr
         SusBnM2x1ixJSmKC9avgAOP8FaC4QO1adCt79wrgdO6hXqU621zHqi6KOCfbMd32kzt0
         oCbw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bnxLQDCy;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d31si43285059pla.393.2019.08.05.15.12.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 15:12:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=bnxLQDCy;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d48a9e50000>; Mon, 05 Aug 2019 15:12:53 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Mon, 05 Aug 2019 15:12:43 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Mon, 05 Aug 2019 15:12:43 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Mon, 5 Aug
 2019 22:12:42 +0000
Subject: Re: [PATCH] fs/io_uring.c: convert put_page() to put_user_page*()
To: Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Jerome Glisse <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>,
	<linux-block@vger.kernel.org>
References: <20190805023206.8831-1-jhubbard@nvidia.com>
 <20190805220441.GA23416@iweiny-DESK2.sc.intel.com>
 <20190805220547.GB23416@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <dddaaf48-ce33-bdf4-86cb-47101d15eb6c@nvidia.com>
Date: Mon, 5 Aug 2019 15:12:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190805220547.GB23416@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565043173; bh=LkAiUo1s42CQYX53EPRAoniYSqypvtE8JhgF1ACTWJI=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=bnxLQDCyTODHWtH8f0QtXRcjnq5ZXER2WiGKW2qcCasfwe2n/ifRFjrKGHdyPOppn
	 UvjQryp87QwL1sEmtQkKSxJDk/DZbvhqo+mDHQVATQ9bBcoKnLRVQZiK9wAKkQ0DdD
	 Vs8tjYGY4h6UomzREoaPHuLbgC1/FrH1JcqhpCHDAF0gBBzIrmrClfnBUsOwA0/j9u
	 PsvNWbbA7QRj75rUXOs05jEZLR3w7rJ4pZ8TDwjzAXpDSY7XDp7GNz9t5A3GCeDz0C
	 mK1bTIxkCObFVZpc/YzRFWLAFY8D44N5xtlkq8ihB9nG04UOs+yqRWzkLpjzL4j7XF
	 R+Vw9vNjJ4jPw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 3:05 PM, Ira Weiny wrote:
> On Mon, Aug 05, 2019 at 03:04:42PM -0700, 'Ira Weiny' wrote:
>> On Sun, Aug 04, 2019 at 07:32:06PM -0700, john.hubbard@gmail.com wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
>>>
>>> For pages that were retained via get_user_pages*(), release those pages
>>> via the new put_user_page*() routines, instead of via put_page() or
>>> release_pages().
>>>
>>> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
>>> ("mm: introduce put_user_page*(), placeholder versions").
>>>
>>> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
>>> Cc: Jens Axboe <axboe@kernel.dk>
>>> Cc: linux-fsdevel@vger.kernel.org
>>> Cc: linux-block@vger.kernel.org
>>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>>
>> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> 
> <sigh>
> 
> I meant to say I wrote the same patch ...  For this one...
> 
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
> 

Hi Ira,

Say, in case you or anyone else is up for it: there are still about 
two thirds of the 34 patches that could use a reviewed-by, in this series:

   https://lore.kernel.org/r/20190804224915.28669-1-jhubbard@nvidia.com

...and even reviewing one or two quick ones would help--no need to look at
all of them, especially if several people each look at a few.

Also note that I'm keeping the gup_dma_core branch tracking the latest
linux.git, and it seems to be working pretty well, aside from one warning
that I haven't yet figured out (as per the latest commit):

    git@github.com:johnhubbard/linux.git
   

thanks,
-- 
John Hubbard
NVIDIA

