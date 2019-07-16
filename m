Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE17CC76195
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:28:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8355E20659
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 12:28:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8355E20659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 146936B0003; Tue, 16 Jul 2019 08:28:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F7BD6B0005; Tue, 16 Jul 2019 08:28:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F26E18E0001; Tue, 16 Jul 2019 08:28:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D16BC6B0003
	for <linux-mm@kvack.org>; Tue, 16 Jul 2019 08:28:06 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 199so16756804qkj.9
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 05:28:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=hwASrMLyQ/zbgKJulRFRGXaABd4mu1eidfBhJJo9ypM=;
        b=Fc0YAc7+fz7jy3Vcg9DD6GX3JhbRlKlVoQaoU26Aa31mQIl3/Cr3+iYlp9vK581O5o
         6cl34f4+V8c8vSAtYerrkv19RIuQ8qEo12HqwiuZHYfJVNVrFIgmcCRj3W7Dc7ikEYPG
         /C9tu+Se4/FFD0EmW68Rd1ccNKrXFKlvDYqLTv0oAiciO5d9PF74rBw9g9OBaj3dpPWw
         vbE1RbaDio7gAe5ZkGebNwcIgW6myxYOUA6m2cIn4aWvvEpAWrxP00ya6GmkpCRVMEwv
         f0Rl0XXUHNCD/KZByFJ7pzPXLRTGc00ubvZ+fzBr5L9qhBT+wlUSLzVZRH/UtOT1/hN+
         F96Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUIVtyP3uVB01s/uACU8q/wSEqHqhw2K3rshgJK/KOpVIYwZk0L
	TUhxv8ty1aqCgTMqVRoC0XawzV5RxBPqmLP0szE+rYNfFw1zm+PeTETU0sa/4Kk9d5c8QFogaqa
	r6P2RH0JcID36WiqsbiTStQ3xKddTF35LEYt6VSEwL3mEz8wXjFFgAJn2y52Ui90qGw==
X-Received: by 2002:a0c:e8c7:: with SMTP id m7mr24064256qvo.134.1563280086624;
        Tue, 16 Jul 2019 05:28:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBkYDvlU08+FZFQPZkBTy1BV1Ud9Gj9kJLSFGVIMIiS6l98mIVK6wPwmd261oqFuHe2rvs
X-Received: by 2002:a0c:e8c7:: with SMTP id m7mr24064202qvo.134.1563280085944;
        Tue, 16 Jul 2019 05:28:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563280085; cv=none;
        d=google.com; s=arc-20160816;
        b=NHRuwqaBaXYESCbKKLxYxw7xZDgcpCi8k7RCOqqO/ZsQUJl3Lln0TrH7nBmivRyZIS
         3O5Hu6d8Ct55ID/jirxfIOXrfkdDs3QoWdaAMyRskJBHMETKlrZ4uAEST6c/EbdSRky1
         JVXzcMpW7cl/tzGGruEijOWl+Fe2U6TStrIGd7vnE5TlQHipsXmWInRjVbDi/uTXijje
         oe6pzt966X/tUeEl45g3unEnmrDaDYbclT4O+XNSXLDaWwrxiNZ3W1C0zOCmcB6v5Dr5
         M1W7vKnT8jS5XCDQF97aG5wbXaJawFp4Vtq3ZniwXHH6oAX/xMLLd1iTxyWQ3bN5crim
         GVDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=hwASrMLyQ/zbgKJulRFRGXaABd4mu1eidfBhJJo9ypM=;
        b=cQsN6xoKN1PWa4EPonwOnd3fEe9J4bbPV6JKQuZ6CfufQQUEuP+809DDTwVZWAMdXS
         42GAo16H63GaeQ7nunpNZ3+bUZKRncM4A7zVFTmBKPNtYcyg0+bdL1ypo5A+PSaDSsE8
         BCleZ1aCOghr2WwccmqHyZD9wI7kbRmxMLBWcgvjwV2e1Rxr3M1F4/kEVWKyv+JoRXil
         xDl29aTNDHiFJwpTLU4Pjxf7ZZRY+kjRQTzKpTlqWTVHrbrlt0Bl+oqiNXX+EjIeRDx4
         uScGomwrEZqobpB7D9bVN+AxYggqq+4gjI+zaPI/3oEa1dFrkYRgHoYqLlSVD33+x1bB
         NZdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t53si13265455qte.224.2019.07.16.05.28.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 05:28:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B8F7F3082E72;
	Tue, 16 Jul 2019 12:28:04 +0000 (UTC)
Received: from [10.36.116.218] (ovpn-116-218.ams2.redhat.com [10.36.116.218])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 54F22611DB;
	Tue, 16 Jul 2019 12:28:02 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Rashmica Gupta <rashmica.g@gmail.com>, Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux>
 <887b902e-063d-a857-d472-f6f69d954378@redhat.com>
 <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <0cd2c142-66ba-5b6d-bc9d-fe68c1c65c77@redhat.com>
Date: Tue, 16 Jul 2019 14:28:01 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <9143f64391d11aa0f1988e78be9de7ff56e4b30b.camel@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Tue, 16 Jul 2019 12:28:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02.07.19 08:42, Rashmica Gupta wrote:
> Hi David,
> 
> Sorry for the late reply.

Hi,

sorry I was on PTO :)

> 
> On Wed, 2019-06-26 at 10:28 +0200, David Hildenbrand wrote:
>> On 26.06.19 10:15, Oscar Salvador wrote:
>>> On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
>>>> Back then, I already mentioned that we might have some users that
>>>> remove_memory() they never added in a granularity it wasn't
>>>> added. My
>>>> concerns back then were never fully sorted out.
>>>>
>>>> arch/powerpc/platforms/powernv/memtrace.c
>>>>
>>>> - Will remove memory in memory block size chunks it never added
>>>> - What if that memory resides on a DIMM added via
>>>> MHP_MEMMAP_DEVICE?
>>>>
>>>> Will it at least bail out? Or simply break?
>>>>
>>>> IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save
>>>> to be
>>>> introduced.
>>>
>>> Uhm, I will take a closer look and see if I can clear your
>>> concerns.
>>> TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
>>> yet.
>>>
>>> I will get back to you once I tried it out.
>>>
>>
>> BTW, I consider the code in arch/powerpc/platforms/powernv/memtrace.c
>> very ugly and dangerous.
> 
> Yes it would be nice to clean this up.
> 
>> We should never allow to manually
>> offline/online pages / hack into memory block states.
>>
>> What I would want to see here is rather:
>>
>> 1. User space offlines the blocks to be used
>> 2. memtrace installs a hotplug notifier and hinders the blocks it
>> wants
>> to use from getting onlined.
>> 3. memory is not added/removed/onlined/offlined in memtrace code.
>>
> 
> I remember looking into doing it a similar way. I can't recall the
> details but my issue was probably 'how does userspace indicate to
> the kernel that this memory being offlined should be removed'?

Instead of indicating a "size", indicate the offline memory blocks that
the driver should use. E.g. by memory block id for each node

0:20-24,1:30-32

Of course, other interfaces might make sense.

You can then start using these memory blocks and hinder them from
getting onlined (as a safety net) via memory notifiers.

That would at least avoid you having to call
add_memory/remove_memory/offline_pages/device_online/modifying memblock
states manually.

(binding the memory block devices to a driver would be nicer, but the
infrastructure is not really there yet - we have no such drivers in
place yet)

> 
> I don't know the mm code nor how the notifiers work very well so I
> can't quite see how the above would work. I'm assuming memtrace would
> register a hotplug notifier and when memory is offlined from userspace,
> the callback func in memtrace would be called if the priority was high
> enough? But how do we know that the memory being offlined is intended
> for usto touch? Is there a way to offline memory from userspace not
> using sysfs or have I missed something in the sysfs interface?

The notifier would really only be used to hinder onlining as a safety
net. User space prepares (offlines) the memory blocks and then tells the
drivers which memory blocks to use.

> 
> On a second read, perhaps you are assuming that memtrace is used after
> adding new memory at runtime? If so, that is not the case. If not, then
> would you be able to clarify what I'm not seeing?

The main problem I see is that you are calling
add_memory/remove_memory() on memory your device driver doesn't own. It
could reside on a DIMM if I am not mistaking (or later on
paravirtualized memory devices like virtio-mem if I ever get to
implement them ;) ).

How is it guaranteed that the memory you are allocating does not reside
on a DIMM for example added via add_memory() by the ACPI driver?

-- 

Thanks,

David / dhildenb

