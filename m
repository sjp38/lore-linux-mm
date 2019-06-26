Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37FBBC4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:15:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E13D62146E
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:15:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E13D62146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CFDB6B0007; Wed, 26 Jun 2019 04:15:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 781818E0003; Wed, 26 Jun 2019 04:15:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 66E3F8E0002; Wed, 26 Jun 2019 04:15:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 42DF06B0007
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:15:58 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z6so1903830qtj.7
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:15:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=WqwatnKPoi7ZhIryQnyckwh/0izQgbq3yhYa6j/LR2o=;
        b=QwQDrEmbEL5WOlSeO1ZcD7M/NrJOLo1V4p+rte558i0wFPhS0V0DlVJ7iQBGEvRYlZ
         ajmIAC8TuRpFEWPUu6JeQVw8hE64aTccttd+GxAuPfmq6qLNTKaVjvDXRA0oMF7PUKO4
         yj6GGw4mLVwJwhodqEk4BK4nIgVz/Q1nStqQNukZpWrFKc6CovK69BLewnNuE2XAiryg
         1tY+CWbjn/yH5J+2ulIpp7Cpce50sr5lSfubIRK4JC0nCjLzeXb5XNw64mx348Q4zZhg
         ldoqTfHLGcM1p4lRb1n6ukOTjNWVKSkI8GXz/gWs8zed2kG//BnXUOR+X2hQNPNz3s37
         X0AQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVJLbHk19OqrMPDTrfOMMFsTTSIvJ8OTL5Q27jMH+vzcqlm9L6k
	1J269kjr9+C0ryW/AKlGyEzHUchHmuTmMpl6SIQSedJtQKNfXemkAKz9a8xRZMoMRIZbVICuCat
	ViFMDcgFatgu++dBMLRxlOvVaZCfAugNICbsO2nXDiCeix+2yrF1ZBIeMv7/bjd/jTw==
X-Received: by 2002:ac8:5289:: with SMTP id s9mr2566825qtn.64.1561536958002;
        Wed, 26 Jun 2019 01:15:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz74W/yjA+nm0um9oN6jU4Z2xTxV+cORWT0cC6rCoFDuExY1ZplbLtXLyWL5eWux01rlcIH
X-Received: by 2002:ac8:5289:: with SMTP id s9mr2566790qtn.64.1561536957231;
        Wed, 26 Jun 2019 01:15:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561536957; cv=none;
        d=google.com; s=arc-20160816;
        b=xCM9ugXWeXQ7JK6SZ8FkjkiP0qL8FJxTeOumPTZd9ziYOYWaaJ/blPn+3YjZ2aPW+p
         FsNI/ccldSO6HX6JDd/c4Nb15PYCID7zPqBwr3pTpf7NdDz+lqQMJ8e22GkXv9ooPMXe
         5U/st2DHmFiQTxcsM7k1G3QrSVgjWzZkjPq81bXOpoNC21bEMdah2y+k3Yzz+IQetucG
         On1lBemwFNph5w/obgGHXgbLEkBRmgY29xR94tKW16c/wiML5pUriC4KaUal1k+AYLMT
         tAn7y2W7qcR5AbUHwPKVS00ZPVdBB9zuCNt0xUDJeRP035pGQWw3DNvgzUwMY2AyxAMa
         eYgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=WqwatnKPoi7ZhIryQnyckwh/0izQgbq3yhYa6j/LR2o=;
        b=uwCjb/z0pyQkZ/hcX/hgjYpIjo0+Me/HPxcHGnosGAMLrgRyxKfNZLJ8QpYSsFKe1s
         ABVGWEIXyPnf3Ac+u/yWs9Oy0jrNqcqY42Ip6lRFccVhU6o8K8+dr4xsmXpqRq9umIe+
         Jmtik5jPoGRRV4KCSSQsK2KhOFtxjdG5UAIddCUFnJgRJubGYWK35kgL76ZeoLccTFS8
         B/lVyAFxnkDjf/Hu5YyzSBcl36ZIws4Y7b+Af9DhHlJ7XCElFaPebzDVbDRlSV05Ejxm
         ggah08Ai8v6FizYG2JnKy7mrOnSF8mS+dBqF9QG9kELTwyH6RIN84LoamHsgWrVavgXU
         RbHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j17si10784091qtl.182.2019.06.26.01.15.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:15:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BCDA6309265B;
	Wed, 26 Jun 2019 08:15:48 +0000 (UTC)
Received: from [10.36.116.174] (ovpn-116-174.ams2.redhat.com [10.36.116.174])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B40611001B0E;
	Wed, 26 Jun 2019 08:15:46 +0000 (UTC)
Subject: Re: [PATCH v2 4/5] mm,memory_hotplug: allocate memmap from the added
 memory range for sparse-vmemmap
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <20190625075227.15193-5-osalvador@suse.de>
 <80f8afcf-0934-33e5-5dc4-a0d19ec2b910@redhat.com>
 <20190626081325.GB30863@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <47246a73-7df4-9ac3-8b09-c8bd6bef1098@redhat.com>
Date: Wed, 26 Jun 2019 10:15:45 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190626081325.GB30863@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Wed, 26 Jun 2019 08:15:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.06.19 10:13, Oscar Salvador wrote:
> On Tue, Jun 25, 2019 at 10:49:10AM +0200, David Hildenbrand wrote:
>> On 25.06.19 09:52, Oscar Salvador wrote:
>>> Physical memory hotadd has to allocate a memmap (struct page array) for
>>> the newly added memory section. Currently, alloc_pages_node() is used
>>> for those allocations.
>>>
>>> This has some disadvantages:
>>>  a) an existing memory is consumed for that purpose
>>>     (~2MB per 128MB memory section on x86_64)
>>>  b) if the whole node is movable then we have off-node struct pages
>>>     which has performance drawbacks.
>>>
>>> a) has turned out to be a problem for memory hotplug based ballooning
>>>    because the userspace might not react in time to online memory while
>>>    the memory consumed during physical hotadd consumes enough memory to
>>>    push system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
>>>    policy for the newly added memory") has been added to workaround that
>>>    problem.
>>>
>>> I have also seen hot-add operations failing on powerpc due to the fact
>>> that we try to use order-8 pages. If the base page size is 64KB, this
>>> gives us 16MB, and if we run out of those, we simply fail.
>>> One could arge that we can fall back to basepages as we do in x86_64, but
>>> we can do better when CONFIG_SPARSEMEM_VMEMMAP is enabled.
>>>
>>> Vmemap page tables can map arbitrary memory.
>>> That means that we can simply use the beginning of each memory section and
>>> map struct pages there.
>>> struct pages which back the allocated space then just need to be treated
>>> carefully.
>>>
>>> Implementation wise we reuse vmem_altmap infrastructure to override
>>> the default allocator used by __vmemap_populate. Once the memmap is
>>> allocated we need a way to mark altmap pfns used for the allocation.
>>> If MHP_MEMMAP_{DEVICE,MEMBLOCK} flag was passed, we set up the layout of the
>>> altmap structure at the beginning of __add_pages(), and then we call
>>> mark_vmemmap_pages().
>>>
>>> Depending on which flag is passed (MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK),
>>> mark_vmemmap_pages() gets called at a different stage.
>>> With MHP_MEMMAP_MEMBLOCK, we call it once we have populated the sections
>>> fitting in a single memblock, while with MHP_MEMMAP_DEVICE we wait until all
>>> sections have been populated.
>>
>> So, only MHP_MEMMAP_DEVICE will be used. Would it make sense to only
>> implement one for now (after we decide which one to use), to make things
>> simpler?
>>
>> Or do you have a real user in mind for the other?
> 
> Currently, only MHP_MEMMAP_DEVICE will be used, as we only pass flags from
> acpi memory-hotplug path.
> 
> All the others: hyper-v, Xen,... will have to be evaluated to see which one
> do they want to use.
> 
> Although MHP_MEMMAP_DEVICE is the only one used right now, I introduced
> MHP_MEMMAP_MEMBLOCK to give the callers the choice of using MHP_MEMMAP_MEMBLOCK
> if they think that a strategy where hot-removing works in a different granularity
> makes sense.
> 
> Moreover, since they both use the same API, there is no extra code needed to
> handle it. (Just two lines in __add_pages())
> 
> This arose here [1].
> 
> [1] https://patchwork.kernel.org/project/linux-mm/list/?submitter=137061
> 

Just noting that you can emulate MHP_MEMMAP_MEMBLOCK via
MHP_MEMMAP_DEVICE by adding memory in memory block granularity (which is
what hyper-v and xen do if I am not wrong!).

Not yet convinced that both, MHP_MEMMAP_MEMBLOCK and MHP_MEMMAP_DEVICE
are needed. But we can sort that out later.

-- 

Thanks,

David / dhildenb

