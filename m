Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 51148C433FF
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:36:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0335E214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 08:36:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0335E214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8EC438E0003; Thu,  1 Aug 2019 04:36:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89CD28E0001; Thu,  1 Aug 2019 04:36:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7665B8E0003; Thu,  1 Aug 2019 04:36:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 545EA8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 04:36:57 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c79so60686267qkg.13
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 01:36:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Nkkpcj5z5rfIB8zxiw0gv6Oppmhjnlbo5qG84pf52xc=;
        b=CPtL/F/w3UlfGXrGeVyxv218gCB8rZr+4oETT/TzSDlonygCATND6u6p77NFY4VlST
         lJZplwchNSBPdG9i80Ffd2wVM9POk9owtjmt89+lM3JRn4NMUhib3GvO/bLoSLSc8KFP
         U/HslKckrH0R4NZf1lnxXYcPfWVHp4BEN0XXTuBYCUAcf+bO9dYrhqyzyA4f+RuF78fF
         5B6keTQjw0GmI7YpmBR6V51NLGygVJdYOwBsG4Ni6wAYXByfD3ToIx3EuQAol034QES5
         kp46NvNkEhrrT4tzZLN63jpYT2/5u/k8k/QHj16/wRFuav8S+tAsI4Ocg5MWjM4wOALL
         FJLQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX4IHzV6TmFtw/Pap5pB/9vDS2hwmi5/awHftmtRpSCQfKLY3Ek
	ep+Q4rcsHBKd8xyxL2UCzRLy+uIdTYAGnjr8Cl0wi4tErPNhhQFZ6DcXGqQzfiZqjZOrLSD6+vr
	xYB/jM+pLL3+yEejqgZOgL0KXR39mT6hwL2w0L9blGOcdQ9IMljCq0QkFHlioXY+SfQ==
X-Received: by 2002:a37:90c1:: with SMTP id s184mr74412558qkd.217.1564648617108;
        Thu, 01 Aug 2019 01:36:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdG1jAuCKS5WCBoO5NHo5q/I+TKbmDC5Ya5+rtrpSRHwmxbN4676T1EtG91JAimdtK6NuK
X-Received: by 2002:a37:90c1:: with SMTP id s184mr74412528qkd.217.1564648616402;
        Thu, 01 Aug 2019 01:36:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564648616; cv=none;
        d=google.com; s=arc-20160816;
        b=p2YSw4gijBbMmBRK6ZsRr9HHn3fbwA6AfobEoDH893QzjkPGYVLpA6AIgov7q9lCy4
         mqrcfFKJqVY9DgufB4ChJtdm1XrTWi+ram5OsYapHkR9pEnak4RpjFKq+D0c/ZN/gUWd
         dEuCkmTwRaNVuzNNETwzqDY2FCXO6jRn1pSlq0VeweXFsrk8ALgyjZtU/4/2zcM9e29Q
         ms7Gsyja7ypVJeuSnJF/2A/DnizJbosLYmNvvTRMTsNLCZ9npSgiCCLL0jotLl9BN3VT
         ndGGKWEFSzXzvFH44wAjTW2m5ttc6iu57/mrYvkBcCjHrjphz32pPoG6hmGvzJoj6RZg
         soKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Nkkpcj5z5rfIB8zxiw0gv6Oppmhjnlbo5qG84pf52xc=;
        b=u8UO2Zm8l+Ij4qjPSSy7+/GAzur7gMXvp4X2MSrwLCxjYUUjEi4CpqjTLK+ABuQxfZ
         wARu3LPie1ixq8qQDGHc2QvD3kjV6WDM6MEhAG0BTzUwz81+q13Rhrizo9HExZaezEvF
         GZzTrqKLORkuSmqdXZEeo6wq5RrJX1rjDlNBS1Db/AtelC9Lj1EUCXuA3TKogqyCqORm
         4v38zjzKlxgVpCVHzeklO2CfvXo0jlMq3oSzOq6ZC9hdOC6KmRG+Qm2FIymDgx8V9/IY
         Gbtj31lNGmeRwshykM17qMuiO2Gq1xs1iTzQjPxDAGBQVGL4KSlCdGSecA1+KXWWez4n
         Yzog==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j16si37084688qkg.311.2019.08.01.01.36.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 01:36:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7E40830A7C62;
	Thu,  1 Aug 2019 08:36:55 +0000 (UTC)
Received: from [10.36.116.245] (ovpn-116-245.ams2.redhat.com [10.36.116.245])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C1E0B5D9CD;
	Thu,  1 Aug 2019 08:36:52 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>
References: <20190731124356.GL9330@dhcp22.suse.cz>
 <f0894c30-105a-2241-a505-7436bc15b864@redhat.com>
 <20190731132534.GQ9330@dhcp22.suse.cz>
 <58bd9479-051b-a13b-b6d0-c93aac2ed1b3@redhat.com>
 <20190731141411.GU9330@dhcp22.suse.cz>
 <c92a4d6f-b0f2-e080-5157-b90ab61a8c49@redhat.com>
 <20190731143714.GX9330@dhcp22.suse.cz>
 <d9db33a5-ca83-13bd-5fcb-5f7d5b3c1bfb@redhat.com>
 <20190801061344.GA11627@dhcp22.suse.cz>
 <f8767e9a-034d-dca6-05e6-dc6bbcb4d005@redhat.com>
 <20190801082741.GK11627@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <36580dc6-2d16-3eb8-ad5c-afb22db87662@redhat.com>
Date: Thu, 1 Aug 2019 10:36:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190801082741.GK11627@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 01 Aug 2019 08:36:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 01.08.19 10:27, Michal Hocko wrote:
> On Thu 01-08-19 09:00:45, David Hildenbrand wrote:
>> On 01.08.19 08:13, Michal Hocko wrote:
>>> On Wed 31-07-19 16:43:58, David Hildenbrand wrote:
>>>> On 31.07.19 16:37, Michal Hocko wrote:
>>>>> On Wed 31-07-19 16:21:46, David Hildenbrand wrote:
>>>>> [...]
>>>>>>> Thinking about it some more, I believe that we can reasonably provide
>>>>>>> both APIs controlable by a command line parameter for backwards
>>>>>>> compatibility. It is the hotplug code to control sysfs APIs.  E.g.
>>>>>>> create one sysfs entry per add_memory_resource for the new semantic.
>>>>>>
>>>>>> Yeah, but the real question is: who needs it. I can only think about
>>>>>> some DIMM scenarios (some, not all). I would be interested in more use
>>>>>> cases. Of course, to provide and maintain two APIs we need a good reason.
>>>>>
>>>>> Well, my 3TB machine that has 7 movable nodes could really go with less
>>>>> than
>>>>> $ find /sys/devices/system/memory -name "memory*" | wc -l
>>>>> 1729>
>>>>
>>>> The question is if it would be sufficient to increase the memory block
>>>> size even further for these kinds of systems (e.g., via a boot parameter
>>>> - I think we have that on uv systems) instead of having blocks of
>>>> different sizes. Say, 128GB blocks because you're not going to hotplug
>>>> 128MB DIMMs into such a system - at least that's my guess ;)
>>>
>>> The system has
>>> [    0.000000] ACPI: SRAT: Node 1 PXM 1 [mem 0x10000000000-0x17fffffffff]
>>> [    0.000000] ACPI: SRAT: Node 2 PXM 2 [mem 0x80000000000-0x87fffffffff]
>>> [    0.000000] ACPI: SRAT: Node 3 PXM 3 [mem 0x90000000000-0x97fffffffff]
>>> [    0.000000] ACPI: SRAT: Node 4 PXM 4 [mem 0x100000000000-0x107fffffffff]
>>> [    0.000000] ACPI: SRAT: Node 5 PXM 5 [mem 0x110000000000-0x117fffffffff]
>>> [    0.000000] ACPI: SRAT: Node 6 PXM 6 [mem 0x180000000000-0x183fffffffff]
>>> [    0.000000] ACPI: SRAT: Node 7 PXM 7 [mem 0x190000000000-0x191fffffffff]
>>>
>>> hotplugable memory. I would love to have those 7 memory blocks to work
>>> with. Any smaller grained split is just not helping as the platform will
>>> not be able to hotremove it anyway.
>>>
>>
>> So the smallest granularity in your system is indeed 128GB (btw, nice
>> system, I wish I had something like that), the biggest one 512GB.
>>
>> Using a memory block size of 128GB would imply on a 3TB system 24 memory
>> blocks - which is tolerable IMHO. Especially, performance-wise there
>> shouldn't be a real difference to 7 blocks. Hotunplug triggered via ACPI
>> will take care of offlining the right DIMMs.
> 
> The problem with a fixed size memblock is that you might not know how
> much memory you will have until much later after the boot. For example,
> it should be quite reasonable to expect that this particular machine
> would boot with node 0 only and have additional boards with memory added
> during runtime. How big the memblock should be then? And I believe that
> the virtualization usecase is similar in that regards. You get memory on
> demand.
>  

Well, via a kernel parameter you could make it configurable (just as on
UV systems). Not optimal though, but would work in many scenarios.

I see virtualization environments rather moving away from inflexible
huge DIMMs towards hotplugging smaller granularities (hyper-v balloon,
xen balloon, virtio-mem).

>> Of course, 7 blocks would be nicer, but as discussed, not possible with
>> the current ABI.
> 
> As I've said, if we want to move forward we have to change the API we
> have right now. With backward compatible option of course.
> 

I am not convinced a new API is really worth it yet.

-- 

Thanks,

David / dhildenb

