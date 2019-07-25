Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD1FEC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:30:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AACA2238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 09:30:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AACA2238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 025CB6B029B; Thu, 25 Jul 2019 05:30:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3F1C6B029D; Thu, 25 Jul 2019 05:30:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E06588E0059; Thu, 25 Jul 2019 05:30:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C02196B029B
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 05:30:28 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id e32so43923499qtc.7
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:30:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=J7tpCFZcs28+r2UOaq7ZWCm6ep0JNsCkziWjo4W0YBQ=;
        b=ov3+gHrdHVeUnxdhPfNYpiefuGCjDbHY0WV6fBZ/Ndg/EsRQLBNkoqF5UGSwCsExRT
         mW4D6JCVmENFnMvCjfepsJuZFC9BRN5ce5zAXwgiI5d7cWNnhkE4Ug7xX4bAAZmlWfYC
         zxPJ1LnsgEqM+aBfu3XhkzISHN46nMV0TLuVuXLqNTizCdh2lDs0I9fjKn0FJahcGnRy
         /w0274+S+CrR96BbrmCuQb+NgMUUhoRe0nRHpARySbuXIaVXhI9E/NJciFF0mseIIinc
         m4n5roYD56h7dp6CJo1lcbB3102pg+qsisV5PfpncAU2sbjUjyl/rJqmcVFwmR6t3LzW
         +DNg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWjyXKttOUa+rKMdfG45VhRP56u4SsRh/HvkP7Hq8ln6iisgXoe
	q1QoJtuuJF+IVPRLs+PgkWBfJmJ/c3v0uJBz60lF4W9rzBg8epOgsBoRWwjVFFxhEihT3lrHcwW
	edFveC1iTDuMpkwDvj3Kabd/jBS2rP0NnB12Etu+3TECjkxnrPHAl7HDg6GT859fjaA==
X-Received: by 2002:a0c:8a43:: with SMTP id 3mr64291923qvu.138.1564047028514;
        Thu, 25 Jul 2019 02:30:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAlCASuiyo3RpT2g7Yjjl7ii+uZL5uea9ffJA7DfR7fgfEbEpQ4IqMM/myQ8qHILQCcusd
X-Received: by 2002:a0c:8a43:: with SMTP id 3mr64291872qvu.138.1564047027753;
        Thu, 25 Jul 2019 02:30:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564047027; cv=none;
        d=google.com; s=arc-20160816;
        b=QfnK7k7l/ZWZXhCghjyScA/qp0WZMKA9Up122BvQCMrmJuWR0ITzA+I64sR0bWx7Pc
         5x5vdO9HphvMrSWxqFhIcRGdiru50IBnHHA0qMa1TNaTmJBFRbTb1D1J1KSougNXOV9G
         i6yji34SlgQJyY+XweGJ0eSeFqSLUjVOeqY5GkYiCzzSnQQKsfJHtEi+zqMRLgB/jBIa
         miNRKLuq6DzuYW2WwPEhxLnyP7lvPkfJrEtOBG8kkSon2iySC9KHHWPoP1KJv1YAOQj8
         kFgfnKsC7mw1c5LaqAVhcFwmi/ZC3avGUFHpAKeUyM3lXZ+QENi7Y1kjttP+Gql6l5K6
         dpog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=J7tpCFZcs28+r2UOaq7ZWCm6ep0JNsCkziWjo4W0YBQ=;
        b=sI6w7WNo3sYs8w7YXLL6UX7r/c70+VZLNGfuzbPZgRFR4h/sUlt9QpL6unyJn9uyTM
         OALblxOQe0qNNEzFV8nY4DGrM7GumUQzr72A+3mRFziBIE3In9k46uusPioKbYRWlXaY
         zrGEd/IalM36/z49F0X0we6zLSzey2f26avXTlDjmmFa95ZDn6kejZx/eNniTpWyubXM
         rJfiiAbWSXFVO68VNd4TRjKByNrlMuEvAknW/tQU0mC6UTWzEWsbgiZ524vtV537wzkN
         /3NASoh+SxMC20A/sGfEEQs225JGCpgYSTzrMNgLJz81rL+03zaDEPhaqFiz8EXjMrw6
         kDgw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k6si28998257qki.23.2019.07.25.02.30.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 02:30:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D0E5B31628FF;
	Thu, 25 Jul 2019 09:30:26 +0000 (UTC)
Received: from [10.36.117.212] (ovpn-117-212.ams2.redhat.com [10.36.117.212])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 943B85C6E3;
	Thu, 25 Jul 2019 09:30:24 +0000 (UTC)
Subject: Re: [PATCH v2 2/5] mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
To: Oscar Salvador <osalvador@suse.de>,
 Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko
 <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Vlastimil Babka <vbabka@suse.cz>, Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-3-osalvador@suse.de>
 <CAPcyv4hvu+wp4tJJNW70jp2G_rNabyvzGMvDTS3PzkDCAFztYg@mail.gmail.com>
 <20190725092751.GA15964@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <71a30086-b093-48a4-389f-7e407898718f@redhat.com>
Date: Thu, 25 Jul 2019 11:30:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725092751.GA15964@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 25 Jul 2019 09:30:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 11:27, Oscar Salvador wrote:
> On Wed, Jul 24, 2019 at 01:11:52PM -0700, Dan Williams wrote:
>> On Tue, Jun 25, 2019 at 12:53 AM Oscar Salvador <osalvador@suse.de> wrote:
>>>
>>> This patch introduces MHP_MEMMAP_DEVICE and MHP_MEMMAP_MEMBLOCK flags,
>>> and prepares the callers that add memory to take a "flags" parameter.
>>> This "flags" parameter will be evaluated later on in Patch#3
>>> to init mhp_restrictions struct.
>>>
>>> The callers are:
>>>
>>> add_memory
>>> __add_memory
>>> add_memory_resource
>>>
>>> Unfortunately, we do not have a single entry point to add memory, as depending
>>> on the requisites of the caller, they want to hook up in different places,
>>> (e.g: Xen reserve_additional_memory()), so we have to spread the parameter
>>> in the three callers.
>>>
>>> The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and only differ
>>> in the way they allocate vmemmap pages within the memory blocks.
>>>
>>> MHP_MEMMAP_MEMBLOCK:
>>>         - With this flag, we will allocate vmemmap pages in each memory block.
>>>           This means that if we hot-add a range that spans multiple memory blocks,
>>>           we will use the beginning of each memory block for the vmemmap pages.
>>>           This strategy is good for cases where the caller wants the flexiblity
>>>           to hot-remove memory in a different granularity than when it was added.
>>>
>>>           E.g:
>>>                 We allocate a range (x,y], that spans 3 memory blocks, and given
>>>                 memory block size = 128MB.
>>>                 [memblock#0  ]
>>>                 [0 - 511 pfns      ] - vmemmaps for section#0
>>>                 [512 - 32767 pfns  ] - normal memory
>>>
>>>                 [memblock#1 ]
>>>                 [32768 - 33279 pfns] - vmemmaps for section#1
>>>                 [33280 - 65535 pfns] - normal memory
>>>
>>>                 [memblock#2 ]
>>>                 [65536 - 66047 pfns] - vmemmap for section#2
>>>                 [66048 - 98304 pfns] - normal memory
>>>
>>> MHP_MEMMAP_DEVICE:
>>>         - With this flag, we will store all vmemmap pages at the beginning of
>>>           hot-added memory.
>>>
>>>           E.g:
>>>                 We allocate a range (x,y], that spans 3 memory blocks, and given
>>>                 memory block size = 128MB.
>>>                 [memblock #0 ]
>>>                 [0 - 1533 pfns    ] - vmemmap for section#{0-2}
>>>                 [1534 - 98304 pfns] - normal memory
>>>
>>> When using larger memory blocks (1GB or 2GB), the principle is the same.
>>>
>>> Of course, MHP_MEMMAP_DEVICE is nicer when it comes to have a large contigous
>>> area, while MHP_MEMMAP_MEMBLOCK allows us to have flexibility when removing the
>>> memory.
>>
>> Concept and patch looks good to me, but I don't quite like the
>> proliferation of the _DEVICE naming, in theory it need not necessarily
>> be ZONE_DEVICE that is the only user of that flag. I also think it
>> might be useful to assign a flag for the default 'allocate from RAM'
>> case, just so the code is explicit. So, how about:
> 
> Well, MHP_MEMMAP_DEVICE is not tied to ZONE_DEVICE.
> MHP_MEMMAP_DEVICE was chosen to make a difference between:
> 
>  * allocate memmap pages for the whole memory-device
>  * allocate memmap pages on each memoryblock that this memory-device spans

I agree that DEVICE is misleading here, you are assuming a one-to-one
mapping between a device and add_memory(). You are actually taliing
about "allocate a single chunk of mmap pages for the whole memory range
that is added - which could consist of multiple memory blocks".

-- 

Thanks,

David / dhildenb

