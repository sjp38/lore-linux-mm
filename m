Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB6DCC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:39:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 73317206B8
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 07:39:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 73317206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 101638E0003; Thu,  1 Aug 2019 03:39:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0B2188E0001; Thu,  1 Aug 2019 03:39:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F08E28E0003; Thu,  1 Aug 2019 03:39:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A36708E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 03:39:45 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f3so44140922edx.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 00:39:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dqk5eFF4PCYO4JnaAcAiiB5/N/JKI9ImFBN4+/itzBw=;
        b=jP5yAh0JJ+AuUZchSdY3046T1AmkBX3fVNsPff4CtmjdLwYe/WAD9KsOgp5/KdE/Tm
         K7+zjuLlEcghoHtwJ3UEzQNJfaCq9+zwffZbKP6zY1kGaV7rhJvh1WUrN5umGUQlTeHz
         6m9He1xIrVayT7mItcOQpjF8mlSR753NahJ7VmbRj88wb5ldoT6J7ptzZxFt2A85yiLH
         balsSfx6alHCglgB4F3T8jBv8yUN4HXcgf5ijeF6DlDSoUKMZahKCJ3PCFOSoi7TmlzC
         0K3lo8e69jFM/OBolpUdHJ7/br6racwjkMzi5Locx6K9eJDqdnwzh+Y7bdXAOnkPS6jX
         g9Sg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVmCeWGvD3BBW1X//W5hhL6lzmXt6Svlkk7Ywkcw2M6WQFBpqCt
	RTjpvqrypI97DtQNcG/oa5G3Rv33TzVmpmIoBgjgHD0BSq0igsZ7tyuatiZ66zMo0eCdk19DilJ
	sfMmaffpJpKKUx3OxpSXIN2ITBswOxWndwcDddGGaxEYsoFlGo9ulHqzjgeuRzOCwqQ==
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr95290645ejd.99.1564645185212;
        Thu, 01 Aug 2019 00:39:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRYI10jzC0/accecnjndk7F+IKzlpkIaqsbLODKiwR0Rmz1OxkyfnQcFbjrxT7e6FX4oO9
X-Received: by 2002:a17:906:304d:: with SMTP id d13mr95290603ejd.99.1564645184468;
        Thu, 01 Aug 2019 00:39:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564645184; cv=none;
        d=google.com; s=arc-20160816;
        b=h0mi0KX4y57o8f4utF8sH0CE91zFOdYcAeC7qQNC0U6gi8EbeKEg4kkUqv4BQpJprm
         hr0TuyMUbJDBjGpqPJ5uK/yZGzoYe42vvmtkaazW2I1m4cUSM1d658DxsTRP9c0OVBIJ
         3MM6bJ6W8Ynj60IpgjCV1prGWTF9yRdpOeZ9sK2q9llbMlkjQ6rrunUCtdHVhogTNXJP
         B1eW9rTfCduXhKIUDpD68ZilztEgTljDxoehSwWNU/l11SOawTo8SMZhNqyWUZFchhlj
         PIvG7fpdfdaym1IDzPLgff0g83xrWJU8ziGhb71Nsyw3pnRP8YQAbOqrC4qiVGswOfRd
         SbYQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dqk5eFF4PCYO4JnaAcAiiB5/N/JKI9ImFBN4+/itzBw=;
        b=Ltb1eh6kIF550mdl2R5IejYsXs1mbsQXrzfYDVts7Sjt4LB2P7QUh8GHvHtkNPZfLa
         DZ/OrCZLcTtZa1v5S5eFBoGZhwYUesBhQpkZzJeRGQ1pjj0/W9CrwrNISrXc3xZZg4FE
         rKNa6TZG6jXeVy02FzWEpLw6aFbYsHkENjXZHTFkwgpOED+LLung9ylygXrZrnvsujyU
         KUmy+6nalC4YqRoyvQNfHhGoOEQ4GSS6pUfQUBGExYZBSCkD66nIGaHXLFPr3dKVG6eI
         a4RIRmryVCkO7Kd0PMP0lr9f/VNGLhm1QfXaASjo0YXbJFEQ2yL8R9dDTIHZMRDs+25j
         6uuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b13si22046300eda.130.2019.08.01.00.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 00:39:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 79E7FB11C;
	Thu,  1 Aug 2019 07:39:43 +0000 (UTC)
Date: Thu, 1 Aug 2019 09:39:40 +0200
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com, david@redhat.com, pasha.tatashin@soleen.com,
	mhocko@suse.com, anshuman.khandual@arm.com,
	Jonathan.Cameron@huawei.com, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 0/5] Allocate memmap from hotadded memory
Message-ID: <20190801073931.GA16659@linux>
References: <20190725160207.19579-1-osalvador@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190725160207.19579-1-osalvador@suse.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 25, 2019 at 06:02:02PM +0200, Oscar Salvador wrote:
> Here we go with v3.
> 
> v3 -> v2:
>         * Rewrite about vmemmap pages handling.
>           Prior to this version, I was (ab)using hugepages fields
>           from struct page, while here I am officially adding a new
>           sub-page type with the fields I need.
> 
>         * Drop MHP_MEMMAP_{MEMBLOCK,DEVICE} in favor of MHP_MEMMAP_ON_MEMORY.
>           While I am still not 100% if this the right decision, and while I
>           still see some gaining in having MHP_MEMMAP_{MEMBLOCK,DEVICE},
>           having only one flag ease the code.
>           If the user wants to allocate memmaps per memblock, it'll
>           have to call add_memory() variants with memory-block granularity.
> 
>           If we happen to have a more clear usecase MHP_MEMMAP_MEMBLOCK
>           flag in the future, so user does not have to bother about the way
>           it calls add_memory() variants, but only pass a flag, we can add it.
>           Actually, I already had the code, so add it in the future is going to be
>           easy.
> 
>         * Granularity check when hot-removing memory.
>           Just checking that the granularity is the same.
> 
> [Testing]
> 
>  - x86_64: small and large memblocks (128MB, 1G and 2G)
> 
> So far, only acpi memory hotplug uses the new flag.
> The other callers can be changed depending on their needs.
> 
> [Coverletter]
> 
> This is another step to make memory hotplug more usable. The primary
> goal of this patchset is to reduce memory overhead of the hot-added
> memory (at least for SPARSEMEM_VMEMMAP memory model). The current way we use
> to populate memmap (struct page array) has two main drawbacks:
> 
> a) it consumes an additional memory until the hotadded memory itself is
>    onlined and
> b) memmap might end up on a different numa node which is especially true
>    for movable_node configuration.
> 
> a) it is a problem especially for memory hotplug based memory "ballooning"
>    solutions when the delay between physical memory hotplug and the
>    onlining can lead to OOM and that led to introduction of hacks like auto
>    onlining (see 31bc3858ea3e ("memory-hotplug: add automatic onlining
>    policy for the newly added memory")).
> 
> b) can have performance drawbacks.
> 
> One way to mitigate all these issues is to simply allocate memmap array
> (which is the largest memory footprint of the physical memory hotplug)
> from the hot-added memory itself. SPARSEMEM_VMEMMAP memory model allows
> us to map any pfn range so the memory doesn't need to be online to be
> usable for the array. See patch 3 for more details.
> This feature is only usable when CONFIG_SPARSEMEM_VMEMMAP is set.
> 
> [Overall design]:
> 
> Implementation wise we reuse vmem_altmap infrastructure to override
> the default allocator used by vmemap_populate. Once the memmap is
> allocated we need a way to mark altmap pfns used for the allocation.
> If MHP_MEMMAP_ON_MEMORY flag was passed, we set up the layout of the
> altmap structure at the beginning of __add_pages(), and then we call
> mark_vmemmap_pages().
> 
> MHP_MEMMAP_ON_MEMORY flag parameter will specify to allocate memmaps
> from the hot-added range.
> If callers wants memmaps to be allocated per memory block, it will
> have to call add_memory() variants in memory-block granularity
> spanning the whole range, while if it wants to allocate memmaps
> per whole memory range, just one call will do.
> 
> Want to add 384MB (3 sections, 3 memory-blocks)
> e.g:
> 
> add_memory(0x1000, size_memory_block);
> add_memory(0x2000, size_memory_block);
> add_memory(0x3000, size_memory_block);
> 
> or
> 
> add_memory(0x1000, size_memory_block * 3);
> 
> One thing worth mention is that vmemmap pages residing in movable memory is not a
> show-stopper for that memory to be offlined/migrated away.
> Vmemmap pages are just ignored in that case and they stick around until sections
> referred by those vmemmap pages are hot-removed.

Gentle ping :-)

-- 
Oscar Salvador
SUSE L3

