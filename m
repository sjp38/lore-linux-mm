Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 876CBC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:17:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3088321855
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 21:17:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3088321855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D12046B0286; Thu, 28 Mar 2019 17:17:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBF376B0288; Thu, 28 Mar 2019 17:17:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B89706B0289; Thu, 28 Mar 2019 17:17:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 964C16B0286
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 17:17:22 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id 75so18821267qki.13
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 14:17:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=FWwb5IZ/2l7XVx7mSs374XXf1wPxculrL40ZxbG2W6k=;
        b=inbVJ8I5XjzR19bfontofPDkJPNHlWH4SfMVB/LXn/Zsw22N6/u/9fukPecUpe7mgt
         kQz1dGrgfjrZ5Lt1uPTnXY7YtItsxFMdvmfJ+rp+uX0pf2IK3CMv0fdrG5EA0kS3jt68
         3RyCKCiKpsUWszeJ8hI/pJQmuKOVkOw2f0bJQaQyKwcdiR3ut6rSJisERDCvGWacIk/W
         s6ZqJDiWAOw0Rto5R2mr2msKbsFE45HR9lQdtvSsVfOU9WBQDbhfZ/MLyTPj6IL53kE2
         tseiDjijEeXLRPRIRteV8s6dD9YS5e/Ny4xKCzl+ajm7BxhRAs0v2FLjvsxhI1qEYWG3
         nYtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV/HYt2aFnU59JCOv7rSfqoCi0zB52aNqe4KH3oGZ1zWlf0yO3i
	qy4tg+2m98X4Y2PiUZ7SHhj6nU4ZXk4EpkdvDVspbUrQhZ/0UrWnS7qZddD8VBRfptEVhh0CJ73
	kfsee22aYNIwGCZcM5+1tuad/QdzhFYvJor0D6su9FUiPY7DvtaRRPTNrm6RBjteBnw==
X-Received: by 2002:ae9:f30f:: with SMTP id p15mr22697729qkg.182.1553807842323;
        Thu, 28 Mar 2019 14:17:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7fE3tB7XWIA3n2RAJlOaZd1EClN2ggrhEhsGcTukyGFbxdz3Ts/cG3GxW97Wt1IJ9RW4h
X-Received: by 2002:ae9:f30f:: with SMTP id p15mr22697672qkg.182.1553807841380;
        Thu, 28 Mar 2019 14:17:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553807841; cv=none;
        d=google.com; s=arc-20160816;
        b=MxIGjkq1umqoVBzq8AzuYgc19ZSclKgrtE+La5CGDdDP/IdsTELZlYXMRLlaa8OaCK
         yhsgASpx819hR81DvRgKolsTpayfTG20pEjaA4RKFAdlQJCrGlw0A6agPCLS5k/cbvAg
         G7SwwsYXZQIwL9r6VsJUXdJPEhu2Z0n6TIqKaP+WK5eSxuNa+f5srCsoOglLZ/6lPzfI
         0+ZM/4dPEr3D3mmu9SvAk61LzaNn8jdNUV9t4TFHqRN7faWRJg0KjCQOVovIq9GmAnoN
         DiR4AqeDD4BVp0O/NFD72icSUcYb3ikpyzD+Hn7ke63eTUkrnkW20m6rJxwILYGC8vap
         +qQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=FWwb5IZ/2l7XVx7mSs374XXf1wPxculrL40ZxbG2W6k=;
        b=zJbJJ9zdOyPMzVSujTeTOfGzvuNsHurHVIGIxJxMsCD7NEHKASVfeLFLvqb3F13bcf
         K3pUj5j8kF4bsgzBYtJfTRbmRwEWAxP3EbcIGgMfDfQODwhUBCHAAUft24hWUfCuuOgm
         urofkjuGjUKNk8iUDFXL41RcGkhuCAcgoDMct5wzcoEp8fbGqU2/XlxBX8Ske+0cCuJW
         jnZ0LmyxJ1ZmPElxPre/ylXU+sjMEyqBw6LgFEi7cBUFMdlKquk8g2CswSTAdo45TO2R
         bCEXPejr2Pr4qnkliGAxyCw290jRLjeBd1hkWh21Fy/ApxH1MU8Nb0worWBkM0jH5QBa
         emsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 94si80031qtc.15.2019.03.28.14.17.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 14:17:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 648C131688E1;
	Thu, 28 Mar 2019 21:17:20 +0000 (UTC)
Received: from [10.36.116.61] (ovpn-116-61.ams2.redhat.com [10.36.116.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id EDBB45C226;
	Thu, 28 Mar 2019 21:17:15 +0000 (UTC)
Subject: Re: [PATCH v5 00/10] mm: Sub-section memory hotplug support
To: Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, Toshi Kani <toshi.kani@hpe.com>,
 Jeff Moyer <jmoyer@redhat.com>, Michal Hocko <mhocko@suse.com>,
 Vlastimil Babka <vbabka@suse.cz>, stable <stable@vger.kernel.org>,
 Linux MM <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@lists.01.org>,
 Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
 <cf304a31-70a6-e701-ec3e-c47dc84b81d2@redhat.com>
 <CAPcyv4hgAM=ex0B4EBZ40RNf=bXk2WkEzySTUV4ZzOWd_HZwSQ@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <24c163f2-3b78-827f-257e-70e5a9655806@redhat.com>
Date: Thu, 28 Mar 2019 22:17:15 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAPcyv4hgAM=ex0B4EBZ40RNf=bXk2WkEzySTUV4ZzOWd_HZwSQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Thu, 28 Mar 2019 21:17:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

>> You are using the term "Sub-section memory hotplug support", but is it
>> actually what you mean? To rephrase, aren't we talking here about
>> "Sub-section device memory hotplug support" or similar?
> 
> Specifically it is support for passing @start and @size arguments to
> arch_add_memory() that are not section aligned. It's not limited to
> "device memory" which is otherwise not a concept that
> arch_add_memory() understands, it just groks spans of pfns.

Okay, so everything that does not have a memory block devices as of now.

> 
>> Reason I am asking is because I wonder how that would interact with the
>> memory block device infrastructure and hotplugging of system ram -
>> add_memory()/add_memory_resource(). I *assume* you are not changing the
>> add_memory() interface, so that one still only works with whole sections
>> (or well, memory_block_size_bytes()) - check_hotplug_memory_range().
> 
> Like you found below, the implementation enforces that add_memory_*()
> interfaces maintain section alignment for @start and @size.
> 
>> In general, mix and matching system RAM and persistent memory per
>> section, I am not a friend of that.
> 
> You have no choice. The platform may decide to map PMEM and System RAM
> in the same section because the Linux section is too large compared to
> typical memory controller mapping granularity capability.

I might be very wrong here, but do we actually care about something like
64MB getting lost in the cracks? I mean if it simplifies core MM, let go
of the couple of MB of system ram and handle the PMEM part only. Treat
the system ram parts like memory holes we already have in ordinary
sections (well, there we simply set the relevant struct pages to
PG_reserved). Of course, if we have hundreds of unaligned devices and
stuff will start to add up ... but I assume this is not the case?

> 
>> Especially when it comes to memory
>> block devices. But I am getting the feeling that we are rather targeting
>> PMEM vs. PMEM with this patch series.
> 
> The collisions are between System RAM, PMEM regions, and PMEM
> namespaces (sub-divisions of regions that each need their own mapping
> lifetime).

Understood. I wonder if that PMEM only mapping (including separate
lifetime) could be handled differently. But I am absolutely no expert,
just curious.

> 
>>> Quote patch7:
>>>
>>> "The libnvdimm sub-system has suffered a series of hacks and broken
>>>  workarounds for the memory-hotplug implementation's awkward
>>>  section-aligned (128MB) granularity. For example the following backtrace
>>>  is emitted when attempting arch_add_memory() with physical address
>>>  ranges that intersect 'System RAM' (RAM) with 'Persistent Memory' (PMEM)
>>>  within a given section:
>>>
>>>   WARNING: CPU: 0 PID: 558 at kernel/memremap.c:300 devm_memremap_pages+0x3b5/0x4c0
>>>   devm_memremap_pages attempted on mixed region [mem 0x200000000-0x2fbffffff flags 0x200]
>>>   [..]
>>>   Call Trace:
>>>     dump_stack+0x86/0xc3
>>>     __warn+0xcb/0xf0
>>>     warn_slowpath_fmt+0x5f/0x80
>>>     devm_memremap_pages+0x3b5/0x4c0
>>>     __wrap_devm_memremap_pages+0x58/0x70 [nfit_test_iomap]
>>>     pmem_attach_disk+0x19a/0x440 [nd_pmem]
>>>
>>>  Recently it was discovered that the problem goes beyond RAM vs PMEM
>>>  collisions as some platform produce PMEM vs PMEM collisions within a
>>
>> As side-noted by Michal, I wonder if PMEM vs. PMEM cannot rather be
>> implemented "on top" of what we have right now. Or is this what we
>> already have that you call "hacks in nvdimm" code? (no NVDIMM expert,
>> sorry for the stupid questions)
> 
> It doesn't work, because even if the padding was implemented 100%
> correct, which thus far has failed to be the case, the platform may
> change physical alignments from one boot to the next for a variety of
> reasons.

Would ignoring the System RAM parts (as mentioned above) help or doesn't
it make any difference in terms of complexity?

> 
>>
>>>  given section. The libnvdimm workaround for that case revealed that the
>>>  libnvdimm section-alignment-padding implementation has been broken for a
>>>  long while. A fix for that long-standing breakage introduces as many
>>>  problems as it solves as it would require a backward-incompatible change
>>>  to the namespace metadata interpretation. Instead of that dubious route
>>>  [2], address the root problem in the memory-hotplug implementation."
>>>
>>> The approach is taken is to observe that each section already maintains
>>> an array of 'unsigned long' values to hold the pageblock_flags. A single
>>> additional 'unsigned long' is added to house a 'sub-section active'
>>> bitmask. Each bit tracks the mapped state of one sub-section's worth of
>>> capacity which is SECTION_SIZE / BITS_PER_LONG, or 2MB on x86-64.
>>>
>>> The implication of allowing sections to be piecemeal mapped/unmapped is
>>> that the valid_section() helper is no longer authoritative to determine
>>> if a section is fully mapped. Instead pfn_valid() is updated to consult
>>> the section-active bitmask. Given that typical memory hotplug still has
>>> deep "section" dependencies the sub-section capability is limited to
>>> 'want_memblock=false' invocations of arch_add_memory(), effectively only
>>> devm_memremap_pages() users for now.
>>
>> Ah, there it is. And my point would be, please don't ever unlock
>> something like that for want_memblock=true. Especially not for memory
>> added after boot via device drivers (add_memory()).
> 
> I don't see a strong reason why not, as long as it does not regress
> existing use cases. It might need to be an opt-in for new tooling that
> is aware of finer granularity hotplug. That said, I have no pressing
> need to go there and just care about the arch_add_memory() capability
> for now.

Especially onlining/offlining of memory might end up very ugly. And that
goes hand in hand with memory block devices. They are either online or
offline, not something in between. (I went that path and Michal
correctly told me why it is not a good idea)

I was recently trying to teach memory block devices who their owner is /
of which type they are. Right now I am looking into the option of using
drivers. Memory block devices that could belong to different drivers at
a time are well ... totally broken. I assume it would still be a special
case, though, but conceptually speaking about the interface it would be
allowed.

Memory block devices (and therefore 1..X sections) should have one owner
only. Anything else just does not fit.

-- 

Thanks,

David / dhildenb

