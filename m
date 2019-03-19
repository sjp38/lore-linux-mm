Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ADA3C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:01:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DF512075C
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 20:01:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="oN2BBuMk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DF512075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5BF06B0005; Tue, 19 Mar 2019 16:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A34876B0006; Tue, 19 Mar 2019 16:01:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FD416B0007; Tue, 19 Mar 2019 16:01:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4C15E6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 16:01:04 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id i13so170412pgb.14
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 13:01:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=HSpyNkpOUN54LoSVErAzdS1E1kZB+HgZS0Abyi+9vjU=;
        b=Cg/mUjhFpE/C0FOHyonRCQrcQtkjy5P798Sut1zlXkt9TuPlTiPQjk6VW+k0QA6HjS
         SHao19EZ97sNvDeQvqvltvQALqnw7Vgl8G1+gNCJ9oZxeI/ThuxsZIDHCe2nJxDbYiPw
         2fMnSHSsc1T+eY8Hu3AettGrGBSwjqWCbqQlTIgH8AVgWcolq1JQZ7ykOM9VamIT8iyJ
         GH0Cy8hezccvCerFZo40ZMLiyJpNcW1u4YD1RVDrIkA/R0SJJo1mhJWDP+JUJTyGj8rF
         QyD2h/WyvPJv0VT2XJ1DIbUVOxWTPuzGQfZbzRgcUDgSCndmULQy12kQTNDCe3+usUcY
         Iuaw==
X-Gm-Message-State: APjAAAWTddAnOdprl1C7AxQjxQ2XhzFKyfLPIYRybeES0W42qu00hy6R
	K0FsJtwiyHyQcpdmTEr6YGhIVZdvkvVUfmrWS1yYWsvp8apbJuHX18pUCI3ez0kAumasY+3K3bG
	SzJz3FOJhhEIQTejgRy6/lGOcajMmEie4SXk643I2/qh+eQWR2FOAcNQodQ3baQP2Zw==
X-Received: by 2002:a62:3107:: with SMTP id x7mr4059513pfx.191.1553025663824;
        Tue, 19 Mar 2019 13:01:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCYdxgld2sRfAsOarx6DdASOSsRnWQGGJZexH3OHAT1cvRTySOLdxkANKVDdbY4PK6UHMF
X-Received: by 2002:a62:3107:: with SMTP id x7mr4059427pfx.191.1553025662736;
        Tue, 19 Mar 2019 13:01:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553025662; cv=none;
        d=google.com; s=arc-20160816;
        b=ga8+aEpfzK5nqpzhl9KofZJ6eadZXuYVyLmSOm1zdVG+82gyew38+2Tel0oYrGYOW7
         XiLFg+fxqvY95QOdA9BqnqvensM2O15PwCnJKX/1ew73Z4Z+s3p4C708ZpO+FVt4cfOV
         GmlKmz2OARda7yULyJy5ha5qw4wMV05po0VZCnh/kp8XYJDlmjMb/BFeP2dBalcCFHFa
         OOwwKr3IVOquvQ6VF4n8znGrB/s/xJFRiiVTpnFSf6vr7ZLCSVAr+uUMmJVzKaCsVOUv
         np+rPcEDrJExubRyIoWVgPSLt2bLxZYluZjdiVj9THPdPhdzMMwq/jKHXGPXkwddeDDv
         WvQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=HSpyNkpOUN54LoSVErAzdS1E1kZB+HgZS0Abyi+9vjU=;
        b=dtcS11eJ+8YbPmnxqY3BRCsOwOMOshKNlM+/+Ni9pq058sx3R4KDSuaPYtTj8l9sFt
         ru9SiXcv5CT0MS7FYmIQ25scC7kAddSECn1OEeFVr62iE0Rtae5siMKTBo54TYPs8gPU
         F2yuGiARWhCJFZt+lPK5swKn6MgqaNuva9YhXJG3adv7Lqx3tyt1qcvnNhvG4br4pEAM
         Bf/ZHUirH8wbjOVdM4Mb/c2ERxTuKhEa2xpnfO7NlZzmUi9SMVOiZ1NgKBp7OLov93U+
         CIsGeGErUwZIq/9LQP8+hfBsy0sjwVXn3cxzmFTQWiPFuaqXzMGIpRSSaKMN1lXgnoPb
         G8kg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=oN2BBuMk;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id 39si12748004pla.214.2019.03.19.13.01.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 13:01:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=oN2BBuMk;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c914a6f0000>; Tue, 19 Mar 2019 13:00:47 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Tue, 19 Mar 2019 13:01:02 -0700
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Tue, 19 Mar 2019 13:01:02 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Tue, 19 Mar
 2019 20:01:01 +0000
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Glisse
	<jglisse@redhat.com>
CC: <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>,
	<linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Christian Benvenuti
	<benve@cisco.com>, Christoph Hellwig <hch@infradead.org>, Christopher Lameter
	<cl@linux.com>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner
	<david@fromorbit.com>, Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319140623.tblqyb4dcjabjn3o@kshutemo-mobl1>
From: John Hubbard <jhubbard@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <6aa32cca-d97a-a3e5-b998-c67d0a6cc52a@nvidia.com>
Date: Tue, 19 Mar 2019 13:01:01 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190319140623.tblqyb4dcjabjn3o@kshutemo-mobl1>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL106.nvidia.com (172.18.146.12) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1553025647; bh=HSpyNkpOUN54LoSVErAzdS1E1kZB+HgZS0Abyi+9vjU=;
	h=X-PGP-Universal:Subject:To:CC:References:From:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=oN2BBuMkNCIXH77NHOjjmKZpQZ9GitLjMPLc2DOfX/7d7jvPcisxSIGFy4WGrRix3
	 M3o1wPgnNpS7wLfDpqv8vDHGdBJ3Jgn1qYOZS8VUalLX+wIMtxCPpfyltItaQMwleQ
	 ptCwtHyq3H4alTuMTew3Bm37SkGH4we0MK4ZFg1q8mY4s1ytDbJUzflFw/PvaCvQwq
	 +B7R0o7qjiUzOFIzZZudvjtnmC/Slf7qFeUYuCzuzGH7oTU8Xg2R7E4cNe9H4Yfb1R
	 MfGwkr7LIvwWCXBzRD2lXqk+JnXl5TLWnKHpaDRyxW9PQF+tUQJXrDQ44VAS1NWP5B
	 8cEOAcfT606Ag==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/19/19 7:06 AM, Kirill A. Shutemov wrote:
> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
>> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
>>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
>>>> From: John Hubbard <jhubbard@nvidia.com>
>>
>> [...]
>>
>>>> diff --git a/mm/gup.c b/mm/gup.c
>>>> index f84e22685aaa..37085b8163b1 100644
>>>> --- a/mm/gup.c
>>>> +++ b/mm/gup.c
>>>> @@ -28,6 +28,88 @@ struct follow_page_context {
>>>>  	unsigned int page_mask;
>>>>  };
>>>>  
>>>> +typedef int (*set_dirty_func_t)(struct page *page);
>>>> +
>>>> +static void __put_user_pages_dirty(struct page **pages,
>>>> +				   unsigned long npages,
>>>> +				   set_dirty_func_t sdf)
>>>> +{
>>>> +	unsigned long index;
>>>> +
>>>> +	for (index = 0; index < npages; index++) {
>>>> +		struct page *page = compound_head(pages[index]);
>>>> +
>>>> +		if (!PageDirty(page))
>>>> +			sdf(page);
>>>
>>> How is this safe? What prevents the page to be cleared under you?
>>>
>>> If it's safe to race clear_page_dirty*() it has to be stated explicitly
>>> with a reason why. It's not very clear to me as it is.
>>
>> The PageDirty() optimization above is fine to race with clear the
>> page flag as it means it is racing after a page_mkclean() and the
>> GUP user is done with the page so page is about to be write back
>> ie if (!PageDirty(page)) see the page as dirty and skip the sdf()
>> call while a split second after TestClearPageDirty() happens then
>> it means the racing clear is about to write back the page so all
>> is fine (the page was dirty and it is being clear for write back).
>>
>> If it does call the sdf() while racing with write back then we
>> just redirtied the page just like clear_page_dirty_for_io() would
>> do if page_mkclean() failed so nothing harmful will come of that
>> neither. Page stays dirty despite write back it just means that
>> the page might be write back twice in a row.
> 
> Fair enough. Should we get it into a comment here?

How's this read to you? I reworded and slightly expanded Jerome's 
description:

diff --git a/mm/gup.c b/mm/gup.c
index d1df7b8ba973..86397ae23922 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -61,6 +61,24 @@ static void __put_user_pages_dirty(struct page **pages,
        for (index = 0; index < npages; index++) {
                struct page *page = compound_head(pages[index]);
 
+               /*
+                * Checking PageDirty at this point may race with
+                * clear_page_dirty_for_io(), but that's OK. Two key cases:
+                *
+                * 1) This code sees the page as already dirty, so it skips
+                * the call to sdf(). That could happen because
+                * clear_page_dirty_for_io() called page_mkclean(),
+                * followed by set_page_dirty(). However, now the page is
+                * going to get written back, which meets the original
+                * intention of setting it dirty, so all is well:
+                * clear_page_dirty_for_io() goes on to call
+                * TestClearPageDirty(), and write the page back.
+                *
+                * 2) This code sees the page as clean, so it calls sdf().
+                * The page stays dirty, despite being written back, so it
+                * gets written back again in the next writeback cycle.
+                * This is harmless.
+                */
                if (!PageDirty(page))
                        sdf(page);

> 
>>>> +void put_user_pages(struct page **pages, unsigned long npages)
>>>> +{
>>>> +	unsigned long index;
>>>> +
>>>> +	for (index = 0; index < npages; index++)
>>>> +		put_user_page(pages[index]);
>>>
>>> I believe there's an room for improvement for compound pages.
>>>
>>> If there's multiple consequential pages in the array that belong to the
>>> same compound page we can get away with a single atomic operation to
>>> handle them all.
>>
>> Yes maybe just add a comment with that for now and leave this kind of
>> optimization to latter ?
> 
> Sounds good to me.
> 

Here's a comment for that:

@@ -127,6 +145,11 @@ void put_user_pages(struct page **pages, unsigned long npages)
 {
        unsigned long index;
 
+       /*
+        * TODO: this can be optimized for huge pages: if a series of pages is
+        * physically contiguous and part of the same compound page, then a
+        * single operation to the head page should suffice.
+        */
        for (index = 0; index < npages; index++)
                put_user_page(pages[index]);
 }


thanks,
-- 
John Hubbard
NVIDIA

