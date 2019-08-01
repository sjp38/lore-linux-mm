Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60559C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:01:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F3BD214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:01:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="BE/FS0Mg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F3BD214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7DD68E0005; Thu,  1 Aug 2019 03:01:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B54318E0001; Thu,  1 Aug 2019 03:01:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F6BA8E0005; Thu,  1 Aug 2019 03:01:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 754E58E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:01:50 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id p7so38832675otk.22
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:01:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=my/85jeGWSZJHtRlBuXzE4k0EyRLwJrmf2kurssg82c=;
        b=oUKvC/kqR3KZg/D+LWbI5C6h0wm28BMKuoFRqfLJu7VBy5dolCj7ILAEctDOQP3i6Y
         8meC4pe5nkK6Z/21UI2R5camgIAt1NSuHeQE0rFr519DZDd/r+oyjYx7hEGZpFx1KSvO
         0BerylhO965NnjZBC1ywMPM2sqxryifD5bS9oMD8yVBRxEZrOK3M8vzWOHAy4N6tNQTJ
         3kWFo3QjYW+TNaFqEKT06XhKjuBs4eAR3df7iUh7sGh0XSVbzKKyhdVdo14jzC6MqxJZ
         M8V1Yuq0PuAN+4bVu12yNlXlDyHVu3F8pVgYAQhb/YxuVjwCLlRtbfrGNhyNaBN7P4lJ
         u7dw==
X-Gm-Message-State: APjAAAVhVGJYBiVPsd/qkmOjfdR3oiJ0XzMEzlgycJvvkpsLcPQu3yPu
	11yHrIbcYQAeJAIY1FMgs92HHvUWgqmXBghFjPTAmdQNh0cveZekr5YY5HkJ5O3Ci/6gNg+n9Sv
	ZydDCyHdBu0g+k24YfT5HZmtLCteFnWyK4EnTeo32qr53MF0N84PqZD7STTIIQ8wO6A==
X-Received: by 2002:a9d:5d0b:: with SMTP id b11mr22245794oti.333.1564642910048;
        Thu, 01 Aug 2019 00:01:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwr/mqg4rV1LF9YRk6bGmCyyXNfxirABD/zRzj3hZTisAOglMsIZc+qeCL3cN1NcrijqF/f
X-Received: by 2002:a9d:5d0b:: with SMTP id b11mr22245743oti.333.1564642909241;
        Thu, 01 Aug 2019 00:01:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564642909; cv=none;
        d=google.com; s=arc-20160816;
        b=uprOGHdOot3jj+fIM0zloDShV9+kaqGO1TK+SQnLFvBFJpqeMUCDB9qH3u9vAkIRap
         ISf3DvchKO9ZSD6KkCrKQ3qHRjfEA7Vs7Wvq7pEAXIafyXPiAfSqudPC8kW6Y+nklcFK
         gVf+N8ZyDmbRluzyfLxXS2tDEGjuCeww7l21cZK7fKG3LsVCcGT/ZHVMHJM8nEN87mbm
         0jTJ1GujJ1IYgDmNbcsFi+V+X4cHaNL6llojyHuF3p5NGlOGLVkfFJSEzBt8r1jIqceA
         DM6R8tPswr9dvdb+xOUfd4hAkmY1H3I3+jgiZ2UawqlJZdmedC69IEDsj5OY256uATQJ
         Xu7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=my/85jeGWSZJHtRlBuXzE4k0EyRLwJrmf2kurssg82c=;
        b=AFkW2d0Gg27/7i14HSMMyFslHfn/0NEmeC6Wxmc3gaZSG+SV1RxyBkj2TOymKFwI5u
         6+eO4sDtYAfNnmnhUg5Pshoj7qXF7bUT9L94WPkzIkizce9sVFKHlG2bX11MWwE2rxjL
         XUQtFr9R0z+hEgwpiS3HNyJ6TIllEe0vYrWt+pYr7S0eduGgBP93QQ8T3Y4gzwimaAdO
         E2/U8lLI1hG50USECrx63kR5TBY83FAPXfVN7ZOpcXaPH/TBWxnB0IfiNlxB0ICUnx2G
         z1nVOd4XYa5qjxhLWmc59Jz79jmjvb8q4epUl3mgqdfevDu3dVRK17ja0PsWacy9M04A
         gXEw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="BE/FS0Mg";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id o24si34943475oic.75.2019.08.01.00.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:01:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b="BE/FS0Mg";
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d428e5c0000>; Thu, 01 Aug 2019 00:01:48 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 01 Aug 2019 00:01:47 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 01 Aug 2019 00:01:47 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 1 Aug
 2019 07:01:46 +0000
Subject: Re: [PATCH v4 1/3] mm/gup: add make_dirty arg to
 put_user_pages_dirty_lock()
To: Christoph Hellwig <hch@lst.de>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Dan Williams <dan.j.williams@intel.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>, Dave Chinner
	<david@fromorbit.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jens Axboe <axboe@kernel.dk>,
	Jerome Glisse <jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill@shutemov.name>, Matthew Wilcox <willy@infradead.org>, Michal Hocko
	<mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Mike
 Rapoport <rppt@linux.ibm.com>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>,
	<linux-xfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
References: <20190730205705.9018-1-jhubbard@nvidia.com>
 <20190730205705.9018-2-jhubbard@nvidia.com> <20190801060755.GA14893@lst.de>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <36713a8a-ac94-8af7-bedf-a3da6c6132a7@nvidia.com>
Date: Thu, 1 Aug 2019 00:01:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190801060755.GA14893@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1564642908; bh=my/85jeGWSZJHtRlBuXzE4k0EyRLwJrmf2kurssg82c=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=BE/FS0MgD5AYk51ouyHNs4X8FqW/AlJFw51Q8R1TRI2GD6IOdn/1tc0f8d17PnQuR
	 0Z29vU6LNM4vLOhRI1ICsnxx9CJbaK67B4+P50dZEZC3TKrxh+CbRgPy1II2gJN1Ox
	 sgjPcluxAyQuF8zD1tmNbaF3orKKsCLf8LGjBkZ2Dd6uk8L1cJZx0sa6gjml9A/pvl
	 l8lHfekfgfuMtiHYmcIuX2d5w4E0873CGNZaTN60cvh/hpRl524bvtSwNb0l1RblrJ
	 aYJKWtVExKSnCUM8qF6X0x0Cyxcn7j9MhMPGq1/IrqL8k30zP0Fu0rWtpPEmGYGs7S
	 JL5/+DN+tFZeQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/19 11:07 PM, Christoph Hellwig wrote:
> On Tue, Jul 30, 2019 at 01:57:03PM -0700, john.hubbard@gmail.com wrote:
>> @@ -40,10 +40,7 @@
>>  static void __qib_release_user_pages(struct page **p, size_t num_pages,
>>  				     int dirty)
>>  {
>> -	if (dirty)
>> -		put_user_pages_dirty_lock(p, num_pages);
>> -	else
>> -		put_user_pages(p, num_pages);
>> +	put_user_pages_dirty_lock(p, num_pages, dirty);
>>  }
> 
> __qib_release_user_pages should be removed now as a direct call to
> put_user_pages_dirty_lock is a lot more clear.

OK.

> 
>> index 0b0237d41613..62e6ffa9ad78 100644
>> --- a/drivers/infiniband/hw/usnic/usnic_uiom.c
>> +++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
>> @@ -75,10 +75,7 @@ static void usnic_uiom_put_pages(struct list_head *chunk_list, int dirty)
>>  		for_each_sg(chunk->page_list, sg, chunk->nents, i) {
>>  			page = sg_page(sg);
>>  			pa = sg_phys(sg);
>> -			if (dirty)
>> -				put_user_pages_dirty_lock(&page, 1);
>> -			else
>> -				put_user_page(page);
>> +			put_user_pages_dirty_lock(&page, 1, dirty);
>>  			usnic_dbg("pa: %pa\n", &pa);
> 
> There is a pre-existing bug here, as this needs to use the sg_page
> iterator.  Probably worth throwing in a fix into your series while you
> are at it.

The amount of scatterlist code I've written is approximately zero lines,
+/- a few lines. :)  I thought for_each_sg() *was* the sg_page iterator...

I'll be glad to post a fix, but I'm not yet actually spotting the bug! heh

> 
>> @@ -63,15 +63,7 @@ struct siw_mem *siw_mem_id2obj(struct siw_device *sdev, int stag_index)
>>  static void siw_free_plist(struct siw_page_chunk *chunk, int num_pages,
>>  			   bool dirty)
>>  {
>> -	struct page **p = chunk->plist;
>> -
>> -	while (num_pages--) {
>> -		if (!PageDirty(*p) && dirty)
>> -			put_user_pages_dirty_lock(p, 1);
>> -		else
>> -			put_user_page(*p);
>> -		p++;
>> -	}
>> +	put_user_pages_dirty_lock(chunk->plist, num_pages, dirty);
> 
> siw_free_plist should just go away now.

OK, yes.

> 
> Otherwise this looks good to me.
> 

Great, I'll make the above changes and post an updated series with your
Reviewed-by, and Bjorn's ACK for patch #3.

Next: I've just finished sweeping through a bunch of patches and applying this
where applicable, so now that this API seems acceptable, I'll post another
chunk of put_user_page*() conversions.

thanks,
-- 
John Hubbard
NVIDIA

