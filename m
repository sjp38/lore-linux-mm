Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 447E2C04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:05:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 035682053B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:05:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 035682053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 78F236B0003; Thu,  9 May 2019 10:05:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 741A66B0006; Thu,  9 May 2019 10:05:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 608746B0007; Thu,  9 May 2019 10:05:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1216B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 10:05:50 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id q17so2128953qkc.23
        for <linux-mm@kvack.org>; Thu, 09 May 2019 07:05:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=QTnQ+klPzvR+UcGoB3JFoDj1rs7l7sYB5F8smvnuBqk=;
        b=WltANLXZ6UxUHlBg6X8cRtfaK9tw+zuTf/WnLLx33U1y2Z6xxLC2CfSKzr/TwrRIB+
         snLgy0x0NtVWE+t1i3IFZ2GVhj7VVTcYXCYbf7VYp+zzwFKsFYR70gPoN1/HhE2vDYrd
         VNPrN/ENsnnmfP+PlhGz8vuEzrzMeZH82af0I6yNKWi0QWciCSZ+WHfr2sAK5MFLDh57
         i6Jqnss514Ekiw+OyqjaY/aGlTWBt7aRgGEtugA80t7AuZdpeC+kKNBOjuFcS5QrkUv6
         N594e+OQ6MYRQ24Cd8UapjjjYWiMwp+nhRaiiOHwyGX0rHQ6jbyWqQMxcTC5fCW56++2
         /Z3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXDqMOnNA7wIS0y0osunlxF0hydjSk8m0T3TeB6jHqs9BPf68rS
	A0Igc5bMIQhgY30whFSYTNVwIp9a8IygJjVMamenN7RtONegGB9YFGqq6v8QuUjmL6rljqpuAFP
	pOwBG+e6+84/FUk8dU6v5WTKiDVPYzE8OZMGM94DKPc0/mR/Fj11vQbotZAoyp5JcjA==
X-Received: by 2002:ac8:2c89:: with SMTP id 9mr3686370qtw.287.1557410749963;
        Thu, 09 May 2019 07:05:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFqDWcDiHj2QE8dvrHlX8KViqo1J/Wi5L8PGqa6Xtu3HajxPVu7xAhq1bScmVExGFTWvp1
X-Received: by 2002:ac8:2c89:: with SMTP id 9mr3686299qtw.287.1557410749268;
        Thu, 09 May 2019 07:05:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557410749; cv=none;
        d=google.com; s=arc-20160816;
        b=tKEX403lfLOGgVI7ai6ZbYMyhKGQ25hKUXg3yW4VZ5WwvSAoAV2wded5+8xHMqCu6D
         nG28C0HOV1yhD6kDBRR+NuDV0+ERhCWw0NQGHdKrxGHf+h5/1OB9wV4yQPYQ3Udz0fhm
         3CuehuuZWZvez17iQgd93bXFczW2ncXTah7EXpapWqgqY4SEI0bMY1aMM1EYPPeULd8I
         O1u5eisYK7+rtNDlreM5M4D24QWQU0I4JKqrI2x0k5FLtjmmSKmA4YLpxnupy57hs3MY
         X4bQeVVfxtMpdyuR2JPKQB3ZLMrCQlQbkiMxBf1rFBiWGMmJ0PltHM2f3DtoM+HzoyL4
         dA+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=QTnQ+klPzvR+UcGoB3JFoDj1rs7l7sYB5F8smvnuBqk=;
        b=kj4Y7W8N35ZQWyezPCHnYxUeTOdvxyY/TlEVj0q/d45ivjM9RGXzIrYrmuWdV5a9i5
         XvUND1nkoMQf3CVjouJqFnnrGkSXq92/7UfnsyRl6buodmk+eRHBbhFSQqOxksyLRVpa
         t3pnQCu74lRGV/FNeyUXyj2Z8O9qDfXq1CEgQIJPu5crBxb495fLfjQHlsHNWVaodGzx
         8r4wU4mcP3RvV+QOCG69B35gnWSrB9XGz/wTOHEUMPnZZ8lcuiIcCAvkyfMQwgWJ8LBW
         wPIRXq98npgj6nWBdcvxM0ngBZhrjkf1rB0E31Bg51W2hb1EJ3+Zkq39MAIfrL6+7hzZ
         etuA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n31si1432870qtb.300.2019.05.09.07.05.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 07:05:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 258DAC075D75;
	Thu,  9 May 2019 14:05:38 +0000 (UTC)
Received: from [10.36.117.56] (ovpn-117-56.ams2.redhat.com [10.36.117.56])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 73DB110027C1;
	Thu,  9 May 2019 14:05:30 +0000 (UTC)
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 akpm@linux-foundation.org, Dan Williams <dan.j.williams@intel.com>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>,
 Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Qian Cai <cai@lca.pw>, Arun KS <arunks@codeaurora.org>,
 Mathieu Malaterre <malat@debian.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <20190509135533.6xok3v7rxxaohc77@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a8e96df6-dc6d-037f-491c-92182d4ada8d@redhat.com>
Date: Thu, 9 May 2019 16:05:29 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190509135533.6xok3v7rxxaohc77@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Thu, 09 May 2019 14:05:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.05.19 15:55, Wei Yang wrote:
> On Tue, May 07, 2019 at 08:38:00PM +0200, David Hildenbrand wrote:
>> Only memory to be added to the buddy and to be onlined/offlined by
>> user space using memory block devices needs (and should have!) memory
>> block devices.
>>
>> Factor out creation of memory block devices Create all devices after
>> arch_add_memory() succeeded. We can later drop the want_memblock parameter,
>> because it is now effectively stale.
>>
>> Only after memory block devices have been added, memory can be onlined
>> by user space. This implies, that memory is not visible to user space at
>> all before arch_add_memory() succeeded.
>>
>> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
>> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
>> Cc: David Hildenbrand <david@redhat.com>
>> Cc: "mike.travis@hpe.com" <mike.travis@hpe.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Ingo Molnar <mingo@kernel.org>
>> Cc: Andrew Banman <andrew.banman@hpe.com>
>> Cc: Oscar Salvador <osalvador@suse.de>
>> Cc: Michal Hocko <mhocko@suse.com>
>> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
>> Cc: Qian Cai <cai@lca.pw>
>> Cc: Wei Yang <richard.weiyang@gmail.com>
>> Cc: Arun KS <arunks@codeaurora.org>
>> Cc: Mathieu Malaterre <malat@debian.org>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> drivers/base/memory.c  | 70 ++++++++++++++++++++++++++----------------
>> include/linux/memory.h |  2 +-
>> mm/memory_hotplug.c    | 15 ++++-----
>> 3 files changed, 53 insertions(+), 34 deletions(-)
>>
>> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
>> index 6e0cb4fda179..862c202a18ca 100644
>> --- a/drivers/base/memory.c
>> +++ b/drivers/base/memory.c
>> @@ -701,44 +701,62 @@ static int add_memory_block(int base_section_nr)
>> 	return 0;
>> }
>>
>> +static void unregister_memory(struct memory_block *memory)
>> +{
>> +	BUG_ON(memory->dev.bus != &memory_subsys);
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
>> +int hotplug_memory_register(unsigned long start, unsigned long size)
>> {
>> -	int ret = 0;
>> +	unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
>> +	unsigned long start_pfn = PFN_DOWN(start);
>> +	unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>> +	unsigned long pfn;
>> 	struct memory_block *mem;
>> +	int ret = 0;
>>
>> -	mutex_lock(&mem_sysfs_mutex);
>> +	BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
>> +	BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
>>
>> -	mem = find_memory_block(section);
>> -	if (mem) {
>> -		mem->section_count++;
>> -		put_device(&mem->dev);
>> -	} else {
>> -		ret = init_memory_block(&mem, section, MEM_OFFLINE);
>> +	mutex_lock(&mem_sysfs_mutex);
>> +	for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
>> +		mem = find_memory_block(__pfn_to_section(pfn));
>> +		if (mem) {
>> +			WARN_ON_ONCE(false);
> 
> One question here, the purpose of WARN_ON_ONCE(false) is? Would we trigger
> this?

Would happen if something goes terribly wrong. We might want to remove
this once we are sure this will not happen.

I replaced it in the meantime by a

if (WARN_ON_ONCE(mem)) {
	put_device(&mem->dev);
	ret = -EEXIST;
	break;
}

> 
>> +			put_device(&mem->dev);
>> +			continue;
>> +		}
>> +		ret = init_memory_block(&mem, __pfn_to_section(pfn),
>> +					MEM_OFFLINE);
>> 		if (ret)
>> -			goto out;
>> -		mem->section_count++;
>> +			break;
>> +		mem->section_count = memory_block_size_bytes() /
>> +				     MIN_MEMORY_BLOCK_SIZE;
> 
> Maybe we can leverage sections_per_block variable.

Most certainly if it does what I think it does :) thanks!


-- 

Thanks,

David / dhildenb

