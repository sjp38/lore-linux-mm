Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7B3AC31E4D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:35:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FF2B20866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 19:35:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FF2B20866
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AF98B6B0006; Fri, 14 Jun 2019 15:35:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA8FF6B0007; Fri, 14 Jun 2019 15:35:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 970666B000D; Fri, 14 Jun 2019 15:35:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 766766B0006
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 15:35:07 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id 5so2997379qki.2
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 12:35:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=a9FIeDvYzGRSuVmuvPdSX/FEwackCKjqHF+ocJGi3XQ=;
        b=h0IFsFXsBgQoMaFji5KLhClXfnu2m2klHLd8jofw4+3vsB8ylfLhwvubseKlyhz0Vp
         CyxAA1ZnxnLOpXTmSQ4RYfF5fAWFiAxMEiBa3ix8di3Ysa9NkCiOm0dTIDEAOvXww6xs
         +DuaqztzqZbLMlXRHs3sNcEJPxT5B3H/Wd2/tiRxwiTr73i6a8G/ZYbO4gLVmrQixmIv
         WVK0514ZbaGrNU+9Tq+B2BKJOVeMVWSXDY2YYXMh67IdJF1m02wHs+vPlSn9zCN9MEmD
         WrCOzQ+ObCTm7N1e4Mek6JYgmGsLl4zR29+Go1tDRLNGF3y8kNjyNZ4tj99T38Q8ItBd
         kU5w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVVivVcizVbqCtTAZBAtQugFlYHRsKfIq9LmBSqJMv+IhPJ1zpZ
	54KMzue593PtxY1rQBhXrYJUk9KmnZ7bacMfoPyNF90Fppf4JCBFZ/ClQtiGhoD1DwMuw/C+exZ
	lnEURTWHmWQwh4skz12+KilzqGUsqJzRo+Wl5ObXzBq6sOa9WWg3sb7QTDU3o+KXmFw==
X-Received: by 2002:a37:6b87:: with SMTP id g129mr68390941qkc.305.1560540907219;
        Fri, 14 Jun 2019 12:35:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFz06awQGvf3Oz4xLkC22nvoUqmV8Cy+gALkiPSPoJfeEThzt0fWuY+XgJHAfJAzfBLZPx
X-Received: by 2002:a37:6b87:: with SMTP id g129mr68390892qkc.305.1560540906584;
        Fri, 14 Jun 2019 12:35:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560540906; cv=none;
        d=google.com; s=arc-20160816;
        b=uW0f5KFKPDmKUcMUcuP7y8pdvLA31n2uLivzoW35ny+bW6/BJHNEb0UC72xvObHfDA
         MmyvyA1E8e7zLPZ1YUZrXxdYkA8E9Ct9KIckG1gbOkXPrhrOoZuBmGdKIIfj07EfSOlT
         U2W82vbnVwADHlcSI/baxaqxIPsfBq7j/0KX1XAb+1O8psY/Fx2mB6fau9UKUoUQhqzA
         iwEDmQHAquZHW+RA2ljuo9WkzdlYlC+Tn4SrgqutJcatzsB98jL4QFRwacJgUHhDTR8h
         M2rzoph3oNyJV7OMq1x8DwcSGvqkIZvb3FOdAC8Q/jl2A3NxpmLZs5JhPbAjf+y+f0pa
         odWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=a9FIeDvYzGRSuVmuvPdSX/FEwackCKjqHF+ocJGi3XQ=;
        b=nug7LBvVy9QELeoZmm27t5P/w2zF3uKklhToo8+KgaDjmgeac6S8rfn9pNDqpFA37H
         0PX2M9XxbWthpkuYTlXWw4u1LgQkqaFn11Nw74XJYaK/+pDyCSDg3c/rXtqGBOidZtYW
         mWMeXt5AsLXzWxXnzHwbtHA3DbfdG1iuZ41Gnr90LpfKOggZhO6rtASjxeVXIqsvMubl
         UofAs3trzN5BgY7krJ8xaWETVzlefd3IpBuSO6nJz3Jkz5Fpe5jyr7yv4cgmL6ymxVFt
         Ej25fe8wZpk3ONiBAEZAbLwRe47mSoWR8xaazHQJ1zCfL+upIH7jMb3IvrxN7v1PyXw7
         ifuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j11si2139516qvn.199.2019.06.14.12.35.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 12:35:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DF3793092645;
	Fri, 14 Jun 2019 19:35:04 +0000 (UTC)
Received: from [10.36.116.43] (ovpn-116-43.ams2.redhat.com [10.36.116.43])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 955E519C67;
	Fri, 14 Jun 2019 19:35:00 +0000 (UTC)
Subject: Re: [PATCH v1 1/6] mm: Section numbers use the type "unsigned long"
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Dan Williams <dan.j.williams@intel.com>,
 linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org,
 linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J. Wysocki" <rafael@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
 Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>,
 Wei Yang <richard.weiyang@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Arun KS <arunks@codeaurora.org>, Pavel Tatashin <pasha.tatashin@oracle.com>,
 Oscar Salvador <osalvador@suse.de>, Stephen Rothwell <sfr@canb.auug.org.au>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Baoquan He <bhe@redhat.com>
References: <20190614100114.311-1-david@redhat.com>
 <20190614100114.311-2-david@redhat.com>
 <20190614120036.00ae392e3f210e7bc9ec6960@linux-foundation.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <e07449fa-251f-51c7-9ee2-202635c4aef7@redhat.com>
Date: Fri, 14 Jun 2019 21:34:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190614120036.00ae392e3f210e7bc9ec6960@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Fri, 14 Jun 2019 19:35:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.06.19 21:00, Andrew Morton wrote:
> On Fri, 14 Jun 2019 12:01:09 +0200 David Hildenbrand <david@redhat.com> wrote:
> 
>> We are using a mixture of "int" and "unsigned long". Let's make this
>> consistent by using "unsigned long" everywhere. We'll do the same with
>> memory block ids next.
>>
>> ...
>>
>> -	int i, ret, section_count = 0;
>> +	unsigned long i;
>>
>> ...
>>
>> -	unsigned int i;
>> +	unsigned long i;
> 
> Maybe I did too much fortran back in the day, but I think the
> expectation is that a variable called "i" has type "int".
> 
> This?

t460s: ~/git/linux memory_block_devices2 $ git grep "unsigned long i;" |
wc -l
245
t460s: ~/git/linux memory_block_devices2 $ git grep "int i;" | wc -l
26827

Yes ;)

While it makes sense for the second and third occurrence, I think for
the first one it could be confusing (it's not actually a section number
but a counter for sections_per_block).

I see just now that we can avoid converting the first occurrence
completely. So maybe we should drop changing removable_show() from this
patch.

Cheers!

> 
> 
> 
> s/unsigned long i/unsigned long section_nr/
> 
> --- a/drivers/base/memory.c~mm-section-numbers-use-the-type-unsigned-long-fix
> +++ a/drivers/base/memory.c
> @@ -131,17 +131,17 @@ static ssize_t phys_index_show(struct de
>  static ssize_t removable_show(struct device *dev, struct device_attribute *attr,
>  			      char *buf)
>  {
> -	unsigned long i, pfn;
> +	unsigned long section_nr, pfn;
>  	int ret = 1;
>  	struct memory_block *mem = to_memory_block(dev);
>  
>  	if (mem->state != MEM_ONLINE)
>  		goto out;
>  
> -	for (i = 0; i < sections_per_block; i++) {
> -		if (!present_section_nr(mem->start_section_nr + i))
> +	for (section_nr = 0; section_nr < sections_per_block; section_nr++) {
> +		if (!present_section_nr(mem->start_section_nr + section_nr))
>  			continue;
> -		pfn = section_nr_to_pfn(mem->start_section_nr + i);
> +		pfn = section_nr_to_pfn(mem->start_section_nr + section_nr);
>  		ret &= is_mem_section_removable(pfn, PAGES_PER_SECTION);
>  	}
>  
> @@ -695,12 +695,12 @@ static int add_memory_block(unsigned lon
>  {
>  	int ret, section_count = 0;
>  	struct memory_block *mem;
> -	unsigned long i;
> +	unsigned long section_nr;
>  
> -	for (i = base_section_nr;
> -	     i < base_section_nr + sections_per_block;
> -	     i++)
> -		if (present_section_nr(i))
> +	for (section_nr = base_section_nr;
> +	     section_nr < base_section_nr + sections_per_block;
> +	     section_nr++)
> +		if (present_section_nr(section_nr))
>  			section_count++;
>  
>  	if (section_count == 0)
> @@ -823,7 +823,7 @@ static const struct attribute_group *mem
>   */
>  int __init memory_dev_init(void)
>  {
> -	unsigned long i;
> +	unsigned long section_nr;
>  	int ret;
>  	int err;
>  	unsigned long block_sz;
> @@ -840,9 +840,9 @@ int __init memory_dev_init(void)
>  	 * during boot and have been initialized
>  	 */
>  	mutex_lock(&mem_sysfs_mutex);
> -	for (i = 0; i <= __highest_present_section_nr;
> -		i += sections_per_block) {
> -		err = add_memory_block(i);
> +	for (section_nr = 0; section_nr <= __highest_present_section_nr;
> +		section_nr += sections_per_block) {
> +		err = add_memory_block(section_nr);
>  		if (!ret)
>  			ret = err;
>  	}
> _
> 


-- 

Thanks,

David / dhildenb

