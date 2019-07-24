Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 303F8C7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:35:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8A6B22ADA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 13:35:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8A6B22ADA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8FBB16B000C; Wed, 24 Jul 2019 09:35:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AB898E0003; Wed, 24 Jul 2019 09:35:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 775708E0002; Wed, 24 Jul 2019 09:35:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 289716B000C
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 09:35:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id e9so19103601edv.18
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 06:35:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jcB/fwvP+XmN7nlPXpSGVweOLawZcJu9AZNteuHDrIM=;
        b=CHLvi/06tF1YORIIS/B8HQlad/K/CaZfvLSUIRhFwGX+IRDlL6T01MbkcypX6gcZBe
         6Wc1W64wWGdDWg/5swsjg4e/pVKIxFzra44USlCfbtkOfOpsOsk16ugzMxgEiHgr+12H
         /Lg213SVk61qkjGSnJ3nJg2G0HH4X3+lVlMHueduqmpEW9voy6/KOIfa0l98YYf4iWgE
         XjZG0J0wbsECVzgeH5dg5ogvwIDqzs9VdLNOzYmFdABuxE88kbSLzn/tzzmfwv2vUthg
         04TEbHFq9EiS5/C+2Cs2cGkGzwuUOoZdnF/fuifNC3Ysfx+5vKvOAxn/2p+XEyraGqgB
         4yXw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXE4Sva+AszLtMqNzYWfx8Y6y7Il3WbTsiIaNZWjIBPKe2kF249
	c/qRDqdIgwId4lszKGskc17FHTrVRs8VGIuR36awF7E35IEYa9Fc2hUnPD9MjKtEpbqDVFq2Kji
	BoizOychXddItkIX3BLr+mKZgRH7oL/BywVZM3ZK9QTKokrIkaEIhg/qV0L/Ts1oD3Q==
X-Received: by 2002:a17:906:3612:: with SMTP id q18mr64297484ejb.278.1563975347697;
        Wed, 24 Jul 2019 06:35:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxr1ImE0heeckHpC6oSqxOueZDl4KG47O4t08qoNv9WJiMwhh+/JHGEfBEOus2NfTGJGu+
X-Received: by 2002:a17:906:3612:: with SMTP id q18mr64297414ejb.278.1563975346773;
        Wed, 24 Jul 2019 06:35:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563975346; cv=none;
        d=google.com; s=arc-20160816;
        b=ab4igud2k7dI3KVisq0Svd/Ha10P0U/svaEq6RUwhMDIWAPNcg5wUOoG8V/mUh06dZ
         HKAsR1l4l2SU3E4eL18IufO5lkLiXMie4gBn4bptyKBooddA60OqvBiIw5IZeP2Ui1s4
         OeQKsOBWAYTVPmaPQwPkYK1mlzYK8KG3SiXb0nxwVaYftrZTRF4vuSYI6rK4bSe96zdB
         uDBXiDIkqXf8jeHh++iPmhJZQCHMCbKgAPRpYf+PMyHHBHC95uoRGzZpZutPSqlcXlPk
         1x9vtRoqZIWU+x3GzXzmdOShgG3wT4EFAXLSmT2TP8LDU75zOoMKjWJx5KvI11wb650z
         r1hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jcB/fwvP+XmN7nlPXpSGVweOLawZcJu9AZNteuHDrIM=;
        b=IBgtS0ofE18QcRjDxtnPIAvpANUlbHkBrGkriY4of8dD9S3EyodEQfNINEh4qnAZDE
         7vrzKwSDsyiU+XaG+4ZWeeqL7opfN3iMrvaOZvA9Yv/0OnAB7JbRHV9GVNx7Pn5EZ6YZ
         9f5sErsM4y9aNhO6eRIQlFfgsoL2FUesbSYGj33J/t8mhQ8H2kqcKcp3REIr3o0g3GtU
         eldx4b/eVkxOWTEKTiktoO6HF+iplH59a2n0h3wq1eyw2ugXxqGXdUjOyR6ng/3EaK0Z
         a3rK0jZ1IFi6O+gm8U2N/31z//hvs8aKs1xTEilTNsQ4ukOVKICuZEZTK4v3+s45Eydg
         VJbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id p55si9318837edc.414.2019.07.24.06.35.46
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 06:35:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C816B337;
	Wed, 24 Jul 2019 06:35:45 -0700 (PDT)
Received: from [10.1.196.133] (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1EAC53F71A;
	Wed, 24 Jul 2019 06:35:43 -0700 (PDT)
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Mark Rutland <Mark.Rutland@arm.com>, x86@kernel.org,
 Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Will Deacon <will@kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190722154210.42799-1-steven.price@arm.com>
 <835a0f2e-328d-7f7f-e52a-b754137789f9@arm.com>
From: Steven Price <steven.price@arm.com>
Message-ID: <c9d2042f-c731-4705-4148-b38deccf7963@arm.com>
Date: Wed, 24 Jul 2019 14:35:41 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <835a0f2e-328d-7f7f-e52a-b754137789f9@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 23/07/2019 07:39, Anshuman Khandual wrote:
> Hello Steven,
> 
> On 07/22/2019 09:11 PM, Steven Price wrote:
>> This is a slight reworking and extension of my previous patch set
>> (Convert x86 & arm64 to use generic page walk), but I've continued the
>> version numbering as most of the changes are the same. In particular
>> this series ends with a generic PTDUMP implemention for arm64 and x86.
>>
>> Many architectures current have a debugfs file for dumping the kernel
>> page tables. Currently each architecture has to implement custom
>> functions for this because the details of walking the page tables used
>> by the kernel are different between architectures.
>>
>> This series extends the capabilities of walk_page_range() so that it can
>> deal with the page tables of the kernel (which have no VMAs and can
>> contain larger huge pages than exist for user space). A generic PTDUMP
>> implementation is the implemented making use of the new functionality of
>> walk_page_range() and finally arm64 and x86 are switch to using it,
>> removing the custom table walkers.
> 
> Could other architectures just enable this new generic PTDUMP feature if
> required without much problem ?

The generic PTDUMP is implemented as a library - so the architectures
would have to provide the call into ptdump_walk_pgd() and provide the
necessary callback note_page() which formats the lines in the output.

Hopefully the implementation is generic enough that it should be
flexible enough to work for most architectures.

arm, powerpc and s390 are the obvious architectures to convert next as
they already have note_page() functions which shouldn't be too difficult
to convert to match the callback prototype.

>>
>> To enable a generic page table walker to walk the unusual mappings of
>> the kernel we need to implement a set of functions which let us know
>> when the walker has reached the leaf entry. After a suggestion from Will
>> Deacon I've chosen the name p?d_leaf() as this (hopefully) describes
>> the purpose (and is a new name so has no historic baggage). Some
>> architectures have p?d_large macros but this is easily confused with
>> "large pages".
> 
> I have not been following the previous version of the series closely, hence
> might be missing something here. But p?d_large() which identifies large
> mappings on a given level can only signify a leaf entry. Large pages on the
> table exist only as leaf entries. So what is the problem for it being used
> directly instead. Is there any possibility in the kernel mapping when these
> large pages are not leaf entries ?

There isn't any problem as such with using p?d_large macros. However the
name "large" has caused confusion in the past. In particular there are
two types of "large" page:

1. leaf entries at high levels than normal ('sections' on Arm, for 4K
pages this gives you 2MB and 1GB pages).

2. sets of contiguous entries that can share a TLB entry (the
'Contiguous bit' on Arm - which for 4K pages gives you 16 entries = 64
KB 'pages').

In many cases both give the same effect (reduce pressure on TLBs and
requires contiguous and aligned physical addresses). But for this case
we only care about the 'leaf' case (because the contiguous bit makes no
difference to walking the page tables).

As far as I'm aware p?d_large() currently implements the first and
p?d_(trans_)huge() implements either 1 or 2 depending on the architecture.

Will[1] suggested the same p?d_leaf() and this also avoids stepping on
the existing usage of p?d_large() which isn't always available on every
architecture.

[1]
https://lore.kernel.org/linux-mm/20190701101510.qup3nd6vm6cbdgjv@willie-the-truck/

>>
>> Mostly this is a clean up and there should be very little functional
>> change. The exceptions are:
>>
>> * x86 PTDUMP debugfs output no longer display pages which aren't
>>   present (patch 14).
> 
> Hmm, kernel mappings pages which are not present! which ones are those ?
> Just curious.

x86 currently outputs a line for every range, including those which are
unpopulated. Patch 14 removes those lines from the output, only showing
the populated ranges. This was discussed[2] previously.

[2]
https://lore.kernel.org/lkml/26df02dd-c54e-ea91-bdd1-0a4aad3a30ac@arm.com/

>>
>> * arm64 has the ability to efficiently process KASAN pages (which
>>   previously only x86 implemented). This means that the combination of
>>   KASAN and DEBUG_WX is now useable.
>>
>> Also available as a git tree:
>> git://linux-arm.org/linux-sp.git walk_page_range/v9
>>
>> Changes since v8:
>> https://lore.kernel.org/lkml/20190403141627.11664-1-steven.price@arm.com/
>>  * Rename from p?d_large() to p?d_leaf()
> 
> As mentioned before wondering if this is actually required or it is even a
> good idea to introduce something like this which expands page table helper
> semantics scope further in generic MM.
> 
>>  * Dropped patches migrating arm64/x86 custom walkers to
>>    walk_page_range() in favour of adding a generic PTDUMP implementation
>>    and migrating arm64/x86 to that instead.
>>  * Rebased to v5.3-rc1
> 
> Creating a generic PTDUMP implementation is definitely a better idea.

Yes, that was always where I was heading. But I initially thought it
would be easier to get the generic walking code in, followed by
implementing generic PTDUMP. But it turns out the generic PTDUMP is
actually the easy bit :)

Steve

