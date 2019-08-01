Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05254C32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 03:02:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A630C214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 03:02:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A630C214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37E3F8E0003; Wed, 31 Jul 2019 23:02:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3069D8E0001; Wed, 31 Jul 2019 23:02:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A8ED8E0003; Wed, 31 Jul 2019 23:02:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BD4598E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:02:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b12so43737299ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 20:02:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=kHusHlcshI7cuaU2q9PclLCd+l4VuAZ8tZKzu0edbgA=;
        b=Yc7V5Dvnze2qo92z3jWy11gmsaMcBjesry8TAWEGUCbGtdBI/APA2sWbBJSoHSP6+s
         vlpMFxW7f8mYo+BSwQzz9zWoKJl9QeJyZljkCErA52IzMJuNmbcubnjF1S+1CFpnDe4s
         YYdPISrM/nMYrZB9TuXEZjZ/v6pKTw8tXhGt29UUxZTeWsjvqIobZmEcI7A82ypiWE7A
         SjjkkFgm4ewJq/5IGWMeOwIZz7RNTTIQnXbCjvULimIfzVXWQ+g2s/H3wB9Qb7t7aU28
         cUSpbVMNOK4OBzRRfkYh+3pgtXg7hZ3E5te6ksZkQHCFiCFiWu9kROD1otF8sCAXoRkP
         oktw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVl9/McjerQIOdHFMX5nRRKx0A/Sk9LhGeCrAeX0qIg18yU7TUr
	tTCsdSxLyKQG4w2pQpKKcCnKypGPxpOXiXh2vrpmDUQf04li4uRDqStNbasBQTgRQstrGFZoaP1
	8CrYtusT+1f5T2QaN3IqpC+QibdNvzKD1U9Y6xiaWFhNVQ9Qglmlh3TKujVhBlaZCPA==
X-Received: by 2002:a17:906:7f91:: with SMTP id f17mr94852939ejr.250.1564628559130;
        Wed, 31 Jul 2019 20:02:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/O6/NdYypIMZ25azYbF++oPJFQLEm8pcKwDN+f7NepK5JYCDscldrS/2KzmDyhnuH9h2Z
X-Received: by 2002:a17:906:7f91:: with SMTP id f17mr94852898ejr.250.1564628558327;
        Wed, 31 Jul 2019 20:02:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564628558; cv=none;
        d=google.com; s=arc-20160816;
        b=bY9NYPTxovC0i0NhqETMdT12KTLJQe31M1veCGIhZH1KwLdGHqUJpzp0PpudDzXgqx
         zOLIIDNVVs88HsPtuEPmhODIfdACoAW9Bcm8JHu/AYqlk/k+7JFQvMIdLurzd4wznsrm
         5+mdnkl/3WPoEvfpAlzGucF0HuXq4F62lNlK0QvNvQ5U6pa+RnIWpYmxLM/lfLA/NDuJ
         ATLjEGAW9S1FraDhXAaABLGtyvE3EH9Ab3q9bO9lax2t7tlvyM6ZkXpINMipm2xtp9WW
         jugO76RT8l0+6dA9LJuUpqN1i75EyK1oLOFMzZRhwzfNnInh4oJUMd3gHVUVDBzRZI4V
         QhMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=kHusHlcshI7cuaU2q9PclLCd+l4VuAZ8tZKzu0edbgA=;
        b=iNLvHZfIqAeCWh2Y7BmRhUdB9V+gRBhYJRmkSyGTiTat9T/Gm6bD4wp4LnVGIWqe7X
         9TRKIs63apqFeHB1v4NdlFSa64JSxNdXC+1SF9TwW/NVzPZ0MB3vaCP406cWkaKde/SI
         U0vGCqDRuXG4mLEmeJFj22mF2nXY7+1oyy+Wh7G6YufqT4vFepIcqL74SIVdrREROZUJ
         NOKA19BheFfX/AC3QeC+VTrR9Slj5TbpO9RIotS47QwXOTQw/6pordS8mfs/gN0ab34R
         6IBpgsnQHCq4NoVeXVq5Tt8Px49/thTqCmcBaltT3KDkZVBiBtm2dGdH/7xiligeI/9w
         Lzlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c25si11500385ejx.201.2019.07.31.20.02.37
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 20:02:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 36AED344;
	Wed, 31 Jul 2019 20:02:37 -0700 (PDT)
Received: from [10.163.1.81] (unknown [10.163.1.81])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id A2A7B3F575;
	Wed, 31 Jul 2019 20:02:33 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC 2/2] arm64/mm: Enable device memory allocation and free for
 vmemmap mapping
To: Will Deacon <will@kernel.org>
Cc: linux-mm@kvack.org, Mark Rutland <mark.rutland@arm.com>,
 Catalin Marinas <catalin.marinas@arm.com>, Will Deacon
 <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
References: <1561697083-7329-1-git-send-email-anshuman.khandual@arm.com>
 <1561697083-7329-3-git-send-email-anshuman.khandual@arm.com>
 <20190731161103.kqv3v2xlq4vnyjhp@willie-the-truck>
Message-ID: <349fb6e2-f9f1-c45a-e512-4ac253e2fd3d@arm.com>
Date: Thu, 1 Aug 2019 08:33:09 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190731161103.kqv3v2xlq4vnyjhp@willie-the-truck>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 07/31/2019 09:41 PM, Will Deacon wrote:
> On Fri, Jun 28, 2019 at 10:14:43AM +0530, Anshuman Khandual wrote:
>> This enables vmemmap_populate() and vmemmap_free() functions to incorporate
>> struct vmem_altmap based device memory allocation and free requests. With
>> this device memory with specific atlmap configuration can be hot plugged
>> and hot removed as ZONE_DEVICE memory on arm64 platforms.
>>
>> Cc: Catalin Marinas <catalin.marinas@arm.com>
>> Cc: Will Deacon <will.deacon@arm.com>
>> Cc: Mark Rutland <mark.rutland@arm.com>
>> Cc: linux-arm-kernel@lists.infradead.org
>> Cc: linux-kernel@vger.kernel.org
>>
>> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
>> ---
>>  arch/arm64/mm/mmu.c | 57 ++++++++++++++++++++++++++++++++++-------------------
>>  1 file changed, 37 insertions(+), 20 deletions(-)
>>
>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>> index 39e18d1..8867bbd 100644
>> --- a/arch/arm64/mm/mmu.c
>> +++ b/arch/arm64/mm/mmu.c
>> @@ -735,15 +735,26 @@ int kern_addr_valid(unsigned long addr)
>>  }
>>  
>>  #ifdef CONFIG_MEMORY_HOTPLUG
>> -static void free_hotplug_page_range(struct page *page, size_t size)
>> +static void free_hotplug_page_range(struct page *page, size_t size,
>> +				    struct vmem_altmap *altmap)
>>  {
>> -	WARN_ON(!page || PageReserved(page));
>> -	free_pages((unsigned long)page_address(page), get_order(size));
>> +	if (altmap) {
>> +		/*
>> +		 * vmemmap_populate() creates vmemmap mapping either at pte
>> +		 * or pmd level. Unmapping request at any other level would
>> +		 * be a problem.
>> +		 */
>> +		WARN_ON((size != PAGE_SIZE) && (size != PMD_SIZE));
>> +		vmem_altmap_free(altmap, size >> PAGE_SHIFT);
>> +	} else {
>> +		WARN_ON(!page || PageReserved(page));
>> +		free_pages((unsigned long)page_address(page), get_order(size));
>> +	}
>>  }
>>  
>>  static void free_hotplug_pgtable_page(struct page *page)
>>  {
>> -	free_hotplug_page_range(page, PAGE_SIZE);
>> +	free_hotplug_page_range(page, PAGE_SIZE, NULL);
>>  }
>>  
>>  static void free_pte_table(pmd_t *pmdp, unsigned long addr)
>> @@ -807,7 +818,8 @@ static void free_pud_table(pgd_t *pgdp, unsigned long addr)
>>  }
>>  
>>  static void unmap_hotplug_pte_range(pmd_t *pmdp, unsigned long addr,
>> -				    unsigned long end, bool sparse_vmap)
>> +				    unsigned long end, bool sparse_vmap,
>> +				    struct vmem_altmap *altmap)
> 
> Do you still need the sparse_vmap parameter, or can you just pass a NULL
> altmap pointer when sparse_vmap is false?

Yes, we will still require sparse_vmap parameter because vmemmap mapping
does not necessarily be created only for ZONE_DEVICE range with an altmap.
vmemmap can still be present with altmap as NULL (regular memory and device
memory without altmap) in which cases it will not be possible to
differentiate between linear and vmemmap mapping.

