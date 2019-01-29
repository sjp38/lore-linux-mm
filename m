Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3221AC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:04:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DA19B20880
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 10:04:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DA19B20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7817B8E0002; Tue, 29 Jan 2019 05:04:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7308F8E0001; Tue, 29 Jan 2019 05:04:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D0988E0002; Tue, 29 Jan 2019 05:04:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2EAC98E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 05:04:00 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id f2so24143660qtg.14
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 02:04:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=FEpWE/UBF9XRkiitEFXa2ZxM2PxMPcoyogjzf3nVjZs=;
        b=XdE67Z7mvpdNd/5dwkmjwPkgrid5vemC/ZdQTv6zr41jUn/zJ1hGFVI/Qtk9nLtiH3
         vN4+g/NlsbSxrIsfAMhv0YgNUvawoobNMHm0R9Zw4qidcpMInojPJLNogJm36ry7rQq+
         FyQMXQAOw3EMKnZ7JK3e3ZD+TQ3dlBGJMMSvHBQZB78Lfka4G+qYAnBzwXnBm39CeBbT
         0KxSAaKefnR+oDj4rTUcMpVaMQjiAHtvevkbVxP+cgi0i0ZA3VHBhNA6yckBnJcq8xNN
         JimO4ssl/Ec4rmGB9AbWpmv5Txum1E1mil5tOtSgqj5PqyrdjTAEgYS7hRQEGtPfbBD0
         34Tw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ50EsuzO0j1RiMU9nQwhJGgT3WpKxCD1RTfB1DhRACoj2aWnCi
	E+4N+5DMDwes8kjavz0lpAwDH9z7oNkDGjdFZpY1JBtGA4MK7ls6dfZxcNCMWmfLJvZq7nXT23I
	oK1W2msN6FI4AgbIUHIdthqOOBls5odVm0Qaqet8GHOD1rak5oYtFJ90cT4ORrzHhag==
X-Received: by 2002:ac8:4284:: with SMTP id o4mr3999024qtl.389.1548756239961;
        Tue, 29 Jan 2019 02:03:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY8WlSL05QKTX41XjbXbNHwcR+b2iCRBWchJGhD5tu5QpeR15YlRY1NtfPBiWzTlj8Ti+TC
X-Received: by 2002:ac8:4284:: with SMTP id o4mr3998987qtl.389.1548756239285;
        Tue, 29 Jan 2019 02:03:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548756239; cv=none;
        d=google.com; s=arc-20160816;
        b=R96sqiyoCMlOP7N+b5+YXOkZ6nMKWzOMhbbDym7WiFWZM0UlcVKENaipOaX5RSBZgO
         O2VthEpClddjaDI8v/J41oAJoXPG4QHUybcRRJ/NdrM5EHe8BTxD0iChAjyr4swcTb5R
         iof02o7OIQEiOU02WxJOeK+3U8xDniZI5FtSUJS1Z0NhMw9/MRqY/pA+44RmsFSSRTho
         q8JkH71w3JMWoQq3HKfQhPV/3tA4Ottd8nxVlq2supSW4NJ1AGiRK2u+MvrGluNWrWbb
         7AGRZpZf2F9ZsfE5HAN7n2ukztRJKZTmpuw3dT/E3XRWZSTi/70Au0oiS/pVzvkWaltV
         n4zQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:to:subject;
        bh=FEpWE/UBF9XRkiitEFXa2ZxM2PxMPcoyogjzf3nVjZs=;
        b=Fr1pDPoPhiwgXfqbiI3dA7tm/apOAGE9TEkq97jiRIl0PcE0dXJ89HSmnhI4fUQ/KM
         Rabu8JMorBV6MP6aD4pLfa+9RHMhvnQO2Nku/2Ppppd+V4nl67cNT4ReL+V8uUrzrlCI
         QYfs193IhuW3YjFK9SQUXFvi6NVgbVHrecqGBjz2Lb6npUAvcrKY0yXuAM5Or/JicmIN
         03zRal3fC4SPmbrixRVR3o20zjftMoQ825sC02K/Kj5ojUVcriMBG1gMfUz5SDA+gITS
         l7eFmSvieAeTUNXcLt+1MT/9wRO/Ky3x83VBVIJYAvacAbLfQIOTvD5nc3ZSVsuV5cXz
         BncA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u198si2182840qka.181.2019.01.29.02.03.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 02:03:59 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5808CC7A07;
	Tue, 29 Jan 2019 10:03:58 +0000 (UTC)
Received: from [10.36.118.12] (unknown [10.36.118.12])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EC295176AE;
	Tue, 29 Jan 2019 10:03:56 +0000 (UTC)
Subject: Re: [PATCH] mm,memory_hotplug: Fix scan_movable_pages for gigantic
 hugepages
To: Andrew Morton <akpm@linux-foundation.org>,
 Oscar Salvador <osalvador@suse.de>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, mhocko@suse.com
References: <20190122154407.18417-1-osalvador@suse.de>
 <5368e2b4-5aca-40dd-fe18-67d861a04a29@redhat.com>
 <20190125075830.6mqw2io4rwz7wxx5@d104.suse.de>
 <20190128145309.c7dcf075b469d6a54694327d@linux-foundation.org>
 <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <33fdaa38-6204-bef0-b12f-0416f16dc165@redhat.com>
Date: Tue, 29 Jan 2019 11:03:56 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.1
MIME-Version: 1.0
In-Reply-To: <20190128145617.069b3a5436fc7e34bdebb104@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 29 Jan 2019 10:03:58 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.01.19 23:56, Andrew Morton wrote:
> On Mon, 28 Jan 2019 14:53:09 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
>> On Fri, 25 Jan 2019 08:58:33 +0100 Oscar Salvador <osalvador@suse.de> wrote:
>>
>>> On Wed, Jan 23, 2019 at 11:33:56AM +0100, David Hildenbrand wrote:
>>>> If you use {} for the else case, please also do so for the if case.
>>>
>>> Diff on top:
>>>
>>> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
>>> index 25aee4f04a72..d5810e522b72 100644
>>> --- a/mm/memory_hotplug.c
>>> +++ b/mm/memory_hotplug.c
>>> @@ -1338,9 +1338,9 @@ static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>>>  				struct page *head = compound_head(page);
>>>  
>>>  				if (hugepage_migration_supported(page_hstate(head)) &&
>>> -				    page_huge_active(head))
>>> +				    page_huge_active(head)) {
>>>  					return pfn;
>>> -				else {
>>> +				} else {
>>>  					unsigned long skip;
>>>  
>>>  					skip = (1 << compound_order(head)) - (page - head);
>>>
>>
>> The indenting is getting a bit deep also, so how about this?
>>
>> static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>> {
>> 	unsigned long pfn;
>>
>> 	for (pfn = start; pfn < end; pfn++) {
>> 		struct page *page, *head;
>> 	
>> 		if (!pfn_valid(pfn))
>> 			continue;
>> 		page = pfn_to_page(pfn);
>> 		if (PageLRU(page))
>> 			return pfn;
>> 		if (__PageMovable(page))
>> 			return pfn;
>>
>> 		if (!PageHuge(page))
>> 			continue;
>> 		head = compound_head(page);
>> 		if (hugepage_migration_supported(page_hstate(head)) &&
>> 		    page_huge_active(head)) {
>> 			return pfn;
> 
> checkpatch pointed out that else-after-return isn't needed so we can do
> 
> static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
> {
> 	unsigned long pfn;
> 
> 	for (pfn = start; pfn < end; pfn++) {
> 		struct page *page, *head;
> 		unsigned long skip;
> 
> 		if (!pfn_valid(pfn))
> 			continue;
> 		page = pfn_to_page(pfn);
> 		if (PageLRU(page))
> 			return pfn;
> 		if (__PageMovable(page))
> 			return pfn;
> 
> 		if (!PageHuge(page))
> 			continue;
> 		head = compound_head(page);
> 		if (hugepage_migration_supported(page_hstate(head)) &&
> 		    page_huge_active(head))
> 			return pfn;
> 		skip = (1 << compound_order(head)) - (page - head);
> 		pfn += skip - 1;
> 	}
> 	return 0;
> }
> 
> --- a/mm/memory_hotplug.c~mmmemory_hotplug-fix-scan_movable_pages-for-gigantic-hugepages-fix
> +++ a/mm/memory_hotplug.c
> @@ -1305,28 +1305,27 @@ int test_pages_in_a_zone(unsigned long s
>  static unsigned long scan_movable_pages(unsigned long start, unsigned long end)
>  {
>  	unsigned long pfn;
> -	struct page *page;
> +
>  	for (pfn = start; pfn < end; pfn++) {
> -		if (pfn_valid(pfn)) {
> -			page = pfn_to_page(pfn);
> -			if (PageLRU(page))
> -				return pfn;
> -			if (__PageMovable(page))
> -				return pfn;
> -			if (PageHuge(page)) {
> -				struct page *head = compound_head(page);
> +		struct page *page, *head;
> +		unsigned long skip;
>  
> -				if (hugepage_migration_supported(page_hstate(head)) &&
> -				    page_huge_active(head))
> -					return pfn;
> -				else {
> -					unsigned long skip;
> +		if (!pfn_valid(pfn))
> +			continue;
> +		page = pfn_to_page(pfn);
> +		if (PageLRU(page))
> +			return pfn;
> +		if (__PageMovable(page))
> +			return pfn;
>  
> -					skip = (1 << compound_order(head)) - (page - head);
> -					pfn += skip - 1;
> -				}
> -			}
> -		}
> +		if (!PageHuge(page))
> +			continue;
> +		head = compound_head(page);
> +		if (hugepage_migration_supported(page_hstate(head)) &&
> +		    page_huge_active(head))
> +			return pfn;
> +		skip = (1 << compound_order(head)) - (page - head);
> +		pfn += skip - 1;

Not sure if encoding the -1 in the previous line is even better now that
we have more space

skip = (1 << compound_order(head)) - (page - head + 1);

Looks good to me.

>  	}
>  	return 0;
>  }
> _
> 


-- 

Thanks,

David / dhildenb

