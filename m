Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7BF6C76191
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:34:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D3CE22CBE
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:34:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D3CE22CBE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 036B76B0003; Fri, 26 Jul 2019 04:34:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F02576B0005; Fri, 26 Jul 2019 04:34:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7B378E0003; Fri, 26 Jul 2019 04:34:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0FFD6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:34:52 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id s9so46851920qtn.14
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:34:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=2VjfKcUW3GszsU06+csJE/013gKljOkf0waZMUJ2Cgo=;
        b=bmWmDACGxy26We1xmWlAi8mW9jahJKtnvewveq35LqD9tywi9XXNyVsxoYD+9VKRfV
         pWbHczTsmAu3Mu8RQCu1ctRz5E2CSdy59O4X9I1wVSWNSk94bc2PfoVeuCZwd4NatPfl
         FL3I6c8VEsE5Sz5LNw99PrXeAHFaaSKUnUFOO9D8bY2d3+XiYUqHkmDfJuUcxh369+hj
         tFZGsgU/JRVlueSz+kA42XtAUKvj09zo97tVXrDp0EFv27O0t2F8O2xy1t36WAhXivuF
         54Bjp4TqzarR7hJIl61Mfck0/ZtUpdJKTN9q8gaxHYuZwFIYZVe9mAChjgtuQmif+Bxn
         28yg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAURag/HnNY5qB67rXpEtwv5aie+G7NXMSuaMr0VmyYDXv8s1HB5
	iWrymRda2+glSbA/wYgIc6fvOiFPNz2Sg5wxUCNlH3DpRlgqFNNHYTfKRiJ/kleY0kOuSkbA7AX
	at+AN7SEnJZU/p5ZCF8vJvaXXjpZebnMAIcsklN5OflObTw9IUH+ectErB3cgko7MTA==
X-Received: by 2002:ac8:3449:: with SMTP id v9mr66354637qtb.163.1564130092457;
        Fri, 26 Jul 2019 01:34:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHj24W2sFU9a9j/1k3qkRzYw5Nr1PrbG1XQ9kZFvgQ2UJ3UoArnMmlwpMzCmGU08B2vYfX
X-Received: by 2002:ac8:3449:: with SMTP id v9mr66354599qtb.163.1564130091550;
        Fri, 26 Jul 2019 01:34:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564130091; cv=none;
        d=google.com; s=arc-20160816;
        b=RTnM2NHibjxZJAWYgef+pa2QSsCcP/FzZebR2a7J8pgcFNI710Eyxa45D6o40k0hpw
         3HEcyEoCTbmtFDo+6nuLA2Se/dB3gQJCMpDnvYmvyRMo445lrZIr/MeVCxGjqLbM4yIB
         oIZWM25cq2bCYFr1AQ5rU2VROaDr8hZjFJFCFpN5hmmzy2UNkc86BK6uWuG1oThveMnX
         /R89p4XbSRJvBIgKjQW9aRq6IuWF0jQjBsuVOrt1JpjEbX+6DpKGE7BTjAQub3+jZuoM
         zLPAlpyT1WP906N010oTWME/c60JLEHVflm60blr+0CuwNWYHnOXI1gGgohKDFIVd+fh
         N7PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=2VjfKcUW3GszsU06+csJE/013gKljOkf0waZMUJ2Cgo=;
        b=aeyhcV5K9+6DnCn9rMOQyjCMTGYc5R/aJ8q6O/OaJUVD4mlBYK2F+8cuBJ8OI0Qipb
         g+v4Ob5KhamT4XADYTVIXkRvlTUVl/DdyB66ThCP33SWOZ5iSH19MTHV65DItYnnMdEe
         nP0rkIsjnbv3bk4fJLYqa5AyizkSu12kGL61GyDRXaryhEGUIfFlGbyaIutCHJ3ihtcK
         /e7poUTRuhd92FEh+ZaZInuiuU8pLEIbMDR2tVWBZwFgu5UYL2qonj3Un9UgTwHAnHzq
         aP3Uj+mcpeuiU/yTUmrfpAyjDoTDjFn79MNr0d13J+9qVH4vAWmXiIzBwYfudidvccsV
         2VSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d48si32588886qta.166.2019.07.26.01.34.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:34:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A51C030C34D4;
	Fri, 26 Jul 2019 08:34:50 +0000 (UTC)
Received: from [10.36.116.244] (ovpn-116-244.ams2.redhat.com [10.36.116.244])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4076A6092D;
	Fri, 26 Jul 2019 08:34:48 +0000 (UTC)
Subject: Re: [PATCH v3 1/5] mm,memory_hotplug: Introduce MHP_MEMMAP_ON_MEMORY
To: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, pasha.tatashin@soleen.com, mhocko@suse.com,
 anshuman.khandual@arm.com, Jonathan.Cameron@huawei.com, vbabka@suse.cz,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <20190725160207.19579-1-osalvador@suse.de>
 <20190725160207.19579-2-osalvador@suse.de>
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
Message-ID: <8b60e40a-1e8a-1f7c-a31d-ad2e511decd5@redhat.com>
Date: Fri, 26 Jul 2019 10:34:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190725160207.19579-2-osalvador@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Fri, 26 Jul 2019 08:34:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 18:02, Oscar Salvador wrote:
> This patch introduces MHP_MEMMAP_ON_MEMORY flag,
> and prepares the callers that add memory to take a "flags" parameter.
> This "flags" parameter will be evaluated later on in Patch#3
> to init mhp_restrictions struct.
> 
> The callers are:
> 
> add_memory
> __add_memory
> add_memory_resource
> 
> Unfortunately, we do not have a single entry point to add memory, as depending
> on the requisites of the caller, they want to hook up in different places,
> (e.g: Xen reserve_additional_memory()), so we have to spread the parameter
> in the three callers.
> 
> MHP_MEMMAP_ON_MEMORY flag parameter will specify to allocate memmaps
> from the hot-added range.
> If callers wants memmaps to be allocated per memory block, it will
> have to call add_memory() variants in memory-block granularity
> spanning the whole range, while if it wants to allocate memmaps
> per whole memory range, just one call will do.
> 
> Want to add 384MB (3 sections, 3 memory-blocks)
> e.g:
> 
> 	add_memory(0x1000, size_memory_block);
> 	add_memory(0x2000, size_memory_block);
> 	add_memory(0x3000, size_memory_block);
> 
> 	[memblock#0  ]
> 	[0 - 511 pfns      ] - vmemmaps for section#0
> 	[512 - 32767 pfns  ] - normal memory
> 
> 	[memblock#1 ]
> 	[32768 - 33279 pfns] - vmemmaps for section#1
> 	[33280 - 65535 pfns] - normal memory
> 
> 	[memblock#2 ]
> 	[65536 - 66047 pfns] - vmemmap for section#2
> 	[66048 - 98304 pfns] - normal memory

I wouldn't even care about documenting this right now. We have no user
so far, so spending 50% of the description on this topic isn't really
needed IMHO :)

> 
> or
> 	add_memory(0x1000, size_memory_block * 3);
> 
> 	[memblock #0 ]
>         [0 - 1533 pfns    ] - vmemmap for section#{0-2}
>         [1534 - 98304 pfns] - normal memory
> 
> When using larger memory blocks (1GB or 2GB), the principle is the same.
> 
> Of course, per whole-range granularity is nicer when it comes to have a large
> contigous area, while per memory-block granularity allows us to have flexibility
> when removing the memory.

E.g., in my virtio-mem I am currently adding all memory blocks
separately either way (to guranatee that remove_memory() works cleanly -
see __release_memory_resource()), and to control the amount of
not-offlined memory blocks (e.g., to make user space is actually
onlining them). As it's just a prototype, this might change of course in
the future.

> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  drivers/acpi/acpi_memhotplug.c |  2 +-
>  drivers/base/memory.c          |  2 +-
>  drivers/dax/kmem.c             |  2 +-
>  drivers/hv/hv_balloon.c        |  2 +-
>  drivers/s390/char/sclp_cmd.c   |  2 +-
>  drivers/xen/balloon.c          |  2 +-
>  include/linux/memory_hotplug.h | 25 ++++++++++++++++++++++---
>  mm/memory_hotplug.c            | 10 +++++-----
>  8 files changed, 33 insertions(+), 14 deletions(-)
> 
> diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
> index e294f44a7850..d91b3584d4b2 100644
> --- a/drivers/acpi/acpi_memhotplug.c
> +++ b/drivers/acpi/acpi_memhotplug.c
> @@ -207,7 +207,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
>  		if (node < 0)
>  			node = memory_add_physaddr_to_nid(info->start_addr);
>  
> -		result = __add_memory(node, info->start_addr, info->length);
> +		result = __add_memory(node, info->start_addr, info->length, 0);
>  
>  		/*
>  		 * If the memory block has been used by the kernel, add_memory()
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 154d5d4a0779..d30d0f6c8ad0 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -521,7 +521,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
>  
>  	nid = memory_add_physaddr_to_nid(phys_addr);
>  	ret = __add_memory(nid, phys_addr,
> -			   MIN_MEMORY_BLOCK_SIZE * sections_per_block);
> +			   MIN_MEMORY_BLOCK_SIZE * sections_per_block, 0);
>  
>  	if (ret)
>  		goto out;
> diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
> index 3d0a7e702c94..e159184e0ba0 100644
> --- a/drivers/dax/kmem.c
> +++ b/drivers/dax/kmem.c
> @@ -65,7 +65,7 @@ int dev_dax_kmem_probe(struct device *dev)
>  	new_res->flags = IORESOURCE_SYSTEM_RAM;
>  	new_res->name = dev_name(dev);
>  
> -	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
> +	rc = add_memory(numa_node, new_res->start, resource_size(new_res), 0);
>  	if (rc) {
>  		release_resource(new_res);
>  		kfree(new_res);
> diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
> index 6fb4ea5f0304..beb92bc56186 100644
> --- a/drivers/hv/hv_balloon.c
> +++ b/drivers/hv/hv_balloon.c
> @@ -731,7 +731,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
>  
>  		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
>  		ret = add_memory(nid, PFN_PHYS((start_pfn)),
> -				(HA_CHUNK << PAGE_SHIFT));
> +				(HA_CHUNK << PAGE_SHIFT), 0);
>  
>  		if (ret) {
>  			pr_err("hot_add memory failed error is %d\n", ret);
> diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
> index 37d42de06079..f61026c7db7e 100644
> --- a/drivers/s390/char/sclp_cmd.c
> +++ b/drivers/s390/char/sclp_cmd.c
> @@ -406,7 +406,7 @@ static void __init add_memory_merged(u16 rn)
>  	if (!size)
>  		goto skip_add;
>  	for (addr = start; addr < start + size; addr += block_size)
> -		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
> +		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size, 0);
>  skip_add:
>  	first_rn = rn;
>  	num = 1;
> diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
> index 4e11de6cde81..e4934ce40478 100644
> --- a/drivers/xen/balloon.c
> +++ b/drivers/xen/balloon.c
> @@ -349,7 +349,7 @@ static enum bp_state reserve_additional_memory(void)
>  	mutex_unlock(&balloon_mutex);
>  	/* add_memory_resource() requires the device_hotplug lock */
>  	lock_device_hotplug();
> -	rc = add_memory_resource(nid, resource);
> +	rc = add_memory_resource(nid, resource, 0);
>  	unlock_device_hotplug();
>  	mutex_lock(&balloon_mutex);
>  
> diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
> index f46ea71b4ffd..45dece922d7c 100644
> --- a/include/linux/memory_hotplug.h
> +++ b/include/linux/memory_hotplug.h
> @@ -54,6 +54,25 @@ enum {
>  };
>  
>  /*
> + * We want memmap (struct page array) to be allocated from the hotadded range.
> + * To do so, there are two possible ways depending on what the caller wants.
> + * 1) Allocate memmap pages whole hot-added range.
> + *    Here the caller will only call any add_memory() variant with the whole
> + *    memory address.
> + * 2) Allocate memmap pages per memblock
> + *    Here, the caller will call any add_memory() variant per memblock
> + *    granularity.
> + * The former implies that we will use the beginning of the hot-added range
> + * to store the memmap pages of the whole range, while the latter implies
> + * that we will use the beginning of each memblock to store its own memmap
> + * pages.

Can you make this documentation only state how MHP_MEMMAP_ON_MEMORY
works? (IOW, shrink it heavily to what we actually implement)

> + *
> + * Please note that this is only a hint, not a guarantee. Only selected
> + * architectures support it with SPARSE_VMEMMAP.
> + */
> +#define MHP_MEMMAP_ON_MEMORY	(1UL<<1)
> +
> +/*
>   * Restrictions for the memory hotplug:
>   * flags:  MHP_ flags
>   * altmap: alternative allocator for memmap array
> @@ -340,9 +359,9 @@ static inline void __remove_memory(int nid, u64 start, u64 size) {}
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
>  extern void __ref free_area_init_core_hotplug(int nid);
> -extern int __add_memory(int nid, u64 start, u64 size);
> -extern int add_memory(int nid, u64 start, u64 size);
> -extern int add_memory_resource(int nid, struct resource *resource);
> +extern int __add_memory(int nid, u64 start, u64 size, unsigned long flags);
> +extern int add_memory(int nid, u64 start, u64 size, unsigned long flags);
> +extern int add_memory_resource(int nid, struct resource *resource, unsigned long flags);
>  extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
>  		unsigned long nr_pages, struct vmem_altmap *altmap);
>  extern bool is_memblock_offlined(struct memory_block *mem);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 9a82e12bd0e7..3d97c3711333 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1046,7 +1046,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
>   *
>   * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
>   */
> -int __ref add_memory_resource(int nid, struct resource *res)
> +int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags)
>  {
>  	struct mhp_restrictions restrictions = {};
>  	u64 start, size;
> @@ -1123,7 +1123,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
>  }
>  
>  /* requires device_hotplug_lock, see add_memory_resource() */
> -int __ref __add_memory(int nid, u64 start, u64 size)
> +int __ref __add_memory(int nid, u64 start, u64 size, unsigned long flags)
>  {
>  	struct resource *res;
>  	int ret;
> @@ -1132,18 +1132,18 @@ int __ref __add_memory(int nid, u64 start, u64 size)
>  	if (IS_ERR(res))
>  		return PTR_ERR(res);
>  
> -	ret = add_memory_resource(nid, res);
> +	ret = add_memory_resource(nid, res, flags);
>  	if (ret < 0)
>  		release_memory_resource(res);
>  	return ret;
>  }
>  
> -int add_memory(int nid, u64 start, u64 size)
> +int add_memory(int nid, u64 start, u64 size, unsigned long flags)
>  {
>  	int rc;
>  
>  	lock_device_hotplug();
> -	rc = __add_memory(nid, start, size);
> +	rc = __add_memory(nid, start, size, flags);
>  	unlock_device_hotplug();
>  
>  	return rc;
> 

Apart from the requested description/documentation changes

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb

