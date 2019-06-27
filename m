Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42CDBC48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:35:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F193620659
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 15:35:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F193620659
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B5C76B0006; Thu, 27 Jun 2019 11:35:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 865898E0003; Thu, 27 Jun 2019 11:35:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77AEE8E0002; Thu, 27 Jun 2019 11:35:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0856B0006
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 11:35:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i44so6280813eda.3
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 08:35:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=6jxBP+iKalMuiz1S8ncMayXUZuReUQzPRBalKlw+MpI=;
        b=Acrr9x/hY5aOpkRMVOFhSK0hhMrYRQIaOnVznQNWLYNHTdJaJxtk6Q0zKyN6rBu/ni
         zRXyJsDNLuV5wVtIyUBPxcZBq/1CQKtxhUisV1FtExh+bSRKWaNMEkLe3NxNf2lIQKZa
         jCnOpWv9q92kA11z3hTK+ELqm7I54qRLV6Po8860YigZI268lZMMGpmKjWXMpI+6LyxR
         HnnAx7pHwzhf73CZyJPBVmBM0Y90a+eoFEHRQG2E0omn2KOVwMIcKvkzP2qf5ScYfaBf
         nm8rP4Wwl62SGr7nR4icsHd4iTqQWg4HbQHjHSosHu/6FWt8Gn5iHeaXGEXDJaZTVDJP
         PvVQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAXumA/KL18XYBtdSaapV0r173Z0beYWnw3F14R+VbYb0h5hfQah
	oFlQ0brQOKdY5ItXN9D3DgP41cM60eARMuM9Kr4zVjhUNIjh22Sb2NiXIaIoNirGbTfNXNwV7nA
	Z+OodaYakcxBwkfI9MhKGu+nVWmcX8DfjPZskzLqHnCEe8fywUgCN9L9iA6x4XHgaDQ==
X-Received: by 2002:a17:906:3497:: with SMTP id g23mr3881494ejb.70.1561649741741;
        Thu, 27 Jun 2019 08:35:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxZyDvvMORUejIHqZYhjYVsokhSFqBS3dQEYp02ByJ76Cdt7vCHUQ6lJ002XSvpVZaaPIZO
X-Received: by 2002:a17:906:3497:: with SMTP id g23mr3881404ejb.70.1561649740794;
        Thu, 27 Jun 2019 08:35:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561649740; cv=none;
        d=google.com; s=arc-20160816;
        b=g26SN95hia2gfv56lCd0uvmCjP4+tRAeu8ZFCU1MRPNP4jGmx2XXz4vA1xKsAeubTo
         wAqjZrMWXcDJau3jhxuSeL2DL/c/Lc1sM2yod7q30XbmBDxyKRWD3uRan0w1iPxF8Sdq
         vmAoINAxzW/FhCct7jfajnKAmOXpc+tlSomIh+e7fppiPb8GW3O4nHFe6FqTl9kOcgmN
         OqIhE98/o6CzL/ST7Tc8+DoPj7RAuY4lj17DSYqgPq6FQ4lG4h/GtQO1AAYRqhc3fuRu
         hEJAfn+mUeIzOegTuhw9P1zosB7dzYTCMgR/m1QX5V0wTpY290YgvoU9HDuuYADX/dJN
         XYfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=6jxBP+iKalMuiz1S8ncMayXUZuReUQzPRBalKlw+MpI=;
        b=HlDwclN5qM3SgqC6bp3yz9OzakcHS3JpofCiWYUjpFtW8xF7Pgy4sWHrCELKixYqqV
         ImKOEusQnBcth9damyknVi4zH9foBDmZ/YA0j8BedCiF63a1zumOsQPLVsvYa1vOynfx
         /EDfOUCE0NjD7UpAFoS+avoWv9ooo/8+ZPfduvWp6YvFU89DRmKrfGKk7lXwknpy/x0u
         bJkSmOIzCTP0ederf3c3xn+xcH4EPsityIYclqr7eKQnErWqu62tWxgJ9AfWVbjeY68c
         2wXR8QjuXypfnEt01dIBR4L4AlBiW1w0ZkrtsYP3zCGV58gmDhiIArh84G/i49SrGLnc
         2Ieg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d48si2255493eda.214.2019.06.27.08.35.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 08:35:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 50103ABC4;
	Thu, 27 Jun 2019 15:35:40 +0000 (UTC)
Subject: Re: [Xen-devel] [PATCH] mm: fix regression with deferred struct page
 init
To: xen-devel@lists.xenproject.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 pasha.tatashin@soleen.com, rppt@linux.ibm.com
References: <20190620160821.4210-1-jgross@suse.com>
 <79797c17-58d6-b09c-3aad-73e375a7f208@suse.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <a9b02905-8b4f-48ac-8638-8ff99bd3b0e6@suse.com>
Date: Thu, 27 Jun 2019 17:35:39 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <79797c17-58d6-b09c-3aad-73e375a7f208@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 10:25, Juergen Gross wrote:
> Gentle ping.
> 
> I'd really like to have that in 5.2 in order to avoid the regression
> introduced with 5.2-rc1.

Adding some maintainers directly...


Juergen

> 
> 
> Juergen
> 
> On 20.06.19 18:08, Juergen Gross wrote:
>> Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
>> instead of doing larger sections") is causing a regression on some
>> systems when the kernel is booted as Xen dom0.
>>
>> The system will just hang in early boot.
>>
>> Reason is an endless loop in get_page_from_freelist() in case the first
>> zone looked at has no free memory. deferred_grow_zone() is always
>> returning true due to the following code snipplet:
>>
>>    /* If the zone is empty somebody else may have cleared out the zone */
>>    if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
>>                                             first_deferred_pfn)) {
>>            pgdat->first_deferred_pfn = ULONG_MAX;
>>            pgdat_resize_unlock(pgdat, &flags);
>>            return true;
>>    }
>>
>> This in turn results in the loop as get_page_from_freelist() is
>> assuming forward progress can be made by doing some more struct page
>> initialization.
>>
>> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>> Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time 
>> instead of doing larger sections")
>> Suggested-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>> Signed-off-by: Juergen Gross <jgross@suse.com>
>> ---
>>   mm/page_alloc.c | 3 ++-
>>   1 file changed, 2 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d66bc8abe0af..8e3bc949ebcc 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1826,7 +1826,8 @@ deferred_grow_zone(struct zone *zone, unsigned 
>> int order)
>>                            first_deferred_pfn)) {
>>           pgdat->first_deferred_pfn = ULONG_MAX;
>>           pgdat_resize_unlock(pgdat, &flags);
>> -        return true;
>> +        /* Retry only once. */
>> +        return first_deferred_pfn != ULONG_MAX;
>>       }
>>       /*
>>
> 
> 
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xenproject.org
> https://lists.xenproject.org/mailman/listinfo/xen-devel

