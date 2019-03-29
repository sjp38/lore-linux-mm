Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A5CBC10F05
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:51:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 040522183E
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 08:51:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 040522183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95F7F6B000E; Fri, 29 Mar 2019 04:51:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90D806B0010; Fri, 29 Mar 2019 04:51:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7AEAE6B0266; Fri, 29 Mar 2019 04:51:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55F816B000E
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 04:51:34 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id c67so1181334qkg.5
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 01:51:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Bpq17pQq9SN8JFSiQjJEi3b64Bvu0P79QnrD83WeoiI=;
        b=jDj9L3DXUjiRbuNdWPwIP7irDxApx0U860gFVjOuVt0y3lGF2zTQ/c+fRF0gZ3CjwN
         zR8xYvi1AAUon/d1A4Xpi5bGh02qLnWpU64rUqdf3DYma6Ww/aLx/v75UHwnJ2SB7La2
         jMKu7OIJZQBqNeYa2YfvXbIFuBSQSgpAiLW4XjyIY/UgA7pPBYYM8U/Wb2P/rsaeWsdt
         3uT9PnfFg94dJttilYO7tE2CgcQyIqsN5BvZFnZjR3J+VMcj8M6CEqKBFn8V001YSTPX
         VjP1b1tjipyvgToWbmgZwBurWsTFeAVglnVx9Rcu2UiJqtBAo3i0SU+mpNaBuWOoaYFs
         AuRw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX8yE0Becy7McmZBl4jCMDNknLpqrV1d1keJDMd41Pi00okW4sc
	zUrYq///swhuFconi4iJCLY0cVMHcN5A4r3RJu7edVfTfXi6qvdmkQ7yhhF4suzWZ8it1erFa3Q
	jBYdfc/dKYCpGQrnN2OfCLz4Lr6gqveX7+9xYmMT/sYKj3E1p5BbrZnVYIu203Ee87w==
X-Received: by 2002:a37:650c:: with SMTP id z12mr38102479qkb.115.1553849494052;
        Fri, 29 Mar 2019 01:51:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyfat/jBb5MnN+4KXEztd3AjIKtXj3sPcnFsI8Fln8WJqr4NIZHxnYfrGKojga1CWOEwqf
X-Received: by 2002:a37:650c:: with SMTP id z12mr38102449qkb.115.1553849493247;
        Fri, 29 Mar 2019 01:51:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553849493; cv=none;
        d=google.com; s=arc-20160816;
        b=DD+KZEUijf7rqoTM587o4ISznfy1LJRndHW5e0Xxf9eoGi7p19Jck1bOei90KP+0sC
         d3/YglUGnE/yXRYaIQ6vci3N57uVBl978RPMjX8YxF2xJ+ftGLEOW+VtxKYLx9YQRePc
         I3onqYCZ3bVlAQAypXcINl8uzZTRAmWZltRlF1IU7i6l2SeTzerzji8t4vmJ6FloTfJS
         +9GMNRwIIFZ7mGQbl+ZSQ9yPSIlJ3Cx4Sp6MTEA0VTxWcpIjvhisWjTlt7nTaKRcfFtZ
         b3AsCeTmm268ceuDNFbOzjJ1UR4TISXfTOBkFo8SV0/EpYef68mq85iUGYzRxlvkhrgZ
         JeNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Bpq17pQq9SN8JFSiQjJEi3b64Bvu0P79QnrD83WeoiI=;
        b=x1NEQTMRz06lI5x7l80uohSCzd9NFcdwNzAMEfcsL3U3pAuRbqWin0WQZFueOjDgi2
         NvDK9NYbfui3CyXVMKad/nOxWOssPQu2fvAlCcspJ+CsM42/SgkOkkl4nemjAASCwsIl
         WHts1obQHpym51WU/Dk22zCqcWdfUsaS+w6E4yWm9Ef42wwUGKIV/NgbSeAnrNl/68/c
         4smzZUUxAmMRjP55QEHAkE0ZRj4VDOphVKNOYudvIjpUbTOnqDy+A0GnZKOoWyq6uj/X
         Q2la5dMo+x/Wm0+kaZbCsVnXXskEZ8Tw4HTYa5M3W5tltQsdu1KnOWQ8JGUfEah13kPj
         aniQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h51si915132qth.340.2019.03.29.01.51.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 01:51:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0DD1230238FE;
	Fri, 29 Mar 2019 08:51:32 +0000 (UTC)
Received: from [10.36.117.0] (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3492561B7A;
	Fri, 29 Mar 2019 08:51:30 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <20190329083006.j7j54nq6pdiffe7v@d104.suse.de>
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
Message-ID: <e9f3013a-bee2-159b-02ca-fc9546d525f2@redhat.com>
Date: Fri, 29 Mar 2019 09:51:29 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190329083006.j7j54nq6pdiffe7v@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 29 Mar 2019 08:51:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


> Great, I would like to see how this works there :-).
> 
>> I guess one important thing to mention is that it is no longer possible
>> to remove memory in a different granularity it was added. I slightly
>> remember that ACPI code sometimes "reuses" parts of already added
>> memory. We would have to validate that this can indeed not be an issue.
>>
>> drivers/acpi/acpi_memhotplug.c:
>>
>> result = __add_memory(node, info->start_addr, info->length);
>> if (result && result != -EEXIST)
>> 	continue;
>>
>> What would happen when removing this dimm (->remove_memory())
> 
> Yeah, I see the point.
> Well, we are safe here because the vmemmap data is being allocated in
> every call to __add_memory/add_memory/add_memory_resource.
> 
> E.g:
> 
> * Being memblock granularity 128M
> 
> # object_add memory-backend-ram,id=ram0,size=256M
> # device_add pc-dimm,id=dimm0,memdev=ram0,node=1

So, this should result in one __add_memory() call with 256MB, creating
two memory block devices (128MB). I *assume* (haven't looked at the
details yet, sorry), that you will allocate vmmap for (and on!) each of
these two 128MB sections/memblocks, correct?

> 
> I am not sure how ACPI gets to split the DIMM in memory resources
> (aka mem_device->res_list), but it does not really matter.
> For each mem_device->res_list item, we will make a call to __add_memory,
> which will allocate the vmemmap data for __that__ item, we do not care
> about the others.
> 
> And when removing the DIMM, acpi_memory_remove_memory will make a call to
> __remove_memory() for each mem_device->res_list item, and that will take
> care of free up the vmemmap data.

Ah okay, that makes sense.

> 
> Now, with all my tests, ACPI always considered a DIMM a single memory resource,
> but maybe under different circumstances it gets to split it in different mem
> resources.
> But it does not really matter, as vmemmap data is being created and isolated in
> every call to __add_memory.

Yes, as long as the calls to add_memory matches remove_memory, we are
totally fine. I am wondering if that could not be the case. A simplified
example:

A DIMM overlaps with some other system ram, as detected and added during
boot. When detecting the dimm, __add_memory() returns -EEXIST.

Now, wehn unplugging the dimm, we call remove_memory(), but only remove
the DIMM part. I wonder how/if something like that can happen and how
the system would react.

I guess I'll have to do some more ACPI code reading to find out how this
-EEXIST case can come to life.

> 
>> Also have a look at
>>
>> arch/powerpc/platforms/powernv/memtrace.c
>>
>> I consider it evil code. It will simply try to offline+unplug *some*
>> memory it finds in *some granularity*. Not sure if this might be
>> problematic-
> 
> Heh, memtrace from powerpc ^^, I saw some oddities coming from there, but
> with my code though because I did not get to test that in concret.
> But I am interested to see if it can trigger something, so I will be testing
> that the next days.
> 
>> Would there be any "safety net" for adding/removing memory in different
>> granularities?
> 
> Uhm, I do not think we need it, or at least I cannot think of a case where this
> could cause trouble with the current design.
> Can you think of any? 

Nope, as long as it works (especially no change to what we had before),
no safety net needed :)


I was just curious if

add_memory() followed by remove_memory() used to work before and if you
patches might change that behavior.

Thanks! Will try to look into the details soon!

> 
> Thanks David ;-)
> 


-- 

Thanks,

David / dhildenb

