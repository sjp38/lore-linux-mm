Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D333C32754
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4A1A214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:48:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4A1A214DA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CD938E0005; Thu,  1 Aug 2019 02:48:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67D4C8E0001; Thu,  1 Aug 2019 02:48:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 543F48E0005; Thu,  1 Aug 2019 02:48:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 326B58E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:48:11 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d11so60286773qkb.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:48:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=UvF066+OX9A8RNo9Cz1ihb7/kOqAF96knxxyYrhMgBo=;
        b=pi0lHDe9iyWXRiRbJ96buevS8XUMMGqtLhZ8JKP0DDYWd9aNhdD6bTBvEIHcB0XrPL
         jaDDJokpx39UPhSGXTUNAd14Lzvdx0fzxSs+QQBkeC6AayIyFmlbp9ewd3dOLwn2sAkr
         ZxCK9jMkscFqEZ5V70vPwziO/elZ2p9Z17HCPBpNWmbnQTeHpSWzFw01rxORoI+t4zJ5
         WLS4Bq03grMo7IXE+EFIvrTyVd1slfquqlaUkMuAdTXy/LrkdAczSumLyH2CjaQvFKEy
         ZmjR67P8mXeRiqxEVknfqdpfIIjo9TC6Ej3H4X8vLyZVMdPsJy7mdXP7VY0PsV76jDQS
         vO+w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWa+TvVL55N1qob3zn3d3XSAiyGNF6H6oCfUBQU+On0Uji3t/oC
	g24HPsBSW7xsvFF8ryhRGbBue/Bdd2cjD4kuwBcw69LOPE0abbLFdabkE4QIv5NRPMlA+5Za47E
	2HqkfJrOyYVb/HaJ9VI/XFhTr7Dc2Yi/nIZpSI8vSuN6AcaydbSiKOnJcwgnIVaO4Uw==
X-Received: by 2002:ac8:7941:: with SMTP id r1mr83619032qtt.82.1564642090962;
        Wed, 31 Jul 2019 23:48:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqnN+ukBq7z604LhYOKSyDPGLWceI6nYKCP9kpvrKdrTaiAmkhNqC+Z/9o0WroctgC9JJz
X-Received: by 2002:ac8:7941:: with SMTP id r1mr83619010qtt.82.1564642090372;
        Wed, 31 Jul 2019 23:48:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564642090; cv=none;
        d=google.com; s=arc-20160816;
        b=pwPe05QMVOqbVZ5ph2erbL62pERK8VUVCOQYPYTt7HEqqDHhZPB3vkZXFYLKVDqRZE
         bTHrNQv0ib/eG4ER/Ej95Xb8+FX8aP+Y0ZiesjWXShkdczkrMBbaeSQPfCeUU5gWVRrx
         Xej7+6Ljh0xx/aGFl9hBppEL3lm7pee90Bt7u7UGea0pbXmRKToeE0j2NY28BkgNo9l6
         o3ICj7ySAmAKqfHfC7fBVZCz/gI3KVkjtqyTcTz8obNX0TTjZwD+IOedBdoyRoGMbYN5
         zAp9xzv94V6H+fHpKovmCQ4tNlsfjJZPAli36csYvrC3ltZfKffyz0XVgf4R18UzwnnT
         P9NA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=UvF066+OX9A8RNo9Cz1ihb7/kOqAF96knxxyYrhMgBo=;
        b=HvSRoImTuii0Lz8buFCJSVFbrLTEAvy+PjRh5C/i51uKImVTH36JuWvXdI38Gjoybm
         1f1OeToSxDBhOueYyXbnULsng+NmvFvF9TskNheE1ndG5/jDlA/BAClnUIvbCOF0JW5Q
         H5rJHv/keZrPgWB04Un76Uy+dfIl89VXg9sX8og/z8c2PuUD/xeiO7u1e0AxIk15EDDd
         QI3DAsMs5LcJM7cgJZvfueK7cc37VfafuEYNbyvCj6mm25a+CFuBTX/pGKaVObNjidcP
         AdmEHAW8YTyMaM+tMKySSUP+pebgDhOj1pmRdPFOH2IN9db7JDomjUUKdh5FZicemATM
         YrKw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r14si38429747qkm.302.2019.07.31.23.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:48:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7EEAD83F45;
	Thu,  1 Aug 2019 06:48:09 +0000 (UTC)
Received: from [10.36.116.245] (ovpn-116-245.ams2.redhat.com [10.36.116.245])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 3EDEC10013D9;
	Thu,  1 Aug 2019 06:48:07 +0000 (UTC)
Subject: Re: [PATCH v1] drivers/base/memory.c: Don't store end_section_nr in
 memory blocks
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Michal Hocko <mhocko@suse.com>,
 Dan Williams <dan.j.williams@intel.com>, Oscar Salvador <osalvador@suse.de>
References: <20190731122213.13392-1-david@redhat.com>
 <20190731135715.ddb4fccb5c4ee2f14f84a34a@linux-foundation.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e9e3a428-0b06-dda3-3171-c76286cee37b@redhat.com>
Date: Thu, 1 Aug 2019 08:48:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190731135715.ddb4fccb5c4ee2f14f84a34a@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Thu, 01 Aug 2019 06:48:09 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 31.07.19 22:57, Andrew Morton wrote:
> On Wed, 31 Jul 2019 14:22:13 +0200 David Hildenbrand <david@redhat.com> wrote:
> 
>> Each memory block spans the same amount of sections/pages/bytes. The size
>> is determined before the first memory block is created. No need to store
>> what we can easily calculate - and the calculations even look simpler now.
>>
>> While at it, fix the variable naming in register_mem_sect_under_node() -
>> we no longer talk about a single section.
>>
>> ...
>>
>> --- a/include/linux/memory.h
>> +++ b/include/linux/memory.h
>> @@ -40,6 +39,8 @@ int arch_get_memory_phys_device(unsigned long start_pfn);
>>  unsigned long memory_block_size_bytes(void);
>>  int set_memory_block_size_order(unsigned int order);
>>  
>> +#define PAGES_PER_MEMORY_BLOCK (memory_block_size_bytes() / PAGE_SIZE)
> 
> Please let's not hide function calls inside macros which look like
> compile-time constants!  Adding "()" to the macro would be a bit
> better.  Making it a regular old inline C function would be better
> still.  But I'd suggest just open-coding this at the macro's single
> callsite.
> 

Sure, makes sense. Thanks!

-- 

Thanks,

David / dhildenb

