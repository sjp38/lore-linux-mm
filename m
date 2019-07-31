Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7882BC32753
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:38:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23E8A206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:38:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23E8A206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7F48E0003; Wed, 31 Jul 2019 09:38:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A76B8E0001; Wed, 31 Jul 2019 09:38:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 895DC8E0003; Wed, 31 Jul 2019 09:38:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACCE8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:38:00 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id h198so58140175qke.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:38:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=iLvEeZ4Nafb10nFjkhOFTjElQ9i3rfU4A5BUL0OaCqU=;
        b=tky8rU+6S3j3HpUxYLz2VI29nA1GSalEPsvTuoH/CUfKey3iGDTZzI6d9Np/kT5pND
         VCVvsW97ukAonSoQhNFfiyYbWLvADtFDuutbCd1yBhheLCMuXbujnyCW9aFPR2mAvkkF
         obdXraijxjXrBbCijyM5NfXQc4aYWJGEX6YlW7cIYJe04COEXB3EarOIKSumLmO+11GX
         gHietjk0MmZjos9PODB8JxySw+aL91vgNgVVCCMI1XKrhJV1w1hIAnJH3Vzm6CAXQXB9
         +mmB7WlxgsxIWOba8exd80W91SUi6d8wOppmifNOoaONbjh06EX4TU4rDhf/Tad7ssno
         v+xA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVT7hfLevEmqmkb6mmFPAW9pF6EdedHO5S5gNbNGp082rWod9ly
	jctwdCR7E/C4WsXUXj9o+xgjaowVuY636pcpVXSnVR8Gv6xeZET7dKr6eGNh+sUahOeMvf6W5fJ
	Qu1Hezl66IUpFYKhgBXkYlQDLe221oSyC7P6X+Ks3j8bSvzPCwR1dBKu6E0RcAKIEgA==
X-Received: by 2002:a37:71c7:: with SMTP id m190mr81611373qkc.47.1564580280196;
        Wed, 31 Jul 2019 06:38:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzNS9NBqdt019No4Ngvf7P8KgQJwxpgG0DRXc8g/dErW8Wpd+zbBj1tSFCiEhDYXqTh3vvJ
X-Received: by 2002:a37:71c7:: with SMTP id m190mr81611337qkc.47.1564580279637;
        Wed, 31 Jul 2019 06:37:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564580279; cv=none;
        d=google.com; s=arc-20160816;
        b=KqAZQmfccZvcotoyl86cVouULKj7BM7x4JFQknuMZlNmzmSvPs229tJYRV5/f4gHya
         INMzFijXleUpmT4ncfVzBXkZXYnkVQVpunpFnFrW94mYSwiFQz8OOCnwxMC6Vl25F7wT
         FC/iCZG7qNgyzP9QCJb3w/op7U3lxAGt3d+DkocLn+IPZsa4UEFvLapAjsLH+3xGOnGg
         HU4Vz4cKeR6yZW0ChIwI9A8AkktDwteUfm9B/PTP62yhVSMBuL/DMF89eFvXDmrthMgD
         mVbDZWArbKpnt2Wh9jXBT7UE07ZoKzaUKPPQR+cvYhuDoU9Ecg+Hj6a+tfqs+cQTx5Uz
         t+hA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=iLvEeZ4Nafb10nFjkhOFTjElQ9i3rfU4A5BUL0OaCqU=;
        b=IPj8zP1aoRrZko+szA1ESqM4xW2RRbBMF3KpVpC6dDsVuR7V67ayfgRGBrb2btWofm
         aNSqOFZWSs6+iMXU69ZghGCfdMJeANPm/iwl1F2YPoWgguDz9UJ6inlij3w9cjYtu9TB
         gs8qwG4j2Rl49Qo6rrphLGCOn3xgWHCjN328lXzrtYEqLdSPgCu2X9w1J/3Pufpnhxo9
         ZlFjjvYn8gPZlZ+n4MnCWhuSrUKTlxxyNm/UKCgNo0cAxfIVN27Az78csQ8C5liI4W+k
         zf1gKnwYBfGzn25DvjcLp0nyhWtqxSmxMUoHvQBLRMOW8Rf3a8G3dqPC32xPBYv4jNQj
         9pQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l40si39583181qtb.243.2019.07.31.06.37.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:37:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CA21B30860C1;
	Wed, 31 Jul 2019 13:37:58 +0000 (UTC)
Received: from [10.36.117.240] (ovpn-117-240.ams2.redhat.com [10.36.117.240])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 56B6A5D6A7;
	Wed, 31 Jul 2019 13:37:57 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/acpi/scan.c: Fixup "acquire
 device_hotplug_lock in acpi_scan_init()"
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-acpi@vger.kernel.org, "Rafael J . Wysocki"
 <rafael.j.wysocki@intel.com>, Oscar Salvador <osalvador@suse.de>,
 Andrew Morton <akpm@linux-foundation.org>
References: <20190731123201.13893-1-david@redhat.com>
 <20190731125334.GM9330@dhcp22.suse.cz>
 <d3cc595d-7e6f-ef6f-044c-b20bd1de3fb0@redhat.com>
 <20190731131408.GP9330@dhcp22.suse.cz>
 <23f28590-7765-bcd9-15f2-94e985b64218@redhat.com>
 <20190731133344.GR9330@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b135e167-a0e1-0772-559b-6375ea40c9c4@redhat.com>
Date: Wed, 31 Jul 2019 15:37:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190731133344.GR9330@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Wed, 31 Jul 2019 13:37:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31.07.19 15:33, Michal Hocko wrote:
> On Wed 31-07-19 15:18:42, David Hildenbrand wrote:
>> On 31.07.19 15:14, Michal Hocko wrote:
>>> On Wed 31-07-19 15:02:49, David Hildenbrand wrote:
>>>> On 31.07.19 14:53, Michal Hocko wrote:
>>>>> On Wed 31-07-19 14:32:01, David Hildenbrand wrote:
>>>>>> Let's document why we take the lock here. If we're going to overhaul
>>>>>> memory hotplug locking, we'll have to touch many places - this comment
>>>>>> will help to clairfy why it was added here.
>>>>>
>>>>> And how exactly is "lock for consistency" comment going to help the poor
>>>>> soul touching that code? How do people know that it is safe to remove it?
>>>>> I am not going to repeat my arguments how/why I hate "locking for
>>>>> consistency" (or fun or whatever but a real synchronization reasons)
>>>>> but if you want to help then just explicitly state what should done to
>>>>> remove this lock.
>>>>>
>>>>
>>>> I know that you have a different opinion here. To remove the lock,
>>>> add_memory() locking has to be changed *completely* to the point where
>>>> we can drop the lock from the documentation of the function (*whoever
>>>> knows what we have to exactly change* - and I don't have time to do that
>>>> *right now*).
>>>
>>> Not really. To remove a lock in this particular path it would be
>>> sufficient to add
>>> 	/*
>>> 	 * Although __add_memory used down the road is documented to
>>> 	 * require lock_device_hotplug, it is not necessary here because
>>> 	 * this is an early code when userspace or any other code path
>>> 	 * cannot trigger hotplug operations.
>>> 	 */
>>
>> Okay, let me phrase it like this: Are you 100% (!) sure that we don't
>> need the lock here. I am not -  I only know what I documented back then
>> and what I found out - could be that we are forgetting something else
>> the lock protects.
>>
>> As I already said, I am fine with adding such a comment instead. But I
>> am not convinced that the absence of the lock is 100% safe. (I am 99.99%
>> sure ;) ).
> 
> I am sorry but this is a shiny example of cargo cult programming. You do
> not add locks just because you are not sure. Locks are protecting data
> structures not code paths! If it is not clear what is actually protected
> then that should be explored first before the lock is spread "just to be
> sure"
> 
> Just look here. You have pushed that uncertainty to whoever is going
> touch this code and guess what, they are going to follow that lead and
> we are likely to grow the unjustified usage and any further changes will
> be just harder. I have seen that pattern so many times that it is even
> not funny. And that's why I pushed back here.
> 
> So let me repeat. If the lock is to stay then make sure that the comment
> actually explains what has to be done to remove it because it is not
> really required as of now.
> 

The other extreme I saw: People dropping locks because they think they
can be smart but end up making developers debug crashes for months (I am
not lying).

As I want to move on with this patch and have other stuff to work on, I
will adjust the comment you gave and add that instead of the lock.

-- 

Thanks,

David / dhildenb

