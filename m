Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A2C8C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:35:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FE14218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:35:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FE14218A4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C891A8E012A; Mon, 11 Feb 2019 13:35:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C0EE18E0126; Mon, 11 Feb 2019 13:35:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAFAC8E012A; Mon, 11 Feb 2019 13:35:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4DB538E0126
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:35:12 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w51so2273234edw.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:35:12 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=TkW8GIak1sWS2ca5tIb1/Cjm6iWO273i074PYzFAbxw=;
        b=KNEaVxDQdV8v067RQNWiStjlhGeMi3tckB8cIUlr8XitfJGJl+nPm4gfRaMcobDQJD
         QKsbmTgUznHkOGdrcJhy7R7yZRJbhZY16gp0MT/0PRX9FpL5UYtLuUHTdQ6KcHWAdVod
         WSpnoCndl1qCgoOFJsaWBik0/8AqmeA5iTg3sgksUTWORX+RnGrJOxljL57Y/HiyI01W
         WZSkzxLZuxhQhR7fw/yrjy8OFRxd2hEfMBRtYEa6Pvr6rTfecEXJMJ9TIRpBxWkvJDwF
         EM8BEsA10YBDPV429QpqY7HFORmZIYyLikv/xucVcg+f7xgMX8Ny59wCYO7KmWh4u7cU
         xSLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
X-Gm-Message-State: AHQUAuY6RRXAYyxNi6u3kk4WLYw8LB1za9NmfltCaFD6v76XXW10l7O3
	/696UXRabWaz6k7AkPX2n8xP0ZA+8G258dGmM65HDMWLcMNaWSWy9M4F+aywpdV23uOy7aTChby
	4d87x84X8F/O+8G3hk84vkRiWjq+vyGUF0Du1L/EU0BDCFNuo6r9wAAG4v46oopIBRg==
X-Received: by 2002:a50:be44:: with SMTP id b4mr29448513edi.41.1549910111702;
        Mon, 11 Feb 2019 10:35:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYs/7UUhrJC9DtVPdwU+U6t9ybbjJOmrt7ZvEyA9QB6kgvrV99J45AHnibGMvJ5NMrvJkGg
X-Received: by 2002:a50:be44:: with SMTP id b4mr29448457edi.41.1549910110626;
        Mon, 11 Feb 2019 10:35:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549910110; cv=none;
        d=google.com; s=arc-20160816;
        b=AMR/iX0TVK/o4luGkBKuEFjW6z1slAUfy50GJv8iXE7fDAbFyiFauZ6Khs/07L6VQ7
         8fEQslaV2vb/ZXA0Og11MSXFEbAdMSLEtPVqbr40KrZfrJfZgZWTK+zg+P38KPddFqxv
         PUOThoGgegixzLsrfgm40RcHxtMXkV/GKVu8Gsh+HmRQAIgemeLJ2mVLEJMxJ3Q8zBkl
         29xBWvLl5suTO09d5Uwt1BnYWevdwf2yc2VYIdILufWXmqSqP+70itCgzJi/k2HIlseT
         9iD9D3eEaHvQmuSrtPtOytxfJhlzuXVeNSUFynOk8QAXGwa+dualtkSrT1NC2UKbIPgI
         zoUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=TkW8GIak1sWS2ca5tIb1/Cjm6iWO273i074PYzFAbxw=;
        b=V8XaeuKYujAqrdE234HAW8q8xHDJILZGAUv0RvS+TyEc4nEmMTvs00AKOZXj739uZi
         hOnGMbPthQ/UqbW25cjhSlKp6JZIoqiIftzCMYdPzYGoPV9ZqDPXJvg30pjzVhUmUkmz
         L1V1Ih1gAdGDdH+dqbHEEhYBZy+9lVnvTOZuGKRUayIrCBQVotg80OgCpx7dWPp3A5xc
         nmEGG0l4yWaeU6LPEuSiJxYXZjIZfkmX9EhIy+v3wxQbd1IrCNVbiWNG/KxCnckhVZNZ
         DPXmIDjLChaWrjT6XFhxoR1uO/TzZBDPqo4j2deAP7u8K1bdeFgBzsJZ6eyPO4xhRCYm
         NzGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w11si2037718eda.242.2019.02.11.10.35.09
        for <linux-mm@kvack.org>;
        Mon, 11 Feb 2019 10:35:10 -0800 (PST)
Received-SPF: pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of james.morse@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=james.morse@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 67C0AEBD;
	Mon, 11 Feb 2019 10:35:08 -0800 (PST)
Received: from [10.1.196.105] (eglon.cambridge.arm.com [10.1.196.105])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 788563F557;
	Mon, 11 Feb 2019 10:35:05 -0800 (PST)
Subject: Re: [PATCH v8 00/26] APEI in_nmi() rework and SDEI wire-up
To: "Rafael J. Wysocki" <rafael@kernel.org>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Borislav Petkov <bp@alien8.de>,
 ACPI Devel Maling List <linux-acpi@vger.kernel.org>,
 kvmarm@lists.cs.columbia.edu,
 Linux ARM <linux-arm-kernel@lists.infradead.org>,
 Linux Memory Management List <linux-mm@kvack.org>,
 Marc Zyngier <marc.zyngier@arm.com>,
 Christoffer Dall <christoffer.dall@arm.com>,
 Will Deacon <will.deacon@arm.com>, Catalin Marinas
 <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
 Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>,
 Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>
References: <20190129184902.102850-1-james.morse@arm.com>
 <15200237.N8Ro7ITLGE@aspire.rjw.lan>
 <a8b9983d-5eef-2f30-441f-73ce50da7bca@arm.com>
 <CAJZ5v0ibUO7F=+_GBbhEz4nc0jtC=UaK+cOcLCBrXd2pfc0iLg@mail.gmail.com>
From: James Morse <james.morse@arm.com>
Message-ID: <f561e55c-3560-6a5a-bd23-5d687227e257@arm.com>
Date: Mon, 11 Feb 2019 18:35:03 +0000
User-Agent: Mozilla/5.0 (X11; Linux aarch64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <CAJZ5v0ibUO7F=+_GBbhEz4nc0jtC=UaK+cOcLCBrXd2pfc0iLg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Rafael,

On 11/02/2019 11:05, Rafael J. Wysocki wrote:
> On Fri, Feb 8, 2019 at 3:13 PM James Morse <james.morse@arm.com> wrote:
>> On 08/02/2019 11:40, Rafael J. Wysocki wrote:
>>> On Tuesday, January 29, 2019 7:48:36 PM CET James Morse wrote:
>>>> This series aims to wire-up arm64's fancy new software-NMI notifications
>>>> for firmware-first RAS. These need to use the estatus-queue, which is
>>>> also needed for notifications via emulated-SError. All of these
>>>> things take the 'in_nmi()' path through ghes_copy_tofrom_phys(), and
>>>> so will deadlock if they can interact, which they might.
>>
>>>> Known issues:
>>>>  * ghes_copy_tofrom_phys() already takes a lock in NMI context, this
>>>>    series moves that around, and makes sure we never try to take the
>>>>    same lock from different NMIlike notifications. Since the switch to
>>>>    queued spinlocks it looks like the kernel can only be 4 context's
>>>>    deep in spinlock, which arm64 could exceed as it doesn't have a
>>>>    single architected NMI. This would be fixed by dropping back to
>>>>    test-and-set when the nesting gets too deep:
>>>>  lore.kernel.org/r/1548215351-18896-1-git-send-email-longman@redhat.com
>>>>
>>>> * Taking an NMI from a KVM guest on arm64 with VHE leaves HCR_EL2.TGE
>>>>   clear, meaning AT and TLBI point at the guest, and PAN/UAO are squiffy.
>>>>   Only TLBI matters for APEI, and this is fixed by Julien's patch:
>>>>  http://lore.kernel.org/r/1548084825-8803-2-git-send-email-julien.thierry@arm.com
>>>>
>>>> * Linux ignores the physical address mask, meaning it doesn't call
>>>>   memory_failure() on all the affected pages if firmware or hypervisor
>>>>   believe in a different page size. Easy to hit on arm64, (easy to fix too,
>>>>   it just conflicts with this series)
>>
>>
>>>> James Morse (26):
>>>>   ACPI / APEI: Don't wait to serialise with oops messages when
>>>>     panic()ing
>>>>   ACPI / APEI: Remove silent flag from ghes_read_estatus()
>>>>   ACPI / APEI: Switch estatus pool to use vmalloc memory
>>>>   ACPI / APEI: Make hest.c manage the estatus memory pool
>>>>   ACPI / APEI: Make estatus pool allocation a static size
>>>>   ACPI / APEI: Don't store CPER records physical address in struct ghes
>>>>   ACPI / APEI: Remove spurious GHES_TO_CLEAR check
>>>>   ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
>>>>   ACPI / APEI: Generalise the estatus queue's notify code
>>>>   ACPI / APEI: Don't allow ghes_ack_error() to mask earlier errors
>>>>   ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
>>>>   ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
>>>>   KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
>>>>   arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
>>>>   ACPI / APEI: Move locking to the notification helper
>>>>   ACPI / APEI: Let the notification helper specify the fixmap slot
>>>>   ACPI / APEI: Pass ghes and estatus separately to avoid a later copy
>>>>   ACPI / APEI: Make GHES estatus header validation more user friendly
>>>>   ACPI / APEI: Split ghes_read_estatus() to allow a peek at the CPER
>>>>     length
>>>>   ACPI / APEI: Only use queued estatus entry during
>>>>     in_nmi_queue_one_entry()
>>>>   ACPI / APEI: Use separate fixmap pages for arm64 NMI-like
>>>>     notifications
>>>>   mm/memory-failure: Add memory_failure_queue_kick()
>>>>   ACPI / APEI: Kick the memory_failure() queue for synchronous errors
>>>>   arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
>>>>   firmware: arm_sdei: Add ACPI GHES registration helper
>>>>   ACPI / APEI: Add support for the SDEI GHES Notification type
>>
>>
>>> I can apply patches in this series up to and including patch [21/26].
>>>
>>> Do you want me to do that?
>>
>> 9-12, 17-19, 21 are missing any review/ack tags, so I wouldn't ask, but as
>> you're offering, yes please!
>>
>>
>>> Patch [22/26] requires an ACK from mm people.
>>>
>>> Patch [23/26] has a problem that randconfig can generate a configuration
>>> in which memory_failure_queue_kick() is not present, so it is necessary
>>> to add a CONFIG_MEMORY_FAILURE dependency somewhere for things to
>>> work (or define an empty stub for that function in case the symbol is
>>> not set).
>>
>> Damn-it! Thanks, I was just trying to work that report out...
>>
>>
>>> If patches [24-26/26] don't depend on the previous two, I can try to
>>> apply them either, so please let me know.
>>
>> 22-24 depend on each other. Merging 24 without the other two is no-improvement,
>> so I'd like them to be kept together.
>>
>> 25-26 don't depend on 22-24, but came later so that they weren't affected by the
>> same race.
>> (note to self: describe that in the cover letter next time.)
>>
>>
>> If I apply the tag's and Boris' changes and post a tested v9 as 1-21, 25-26, is
>> that easier, or does it cause extra work?
> 
> Actually, I went ahead and applied them, since I had the 1-21 ready anyway.

> I applied the Boris' fixups manually which led to a bit of rebasing,
> so please check my linux-next branch.

Looks okay to me, and I ran your branch through the POLL/SEA/SDEI tests I've
been doing for each version so far.


Thanks!

James

