Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 527E6C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:38:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC09A21841
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 14:38:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC09A21841
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AEAD6B0008; Wed, 17 Jul 2019 10:38:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55FF18E0003; Wed, 17 Jul 2019 10:38:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4260A8E0001; Wed, 17 Jul 2019 10:38:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2176C6B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 10:38:36 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id k125so20252890qkc.12
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 07:38:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=GdM7NKyFH524MPCjwjxMKxYZLOycKgENrZRvN2UfZlo=;
        b=sK6qx35JY/nu1gKGwTPCeMYsG5mHo5oKXT1Q9cWA1oLqepHW1JYtbiH+lJkX38PPEJ
         3McG4LMlotpDWniZX+SqH2kEhnA5Bzatxj8X4AgiTbdh7I2MNx0H4g6VmtEe1lDvP3PG
         KtocjmHKSeUC/EXoVtry91FwMwSI1iipSe+Wq654S4A9vQEYI/OVNaW858lr6ObokwNU
         QNKKDNAk3dsiJ+kh/RJ8TTM97+iVAJmsKf7vnaYyr1xs5E64LwDNuYYJeutG+4HpeNSy
         12Lv4hDvkp0fQIXeiBWtexxqjdOwplQFWYwnC+2pxqs65VzgSPkEUdqOd1seGlfw3WmQ
         o2gA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX3cEBUpWR2KIw1mhAG+OupFe1ceQFsnTj/bJq2StYnuCDuwaeM
	BxevivZPS0eeezijtbiJT81h0yWiiz2Sj4byajhv0uBxbaAa3T9NYeq+ohAn05Z+JpH8r4912Gl
	jmE21D612an0jK4/stLkRIow5eDY3kdGkhpZUeYyOWkplMYaKR2tRx9lRX94Z0UFbkA==
X-Received: by 2002:a0c:9895:: with SMTP id f21mr28399642qvd.123.1563374315922;
        Wed, 17 Jul 2019 07:38:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPulH2/WEiP7iRRBzvZKoouxkQpAAHnkSmrjDRDvSaAH08bwTbR7hR5XLgIaDWEmD3M0s6
X-Received: by 2002:a0c:9895:: with SMTP id f21mr28399611qvd.123.1563374315428;
        Wed, 17 Jul 2019 07:38:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563374315; cv=none;
        d=google.com; s=arc-20160816;
        b=ZvM0I+QTGJHaddQA3szmERlF7pktloYBPoQxlpF8IUSJsezfIq144ykMb+Gea2o8xs
         SRo4WN2Mw5Gl/Q2j0VaoEEOUvYk4fVLrgJVEPm2Go3fURA6H3eqTC2TFIAk4z7QOIr26
         abu71/qblz6wBxSrHdDBBmxYGw/iYgdYhfmRvsnmx1jD9SXOW/Gj7VjyMT0QPosMCPhS
         majFSWg1btMNY0KlE7TCMIgo096teBx0CL+BbXqiSKr+kWQXJ70HtK754Z19TbwqppmE
         YEgP/Bx7lXaR4uvuoK4MtP2DBcoAg2KpcYCHOS/WuRXgTGPZpLsBe5WJLIyWhpvoRw1k
         h5pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=GdM7NKyFH524MPCjwjxMKxYZLOycKgENrZRvN2UfZlo=;
        b=Ykwyra1N/vd58b4K55Dp7BMNzjH22elcW27NpFmebZwiv0aU6K95gy8MgJ761OkTzb
         oJeEIydPY2PqMmtNxnnmTyRwXolB2IsVoNW1gCAYD1bDgbk1QdDt6Jbo28ZBo/GSyKmT
         /aqdce6fa312CaBj2rI+ciB5ud0V0fvGUL4esko+l3od096zcbqN80tav40FXHDDxXp/
         xRaBwOTXxtUD91ex5igLKLBBNhU6bQ08SVyb8k9MyYovwBZl9yhL6nOu2BP6LY1Y7isv
         WN3Mq1L7ivruI4Uj7ZqXmF/nye6u10lpJaemHM686eu2+/vA+4z8mHpBQLi4fJxzGucB
         Dabw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o25si14677634qkk.39.2019.07.17.07.38.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jul 2019 07:38:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6691337F46;
	Wed, 17 Jul 2019 14:38:34 +0000 (UTC)
Received: from [10.36.116.213] (ovpn-116-213.ams2.redhat.com [10.36.116.213])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 9200D19C59;
	Wed, 17 Jul 2019 14:38:23 +0000 (UTC)
Subject: Re: use of shrinker in virtio balloon free page hinting
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>, wei.w.wang@intel.com,
 Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 Dave Hansen <dave.hansen@intel.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
 Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
 Rik van Riel <riel@surriel.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com,
 Andrea Arcangeli <aarcange@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>,
 dan.j.williams@intel.com, Alexander Duyck <alexander.h.duyck@linux.intel.com>
References: <20190717071332-mutt-send-email-mst@kernel.org>
 <959237f9-22cc-1e57-e07d-b8dc3ddf9ed6@redhat.com>
 <20190717103208-mutt-send-email-mst@kernel.org>
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
Message-ID: <99c05ccc-5ce8-a192-ede8-40417a3f45dc@redhat.com>
Date: Wed, 17 Jul 2019 16:38:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717103208-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Wed, 17 Jul 2019 14:38:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 17.07.19 16:34, Michael S. Tsirkin wrote:
> On Wed, Jul 17, 2019 at 04:10:47PM +0200, David Hildenbrand wrote:
>> On 17.07.19 13:20, Michael S. Tsirkin wrote:
>>> Wei, others,
>>>
>>> ATM virtio_balloon_shrinker_scan will only get registered
>>> when deflate on oom feature bit is set.
>>>
>>> Not sure whether that's intentional.  Assuming it is:
>>>
>>> virtio_balloon_shrinker_scan will try to locate and free
>>> pages that are processed by host.
>>> The above seems broken in several ways:
>>> - count ignores the free page list completely
>>> - if free pages are being reported, pages freed
>>>   by shrinker will just get re-allocated again
>>
>> Trying to answer your questions (not sure if I fully understood what you
>> mean)
>>
>> virtio_balloon_shrinker_scan() will not be called due to inflation
>> requests (balloon_page_alloc()). It will be called whenever the system
>> is OOM, e.g., when starting a new application.
>>
>> I assume you were expecting the shrinker getting called due to
>> balloon_page_alloc(). however, that is not the case as we pass
>> "__GFP_NORETRY".
> 
> Right but it's possible we exhaust all memory, then
> someone else asks for a single page and that invokes
> the shrinker.

Yes, I think that can happen.

> 
>>
>> To test, something like:
>>
>> 1. Start a VM with
>>
>> -device virtio-balloon-pci,deflate-on-oom=true
>>
>> 2. Inflate the balloon, e.g.,
>>
>> QMP: balloon 1024
>> QMP: info balloon
>> -> 1024
>>
>> See how "MemTotal" in /proc/meminfo in the guest won't change
>>
>> 3. Run a workload that exhausts memory in the guest (OOM).
>>
>> See how the balloon was automatically deflated
>>
>> QMP: info balloon
>> -> Something bigger than 1024
>>
>>
>> Not sure if it is broken, last time I played with it, it worked, but
>> that was ~1-2 years ago.
>>
>> -- 
>>
>> Thanks,
>>
>> David / dhildenb
> 
> Sorry I was unclear.  The question was about
> VIRTIO_BALLOON_F_FREE_PAGE_HINT specifically.

Ah, I see. Never used both things together.

-- 

Thanks,

David / dhildenb

