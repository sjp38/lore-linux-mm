Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53905C76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:45:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 177282064B
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 10:45:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 177282064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 926D06B000A; Mon, 15 Jul 2019 06:45:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D7B26B000C; Mon, 15 Jul 2019 06:45:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 79F0E6B000D; Mon, 15 Jul 2019 06:45:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56A0C6B000A
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:45:58 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e32so14408015qtc.7
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 03:45:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=3204zFXkuISO8j1jSjFIAEtTlRGZa+CiI7q3cRXUaw4=;
        b=aE2Pc3Zg+h7O6ZEaoOeMIschiKzTQLFvY5TdQ5R+1nGMEE20NpzAJn1uhA4ovoGdj4
         vpDBTUCfaal0ezDYvyh4dLCePExnik95GkqwAi/BRewZyQHNYLMAzrL2697tZGgxJlNx
         tw66eZbz5quQ2FhpNqpiV45YhlmKHZZPGztjBGP8ZeEj65ZXyFGOkzxnmYlOElovygV9
         YRCxuy0SIiNQBo7nBnJ5WYqMV6VfaXkqp9xogu5e/eveaXDW2rIT2B3+U4I0pst73gk2
         701r2mRFCs39fyOhhcHNrh7gtmQ6W9maXrwMaHxG+Cz+84qzPHn/K8VE7mwfS6auPDh6
         IZeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVtymSxpMTZyIw22Hnhk3yhT8lppud1Z5QOVv2F5dFKkEodUg1X
	L+jAvUHE0mJnDpNDBw18JD4FNLQEVCUXZvDpFbXZnkr7kMhLmOFqphFbc4sHBmzqP+PB57lQ8bK
	DNBMIbiCGdzh9auKJlRZElEYL7D86DxO4zuCk8FpItN/Ln0MrZbyq0EfDVdpQNXN7xQ==
X-Received: by 2002:a37:b045:: with SMTP id z66mr15939771qke.501.1563187558130;
        Mon, 15 Jul 2019 03:45:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbC5mT1pEYIuvLstTPB0KAeTxt8Qw334/CU6O1/ljo3w9IQukV0bCOdSWHtm3Whtfy/fGd
X-Received: by 2002:a37:b045:: with SMTP id z66mr15939736qke.501.1563187557527;
        Mon, 15 Jul 2019 03:45:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563187557; cv=none;
        d=google.com; s=arc-20160816;
        b=Gwk2rwo3zFj14gXEHaCRxqfrSdokxkGrnviw1DvU7VZ9tsqePUtfYj6KoLXxReWbDJ
         ZI6eu1N5T31Gzou5wONsL29X1Ur5NNwJDVzi9WAfieXKwR+01p5by+qS6bOWYMYX1DxP
         7qakD2b2TQRGy6dD39TxjcMWUXegimjSY6myPswJy43FUWZ+ND4egYOwKl50JGFivHHh
         BAl6MZ1MScsF+r+/FxjU4YhAQMto1zE83DdFLUSufsp1G/Lk4cY0GOIsN8fYthO1iL3q
         9Hle/8FxHyYdH85546X3UWB9i35LajnCPqsK+5ye7UOlc0H0QhrxZeHwoXtYb4KRKQIq
         Ui/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=3204zFXkuISO8j1jSjFIAEtTlRGZa+CiI7q3cRXUaw4=;
        b=qQPeqJwgWvQUzxsx0ezQYp6/zWBVm6m1krmu8tg8F/bS3QkfkfRGvgomcziCxIYMBY
         ohXu5WEhzG6kpVXuyQOb1B7iSZO5nvjr0SdcZELSug2gJZSDuKg1mdssVh4CEHIaStee
         6Vdunnqfz37xN2yvM1L/z5rJUJ74oPYtupyXc0uKhjnFTYJ5UTbbBSAJUmQKg00+jzSE
         eywb1U4vRM5nJ5/EyNWH/lPbQ/MTdIG+zWWoBN1ZWrnMsk4ca1nT/uc5OywgJvaD5Oul
         ez60aCl+nraGfV9KeiA50JXpcBkRYQMb7Y2fIAOVfwZL6XA7tkHZ2SaswWypvsYx2p0n
         MfQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a21si9888749qkl.269.2019.07.15.03.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 03:45:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3A70B85376;
	Mon, 15 Jul 2019 10:45:56 +0000 (UTC)
Received: from [10.36.117.137] (ovpn-117-137.ams2.redhat.com [10.36.117.137])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CAB404505;
	Mon, 15 Jul 2019 10:45:52 +0000 (UTC)
Subject: Re: [PATCH v3 03/11] s390x/mm: Implement arch_remove_memory()
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Wei Yang
 <richard.weiyang@gmail.com>, Igor Mammedov <imammedo@redhat.com>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Vasily Gorbik <gor@linux.ibm.com>,
 Oscar Salvador <osalvador@suse.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-4-david@redhat.com>
 <20190701074503.GD6376@dhcp22.suse.cz> <20190701124717.GU6376@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <556f2941-4c76-37f2-cac1-91eca48cc0e9@redhat.com>
Date: Mon, 15 Jul 2019 12:45:52 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190701124717.GU6376@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 15 Jul 2019 10:45:56 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.07.19 14:47, Michal Hocko wrote:
> On Mon 01-07-19 09:45:03, Michal Hocko wrote:
>> On Mon 27-05-19 13:11:44, David Hildenbrand wrote:
>>> Will come in handy when wanting to handle errors after
>>> arch_add_memory().
>>
>> I do not understand this. Why do you add a code for something that is
>> not possible on this HW (based on the comment - is it still valid btw?)
> 
> Same as the previous patch (drop it).

No. As the description says, this will be needed to handle errors in
patch 6 cleanly.

And BTW, with paravirtualied devices like virtio-pmem and virtio-mem,
this will also see some other users in the future.

Thanks.

> 
>>> Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
>>> Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Michal Hocko <mhocko@suse.com>
>>> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
>>> Cc: David Hildenbrand <david@redhat.com>
>>> Cc: Vasily Gorbik <gor@linux.ibm.com>
>>> Cc: Oscar Salvador <osalvador@suse.com>
>>> Signed-off-by: David Hildenbrand <david@redhat.com>
>>> ---
>>>  arch/s390/mm/init.c | 13 +++++++------
>>>  1 file changed, 7 insertions(+), 6 deletions(-)
>>>
>>> diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
>>> index d552e330fbcc..14955e0a9fcf 100644
>>> --- a/arch/s390/mm/init.c
>>> +++ b/arch/s390/mm/init.c
>>> @@ -243,12 +243,13 @@ int arch_add_memory(int nid, u64 start, u64 size,
>>>  void arch_remove_memory(int nid, u64 start, u64 size,
>>>  			struct vmem_altmap *altmap)
>>>  {
>>> -	/*
>>> -	 * There is no hardware or firmware interface which could trigger a
>>> -	 * hot memory remove on s390. So there is nothing that needs to be
>>> -	 * implemented.
>>> -	 */
>>> -	BUG();
>>> +	unsigned long start_pfn = start >> PAGE_SHIFT;
>>> +	unsigned long nr_pages = size >> PAGE_SHIFT;
>>> +	struct zone *zone;
>>> +
>>> +	zone = page_zone(pfn_to_page(start_pfn));
>>> +	__remove_pages(zone, start_pfn, nr_pages, altmap);
>>> +	vmem_remove_mapping(start, size);
>>>  }
>>>  #endif
>>>  #endif /* CONFIG_MEMORY_HOTPLUG */
>>> -- 
>>> 2.20.1
>>>
>>
>> -- 
>> Michal Hocko
>> SUSE Labs
> 


-- 

Thanks,

David / dhildenb

