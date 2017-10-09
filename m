Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 662496B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:42:37 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id a47so16848749uai.10
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:42:37 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id d22si6503304itb.204.2017.10.09.11.42.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 11:42:36 -0700 (PDT)
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v99IgZHV026772
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 18:42:35 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id v99IgYSf030388
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 18:42:34 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id v99IgYMR004842
	for <linux-mm@kvack.org>; Mon, 9 Oct 2017 18:42:34 GMT
Received: by mail-oi0-f45.google.com with SMTP id m198so28924683oig.5
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:42:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171009182217.GC30828@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com> <20171003144845.GD4931@leverpostej>
 <20171009171337.GE30085@arm.com> <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
 <20171009182217.GC30828@arm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Mon, 9 Oct 2017 14:42:32 -0400
Message-ID: <CAOAebxu1310eCrk88EC=Oaw3n90-9RuHZ1KBhPvLu_DyXBNZFQ@mail.gmail.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Will,

In addition to what Michal wrote:

> As an interim step, why not introduce something like
> vmemmap_alloc_block_flags and make the page-table walking opt-out for
> architectures that don't want it? Then we can just pass __GFP_ZERO from
> our vmemmap_populate where necessary and other architectures can do the
> page-table walking dance if they prefer.

I do not see the benefit, implementing this approach means that we
would need to implement two table walks instead of one: one for x86,
another for ARM, as these two architectures support kasan. Also, this
would become a requirement for any future architecture that want to
add kasan support to add this page table walk implementation.

>> IMO, while I understand that it looks strange that we must walk page
>> table after creating it, it is a better approach: more enclosed as it
>> effects kasan only, and more universal as it is in common code.
>
> I don't buy the more universal aspect, but I appreciate it's subjective.
> Frankly, I'd just sooner not have core code walking early page tables if
> it can be avoided, and it doesn't look hard to avoid it in this case.
> The fact that you're having to add pmd_large and pud_large, which are
> otherwise unused in mm/, is an indication that this isn't quite right imo.

 28 +#define pmd_large(pmd)         pmd_sect(pmd)
 29 +#define pud_large(pud)         pud_sect(pud)

it is just naming difference, ARM64 calls them pmd_sect, common mm and
other arches call them
pmd_large/pud_large. Even the ARM has these defines in

arm/include/asm/pgtable-3level.h
arm/include/asm/pgtable-2level.h

Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
