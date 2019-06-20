Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 706D9C48BE3
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:20:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B02120675
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 15:20:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B02120675
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CCE088E0003; Thu, 20 Jun 2019 11:20:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7CDE8E0001; Thu, 20 Jun 2019 11:20:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B45178E0003; Thu, 20 Jun 2019 11:20:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6605B8E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 11:20:12 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so4748665eda.3
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 08:20:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=/hJ2tIeaoXzl+5jHO9KjUkmR0lsFl8lKMVzEl2/1hqg=;
        b=ahwIFnjL+EBFLTqfi9RC+leCYvk8b6CO4BDSLhbKiuWcRR/g5q/Yms5GoW112HktFC
         p4s2+nD3d1+KxqaAZ5O3optpaGXrzzBxwmKiCp9qIagf9vE5f7HngKoA6gAO28VjQZ/m
         1FzHCSWx/ambkw8xtLsotiZ9zqlyCrINJT/7xv8dbH30ZXY1CtOXEwFcAt8b1cLKKXcI
         ALhLBiNWr5sSSuyNzkoTpX+1Mmja+WJxWoFMzsbh0ioVre7hMtu5MN3UkQUHmUbRi/bC
         0HPs1y9fSDF3YFaX8H5UBSeZ2/nThc3Lxx3x88Ph7wuhdb5/g2dJUDVcR9CCvytcNhuE
         IREw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAVlk4G+zClMde4k84+4veac99hgW2VQ5zedPv8CCUqd0YoFw3Z0
	Vvp12eyAGcXLFoOJpKKTazjoR9ZRy72OVgEZjEpMpHbWNbrjoTQNCwoDmoK1og1fQN2Pc4Nap4e
	TJK5Ak81UGagoRndCNpmKQNnkyWJKucHK9lBwFXjpPGnoTlMSSFNccTzKoJR42QSSjA==
X-Received: by 2002:aa7:c2c8:: with SMTP id m8mr53541370edp.63.1561044011983;
        Thu, 20 Jun 2019 08:20:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCJj0E5LrCb13MNCvuY/f4IqvJJO3cRLSkcboBw4SPPpT6r9l2CkPgtYJ8t//EbOHX4xkl
X-Received: by 2002:aa7:c2c8:: with SMTP id m8mr53541272edp.63.1561044011141;
        Thu, 20 Jun 2019 08:20:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561044011; cv=none;
        d=google.com; s=arc-20160816;
        b=OQKzgghYfN3Urjuu8sLCmHCZL6eM/Hmr6b0+r2xOskVBtLP5d3+fPHhCVDoaNybF91
         C0iHkuS4pG3QWaTI4+hgwGnvuh3ooe0ac88lJ4cZGVjU9a0JhktX7FgGXq5vUbqxduZr
         umTGHjDS6DyEQo5Fo4pDxY0DuljuYGVxiP6xl/wJNRF8R07BD5r4Z0T3a8q8adwa8Ht2
         nIB7m9mKUv32eZTNoAkNOUYnj2k8hQWmm8SOsQIY+vyOQhVAOjZTdTajdubZQZukyLPk
         I5KthtGJWEUk/4T2QdJPiX6JC+IVWKBfGkUtdNANecuJHZHaJ4gB2ZfPW905ssfPJSwz
         p9lw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:to:subject;
        bh=/hJ2tIeaoXzl+5jHO9KjUkmR0lsFl8lKMVzEl2/1hqg=;
        b=eRad3EfaVcoUmu0RF8vIHpsu10bLI+E/L/3E6047TYralBZ8qjkxQdZB361SH4PcIn
         Inkf5cjGinmaT4gpGfG5ukzC2F0WZgQqdi8e0pSC9tGjeQsfLTGPa8KujwVUMUeKukbc
         jk5qr3qUkWUKNzqx9/3aNPdpmJ6dKoXVRLsZcxLRQmKriV4S3VVrSXBW+UxCEv3r0KEy
         72Y9V/XIYH8tvweTJUsw1ej5z1XTefnS0D5ECC30yWDkFAv+jnYCaEh0p8h9ls8m4fSw
         NDQP3hBhctOwKPaDnnBcDlV5fH0b25uWE2FXXvr/dX/Dp1hY3qlEK07oYl1Ms/NTQZ0x
         zHdg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w12si12989750ejn.86.2019.06.20.08.20.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 08:20:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 1D804AE46;
	Thu, 20 Jun 2019 15:20:10 +0000 (UTC)
Subject: Re: [PATCH RFC] mm: fix regression with deferred struct page init
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 xen-devel@lists.xenproject.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190620094015.21206-1-jgross@suse.com>
 <d11cf6a9ac9f2f21b6102464bf80925ada02bc78.camel@linux.intel.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <0fae5789-3859-d49f-6c4c-2bde09dc3307@suse.com>
Date: Thu, 20 Jun 2019 17:20:09 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <d11cf6a9ac9f2f21b6102464bf80925ada02bc78.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 20.06.19 17:17, Alexander Duyck wrote:
> On Thu, 2019-06-20 at 11:40 +0200, Juergen Gross wrote:
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
>>    /* If the zone is empty somebody else may have cleared out the zone */
>>    if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
>>                                             first_deferred_pfn)) {
>>            pgdat->first_deferred_pfn = ULONG_MAX;
>>            pgdat_resize_unlock(pgdat, &flags);
>>            return true;
>>    }
>>
>> This in turn results in the loop as get_page_from_freelist() is
>> assuming forward progress can be made by doing some more struct page
>> initialization.
>>
>> Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
>> ---
>> This patch makes my system boot again as Xen dom0, but I'm not really
>> sure it is the correct way to do it, hence the RFC.
>> Signed-off-by: Juergen Gross <jgross@suse.com>
>> ---
>>   mm/page_alloc.c | 2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index d66bc8abe0af..6ee754b5cd92 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -1826,7 +1826,7 @@ deferred_grow_zone(struct zone *zone, unsigned int order)
>>   						 first_deferred_pfn)) {
>>   		pgdat->first_deferred_pfn = ULONG_MAX;
>>   		pgdat_resize_unlock(pgdat, &flags);
>> -		return true;
>> +		return false;
>>   	}
>>   
>>   	/*
> 
> The one change I might make to this would be to do:
> 	return first_deferred_pfn != ULONG_MAX;
> 
> That way in the event the previous caller did free up the last of the
> pages and empty the zone just before we got here then we will try one more
> time. Otherwise if it was already done before we got here we exit.

Thanks for the constructive feedback!

Will send a non-RFC variant soon.


Juergen

