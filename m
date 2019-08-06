Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 521C2C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:43:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04F062070D
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 20:43:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="ap4Gh4eA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04F062070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A6D9E6B0007; Tue,  6 Aug 2019 16:43:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1C806B0008; Tue,  6 Aug 2019 16:43:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 90C5D6B000A; Tue,  6 Aug 2019 16:43:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED7D6B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 16:43:45 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so56723183pfd.3
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 13:43:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=69F2w6W//D6RGOmiznV0xApH922IMQ0bjLWukK3Y3fM=;
        b=gM627ZpZinWzCazjCHzrlotIHoGmox6jEvcqF3PS3Tz6BQUZJPEPJCHejQVFCWoboP
         QVhBmYNL9Q38ZvoPsfYAoWWxaW66Akst7BgdvfHcs+RS41+GYTOVVBrcJlx2er6injr9
         vAbXb6lBkBkqdk7w1lYqsTzKCRLIR/HQwRmzNuRra0mHiv2DaOyHQvFVyeshiyXnLate
         KkIQimspx1wCwfU/g3NT540hYlHln91yhfQW7rWZgOnlTIB/0ZkzNZg3S2G72n6Ih8UB
         Mm+CZ5w+Nu1VJL/jBZk0NPKLrVrfQFKs7VQwnr0JrHeJbyyvJtiuvcMYAeCsFV30v9tK
         9IOg==
X-Gm-Message-State: APjAAAXwKlzrhrt6mCuCvdOvbE2Gg4CQ3QjZpg7bsLuzooKWXoVnx00e
	ssRPhhs/aecXCBtm0pBYA7oMilMMTqrcK/e9i65YokZIJAnF75urcuQ+yRJIf0rfGj+EeYKrWbJ
	hIghGNUrHcfm+HhUdEYjItIV2iXeQ7/BbGFK4c0CJV1mFGFxSXnNPRpGh695QynJQJw==
X-Received: by 2002:aa7:84d1:: with SMTP id x17mr5640008pfn.188.1565124224884;
        Tue, 06 Aug 2019 13:43:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwFHlnDzwG1G6hFHZ0SUV+SYkoRTFGFCnpPXNsxdamCk157yprcFfPnSbFOmmsMOjYCvAZS
X-Received: by 2002:aa7:84d1:: with SMTP id x17mr5639963pfn.188.1565124224107;
        Tue, 06 Aug 2019 13:43:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565124224; cv=none;
        d=google.com; s=arc-20160816;
        b=ncMxZGwqWgNbaptP0mS5bI3h2ki3KWEf7nz7iJVa8ej71Ot6Y6biiOeZmo+qOmFka5
         R2lUINvBqyvhVCSE99kw3m99URiYqe2T6mPRSuinICqnOyYXAVWs7I0g3F5bCTQhADUt
         x+dvnZa+kxIxHvFtMC8M7qu80JigAaea8jZRseZXMpmOqv0rq6Ozv91zYI+USUl1eTMu
         lE1olHumYa7AwYXHykCo092gpNGZThQj1ffPKmWI498WuMz4WFlBhobow6OF2DuuLae9
         cBwjYIu97Q3vRDRRHvOHhyZ2rRE3CKvy/2azVoJdymI3EfbbL0PhODu2cymQShZY6fzj
         9l6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=69F2w6W//D6RGOmiznV0xApH922IMQ0bjLWukK3Y3fM=;
        b=XIT1jD1WuupYGOaKpghRov1pLWQjSHSsYDD3n/H0qNOEX1KmEAKs+nsrjl4X9c3X9M
         008AKvbnrqT9R5Z4aB7RA2BNnaQheVQmaFdJ8qEKz/S44m2JU6UVzJ0KMbTjo7BrhZ5m
         ZHAjHXgKV1+nQ1hwymJ0BvVLnnNUnLeOY9miLF19dYWAnsK/ni16zPR06dKkDLNjCQGE
         9d9+E2oe6NwOWiJMbPAQ0/JwRpbBC8drxw0olPVn4k77bjErUQmw2TrRFdj2doFi5ysi
         Xg0VujhZi/dMA/G7rioJyyM6Ies2lZA7apeAqBWI8hrDZSsQ+MDPOElSep+47GxOu5o4
         YO6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ap4Gh4eA;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id y5si42985243plk.338.2019.08.06.13.43.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 13:43:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=ap4Gh4eA;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d49e6890000>; Tue, 06 Aug 2019 13:43:53 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 06 Aug 2019 13:43:43 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 06 Aug 2019 13:43:43 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 6 Aug
 2019 20:43:43 +0000
Subject: Re: [PATCH v6 1/3] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
To: Ira Weiny <ira.weiny@intel.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro
	<viro@zeniv.linux.org.uk>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?=
	<bjorn.topel@intel.com>, Boaz Harrosh <boaz@plexistor.com>, Christoph Hellwig
	<hch@lst.de>, Daniel Vetter <daniel@ffwll.ch>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, David Airlie
	<airlied@linux.ie>, "David S . Miller" <davem@davemloft.net>, Ilya Dryomov
	<idryomov@gmail.com>, Jan Kara <jack@suse.cz>, Jason Gunthorpe
	<jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Johannes Thumshirn
	<jthumshirn@suse.de>, Magnus Karlsson <magnus.karlsson@intel.com>, Matthew
 Wilcox <willy@infradead.org>, Miklos Szeredi <miklos@szeredi.hu>, Ming Lei
	<ming.lei@redhat.com>, Sage Weil <sage@redhat.com>, Santosh Shilimkar
	<santosh.shilimkar@oracle.com>, Yan Zheng <zyan@redhat.com>,
	<netdev@vger.kernel.org>, <dri-devel@lists.freedesktop.org>,
	<linux-mm@kvack.org>, <linux-rdma@vger.kernel.org>, <bpf@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
References: <20190804214042.4564-1-jhubbard@nvidia.com>
 <20190804214042.4564-2-jhubbard@nvidia.com>
 <20190806174017.GB4748@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <662e3f1e-b63e-ce80-274b-cb407bce6f78@nvidia.com>
Date: Tue, 6 Aug 2019 13:43:42 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190806174017.GB4748@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565124233; bh=69F2w6W//D6RGOmiznV0xApH922IMQ0bjLWukK3Y3fM=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=ap4Gh4eAjhabzOCGXg03MlGS3E39LbT2CXYDFUwj2rPlbF7hC6RWG9GhsJ2iB7VW/
	 iYlQoSLezyw7mHlxXl/fKIiZ8rXughCfKjTKN4/Z6IMCoXcHiVjqfWI1NEleGSaZ1D
	 nb/98DcL6LZnWfzY2lODnRbMeV4rL6NENctX00s/9WgBVnL9OMB/MDykHOE9G7K2wL
	 YOLJ7T/SYKJKGHtGsae2JANuXCcr7t7WsPen/yG+U/cLlENdGZ/NhUeRG2cxaPNVG0
	 iSR9G6EBnJbeu0s0AK9qSs5J/PxhKEARuOdUaS2rM7tLFwOLC4PrmECrXiOHXA9ve3
	 yBfnp2wxB5hBA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/6/19 10:40 AM, Ira Weiny wrote:
> On Sun, Aug 04, 2019 at 02:40:40PM -0700, john.hubbard@gmail.com wrote:
>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> Provide a more capable variation of put_user_pages_dirty_lock(),
>> and delete put_user_pages_dirty(). This is based on the
>> following:
>>
>> 1. Lots of call sites become simpler if a bool is passed
>> into put_user_page*(), instead of making the call site
>> choose which put_user_page*() variant to call.
>>
>> 2. Christoph Hellwig's observation that set_page_dirty_lock()
>> is usually correct, and set_page_dirty() is usually a
>> bug, or at least questionable, within a put_user_page*()
>> calling chain.
>>
>> This leads to the following API choices:
>>
>>     * put_user_pages_dirty_lock(page, npages, make_dirty)
>>
>>     * There is no put_user_pages_dirty(). You have to
>>       hand code that, in the rare case that it's
>>       required.
>>
>> Reviewed-by: Christoph Hellwig <hch@lst.de>
>> Cc: Matthew Wilcox <willy@infradead.org>
>> Cc: Jan Kara <jack@suse.cz>
>> Cc: Ira Weiny <ira.weiny@intel.com>
>> Cc: Jason Gunthorpe <jgg@ziepe.ca>
>> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> 
> I assume this is superseded by the patch in the large series?
> 

Actually, it's the other way around (there is a note that that effect
in the admittedly wall-of-text cover letter [1] in the 34-patch series.

However, I'm trying hard to ensure that it doesn't actually matter:

* Patch 1 in the latest of each patch series, is identical

* I'm reposting the two series together.

...and yes, it might have been better to merge the two patchsets, but
the smaller one is more reviewable. And as a result, Andrew has already
merged it into the akpm tree.


[1] https://lore.kernel.org/r/20190804224915.28669-1-jhubbard@nvidia.com

thanks,
-- 
John Hubbard
NVIDIA

