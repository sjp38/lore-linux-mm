Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76703C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:38:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3BA3520663
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:38:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3BA3520663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 91DEB8E0003; Wed, 26 Jun 2019 04:38:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8CE5F8E0002; Wed, 26 Jun 2019 04:38:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 796698E0003; Wed, 26 Jun 2019 04:38:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5B18D8E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:38:09 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id s25so1678421qkj.18
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:38:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=zr5C4FkDMtC6jcrHEkap1CUMgcz6mUyjlIntOqFk+B4=;
        b=IdBscE6Bz6Bi5JGpxfXqROwyBT5irbGEH2o1YVlHei0Dcbj3rqSabyp73PVr4/FDhW
         1pnOjrMY7peqO5nXCOHgH+VAAv6zLxrkNa2l1IgvqXqL2MZPgYfWNP9/efCx6CCPW/iu
         aw6V2FFGK23Zm37PAPhz+R8iBBY+F4rtK6Q9w8A/lueSPpnjxFOQbM89Ce7JDDHgCOfp
         DHECfbgbcZKpJ9hrioVlpaNaWK5zCMKIfVbNWQqXjj4jtUCcvScTU9YbZA/8maJ4Uint
         Huu2gL6XhL+XBsPG0mKOaO0wUs8xZY+THOCzHw1Ne/T3BECIV3AuMyt1jG4RjrVjsMMJ
         Asrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXG9tJc0ecEMLKATzkdkmBzEY1yNjwM6NU31JuTjZdD93rfPni5
	dR5o0g+p8cCkpavRvqizDoJke/CUPauf/S24gf248qgZMvGvxAemWmuFuqQKo8671NaYaDPKGZO
	odvNevV81rK47z8LBSPVB+YMPjrE7S/88PAVXsYeXNEYtJ6ytQsdnIsqxI5xsOPKXyA==
X-Received: by 2002:a0c:d610:: with SMTP id c16mr2534520qvj.22.1561538289147;
        Wed, 26 Jun 2019 01:38:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzk6NO0ZWHkyrw34dgcYUhEvn4LIbwK8vqd7Kl0usXToFolkhZ6sJroZ5+m/CBIXa9zHto0
X-Received: by 2002:a0c:d610:: with SMTP id c16mr2534497qvj.22.1561538288567;
        Wed, 26 Jun 2019 01:38:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561538288; cv=none;
        d=google.com; s=arc-20160816;
        b=pqwsZQVfmOYc0KFHMVLKKchaHlOUSNZi7Xw8M5H4P4sn5S33N2nXMNgrtMKCLnLg5t
         reNLGH7V6p1y9USmIEA52J7CH4z+yCaaHjhsD/rQASAEIZHGY7+11HSGWy873XFI63hc
         hTCOA5vnjCiDb7ggMOuuwAqb9mTbjP0vD02aEysilL4AavjjvUuJEW68hlCQOAhGqJAe
         zyxhXrZMqCJg9E0p+At7eQbEU09gRyeltNSsjXsh07BS7XBVQq0OQKEcdwCVn0j2O+dB
         +ruEcOreYSWZs2cPqbpj0Sp1c9VGcladyUlHCzpUxlDJbVQbyDbRLfcLbL5FQK/F4TCq
         fHvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=zr5C4FkDMtC6jcrHEkap1CUMgcz6mUyjlIntOqFk+B4=;
        b=p2QftDDkTzSSepGQ97LjDOYhNRshPxNkr1kBBeZeEdGnTuXyfFqr3lsKYWXFOacLv4
         gBxdL12aVKrRFW1J6S8a0sP1qXI+FZwBRPtHnj6BTZJKnkJRu6uK2XudiLGJoxNyhQO5
         tOlmhKWiB8IHuDORwVGqmW/+wBBmkpu5zOyGT3oLjqiTZt1pswzK7djP+3ItAAMuGwVJ
         GamRv+jHBmBCf6222xPW1Mq3e8FCpd9xu1jl5hdCHVZQ6SOnU/8tkFfDt55NQ3ZnHAa1
         pVmPEgN4GuW1WruuebZn40TiHXzZkAoOP219dp7ympjJZG7MccXqa37cGZZuPL6LzUjE
         oZEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d3si4492591qkk.167.2019.06.26.01.38.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:38:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 296DE3086213;
	Wed, 26 Jun 2019 08:37:55 +0000 (UTC)
Received: from [10.36.116.174] (ovpn-116-174.ams2.redhat.com [10.36.116.174])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ED3CA5D71B;
	Wed, 26 Jun 2019 08:37:50 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
 <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
 <20190626081516.GC30863@linux> <20190626082756.GD30863@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <b2e25c78-03d3-8423-4bc7-1a5c4779d5ab@redhat.com>
Date: Wed, 26 Jun 2019 10:37:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190626082756.GD30863@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 26 Jun 2019 08:38:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.06.19 10:27, Oscar Salvador wrote:
> On Wed, Jun 26, 2019 at 10:15:16AM +0200, Oscar Salvador wrote:
>> On Wed, Jun 26, 2019 at 10:11:06AM +0200, David Hildenbrand wrote:
>>> Back then, I already mentioned that we might have some users that
>>> remove_memory() they never added in a granularity it wasn't added. My
>>> concerns back then were never fully sorted out.
>>>
>>> arch/powerpc/platforms/powernv/memtrace.c
>>>
>>> - Will remove memory in memory block size chunks it never added
>>> - What if that memory resides on a DIMM added via MHP_MEMMAP_DEVICE?
>>>
>>> Will it at least bail out? Or simply break?
>>>
>>> IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save to be
>>> introduced.
>>
>> Uhm, I will take a closer look and see if I can clear your concerns.
>> TBH, I did not try to use arch/powerpc/platforms/powernv/memtrace.c
>> yet.
>>
>> I will get back to you once I tried it out.
> 
> On a second though, it would be quite trivial to implement a check in
> remove_memory() that does not allow to remove memory used with MHP_MEMMAP_DEVICE
> in a different granularity:
> 
> +static bool check_vmemmap_granularity(u64 start, u64 size);
> +{
> +	unsigned long pfn;
> +	unsigned int nr_pages;
> +	struct page *p;
> +
> +	pfn = PHYS_PFN(start);
> +	p = pfn_to_page(pfn);
> +	nr_pages = size >> PAGE_SIZE;
> +
> +	if (PageVmemmap(p)) {
> +		struct page *h = vmemmap_get_head(p);
> +		unsigned long sections = (unsigned long)h->private;
> +
> +		if (sections * PAGES_PER_SECTION > nr_pages)
> +			fail;
> +	}
> +	no_fail;
> +}
> +		
> +
>  static int __ref try_remove_memory(int nid, u64 start, u64 size)
>  {
>  	int rc = 0;
>  
>  	BUG_ON(check_hotplug_memory_range(start, size));
>  
>  	mem_hotplug_begin();
>  
> +	rc = check_vmemmap_granularity(start, size);
> +	if (rc)
> +		goto done;
> 
> 
> The above is quite hacky, but it gives an idea.
> I will try the code from arch/powerpc/platforms/powernv/memtrace.c and see how
> can I implement a check.
> 

Yeah, I would consider such a safety check mandatory for MHP_MEMMAP_DEVICE.

-- 

Thanks,

David / dhildenb

