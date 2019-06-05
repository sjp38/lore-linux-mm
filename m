Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97CDEC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 08:58:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 50B2E2075C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 08:58:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 50B2E2075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE2326B0008; Wed,  5 Jun 2019 04:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D92DB6B000A; Wed,  5 Jun 2019 04:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C59AE6B000C; Wed,  5 Jun 2019 04:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id A575B6B0008
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 04:58:52 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q13so9328750qtj.15
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 01:58:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=cLIZ/ljclXWMpVGqRisKX6seLgSUGyAJbPYt6glwvHk=;
        b=mc197g2dS8f0OMIoTniXxlx2Jvh4+NnXGYwSNmvRKUPNG5sdzyKwWIus7AWXIH2WCq
         eoN1/5eAKr5ZbhI3Ja5unFkpRvqUS3qhPKn4AMVtfar85v/4DspAd1HEXKd8Ye0EbRJS
         2sNBqlzxa6DxSDPxoiqQrLJYN/SRtw7GxoktKHfjQBewF6cYMyma6UaqElWBRe837jAf
         4GX/QxwP2vH+8HTC63QwFP6WgSWJPT8dw7lDgBidOyvvWlJy/PIjeXmuqo+9BUErLOqV
         brgvVLJ6FAuL795PmKV/Nwx+WgJx8wDlfZrUEkSGhxTIqZaFK6VxwEiEuXxz8Yd5Lswc
         oj6w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW/Vv2T4Xshv4ppb+uJvWWW0SvDsqon4Kz3auHScMyVUeWfCxO1
	rPmjLbBs72VgoLBC3mD/ln1v6XviBjRL6RUrbgFWFBgeIv3vV1xAPIvFjkI2aQKIZjjLL78vG3I
	Q/FQqSwrQucmSqDfh8bKN8VR2efG1AefOjmZ/F68UZlghiM7rYV/kY+lFKr3BKZOKbw==
X-Received: by 2002:aed:3bb5:: with SMTP id r50mr31722682qte.89.1559725132388;
        Wed, 05 Jun 2019 01:58:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy+HlyiaHcwYPUn0kS8C4QDbTNU5brRwvhE0b48lf5B2O4c24xuNzmPen/trNTz7SkAr+P
X-Received: by 2002:aed:3bb5:: with SMTP id r50mr31722628qte.89.1559725131482;
        Wed, 05 Jun 2019 01:58:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559725131; cv=none;
        d=google.com; s=arc-20160816;
        b=gL/kIj8WeFMfn55wELedO1NVkI0KLf/eG0hnNI7HJgDGvGDe7x+589GUusvmFvD+Iy
         HiaifHUJMX5TQbBEiaDMVeKqyi/o0HehJWAyRnCBZgmQTziCEcsPWLAI+dcOG7YLVc8W
         MVAu0G/SXW7w/OVl59zbVus7xd4cMZYPdrTeAl4ZTrQSVps5yhb50HU1uncGHGQoIGWM
         +tcpfSFQRL12TtQunWiUh8DB35MRGISmmTeh8/XfQ7ul5GJJUBcclkjlZocdCpD6ZH13
         y98pTM/kg6cf8t32IWTm9ZIV2JnOdFeGw4VFQrBMpZb//q1a5LAZJuEBEuwLBCdnintE
         wDwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=cLIZ/ljclXWMpVGqRisKX6seLgSUGyAJbPYt6glwvHk=;
        b=S8enVt4F/SHodsz15LtZFX9KAiCQ38MUPbkE6VZ2+FXj5cISx4DxwDdSBPkRblPBg5
         fL7qKdB0/PBzUIVNaR53eAgXChaABgdF0TqxntqxBXvwWqsz0m4Ufyewq/KycwbAWueG
         kGtOFDtVxwtRg/yc9K9lcFSc0zz0V2PHvw+2g7ml+uDLVjQT1iyA8zQlbX2ZptVHqskI
         jhh99ZKNQDXAUNvLQAyPXZLXoMFk+HJBlAwmE9uTVg9Th5uJReVwxeEc1O3nzDUZmUkO
         6mNfiIkabf0I6L1yGeSnAEMGJDOYBa8cJ8PojLL/8ejxXXpk/Vp4CR8rI10zygz72yKt
         AAPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c9si2682666qve.116.2019.06.05.01.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 01:58:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9D2A8B0CCB;
	Wed,  5 Jun 2019 08:58:36 +0000 (UTC)
Received: from [10.36.118.48] (unknown [10.36.118.48])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0A8321001E80;
	Wed,  5 Jun 2019 08:58:26 +0000 (UTC)
Subject: Re: [PATCH v3 07/11] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Igor Mammedov
 <imammedo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>,
 Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>,
 Mathieu Malaterre <malat@debian.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-8-david@redhat.com>
 <20190604214234.ltwtkcdoju2gxisx@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <f6523d67-cac9-1189-884a-67b6829320ba@redhat.com>
Date: Wed, 5 Jun 2019 10:58:26 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190604214234.ltwtkcdoju2gxisx@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 05 Jun 2019 08:58:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>> /*
>>  * For now, we have a linear search to go find the appropriate
>>  * memory_block corresponding to a particular phys_index. If
>> @@ -658,6 +670,11 @@ static int init_memory_block(struct memory_block **memory, int block_id,
>> 	unsigned long start_pfn;
>> 	int ret = 0;
>>
>> +	mem = find_memory_block_by_id(block_id, NULL);
>> +	if (mem) {
>> +		put_device(&mem->dev);
>> +		return -EEXIST;
>> +	}
> 
> find_memory_block_by_id() is not that close to the main idea in this patch.
> Would it be better to split this part?

I played with that but didn't like the temporary results (e.g. having to
export find_memory_block_by_id()). I'll stick to this for now.

> 
>> 	mem = kzalloc(sizeof(*mem), GFP_KERNEL);
>> 	if (!mem)
>> 		return -ENOMEM;
>> @@ -699,44 +716,53 @@ static int add_memory_block(int base_section_nr)
>> 	return 0;
>> }
>>
>> +static void unregister_memory(struct memory_block *memory)
>> +{
>> +	if (WARN_ON_ONCE(memory->dev.bus != &memory_subsys))
>> +		return;
>> +
>> +	/* drop the ref. we got via find_memory_block() */
>> +	put_device(&memory->dev);
>> +	device_unregister(&memory->dev);
>> +}
>> +
>> /*
>> - * need an interface for the VM to add new memory regions,
>> - * but without onlining it.
>> + * Create memory block devices for the given memory area. Start and size
>> + * have to be aligned to memory block granularity. Memory block devices
>> + * will be initialized as offline.
>>  */
>> -int hotplug_memory_register(int nid, struct mem_section *section)
>> +int create_memory_block_devices(unsigned long start, unsigned long size)
>> {
>> -	int block_id = base_memory_block_id(__section_nr(section));
>> -	int ret = 0;
>> +	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
>> +	int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
>> 	struct memory_block *mem;
>> +	unsigned long block_id;
>> +	int ret = 0;
>>
>> -	mutex_lock(&mem_sysfs_mutex);
>> +	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>> +			 !IS_ALIGNED(size, memory_block_size_bytes())))
>> +		return -EINVAL;
>>
>> -	mem = find_memory_block(section);
>> -	if (mem) {
>> -		mem->section_count++;
>> -		put_device(&mem->dev);
>> -	} else {
>> +	mutex_lock(&mem_sysfs_mutex);
>> +	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>> 		ret = init_memory_block(&mem, block_id, MEM_OFFLINE);
>> 		if (ret)
>> -			goto out;
>> -		mem->section_count++;
>> +			break;
>> +		mem->section_count = sections_per_block;
>> +	}
>> +	if (ret) {
>> +		end_block_id = block_id;
>> +		for (block_id = start_block_id; block_id != end_block_id;
>> +		     block_id++) {
>> +			mem = find_memory_block_by_id(block_id, NULL);
>> +			mem->section_count = 0;
>> +			unregister_memory(mem);
>> +		}
>> 	}
> 
> Would it be better to do this in reverse order?
> 
> And unregister_memory() would free mem, so it is still necessary to set
> section_count to 0?

1. I kept the existing behavior (setting it to 0) for now. I am planning
to eventually remove the section count completely (it could be
beneficial to detect removing of partially populated memory blocks).

2. Reverse order: We would have to start with "block_id - 1", I don't
like that better.

Thanks for having a look!

-- 

Thanks,

David / dhildenb

