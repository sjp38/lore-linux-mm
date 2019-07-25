Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C173DC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:04:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 745D7218D4
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 10:04:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 745D7218D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E63628E005F; Thu, 25 Jul 2019 06:04:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E14828E0059; Thu, 25 Jul 2019 06:04:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDC1F8E005F; Thu, 25 Jul 2019 06:04:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAF708E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 06:04:12 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id o11so35479996qtq.10
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:04:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ma1SxNQM6EWnnmwl1C/BOICMsv3Ucba+C9kfEp78Aq8=;
        b=gIj4mxF3GfwhuxUqW0LVZxWIkII+hSMNTcUsyqElEJlw1MXo9PHESgiSQrgeV+5+LF
         lWl/O1xucEN0svQScHfiS0eKramETdOcnZzY4LOmTZRITuUb1xjneEfIjCSuHOhWCWKC
         QmGkGNI36snIjS2shbMaARxm6SeqCZxK2w6zTLygKaoGQrQXOF/lPn7Y8hWvUmOOpZQK
         EWUzT3rHzjjsRTep5d1TObS+vdhgIv4gzXn7upHPUmiznIF/aeA+q2/KPredw2dvPlLQ
         wbxyNaQaOWdIQsGn6voXKhAXdoyQbO8jw5RkuIKphGzGsbA7pn786Gz2hPxb0gpICX+p
         aQAQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVXfzX7rrx1tzFum8QJH7hWHhHuTm/38FqJ4glbtqBvpB447Ork
	AL9EWa1B4L50d7X7+52lnWxwib9EMqLMRZrPuWcBBS2AM2SgMXH40Rqhbn8ZLeBN4Flalfu8YNh
	oCrrlk9+gmSkxFPDlep46toniwXCfrxU1vBum2m0qBFmdLOM/EAxwVOCq+ZmLUMbCDA==
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr56877832qkl.333.1564049052442;
        Thu, 25 Jul 2019 03:04:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd2Y7npMwhZvt2w+lCxpO+dvGAGRTLyP4C3ovWucxccAfCLEL3HRV9TzaTRnHXVwPK6Rgo
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr56877778qkl.333.1564049051799;
        Thu, 25 Jul 2019 03:04:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564049051; cv=none;
        d=google.com; s=arc-20160816;
        b=UmRxry4SfZ70Q0xEqh1CRReS8vzhyqamDv5vV9ryVOtofW5131d6F5cye+NbuTynhe
         xKRbPdnowjOpTNSSr0WJpD57+3zFgFjq3EyjLGAuCfQOgr8quMOT1q8JSb1sWFSOxtZN
         yNbGAsf+vRLMHHeWsWj+druDibQWk8EnXjc20fLX7AQj4bmgcygM1QWJ4JCGz/oLsNjU
         8rBNgk3oq3QoHpR5oH18gud8xxCpIyZNS2c45JwOd8BTNSw9FzxsI7gN4Ro9HarnBJ2q
         LQeXJ8HMuJHlxtNBB2hEaY7lR0s+ApaE2rYySFAt/tXqWTm1Wzxsbfmz87kSDlOZbx+g
         eHyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ma1SxNQM6EWnnmwl1C/BOICMsv3Ucba+C9kfEp78Aq8=;
        b=ADv/VbIuUKJj8Cmx0MCP9mdQBYnLbQh2S/B1Z1ZMClhVKW3CFuf6XDmHetAKO825ZJ
         i8OL4UBItGYA4EwXlLY/KY5yFLKPnVSsOdMyh98TbF6VtWnJpp/IUTSZw+1UTL9WG5Mk
         eHSwJZ1aw+LNHI+6scdrUPp7meKWnIA31GuCnfQ9YbHnasJG69Wp51rIsAMn5m4pRKD+
         zfkXcvUHBGrJDTFnZDBjIlRhK6vYYturh4fbq/Odap8ioO975OjgtqZxyUNdBsYmYdeO
         YanIIxaLlaYmJdlVIbADzdYVbhihae0XMOgc6EMYyD1VsSdLcC3x9Pc5cTetxSRuUrzA
         8OOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r129si29085877qkd.73.2019.07.25.03.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 03:04:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F16C885543;
	Thu, 25 Jul 2019 10:04:10 +0000 (UTC)
Received: from [10.36.117.212] (ovpn-117-212.ams2.redhat.com [10.36.117.212])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E463410027BE;
	Thu, 25 Jul 2019 10:04:08 +0000 (UTC)
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
To: Oscar Salvador <osalvador@suse.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-3-osalvador@suse.de>
 <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
 <20190725092751.GA15964@linux>
 <71a30086-b093-48a4-389f-7e407898718f@redhat.com>
 <20190725094030.GA16069@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6410dd7d-bc9c-1ca2-6cb7-d51b059be388@redhat.com>
Date: Thu, 25 Jul 2019 12:04:08 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725094030.GA16069@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 25 Jul 2019 10:04:11 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 11:40, Oscar Salvador wrote:
> On Thu, Jul 25, 2019 at 11:30:23AM +0200, David Hildenbrand wrote:
>> On 25.07.19 11:27, Oscar Salvador wrote:
>>> On Wed, Jul 24, 2019 at 01:11:52PM -0700, Dan Williams wrote:
>>>> On Tue, Jun 25, 2019 at 12:53 AM Oscar Salvador <osalvador@suse.de> wrote:
>>>>>
>>>>> This patch introduces MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK flags,
>>>>> and prepares the callers that add memory to take a "flags" parameter.
>>>>> This "flags" parameter will be evaluated later on in Patch#3
>>>>> to init mhp_restrictions struct.
>>>>>
>>>>> The callers are:
>>>>>
>>>>> add_memory
>>>>> __add_memory
>>>>> add_memory_resource
>>>>>
>>>>> Unfortunately, we do not have a single entry point to add memory, as depending
>>>>> on the requisites of the caller, they want to hook up in different places,
>>>>> (e.g: Xen reserve_additional_memory()), so we have to spread the parameter
>>>>> in the three callers.
>>>>>
>>>>> The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and only differ
>>>>> in the way they allocate vmemmap pages within the memory blocks.
>>>>>
>>>>> MHP_MEMMAP_MEMBLOCK:
>>>>>         - With this flag, we will allocate vmemmap pages in each memory block.
>>>>>           This means that if we hot-add a range that spans multiple memory blocks,
>>>>>           we will use the beginning of each memory block for the vmemmap pages.
>>>>>           This strategy is good for cases where the caller wants the flexiblity
>>>>>           to hot-remove memory in a different granularity than when it was added.
>>>>>
>>>>>           E.g:
>>>>>                 We allocate a range (x,y], that spans 3 memory blocks, and given
>>>>>                 memory block size = 128MB.
>>>>>                 [memblock#0  ]
>>>>>                 [0 - 511 pfns      ] - vmemmaps for section#0
>>>>>                 [512 - 32767 pfns  ] - normal memory
>>>>>
>>>>>                 [memblock#1 ]
>>>>>                 [32768 - 33279 pfns] - vmemmaps for section#1
>>>>>                 [33280 - 65535 pfns] - normal memory
>>>>>
>>>>>                 [memblock#2 ]
>>>>>                 [65536 - 66047 pfns] - vmemmap for section#2
>>>>>                 [66048 - 98304 pfns] - normal memory
>>>>>
>>>>> MHP_MEMMAP_DEVICE:
>>>>>         - With this flag, we will store all vmemmap pages at the beginning of
>>>>>           hot-added memory.
>>>>>
>>>>>           E.g:
>>>>>                 We allocate a range (x,y], that spans 3 memory blocks, and given
>>>>>                 memory block size = 128MB.
>>>>>                 [memblock #0 ]
>>>>>                 [0 - 1533 pfns    ] - vmemmap for section#{0-2}
>>>>>                 [1534 - 98304 pfns] - normal memory
>>>>>
>>>>> When using larger memory blocks (1GB or 2GB), the principle is the same.
>>>>>
>>>>> Of course, MHP_MEMMAP_DEVICE is nicer when it comes to have a large contigous
>>>>> area, while MHP_MEMMAP_MEMBLOCK allows us to have flexibility when removing the
>>>>> memory.
>>>>
>>>> Concept and patch looks good to me, but I don't quite like the
>>>> proliferation of the _DEVICE naming, in theory it need not necessarily
>>>> be ZONE_DEVICE that is the only user of that flag. I also think it
>>>> might be useful to assign a flag for the default 'allocate from RAM'
>>>> case, just so the code is explicit. So, how about:
>>>
>>> Well, MHP_MEMMAP_DEVICE is not tied to ZONE_DEVICE.
>>> MHP_MEMMAP_DEVICE was chosen to make a difference between:
>>>
>>>  * allocate memmap pages for the whole memory-device
>>>  * allocate memmap pages on each memoryblock that this memory-device spans
>>
>> I agree that DEVICE is misleading here, you are assuming a one-to-one
>> mapping between a device and add_memory(). You are actually taliing
>> about "allocate a single chunk of mmap pages for the whole memory range
>> that is added - which could consist of multiple memory blocks".
> 
> Well, I could not come up with a better name.
> 
> MHP_MEMMAP_ALL?
> MHP_MEMMAP_WHOLE?

As I said somewhere already (as far as I recall), one mode would be
sufficient. If you want per memblock, add the memory in memblock
granularity.

So having a MHP_MEMMAP_ON_MEMORY that allocates it in one chunk would be
sufficient for the current use cases (DIMMs, Hyper-V).

MHP_MEMMAP_ON_MEMORY: Allocate the memmap for the added memory in one
chunk from the beginning of the added memory. This piece of memory will
be accessed and used even before the memory is onlined.

Of course, if we want to make it configurable (e.g., for ACPI) it would
be a different story. But for now this isn't really needed as far as I
can tell.

-- 

Thanks,

David / dhildenb

