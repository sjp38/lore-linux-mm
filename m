Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66368C48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:11:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2001E2146E
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 08:11:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2001E2146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B2E556B0003; Wed, 26 Jun 2019 04:11:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADEC88E0003; Wed, 26 Jun 2019 04:11:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A5A08E0002; Wed, 26 Jun 2019 04:11:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7865B6B0003
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 04:11:25 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id z5so1865722qth.15
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 01:11:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=jLH7qRSDmBL+Db+V6PH40Np7/LSOIIVEfelN1asB7JU=;
        b=dcLd8i4yDY5kUYvARI1/QppU9kOgomzEABy//i+JVI+nrsjfGcmopDzbwFLpVgJvs4
         lUk3sIPS6+ccoDHeQQlPn/zSGwW+fcsLuE6cpuLhUVvHRrgzfCUrSE2p5EaU2mP/0Hcq
         fwVPH7QZscX9ueU0ltblIgpyfhM0uiu4KAzhV/6li9EiBasXEE87o2pha46vR2qkpeYi
         kTYflQ6R+my1ScH7ACSF0b3+cY0spI9dsvwG2bju2E5KvM2hRBEWyKWgi8/VGD6l5eEI
         pl+O/gEaYqI1WMj2Zc3Dk26/2lCsqHnxHj1NZ9JAUjTgg7oMRTDV8fAuNZShSw4u4sQ1
         NotQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUQEREHylnkriDXfrxOH5WtsRhKrFSEbB+KBYA0xgI2gaLHfhT6
	QMKII9wHB38WHFE6ZQy+yLYMqqsJ+l3r72z40ngyKLqEI+4C+jVpMGePj7U/iliZlpXtxYTOBhx
	fRRjB9srqV4LjTWFJDyhOZrYAtWwlgkwRUwI4UurmkdHW3g2rU/YzPegAxecXltRcVg==
X-Received: by 2002:a0c:d91b:: with SMTP id p27mr2388973qvj.236.1561536685227;
        Wed, 26 Jun 2019 01:11:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRmybnOg+fpFJ61OZoR1vGiQJBXacVsMgdJY5v3cKmXE5D+pzEM6136S+A2wWupGrWgCi0
X-Received: by 2002:a0c:d91b:: with SMTP id p27mr2388930qvj.236.1561536684516;
        Wed, 26 Jun 2019 01:11:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561536684; cv=none;
        d=google.com; s=arc-20160816;
        b=Vn1eWEonrwDAF2vc19SZWV4trk1MXE/oIT24b7RoBGZrOYJcFmtaDnutZDPMg7hokp
         uhZs+yyTTHytmr/SrJ9r1Gc4ME0zuQzjeCbgvgUZMA+BY913qL4z5+8JsUCeEMuMQla5
         SWLfanH2plSKNiWCq/McNROdJX3Ikq0IrsUBsk/daPEYJP4pb7fybp7s45Y1j+OuyVHW
         aTnOI3qmw/fTgeMMRus9oTerV84N4hZKQDX+EWaFu2wbjnYyo7xJIV9TWDYnYb9QN2H8
         QcfcoWFulxfjnO4yA3MHumhl+zTc7MBAp8CCTR1CxDWvoPpJvOnzpCatUFDi9xFnnPBi
         suHA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=jLH7qRSDmBL+Db+V6PH40Np7/LSOIIVEfelN1asB7JU=;
        b=LEJ4b6equhOtg2QsUOyuJ7XKaGyKLuI3w1JYNFuFzrDVZ8PB7xqczT8FDdeT9b7HnK
         1mzokUIHMqAgCLpCLGCTwkhEAQ6QNjYnv5kxGbl9il4eiB0ZxY1tFTed+vaYUVMG8Lkr
         ACeWxhSWOye9fnm3jrJe1Se5w286LNIrVcepiP8YyE9/YrltP0QUYmMnWVT04MaWRL7H
         AvPJezj7Lsru2sBsXxhW40aKZ/tuITFLn75T67UwodP6keyNaxyR4nJHHu3Dp3dR3h0o
         yfwxoE6Lt3Tx+sNbHYkfvs2/AZ4YWkPD0M5krFsurEM5ATZO+lLb0UMJBpXOjoEDBePK
         pHXQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i53si11199451qta.136.2019.06.26.01.11.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 01:11:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 39AD4811D8;
	Wed, 26 Jun 2019 08:11:10 +0000 (UTC)
Received: from [10.36.116.174] (ovpn-116-174.ams2.redhat.com [10.36.116.174])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 14D545D9C6;
	Wed, 26 Jun 2019 08:11:06 +0000 (UTC)
Subject: Re: [PATCH v2 0/5] Allocate memmap from hotadded memory
To: Oscar Salvador <osalvador@suse.de>
Cc: akpm@linux-foundation.org, mhocko@suse.com, dan.j.williams@intel.com,
 pasha.tatashin@soleen.com, Jonathan.Cameron@huawei.com,
 anshuman.khandual@arm.com, vbabka@suse.cz, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
References: <20190625075227.15193-1-osalvador@suse.de>
 <2ebfbd36-11bd-9576-e373-2964c458185b@redhat.com>
 <20190626080249.GA30863@linux>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <2750c11a-524d-b248-060c-49e6b3eb8975@redhat.com>
Date: Wed, 26 Jun 2019 10:11:06 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190626080249.GA30863@linux>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 26 Jun 2019 08:11:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 26.06.19 10:03, Oscar Salvador wrote:
> On Tue, Jun 25, 2019 at 10:25:48AM +0200, David Hildenbrand wrote:
>>> [Coverletter]
>>>
>>> This is another step to make memory hotplug more usable. The primary
>>> goal of this patchset is to reduce memory overhead of the hot-added
>>> memory (at least for SPARSEMEM_VMEMMAP memory model). The current way we use
>>> to populate memmap (struct page array) has two main drawbacks:
> 
> First off, thanks for looking into this :-)

Thanks for working on this ;)

> 
>>
>> Mental note: How will it be handled if a caller specifies "Allocate
>> memmap from hotadded memory", but we are running under SPARSEMEM where
>> we can't do this.
> 
> In add_memory_resource(), we have a call to mhp_check_correct_flags(), which is
> in charge of checking if the flags passed are compliant with our configuration
> among other things.
> It also checks if both flags were passed (_MEMBLOCK|_DEVICE).
> 
> If a) any of the flags were specified and we are not on CONFIG_SPARSEMEM_VMEMMAP,
> b) the flags are colliding with each other or c) the flags just do not make sense,
> we print out a warning and drop the flags to 0, so we just ignore them.
> 
> I just realized that I can adjust the check even more (something for the next
> version).
> 
> But to answer your question, flags are ignored under !CONFIG_SPARSEMEM_VMEMMAP.

So it is indeed a hint only.

> 
>>
>>>
>>> a) it consumes an additional memory until the hotadded memory itself is
>>>    onlined and
>>> b) memmap might end up on a different numa node which is especially true
>>>    for movable_node configuration.
>>>
>>> a) it is a problem especially for memory hotplug based memory "ballooning"
>>>    solutions when the delay between physical memory hotplug and the
>>>    onlining can lead to OOM and that led to introduction of hacks like auto
>>>    onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
>>>    policy for the newly added memory")).
>>>
>>> b) can have performance drawbacks.
>>>
>>> Another minor case is that I have seen hot-add operations failing on archs
>>> because they were running out of order-x pages.
>>> E.g On powerpc, in certain configurations, we use order-8 pages,
>>> and given 64KB base pagesize, that is 16MB.
>>> If we run out of those, we just fail the operation and we cannot add
>>> more memory.
>>
>> At least for SPARSEMEM, we fallback to vmalloc() to work around this
>> issue. I haven't looked into the populate_section_memmap() internals
>> yet. Can you point me at the code that performs this allocation?
> 
> Yes, on SPARSEMEM we first try to allocate the pages physical configuous, and
> then fallback to vmalloc.
> This is because on CONFIG_SPARSEMEM memory model, the translations pfn_to_page/
> page_to_pfn do not expect the memory to be contiguous.
> 
> But that is not the case on CONFIG_SPARSEMEM_VMEMMAP.
> We do expect the memory to be physical contigous there, that is why a simply
> pfn_to_page/page_to_pfn is a matter of adding/substracting vmemmap/pfn.

Yeas, I explored that last week but didn't figure out where the actual
vmmap population code resided - thanks :)

> 
> Powerpc code is at:
> 
> https://elixir.bootlin.com/linux/v5.2-rc6/source/arch/powerpc/mm/init_64.c#L175
> 
> 
> 
>> So, assuming we add_memory(1GB, MHP_MEMMAP_DEVICE) and then
>> remove_memory(128MB) of the added memory, this will work?
> 
> No, MHP_MEMMAP_DEVICE is meant to be used when hot-adding and hot-removing work
> in the same granularity.
> This is because all memmap pages will be stored at the beginning of the memory
> range.
> Allowing hot-removing in a different granularity on MHP_MEMMAP_DEVICE would imply
> a lot of extra work.
> For example, we would have to parse the vmemmap-head of the hot-removed range,
> and punch a hole in there to clear the vmemmap pages, and then be very carefull
> when deleting those pagetables.
> 
> So I followed Michal's advice, and I decided to let the caller specify if he
> either wants to allocate per memory block or per hot-added range(device).
> Where per memory block, allows us to do:
> 
> add_memory(1GB, MHP_MEMMAP_MEMBLOCK)
> remove_memory(128MB)

Back then, I already mentioned that we might have some users that
remove_memory() they never added in a granularity it wasn't added. My
concerns back then were never fully sorted out.

arch/powerpc/platforms/powernv/memtrace.c

- Will remove memory in memory block size chunks it never added
- What if that memory resides on a DIMM added via MHP_MEMMAP_DEVICE?

Will it at least bail out? Or simply break?

IOW: I am not yet 100% convinced that MHP_MEMMAP_DEVICE is save to be
introduced.

-- 

Thanks,

David / dhildenb

