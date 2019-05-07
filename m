Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA4D3C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:27:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79F2920656
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 21:27:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79F2920656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22F8B6B0271; Tue,  7 May 2019 17:27:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1E0286B0272; Tue,  7 May 2019 17:27:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A9A16B0273; Tue,  7 May 2019 17:27:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE56F6B0271
	for <linux-mm@kvack.org>; Tue,  7 May 2019 17:27:23 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id q127so19633120qkd.2
        for <linux-mm@kvack.org>; Tue, 07 May 2019 14:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=vweAD4TKhKSB+d5mhTllEtmRCtlok88/U7lRCjz+U+s=;
        b=Rjmx2O2WJ02wJQI38FTm5AnJuJETbTZd25TnBAzYF/m8nPI0itQjJys3pWmfT5Jwf4
         wJ9EY0572ukhi5DBO+jUaApGYfG7/DDuSkAq5bTWqTMqAhMFhCCYb1dzDi7wv6CHaQVb
         nLYvfn9H6MRA6qRKxZSeYcXNMAMxx3o87yUvlODNWHeNRzYEiZSfF9Tr1eh6Vedvwg9e
         E2G0suokAoDJwDzV8QRX9y5SQOAc9lqXVGc6yCnLCwHOcSKMuIxj0rg3YZckf+9bkh3M
         XKW6UtlhBf4BNZeEkgjMRlJxKO/3uzMNnqa/rGa7R+TU5GxxPcEkf56VoT8FF0BOWizn
         nphw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWNJRE/ANX4xTyV8AEJOyglpmMvXqiDzn5+c9enF0Z/h859hws3
	nFaAWwJmrlUSHo8+E/3YOU24u8j6jUKhBL78xCDz2T1PhGfLo54LAFil6HDrkrcm++PQ7tMuq9x
	5J56HsAxxoO58ktQ7RNzNfLWlQqzn6pjAPkW+2n0VZKFJZj2bbfZ32Wng/vNtNFn9cA==
X-Received: by 2002:ac8:2228:: with SMTP id o37mr29764747qto.200.1557264443629;
        Tue, 07 May 2019 14:27:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztvlmgXqBymg8ekTumQvNpJmybmWd15qsIgNMwaeWnviYWwEZdpw0UjBLaEUnRzsbMicks
X-Received: by 2002:ac8:2228:: with SMTP id o37mr29764704qto.200.1557264443020;
        Tue, 07 May 2019 14:27:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557264443; cv=none;
        d=google.com; s=arc-20160816;
        b=KWYmty99AemUDynj4VMJDeW9WJtB6QtR8t6/8wSblK0ayPPBvS98WS3KoKJFfp7anI
         rAzq2jW0A0cFIjmf318X5vMblgOd6KhYnVF+5O3Pce/vAjWPP1SyvmkE8FVa7Y1r7pn1
         uVt8f/9niyFBd/M0ZBMSPJIF7lADTdLJLC/FOHE9S/rRUuiJeQLkyMZUg0snkBAPrI41
         HP3XHJ6BY7hrt0g2XdXC8V+w9sxEtIfUSq3F+PPP33u7i1OlqUIFjv+IWsjzeYLme3OC
         3gz6FrkbSqqWjAFXdZ+fYul06GgZ0j//rYxe61ko0CRtTlg5/GXfnHo4oyBOGjU9ttOm
         pyzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=vweAD4TKhKSB+d5mhTllEtmRCtlok88/U7lRCjz+U+s=;
        b=p6eG5kIPac2r06VQEWzkZPuojuM2RQxWbRad9bx/FE4UL6GIeCQ78VqoMkpQ2NdRht
         qwIbLfHXPUPM8mAHcykOekV7PGHqOKwVpDdq46BkX0/hiY4UDQBcSpNSoY/dOCL8OIuD
         QYISyngYt/ToZtHAuGfA8NVYbS0Tudz/2QDtYLO4rTX3yWEWu8IrLQYlWnkPw1gmKk8v
         oa2b/cBDcFdyJORkXRQq9RukNop6cK6+WYfSqqkqY4BU5SCamZl1K5M1hBNEjJbqe9n+
         +Y0CoWdkuY7Jr7QufVr8wyZ8G9db/NOBaDSR202lKApCqLwOF+M1rOsSj0Z5h7tpndpr
         o7vg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p38si870625qtp.338.2019.05.07.14.27.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 14:27:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 16D37308793B;
	Tue,  7 May 2019 21:27:22 +0000 (UTC)
Received: from [10.36.116.95] (ovpn-116-95.ams2.redhat.com [10.36.116.95])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5781A1001DDC;
	Tue,  7 May 2019 21:27:18 +0000 (UTC)
Subject: Re: [PATCH v2 4/8] mm/memory_hotplug: Create memory block devices
 after arch_add_memory()
To: Dan Williams <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 linux-ia64@vger.kernel.org, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>,
 linux-s390 <linux-s390@vger.kernel.org>, Linux-sh
 <linux-sh@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 "mike.travis@hpe.com" <mike.travis@hpe.com>, Ingo Molnar <mingo@kernel.org>,
 Andrew Banman <andrew.banman@hpe.com>, Oscar Salvador <osalvador@suse.de>,
 Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 Qian Cai <cai@lca.pw>, Wei Yang <richard.weiyang@gmail.com>,
 Arun KS <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
References: <20190507183804.5512-1-david@redhat.com>
 <20190507183804.5512-5-david@redhat.com>
 <CAPcyv4jiVyaPbUrQwSiy65xk=EegJwuGSDKkVYWkGiTJz847gg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <a41438f2-6bac-a2ad-96ec-234762c1cd37@redhat.com>
Date: Tue, 7 May 2019 23:27:17 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jiVyaPbUrQwSiy65xk=EegJwuGSDKkVYWkGiTJz847gg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Tue, 07 May 2019 21:27:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>> +static void unregister_memory(struct memory_block *memory)
>> +{
>> +       BUG_ON(memory->dev.bus != &memory_subsys);
> 
> Given this should never happen and only a future kernel developer
> might trip over it, do we really need to kill that developer's
> machine? I.e. s/BUG/WARN/? I guess an argument can be made to move
> such a change that to a follow-on patch since you're just preserving
> existing behavior, but I figure might as well address these as the
> code is refactored.

I assume only

if (WARN ...)
	return;

makes sense then, right?

> 
>> +
>> +       /* drop the ref. we got via find_memory_block() */
>> +       put_device(&memory->dev);
>> +       device_unregister(&memory->dev);
>> +}
>> +
>>  /*
>> - * need an interface for the VM to add new memory regions,
>> - * but without onlining it.
>> + * Create memory block devices for the given memory area. Start and size
>> + * have to be aligned to memory block granularity. Memory block devices
>> + * will be initialized as offline.
>>   */
>> -int hotplug_memory_register(int nid, struct mem_section *section)
>> +int hotplug_memory_register(unsigned long start, unsigned long size)
>>  {
>> -       int ret = 0;
>> +       unsigned long block_nr_pages = memory_block_size_bytes() >> PAGE_SHIFT;
>> +       unsigned long start_pfn = PFN_DOWN(start);
>> +       unsigned long end_pfn = start_pfn + (size >> PAGE_SHIFT);
>> +       unsigned long pfn;
>>         struct memory_block *mem;
>> +       int ret = 0;
>>
>> -       mutex_lock(&mem_sysfs_mutex);
>> +       BUG_ON(!IS_ALIGNED(start, memory_block_size_bytes()));
>> +       BUG_ON(!IS_ALIGNED(size, memory_block_size_bytes()));
> 
> Perhaps:
> 
>     if (WARN_ON(...))
>         return -EINVAL;
> 

Yes, guess this souldn't hurt.

>>
>> -       mem = find_memory_block(section);
>> -       if (mem) {
>> -               mem->section_count++;
>> -               put_device(&mem->dev);
>> -       } else {
>> -               ret = init_memory_block(&mem, section, MEM_OFFLINE);
>> +       mutex_lock(&mem_sysfs_mutex);
>> +       for (pfn = start_pfn; pfn != end_pfn; pfn += block_nr_pages) {
>> +               mem = find_memory_block(__pfn_to_section(pfn));
>> +               if (mem) {
>> +                       WARN_ON_ONCE(false);
> 
> ?? Isn't that a nop?

Yes, that makes no sense :)

Thanks!

-- 

Thanks,

David / dhildenb

