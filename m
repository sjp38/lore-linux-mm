Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3254FC282DE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:01:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1FC32075C
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 09:01:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1FC32075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7288D6B0008; Wed,  5 Jun 2019 05:01:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D9A96B000A; Wed,  5 Jun 2019 05:01:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A2F26B000C; Wed,  5 Jun 2019 05:01:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 38D7B6B0008
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 05:01:04 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id w184so5960549qka.15
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 02:01:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=1S3h02Wt9Ql/6FcYF2YgKT0Aqb2sOu0OOilZ8jc3BV4=;
        b=B6AEO64XJrfCIfIVBVXT8lufhZqDyZOxU9nanKG7kXa/EN+VR5NXt5j9a2n3VAdYce
         6SOa3JZtKQnFjI0MwJ4HlUoZNIcxChKtUT2R/HX9LeiYdwB4VAo8x40OJKLYxN1HJaHH
         GFPWGACMw7LQ+sHwCT/5SPNzMMqLyh2yH3kviNZEHAzo1XkkYx1gm5p4hmIIulYb4TlA
         SYOGHL826Fy1NWPX3Q9ZHjszECE8AyPXud0p1tXjKDcy+n2CkPOdsu/bsJa0Q5URkS9G
         aYkCJFLw2GdSxkzdg7M6VTKdRUun+sUpOtwwZKv2P7VKm9l3Wc7X9btLSbod8AHcruv9
         9h4A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUvKEXqJzrsVYL2CDKCmGBXdQH9v6QYBKl++Q1ipS+qUyrQ+91Y
	DMkRN7yydPGisXoaSLyIEH1ocUXA4BtMiZeh1veLngYqAM5wE/PT9R091T6JsFXlR2tmD/ixei8
	vzZq9T2I8bQ+GiQN0Ag3zlZREkKnvIv2H5xbDPlz5sAclY06+PByaSfR2yVO9tnnp9Q==
X-Received: by 2002:ac8:88e:: with SMTP id v14mr32200087qth.214.1559725263996;
        Wed, 05 Jun 2019 02:01:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzJISWHWPPK8HdCd5IEP7eTteU+TlD/3/WhL51iaKp0VpABdAHv15KggS6Zr0V1xaIrdwuD
X-Received: by 2002:ac8:88e:: with SMTP id v14mr32200023qth.214.1559725263375;
        Wed, 05 Jun 2019 02:01:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559725263; cv=none;
        d=google.com; s=arc-20160816;
        b=c+1/+aLhDHNwt17MMkMLD9d0ZO0VZ6ZKFwjjui+E3igOtI8rvviC3YwNxje6ofwebk
         BB3dtpKtnETKKihYTTT7Brk7nrmlKT6/wxd4kSzXmBOUXiPBwxH6t6b2WfR7Sezjj+AT
         6wsf2mp5XPk2zaBd1hidrjn6DkhlTlUPh5lp+giKKJhNRT9g6yOQx9ha6YwgaljpL4XP
         TGv5+bCoG4kou3EBUtk08SDg31ASPNYucQtqSaaM/hGHzl8w7XQDvsBjJYUsxkFd8pmm
         FDVfO0q/DNuFY9IEtYqX3YahPfI3NwtBUa7PivFqcrs35MCgRtic22Rl6dwBJntqncT3
         yv8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=1S3h02Wt9Ql/6FcYF2YgKT0Aqb2sOu0OOilZ8jc3BV4=;
        b=PHeL5OR0d8au+aeu4kCvf1TF9HFl7dypz9gf+HISaswQDyo0+uByi8iIWPgbQj52YC
         N+2IIJ7eCA7WWgdvClFJ3qm5SJ4P0osCswgGo0woqNR4wrUlIKeYbWlVgUq3arVfNNd3
         8/4t9nPLNz8tV4jxfJ/HN/CYObOBA4i0SbLnMo0JwxHp9HBus1HvTrsNj4lLCDulYcco
         +Ex9CIMM8+gX+7JEkIqSh62inehSLKVegN5xGurd3XvV5vecgnlW/1OSx/dF5Zq0mWaZ
         88Jh0UEKLzJMNepjT/f/W+kkCVWZzv6yburbFGBxR4eHBN17iEyNeCs/87dpTV5bcTxd
         WE/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n48si6960754qtc.312.2019.06.05.02.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 02:01:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E0E3030C0DD6;
	Wed,  5 Jun 2019 09:00:36 +0000 (UTC)
Received: from [10.36.118.48] (unknown [10.36.118.48])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C8C0E5C225;
	Wed,  5 Jun 2019 09:00:29 +0000 (UTC)
Subject: Re: [PATCH v3 09/11] mm/memory_hotplug: Remove memory block devices
 before arch_remove_memory()
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Igor Mammedov
 <imammedo@redhat.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>,
 Andrew Banman <andrew.banman@hpe.com>, Ingo Molnar <mingo@kernel.org>,
 Alex Deucher <alexander.deucher@amd.com>,
 "David S. Miller" <davem@davemloft.net>, Mark Brown <broonie@kernel.org>,
 Chris Wilson <chris@chris-wilson.co.uk>, Oscar Salvador <osalvador@suse.de>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pavel.tatashin@microsoft.com>, Arun KS <arunks@codeaurora.org>,
 Mathieu Malaterre <malat@debian.org>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-10-david@redhat.com>
 <20190604220715.d4d2ctwjk25vd5sq@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <38b8b004-9a26-e4ba-d8e3-a41c8fcc51c1@redhat.com>
Date: Wed, 5 Jun 2019 11:00:28 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190604220715.d4d2ctwjk25vd5sq@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 05 Jun 2019 09:00:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05.06.19 00:07, Wei Yang wrote:
> On Mon, May 27, 2019 at 01:11:50PM +0200, David Hildenbrand wrote:
>> Let's factor out removing of memory block devices, which is only
>> necessary for memory added via add_memory() and friends that created
>> memory block devices. Remove the devices before calling
>> arch_remove_memory().
>>
>> This finishes factoring out memory block device handling from
>> arch_add_memory() and arch_remove_memory().
>>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Andrew Banman <andrew.banman@hpe.com>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Alex Deucher <alexander.deucher@amd.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: Mark Brown <broonie@kernel.org>
>> Cc: Chris Wilson <chris@chris-wilson.co.uk>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Pavel Tatashin <pavel.tatashin@microsoft.com>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Reviewed-by: Dan Williams <dan.j.williams@intel.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> drivers/base/memory.c  | 37 ++++++++++++++++++-------------------
>> drivers/base/node.c    | 11 ++++++-----
>> include/linux/memory.h |  2 +-
>> include/linux/node.h   |  6 ++----
>> mm/memory_hotplug.c    |  5 +++--
>> 5 files changed, 30 insertions(+), 31 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 5a0370f0c506..f28efb0bf5c7 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -763,32 +763,31 @@ int create_memory_block_devices(unsigned long start, unsigned long size)
>> 	return ret;
>> }
>>
>> -void unregister_memory_section(struct mem_section *section)
>> +/*
>> + * Remove memory block devices for the given memory area. Start and size
>> + * have to be aligned to memory block granularity. Memory block devices
>> + * have to be offline.
>> + */
>> +void remove_memory_block_devices(unsigned long start, unsigned long size)
>> {
>> +	const int start_block_id = pfn_to_block_id(PFN_DOWN(start));
>> +	const int end_block_id = pfn_to_block_id(PFN_DOWN(start + size));
>> 	struct memory_block *mem;
>> +	int block_id;
>>
>> -	if (WARN_ON_ONCE(!present_section(section)))
>> +	if (WARN_ON_ONCE(!IS_ALIGNED(start, memory_block_size_bytes()) ||
>> +			 !IS_ALIGNED(size, memory_block_size_bytes())))
>> 		return;
>>
>> 	mutex_lock(&mem_sysfs_mutex);
>> -
>> -	/*
>> -	 * Some users of the memory hotplug do not want/need memblock to
>> -	 * track all sections. Skip over those.
>> -	 */
>> -	mem = find_memory_block(section);
>> -	if (!mem)
>> -		goto out_unlock;
>> -
>> -	unregister_mem_sect_under_nodes(mem, __section_nr(section));
>> -
>> -	mem->section_count--;
>> -	if (mem->section_count == 0)
>> +	for (block_id = start_block_id; block_id != end_block_id; block_id++) {
>> +		mem = find_memory_block_by_id(block_id, NULL);
>> +		if (WARN_ON_ONCE(!mem))
>> +			continue;
>> +		mem->section_count = 0;
> 
> Is this step necessary?

It's what the previous code does, it might not be - I'll leave it like
that for now. As mentioned in another reply, I might remove the
section_count completely, eventually.

-- 

Thanks,

David / dhildenb

