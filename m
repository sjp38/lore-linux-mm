Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5CC1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 11:06:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F4A520873
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 11:06:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F4A520873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BFD978E00D7; Mon, 11 Feb 2019 06:06:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BAD5C8E00C4; Mon, 11 Feb 2019 06:06:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9C948E00D7; Mon, 11 Feb 2019 06:06:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 816038E00C4
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 06:06:06 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id d5so10659470otl.21
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 03:06:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :references:in-reply-to:from:date:message-id:subject:to:cc;
        bh=zPI7PjhalKapOqadpYNDIzByO1yNXs4bj5jUAy0+XwM=;
        b=MESbi0eMS7tyswPfrkxLHL78CghFVAVtqn65iH8r+2p5THD7CTdSuXNbhQr6spLXjl
         StvG/cxKSL6/l94jJq7Tll5l7vTrgD0BWjH4X8cb6siBDqtQtOqDn9TmkItIaOz62bUs
         vFT1oZNyOQ6vV0suQ0v4qRPDvfHutxCZ7EbBQQ24ld+sXpGhBiGZ+CgVM5lA1fHN2enZ
         ct1siBVVWkfzO5pEHb/qkEeGWDeP0uayX9vY8QuOx4F0dbEjZrYy8tn1hpeaI4D5bKd7
         WLL/BUH8px/tv2joveninLJkwjFIIZu9t0zreZdLP7mGW0REyFrV/tFj8sGyN7PgtH/u
         Gn0Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAubb+QZESu3bOmtctiMbV7vT1eR/r1vliXGtatWB9avCxp0XG6cw
	NsCnb5809ZVbusgrcriO0ppOLFT2sp4HBFAERz9BQmL55zbe6pNC8h2oBavnRcpuc0dc6TYshQZ
	UnFHGlGep8op+vlswyoQDiU9Tpk/gGPYY83YAbE0XW28WGCBrudw3eSpPuCEa8VUlGO3g6Tzw7O
	zg0R76eIm0EXRYOU84Utl9l8AbE/R+7xk9Vt8UMypRrZaoDphrynDI3f6pFTQ/VZngpFR2ZqMTR
	rtxMAvWwkCBOl9r1jGz8T0T5jmmaHC9w/fWF3DQjh0m2jKFxZOgd5vyChXT2MeszIayTnBhM+ms
	qEMGCys1PcI40ltmqvYSWV7yHSXfIJdjjB9/NWtTbB2JBGgOv0mP/UZTsVQvIkSeWUi92ir6QA=
	=
X-Received: by 2002:a05:6830:1005:: with SMTP id a5mr20625728otp.113.1549883166173;
        Mon, 11 Feb 2019 03:06:06 -0800 (PST)
X-Received: by 2002:a05:6830:1005:: with SMTP id a5mr20625606otp.113.1549883164520;
        Mon, 11 Feb 2019 03:06:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549883164; cv=none;
        d=google.com; s=arc-20160816;
        b=gtHoqocaX9rYvg2sXKdrxGGr2J+Z+xfelPRdtdRH3bifBPBv/CxBLz9b/TVfPFn4OC
         krggIUi62u8fQtYNSKpg4ChG766GddjOW+mOlK8UVIL5U61Q88PwDunM4RUOOyovjEU7
         LPSSYbjOYQSN71zP5q3fcEzXgRctNqzMfMUSuSQLjhtXYI8REq3p6+ANx56yi3zAfhkm
         vAVgo93fuXYAZuJDZEMUZbeQdEb2DLC+qK3VXmoKB/qixbmx4J0wma+0scjnUQng4u5w
         h2vyV1bIhgXz2/jANKPmSUdQIA52mzyCApa7NDFPb30mOdHxzflnXjItxHqqIRDnIibD
         eoMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version;
        bh=zPI7PjhalKapOqadpYNDIzByO1yNXs4bj5jUAy0+XwM=;
        b=uZCsuit6ZLgdtXbvCgrWhG/oKVE11qUgubJOE6GpRfacsTVNN9TNXev8k3nC/27o5u
         MOMZISe5QNJswFdDeL68cBtclfXKclfQxqUCpURHc+m44owO+MGyVkFyalYltn1TISOj
         xytrkHNtQFb/P6c8UhTUGjPOBvzIH5YNBaUOdqHaKwjQln47+iTcaKaw02CZe9lcwlNp
         FFnoWdcY4zsGJCxoEdwW7s0hIN1LB+Q9dlkGGZtRuKbtl1Dh64K1uqZL2SQX/kaLMsZv
         s7TmNXt54svg+mwarRA5WKaRqarIsSCIJWuYOhc+TGNeUwNbBmvx/WE4KZ37hedpc2nW
         8j/A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r7sor5973023otq.70.2019.02.11.03.06.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 03:06:04 -0800 (PST)
Received-SPF: pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rjwysocki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=rjwysocki@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Google-Smtp-Source: AHgI3IbqhuaLzlFP3vnwI5lQfCp+NTR8q63Sd4/HJ6XtRio15ezN5QQmmTyNqLT2Rmn/CgtqS7GoG3E+06+CFBOjhCA=
X-Received: by 2002:a9d:5e8c:: with SMTP id f12mr28560952otl.343.1549883164127;
 Mon, 11 Feb 2019 03:06:04 -0800 (PST)
MIME-Version: 1.0
References: <20190129184902.102850-1-james.morse@arm.com> <15200237.N8Ro7ITLGE@aspire.rjw.lan>
 <a8b9983d-5eef-2f30-441f-73ce50da7bca@arm.com>
In-Reply-To: <a8b9983d-5eef-2f30-441f-73ce50da7bca@arm.com>
From: "Rafael J. Wysocki" <rafael@kernel.org>
Date: Mon, 11 Feb 2019 12:05:52 +0100
Message-ID: <CAJZ5v0ibUO7F=+_GBbhEz4nc0jtC=UaK+cOcLCBrXd2pfc0iLg@mail.gmail.com>
Subject: Re: [PATCH v8 00/26] APEI in_nmi() rework and SDEI wire-up
To: James Morse <james.morse@arm.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Borislav Petkov <bp@alien8.de>, 
	ACPI Devel Maling List <linux-acpi@vger.kernel.org>, kvmarm@lists.cs.columbia.edu, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, Marc Zyngier <marc.zyngier@arm.com>, 
	Christoffer Dall <christoffer.dall@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Catalin Marinas <catalin.marinas@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, 
	Len Brown <lenb@kernel.org>, Tony Luck <tony.luck@intel.com>, 
	Dongjiu Geng <gengdongjiu@huawei.com>, Xie XiuQi <xiexiuqi@huawei.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 8, 2019 at 3:13 PM James Morse <james.morse@arm.com> wrote:
>
> Hi Rafael,
>
> On 08/02/2019 11:40, Rafael J. Wysocki wrote:
> > On Tuesday, January 29, 2019 7:48:36 PM CET James Morse wrote:
> >> This series aims to wire-up arm64's fancy new software-NMI notifications
> >> for firmware-first RAS. These need to use the estatus-queue, which is
> >> also needed for notifications via emulated-SError. All of these
> >> things take the 'in_nmi()' path through ghes_copy_tofrom_phys(), and
> >> so will deadlock if they can interact, which they might.
>
> >> Known issues:
> >>  * ghes_copy_tofrom_phys() already takes a lock in NMI context, this
> >>    series moves that around, and makes sure we never try to take the
> >>    same lock from different NMIlike notifications. Since the switch to
> >>    queued spinlocks it looks like the kernel can only be 4 context's
> >>    deep in spinlock, which arm64 could exceed as it doesn't have a
> >>    single architected NMI. This would be fixed by dropping back to
> >>    test-and-set when the nesting gets too deep:
> >>  lore.kernel.org/r/1548215351-18896-1-git-send-email-longman@redhat.com
> >>
> >> * Taking an NMI from a KVM guest on arm64 with VHE leaves HCR_EL2.TGE
> >>   clear, meaning AT and TLBI point at the guest, and PAN/UAO are squiffy.
> >>   Only TLBI matters for APEI, and this is fixed by Julien's patch:
> >>  http://lore.kernel.org/r/1548084825-8803-2-git-send-email-julien.thierry@arm.com
> >>
> >> * Linux ignores the physical address mask, meaning it doesn't call
> >>   memory_failure() on all the affected pages if firmware or hypervisor
> >>   believe in a different page size. Easy to hit on arm64, (easy to fix too,
> >>   it just conflicts with this series)
>
>
> >> James Morse (26):
> >>   ACPI / APEI: Don't wait to serialise with oops messages when
> >>     panic()ing
> >>   ACPI / APEI: Remove silent flag from ghes_read_estatus()
> >>   ACPI / APEI: Switch estatus pool to use vmalloc memory
> >>   ACPI / APEI: Make hest.c manage the estatus memory pool
> >>   ACPI / APEI: Make estatus pool allocation a static size
> >>   ACPI / APEI: Don't store CPER records physical address in struct ghes
> >>   ACPI / APEI: Remove spurious GHES_TO_CLEAR check
> >>   ACPI / APEI: Don't update struct ghes' flags in read/clear estatus
> >>   ACPI / APEI: Generalise the estatus queue's notify code
> >>   ACPI / APEI: Don't allow ghes_ack_error() to mask earlier errors
> >>   ACPI / APEI: Move NOTIFY_SEA between the estatus-queue and NOTIFY_NMI
> >>   ACPI / APEI: Switch NOTIFY_SEA to use the estatus queue
> >>   KVM: arm/arm64: Add kvm_ras.h to collect kvm specific RAS plumbing
> >>   arm64: KVM/mm: Move SEA handling behind a single 'claim' interface
> >>   ACPI / APEI: Move locking to the notification helper
> >>   ACPI / APEI: Let the notification helper specify the fixmap slot
> >>   ACPI / APEI: Pass ghes and estatus separately to avoid a later copy
> >>   ACPI / APEI: Make GHES estatus header validation more user friendly
> >>   ACPI / APEI: Split ghes_read_estatus() to allow a peek at the CPER
> >>     length
> >>   ACPI / APEI: Only use queued estatus entry during
> >>     in_nmi_queue_one_entry()
> >>   ACPI / APEI: Use separate fixmap pages for arm64 NMI-like
> >>     notifications
> >>   mm/memory-failure: Add memory_failure_queue_kick()
> >>   ACPI / APEI: Kick the memory_failure() queue for synchronous errors
> >>   arm64: acpi: Make apei_claim_sea() synchronise with APEI's irq work
> >>   firmware: arm_sdei: Add ACPI GHES registration helper
> >>   ACPI / APEI: Add support for the SDEI GHES Notification type
>
>
> > I can apply patches in this series up to and including patch [21/26].
> >
> > Do you want me to do that?
>
> 9-12, 17-19, 21 are missing any review/ack tags, so I wouldn't ask, but as
> you're offering, yes please!
>
>
> > Patch [22/26] requires an ACK from mm people.
> >
> > Patch [23/26] has a problem that randconfig can generate a configuration
> > in which memory_failure_queue_kick() is not present, so it is necessary
> > to add a CONFIG_MEMORY_FAILURE dependency somewhere for things to
> > work (or define an empty stub for that function in case the symbol is
> > not set).
>
> Damn-it! Thanks, I was just trying to work that report out...
>
>
> > If patches [24-26/26] don't depend on the previous two, I can try to
> > apply them either, so please let me know.
>
> 22-24 depend on each other. Merging 24 without the other two is no-improvement,
> so I'd like them to be kept together.
>
> 25-26 don't depend on 22-24, but came later so that they weren't affected by the
> same race.
> (note to self: describe that in the cover letter next time.)
>
>
> If I apply the tag's and Boris' changes and post a tested v9 as 1-21, 25-26, is
> that easier, or does it cause extra work?

Actually, I went ahead and applied them, since I had the 1-21 ready anyway.

I applied the Boris' fixups manually which led to a bit of rebasing,
so please check my linux-next branch.

Thanks!

