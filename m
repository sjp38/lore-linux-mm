Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DACDFC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:56:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8ED0421851
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:56:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8ED0421851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F9B66B0006; Thu, 25 Jul 2019 12:56:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0AC716B0007; Thu, 25 Jul 2019 12:56:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB5178E0002; Thu, 25 Jul 2019 12:56:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id C99966B0006
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:56:44 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id q25so5399772uar.17
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:56:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=rbDMXoRSXlzGT0tjWZhwdrsLBEa4Yni2xq2GD1gmOho=;
        b=VIav9XkqHH2xrwT0bc5n3mbsw0n/wwi5qnYETov9jSmrg3MSct+DdhJ9DvmdmiYt/0
         Da6d0UbamwmuDY1cBdgbaRKXTT8j1MQ3E6lXOt6TQPdBqeUi8Ic9+Pr/Dehm53P8m/GD
         zrwJe4iPhqPYyvyOgPavg+txC7kDIwtd57l2Nrvkz1SQae49PlA42u38TQ1pNdxc4WXV
         QTwK7zbRF7l0kpBsCsoV26TqdzEhekCQ8wnNElxwpR7tZ4KRme9LnoXRFTQq7SUe4ezq
         p2/GLn94ZXaOMz5M/OdHnlKbbn0uDGvBLXEzYUU2b1BOksy5Bpg2ZRlAkt0V04TSIT+9
         JUoQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUrM5b79ApRgtZmiLG0kgGiKivZhZn/cIht+eDY+i7jdVdvs+p7
	/aqwsyrtqnvZ+Ew/ZY1sOz7bZIYfsVt2PynibvcIJYWQ/T9rWRInjss29x8SXsw7uwQqccx3J1G
	apC7ZoZnWxPKRjbLFhG8r6iOEk99YnXDXe+4bk16Qrj7V6KK7ajnNXKU/EplS97F/mw==
X-Received: by 2002:a67:444:: with SMTP id 65mr56599208vse.166.1564073804564;
        Thu, 25 Jul 2019 09:56:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYn5bV3dBSKXLSO4JGCoKtCMaI/c0B8LqFrhcV3BEk6J8a2f+mqBZ6gBMg3pj1cWs0Nwd2
X-Received: by 2002:a67:444:: with SMTP id 65mr56599113vse.166.1564073803663;
        Thu, 25 Jul 2019 09:56:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564073803; cv=none;
        d=google.com; s=arc-20160816;
        b=xxVo7JhVho+qN3vu+HoRePCpkETwpCtgoJQs5Twsu2jsmmooE3UkAsIhMTJsgKNkjS
         W8nygLDO0qUuD2c2CNCfyoWFnoRBJGfCbEUmOIY3uOwxaduXux/t1lhlC6y3vZ6hZvqo
         Njk9WdCTJ5zJiT3gc6jurQDw1nW6aJZ6d++F9HPPxHO/DQGJ2Qvgbyp73p7bjDdA9h45
         A84jQkZzYgoEUNx/+MApdoJMhLHBytVvZE8FDyUCr9TKimzqX1yzFyATPYut4+iVwA3O
         1HE8zFti6JcqcFgJbXU15+fzNLxBsEoS6/DqR+curNCtiH8gle0MGWPyhOvz0WuL3Lbs
         zP7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=rbDMXoRSXlzGT0tjWZhwdrsLBEa4Yni2xq2GD1gmOho=;
        b=nscGNEkXAiZB2nnG5biXMQ6TYm7lqh9USehTJBhyzr2EEPZ53dn7waI5eHhma28fXv
         d93Ta1rQk5HA2lpcKTK/4wHa/rUFrmcQXRJMsYW52peouQny6aUl1igSTA/o1mliX/b/
         aS26r743eouhM0smC4heCXEIZo/MsfDWI0G77gutgNcoyY8dyc431okk7A6moxq5Meqy
         Cew43Z4E8tY31lVGyHPNkw0GQG3r2JCV+Uc1PZ2QXa1OTEKNkSZ9uIZJ4OPDFMxdclSb
         1nNdRwh1oLxJYez5Gmj+wBO7Om0NMG5nhHMIZUWVtiueegyIqAYiLXsU2dl4KNDOV9ke
         os2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b7si781924vsj.178.2019.07.25.09.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:56:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7AF5B30C585C;
	Thu, 25 Jul 2019 16:56:42 +0000 (UTC)
Received: from [10.36.116.67] (ovpn-116-67.ams2.redhat.com [10.36.116.67])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 56C085D71A;
	Thu, 25 Jul 2019 16:56:40 +0000 (UTC)
Subject: Re: [PATCH v3 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, pasha.tatashin@soleen.com, mhocko@suse.com,
 anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
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
Message-ID: <2598d082-dd20-627e-61e9-b9e4b37af877@redhat.com>
Date: Thu, 25 Jul 2019 18:56:39 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725160207.19579-1-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 25 Jul 2019 16:56:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 18:02, Oscar Salvador wrote:
> Here we go with v3.
> 
> v3 -> v2:
>         * Rewrite about vmemmap pages handling.
>           Prior to this version, I was (ab)using hugepages fields
>           from struct page, while here I am officially adding a new
>           sub-page type with the fields I need.
> 
>         * Drop MHP_MEMMAP_{MEMBLOCK,DEVICE} in favor of MHP_MEMMAP_ON_MEMORY.
>           While I am still not 100% if this the right decision, and while I
>           still see some gaining in having MHP_MEMMAP_{MEMBLOCK,DEVICE},
>           having only one flag ease the code.
>           If the user wants to allocate memmaps per memblock, it'll
>           have to call add_memory() variants with memory-block granularity.
> 
>           If we happen to have a more clear usecase MHP_MEMMAP_MEMBLOCK
>           flag in the future, so user does not have to bother about the way
>           it calls add_memory() variants, but only pass a flag, we can add it.
>           Actually, I already had the code, so add it in the future is going to be
>           easy.

FWIW, for now I think this is the right thing to do. Whoever roots for
this now has to propose an interface on how this is going to be used
now. Otherwise, this is untested, dead code. Nobody wants that :)

> 
>         * Granularity check when hot-removing memory.
>           Just checking that the granularity is the same.

This is for the powernv/memtrace.c case, right?

> 
> [Testing]
> 
>  - x86_64: small and large memblocks (128MB, 1G and 2G)
> 
> So far, only acpi memory hotplug uses the new flag.
> The other callers can be changed depending on their needs.
> 
> [Coverletter]
> 
> This is another step to make memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot-added
> memory (at least for SPARSEMEM_VMEMMAP memory model). The current way we use
> to populate memmap (struct page array) has two main drawbacks:
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

We now also consume less NORMAL memory when onlining DIMMs to the
MOVABLE_ZONE, as the vmemmap no longer ends up in the NORMAL zone -
which is nice. (not perfect, but nice :) )

I'm curious on how/when you are initializing the vmemmap and setting all
vmemmap pages to the new page type. Right now, we initialize it when
onlining memory - will have a look how you sorted that out :)

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
> If MHP_MEMMAP_ON_MEMORY flag was passed, we set up the layout of the
> altmap structure at the beginning of __add_pages(), and then we call
> mark_vmemmap_pages().
> 
> MHP_MEMMAP_ON_MEMORY flag parameter will specify to allocate memmaps
> from the hot-added range.
> If callers wants memmaps to be allocated per memory block, it will
> have to call add_memory() variants in memory-block granularity
> spanning the whole range, while if it wants to allocate memmaps
> per whole memory range, just one call will do.

I assume you you played with all kinds of offlining/onlining of affected
memory blocks and especially that the vmemmap pages remain set to the
new page type?

-- 

Thanks,

David / dhildenb

