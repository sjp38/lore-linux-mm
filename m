Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 496E4C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:18:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0347F2184E
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 11:18:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0347F2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94FBE6B0006; Thu, 11 Apr 2019 07:18:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FD596B0007; Thu, 11 Apr 2019 07:18:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79D586B000E; Thu, 11 Apr 2019 07:18:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5833A6B0006
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 07:18:12 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id b188so4734609qkg.15
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 04:18:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=DQ4/beaH8wIyCSuOMZ4yMjKXXLy4HKl6p1piAOFjM3I=;
        b=Wn2BCqfk3ZyReIWWxZ0eBUXM8Nw/ZESAWg/5rovLRtyyU4XW/GCbFNjljyit7RaCLx
         l8I3YqaPHo5Wnu0h31t2ySEfDGfUXCWbC9oDq8QGLSSb0p79Zja23bmtNXhb/61wYGoJ
         7Sm9xHtp4KzNw0jJkB77BEVMOwAwlJsrB2ArrxF/YPGLli9tZXsZi7D1GhWTWDC1it9Q
         DRrMcURLqJWNttauJkIyxtrpMQxVZUoYCXgJbVx9aycPG4ieO+XIyCR+m5DttcFjRd0K
         NuOwK/BcEoJMKTiy2ywNzINZpjy/w+zgMvDRIBERuacRt/daWwzZTMJbpKhmLZfxNaNP
         rsTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXtj7dXI4AqGZaYZB6qyA2CzXlo2cZ11ivonNijbHh6n1jO63iC
	HD36aKnUrSHp+p39MVORVUPzzXSKlTj04j25kGh/p0HVg9XFHv8xUMT42Kvmrs+iyw4Vfo3EMJO
	rIw7w5BfNYR9wsbMDOzHrnq2YONd9wqkNmy+mZ/Qe2skFXTpOmouDskYCpz5s+abt5A==
X-Received: by 2002:a0c:b0a5:: with SMTP id o34mr39396988qvc.42.1554981492109;
        Thu, 11 Apr 2019 04:18:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyK3wquz4MhL0W1ntoxp0qI7FOGxgk5N2q2/Bxb23QwQauxJbzAxC1fRmwkfTLv/t9o45VB
X-Received: by 2002:a0c:b0a5:: with SMTP id o34mr39396952qvc.42.1554981491435;
        Thu, 11 Apr 2019 04:18:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554981491; cv=none;
        d=google.com; s=arc-20160816;
        b=ZSDv0YoSAWRlbRsQA3KYHrJJ2nU/VdSq+Joytw3SecwLp1H9z0xIxEVuYK0BJ9VMA2
         P+qmTrc9Av1mMSmU2yM4PB3cn4DI543wLAZrq3/K1FqNJvmRhB2KoMTMLoqBuvheuKLJ
         +O6WD6ufSNEOhbxZJtkf4uP54vzm8qqzwKDrPeJJyDEUObSr2UR4UVJ7YKWWslaQdDuN
         UYEwnhbOcS+cbFK6ggBA2EMMdU1hnVb9R+zPmyBPjVUvsi5GghCCMNkn+9hhWT8FtaLe
         YAss0JWidSyxjOOVyH6EXzFmBEa/RD5Urszjb0GMYYYd7LulbbLGLAfG+G2G+9xx4tw6
         FqKg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=DQ4/beaH8wIyCSuOMZ4yMjKXXLy4HKl6p1piAOFjM3I=;
        b=ebiRm513k3yhR01B/odJWocsaI1m8fmsSokMeMoikvj2W6SQafp+GWSqRvXEB1d5Rt
         N7QiVkuo1NDxVKNh4VZ5G7IrEC5y5dLHoaD6DTu3nH4LW/1en1jFolpEEUUn6zvqtcTH
         jfuPoAKaFJlexba9rTVAdWvcPR2J/BPsAjX7smLPOBmcca+vvPjpSaaIOTzyIJ8/cR8t
         pqcR8t34/dBVTS2xACawHAmeDQ5CYpvK5LOg/HYSmPC1vWWiRiwXrHiwIn9b135VTFNN
         ZEJPTNUagpac7zr737j+Q5LM+Dw/ZhhlJctsLUckPlTTjBPzjm3gJ1x4DthFpBxHdwiT
         +PxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r17si2411903qte.289.2019.04.11.04.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Apr 2019 04:18:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9C65137E7B;
	Thu, 11 Apr 2019 11:18:10 +0000 (UTC)
Received: from [10.36.118.43] (unknown [10.36.118.43])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9DE4E60BF7;
	Thu, 11 Apr 2019 11:18:08 +0000 (UTC)
Subject: Re: [PATCH] mm/memory_hotplug: Drop memory device reference after
 find_memory_block()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador
 <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richard.weiyang@gmail.com>, Qian Cai <cai@lca.pw>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190410101455.17338-1-david@redhat.com>
 <20190411084141.GQ10383@dhcp22.suse.cz>
 <0bbe632f-cb85-4a98-0c79-ded11cf39081@redhat.com>
 <20190411105617.GS10383@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <711db571-ee39-eb64-4551-baaa5b562579@redhat.com>
Date: Thu, 11 Apr 2019 13:18:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190411105617.GS10383@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Thu, 11 Apr 2019 11:18:10 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.04.19 12:56, Michal Hocko wrote:
> On Thu 11-04-19 11:11:05, David Hildenbrand wrote:
>> On 11.04.19 10:41, Michal Hocko wrote:
>>> On Wed 10-04-19 12:14:55, David Hildenbrand wrote:
>>>> While current node handling is probably terribly broken for memory block
>>>> devices that span several nodes (only possible when added during boot,
>>>> and something like that should be blocked completely), properly put the
>>>> device reference we obtained via find_memory_block() to get the nid.
>>>
>>> The changelog could see some improvements I believe. (Half) stating
>>> broken status of multinode memblock is not really useful without a wider
>>> context so I would simply remove it. More to the point, it would be much
>>> better to actually describe the actual problem and the user visible
>>> effect.
>>>
>>> "
>>> d0dc12e86b31 ("mm/memory_hotplug: optimize memory hotplug") has started
>>> using find_memory_block to get a nodeid for the beginnig of the onlined
>>> pfn range. The commit has missed that the memblock contains a reference
>>> counted object and a missing put_device will leak the kobject behind
>>> which ADD THE USER VISIBLE EFFECT HERE.
>>> "
>>
>> I don't think mentioning the commit a second time is really needed.
>>
>> "
>> Right now we are using find_memory_block() to get the node id for the
>> pfn range to online. We are missing to drop a reference to the memory
>> block device. While the device still gets unregistered via
>> device_unregister(), resulting in no user visible problem, the device is
>> never released via device_release(), resulting in a memory leak. Fix
>> that by properly using a put_device().
>> "
> 
> OK, sounds good to me. I was not sure about all the sysfs machinery
> and the kobj dependencies but if there are no sysfs files leaking and
> crashing upon a later access then a leak of a small amount of memory
> that is not user controlable then this is not super urgent.
> 
> Thanks!

I think it can be triggered by onlining/offlining memory in a loop. But
as you said, only leaks of small amount of memory.

Thanks!

-- 

Thanks,

David / dhildenb

