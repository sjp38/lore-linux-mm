Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 52460C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:41:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00C63214AE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:41:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00C63214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92AE56B0007; Thu, 25 Apr 2019 03:41:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DB256B0008; Thu, 25 Apr 2019 03:41:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A1CC6B000A; Thu, 25 Apr 2019 03:41:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4F3B36B0007
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:41:28 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id c44so12056438qtb.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:41:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=xrDO0DuAzvbXY0cWgTlMXrt+STfmZ6QdGYVGqUn2648=;
        b=XMw6Y2lzBwHNMu0wzgtufp9zn+ElEFQf8nVXQGvMXl3AAU5V3/pmEG8NMuWxxmUwCa
         BbKISFpjH4T0Ef8m+zzJUOmSTlfaH6ilOt1E0nWxuuJ3S+TE1XEv4dAnpcb9OxPASWBf
         kML1A+6AnOJdq7OiDmAj4K6ld9evzKL0b60/sbNKf3yfrgS44f8YCtBsYMK4otyrXVht
         1bNfSOCX7Un6P2yqkymBNLlKoxPOris1mwxNvid1hVCZ3m+ea+w/QNuZANBybkW8pt0E
         L5kZ8/BQxmhJ4L/b+u4em4EPdtnt/BgWmwuOVA7duMSEpmtkWLWAhhOudAk5dfuYziFd
         yRCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXYKeVz1Fj8TuUzDixcsZl3BJlJf5xTPqCCtP8mvzSniCdG7aPU
	KQGPMEI+DKAz/7iaRCZ2cnAl3XSXyxjLEa8lv40GkxTByIvQ47h5zpSsWy+B+t3Gr4ayGqLrASZ
	+zLhqTGoHJmDb7BTsbIdluN1anFgpZMoNaLjjcNfjPCrHI11nFsq3zRirJVmjjyVydA==
X-Received: by 2002:a0c:9d82:: with SMTP id s2mr15510140qvd.152.1556178088024;
        Thu, 25 Apr 2019 00:41:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSpjDuVNa9iTEgc8GUKEUZ3232CiBTSB2JUjelGtA3vN93wqEvBxtdLu+YoUhhI3/YjZYm
X-Received: by 2002:a0c:9d82:: with SMTP id s2mr15510115qvd.152.1556178087462;
        Thu, 25 Apr 2019 00:41:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556178087; cv=none;
        d=google.com; s=arc-20160816;
        b=ygwYB6ud+3zPDx47t4q+CaXdK+DIhiYuGaUXj+JQ+9LTiW2M1ZRfcFCdJjNHTgV1bx
         zsIt7gJLMY4DyCGsjxADVTJ9oPboIrZOnJ492J8nB0X0UwNJHj+NNLadmm09cLJ6nCtv
         znNXCIjoTfrzRi+D6aQR2YbBPmkoNI2dlobZqdHgk9E5cPxtElkfd1aAo/w0wu2y+6IC
         VUMI78mTHUdwqZx4FywLB6pIGFi93AgrBPafQA710U/A+192v/tEb9bsGm6aAHg5p/3l
         BJv02CRV2wn8QBEQ+5ZR8fRaDxMC/+U+FcBgMHEjqfYtvyuyvZLMvSZFzFqBmDYNLfAY
         UB4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=xrDO0DuAzvbXY0cWgTlMXrt+STfmZ6QdGYVGqUn2648=;
        b=dDyyPp5XZ40TcQuAfKFF/R0NMYjKsNfu12SW5G1PDLs5chM87LlWGqOlZOSwzxav5l
         DdnNbhEpt/o6SBbuv4QO7BfWbCAEVlDKA+ozv28AtNituWlF3uQ03d8Opqk8+LHWinu6
         4Uvvve4vTw3zGFwl/wpHmTtWKCd3Lzs5ejODfmIroM8Pz9c1y7WbG7FGMssS0QCsDbW/
         aS4OHAahJJMr/9G55VA47iE3etqbOqRI/ZU0X4cZ5eA/2ZN91Z1f3Rg5kcRlTNsWIq6n
         WrzXtLnVf4qUEiD5TBOZyEjURZotmaVKxorQzN0XNWkTSgaou6Lg+EHvSEOW4GXCUMV8
         v8ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k9si7252280qke.34.2019.04.25.00.41.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:41:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 088BD2D813;
	Thu, 25 Apr 2019 07:41:26 +0000 (UTC)
Received: from [10.36.117.163] (ovpn-117-163.ams2.redhat.com [10.36.117.163])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 858D21001DE4;
	Thu, 25 Apr 2019 07:41:21 +0000 (UTC)
Subject: Re: [v2 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Pavel Tatashin <pasha.tatashin@soleen.com>,
 Dan Williams <dan.j.williams@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
 Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>,
 Dave Hansen <dave.hansen@linux.intel.com>,
 Keith Busch <keith.busch@intel.com>,
 Vishal L Verma <vishal.l.verma@intel.com>, Dave Jiang
 <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>,
 Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying"
 <ying.huang@intel.com>, Fengguang Wu <fengguang.wu@intel.com>,
 Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>,
 Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
References: <20190421014429.31206-1-pasha.tatashin@soleen.com>
 <20190421014429.31206-3-pasha.tatashin@soleen.com>
 <4ad3c587-6ab8-1307-5a13-a3e73cf569a5@redhat.com>
 <CAPcyv4h3+hU=MmB=RCc5GZmjLW_ALoVg_C4Z7aw8NQ=1LzPKaw@mail.gmail.com>
 <CA+CK2bDB5o4+NMc7==_ipVAZoEo7fdrkjZ4etU0LUCqxnmN-Rg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <180d6250-8a6a-0b5d-642a-ec6648cb45b1@redhat.com>
Date: Thu, 25 Apr 2019 09:41:20 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CA+CK2bDB5o4+NMc7==_ipVAZoEo7fdrkjZ4etU0LUCqxnmN-Rg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 25 Apr 2019 07:41:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 24.04.19 23:34, Pavel Tatashin wrote:
>>>> +static int
>>>> +offline_memblock_cb(struct memory_block *mem, void *arg)
>>>
>>> Function name suggests that you are actually trying to offline memory
>>> here. Maybe check_memblocks_offline_cb(), just like we have in
>>> mm/memory_hotplug.c.
> 
> Makes sense, I will rename to check_memblocks_offline_cb()
> 
>>>> +     lock_device_hotplug();
>>>> +     rc = walk_memory_range(start_pfn, end_pfn, dev, offline_memblock_cb);
>>>> +     unlock_device_hotplug();
>>>> +
>>>> +     /*
>>>> +      * If admin has not offlined memory beforehand, we cannot hotremove dax.
>>>> +      * Unfortunately, because unbind will still succeed there is no way for
>>>> +      * user to hotremove dax after this.
>>>> +      */
>>>> +     if (rc)
>>>> +             return rc;
>>>
>>> Can't it happen that there is a race between you checking if memory is
>>> offline and an admin onlining memory again? maybe pull the
>>> remove_memory() into the locked region, using __remove_memory() instead.
>>
>> I think the race is ok. The admin gets to keep the pieces of allowing
>> racing updates to the state and the kernel will keep the range active
>> until the next reboot.
> 
> Thank you for noticing this. I will pull it into locking region.
> Because, __remove_memory() has this code:
> 
> 1868   ret = walk_memory_range(PFN_DOWN(start), PFN_UP(start + size - 1), NULL,
> 1869   check_memblock_offlined_cb);
> 1870   if (ret)
> 1871      BUG();
> 

Yes, also I think you can let go of the device_lock in
check_memblocks_offline_cb, lock_device_hotplug() should take care of
this (see Documentation/core-api/memory-hotplug.rst - "locking internals")

Cheers!

-- 

Thanks,

David / dhildenb

