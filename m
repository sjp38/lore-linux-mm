Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3B99C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:50:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93A40206DD
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 16:50:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93A40206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13E8D6B0010; Thu,  4 Apr 2019 12:50:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0EEF26B0266; Thu,  4 Apr 2019 12:50:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F1DCB6B026B; Thu,  4 Apr 2019 12:50:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE2B56B0010
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 12:50:55 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id n10so2822532qtk.9
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 09:50:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=rFmOvr7Ta0K8TnmwwLOsmRukc4Qr5OijO1+CekD6wLU=;
        b=EaXjLGQ73Qs+LliW0IZGBLHFMoLP6AtpY+E/wQ4BL/nSjyCnQPkjf50zmrQ+Rw65EM
         r+gRhkLTWzXzVd3aVnmiip1KoH1laozezmggzNruWvYBP11TIdUqU/uQk4p1ERgvB7Kh
         eWi2nQXXriOS6iSCoGuI8rVGQhmmwTOyc6E5h8HIHJLn84rsPP3odoj1JpljSWiIIUCB
         Wpw1/tI9J5TF74eDDwaAQj+3SHeAm4v6Kk1PoMwOTKG89ox9kXBVNj0PFyB/KHcEXQ18
         yLRTpFEVhN6dC2HT/w30iV9EJxon/vJkEUT7LHUvS5BMqZxM4v18k2ar4YVEQWRU3dIK
         2DIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW2M0Ulbh+ucQjVZfj+QyCJdy8JcQ2b2YK4ojql4h706rOqhF3S
	WYUjCLabQk9XMeG+GRu2LFOV09kTLbvQ2iItz34PwgbEfIb6/cwaCMDbdAFInWeaEJIrNfbyAJp
	G3qOPF17RvFdDlA7apkNGxkj0vyQeoWX0ZEEFV6nzOPhwiFkM4kOyBNqb5szm/mkJ3Q==
X-Received: by 2002:ae9:e8c3:: with SMTP id a186mr5901569qkg.183.1554396655576;
        Thu, 04 Apr 2019 09:50:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBYcQ0q0mYv5ZiEE4Cjma5hY8E03O9DUzrq/C54fcMAfyGSie9LSeC9b+L8PN4STnp2EZW
X-Received: by 2002:ae9:e8c3:: with SMTP id a186mr5901527qkg.183.1554396654903;
        Thu, 04 Apr 2019 09:50:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554396654; cv=none;
        d=google.com; s=arc-20160816;
        b=qva5aP1O06HCAvzEJDwAqnRyv3QhW9mtYcLfThSE/F0wOz+mVUo5Nje7JVks0BOLzq
         opd6v4X5yKGpfbZxAc/hfdXN0TX83QV3pl2KlwKGCIQwcKwdVPqOS5bVctDQw3/nTw0R
         cCHvl+WEBpLlXbk4fr2JH25oh411f8uWWhONXtxNHEr4TuWzel30/7zbgZoyi7P35uB7
         O/TTgijyLqYMi48CZPHuSZIZNRpIYS3P/wbRJqSnh84CR6+uSWuHQAch3DFeDZopsWyb
         +ZkXnD9JnUs0Yl6N8HDEyHzK3eVH/D4m9dShht4UZGF8EFKekwNslQzmPQ5pP96QUal9
         67KQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=rFmOvr7Ta0K8TnmwwLOsmRukc4Qr5OijO1+CekD6wLU=;
        b=txeTBOd0/m0PwebY9x1voLnRVZrqHOAk+0XQmrbxqPVkNaHfBykxbilsDrHAAc0rUa
         9PVwVJWouOnJaVY2h3H9ji4Yq4kevzJDFnXJ5WWv0qqHjuOxuk70LBHpQtevccL8BOdl
         Cuygkxh0Tccm11pyB3kPLl/fqnq8uNTI1eEacC8lJuST0DxNiCFbRQvvsZjP07K1PL9m
         OYkUW+woaiddG5wdQUU5FLwgN2BrzxKCXlCpGIaRiMZk/F6WrAljzvlcidAf+gpA2fk+
         2AZ+aqHVJyNftESsVyCHSVfknJI6C1THVOF2Aai0EwyKF4GbtDxq7gsIGosgL5N4sMeV
         ohSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g29si4820793qte.166.2019.04.04.09.50.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 09:50:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0A47F307E05C;
	Thu,  4 Apr 2019 16:50:54 +0000 (UTC)
Received: from [10.36.116.16] (ovpn-116-16.ams2.redhat.com [10.36.116.16])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8B7F75C22B;
	Thu,  4 Apr 2019 16:50:52 +0000 (UTC)
Subject: Re: [PATCH 1/2] mm, memory_hotplug: cleanup memory offline path
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-2-osalvador@suse.de>
 <f2360f11-4360-b678-f095-c4ebbf7cd0ec@redhat.com>
 <20190404132506.kaqzop4qs6m56plu@d104.suse.de>
 <7874ef85-adc7-95a8-87f4-1f15eb21c677@redhat.com>
 <20190404154006.ywtpwb3c3frkajzk@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <bf17fd40-82d7-3b8a-acb3-3103a0a1e410@redhat.com>
Date: Thu, 4 Apr 2019 18:50:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190404154006.ywtpwb3c3frkajzk@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 04 Apr 2019 16:50:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.04.19 17:40, Oscar Salvador wrote:
> On Thu, Apr 04, 2019 at 04:47:43PM +0200, David Hildenbrand wrote:
>> On 04.04.19 15:25, Oscar Salvador wrote:
>>> On Thu, Apr 04, 2019 at 03:18:00PM +0200, David Hildenbrand wrote:
>>>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>>>> index f206b8b66af1..d8a3e9554aec 100644
>>>>> --- a/mm/memory_hotplug.c
>>>>> +++ b/mm/memory_hotplug.c
>>>>> @@ -1451,15 +1451,11 @@ static int
>>>>>  offline_isolated_pages_cb(unsigned long start, unsigned long nr_pages,
>>>>>  			void *data)
>>>>>  {
>>>>> -	__offline_isolated_pages(start, start + nr_pages);
>>>>> -	return 0;
>>>>> -}
>>>>> +	unsigned long offlined_pages;
>>>>>  
>>>>> -static void
>>>>> -offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
>>>>> -{
>>>>> -	walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
>>>>> -				offline_isolated_pages_cb);
>>>>> +	offlined_pages = __offline_isolated_pages(start, start + nr_pages);
>>>>> +	*(unsigned long *)data += offlined_pages;
>>>>
>>>> unsigned long *offlined_pages = data;
>>>>
>>>> *offlined_pages += __offline_isolated_pages(start, start + nr_pages);
>>>
>>> Yeah, more readable.
>>>
>>>> Only nits
>>>
>>> About the identation, I double checked the code and it looks fine to me.
>>> In [1] looks fine too, might be your mail client?
>>>
>>> [1] https://patchwork.kernel.org/patch/10885571/
>>
>> Double checked, alignment on the parameter on the new line is very weird.
> 
> Uhm, are not you confused because we removed the "while (off...)", and
> "ret =" gets idented right below "/*check again*".
> 
> Try to apply the patch and check whether you still see the issue.
> I just checked out the branch and it looks fine to me.


That's what I did and it hurts my eyes (dropping two tabs, converting
tabs to spaces)

your patch:

ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
                                        check_pages_isolated_cb);

vs.

ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn, NULL,
                            check_pages_isolated_cb);


Just so we are on the same page, we usually indent parameters on
additional lines to the start of other parameters. Not to the end
of the previous line.

> 
>> And both lines cross 80 lines per line ... nit :)
> 
> Yeah, 81 characters, but I decided to go with that rather than start doing
> tricky things to accomplish 80 characters.
> Maybe Andrew agrees, or he might slap me.
> 

Why not simply


ret = walk_system_ram_range(start_pfn, end_pfn - start_pfn,
			    NULL, check_pages_isolated_cb);

just as we have in add_memory_resource along with walk_memory_range().


A lot of nit-picking, sorry :)

-- 

Thanks,

David / dhildenb

