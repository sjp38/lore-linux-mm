Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 67D0EC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:57:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1EC8B206C3
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 23:57:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="PkoJ+EDW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1EC8B206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F3DB6B0003; Thu,  8 Aug 2019 19:57:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 97D3B6B0006; Thu,  8 Aug 2019 19:57:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81E756B0007; Thu,  8 Aug 2019 19:57:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 495D76B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 19:57:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id m19so44156632pgv.7
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 16:57:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ItTlcxLB3OzkqKxPiAlZSVxn8wLR/CcyzAXny5jY54w=;
        b=fzvLV1C4pcfwd+XdNQWSLN42Ue0JXP/ba8oUdfFj+iQ8UTnFhXaerNkt64uky/xpC3
         S5T7ep7DP4F90Ajm7sDASc1pAqvalBGJ0Rw9Phf8egyFpq1+ZeWPNw1Vw4Gd23m0nMQZ
         OIBqq6qqHjYOroVOSby0u8V7IXzzimrG4BX7utNo/sNIlcY7hLw4v7LpQiRcha2B8j1O
         J/AGbvGIuEOK1xDShtLC7eATQOXKvlkRjckYUkzaF4O73FwkXAosRIt5oSMtvaOTLOSH
         GM4hdlLkwWJyuquEQphvXpV95Xo7fvpiNxgsyEAFNSEfkHMUHT5DUzG4yCnn/TTdFhwK
         Z7/Q==
X-Gm-Message-State: APjAAAWcEwF448E+oXcO5I1Wst/ymeN6A9M+Eqt/kNOS1OAIWILSlhRC
	Ah8RVuwARe2LseXmAaddHeQdeHYB3T4oHy8k2rAZsnpkcUc/r1lK1+B3N99abfNTeij334teOO7
	JeRc0UdsD6XZ+O7ZEk4n/rrnGu4HUt7M3sQmzfwCwLW46b1ercC2iv41/sSgJeoqb2w==
X-Received: by 2002:a17:902:8bc1:: with SMTP id r1mr16312295plo.42.1565308673912;
        Thu, 08 Aug 2019 16:57:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCcmY4qXXgbMio4vpCzs+Pi3xtjrJsdtFTP8i5Ulq9FcTc4GrUKQXkx6A03vEKKidWLr5+
X-Received: by 2002:a17:902:8bc1:: with SMTP id r1mr16312247plo.42.1565308673097;
        Thu, 08 Aug 2019 16:57:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565308673; cv=none;
        d=google.com; s=arc-20160816;
        b=gpa2dcYFd709jR/mqvNn2WOXIduMyCAUEJlECT4zLvkUvAdjkeexDYIhFDr/g6IZv5
         hPVHznG0kmLcqV4qFxekETr1S0xCNMq8MCAj6+cgsN3DUoz30nwDVQst3noEyO8Cq15m
         TfIId2fTv0OvIyNsBAh8KUguTSWJiHV87CorR30H5ZGKp8wCtzoorHjLn7j8FmgtFj42
         2n7erDFoNTPRosPheBAJumf8WtMBaiQb2SZM5GX5wIG+t/GSRUqLnRpORk7Mum3iJ6oU
         RmnXikCuu9vaihcmnmfL9WkcnV2mrlbTKDGMlrroP5NBQ614Q7TOx0h11xfcdnbl9HfP
         nZDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=ItTlcxLB3OzkqKxPiAlZSVxn8wLR/CcyzAXny5jY54w=;
        b=P/K74Nah+flZvcBvTmsEKngP1KB3ltppkSnAdl4Y9VatQnmvZofLQCa0HGE2VKZff5
         D04zKrlW6nIF+hL9tJACQE7H368akpIOQBFpj8P6Bx8va7+m2kgQhR09ngLyC5LCn6qf
         lxiQHfrCEntiwott6e9k7cY2J6P4FN31riGExEAzmbJz3wDbZgg1tAfKqoXS9TRnOXa7
         SVAA3kywMpR0w6IcYIL5xh0+fHSrgQasTfmGvfPbIA6rvug7VfdlAANB4XAADR8SQuKx
         2WYiL4+kaBVTSwhLE25HlXTCYuL2DMraswVJ8vpj5HFvITe0mqbrdSGH6ZRL80ChDitz
         kONg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PkoJ+EDW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id l64si2950254pjb.93.2019.08.08.16.57.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 16:57:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=PkoJ+EDW;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4cb7020002>; Thu, 08 Aug 2019 16:57:54 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 16:57:52 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 08 Aug 2019 16:57:52 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 8 Aug
 2019 23:57:51 +0000
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
To: Ira Weiny <ira.weiny@intel.com>
CC: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew
 Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>, Dan Williams
	<dan.j.williams@intel.com>, Daniel Black <daniel@linux.ibm.com>, Matthew
 Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
 <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
 <20190808234138.GA15908@iweiny-DESK2.sc.intel.com>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <5713cc2b-b41c-142a-eb52-f5cda999eca7@nvidia.com>
Date: Thu, 8 Aug 2019 16:57:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190808234138.GA15908@iweiny-DESK2.sc.intel.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565308674; bh=ItTlcxLB3OzkqKxPiAlZSVxn8wLR/CcyzAXny5jY54w=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=PkoJ+EDWEq2PAabC2cPHA1oueE3YrcKkjoul5TR4Oa1yBcvabjT4+f41IFrkiWh2Z
	 FMyHHF6xQc3T1CBt7cg1mqsbQ5mtIYUvCL++2XyzG8RuqfLyjoQpj11SZummKWRV/z
	 XcR8S/Kdg4cmuC0ro638QgTio3qAJoA8sC+XAHtJqsH4Fibn2aZezpl+ol7b0a9c+o
	 xLyC3/U6MxfnBH6duwZ/owBk7ytCphS6oa+2DMO396CuXm3w0FiJGsC3pHOVlWcHg1
	 DD1wz2Shd4QjyoRYu/PDeBzxX/9Nf0jaSgifEpzmFnz+2z5iIqzhtWVw9mrQDdUu35
	 f0aIucgjoeWKw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 4:41 PM, Ira Weiny wrote:
> On Thu, Aug 08, 2019 at 03:59:15PM -0700, John Hubbard wrote:
>> On 8/8/19 12:20 PM, John Hubbard wrote:
>>> On 8/8/19 4:09 AM, Vlastimil Babka wrote:
>>>> On 8/8/19 8:21 AM, Michal Hocko wrote:
>>>>> On Wed 07-08-19 16:32:08, John Hubbard wrote:
>>>>>> On 8/7/19 4:01 AM, Michal Hocko wrote:
>>>>>>> On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
...
>> Oh, and meanwhile, I'm leaning toward a cheap fix: just use gup_fast() instead
>> of get_page(), and also fix the releasing code. So this incremental patch, on
>> top of the existing one, should do it:
>>
>> diff --git a/mm/mlock.c b/mm/mlock.c
>> index b980e6270e8a..2ea272c6fee3 100644
>> --- a/mm/mlock.c
>> +++ b/mm/mlock.c
>> @@ -318,18 +318,14 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
>>                 /*
>>                  * We won't be munlocking this page in the next phase
>>                  * but we still need to release the follow_page_mask()
>> -                * pin. We cannot do it under lru_lock however. If it's
>> -                * the last pin, __page_cache_release() would deadlock.
>> +                * pin.
>>                  */
>> -               pagevec_add(&pvec_putback, pvec->pages[i]);
>> +               put_user_page(pages[i]);

correction, make that:   
                   put_user_page(pvec->pages[i]);

(This is not fully tested yet.)

>>                 pvec->pages[i] = NULL;
>>         }
>>         __mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
>>         spin_unlock_irq(&zone->zone_pgdat->lru_lock);
>>  
>> -       /* Now we can release pins of pages that we are not munlocking */
>> -       pagevec_release(&pvec_putback);
>> -
> 
> I'm not an expert but this skips a call to lru_add_drain().  Is that ok?

Yes: unless I'm missing something, there is no reason to go through lru_add_drain
in this case. These are gup'd pages that are not going to get any further
processing.

> 
>>         /* Phase 2: page munlock */
>>         for (i = 0; i < nr; i++) {
>>                 struct page *page = pvec->pages[i];
>> @@ -394,6 +390,8 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>>         start += PAGE_SIZE;
>>         while (start < end) {
>>                 struct page *page = NULL;
>> +               int ret;
>> +
>>                 pte++;
>>                 if (pte_present(*pte))
>>                         page = vm_normal_page(vma, start, *pte);
>> @@ -411,7 +409,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
>>                 if (PageTransCompound(page))
>>                         break;
>>  
>> -               get_page(page);
>> +               /*
>> +                * Use get_user_pages_fast(), instead of get_page() so that the
>> +                * releasing code can unconditionally call put_user_page().
>> +                */
>> +               ret = get_user_pages_fast(start, 1, 0, &page);
>> +               if (ret != 1)
>> +                       break;
> 
> I like the idea of making this a get/put pair but I'm feeling uneasy about how
> this is really supposed to work.
> 
> For sure the GUP/PUP was supposed to be separate from [get|put]_page.
> 

Actually, they both take references on the page. And it is absolutely OK to call
them both on the same page.

But anyway, we're not mixing them up here. If you follow the code paths, either 
gup or follow_page_mask() is used, and then put_user_page() releases. 

So...you haven't actually pointed to a bug here, right? :)


thanks,
-- 
John Hubbard
NVIDIA

