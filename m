Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5F3BC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:47:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 806DB206B7
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 14:47:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 806DB206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 236036B0008; Thu,  4 Apr 2019 10:47:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E7A66B000A; Thu,  4 Apr 2019 10:47:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0AD566B000C; Thu,  4 Apr 2019 10:47:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id D6D536B0008
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 10:47:48 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 75so2335316qki.13
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 07:47:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=EMWT8PdKLEkL9LuyPygUOuenVj0wbK68lOUlBM1tR8U=;
        b=U/zjSAmu5ExlYpuL1DC713rov8ji3yw8CTE0YYX+lUrtsS0h94B5OGoLazB9ujzOQ9
         SmPRz269BmaFXpF1bwE3IkmrlyKWPukwe8phTBGyD1ktDxc9V+njCKfMcwELGtcT26K7
         E0i01+EnXCjIpF04bGp8FWNSfni3lrrE9IJSzgOwWaZWP0S8GWqu5IAHkJ7sqHUEom4Y
         lgkl6m0dobOmz3FONN7bkkIdcXyrIZwKeZreYlppnBCIKbkAqYANYrgPhD+1pb6vCPza
         URZxCtRgeVpBNQKzsEKZnaP+k0zOR8WFDquLqLn+1IGSxbPPXpkdEpTih1rvB6HYuV+N
         blQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXNhIW+SZPTqECJwgGnZDL8mudZzQ1UfGk25msjDCLc8/l2bey1
	MnaFafLecM3s1/WCGMuK2D5eMk+UndR53/lFrARXzqEbYfNpuK1X1KE+qGuXJ2H7Fu7XdL3jlMl
	Ed6mF3R4fnNRG8G+KGK6mh8SoHxtKLFh5WP+5eOFxJwlei4Uvnbq52qmXJZ3HkSmcsQ==
X-Received: by 2002:aed:358b:: with SMTP id c11mr5757628qte.70.1554389268568;
        Thu, 04 Apr 2019 07:47:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwJdHRULx0WkWB4uGVLQxGMxWBWdTUXdsETaWUdMP7AjByIJMbDgTz3T/kNH+qnwPEr+y4S
X-Received: by 2002:aed:358b:: with SMTP id c11mr5757592qte.70.1554389267981;
        Thu, 04 Apr 2019 07:47:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554389267; cv=none;
        d=google.com; s=arc-20160816;
        b=XRFiq9EXrOSFU3z9Z4lOOaa2xFiQKWYNOxqzotJk9hM0YvWNbn3ndaBPZuWPoDXvbD
         XdxXApxyed5UFjhA3+daRkA/eVcNBjtx2U0ca8ShTaQY1nRYoGDD+s7xk53z+VI/YWhW
         EQ4StpeWY6hQU/MWy0B6dszcxCQA3VqeM/DEMXnvvBReslFCWLbiuZ3bPMzav2k2YZdS
         wLc28siE3kXH6A7h3fwkmsjrfKvdlxxeCjtqPnP0R+VwIr/N/0/j9x3goRdelwlunJ70
         pKPJIWLZQE0iMbYryukUYPXbDI++h1z8ZzH+SOPszAxEkEiVebTQDLJRJ9Hmz9nSQhlb
         0VZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=EMWT8PdKLEkL9LuyPygUOuenVj0wbK68lOUlBM1tR8U=;
        b=muNziUDnE9BF2PmxBxqhEKoLB48u0dhEZbZywXU8yY3JaFSSdhotbY18AitwafLPlB
         z70GASh7N/VDCcwhCAjiWewH/vQz6xupnju/r34hndVXR/OzsXE2CId4WNqKExDKKmZ+
         T/7dIDWaI4FZT/0eXatBrQJ6BJX1HdOTfytaJy6BQZXO3KUIoQZlWDtBn4lNIbjhiECD
         c7aqVeYZ5Y0YBXJkv2ctsF+FrS9y9TBQlvMaxA7kD305n5z52Vr/LyWZRPANpqkUlH+X
         2Tvtph5eEeyyZJNNCothZm4J61wu34BvOTGylophGcxeLQAkgeP+G19G83sUDE2v410Q
         uTlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c4si2503921qtp.398.2019.04.04.07.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 07:47:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 30A897D7A3;
	Thu,  4 Apr 2019 14:47:47 +0000 (UTC)
Received: from [10.36.117.116] (ovpn-117-116.ams2.redhat.com [10.36.117.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BE6878645A;
	Thu,  4 Apr 2019 14:47:44 +0000 (UTC)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: cleanup memory offline path
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-2-osalvador@suse.de>
 <f2360f11-4360-b678-f095-c4ebbf7cd0ec@redhat.com>
 <20190404132506.kaqzop4qs6m56plu@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <7874ef85-adc7-95a8-87f4-1f15eb21c677@redhat.com>
Date: Thu, 4 Apr 2019 16:47:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190404132506.kaqzop4qs6m56plu@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 04 Apr 2019 14:47:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.04.19 15:25, Oscar Salvador wrote:
> On Thu, Apr 04, 2019 at 03:18:00PM +0200, David Hildenbrand wrote:
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index f206b8b66af1..d8a3e9554aec 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1451,15 +1451,11 @@ static int
>>>  offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
>>>  			void *data)
>>>  {
>>> -	__offline_isolated_pages(start, start + nr_pages);
>>> -	return 0;
>>> -}
>>> +	unsigned long offlined_pages;
>>>  
>>> -static void
>>> -offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>> -{
>>> -	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
>>> -				offline_isolated_pages_cb);
>>> +	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
>>> +	*(unsigned long *)data += offlined_pages;
>>
>> unsigned long *offlined_pages = data;
>>
>> *offlined_pages += __offline_isolated_pages(start, start + nr_pages);
> 
> Yeah, more readable.
> 
>> Only nits
> 
> About the identation, I double checked the code and it looks fine to me.
> In [1] looks fine too, might be your mail client?
> 
> [1] https://patchwork.kernel.org/patch/10885571/

Double checked, alignment on the parameter on the new line is very weird.

And both lines cross 80 lines per line ... nit :)

> 
>>
>> Reviewed-by: David Hildenbrand <david@redhat.com>
> 
> Thanks ;-)
> 


-- 

Thanks,

David / dhildenb

