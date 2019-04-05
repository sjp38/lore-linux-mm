Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2FCFC10F00
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 08:05:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C036217D4
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 08:05:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C036217D4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25F3A6B000C; Fri,  5 Apr 2019 04:05:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E73F6B000D; Fri,  5 Apr 2019 04:05:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 05FEB6B000E; Fri,  5 Apr 2019 04:05:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id D6C186B000C
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 04:05:16 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id a188so4408861qkf.0
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 01:05:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=w8kuRkWkOtRImrq73+ErSyMo6KqtUHPB3SzdjypbOfI=;
        b=eJDhBeZpfEGH2zK4DZ1goNWUaFa9JYTN6XJpuaIiPFOUXI806ObDCNsQ2e6dlH6Hpz
         04yq8Bj0XxDvc2t1stV+fOJM0tVSF173+XQwvSn0WVB7jKEGahnbNu9NZzMEPN8pxne/
         1ZObpcmFQ88t+kg07rbKUvPY1L0dY871lIMxy+8asKCNrKJSGT0SMvRs6hxQsGCLcFiO
         ZK2hvL+Eb3hontQHrUUxUn9XlZTi6jiLwqNrkNJzHqboDsO7iUXGq8FPm5pjvhOEivMe
         Xm/yuYY7sqw4lM4AuSl1iKhSesBORxmVOZJFPiZuuRizPt4J1Z56XRXm/r1zlEfqGmrK
         8c2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXn+uG0Gws7gVbjNixXgHB8RENunSGloaxPH09PsZN5GpqYlip9
	c5iEZQjn4iFm94k2wo3hFQ0pgDnDwaLU+l6xEeieDLJW2NRQo2kQzjkEV1rSo5cx0H8b9M9SDyk
	nP2gaVB4/ehU9TbUve7jjjK+/SXgWzemsuQgMju57YDvowe6yLkrtIWETHJ/lqY60+w==
X-Received: by 2002:a37:8d44:: with SMTP id p65mr8823558qkd.151.1554451516627;
        Fri, 05 Apr 2019 01:05:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJEAxxDYuder3XnaeEHYmJ2KHtkw6nAht+7+AeutP06bRPAX4HOuTPK1bJKPSxWLUqmc5l
X-Received: by 2002:a37:8d44:: with SMTP id p65mr8823489qkd.151.1554451515541;
        Fri, 05 Apr 2019 01:05:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554451515; cv=none;
        d=google.com; s=arc-20160816;
        b=oNv5f2Cw4f3Ulsx7A2Y4u4t4+OrVkr/MMs6SA/ZmuYYrnCTQxpNi5u+2icOai8nBr5
         9xmJpUyUOjGtCRhZW/udSHGEJ+ID1cukBpfNMGPzHRKSJOMoFN7apKQcUxgW7NVV6oS7
         b+911Ke5UHqz8EPhpfEZuSNcCksBrJBMaBrZDJHRJM3oPqMqApCcLBOfKKKuDHvjlwee
         rpYxPv9DFKQJAcReo2JmfSZmiC71V1lqnR8YBDHgcwisD5nP8A+K2/BC2NqDBbgkiP16
         ZJld6vxrdtOszIkpPIj4uHsoW7H3/I6QnKkjCcv4vCnBwJMaitlRNoYcaLIYayo8sflG
         eu/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=w8kuRkWkOtRImrq73+ErSyMo6KqtUHPB3SzdjypbOfI=;
        b=LFbssWw7m6L3Yux9v+GGHjxMBjX3o2aoqQFGtVDD7aJ4ryWJHr+wUlnLKAV3lq+EG4
         RzQIFMaclIsjRP4w322XTpZ5CyAk+pVDwa3Bm0b9jG6ORMIl2j/vrXyBVKQmYNJZA8r3
         wVOABocZOGWMt6ZU3np1xPfEdiMundGUtNLOS4WTGOBl5OFVKYsRyMBXmUnNqh2u+KUl
         uiMw4NehmD7/0vQo/F0CNSDNwcceJMl+F24/W9KD/3NBDJX+SkTBMSpX7gP+cJ3VbzI1
         jVQbRUEhIlExxztcRa5qaYN8yxOfABRMmjOW4px4DPiEfjD70zKPbEAggNkh3n7KQenU
         cUQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m50si4676068qtm.179.2019.04.05.01.05.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 01:05:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8A91E81E19;
	Fri,  5 Apr 2019 08:05:14 +0000 (UTC)
Received: from [10.36.117.86] (ovpn-117-86.ams2.redhat.com [10.36.117.86])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BEE511001E8A;
	Fri,  5 Apr 2019 08:05:10 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
To: Michal Hocko <mhocko@kernel.org>
Cc: Oscar Salvador <osalvador@suse.de>, akpm@linux-foundation.org,
 dan.j.williams@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-3-osalvador@suse.de>
 <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
 <20190404180144.lgpf6qgnp67ib5s7@d104.suse.de>
 <5f735328-3451-ebd7-048e-e83e74e2c622@redhat.com>
 <20190405071418.GN12864@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a4230528-dc7e-e17c-c363-e3da7961dbf1@redhat.com>
Date: Fri, 5 Apr 2019 10:05:09 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190405071418.GN12864@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 05 Apr 2019 08:05:14 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05.04.19 09:14, Michal Hocko wrote:
> On Thu 04-04-19 20:27:41, David Hildenbrand wrote:
>> On 04.04.19 20:01, Oscar Salvador wrote:
> [...]
>>> But I am not really convinced by MHP_SYSTEM_RAM name, and I think we should stick
>>> with MHP_MEMBLOCK_API because it represents __what__ is that flag about and its
>>> function, e.g: create memory block devices.
> 
> Exactly

Fine with me for keeping what Oscar has.

> 
>> This nicely aligns with the sub-section memory add support discussion.
>>
>> MHP_MEMBLOCK_API immediately implies that
>>
>> - memory is used as system ram. Memory can be onlined/offlined. Markers
>>   at sections indicate if the section is online/offline.
> 
> No there is no implication like that. It means only that the onlined
> memory has a sysfs interface. Nothing more, nothing less

As soon as there is a online/offline interface, you *can* (and user
space usually *will*) online that memory. Onlining/offlining is only
defined for memory to be added to the buddy - memory to be used as
"system ram". Doing it for random device memory will not work / result
in undefined behavior.

Not adding memory block devices for system ram will not allow user space
to online/offline it and break kdump reload for hot-added memory. But
memory can be onlined/offlined using internal APIs of course - if that's
what you were referring to.

> 
> This is an internal API so we are not carving anything into the stone.

That is true.

> So can we simply start with what we have and go from there?

Sure, what Oscar does here is just a simple refactoring of the interface
and I was just wondering if the interface needs a general overhaul.

>I am getting
> felling that this discussion just makes the whole thing more muddy.

I think this discussion is helpful to understand how the whole thing is
supposed to work :) At least on my side.


Meanwhile, I will have a look if memory block devices cannot simply be
created by the caller of arch_add_memory(). At least it feels like
creating memory bock devices could be factored out - I remember that it
was not that easy.


-- 

Thanks,

David / dhildenb

