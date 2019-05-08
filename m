Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1883EC04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 08:35:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A153F2053B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 08:35:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A153F2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 101966B0003; Wed,  8 May 2019 04:35:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B2E76B0005; Wed,  8 May 2019 04:35:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EE2676B0007; Wed,  8 May 2019 04:35:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id CAD286B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 04:35:33 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id f25so213766qkk.22
        for <linux-mm@kvack.org>; Wed, 08 May 2019 01:35:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ZuJrtuIQ6NREOIFPk7z1wJQl0dyt8jdg4/r7soAERnc=;
        b=VkV8d7YKe8pfdCTPG4PyC8NDiq/FhAYGd+eK588CNBFz3KyG7UJI/6p4u3lrStSts4
         Hn6pdEmYNSceVclmZxy48mY0HQ4tZ6bMpqdSK4oMzIRd/ubbIJ9ryrHE+t3AyiIgLSvI
         aQYeuXjf09pq3G6Ku04p8YFKo/21bI8J7GPgaFuPDP2fpnv9OqBwTfmiyH6GAZlTM4ON
         S/FiLPcTGOOoZ7EraPY8ElszHLBwxFPkhk0iZaMLhWCPJYGPas0C6ELk27xNapgh0RRj
         JFnr7n+een7uhH+J2c99YLsMfAMQqsM7n+XK3EdwBSMggU7xjO3wZoLfY0S3LdCHyL+5
         ACZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVmfJswfPeN7VGzGhMRlYRJFO7WFWctwTDL/Nh+fiPwckA/vXU+
	OBHUnSI45D1lBWAaUaZrDL4C8pKfUQo6/NQS1pcQXH+vBYPyLj4NNEXJFCaEay6wldZwx5muu5K
	Dy8f8RSaI8QnJwIqaw/lAwDfIn9VqtAuXWpUWLfYPpigtEnzapBWVu7Q9Xss5C6AmLw==
X-Received: by 2002:ac8:1aa4:: with SMTP id x33mr15185626qtj.69.1557304533554;
        Wed, 08 May 2019 01:35:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw3lg43I0GMAYMWjZUKnxoDfrdVjat8NxC+Umpzh36snfaEeffkygoHrF1r82S3RfEqqfUC
X-Received: by 2002:ac8:1aa4:: with SMTP id x33mr15185584qtj.69.1557304532723;
        Wed, 08 May 2019 01:35:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557304532; cv=none;
        d=google.com; s=arc-20160816;
        b=qv52cmyQ8cXaNe9IL/zlhqCagriaYfgWMb2xmDnP7nJzOLLbhRIhcTzMDUVtyelfye
         JVjphQutBablCW1w19fc8vXrXqYRgrKPSQtngbHQx5psHoL59HF1Rma2G9f7EhzBsghE
         OX/Iu/WgJlAI51GLNM8knfX+v1k03lDzoLb/Bi2Z0oHAsdtO4f/jO9HOL7793ieswney
         KQVQKdHAGkgzRYUGYHaRIZtW22JIGbfUmdq7uVwgv9Hn/WRsNwPi4ZG7Vsd1eh9n7sRB
         Ot/2wSFWsnNQUUTFCCrzn5lahzNS/i3dX6VyzxPj8Dr6HgHov6W69o2iWob3gJRDpkuE
         jdMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ZuJrtuIQ6NREOIFPk7z1wJQl0dyt8jdg4/r7soAERnc=;
        b=tvvTCR0fROTK122tjw+zQVQ8z+QQLA/uaQT41dD73PxquatEcA/KGZI/JBc85JFmps
         L9AgtUsZ2qYshpgJJiH/mXfeQYyqEdYSrIT3W+Bx/dr7dNo3YsfC3Fjy5QQ2fdvVwj8D
         xMt24peCC/AyjtquzeV6L+qdndbXTw4ELwjw2VzJanoR66PkSeE39fdYLDOfHLMeHqMS
         3sLG2ezooNxJ95UREKgVZcYH+Xu7qoSLFjD0WLc5dRzXyI/yMeggG1qtRPmx3cj5Rj9D
         qh0Ot88CuFtNj6Szm0htFxCxaGe3zZpER/aZzhewO2Z1UqUfxTgy6ymhewDlmDvgGARq
         NRfQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e15si3796566qto.336.2019.05.08.01.35.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 01:35:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9C383302451A;
	Wed,  8 May 2019 08:35:31 +0000 (UTC)
Received: from [10.36.117.63] (ovpn-117-63.ams2.redhat.com [10.36.117.63])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B6A1460C67;
	Wed,  8 May 2019 08:35:27 +0000 (UTC)
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org,
 linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org,
 linux-sh@vger.kernel.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>,
 Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
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
Message-ID: <094f6f72-b02f-585f-6ffa-d631c71808d6@redhat.com>
Date: Wed, 8 May 2019 10:35:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190507183804.5512-5-david@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 08 May 2019 08:35:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.05.19 20:38, David Hildenbrand wrote:
> Only memory to be added to the buddy and to be onlined/offlined by
> user space using memory block devices needs (and should have!) memory
> block devices.
> 
> Factor out creation of memory block devices Create all devices after
> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
> because it is now effectively stale.
> 
> Only after memory block devices have been added, memory can be onlined
> by user space. This implies, that memory is not visible to user space at
> all before arch_add_memory() succeeded.
> 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Andrew Banman <andrew.banman@hpe.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Qian Cai <cai@lca.pw>
> Cc: Wei Yang <richard.weiyang@gmail.com>
> Cc: Arun KS <arunks@codeaurora.org>
> Cc: Mathieu Malaterre <malat@debian.org>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
>  include/linux/memory.h |  2 +-
>  mm/memory_hotplug.c    | 15 ++++-----
>  3 files changed, 53 insertions(+), 34 deletions(-)
> 
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index 6e0cb4fda179..862c202a18ca 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
>  	return 0;
>  }
>  
> +static void unregister_memory(struct memory_block *memory)
> +{
> +	BUG_ON(memory->dev.bus != &memory_subsys);
> +
> +	/* drop the ref. we got via find_memory_block() */
> +	put_device(&memory->dev);
> +	device_unregister(&memory->dev);
> +}
> +
>  /*
> - * need an interface for the VM to add new memory regions,
> - * but without onlining it.
> + * Create memory block devices for the given memory area. Start and size
> + * have to be aligned to memory block granularity. Memory block devices
> + * will be initialized as offline.
>   */
> -int hotplug_memory_register(int nid, struct mem_section *section)
> +int hotplug_memory_register(unsigned long start, unsigned long size)
>  {
> -	int ret = 0;
> +	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
> +	unsigned long start_pfn = PFN_DOWN(start);
> +	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
> +	unsigned long pfn;
>  	struct memory_block *mem;
> +	int ret = 0;
>  
> -	mutex_lock(&mem_sysfs_mutex);
> +	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
> +	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
>  
> -	mem = find_memory_block(section);
> -	if (mem) {
> -		mem->section_count++;
> -		put_device(&mem->dev);
> -	} else {
> -		ret = init_memory_block(&mem, section, MEM_OFFLINE);
> +	mutex_lock(&mem_sysfs_mutex);
> +	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +		mem = find_memory_block(__pfn_to_section(pfn));
> +		if (mem) {
> +			WARN_ON_ONCE(false);
> +			put_device(&mem->dev);
> +			continue;
> +		}
> +		ret = init_memory_block(&mem, __pfn_to_section(pfn),
> +					MEM_OFFLINE);
>  		if (ret)
> -			goto out;
> -		mem->section_count++;
> +			break;
> +		mem->section_count = memory_block_size_bytes() /
> +				     MIN_MEMORY_BLOCK_SIZE;
> +	}
> +	if (ret) {
> +		end_pfn = pfn;
> +		for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
> +			mem = find_memory_block(__pfn_to_section(pfn));
> +			if (!mem)
> +				continue;
> +			mem->section_count = 0;
> +			unregister_memory(mem);
> +		}
>  	}
> -
> -out:
>  	mutex_unlock(&mem_sysfs_mutex);
>  	return ret;
>  }
>  
> -static void
> -unregister_memory(struct memory_block *memory)
> -{
> -	BUG_ON(memory->dev.bus != &memory_subsys);
> -
> -	/* drop the ref. we got via find_memory_block() */
> -	put_device(&memory->dev);
> -	device_unregister(&memory->dev);
> -}
> -
> -void unregister_memory_section(struct mem_section *section)
> +static int remove_memory_section(struct mem_section *section)
>  {

The function change is misplaces in this patch will drop it so this
patch compiles without the other patches.


-- 

Thanks,

David / dhildenb

