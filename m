Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04191C10F11
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 09:52:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D3A920820
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 09:52:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D3A920820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE0116B0275; Wed, 10 Apr 2019 05:52:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8F696B0276; Wed, 10 Apr 2019 05:52:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97E8E6B0277; Wed, 10 Apr 2019 05:52:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 73E946B0275
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 05:52:03 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g48so1677870qtk.19
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 02:52:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=J8zn+PDLd9ySHcMCSf7/31XeLtA8HdKy5k4RinWbM38=;
        b=oSFwh4fX+dVUxEeXTPQ1hJNWncMTV76IalogUw9DuGZxMeDHGWejI4IVcboKdDH7F9
         HqfRPQbi3e6JY0TubJdpWWXxwezzTQLuKKIz74gQqcmFZYzWbE28qR8nz9ciLXy/1EvS
         L5NEfrBUzjCxJpAI1KXM/VrKeqfuWMFoMT8l4lFl63HDpJlkQpUxryLOfKiuriHsEOe6
         BI/ZViqW10CN4qZGePYpuqWZC2Ac0cevIrZoBoxoyg3TSn9x3XpMeyF54WekaLbVKTG6
         2dN8L7ogSm8iC/Ft0EfKBHqZ0ayTPfXSP1b/zg+3ecvQXlADQhY4QSxsxtm5NE5vU7bJ
         xOgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVth824XcMEQyE93QoBkeoGu8o5dJaULyX60+AFzx2Mv6Bd73F/
	tdeQ+pKISeIW7irBXHjymE9kW82F/Uw67s+ZGX8dG+97V44PoQ+r4rgx7FXrsstgPmDEtKQL8Eg
	ldK7G9ftnbHVvyMlm7iNTiv0vt+xtSZAz5MrO65T+IA6uiX8duCziDfiJDxPpy8BLxw==
X-Received: by 2002:ae9:f442:: with SMTP id z2mr31812721qkl.172.1554889923067;
        Wed, 10 Apr 2019 02:52:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyg7sUZS7GzOrZsEV710UUzLcXOYqBQmau5CRAAPyBqQ0LLMCcz6gc8KUitHOEkySsU3tLe
X-Received: by 2002:ae9:f442:: with SMTP id z2mr31812652qkl.172.1554889921935;
        Wed, 10 Apr 2019 02:52:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554889921; cv=none;
        d=google.com; s=arc-20160816;
        b=wpEcCxCtOOlUhsD6aABYTr5c+lZmNmpuUZ3Zf9zAnppoqY0Hw4y8RR5UksNkRLc3st
         EU/HjtDEB5f/CfmPxbYBO6C9x5v/8Igv4neL8hHIRojGO7+NLD4cxS4h0Z7iJMVa1nL1
         eZSeOoOM0u04IkpbAKpJty62t+YO+viO776jd859QaZlplXSrQqz+zPAHC5bof9GS6Z4
         dACHrQ0+lE5GhJwH0jbB1lR1fKMDRM6aA4aIVXeff05I5RSMhmJIiEjoSpRqNSeIrdYr
         9LdzM2+BtCJLu6zVmCOEHYCvBpKBgoSiW6X3cRrHjWH8YC707h4/50PB13GibFqiuOeq
         Et8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=J8zn+PDLd9ySHcMCSf7/31XeLtA8HdKy5k4RinWbM38=;
        b=WH/+dVUdN3OsBqw5PR0mgGZ8FJAcOh89J7i0jsj8pv8Hq0Nuxg/hc9QlLnnLhOpIbE
         +s0Pe5Itjmtdi7qhCAnVCHYdQLjEb6uKUPUK1KboG5fd40J+ck0xIrTqNgMcpWWXPxvT
         s+Yx42HFBONqlQb6e1kRZahqXhG8tp5cCpfnQlQxvHkPnQT0lE2u7ZLBOvyAa2iFMHSt
         cHsSYNLn3k1Q3ZloTBzh1Hkb4vNQzV7BM4e4mZLQeMQqNIdF28miVwqRMuNqlEKSmg2A
         Th4YFlcZwhSnmn1NQGEG+Qsz7SavekUwgy8L7/iZ1stO2/EI+JA9yPUEVcKZ/w9hQ4n0
         bdGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w73si258377qka.41.2019.04.10.02.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 02:52:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F19218666F;
	Wed, 10 Apr 2019 09:52:00 +0000 (UTC)
Received: from [10.36.118.36] (unknown [10.36.118.36])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 73A035C666;
	Wed, 10 Apr 2019 09:51:58 +0000 (UTC)
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <91856fac-c624-fcef-4c58-547a216d370b@redhat.com>
Date: Wed, 10 Apr 2019 11:51:57 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 10 Apr 2019 09:52:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22.03.19 17:57, Dan Williams wrote:
> Changes since v4 [1]:
> - Given v4 was from March of 2017 the bulk of the changes result from
>   rebasing the patch set from a v4.11-rc2 baseline to v5.1-rc1.
> 
> - A unit test is added to ndctl to exercise the creation and dax
>   mounting of multiple independent namespaces in a single 128M section.
> 
> [1]: https://lwn.net/Articles/717383/
> 
> ---
> 
> Quote patch7:
> 
> "The libnvdimm sub-system has suffered a series of hacks and broken
>  workarounds for the memory-hotplug implementation's awkward
>  section-aligned (128MB) granularity. For example the following backtrace
>  is emitted when attempting arch_add_memory() with physical address
>  ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
>  within a given section:
>  
>   WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
>   devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
>   [..]
>   Call Trace:
>     dump_stack+0x86/0xc3
>     __warn+0xcb/0xf0
>     warn_slowpath_fmt+0x5f/0x80
>     devm_memremap_pages+0x3b5/0x4c0
>     __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
>     pmem_attach_disk+0x19a/0x440 [nd_pmem]
>  
>  Recently it was discovered that the problem goes beyond RAM vs PMEM
>  collisions as some platform produce PMEM vs PMEM collisions within a
>  given section. The libnvdimm workaround for that case revealed that the
>  libnvdimm section-alignment-padding implementation has been broken for a
>  long while. A fix for that long-standing breakage introduces as many
>  problems as it solves as it would require a backward-incompatible change
>  to the namespace metadata interpretation. Instead of that dubious route
>  [2], address the root problem in the memory-hotplug implementation."
> 
> The approach is taken is to observe that each section already maintains
> an array of 'unsigned long' values to hold the pageblock_flags. A single
> additional 'unsigned long' is added to house a 'sub-section active'
> bitmask. Each bit tracks the mapped state of one sub-section's worth of
> capacity which is SECTION_SIZE / BITS_PER_LONG, or 2MB on x86-64.
> 
> The implication of allowing sections to be piecemeal mapped/unmapped is
> that the valid_section() helper is no longer authoritative to determine
> if a section is fully mapped. Instead pfn_valid() is updated to consult
> the section-active bitmask. Given that typical memory hotplug still has
> deep "section" dependencies the sub-section capability is limited to
> 'want_memblock=false' invocations of arch_add_memory(), effectively only
> devm_memremap_pages() users for now.
> 
> With this in place the hacks in the libnvdimm sub-system can be
> dropped, and other devm_memremap_pages() users need no longer be
> constrained to 128MB mapping granularity.
> 
> [2]: https://lore.kernel.org/r/155000671719.348031.2347363160141119237.stgit@dwillia2-desk3.amr.corp.intel.com
> 

I started to explore the wonderful world of system ram memory hotplug
(memory block devices) and it is full with issues. Too many to name them
all, but two example are memory block devices that span several nodes
(such memory can only be added during boot, mem->nid would be completely
misleading) or that we assume struct pages have been initialized, while
they really haven't when removing memory.

It is already a mess that we have multiple sections per memory block
devices (and it was never properly cleaned up and I think I spotted
several issues). Going into the direction of sub-sections for memory
block devices, I don't like. It is already a big mess.

Memory block devices are an important concept for memory hotplug/unplug.
This is the granularity memory will get onlined/offlined by user space.
I don't see this interface going away. On the other hand, memory block
devices only make sense for memory to be onlined/offlined in such
chunks, system ram. So whatever ZONE_DEVICE memory doesn't run into that
restriction.

I think we should restrict adding/removing system ram via
online_pages()/offline_pages()/add_memory()/remove_memory() to
- memory block device granularity (already mostly checked)
- single zones (already mostly checked)
- single nodes (basically not checked as far as I can see)

Cleaning this mess up might take some time. Essentially, all special
handling related to memory block devices should be factored out from
arch_add_memory()/arch_remove_memory() to add_memory()/remove_memory().
I started looking into that. __add_pages() doesn't properly revert what
it already did when failing.

I don't have a strong opinion against adding sub-section memory hotadd
as long as we don't use it for memory block devices hotplug. Meaning,
use it internally, but don't use it along with memory block device hotplug.

As add_memory() only works on memory block device granularity, memory
block devices for something like that is not an issue. The real issue is
memory added during boot that e.g. has holes or overlaps with pmem and
friends. Trying to offline/online/remove such memory should be
completely blocked.

To easily detect multiple nodes per memory block devices, I am thinking
about making mem->nid indicated that. E.g. nid == -1, uninitialized, nid
== -2, mixed nodes, don't allow to offline/remove such memory. Might
require some refactorings.

The question is how we could easily detect
- memory block devices with some sub-sections missing. Offlining code
forbids this right now as the holes are marked as PG_reserved.
- memory block devices with some sub-sections being ZONE_DEVICE memory
like pmem.

Both cases could only happen when memory was added during boot.
Offlining/removing such memory has to be forbidden.

-- 

Thanks,

David / dhildenb

