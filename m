Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 499EAC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:25:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01AB52168B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 08:25:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01AB52168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 98F8E6B0006; Tue, 25 Jun 2019 04:25:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 93F958E0003; Tue, 25 Jun 2019 04:25:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 807A18E0002; Tue, 25 Jun 2019 04:25:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC806B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 04:25:56 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 18so19062407qkl.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:25:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=qQjDZ4mD8axgDTFqi0eKCsjbaLwAB7yM6Z77K7XGXs8=;
        b=nLbCLvpmOQRpeM+5vA2CsSKix8ZXkDHzuazoiEbLuFpyfJh9zm8vtF/29zmuQYz5RG
         ktUP5DRAz5b8qc2sycv5p4G2sBFMi+2kTtp47dXKKf+YhHhbeQzNyoXy4BAie7EeUrd5
         ihCUXR/G6kJ2GSEYrz/PdqTH9RbAElRu66w7ACHMWmsBO2V9I7zSvTOysDc5ic4r1yYd
         HcZKGRfFh2HqQfOtvUs7VlBwnI12qNOVUUf4sSfHuQi5+hotTfvFiq7HxygYqn4way/w
         YsMtx1+Q33spPBtYru5AAkWj80dEY53N93LMVZZ0tC+c8fFtgb9DI0GBJHsxtHOELbc9
         XA7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVNylMJokxVoDgEkvT6Hf/YKGXRdKZN+aw1orPQqmmOHYvTiiRA
	jMdUo8D5gGJsZdP04dm/dboGYxrog+RRfm7POMXjQVO9e1VetSt9yvcihEiG0XiE2zrL23PleDt
	OIZ77N1+NKFSI3+CK5usLmz4olv5uhQ2Kd9rTjhlqG96HtPb3RCPLXClXbp2c0j0lCA==
X-Received: by 2002:ac8:17f7:: with SMTP id r52mr35582852qtk.235.1561451156129;
        Tue, 25 Jun 2019 01:25:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyI0bUBuKVzNJysbKkP9AqiIB55ZxkC7tI9dKf/e3zEqQ2FKqAzIWg+f/+g9RXLuVARIVIC
X-Received: by 2002:ac8:17f7:: with SMTP id r52mr35582808qtk.235.1561451155082;
        Tue, 25 Jun 2019 01:25:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561451155; cv=none;
        d=google.com; s=arc-20160816;
        b=tN/hvivMPrrzWOhFAuypTFiXhKAZzOyYfeH9k8T4EIc6nmI1CHOD2coL91ezTEudqV
         fqyo6CMXwOp5nbEgi5GX8vMhFF59WjJttEzJo3I2jsHVo/xY8hj8xDfQ9PmvrsL3yptN
         Q3J5/aXjJAfn6+GvBMAIxxlaMh/Kz5kPV6KABj8Fj+PsiZdmb4tkTCkGIBdg+rRR54bS
         4I4xsUNUA1Qqoa0h3BFpJRGSsuJIEt24at797BzPtvo/CwtuBcWRQP0uPEdlqK1WLjh1
         4QFaVXmKrK0KPUwPITkaq1yzCLJrzHcPeRR28MdSLyVCv3IgvjYsw2VZLtNAHpUEdGj5
         5+JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=qQjDZ4mD8axgDTFqi0eKCsjbaLwAB7yM6Z77K7XGXs8=;
        b=tHk8VeDwefmWLKVhrVbY2t//48ShWywD60P0PKR0XhbvKPgyueFMOBMAXCxhVEcyp+
         42LHJOa5TRYeDSUVDiEIKdswr5MbApwFjvg63vqd1qqrSttFstto+0vdN0aJOXLkmeVa
         7LbKShiYPDbN0aImO5RP4b0cBdzyAtfxecgDHnY3RA7gHyhV0+IVckc2oBbPTlvyTnPm
         AivbDEEWWaGfRMCnB+k84+MtT0T54tn8/2NzCud2e35hHrRJKq8arGobH206uNPwsYj6
         Ub9QlA5wplrBSkTj/BZxpUmdg4Yoan6LuZnTGDciKRvFfD32eQqAI6BR6SIg2Cb51W94
         Q7AA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m14si8710700qke.372.2019.06.25.01.25.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 01:25:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BCD49309175F;
	Tue, 25 Jun 2019 08:25:53 +0000 (UTC)
Received: from [10.36.117.83] (ovpn-117-83.ams2.redhat.com [10.36.117.83])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1DBB9600C7;
	Tue, 25 Jun 2019 08:25:48 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: mhocko@suse.com, dan.j.williams@intel.com, pasha.tatashin@soleen.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 xsFNBFXLn5EBEAC+zYvAFJxCBY9Tr1xZgcESmxVNI/0ffzE/ZQOiHJl6mGkmA1R7/uUpiCjJ
 dBrn+lhhOYjjNefFQou6478faXE6o2AhmebqT4KiQoUQFV4R7y1KMEKoSyy8hQaK1umALTdL
 QZLQMzNE74ap+GDK0wnacPQFpcG1AE9RMq3aeErY5tujekBS32jfC/7AnH7I0v1v1TbbK3Gp
 XNeiN4QroO+5qaSr0ID2sz5jtBLRb15RMre27E1ImpaIv2Jw8NJgW0k/D1RyKCwaTsgRdwuK
 Kx/Y91XuSBdz0uOyU/S8kM1+ag0wvsGlpBVxRR/xw/E8M7TEwuCZQArqqTCmkG6HGcXFT0V9
 PXFNNgV5jXMQRwU0O/ztJIQqsE5LsUomE//bLwzj9IVsaQpKDqW6TAPjcdBDPLHvriq7kGjt
 WhVhdl0qEYB8lkBEU7V2Yb+SYhmhpDrti9Fq1EsmhiHSkxJcGREoMK/63r9WLZYI3+4W2rAc
 UucZa4OT27U5ZISjNg3Ev0rxU5UH2/pT4wJCfxwocmqaRr6UYmrtZmND89X0KigoFD/XSeVv
 jwBRNjPAubK9/k5NoRrYqztM9W6sJqrH8+UWZ1Idd/DdmogJh0gNC0+N42Za9yBRURfIdKSb
 B3JfpUqcWwE7vUaYrHG1nw54pLUoPG6sAA7Mehl3nd4pZUALHwARAQABzSREYXZpZCBIaWxk
 ZW5icmFuZCA8ZGF2aWRAcmVkaGF0LmNvbT7CwX4EEwECACgFAljj9eoCGwMFCQlmAYAGCwkI
 BwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEE3eEPcA/4Na5IIP/3T/FIQMxIfNzZshIq687qgG
 8UbspuE/YSUDdv7r5szYTK6KPTlqN8NAcSfheywbuYD9A4ZeSBWD3/NAVUdrCaRP2IvFyELj
 xoMvfJccbq45BxzgEspg/bVahNbyuBpLBVjVWwRtFCUEXkyazksSv8pdTMAs9IucChvFmmq3
 jJ2vlaz9lYt/lxN246fIVceckPMiUveimngvXZw21VOAhfQ+/sofXF8JCFv2mFcBDoa7eYob
 s0FLpmqFaeNRHAlzMWgSsP80qx5nWWEvRLdKWi533N2vC/EyunN3HcBwVrXH4hxRBMco3jvM
 m8VKLKao9wKj82qSivUnkPIwsAGNPdFoPbgghCQiBjBe6A75Z2xHFrzo7t1jg7nQfIyNC7ez
 MZBJ59sqA9EDMEJPlLNIeJmqslXPjmMFnE7Mby/+335WJYDulsRybN+W5rLT5aMvhC6x6POK
 z55fMNKrMASCzBJum2Fwjf/VnuGRYkhKCqqZ8gJ3OvmR50tInDV2jZ1DQgc3i550T5JDpToh
 dPBxZocIhzg+MBSRDXcJmHOx/7nQm3iQ6iLuwmXsRC6f5FbFefk9EjuTKcLMvBsEx+2DEx0E
 UnmJ4hVg7u1PQ+2Oy+Lh/opK/BDiqlQ8Pz2jiXv5xkECvr/3Sv59hlOCZMOaiLTTjtOIU7Tq
 7ut6OL64oAq+zsFNBFXLn5EBEADn1959INH2cwYJv0tsxf5MUCghCj/CA/lc/LMthqQ773ga
 uB9mN+F1rE9cyyXb6jyOGn+GUjMbnq1o121Vm0+neKHUCBtHyseBfDXHA6m4B3mUTWo13nid
 0e4AM71r0DS8+KYh6zvweLX/LL5kQS9GQeT+QNroXcC1NzWbitts6TZ+IrPOwT1hfB4WNC+X
 2n4AzDqp3+ILiVST2DT4VBc11Gz6jijpC/KI5Al8ZDhRwG47LUiuQmt3yqrmN63V9wzaPhC+
 xbwIsNZlLUvuRnmBPkTJwwrFRZvwu5GPHNndBjVpAfaSTOfppyKBTccu2AXJXWAE1Xjh6GOC
 8mlFjZwLxWFqdPHR1n2aPVgoiTLk34LR/bXO+e0GpzFXT7enwyvFFFyAS0Nk1q/7EChPcbRb
 hJqEBpRNZemxmg55zC3GLvgLKd5A09MOM2BrMea+l0FUR+PuTenh2YmnmLRTro6eZ/qYwWkC
 u8FFIw4pT0OUDMyLgi+GI1aMpVogTZJ70FgV0pUAlpmrzk/bLbRkF3TwgucpyPtcpmQtTkWS
 gDS50QG9DR/1As3LLLcNkwJBZzBG6PWbvcOyrwMQUF1nl4SSPV0LLH63+BrrHasfJzxKXzqg
 rW28CTAE2x8qi7e/6M/+XXhrsMYG+uaViM7n2je3qKe7ofum3s4vq7oFCPsOgwARAQABwsFl
 BBgBAgAPBQJVy5+RAhsMBQkJZgGAAAoJEE3eEPcA/4NagOsP/jPoIBb/iXVbM+fmSHOjEshl
 KMwEl/m5iLj3iHnHPVLBUWrXPdS7iQijJA/VLxjnFknhaS60hkUNWexDMxVVP/6lbOrs4bDZ
 NEWDMktAeqJaFtxackPszlcpRVkAs6Msn9tu8hlvB517pyUgvuD7ZS9gGOMmYwFQDyytpepo
 YApVV00P0u3AaE0Cj/o71STqGJKZxcVhPaZ+LR+UCBZOyKfEyq+ZN311VpOJZ1IvTExf+S/5
 lqnciDtbO3I4Wq0ArLX1gs1q1XlXLaVaA3yVqeC8E7kOchDNinD3hJS4OX0e1gdsx/e6COvy
 qNg5aL5n0Kl4fcVqM0LdIhsubVs4eiNCa5XMSYpXmVi3HAuFyg9dN+x8thSwI836FoMASwOl
 C7tHsTjnSGufB+D7F7ZBT61BffNBBIm1KdMxcxqLUVXpBQHHlGkbwI+3Ye+nE6HmZH7IwLwV
 W+Ajl7oYF+jeKaH4DZFtgLYGLtZ1LDwKPjX7VAsa4Yx7S5+EBAaZGxK510MjIx6SGrZWBrrV
 TEvdV00F2MnQoeXKzD7O4WFbL55hhyGgfWTHwZ457iN9SgYi1JLPqWkZB0JRXIEtjd4JEQcx
 +8Umfre0Xt4713VxMygW0PnQt5aSQdMD58jHFxTk092mU+yIHj5LeYgvwSgZN4airXk5yRXl
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
Date: Tue, 25 Jun 2019 10:25:48 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190625075227.15193-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Tue, 25 Jun 2019 08:25:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 09:52, Oscar Salvador wrote:
> Hi,
> 
> It has been while since I sent previous version [1].
> 
> In this version I added some feedback I got back then, like letting
> the caller decide whether he wants allocating per memory block or
> per memory range (patch#2), and having the chance to disable vmemmap when
> users want to expose all hotpluggable memory to userspace (patch#5).
> 
> [Testing]
> 
> While I could test last version on powerpc, and Huawei's fellows helped me out
> testing it on arm64, this time I could only test it on x86_64.
> The codebase is quite the same, so I would not expect surprises.
> 
>  - x86_64: small and large memblocks (128MB, 1G and 2G)
>  - Kernel module that adds memory spanning multiple memblocks
>    and remove that memory in a different granularity.
> 
> So far, only acpi memory hotplug uses the new flag.
> The other callers can be changed depending on their needs.
> 
> Of course, more testing and feedback is appreciated.
> 
> [Coverletter]
> 
> This is another step to make memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot-added
> memory (at least for SPARSEMEM_VMEMMAP memory model). The current way we use
> to populate memmap (struct page array) has two main drawbacks:

Mental note: How will it be handled if a caller specifies "Allocate
memmap from hotadded memory", but we are running under SPARSEMEM where
we can't do this.

> 
> a) it consumes an additional memory until the hotadded memory itself is
>    onlined and
> b) memmap might end up on a different numa node which is especially true
>    for movable_node configuration.
> 
> a) it is a problem especially for memory hotplug based memory "ballooning"
>    solutions when the delay between physical memory hotplug and the
>    onlining can lead to OOM and that led to introduction of hacks like auto
>    onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
>    policy for the newly added memory")).
> 
> b) can have performance drawbacks.
> 
> Another minor case is that I have seen hot-add operations failing on archs
> because they were running out of order-x pages.
> E.g On powerpc, in certain configurations, we use order-8 pages,
> and given 64KB base pagesize, that is 16MB.
> If we run out of those, we just fail the operation and we cannot add
> more memory.

At least for SPARSEMEM, we fallback to vmalloc() to work around this
issue. I haven't looked into the populate_section_memmap() internals
yet. Can you point me at the code that performs this allocation?

> We could fallback to base pages as x86_64 does, but we can do better.
> 
> One way to mitigate all these issues is to simply allocate memmap array
> (which is the largest memory footprint of the physical memory hotplug)
> from the hot-added memory itself. SPARSEMEM_VMEMMAP memory model allows
> us to map any pfn range so the memory doesn't need to be online to be
> usable for the array. See patch 3 for more details.
> This feature is only usable when CONFIG_SPARSEMEM_VMEMMAP is set.
> 
> [Overall design]:
> 
> Implementation wise we reuse vmem_altmap infrastructure to override
> the default allocator used by vmemap_populate. Once the memmap is
> allocated we need a way to mark altmap pfns used for the allocation.
> If MHP_MEMMAP_{DEVICE,MEMBLOCK} flag was passed, we set up the layout of the
> altmap structure at the beginning of __add_pages(), and then we call
> mark_vmemmap_pages().
> 
> The flags are either MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK, and only differ
> in the way they allocate vmemmap pages within the memory blocks.
> 
> MHP_MEMMAP_MEMBLOCK:
>         - With this flag, we will allocate vmemmap pages in each memory block.
>           This means that if we hot-add a range that spans multiple memory blocks,
>           we will use the beginning of each memory block for the vmemmap pages.
>           This strategy is good for cases where the caller wants the flexiblity
>           to hot-remove memory in a different granularity than when it was added.
> 
> MHP_MEMMAP_DEVICE:
>         - With this flag, we will store all vmemmap pages at the beginning of
>           hot-added memory.
> 
> So it is a tradeoff of flexiblity vs contigous memory.
> More info on the above can be found in patch#2.
> 
> Depending on which flag is passed (MHP_MEMMAP_DEVICE or MHP_MEMMAP_MEMBLOCK),
> mark_vmemmap_pages() gets called at a different stage.
> With MHP_MEMMAP_MEMBLOCK, we call it once we have populated the sections
> fitting in a single memblock, while with MHP_MEMMAP_DEVICE we wait until all
> sections have been populated.
> 
> mark_vmemmap_pages() marks the pages as vmemmap and sets some metadata:
> 
> The current layout of the Vmemmap pages are:
> 
>         [Head->refcount] : Nr sections used by this altmap
>         [Head->private]  : Nr of vmemmap pages
>         [Tail->freelist] : Pointer to the head page
> 
> This is done to easy the computation we need in some places.
> E.g:
> 
> Example 1)
> We hot-add 1GB on x86_64 (memory block 128MB) using
> MHP_MEMMAP_DEVICE:
> 
> head->_refcount = 8 sections
> head->private = 4096 vmemmap pages
> tail's->freelist = head
> 
> Example 2)
> We hot-add 1GB on x86_64 using MHP_MEMMAP_MEMBLOCK:
> 
> [at the beginning of each memblock]
> head->_refcount = 1 section
> head->private = 512 vmemmap pages
> tail's->freelist = head
> 
> We have the refcount because when using MHP_MEMMAP_DEVICE, we need to know
> how much do we have to defer the call to vmemmap_free().
> The thing is that the first pages of the hot-added range are used to create
> the memmap mapping, so we cannot remove those first, otherwise we would blow up
> when accessing the other pages.

So, assuming we add_memory(1GB, MHP_MEMMAP_DEVICE) and then
remove_memory(128MB) of the added memory, this will work?

add_memory(8GB, MHP_MEMMAP_DEVICE)

For 8GB, we will need exactly 128MB of memmap if I did the math right.
So exactly one section. This section will still be marked as being
online (although not pages on it are actually online)?

> 
> What we do is that since when we hot-remove a memory-range, sections are being
> removed sequentially, we wait until we hit the last section, and then we free
> the hole range to vmemmap_free backwards.
> We know that it is the last section because in every pass we
> decrease head->_refcount, and when it reaches 0, we got our last section.
> 
> We also have to be careful about those pages during online and offline
> operations. They are simply skipped, so online will keep them
> reserved and so unusable for any other purpose and offline ignores them
> so they do not block the offline operation.

I assume that they will still be dumped normally by user space. (as they
are described by a "memory resource" and not PG_Offline)

> 
> One thing worth mention is that vmemmap pages residing in movable memory is not a
> show-stopper for that memory to be offlined/migrated away.
> Vmemmap pages are just ignored in that case and they stick around until sections
> referred by those vmemmap pages are hot-removed.
> 
> [1] https://patchwork.kernel.org/cover/10875017/
> 
> Oscar Salvador (5):
>   drivers/base/memory: Remove unneeded check in
>     remove_memory_block_devices
>   mm,memory_hotplug: Introduce MHP_VMEMMAP_FLAGS
>   mm,memory_hotplug: Introduce Vmemmap page helpers
>   mm,memory_hotplug: allocate memmap from the added memory range for
>     sparse-vmemmap
>   mm,memory_hotplug: Allow userspace to enable/disable vmemmap
> 
>  arch/arm64/mm/mmu.c            |   5 +-
>  arch/powerpc/mm/init_64.c      |   7 ++
>  arch/s390/mm/init.c            |   6 ++
>  arch/x86/mm/init_64.c          |  10 +++
>  drivers/acpi/acpi_memhotplug.c |   2 +-
>  drivers/base/memory.c          |  41 +++++++++--
>  drivers/dax/kmem.c             |   2 +-
>  drivers/hv/hv_balloon.c        |   2 +-
>  drivers/s390/char/sclp_cmd.c   |   2 +-
>  drivers/xen/balloon.c          |   2 +-
>  include/linux/memory_hotplug.h |  31 ++++++++-
>  include/linux/memremap.h       |   2 +-
>  include/linux/page-flags.h     |  34 +++++++++
>  mm/compaction.c                |   7 ++
>  mm/memory_hotplug.c            | 152 ++++++++++++++++++++++++++++++++++-------
>  mm/page_alloc.c                |  22 +++++-
>  mm/page_isolation.c            |  14 +++-
>  mm/sparse.c                    |  93 +++++++++++++++++++++++++
>  mm/util.c                      |   2 +
>  19 files changed, 394 insertions(+), 42 deletions(-)
> 

Thanks for doing this, this will be very helpful :)

-- 

Thanks,

David / dhildenb

