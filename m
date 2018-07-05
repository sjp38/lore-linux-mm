Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B57A46B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 11:42:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x18-v6so7515885oie.7
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 08:42:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h189-v6si2614100oia.293.2018.07.05.08.42.58
        for <linux-mm@kvack.org>;
        Thu, 05 Jul 2018 08:42:58 -0700 (PDT)
Subject: Re: [PATCH v5 00/20] APEI in_nmi() rework and arm64 SDEI wire-up
References: <20180626170116.25825-1-james.morse@arm.com>
 <4409985.sv3PbRGN0l@aspire.rjw.lan>
From: James Morse <james.morse@arm.com>
Message-ID: <1246af75-eaf4-e306-2276-65859be053e6@arm.com>
Date: Thu, 5 Jul 2018 16:42:51 +0100
MIME-Version: 1.0
In-Reply-To: <4409985.sv3PbRGN0l@aspire.rjw.lan>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Tony Luck <tony.luck@intel.com>
Cc: linux-acpi@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Borislav Petkov <bp@alien8.de>, Marc Zyngier <marc.zyngier@arm.com>, Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Len Brown <lenb@kernel.org>, Tyler Baicar <tbaicar@codeaurora.org>, Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>, Punit Agrawal <punit.agrawal@arm.com>, jonathan.zhang@cavium.com

Hi guys,

On 05/07/18 10:50, Rafael J. Wysocki wrote:
> On Tuesday, June 26, 2018 7:00:56 PM CEST James Morse wrote:
>> The aim of this series is to wire arm64's SDEI into APEI.
>>
>> On arm64 we have three APEI notifications that are NMI-like, and
>> in the unlikely event that all three are supported by a platform,
>> they can interrupt each other.
>> The GHES driver shouldn't have to deal with this, so this series aims
>> to make it re-entrant.
>>
>> To do that, we refactor the estatus queue to allow multiple notifications
>> to use it, then convert NOTIFY_SEA to always be described as NMI-like,
>> and to use the estatus queue.
>>
>> From here we push the locking and fixmap choices out to the notification
>> functions, and remove the use of per-ghes estatus and flags. This removes
>> the in_nmi() 'timebomb' in ghes_copy_tofrom_phys().
>>
>> Things get sticky when an NMI notification needs to know how big the
>> CPER records might be, before reading it. This series splits
>> ghes_estatus_read() to let us peek at the buffer. A side effect of this
>> is the 20byte header will get read twice. (how does it work today? it
>> reads the records into a per-ghes worst-case sized buffer, allocates
>> the correct size and copies the records. in_nmi() use of this per-ghes
>> buffer needs eliminating).
>>
>> One alternative was to trust firmware's 'max raw data length' and use
>> that to allocate 'enough' memory. We don't use this value today, so its
>> probably wrong on some sytem somewhere.
>>
>> Since v4 patches 5,8-15 are new, otherwise changes are noted in the patch.

> Tony, I need your help with reviewing the APEI-related material here.
> Can you please have a look at this series and let me know if there are
> any concerns regarding it?

Thanks.

I think the only context from earlier versions is where Borislav spotted some
issues with the ghes_proc() call at probe time and NMI-like notifications.

>From https://www.spinics.net/lists/arm-kernel/msg653332.html :
| Which means, that this code is not really reentrant and if should be
| fixed to be callable from different contexts, then it should use private
| buffers and be careful about locking.

... the patches for which have bloated this series.


Thanks,

James
