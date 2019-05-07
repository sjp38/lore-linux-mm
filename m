Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82B4EC04AAD
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:13:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FF96206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:13:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FF96206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3B2A6B0007; Tue,  7 May 2019 17:13:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AEBCE6B0008; Tue,  7 May 2019 17:13:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98CFF6B026B; Tue,  7 May 2019 17:13:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7261D6B0007
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:13:28 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id s32so20720329qts.8
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:13:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=VHZaOmOPhP1H4j7Rq90bzVYWfM8XjP5MBIYwbKtWRto=;
        b=S/fe2CR2E+aEWg+qkkSWxI503RVR6EqI5XIgc0Xrn3U/6eBsHLr91ssaURrWaxeM1h
         yBqWO3cbPSXn/8d4an7P8ie6igiYopeS5Ek7Vm++LCD3NS+3qhxwBACM5AvUeKtc9UiV
         qLv42RoJikSvlvfo/woB9/qnNUwGnYUzHsxn+j16kcMVN+U5HMxELSwx9AHWlqrJOzlH
         U/f6qDk2MWNTV73n8X2zsNubwLoKCFruFiL0FpY9kdz8AOj0PS5JVguVcO+5NxYq5kFE
         gxCPwpjM1NUJ/jyDYnIa+3AvUaMhknCkcTgDy8vb6hqnHn6zeVjUD/W6dpqqCrYpuRPz
         Myyg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVe3SCK78qnXb1Z0BudWYhEjz8iT2GBhBUrVYhHL+o3LwOmmXpD
	9IF8uCtISOKj257M/28qqhssiNZ2Hs/0ypI+i8uvQ1SrfzpOL8iJXN2gfnL+EB8OQY+Jx0ZC30l
	pShZQKQHKQtfs2KF09dIwWKzkP+ryt3M+d88JKkhr20LwyysQb4UZoxzsKq2JGl53cQ==
X-Received: by 2002:a37:4854:: with SMTP id v81mr27568618qka.333.1557263608231;
        Tue, 07 May 2019 14:13:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzz4U7/ZMxe1BcdiAvIbuw75vzTnMW0syLZzZvzwP/JNx35xqeNiHA8X8eJbRYSarZ2Esz2
X-Received: by 2002:a37:4854:: with SMTP id v81mr27568581qka.333.1557263607601;
        Tue, 07 May 2019 14:13:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557263607; cv=none;
        d=google.com; s=arc-20160816;
        b=Pp9r0AfYIQI72PWLlQN1dKFZ5ioxl4SPUqSptt4GQWBPKLL35zYnR/CgawxpSO08iF
         N8Ze3z7MlJVO7WhLWilNS128C+pDVoBX5W4IhCAut6SlDV/aMb53HtxStPJAw8Q5zDuH
         XIwLMW/xRiyBpEJrsMmX+jFh4ZI/pKnuHRnx74QcK0OxwagYBojLY7Z5ywUSFbjU5UZw
         2S3fAaZuEoDeSeOCr2RHOk1BySBMaWb57zJXf+gGWtyf9raegxXwef4Q+0fPDSKK71I8
         ri847cBsP97LgDL2vqtZ9x+fJCAvqCWQzotyguyTBdz2IkbKqqHUz7plHx8y5UDyxiQC
         E9dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=VHZaOmOPhP1H4j7Rq90bzVYWfM8XjP5MBIYwbKtWRto=;
        b=s8LAx/QTylzupddGVKe3v55ioY9yGjsViM4qPfwe1S+B5h56/ZuZSEWFQuK2voJwDe
         EHWhYtCMHoSk35SCh88vl3wundbACzpdqLhrP7cFBytZKXX15lBIAlhFyxnUzui/fs1q
         kXZiuoyxzQwQZb5Kym+wsNS8Ehk9/iCVr1zRpTO/1JHWCNJ8ZqJNcQCLvedIyOxrauSf
         NWlc3NVclgiFLPi/3h+B1CZO8upt/2B6b51Z1uyfqWS76h5k69j8my+Nj7NFbQTqSnDI
         0RtiWBiZLPEp/XzN9hdTGq9uA5SPIcTw7wSsvV+hdY+lX0pqaJ8HT3nMrAd4+OwLXRhV
         xSjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l1si1982631qvc.102.2019.05.07.14.13.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 14:13:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 866CA300271F;
	Tue,  7 May 2019 21:13:26 +0000 (UTC)
Received: from [10.36.116.95] (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CF61E60139;
	Tue,  7 May 2019 21:13:23 +0000 (UTC)
Subject: Re: [PATCH v2 2/8] s390x/mm: Implement arch_remove_memory()
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>, Michal Hocko <mhocko@suse.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>,
 Oscar Salvador <osalvador@suse.com>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-3-david@redhat.com>
 <CAPcyv4gtAMn2mDz0s1GRTJ52MeTK3jJYLQne6MiEx_ipPFUsmA@mail.gmail.com>
 <97a6a2ab-0e8b-d403-ca39-ffa4425e15a5@redhat.com>
 <CAPcyv4hvpBo=6c6pFCoGiEf3xiPsjc8w2p4Y6_bW4PrzcN=Few@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <942f4952-b8bf-86fb-fd10-4fd5519198aa@redhat.com>
Date: Tue, 7 May 2019 23:13:22 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hvpBo=6c6pFCoGiEf3xiPsjc8w2p4Y6_bW4PrzcN=Few@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 07 May 2019 21:13:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07.05.19 22:57, Dan Williams wrote:
> On Tue, May 7, 2019 at 1:47 PM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 07.05.19 22:46, Dan Williams wrote:
>>> On Tue, May 7, 2019 at 11:38 AM David Hildenbrand <david@redhat.com> wrote:
>>>>
>>>> Will come in handy when wanting to handle errors after
>>>> arch_add_memory().
>>>>
>>>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>>> Cc: David Hildenbrand <david@redhat.com>
>>>> Cc: Vasily Gorbik <gor@linux.ibm.com>
>>>> Cc: Oscar Salvador <osalvador@suse.com>
>>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>>> ---
>>>>  arch/s390/mm/init.c | 13 +++++++------
>>>>  1 file changed, 7 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
>>>> index 31b1071315d7..1e0cbae69f12 100644
>>>> --- a/arch/s390/mm/init.c
>>>> +++ b/arch/s390/mm/init.c
>>>> @@ -237,12 +237,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
>>>>  void arch_remove_memory(int nid, u64 start, u64 size,
>>>>                         struct vmem_altmap *altmap)
>>>>  {
>>>> -       /*
>>>> -        * There is no hardware or firmware interface which could trigger a
>>>> -        * hot memory remove on s390. So there is nothing that needs to be
>>>> -        * implemented.
>>>> -        */
>>>> -       BUG();
>>>> +       unsigned long start_pfn = start >> PAGE_SHIFT;
>>>> +       unsigned long nr_pages = size >> PAGE_SHIFT;
>>>> +       struct zone *zone;
>>>> +
>>>> +       zone = page_zone(pfn_to_page(start_pfn));
>>>
>>> Does s390 actually support passing in an altmap? If 'yes', I think it
>>> also needs the vmem_altmap_offset() fixup like x86-64:
>>>
>>>         /* With altmap the first mapped page is offset from @start */
>>>         if (altmap)
>>>                 page += vmem_altmap_offset(altmap);
>>>
>>> ...but I suspect it does not support altmap since
>>> arch/s390/mm/vmem.c::vmemmap_populate() does not arrange for 'struct
>>> page' capacity to be allocated out of an altmap defined page pool.
>>>
>>> I think it would be enough to disallow any arch_add_memory() on s390
>>> where @altmap is non-NULL. At least until s390 gains ZONE_DEVICE
>>> support and can enable the pmem use case.
>>>
>>
>> As far as I know, it doesn't yet, however I guess this could change once
>> virtio-pmem is supported?
> 
> I would expect and request virtio-pmem remain a non-starter on s390
> until s390 gains ZONE_DEVICE support. As it stands virtio-pmem is just
> another flavor of the general pmem driver and the pmem driver
> currently only exports ZONE_DEVICE pfns tagged by the PTE_DEVMAP
> pte-flag and PFN_DEV+PFN_MAP pfn_t-flags.

Yes, I think ZONE_DEVICE will be the way to go. On real HW, there will
never be anything mapped into the physical address space besides system
ram. However with virtio-pmem in virtual environments, we have the
option to change that.

-- 

Thanks,

David / dhildenb

