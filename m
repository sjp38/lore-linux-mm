Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B96DC28CC6
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:56:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3C3924DFC
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 06:56:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3C3924DFC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 79F776B000C; Tue,  4 Jun 2019 02:56:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 750D66B000D; Tue,  4 Jun 2019 02:56:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5F12B6B0269; Tue,  4 Jun 2019 02:56:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 310836B000C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 02:56:24 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id b64so7073712otc.3
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 23:56:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=P/oTAg5XbIXufBM5LBUlgdxh/oIhL4+gm9j7aKXhAm0=;
        b=FCRHDqp7D8fvfd45y5uXZWyfhsw7/YXriNkLeG2JhG/DGzZ8f7OpBptrbRrWSTmksS
         9qH6f4iotuLRe2cVhbL8WUMv5cUxMNIwLRBFoCzUHW+IHRyCrABw3ubdlv5T4PQ8l+mi
         8TU/XGxX0K/Zrv9Ja8OlfuJpFnQ6rk9jhTyRFw0hd5vSK2+pkCpdx1LTnfCXOc08E3RV
         HhelJ9r7mtiRcqaQnlG3wvvxRVYH3/ges+1AvfFpFeM048QqNMse503DnyW6CS0NG/PR
         k2knKWODYqXeq3SWunSDUXKzHHPkVJPOF0MNXYZeo5TNg/awFEHm4j82Hu8RePMK+mgi
         98hg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXtkcGRXM3iBij90+zVyz3SL2Q/Vci7dTihf1ZGtVoEVmfcVgT0
	KV8VzLeRN0dMAcr1bkf9hA5qy1Q1tMv1Uw/uSvwC5Mk2Lu3004IXQMsl9zlrZS/1xAuOCb1Ejw4
	s+peeUV7RPTsx7csCOIVlM5rt+s9nOrSFyr8p1FbBee382jw/hm3Y1PbnG5J+S6FFrQ==
X-Received: by 2002:a05:6830:1293:: with SMTP id z19mr2920816otp.25.1559631383919;
        Mon, 03 Jun 2019 23:56:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqznutPWC2lZugSS1N/zzu42f0rnlP4w2i/Tzs/Ef8vOUiFK7aYBf+uaDhEPemlQ4fcE+b6o
X-Received: by 2002:a05:6830:1293:: with SMTP id z19mr2920798otp.25.1559631383259;
        Mon, 03 Jun 2019 23:56:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559631383; cv=none;
        d=google.com; s=arc-20160816;
        b=ayXZfB0jP5bGJUMUPBLp6MLlMknhgS6WAHK01QPbQtcvXHFN9QnwAtKen3zNYl3fku
         +sNUEI6m6ifxMdSvETe0/Dg3IyTGuTWOF5eMMGD41seyhQsYKYuX+FAD9Y9+G0V3cIt1
         6o0mZm9z14/j4H16pBCsT1mF6aic7sj5OZfXfC5qvuk34AQ3I/qNagQ/gZ2gY3WTTNy7
         wmUsGkmotjRFNOu7nfbD5lrYNexQHSlBoLANnMeaa7PvEg/Mo8HANDboWPLwLpTnNxpb
         MHaZ0DuJLTns8WRI42DYbQHtFXm3NFHCbGwmnzIhAvlkmYl7sBJS6CSYJ9FqGiOJc7Ug
         ZQIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=P/oTAg5XbIXufBM5LBUlgdxh/oIhL4+gm9j7aKXhAm0=;
        b=SbNxfdIGsypWmYWTq86TypJbzQUGI/3bk+1H6OpRh7R5tR9V7vYPFanzhkkA/obsJY
         0Rz73dd+yw2jImwhe9ehnYJ4JC7t1YnjrYmyYTpHq9bHdg6n20cFpPR3YGkP4oolpiEQ
         S9FP2PBUQxx3rAOBZLemXV9iNHWTjJgFNUMh88+F29fFCZieZ51PUINIT9l3INePk9qf
         9F7WnHgU3wBoaYrZh3PNRyn2e2ruwZhXU55H1HxUaQG/KEWoHriI8PneDQMDzwiT6XKq
         jQjT2nlvY56GTiCjcKw98Qj9o0IW1JAvrughPEWxCXhACsMRX9Wg10+HX7s6vRI9NfsE
         J+AA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h38si4108836otb.241.2019.06.03.23.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 23:56:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7D37F75727;
	Tue,  4 Jun 2019 06:56:22 +0000 (UTC)
Received: from [10.36.117.37] (ovpn-117-37.ams2.redhat.com [10.36.117.37])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A151510013D9;
	Tue,  4 Jun 2019 06:56:16 +0000 (UTC)
Subject: Re: [PATCH v3 04/11] arm64/mm: Add temporary arch_remove_memory()
 implementation
To: Wei Yang <richard.weiyang@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 Dan Williams <dan.j.williams@intel.com>, Igor Mammedov
 <imammedo@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Chintan Pandya <cpandya@codeaurora.org>, Mike Rapoport <rppt@linux.ibm.com>,
 Jun Yao <yaojun8558363@gmail.com>, Yu Zhao <yuzhao@google.com>,
 Robin Murphy <robin.murphy@arm.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-5-david@redhat.com>
 <20190603214139.mercn5hol2yyfl2s@master>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <5059f68d-45d2-784e-0770-ee67060773c7@redhat.com>
Date: Tue, 4 Jun 2019 08:56:15 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190603214139.mercn5hol2yyfl2s@master>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 04 Jun 2019 06:56:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.06.19 23:41, Wei Yang wrote:
> On Mon, May 27, 2019 at 01:11:45PM +0200, David Hildenbrand wrote:
>> A proper arch_remove_memory() implementation is on its way, which also
>> cleanly removes page tables in arch_add_memory() in case something goes
>> wrong.
> 
> Would this be better to understand?
> 
>     removes page tables created in arch_add_memory

That's not what this sentence expresses. Have a look at
arch_add_memory(), in case  __add_pages() fails, the page tables are not
removed. This will also be fixed by Anshuman in the same shot.

> 
>>
>> As we want to use arch_remove_memory() in case something goes wrong
>> during memory hotplug after arch_add_memory() finished, let's add
>> a temporary hack that is sufficient enough until we get a proper
>> implementation that cleans up page table entries.
>>
>> We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
>> patches.
>>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>> Cc: Chintan Pandya <cpandya@codeaurora.org>
>> Cc: Mike Rapoport <rppt@linux.ibm.com>
>> Cc: Jun Yao <yaojun8558363@gmail.com>
>> Cc: Yu Zhao <yuzhao@google.com>
>> Cc: Robin Murphy <robin.murphy@arm.com>
>> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>> Signed-off-by: David Hildenbrand <david@redhat.com>
>> ---
>> arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
>> 1 file changed, 19 insertions(+)
>>
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index a1bfc4413982..e569a543c384 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
>> 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>> 			   restrictions);
>> }
>> +#ifdef CONFIG_MEMORY_HOTREMOVE
>> +void arch_remove_memory(int nid, u64 start, u64 size,
>> +			struct vmem_altmap *altmap)
>> +{
>> +	unsigned long start_pfn = start >> PAGE_SHIFT;
>> +	unsigned long nr_pages = size >> PAGE_SHIFT;
>> +	struct zone *zone;
>> +
>> +	/*
>> +	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
>> +	 * adding fails). Until then, this function should only be used
>> +	 * during memory hotplug (adding memory), not for memory
>> +	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
>> +	 * unlocked yet.
>> +	 */
>> +	zone = page_zone(pfn_to_page(start_pfn));
> 
> Compared with arch_remove_memory in x86. If altmap is not NULL, zone will be
> retrieved from page related to altmap. Not sure why this is not the same?

This is a minimal implementation, sufficient for this use case here. A
full implementation is in the works. For now, this function will not be
used with an altmap (ZONE_DEVICE is not esupported for arm64 yet).

Thanks!

> 
>> +	__remove_pages(zone, start_pfn, nr_pages, altmap);
>> +}
>> +#endif
>> #endif
>> -- 
>> 2.20.1
> 


-- 

Thanks,

David / dhildenb

