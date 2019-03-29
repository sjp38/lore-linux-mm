Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9CF4DC43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:01:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D7402184D
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 09:01:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D7402184D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC3196B026A; Fri, 29 Mar 2019 05:01:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D736E6B026B; Fri, 29 Mar 2019 05:01:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C62F86B026C; Fri, 29 Mar 2019 05:01:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A010B6B026A
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 05:01:31 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id c67so1198743qkg.5
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 02:01:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=6fH1IuKmORJJq5IUd3STvtgXR5vuewmaZietV9iMZwg=;
        b=PGvaLxv7oLKdIAGUSYGcl3vD/Ahm7JdDv3HMKPJKMjBdKjS4DBoZDdDLNJMDhDQba/
         xhQ6iOGeP4IiTiZI2wJajkb2zvrC4ujNNR29J2W8d/nOhPokbvVltTZobilDAUMg2RVX
         eflOeMYdr0LLQ40dIrZh8V8HcCcMZnGNjWaZp5xPX32bku2aegh23Mgqpch6DhApsHUw
         7+5IRiVbLxyCsMS2AX3m5FmwFOTjjEkdAG2Acsa67LcOgPTyVOmdKlIjwWlbu3bZuJMA
         x5LEJz6UUUxA8X3kJAPyjKonnkis85VkurQhoMJJ/VgKXmPHT0I7jvc3mHgub+hX6RDc
         MyRg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWaeM18RoVG1qDGcOooPi8+JOCJa5poDDqKrN7158WFc6SSM1ha
	QRFdfYlADgHu5VxR2QudILPtjrJ1mAuIztSxv5S2s36Xh8i60vxUUkXxG412F7mpChz67jCG5EH
	5dxZAxRjuOLTI6G8v0LX1T0CipLKZLd+0i/M9ITMV+S8dJjKzXCV3HLQVkxFn6CRvKA==
X-Received: by 2002:a37:8505:: with SMTP id h5mr38317726qkd.66.1553850091428;
        Fri, 29 Mar 2019 02:01:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxL3qwnNYxotyaqkioWy3xGcEd+ewurP+ga5LABdjudNR+SxfXEJH+RIQ7x8TlwfeqGdqcG
X-Received: by 2002:a37:8505:: with SMTP id h5mr38317692qkd.66.1553850090813;
        Fri, 29 Mar 2019 02:01:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553850090; cv=none;
        d=google.com; s=arc-20160816;
        b=kVWZepztN/MXY9foCwi/lLwwm265GaQf2dtHbGdGJf/BfuMqv8tB1N6cCOsIRAUhyr
         EzK3vFCYl8U3kciluHe6ui56Ngab41asKeccB2At9e4ftv0i33+xQySWdzKz/BO24Fqq
         +l70QDVqcr9WXSIHz88oSRK40hz3YKc/7b4dcZgmELhMDT1bobN7fs2+ze4afWE6G39i
         81ZuCgfRuDe2yTx5KpRqn9thEO7cgEqFr2L2GRBgIOZXMBDtoW/kIG9JOJHZrW2qOZ27
         S+qaildd4gR7jUmOCXfGdpaNAXd7Y6D+HXexv/prRVycBMthVg7Nk5JGTt+Q/wunjPqZ
         ViUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp
         :references:cc:to:from:subject;
        bh=6fH1IuKmORJJq5IUd3STvtgXR5vuewmaZietV9iMZwg=;
        b=ZQYOK8CqO3U8KtuF4UotmMg/QtdIoehkkTJq7w4aKvrxf0zNGL3hOwGusqBFKOFSic
         qvVVm+xniUmPX1O8Hq3Lny4UITzBhr4Rgnt+yPOzAuGGAim2MU6oTAxAfhobSXqw8WOI
         7ENvWTEk4DPxcymYWurobLLu53UCdhcy69kz+xjdo/iab31Yno1olVObZSn83Qf8BPx8
         Ay4pZF+h4HMjs7ESPxtYaYotbJFkGhTiTJAOYXLhHA/vBooudYD+hU73YSRPX/U/h3RY
         C+RMA99hgHMb+UxW5NJ91R9pSQjqIBITcJ05mcFJWjYEobGVa9rv/iopFNhCLFo7jDfb
         XVgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 25si920123qts.195.2019.03.29.02.01.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 02:01:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id ED0F1308FC5E;
	Fri, 29 Mar 2019 09:01:29 +0000 (UTC)
Received: from [10.36.117.0] (unknown [10.36.117.0])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5ABD060851;
	Fri, 29 Mar 2019 09:01:27 +0000 (UTC)
Subject: Re: [PATCH 0/4] mm,memory_hotplug: allocate memmap from hotadded
 memory
From: David Hildenbrand <david@redhat.com>
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 Jonathan.Cameron@huawei.com, anshuman.khandual@arm.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190328134320.13232-1-osalvador@suse.de>
 <cc68ec6d-3ad2-a998-73dc-cb90f3563899@redhat.com>
 <efb08377-ca5d-4110-d7ae-04a0d61ac294@redhat.com>
 <20190329084547.5k37xjwvkgffwajo@d104.suse.de>
 <23dcfb4a-339b-dcaf-c037-331f82fdef5a@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <6c58b0ef-7a9a-491d-7286-7642f9d4c7bb@redhat.com>
Date: Fri, 29 Mar 2019 10:01:26 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <23dcfb4a-339b-dcaf-c037-331f82fdef5a@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 29 Mar 2019 09:01:30 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.03.19 09:56, David Hildenbrand wrote:
> On 29.03.19 09:45, Oscar Salvador wrote:
>> On Thu, Mar 28, 2019 at 04:31:44PM +0100, David Hildenbrand wrote:
>>> Correct me if I am wrong. I think I was confused - vmemmap data is still
>>> allocated *per memory block*, not for the whole added memory, correct?
>>
>> No, vmemap data is allocated per memory-resource added.
>> In case a DIMM, would be a DIMM, in case a qemu memory-device, would be that
>> memory-device.
>> That is counting that ACPI does not split the DIMM/memory-device in several memory
>> resources.
>> If that happens, then acpi_memory_enable_device() calls __add_memory for every
>> memory-resource, which means that the vmemmap data will be allocated per
>> memory-resource.
>> I did not see this happening though, and I am not sure under which circumstances
>> can happen (I have to study the ACPI code a bit more).
>>
>> The problem with allocating vmemmap data per memblock, is the fragmentation.
>> Let us say you do the following:
>>
>> * memblock granularity 128M
>>
>> (qemu) object_add memory-backend-ram,id=ram0,size=256M
>> (qemu) device_add pc-dimm,id=dimm0,memdev=ram0,node=1
>>
>> This will create two memblocks (2 sections), and if we allocate the vmemmap
>> data for each corresponding section within it section(memblock), you only get
>> 126M contiguous memory.
> 
> Oh okay, so actually the way I guessed it would be now.
> 
> While this makes totally sense, I'll have to look how it is currently
> handled, meaning if there is a change. I somewhat remembering that
> delayed struct pages initialization would initialize vmmap per section,
> not per memory resource.
> 
> But as I work on 10 things differently, my mind sometimes seems to
> forget stuff in order to replace it with random nonsense. Will look into
> the details to not have to ask too many dumb questions.

s/differently/concurrently/

See, nonsense ;)

-- 

Thanks,

David / dhildenb

