Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A35FC7618B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:21:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 021B221852
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 07:21:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 021B221852
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 835296B0006; Fri, 26 Jul 2019 03:21:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80C228E0003; Fri, 26 Jul 2019 03:21:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6D5408E0002; Fri, 26 Jul 2019 03:21:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4CD366B0006
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 03:21:03 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 199so44551084qkj.9
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 00:21:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=UzRkNTfSQdZZItwCe2vg0oZDL3Y15lhgb/8ppk2aE7U=;
        b=E6qf/sBAjFl20qnoPEb4hqK/wg3Y6I/JzR/Cio76k5k1wTKVQFFrvCbIEQfm2i3VCX
         wPBdhh0RXAfq1cpaMN48R8WAi2aTufhZyqlU46rWzNqY366Wb+JRfl9WNmls5D6y+AIX
         97/FGkb9wEis8PrHFTQYc8pqA/zH4cbCqaFpp3YUfhNPPpVahWz2H3Sk0os2/Y1sBavr
         9QEyIujtFx0RtHfNqerD1tDB4IqTSevY+sbBJ8bGZ2AA0pFFBINSxs/TVBe822qKPc80
         T1WyGNV3t0VDjTVDotfnPQoCbwIPE2YKgWh9PHs52UGUvBnmIeHXLTuLNvo8zueCbzrI
         kAag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/yLh0XU9aqDprVnw6vBv08pnqFx56pj+lsJPtHnfHN8COCoEt
	24RxumRYItIGkn82E6801yMSJg3a5tNFTFoz3GCAkbiUoXUycCYIw3obVruMAKE5kK6P/5FZTcE
	8VVyse5LuUFK1hkD5WAucan8BoKpty+aLNUgxvY0o/WvNRq4nHo1RsQbGd2KvsUtNsQ==
X-Received: by 2002:a37:7e84:: with SMTP id z126mr58608245qkc.386.1564125663042;
        Fri, 26 Jul 2019 00:21:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQmUJ9Mh8ihBAmum10QSoxKsV3MKukY5iVbIXnZFW0YuXUWVTN3fjRWFbZa/+OTt3Jmio0
X-Received: by 2002:a37:7e84:: with SMTP id z126mr58608217qkc.386.1564125662379;
        Fri, 26 Jul 2019 00:21:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564125662; cv=none;
        d=google.com; s=arc-20160816;
        b=IpslDQd2H3Gol1NOqint0x/iBx9JPpm4GNM5sQcK7NGTsWJn4YpfCQc46HnRIsQIpZ
         jlLbfi4mqIuEtEIy53uu2LcjdVZbikAGbu1Fe4H2qMYN4uHfI9m7Yf34KgV/zlF6Ywzi
         MCYad/A3TcRTlBOviFVKhmCGQ8tCk8I+BPubtLQBXQYJ1Tfp+vv1CBOJ9JpYMVJ9S6ck
         X824XVvS88DYTf2YswnLompQb+PknrIs3c435PrkIQ2F7BhH+nw6gkE1/UaBfbbHw3MB
         J1c61JWr+/MkIhCPcHpXR9K2OqCdwujO1Hjs1VQ7mLdSqhmPu6XNgyqO638uCzF2RcHT
         PkVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=UzRkNTfSQdZZItwCe2vg0oZDL3Y15lhgb/8ppk2aE7U=;
        b=BqrWh/Fodto0e6+7QKSPhqJVW2SGvwJnd8kFbezKHzXu400TRp45T6La8tRN92j4wz
         VALHck3LvjL8dpD8MzzH7rrUJGP6L8kN9KyP6hdbcStmAV9kDQNmeaBFJLWYb7h4Ssfa
         W6onsmRC7EwWP+EQmOp1qcRhK2xiM+671Y8VBJNVkxutmMSgU2Gugjng7dIhDsNNkrSH
         ThcBPmLBygqbw9WRMaz/ZnxywmU1WdsA4GnHPoO8/80nLIQWkwzJts3zDdJK4B25JRs5
         Ri/8b133WoClaoztnfaTM/J5qsFN0Yi2Ro6Bdd+Yv/g4rD/PaRgpFok/5qTix/rRgEXm
         cyCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h17si27334834qkg.231.2019.07.26.00.21.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 00:21:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8121DA70E;
	Fri, 26 Jul 2019 07:21:01 +0000 (UTC)
Received: from [10.36.116.244] (ovpn-116-244.ams2.redhat.com [10.36.116.244])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B6A3D5DE80;
	Fri, 26 Jul 2019 07:20:59 +0000 (UTC)
Subject: Re: [PATCH v1] ACPI / scan: Acquire device_hotplug_lock in
 acpi_scan_init()
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Andrew Morton <akpm@linux-foundation.org>, Oscar Salvador <osalvador@suse.de>
References: <20190724143017.12841-1-david@redhat.com>
 <20190725125636.GA3582@dhcp22.suse.cz>
 <6dc566c2-faf6-565d-4ef1-2ac3a366bc76@redhat.com>
 <20190725135747.GB3582@dhcp22.suse.cz>
 <447b74ca-f7c7-0835-fd50-a9f7191fe47c@redhat.com>
 <20190725191943.GA6142@dhcp22.suse.cz>
 <e31882cf-3290-ea36-77d6-637eaf66fe77@redhat.com>
 <CAJZ5v0h+MjC3gFm1Kf3eBg2Rs12368j6S_i5_Gc24yWx+Z3xBA@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <8e891e0c-9024-b5ad-0f44-bccd4e87c60e@redhat.com>
Date: Fri, 26 Jul 2019 09:20:58 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0h+MjC3gFm1Kf3eBg2Rs12368j6S_i5_Gc24yWx+Z3xBA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Fri, 26 Jul 2019 07:21:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.07.19 23:23, Rafael J. Wysocki wrote:
> On Thu, Jul 25, 2019 at 10:49 PM David Hildenbrand <david@redhat.com> wrote:
>>
>> On 25.07.19 21:19, Michal Hocko wrote:
>>> On Thu 25-07-19 16:35:07, David Hildenbrand wrote:
>>>> On 25.07.19 15:57, Michal Hocko wrote:
>>>>> On Thu 25-07-19 15:05:02, David Hildenbrand wrote:
>>>>>> On 25.07.19 14:56, Michal Hocko wrote:
>>>>>>> On Wed 24-07-19 16:30:17, David Hildenbrand wrote:
>>>>>>>> We end up calling __add_memory() without the device hotplug lock held.
>>>>>>>> (I used a local patch to assert in __add_memory() that the
>>>>>>>>  device_hotplug_lock is held - I might upstream that as well soon)
>>>>>>>>
>>>>>>>> [   26.771684]        create_memory_block_devices+0xa4/0x140
>>>>>>>> [   26.772952]        add_memory_resource+0xde/0x200
>>>>>>>> [   26.773987]        __add_memory+0x6e/0xa0
>>>>>>>> [   26.775161]        acpi_memory_device_add+0x149/0x2b0
>>>>>>>> [   26.776263]        acpi_bus_attach+0xf1/0x1f0
>>>>>>>> [   26.777247]        acpi_bus_attach+0x66/0x1f0
>>>>>>>> [   26.778268]        acpi_bus_attach+0x66/0x1f0
>>>>>>>> [   26.779073]        acpi_bus_attach+0x66/0x1f0
>>>>>>>> [   26.780143]        acpi_bus_scan+0x3e/0x90
>>>>>>>> [   26.780844]        acpi_scan_init+0x109/0x257
>>>>>>>> [   26.781638]        acpi_init+0x2ab/0x30d
>>>>>>>> [   26.782248]        do_one_initcall+0x58/0x2cf
>>>>>>>> [   26.783181]        kernel_init_freeable+0x1bd/0x247
>>>>>>>> [   26.784345]        kernel_init+0x5/0xf1
>>>>>>>> [   26.785314]        ret_from_fork+0x3a/0x50
>>>>>>>>
>>>>>>>> So perform the locking just like in acpi_device_hotplug().
>>>>>>>
>>>>>>> While playing with the device_hotplug_lock, can we actually document
>>>>>>> what it is protecting please? I have a bad feeling that we are adding
>>>>>>> this lock just because some other code path does rather than with a good
>>>>>>> idea why it is needed. This patch just confirms that. What exactly does
>>>>>>> the lock protect from here in an early boot stage.
>>>>>>
>>>>>> We have plenty of documentation already
>>>>>>
>>>>>> mm/memory_hotplug.c
>>>>>>
>>>>>> git grep -C5 device_hotplug mm/memory_hotplug.c
>>>>>>
>>>>>> Also see
>>>>>>
>>>>>> Documentation/core-api/memory-hotplug.rst
>>>>>
>>>>> OK, fair enough. I was more pointing to a documentation right there
>>>>> where the lock is declared because that is the place where people
>>>>> usually check for documentation. The core-api documentation looks quite
>>>>> nice. And based on that doc it seems that this patch is actually not
>>>>> needed because neither the online/offline or cpu hotplug should be
>>>>> possible that early unless I am missing something.
>>>>
>>>> I really prefer to stick to locking rules as outlined on the
>>>> interfaces if it doesn't hurt. Why it is not needed is not clear.
>>>>
>>>>>
>>>>>> Regarding the early stage: primarily lockdep as I mentioned.
>>>>>
>>>>> Could you add a lockdep splat that would be fixed by this patch to the
>>>>> changelog for reference?
>>>>>
>>>>
>>>> I have one where I enforce what's documented (but that's of course not
>>>> upstream and therefore not "real" yet)
>>>
>>> Then I suppose to not add locking for something that is not a problem.
>>> Really, think about it. People will look at this code and follow the
>>> lead without really knowing why the locking is needed.
>>> device_hotplug_lock has its purpose and if the code in question doesn't
>>> need synchronization for the documented scenarios then the locking
>>> simply shouldn't be there. Adding the lock just because of a
>>> non-existing, and IMHO dubious, lockdep splats is just wrong.
>>>
>>> We need to rationalize the locking here, not to add more hacks.
>>
>> No, sorry. The real hack is calling a function that is *documented* to
>> be called under lock without it. That is an optimization for a special
>> case. That is the black magic in the code.
>>
>> The only alternative I see to this patch is adding a comment like
>>
>> /*
>>  * We end up calling __add_memory() without the device_hotplug_lock
>>  * held. This is fine as we cannot race with other hotplug activities
>>  * and userspace trying to online memory blocks.
>>  */
>>
>> Personally, I don't think that's any better than just grabbing the lock
>> as we are told to. (honestly, I don't see how optimizing away the lock
>> here is of *any* help to optimize our overall memory hotplug locking)
>>
>> @Rafael, what's your take? lock or comment?
> 
> Well, I have ACKed your patch already. :-)

It's never to late to un-ACK if you changed your mind :)

> 
> That said, adding a comment stating that the lock is acquired mostly
> for consistency wouldn't hurt.
> 

I can certainly do that. Thanks!

-- 

Thanks,

David / dhildenb

