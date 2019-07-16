Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6CE7AC7618F
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 14:17:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B54D20693
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 14:17:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B54D20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2ECA6B000A; Tue, 16 Jul 2019 10:17:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB8988E0003; Tue, 16 Jul 2019 10:17:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 930A58E0001; Tue, 16 Jul 2019 10:17:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6E56B000A
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 10:17:26 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id k13so17027422qkj.4
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 07:17:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=6kccRFc4PeFOiUHBCyI6dRc2JO7B15Tf2KUoAPAYMEU=;
        b=bAMR8LEAvo432BaQCe/AOYVJFTFrzMZ2zU5LOsLysELLEKts//EVuN0x+0jmVeSxC8
         w/UzhYHtp8VIL0PEqhxpqSNe4VAa15SX4oJfboDEEEzT87bZyePst0ZilbdL5U4CJozp
         y2xEX5N0TFyQThOl+0mZE0f+0YVjwLErIxUPquF8VIdCXesxLKm0Mmva3T0V99yuBuIr
         iOzAlRJNVhRMbVjnLeaEtC+4g+096rG2x1v9u8SG1npdwwZgeHxlKix1WhGFRNhBVK86
         h3IyG/TReXRLf9AK0XVPwsHvBHaGdVNRTXOQwUn286LS511y0FRhlScFjhCAKZWwpg/j
         3ZYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXzDAnY2+47oL+CIBFtNAJpQ1zSVc0OMVK8g8CrLV99YQMGT3HH
	IFoccFIqxxEYaKmM96rcIvi6lLcmM/91D3781kk8XVj/Vjv9hpZQzKdpy26BPoxw5rrZ6D5S/m3
	b7HVcyJQ7L6mhxU45Y6hIhPWqsD2k8HNkkrsgtZztPSjbWILG6tW4i7hxOAK8mmDL+Q==
X-Received: by 2002:a05:620a:1387:: with SMTP id k7mr21734976qki.129.1563286646235;
        Tue, 16 Jul 2019 07:17:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1d3XoXaUED2ojoUzrn/eNZW49eCc7jPAU0GIsSjE/iG5W3D3S7fXmvf6yVSF0elSx49iW
X-Received: by 2002:a05:620a:1387:: with SMTP id k7mr21734928qki.129.1563286645785;
        Tue, 16 Jul 2019 07:17:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563286645; cv=none;
        d=google.com; s=arc-20160816;
        b=CKPql0D+oGtjveb1i2Epo07jUH6nH4rb/4i2zr07Df9q05NC1+TJnElwWuenI/yS8q
         dT5saQ6RAYdqccGyTEa3FDbW2ttMSeMe2fimThzZzzH5YKcxxHaUgMcF8orPvgQYBT6b
         JbCJhgqyg1Bc6vwMUgZX88ddCR82r+emH94neGaatg8vjoF+L5z+V/vAm22/JNp5mvSf
         9/l+rqy6VLgfXAU3uey2LoQ5a4SvwxOrDX1QH2viJC6oDpQ7c9ULYAnShDlSH4bnIWPZ
         +396D5touXZIDQP1BV5twb2qI9LcdO/4baOzKb9bNdQdUAA+ZH21Fdi9eYbNAcASJf6d
         nVWA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=6kccRFc4PeFOiUHBCyI6dRc2JO7B15Tf2KUoAPAYMEU=;
        b=yuygIEF3RzdPkjrGB3NAzHVuErvp8dHtmWvXs/ZFcSFkbPnSPPAKtCdJqfW5ch3aIo
         F5IR/VM398F+OY9O6iFVRMdUuKGBHapw1X0IIp08qm8YyWQkGrt3lsi15iwQC7Vr0dkM
         a0ChjOfGd3MOpHV5HFSSSI46HCdxDsTCN4Bf03bLtyv7YiN6bLAS+DV2OnzssbCcRXND
         bbcS8cS1K7l8bhgyFh3eKwWV4Log+r38ZmPUbbpRhgeN8ic4RDwARflTz/fY/Tet4j/i
         bXKukDNEz/pZv1ZXytEeUabvw3TAuSucac90jKZRGCegLa0FwcT+V2hf2b8PJsxTooup
         8Iow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k53si14711943qta.47.2019.07.16.07.17.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 07:17:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E9AE0882EA;
	Tue, 16 Jul 2019 14:17:24 +0000 (UTC)
Received: from [10.36.116.218] (ovpn-116-218.ams2.redhat.com [10.36.116.218])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A3DB6611DE;
	Tue, 16 Jul 2019 14:17:14 +0000 (UTC)
Subject: Re: [PATCH v1 6/6] virtio-balloon: Add support for aerating memory
 via hinting
From: David Hildenbrand <david@redhat.com>
To: Dave Hansen <dave.hansen@intel.com>, "Michael S. Tsirkin"
 <mst@redhat.com>, Alexander Duyck <alexander.duyck@gmail.com>
Cc: nitesh@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
 pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
 lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
 pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223338.1231.52537.stgit@localhost.localdomain>
 <20190716055017-mutt-send-email-mst@kernel.org>
 <cad839c0-bbe6-b065-ac32-f32c117cf07e@intel.com>
 <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
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
Message-ID: <e565859c-d41a-e3b8-fd50-4537b50b95fb@redhat.com>
Date: Tue, 16 Jul 2019 16:17:13 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <3f8b2a76-b2ce-fb73-13d4-22a33fc1eb17@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 16 Jul 2019 14:17:25 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 16.07.19 16:12, David Hildenbrand wrote:
> On 16.07.19 16:00, Dave Hansen wrote:
>> On 7/16/19 2:55 AM, Michael S. Tsirkin wrote:
>>> The approach here is very close to what on-demand hinting that is
>>> already upstream does.
>>
>> Are you referring to the s390 (and powerpc) stuff that is hidden behind
>> arch_free_page()?
>>
> 
> I assume Michael meant "free page reporting".
> 

(https://lwn.net/Articles/759413/)

-- 

Thanks,

David / dhildenb

