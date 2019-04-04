Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13624C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 18:27:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC8C9206DD
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 18:27:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC8C9206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D3B16B000E; Thu,  4 Apr 2019 14:27:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 783666B0266; Thu,  4 Apr 2019 14:27:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 64B5C6B0269; Thu,  4 Apr 2019 14:27:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 41A3C6B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 14:27:46 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id c67so2931292qkg.5
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 11:27:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=Pqo2xRZJHl4Xda/cR5qeaa2JlEc3XoANXzV0D472+z8=;
        b=UGYzfLXQGmdYqTetoFN40pw8viGMVwjkRX2QBUNQy6yAehxCL5IqbQb9GuqGPRVFPA
         lTMpxBdPLjvoljO5sJ6aDvAiUwbwM2OxhDMEwQYtpsmQGa3WQ9/wH5dX1UVJsewQLvPY
         Zp2yZFk4AV9e5xgZ5Zsxjt2uSH093eZI3Qg5cBriW+OAue5rHM+vwvNihN6n1wpTNo20
         4r7SorynNtF9JsmODm47HxWQU7a7VSOWfXUaWxEe9BsUNecRkvk7Qnfapt7o+pzWItuh
         2zbitWZFUU0Y1hdlZP0tNU8zLTblGLe//JqWMBzMLqod8wKUulBC+DqXgqAa6HgmN7/4
         JZfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV4+wXyySrpC7qDzVZeavgXzTQbl75vfKapPFEvaTMF1LJshuZG
	11Y2qVImUmPXANa22+KwFjnC6SdKmcbR0DYrkVoe5OiTm4toUT0dcXoQ1z5oEvVdvXIqnwbDgjV
	aAISakVv4CYqawkl9zPp1wpS7uR/+o+jCBCVOvMkRGdi2UP5yxXPGS+0TPespx8eWfg==
X-Received: by 2002:ac8:70d6:: with SMTP id g22mr6901601qtp.216.1554402465952;
        Thu, 04 Apr 2019 11:27:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpe03H8g6FuRCQuyUh+EtHrrmhLzEtNFjvlkF/1OtnrsewObIrkBj8UwxTESL6VlQqszX/
X-Received: by 2002:ac8:70d6:: with SMTP id g22mr6901528qtp.216.1554402464841;
        Thu, 04 Apr 2019 11:27:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554402464; cv=none;
        d=google.com; s=arc-20160816;
        b=OwhAr3WSgCFzxDhtwU5XZ/v8rfdoo1MPmid7XFVdjHnBfm0zIuMIMOQVA4BAf/6WS6
         7wEB6HTB3jDksTFyxnRN9NjmHCKj+DbEg3joKAM+OFbF8Wcjwx3HiTv6G9XYGWcdPvte
         UVMuUXrln+tqiLs/cURJbdzQqTk1ZXFf15fSIQ3MbjZIf/JFC1HPD0MoYmpT8/DM2oI5
         1akU2oGo+hGSyUsVsZ8PUqX+JbT6yHSxsHrnrNh7qxGGJwcJXaS2L77JdbB+kinc3EHo
         HY1pICOTumUOXzkM1shTCaFbSbPPvyhsAd9QrmfLSYp2BKDNi66L/ZO3LX+dRc3l1e93
         A5sg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=Pqo2xRZJHl4Xda/cR5qeaa2JlEc3XoANXzV0D472+z8=;
        b=Xcame1KNjkyomPiKYCeCu5UnBeitVt2symL7Pb4a7NJVG2aZFrABS/4TJlVr28TdNj
         PWu7uJBhQ8z52Mwmb7eBvINqczk5xBhZ04PCqKUvXtembqwubBpDzn9L9F3b8LTMmRst
         gSqxD3sRh4Zev1/LBmtXrG7lNc8xq0m5gup7FCKj2w9TvetSTCtVkIsp8Mu05PYk8cU3
         LnDM6gyyBGJZR43ompdJTrmfkC3EByG+DZeon+iaggmucwwbabXlQA7b8l+ksZuB/kth
         mXoM6f7jHfLUkvRjnXNoQFP4Uz06PCKY/Zsd42uLBj48kD5S02XAwD74J0iR6eTix5BV
         Rabw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z3si5676598qvj.216.2019.04.04.11.27.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 11:27:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E4DA6307B483;
	Thu,  4 Apr 2019 18:27:43 +0000 (UTC)
Received: from [10.36.116.63] (ovpn-116-63.ams2.redhat.com [10.36.116.63])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8854F600C5;
	Thu,  4 Apr 2019 18:27:42 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm, memory_hotplug: provide a more generic
 restrictions for memory hotplug
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <20190404125916.10215-1-osalvador@suse.de>
 <20190404125916.10215-3-osalvador@suse.de>
 <880c5d09-7d4e-2a97-e826-a8a6572216b2@redhat.com>
 <20190404180144.lgpf6qgnp67ib5s7@d104.suse.de>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <5f735328-3451-ebd7-048e-e83e74e2c622@redhat.com>
Date: Thu, 4 Apr 2019 20:27:41 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190404180144.lgpf6qgnp67ib5s7@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 04 Apr 2019 18:27:44 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04.04.19 20:01, Oscar Salvador wrote:
> On Thu, Apr 04, 2019 at 04:57:03PM +0200, David Hildenbrand wrote:
> 
>>>  #ifdef CONFIG_MEMORY_HOTPLUG
>>> -int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
>>> -		    bool want_memblock)
>>> +int arch_add_memory(int nid, u64 start, u64 size,
>>> +			struct mhp_restrictions *restrictions)
>>
>> Should the restrictions be marked const?
> 
> We could, but maybe some platforms want to override something later on
> depending on x or y configurations, so we could be more flexible here.
> 
>>> +/*
>>> + * Do we want sysfs memblock files created. This will allow userspace to online
>>> + * and offline memory explicitly. Lack of this bit means that the caller has to
>>> + * call move_pfn_range_to_zone to finish the initialization.
>>> + */
>>
>> I think you can be more precise here.
>>
>> "Create memory block devices for added pages. This is usually the case
>> for all system ram (and only system ram), as only this way memory can be
>> onlined/offlined by user space and kdump to correctly detect the new
>> memory using udev events."
>>
>> Maybe we should even go a step further and call this
>>
>> MHP_SYSTEM_RAM
>>
>> Because that is what it is right now.
> 
> I agree that that is nicer explanation, and I would not mind to add it.
> In the end, the more information and commented code the better.
> 
> But I am not really convinced by MHP_SYSTEM_RAM name, and I think we should stick
> with MHP_MEMBLOCK_API because it represents __what__ is that flag about and its
> function, e.g: create memory block devices.

This nicely aligns with the sub-section memory add support discussion.

MHP_MEMBLOCK_API immediately implies that

- memory is used as system ram. Memory can be onlined/offlined. Markers
  at sections indicate if the section is online/offline.
- memory has to follow certain restrictions (alignment + size multiple
  of memory block size)

IOW, if some ZONE_DEVICE memory would set this flag, very bad things
will happen. Especially, device memory with memory block devices should
also result in quite some issues (I remember it is checked somewhere).

System ram added without MHP_MEMBLOCK_API? What would happen? Memory can
never be onlined.

I feel like mixing these two interfaces - adding system memory vs.
adding device memory wasn't the best design choice. Lot of parameters to
set, but the some parameters are actually mutually exclusive. Especially
memory block devices are a difference.

Maybe having actual function cal variants like

__add_system_memory / arch_add_system_memory ...

and

__add_device_memory / arch_add_device_memory

would make things clearer. To me, it feels like we are trying to squeeze
too many different things into one function call path, allowing people
do do things that shouldn't be done.

Any opinions on the design/direction on these interfaces in general? I
don't see us moving away from memory block devices for system ram. But I
am seeing us moving towards sub-section hot-add support for anything not
system ram.

> 
>>> @@ -1102,6 +1102,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
>>>  	u64 start, size;
>>>  	bool new_node = false;
>>>  	int ret;
>>> +	struct mhp_restrictions restrictions = {};
>>
>> I'd make this the very first variable.
>>
>> Also eventually
>>
>> struct mhp_restrictions restrictions = {
>> 	.restrictions = MHP_MEMBLOCK_API
>> };
> 
> It might be more right.
> Actually, that is the way we tend to pre-initialize fields in structs.
> 
> About the identation, I  am really puzzled, I checked my branch and I
> cannot see any space that should be a tab.
> Maybe it got screwed up when sending it.

It's not about spaces that should be tabs, rather about how many tabs to
use. But this is really just nit picking, because it usually directly
jumps into my eyes :) On vim with tabstop=8 it didn't look right.

> 
> Anyway, thanks for the feedback David ;-)
> 


-- 

Thanks,

David / dhildenb

