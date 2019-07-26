Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59B08C7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:06:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 174F32166E
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 08:06:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 174F32166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0728C6B0008; Fri, 26 Jul 2019 04:06:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 023DC8E0003; Fri, 26 Jul 2019 04:06:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E04E18E0002; Fri, 26 Jul 2019 04:06:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id C0C4F6B0008
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 04:06:02 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id l9so46617517qtu.12
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 01:06:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=psJGpmGrj6l0W1Dy3j7QlpBxhrkQrlKVevSHH0DIDq0=;
        b=eJSEZqmTbZl/4mMYcq91ErCpHDByNNB6fEXBf/qNpM/3CqEgqBZSRpVwurpO5QBsf4
         M1E1CvssA1ZNQRn9atpC8IE1L4aSvJS72s2xd5xNCeJr+7IcOW4ErrcwpZv4DBEwebV2
         jKcdD04b4srFVJnDDnN3Ld04ud612ioyZGLtynDjSY6YtqSArM/AnruzVUqNuod/Ei+W
         EKX2QKFysl4iLFugI/8LvXCpWoBlcOkewUtPCDuf3iRjSEWLLZ6mbJpMJJLFJ3m567jS
         qFMs6Z4YsVPPIcVHx+j2DWJOqy04fGXAX1IjT+HZTVHToanCEYsjh/7F4SE2xBSYKRH9
         KEVw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUMX1/VQYwf/qAjgHLBzyMXvULfL+B5CkPci+4l31towc4xEHBK
	MH/5uA4OtVo499wcGqcksFD+Ng0K3BO+S/b5FMYgtBjMCZ48Js2nTRDzIUCFz3YbTQoi6TDtS+H
	NdohaK/zufmgSqOwKorICUd9vXVE7U7rm5PwCQaXHwwyRLRBiKeg5sf2IdNAP93d9zQ==
X-Received: by 2002:a05:6214:601:: with SMTP id z1mr49605693qvw.197.1564128362528;
        Fri, 26 Jul 2019 01:06:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw8X2igYPvqh/lvDD703mjlb2+BH0LpSZUhEqM8L2pZ6Hz5q1tMAd1drq4IB3k4ehEu13yW
X-Received: by 2002:a05:6214:601:: with SMTP id z1mr49605655qvw.197.1564128361953;
        Fri, 26 Jul 2019 01:06:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564128361; cv=none;
        d=google.com; s=arc-20160816;
        b=L4Mh+fszMMK+65CAHiUgV842KHLXaKB5MvKN78N4e4Kaccq1K+HfIsPvKkxm3m2U4j
         3Tln1dqHB5rppoUMMNhi6NEMoRI6U1x6e3HmxUAEOtmsjSXmuz1+7hHlzr8A4vHHsdEo
         HUF9ul6/Eg9K7eLB713XZFBqQGth7BALUJS5XSxc3Bpuev4q/ZIO2iDTHzRfskUsCeUr
         1nlJZdmxVJdeew+lonF8jbYk2rLmsd1TLqFcfG9g44T2lF3GU+/IySiEeKz9IXRsqS39
         4rN1mHaBDs8+ti3nds9MJ7gBPNHkegTaRYwUJNAFwDJCCIY5aa7cQP22Rv7uq5s7W3Vc
         FSpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=psJGpmGrj6l0W1Dy3j7QlpBxhrkQrlKVevSHH0DIDq0=;
        b=q8fmMdVAvYV/UheYpJyxo15BJOQ7vJcZ9XMaJKSA1EGIIoWhskPqYe4YnRYTn0tNBD
         suPlTK9XmWfhdRSZuKdyCb4DIjSW7g9EBDBuRFWqSyHVmt2cQ2bw2uVUej5IfgaMGk7x
         xSE3X0f56hF1IXpfcYl4YzY0z1t2we6qs/5NdFRwBQimj350HdZZAiI9kOQFciAMm1Ve
         Ht9ikT4HRfBeApQ0djtvrJMxOLkqnY9UhyOpg9Daw3oBUFRr8LoRaJtQqhUjEfBAQbbn
         x/bvTjP9WteC+EeNlivueyG6sPdHThOTMLx1ZkMgxkMFJAN36EMVaIreKydAbuWW2IPb
         HVFA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g50si34682664qtk.197.2019.07.26.01.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 01:06:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 092993082E0F;
	Fri, 26 Jul 2019 08:06:01 +0000 (UTC)
Received: from [10.36.116.244] (ovpn-116-244.ams2.redhat.com [10.36.116.244])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7A0FE51;
	Fri, 26 Jul 2019 08:05:59 +0000 (UTC)
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-acpi@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>
References: <20190724143017.12841-1-david@redhat.com>
 <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
 <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
 <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
 <20190726075729.GG6142@dhcp22.suse.cz>
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
Message-ID: <fd9e8495-1a93-ac47-442f-081d392ed09b@redhat.com>
Date: Fri, 26 Jul 2019 10:05:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190726075729.GG6142@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Fri, 26 Jul 2019 08:06:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.07.19 09:57, Michal Hocko wrote:
> On Thu 25-07-19 22:49:36, David Hildenbrand wrote:
>> On 25.07.19 21:19, Michal Hocko wrote:
> [...]
>>> We need to rationalize the locking here, not to add more hacks.
>>
>> No, sorry. The real hack is calling a function that is *documented* to
>> be called under lock without it. That is an optimization for a special
>> case. That is the black magic in the code.
> 
> OK, let me ask differently. What does the device_hotplug_lock actually
> protects from in the add_memory path? (Which data structures)
> 
> This function is meant to be used when struct pages and node/zone data
> structures should be updated. Why should we even care about some device
> concept here? This should all be handled a layer up. Not all memory will
> have user space API to control online/offline state.

Via add_memory()/__add_memory() we create memory block devices for all
memory. So all memory we create via this function (IOW, hotplug) will
have user space APIs.

Sorry, I can't follow what you are saying here - are you confusing the
function we are talking about with arch_add_memory() ? (where I pulled
out the creation of memory block devices)

-- 

Thanks,

David / dhildenb

