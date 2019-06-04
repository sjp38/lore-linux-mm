Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4830C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 19:38:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79FE72075B
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 19:38:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FXoMc9du"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79FE72075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F008C6B0274; Tue,  4 Jun 2019 15:38:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB27E6B0276; Tue,  4 Jun 2019 15:38:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA0296B0277; Tue,  4 Jun 2019 15:38:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBE896B0274
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 15:38:04 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id v5so2145720ybq.17
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 12:38:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=lIhxOsA9OCHLVcsFXFBTh63vXKqw/oUiHBUnBqTQTXA=;
        b=EmiaAvIWV9y1YeQm/O31q5XSm+pUTt7pGA4aMDkIlAH3a7Tdf+Dg7VwMQ/M35zFLMZ
         G3LNKg5rti+5/hVepQ1w6wxsTSLBgf0xUOjPRSsWggoL9PX4nKp9CuCPsrGkY7H27ocy
         QtFQnNjmsKddHmUOHNZXJvv6MSymJ1Ff3q6V1rbB51vHmT9OmRPnzodzoHT5QYzIXTB9
         RAOu+bOwJsixAaTe8mQpOQTIvao+AWV8dgqbKfgRUuJOP1fEgOO+I8g9k/xSsFcvKeZL
         zCLGMhQybk9Dy1dQuwZnyNzfV73ssOdxgo8GShPD96mrow95za7VFD+613LNrYoXyxeA
         whWw==
X-Gm-Message-State: APjAAAVc+u/QwXTYm3cQLYD/fCfIdKKzSvI+Lk/s5USe0tTK1iyyZeLP
	Rm7VRKnyY66dpvLptgUliSkKL2VgDqWvBnDyIqeHE7a3zWQpA9dT9dD+0XjYBWEG8mcMSFwYzCE
	cb8uUK1goEacq7rqujrwnEWCdONtzYDIhA1wUKxas6gD5hi0EWdvpChTy1Kx0ZNXZZA==
X-Received: by 2002:a0d:d489:: with SMTP id w131mr17687575ywd.182.1559677084513;
        Tue, 04 Jun 2019 12:38:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgpwUJBTtUN5w9RSmdTQONMZizoygkmfa8Z4nYaIzLNdmjIR6dkpeR8RZ1ixKQWaOP/Unk
X-Received: by 2002:a0d:d489:: with SMTP id w131mr17687552ywd.182.1559677083817;
        Tue, 04 Jun 2019 12:38:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559677083; cv=none;
        d=google.com; s=arc-20160816;
        b=BVLKC148K2xtnh7sJySH6g/AnNRj80P5D3b39yYJYlLt9uiaDHBviQtj97imNSO0XB
         bveP66naJzN42dDIEbw30iftdHk6kQYcXAH9499PjyxxyEfvGxiVIhyFBbUaMhf3HFzy
         FETUBeT2QRjTiEL3sKl4zY+lIRlWytopeq+T05nkLhF38L5dfwrNsn/KFcS8N78zEDcM
         +rUyDoaL9RFJqR0CCCttWsW4R6WwK2xn70+v/FkKFkZKjiMnRDb1Rd0cjWCoCPy4LReo
         xqYxR+Qa8WKnJNCNR3glQ0qcC9yAUCd8eRxGjBfINJGEXVKxS1jfV9UwSytxOu84o7tq
         Rk6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=lIhxOsA9OCHLVcsFXFBTh63vXKqw/oUiHBUnBqTQTXA=;
        b=PZ6ZvzJ7SqaUTAeCbi6LwsqVMIwewIb87sGnyAZ0oC6gvAa3Sw1dnjKkzm0n0LsmXu
         YFuj212O+oF23JlFO9xaZ5PYG8ronWaKW6akwlKjZEM4V77YaPZLRpcO4hYtAUkxmymq
         rxg291UJTAqxm7HBFTjfVGfeFlkYJrZcQP+K+jSnZHp3PAQRdvUnn4PqA4gTk/HfvOCx
         ugOxoWhcC2aZIU0QInX79p0BMm/4d/QFS6T+lMAZL3/+olyHZDAnQel+T3LrDbuTuvM6
         aBufHWaLMbsFSswIL4wZuaVirLC2umD5nETtOxt/rtTcwV8Cm7OYz9tc6Vkvijkfv+kw
         h+vw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FXoMc9du;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 14si5486349ybf.402.2019.06.04.12.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 12:38:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FXoMc9du;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5cf6c88d0000>; Tue, 04 Jun 2019 12:37:49 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 04 Jun 2019 12:38:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 04 Jun 2019 12:38:02 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 4 Jun
 2019 19:38:02 +0000
Subject: Re: [PATCHv2 1/2] mm/gup: fix omission of check on FOLL_LONGTERM in
 get_user_pages_fast()
To: Ira Weiny <ira.weiny@intel.com>, Christoph Hellwig <hch@infradead.org>
CC: Pingfan Liu <kernelfans@gmail.com>, <linux-mm@kvack.org>, Andrew Morton
	<akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.ibm.com>, Dan Williams
	<dan.j.williams@intel.com>, Matthew Wilcox <willy@infradead.org>, Aneesh
 Kumar K.V <aneesh.kumar@linux.ibm.com>, Keith Busch <keith.busch@intel.com>,
	<linux-kernel@vger.kernel.org>
References: <1559543653-13185-1-git-send-email-kernelfans@gmail.com>
 <20190603164206.GB29719@infradead.org>
 <20190603235610.GB29018@iweiny-DESK2.sc.intel.com>
 <20190604070808.GA28858@infradead.org>
 <20190604165533.GA3980@iweiny-DESK2.sc.intel.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ca72278a-e9b8-65de-29be-0fe194069172@nvidia.com>
Date: Tue, 4 Jun 2019 12:38:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190604165533.GA3980@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1559677069; bh=lIhxOsA9OCHLVcsFXFBTh63vXKqw/oUiHBUnBqTQTXA=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=FXoMc9dukyinG2w2j6LgNDON/dcWawP8WF6kN06Mt/GMuCzrpvC2YJ0uCN1OCeE5L
	 QIch35Q5uHWL1NgN9iPZBZMdTyGNGebrWNWopsgBCaDHPfIkHlqULpi0kq/RearpDB
	 b5Q1G/d4cTMi+a5wDrVzpaAWLH08HMk1+r5fMQajaKPJOIS28paAvNuUQc/MQprc0i
	 TukcfTSZTltBtJxuXPG1lbt1VunG2qk4hyAnOZOB26xC6dZzuEc0VqBTgSF8A5CX10
	 77sY1bwc2HndVFLJkqNFl3PkJejPUNLMcFzjyyjvibqXB6ivb8mLJ3ju5ZULYqj+sN
	 mWoPuSX3a2I3Q==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/4/19 9:55 AM, Ira Weiny wrote:
> On Tue, Jun 04, 2019 at 12:08:08AM -0700, Christoph Hellwig wrote:
>> On Mon, Jun 03, 2019 at 04:56:10PM -0700, Ira Weiny wrote:
>>> On Mon, Jun 03, 2019 at 09:42:06AM -0700, Christoph Hellwig wrote:
>>>>> +#if defined(CONFIG_CMA)
>>>>
>>>> You can just use #ifdef here.
>>>>
>>>>> +static inline int reject_cma_pages(int nr_pinned, unsigned int gup_flags,
>>>>> +	struct page **pages)
>>>>
>>>> Please use two instead of one tab to indent the continuing line of
>>>> a function declaration.
>>>>
>>>>> +{
>>>>> +	if (unlikely(gup_flags & FOLL_LONGTERM)) {
>>>>
>>>> IMHO it would be a little nicer if we could move this into the caller.
>>>
>>> FWIW we already had this discussion and thought it better to put this here.
>>>
>>> https://lkml.org/lkml/2019/5/30/1565
>>
>> I don't see any discussion like this.  FYI, this is what I mean,
>> code might be easier than words:
> 
> Indeed that is more clear.  My apologies.
> 
> Ira
> 
>>
>>
>> diff --git a/mm/gup.c b/mm/gup.c
>> index ddde097cf9e4..62d770b18e2c 100644
>> --- a/mm/gup.c
>> +++ b/mm/gup.c
>> @@ -2197,6 +2197,27 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
>>  	return ret;
>>  }
>>  
>> +#ifdef CONFIG_CMA
>> +static int reject_cma_pages(struct page **pages, int nr_pinned)
>> +{
>> +	int i = 0;
>> +
>> +	for (i = 0; i < nr_pinned; i++)
>> +		if (is_migrate_cma_page(pages[i])) {
>> +			put_user_pages(pages + i, nr_pinned - i);
>> +			return i;
>> +		}
>> +	}
>> +
>> +	return nr_pinned;
>> +}
>> +#else
>> +static inline int reject_cma_pages(struct page **pages, int nr_pinned)
>> +{
>> +	return nr_pinned;
>> +}
>> +#endif /* CONFIG_CMA */
>> +
>>  /**
>>   * get_user_pages_fast() - pin user pages in memory
>>   * @start:	starting user address
>> @@ -2237,6 +2258,9 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>>  		ret = nr;
>>  	}
>>  
>> +	if (nr && unlikely(gup_flags & FOLL_LONGTERM))
>> +		nr = reject_cma_pages(pages, nr);
>> +

Yes, now I see what you meant, and agree that that is cleaner.

thanks,
-- 
John Hubbard
NVIDIA

>>  	if (nr < nr_pages) {
>>  		/* Try to get the remaining pages with get_user_pages */
>>  		start += nr << PAGE_SHIFT;
>>

