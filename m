Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D659C04AB3
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:59:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B188C21783
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 14:59:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B188C21783
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 349D66B0003; Thu,  9 May 2019 10:59:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FA9E6B0006; Thu,  9 May 2019 10:59:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C1B06B0007; Thu,  9 May 2019 10:59:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EA74F6B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 10:59:03 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id k15so2343256qki.4
        for <linux-mm@kvack.org>; Thu, 09 May 2019 07:59:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=z+NulanEzf4+PvS+UBgCUIaValDqqTNwvRrELFBoInE=;
        b=J+PfjR8RIPiXuUfwILs8FszFIHBV1l4UEiMeTjnAArDHR4XzZjxI+nwWu5NB28Sl58
         X8oI5HAIzSKX2gVzxTS5l6q2CkubWrCW7GzvW80CMKkG9uq28yMxMVT0Zin3iNBGXFO8
         MLiRuFpGYq3gMbW5jD5ouzMUjORn+pfodW8wzrytOFAGT304IOuedfbs9I8GGmG3ItTi
         FhTm6/L6OlAqp0WODUnfgi06t7iBoXiSOLAfhoxRhI0yuF/zqKwBiRNFx+7PrHhP3gsN
         fDOH3qYHCOaYqdKL+Z7V7Sp/5l4fvjNKljy49lwNy9OyJkP8THRKFiFuC0igkzWEoHpp
         USxQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU7FJj6MKaBGzWs2Lz2LE0hoym8dDdtGd9gEzyG6lycqTUtNGcd
	ZsEn0tfw2YNbgJVkMTfAg5zzc6DSLPoi/hJjlIMzxQVEKhFkp2tvFh6KbmCQK23577aiDiKjnKG
	K7b/rMmVnFmm4V/lwyAnKErnhb6iMOwwpf6AQw9inMKdB0X9oKUiTqFa/n2rzmPsrEw==
X-Received: by 2002:aed:3f57:: with SMTP id q23mr4066000qtf.285.1557413943614;
        Thu, 09 May 2019 07:59:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc4sektiwybK0gefpJd+T+ZEGS7ybgmrtOSqT1RWtS5XYZm5L77CI92Rb9UXpGb/7b94qA
X-Received: by 2002:aed:3f57:: with SMTP id q23mr4065901qtf.285.1557413942456;
        Thu, 09 May 2019 07:59:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557413942; cv=none;
        d=google.com; s=arc-20160816;
        b=OLWIHPDNsUB+6zj+m0cJE4n7wDgHCGynivYNOQFdnGrbmD/nGbcCV4Ip+ByMaDZv2I
         7KWGvM1m7kmcBOV65TebTzpEfYue9OLG3wdLTbMG/s1U5e/5dD17PiFw8dmH8NwnsGmd
         gTMmbB3R04YQqgoTSrEVSbEDYjOJBHFQGue8KeZgyZv0e/OSVhYFcOy3fFf8fTtku+Au
         wb9cq2V9SM0GuBE/84dGzbcw/RDbPE0BpU46olfBFWq/mTDvkKXfJt2t717mZfv0ibmm
         7omW/OTopLhWwlDJGJwXhZt3RMTdJh3w/aWaOHnl+iEUBvAnFDlWiSF7DkFkeFnYytqG
         fu9w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=z+NulanEzf4+PvS+UBgCUIaValDqqTNwvRrELFBoInE=;
        b=PbyYq9j1F6drlppdCtWH2s6KWBVdBwGE76fk5O4ihuOcrdh6iGITwdG7U9xKNsxozR
         1B2z0sfSTPtEVgsBw5Htwx5dwx6i9KQKyaRWRTM0PkUEMhbSbiNfhJcy5R2roGRM0HGS
         Uw1bzY3ktpIAr6GtTTaMpHtWy7c9O7x32dwP0YnHyZ9O+nfxsFuN6TkKXdQhngr8llIo
         /GQqta7iWnW5Dk+xWx1BYshXzlOmV63zDmZEqFKktPEX/lIQwgHflp+keJp7YUvwNJ61
         zkPlFUNmSRFoQ2slEWQHrymOCVEG/66JoGKK+P6BNMlX32ZoTuqtSutkVqbftD3jQ/UE
         ISHw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 19si1539305qtx.260.2019.05.09.07.59.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 07:59:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 610A53086200;
	Thu,  9 May 2019 14:59:01 +0000 (UTC)
Received: from [10.36.117.56] (ovpn-117-56.ams2.redhat.com [10.36.117.56])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 077175D717;
	Thu,  9 May 2019 14:58:56 +0000 (UTC)
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
 <20190509143151.zexjmwu3ikkmye7i@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <28071389-372c-14eb-1209-02464726b4f0@redhat.com>
Date: Thu, 9 May 2019 16:58:56 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190509143151.zexjmwu3ikkmye7i@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 09 May 2019 14:59:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09.05.19 16:31, Wei Yang wrote:
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
> 
> One trivial suggestion about the function name.
> 
> For memory_block device, sometimes we use the full name
> 
>     find_memory_block
>     init_memory_block
>     add_memory_block
> 
> But sometimes we use *nick* name
> 
>     hotplug_memory_register
>     register_memory
>     unregister_memory
> 
> This is a little bit confusion.
> 
> Can we use one name convention here?

We can just go for

crate_memory_blocks() and free_memory_blocks(). Or do
you have better suggestions?

(I would actually even prefer "memory_block_devices", because memory
blocks have different meanins)

> 
> [...]
> 
>> /*
>> @@ -1106,6 +1100,13 @@ int __ref add_memory_resource(int nid, struct resource *res)
>> 	if (ret < 0)
>> 		goto error;
>>
>> +	/* create memory block devices after memory was added */
>> +	ret = hotplug_memory_register(start, size);
>> +	if (ret) {
>> +		arch_remove_memory(nid, start, size, NULL);
> 
> Functionally, it works I think.
> 
> But arch_remove_memory() would remove pages from zone. At this point, we just
> allocate section/mmap for pages, the zones are empty and pages are not
> connected to zone.
> 
> Function  zone = page_zone(page); always gets zone #0, since pages->flags is 0
> at  this point. This is not exact.
> 
> Would we add some comment to mention this? Or we need to clean up
> arch_remove_memory() to take out __remove_zone()?

That is precisely what is on my list next (see cover letter).This is
already broken when memory that was never onlined is removed again.
So I am planning to fix that independently.


-- 

Thanks,

David / dhildenb

