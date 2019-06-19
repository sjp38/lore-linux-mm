Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 276B2C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:11:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D0F3320B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:11:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D0F3320B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AA356B0003; Wed, 19 Jun 2019 05:11:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 681C38E0002; Wed, 19 Jun 2019 05:11:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 570388E0001; Wed, 19 Jun 2019 05:11:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3375D6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:11:23 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id j128so14827041qkd.23
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:11:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=x1429AKvgwNIHkQWgJ5BcpNvBwHVnm59/gIYqZPftbs=;
        b=IzW5h3u+UVPIlRZfoXE3CyxDy6psMob0ZGE+kpvn5fhEsmZDp8RaL3IoQBFTknLbLc
         kvPUBVMM9rS4B1aGoJ/b6zbeUg/q3oKnkmFYy/KHuhgF42pN1jRO3GoZJjLMw72kTRd+
         u5b+VySBk2XKXrAIZesHSv7+Cp0nEcTThVCyKVd6Sq33CaMiucT/hYV7sj/Urc5rdgGL
         PQITEUK+QWWNaB9BNux4uKgT4UWlTT0DP12F/CgCOaCkfdocx4IKrcRhaLZvKxOQEhwQ
         0ewrbvs/T+5Sz00ThDO8VEjuS/MZWHwPAswA24Iz1uwi7f9jLwe2/1rp5FCwtq1q6j94
         jP3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUZvFjQWJC9oKLzN08etyNtuLcgBtw6/IicJYFJAMWm+PHFrq6Z
	BRmnCsc58ObsP8QBhA2YWHkj88fv+PJUgj01NHpeXB5GZLE7JikGu00JITnK6mDjRrapdhHXusa
	TcbJHl5iINnZ92a7vLaj1UNB8vgx2Ly7v8BO+lyvNCUyjdnMduKow4DqoOrXlIzr4BA==
X-Received: by 2002:aed:2336:: with SMTP id h51mr48996344qtc.125.1560935483017;
        Wed, 19 Jun 2019 02:11:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx5uxhYNKPX3DNjJGiMTOpqRakyofbt1znpd+R3r01nCKGVt9wyN+gSKiw049EWObvgSwE+
X-Received: by 2002:aed:2336:: with SMTP id h51mr48996319qtc.125.1560935482626;
        Wed, 19 Jun 2019 02:11:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560935482; cv=none;
        d=google.com; s=arc-20160816;
        b=lCI7hfFEEsDUa2FDbGZV3GEfdorxbJ5Y7Qxr9Ay7eC72SgQ26uGoshJagwaBhPzqZN
         R895kxqmD3TiDt3OAgJiycWWo57S+CHC3Eva2uQdwkxh8TWu6q1u+TZ4YgP8PZEhdE7T
         ceFzywlFm4uXg7JysSI77h6ile7UySd6hgIl4z3UqF9Bb8Tm8UX6elXfSdbjN0S0Y1Q1
         Mla1uuAc8LsA64UX3N9xbbEcFTDpiARYKeTPDytnwr402pWBj88IEbRf1cUfSIe2qQG0
         x6w/XGoNavK8c+eQfsgd344Grt5pQqklvXIWb0GRtjJaGQca5sxDN3OMdAxHzf44LOCz
         32+w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=x1429AKvgwNIHkQWgJ5BcpNvBwHVnm59/gIYqZPftbs=;
        b=sz4K4x4Yw1aOOWYoAHOBMnM/ZzNtShGhx1bCVL8N2iPAxEtfgj4BRiFqTYh9AVJvPW
         vwgzTa0XLJJYPpmDok6tGVryd6lkyhK47/VrHxncGYwT9e5OgJNZ53SMwyktCVj/e5BE
         IUJBvbJCU1hPTF8fkRZcsnJyl6Afo40seAjNKDm78lUwazJG12StKYnIz82msZfZRycT
         cNrzJPrNYt7H5JriI69alvuhn2rQJrW/vBUGhp8DZGpcAlIEKvOeBSVmjm1tQtLO3eTk
         JY5mCzGwh4752f2yB7EUxgANowKd1B2nBQxQNw4wefnPjWgVv1+wLjm21QBSQlO3famu
         N+bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i5si11113724qvv.2.2019.06.19.02.11.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:11:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B19AB10C94;
	Wed, 19 Jun 2019 09:11:16 +0000 (UTC)
Received: from [10.36.117.229] (ovpn-117-229.ams2.redhat.com [10.36.117.229])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4679910190A9;
	Wed, 19 Jun 2019 09:11:12 +0000 (UTC)
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
To: Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richardw.yang@linux.intel.com>,
 Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
 akpm@linux-foundation.org, anshuman.khandual@arm.com
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190618074900.GA10030@linux> <20190618083212.GA24738@richard>
 <93d7ea6c-135e-7f12-9d75-b3657862dea0@redhat.com>
 <20190619061025.GA5717@dhcp22.suse.cz>
 <aaa9d3af-0472-ffde-a565-fe6a067a4c49@redhat.com>
 <20190619090126.GI2968@dhcp22.suse.cz>
 <5630056e-cc60-c451-714b-f8524eb70839@redhat.com>
 <20190619090824.GK2968@dhcp22.suse.cz>
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
Message-ID: <40817af2-992e-adb6-3053-fc8f570050a4@redhat.com>
Date: Wed, 19 Jun 2019 11:11:12 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190619090824.GK2968@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Wed, 19 Jun 2019 09:11:16 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.06.19 11:08, Michal Hocko wrote:
> On Wed 19-06-19 11:03:49, David Hildenbrand wrote:
>> On 19.06.19 11:01, Michal Hocko wrote:
> [...]
>>> And if they do need a smaller granularity to describe their
>>> memory topology then we need a different user API rather the fiddle with
>>> implementation details I would argue.
>>>
>>
>> It is not about supporting it, it is about properly blocking it.
> 
> We already do that in test_pages_in_a_zone, right? Albeit in
> MAX_ORDER_NR_PAGES granularity.
> 

Indeed, thanks for pointing that out. I knew that we were checking zones
but had in my head that it was working on zone idx.

-- 

Thanks,

David / dhildenb

