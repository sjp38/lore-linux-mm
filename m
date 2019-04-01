Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB4DDC4360F
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 09:18:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C03C2086C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 09:18:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C03C2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2BF96B0006; Mon,  1 Apr 2019 05:18:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDBE46B0008; Mon,  1 Apr 2019 05:18:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ACA996B000A; Mon,  1 Apr 2019 05:18:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 870A26B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 05:18:17 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q21so9344915qtf.10
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 02:18:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=pSsVImSsTTc5R78DKZVzJM+yef1ElDpnV3PNyny0ZZ8=;
        b=RfV7NOSbbyYYgttvj0wFwLOhhnt65PjyyetGavvb/ON8Qp37iraf6a5put9uvXvpGv
         ilIyMIwtovgnFJ7pik6Gkr8pgk72RBrhHrDZHjy0qEf26XuHC9QgW/S3J+o+OSim4x+0
         Jd47gJn4xBuh4zp9J83bL70mIIPrr5xcJcGyJBpQpj2aTILLKCS2pM/iL1fvMmqbdBlb
         x+vtZ4xzB8hLOIL6lxb3p2cf6Yt8URph84tEn5uoyx/oud6gDVpAIo15ZMAAqLy1srhk
         KqGosJ6ZRUpGQvRCid30ksW07hXR+t2+z4b7b5iMhCq99lWongcf2EsstVFw0fDHAsX3
         nF2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVjqHyxdIsvzFujeGe32mZPBvY0xySOtlK9voi91/HwRYSHCOrn
	U5sME89NyN+DMdpgkbR5G6BatIpJUFmsmz1ygCODb1OEmyYeAAHX0cV91UwdU0TmjMdC4nKsWr9
	KLMTNnekolasB37BSPZfi2sG03j4HbqsrNiuz6zLZ2+6IDbmsv2+VxRc8vZWDU6knMw==
X-Received: by 2002:ac8:7607:: with SMTP id t7mr53694286qtq.28.1554110297224;
        Mon, 01 Apr 2019 02:18:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnvkOCnmfTdettGkFz0SPN/+ZnPbhEHtz6ICqYLsiSKeHmXKyMF5/LBzKDBFZklhh+VVvv
X-Received: by 2002:ac8:7607:: with SMTP id t7mr53694221qtq.28.1554110296074;
        Mon, 01 Apr 2019 02:18:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554110296; cv=none;
        d=google.com; s=arc-20160816;
        b=fnZ2bHIZXIuc/G08XtYoeO9nXNmAi726x+lNQxf0dnMIfkwYtBZhPOBm4spCHAjdGq
         VPRqw+5owSpnnwWwQG9yFg0Oo1QQ30/piUwL+Q7+S0nUSKgjVK5nMILZDQyI6e6mwE/k
         kL0zeDC7i4vLTQzJrBCMx9Gcp8rlcKDrbIW+BYdfWSzFyz9u0pQPkiu+CJ6FlfuRVzt+
         EZDoAvZIZMrXES1NS/WVrOVltGER+yP31UnflWY4UiYiHwhp7uX4r9YNiaMJjRq1Amod
         7mlKXZzf5cbGc5kGYJT3P51O829NsZpK01k504EtL1pVdeUBxd0/NBno2Tb/DZoHxWvM
         qoDg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=pSsVImSsTTc5R78DKZVzJM+yef1ElDpnV3PNyny0ZZ8=;
        b=CF+HqeiD/LS+rDX9i1tSAIj5L4TyyOHPnn6+CCBXQKkQyqE/WieJ3PwxaBDIb271Gg
         IFAKM5HToZ4Quunat/BFdfD+IFJb5P1OShFz8BdeQb7z2DwIxjpCXv0LPCxvKMB8Pnh9
         RQw4jZYSSiVIGRfD1bB+WTuMt1htMgw7u0GZqM+XMfiD5ifpuqPnan5xSel5knKd8XdG
         FmuGZ500lJFXHuq4q2C3+/ZzBL01HzHZW1y58ky4Ibpt5unf7zgQTqJBe64D88bgAPuH
         DeddONyRZVajR83D/uCphX7iQYDdCqlHWz2ISrO85Zheca8HxQx0ifmX6d3QG/54aonH
         UfDA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h6si1225331qkm.59.2019.04.01.02.18.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 02:18:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 19D72308622A;
	Mon,  1 Apr 2019 09:18:15 +0000 (UTC)
Received: from [10.36.117.63] (ovpn-117-63.ams2.redhat.com [10.36.117.63])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 599B860851;
	Mon,  1 Apr 2019 09:18:12 +0000 (UTC)
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Jeff Moyer <jmoyer@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
 stable <stable@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
 linux-nvdimm <linux-nvdimm@lists.01.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20190322180532.GM32418@dhcp22.suse.cz>
 <CAPcyv4gBGNP95APYaBcsocEa50tQj9b5h__83vgngjq3ouGX_Q@mail.gmail.com>
 <20190325101945.GD9924@dhcp22.suse.cz>
 <CAPcyv4iJCgu-akJM_O8ZtscqWQt=CU-fvx-ViGYeau-NJufmSQ@mail.gmail.com>
 <20190326080408.GC28406@dhcp22.suse.cz>
 <CAPcyv4jUeUPwbfToWQtWX1AxfgFLNpBUhm8BvgJ2Hv1RbNPiog@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <89ee9efc-868a-7f08-79e3-60454ecd3089@redhat.com>
Date: Mon, 1 Apr 2019 11:18:11 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4jUeUPwbfToWQtWX1AxfgFLNpBUhm8BvgJ2Hv1RbNPiog@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Mon, 01 Apr 2019 09:18:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 27.03.19 01:20, Dan Williams wrote:
> On Tue, Mar 26, 2019 at 1:04 AM Michal Hocko <mhocko@kernel.org> wrote:
>>
>> On Mon 25-03-19 13:03:47, Dan Williams wrote:
>>> On Mon, Mar 25, 2019 at 3:20 AM Michal Hocko <mhocko@kernel.org> wrote:
>> [...]
>>>>> User-defined memory namespaces have this problem, but 2MB is the
>>>>> default alignment and is sufficient for most uses.
>>>>
>>>> What does prevent users to go and use a larger alignment?
>>>
>>> Given that we are living with 64MB granularity on mainstream platforms
>>> for the foreseeable future, the reason users can't rely on a larger
>>> alignment to address the issue is that the physical alignment may
>>> change from one boot to the next.
>>
>> I would love to learn more about this inter boot volatility. Could you
>> expand on that some more? I though that the HW configuration presented
>> to the OS would be more or less stable unless the underlying HW changes.
> 
> Even if the configuration is static there can be hardware failures
> that prevent a DIMM, or a PCI device to be included in the memory map.
> When that happens the BIOS needs to re-layout the map and the result
> is not guaranteed to maintain the previous alignment.
> 
>>> No, you can't just wish hardware / platform firmware won't do this,
>>> because there are not enough platform resources to give every hardware
>>> device a guaranteed alignment.
>>
>> Guarantee is one part and I can see how nobody wants to give you
>> something as strong but how often does that happen in the real life?
> 
> I expect a "rare" event to happen everyday in a data-center fleet.
> Failure rates tend towards 100% daily occurrence at scale and in this
> case the kernel has everything it needs to mitigate such an event.
> 
> Setting aside the success rate of a software-alignment mitigation, the
> reason I am charging this hill again after a 2 year hiatus is the
> realization that this problem is wider spread than the original
> failing scenario. Back in 2017 the problem seemed limited to custom
> memmap= configurations, and collisions between PMEM and System RAM.
> Now it is clear that the collisions can happen between PMEM regions
> and namespaces as well, and the problem spans platforms from multiple
> vendors. Here is the most recent collision problem:
> https://github.com/pmem/ndctl/issues/76, from a third-party platform.
> 
> The fix for that issue uncovered a bug in the padding implementation,
> and a fix for that bug would result in even more hacks in the nvdimm
> code for what is a core kernel deficiency. Code review of those
> changes resulted in changing direction to go after the core
> deficiency.
> 
>>> The effect is that even if the driver deploys a software alignment
>>> mitigation when it first sees the persistent memory range, that
>>> alignment can be violated on a subsequent boot leading to data being
>>> unavailable. There is no facility to communicate to the administrator
>>> what went wrong in this scenario as several events can trigger a
>>> physical map layout change. Add / remove of hardware and hardware
>>> failure are the most likely causes.
>>
>> This is indeed bad and unexpected! That is exactly something to have in
>> the chagelog!
> 
> Apologies that was indeed included in the 2017 changelog (see: "a user
> could inadvertently lose access to nvdimm namespaces" note here:
> https://lwn.net/Articles/717383/), and I failed to carry it forward.
> 
>>
>>> An additional pain point for users is that EFI pre-boot environment
>>> has little chance to create a namespace that Linux might be able to
>>> use. The section size is an arbitrary Linux constraint and we should
>>> not encode something Linux specific that might change in the future
>>> into OS agnostic software.
>>
>> This looks like a fair point but please keep in mind that there hotplug
>> restrictions are on other platforms as well (4MB on Windows IIRC) so
>> there will be some knowledge required all the time. Besides that there
>> are likely to be some restrictions depending on the implementation.
> 
> Windows does not have an equivalent constraint, so it's only Linux
> that imposes an arbitrary alignment restriction on pmem to agents like
> EFI.
> 
>> [...]
>>>>> Right, as stated in the cover letter, this does not remove all those
>>>>> assumptions, it only removes the ones that impact
>>>>> devm_memremap_pages(). Specifying that sub-section is only supported
>>>>> in the 'want_memblock=false' case to arch_add_memory().
>>>>
>>>> And this is exactly the problem. Having different assumptions depending
>>>> on whether there is a memblock interface or not is utterly wrong and a
>>>> maintainability mess.
>>>
>>> In this case I disagree with you. The hotplug code already has the
>>> want_memblock=false semantic in the implementation.
>>
>> want_memblock was a hack to allow memory hotplug to not have user
>> visible sysfs interface. It was added to reduce the code duplication
>> IIRC. Besides that this hasn't changed the underlying assumptions about
>> hotplugable units or other invariants that were in place.
> 
> Neither does this patch series for the typical memory hotplug case.
> For the device-memory use case I've gone through and fixed up the
> underlying assumptions.
> 
>>> The sub-section
>>> hotplug infrastructure is a strict superset of what is there already.
>>> Now, if it created parallel infrastructure that would indeed be a
>>> maintainability burden, but in this case there are no behavior changes
>>> for typical memory hotplug as it just hotplugs full sections at a time
>>> like always. The 'section' concept is not going away.
>>
>> You are really neglecting many details here. E.g. memory section can be
>> shared between two different types of memory. We've had some bugs in the
>> hotplug code when one section can be shared between two different NUMA
>> nodes (e.g. 4aa9fc2a435a ("Revert "mm, memory_hotplug: initialize struct
>> pages for the full memory section""). We do not allow to hotremove such
>> sections because it would open another can of worms. I am not saying
>> your implementation is incorrect - still haven't time to look deeply -
>> but stating that this is a strict superset of want_memblock is simply
>> wrong.
> 
> Please have a look at the code and the handling of "early" sections.
> The assertion that I neglected to consider that detail is not true.
> 
> My "superset" contention is from the arch_add_memory() api
> perspective. All typical memory hotplug use cases are a sub-case of
> the new support.
> 
>> [...]
>>>> Why do we have to go a mile to tweak the kernel, especially something as
>>>> fragile as memory hotplug, just to support sub mem section ranges. This
>>>> is somthing that is not clearly explained in the cover letter. Sure you
>>>> are talking about hacks at the higher level to deal with this but I do
>>>> not see any fundamental reason to actually support that at all.
>>>
>>> Like it or not, 'struct page' mappings for arbitrary hardware-physical
>>> memory ranges is a facility that has grown from the pmem case, to hmm,
>>> and peer-to-peer DMA. Unless you want to do the work to eliminate the
>>> 'struct page' requirement across the kernel I think it is unreasonable
>>> to effectively archive the arch_add_memory() implementation and
>>> prevent it from reacting to growing demands.
>>
>> I am definitely not blocking memory hotplug to be reused more! All I am
>> saying is that there is much more ground work to be done before you can
>> add features like that. There are some general assumptions in the code,
>> like it or not, and you should start by removing those to build on top.
> 
> Let's talk about specifics please, because I don't think you've had a
> chance to consider the details in the patches. Your "start by removing
> those [assumptions] to build on top" request is indeed what the
> preparation patches in this series aim to achieve.
> 
> The general assumptions of the current (pre-patch-series) implementation are:
> 
> - Sections that describe boot memory (early sections) are never
> unplugged / removed.

I m not sure if this is completely true, and it also recently popped up
while discussing some work Oscar is doing ("[PATCH 0/4]
mm,memory_hotplug: allocate memmap from hotadded memory").

We have powernv (arch/powerpc/platforms/powernv/memtrace.c), that will
offline + remove memory from the system that it didn't originally add.
As far as I understand, this can easily be boot memory. Not sure if
there is anything blocking this code from removing boot memory.

Also, ACPI memory hotplug (drivers/acpi/acpi_memhotplug.c) seems to have
a case where memory provided by a DIMM is already used by the kernel (I
assume this means, it was detected and added during boot). This memory
can theoretically be removed. I am still to figure out how that special
case here fits into the big picture.

> 
> - pfn_valid(), in the CONFIG_SPARSEMEM_VMEMMAP=y, case devolves to a
> valid_section() check
> 
> - __add_pages() and helper routines assume all operations occur in
> PAGES_PER_SECTION units.
> 
> - the memblock sysfs interface only comprehends full sections
> 
> Those assumptions are removed / handled with the following
> implementation details respectively:
> 
> - Partially populated early sections can be extended with additional
> sub-sections, and those sub-sections can be removed with
> arch_remove_memory(). With this in place we no longer lose usable
> memory capacity to padding.
> 
> - pfn_valid() goes beyond valid_section() to also check the
> active-sub-section mask. As stated before this indication is in the
> same cacheline as the valid_section() so the performance impact is
> expected to be negligible. So far the lkp robot has not reported any
> regressions.
> 
> - Outside of the core vmemmap population routines which are replaced,
> other helper routines like shrink_{zone,pgdat}_span() are updated to
> handle the smaller granularity. Core memory hotplug routines that deal
> with online memory are not updated. That's a feature not a bug until
> we decide that sub-section hotplug makes sense for online / typical
> memory as well.
> 
> - the existing memblock sysfs user api guarantees / assumptions are
> not touched since this capability is limited to !online
> !sysfs-accessible sections for now.

So to expand on that, the main difference of RAM hotplug to device
memory hotplug is that

- Memory has to be onlined/offlined. Sections are marked as being either
online or offline. Not relevant for device memory. Onlining/offlining
imples working on the buddy / core MM.

- Memory is exposed and managed via memblock sysfs API. memblocks are
multiples of sections. The RAM hotplug granularity really is the size of
memblocks. E.g. kdump uses memblock sysfs events to reaload when new
memory is added/onlined. Onlining controlled by userspace works on
memblocks getting added. Other users heavily use the memblock API.

So I think the hotplug granularity of RAM really is memblocks (actually
sections). Changing that might be very complicated, will break APIs and
has a questionable benefit.

I am starting to wonder if RAM (memdev) really is the special case and
what you are proposing is the right thing to do for everything that
- doesn't use memdev sysfs interface
- doesn't require to online memory (sections)

So, it boils down to memblock=true is the special case. We would have to
make sure that memblock=true cannot be mixed with memblock=false on the
same sections (or even memory blocks)

(not having had a detailed look at the patches yet) Michal, what do you
think?

-- 

Thanks,

David / dhildenb

