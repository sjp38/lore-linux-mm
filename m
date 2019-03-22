Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB2F9C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:37:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64B6E20850
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 10:37:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64B6E20850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9FA66B026F; Fri, 22 Mar 2019 06:37:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E507A6B0270; Fri, 22 Mar 2019 06:37:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D3EE26B0271; Fri, 22 Mar 2019 06:37:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 77E4B6B026F
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 06:37:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id d5so751284edl.22
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 03:37:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gSiJQfIPML9gLrzmriwMRwb64RJ2vHaOnLr1sL4soB8=;
        b=iMIJ4LQa4tAI+AhzRdStQy68qytJM9evW8clNZDjX2QoIVsAEHfhOk6AKPaEvseU2i
         4dfnbnVRvkg6w3p/8RwxnTYVrbU+J7oCbsGg68SWY71IkYAWfllbU2T/VXTYLxHyx0R/
         2GkdMYmnCDAgtMC88ojsWfoJYf5ivSg6Kn/nEw4PWTbeIE4sKsIVgxWQX+Jwo8FhXDS4
         cPW3MRqFQH7qe6PI9BcsJnHgWOW6edlb+dsBuREAYOEWPS43Dd3Rfz/agkz9vBMGS80n
         KIwQ0bdMOySIBut0oZTO/VIBCqKtc/q+8g9t+j4Irh1hRgPRnUKVLy+eA0If8g5F3qGs
         zDfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVE64UCYAiBYHbNx/FA3GvSWgB0Pgk1BKe6U/Pyy38K9WKmUfFc
	GISOPoDNx6Hs8r+JgTQpEddhl2RD+fHK5up31UxGzv/+MLdGJ5Xk9yS9QX5BNhxS+Y9l9q6kX/5
	FEmrlpZL4gfB/kWdwM1ihr7/gubTyyAmbo7gQN502Kvorqjv7Mn3eLWiwkV2INstqjg==
X-Received: by 2002:a50:b493:: with SMTP id w19mr6147091edd.11.1553251041029;
        Fri, 22 Mar 2019 03:37:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqywfYGl9sG9NP79GE+5WMeyfetBe0zRwimBaPk/qVjhpj7/fSB+al5QtOX+P8ybcloiJUJs
X-Received: by 2002:a50:b493:: with SMTP id w19mr6147046edd.11.1553251040126;
        Fri, 22 Mar 2019 03:37:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553251040; cv=none;
        d=google.com; s=arc-20160816;
        b=pji91tDOhX1KzNPGEWdZuamf00Nx8+m0XMu7BqEsnkiwfu3eGB/rA8BnCOdovWo5iE
         +3m5SDdpzJTuH9ZlTavUdP/+t8T/3AgviAAVHCKbqAtrVZjINZE7LG3fT4S/gSdFBE7A
         4GPPRv1V4gEo3LRpgkK4h+SuL2+5CVso94J0YebA2N+mcyxC6O2Y2gduQOQFnVjuIrq0
         ThRtfUJAFqZcyD549DTNtCX95i/aY+64iD2/6twMWVDHHd/1H1vylBRUitK7PiubrFVp
         08nnQC1Js67LWxnKBsNXEvYWUV+K6WwO0SqmvDLQ7/S2yM7liBLV20BC2sqk4TAk7LHf
         hUCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gSiJQfIPML9gLrzmriwMRwb64RJ2vHaOnLr1sL4soB8=;
        b=S0usPXU7Ou/zhme0+OdT/FtBXU50j14dzTwHA/OXswtxhmfYZvC8JsKiL+OjhXqlm+
         7xHemANwWgcXbgbo53gvmaAgP9IyKT9HtBMD1HH9E8qTHon+vWQYl4TLpRtOVb+D1XjM
         bqf2WSMarzODkCZD7BWoyHXqo/DIa8+l8L4MMLkV9/iHTfL4J2S5kaIdpbThewuEVdCe
         jAgC96B7YxF2XsUICUG2vtqMZ4JSNig4NoW14a0ZfEtP24H8yk5zTYpRUv+PCr3Lft2G
         LNvJT1j1RQu2FWCbH+EwtnP4EfGZ6/KCqdnbMop02JRL/fZuVFygpu/BDJU7KnDWJHeq
         3twg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y18si3471377edc.58.2019.03.22.03.37.19
        for <linux-mm@kvack.org>;
        Fri, 22 Mar 2019 03:37:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D55CB374;
	Fri, 22 Mar 2019 03:37:18 -0700 (PDT)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B5DB43F575;
	Fri, 22 Mar 2019 03:37:15 -0700 (PDT)
Subject: Re: [PATCH v5 10/19] mm: pagewalk: Add p4d_entry() and pgd_entry()
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Peter Zijlstra <peterz@infradead.org>,
 Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org,
 Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
 James Morse <james.morse@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 linux-arm-kernel@lists.infradead.org, "Liang, Kan"
 <kan.liang@linux.intel.com>
References: <20190321141953.31960-1-steven.price@arm.com>
 <20190321141953.31960-11-steven.price@arm.com>
 <20190321211510.GA27213@rapoport-lnx>
 <03f5ad0f-2450-c53f-b1e6-d2c0f2d4879c@arm.com>
 <20190322102930.GA24367@rapoport-lnx>
From: Steven Price <steven.price@arm.com>
Message-ID: <f3ec9d74-f578-117a-6529-469089e46788@arm.com>
Date: Fri, 22 Mar 2019 10:37:14 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190322102930.GA24367@rapoport-lnx>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 22/03/2019 10:29, Mike Rapoport wrote:
> On Fri, Mar 22, 2019 at 10:11:59AM +0000, Steven Price wrote:
>> On 21/03/2019 21:15, Mike Rapoport wrote:
>>> On Thu, Mar 21, 2019 at 02:19:44PM +0000, Steven Price wrote:
>>>> pgd_entry() and pud_entry() were removed by commit 0b1fbfe50006c410
>>>> ("mm/pagewalk: remove pgd_entry() and pud_entry()") because there were
>>>> no users. We're about to add users so reintroduce them, along with
>>>> p4d_entry() as we now have 5 levels of tables.
>>>>
>>>> Note that commit a00cc7d9dd93d66a ("mm, x86: add support for
>>>> PUD-sized transparent hugepages") already re-added pud_entry() but with
>>>> different semantics to the other callbacks. Since there have never
>>>> been upstream users of this, revert the semantics back to match the
>>>> other callbacks. This means pud_entry() is called for all entries, not
>>>> just transparent huge pages.
>>>>
>>>> Signed-off-by: Steven Price <steven.price@arm.com>
>>>> ---
>>>>  include/linux/mm.h |  9 ++++++---
>>>>  mm/pagewalk.c      | 27 ++++++++++++++++-----------
>>>>  2 files changed, 22 insertions(+), 14 deletions(-)
>>>>
>>>> diff --git a/include/linux/mm.h b/include/linux/mm.h
>>>> index 76769749b5a5..2983f2396a72 100644
>>>> --- a/include/linux/mm.h
>>>> +++ b/include/linux/mm.h
>>>> @@ -1367,10 +1367,9 @@ void unmap_vmas(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
>>>>
>>>>  /**
>>>>   * mm_walk - callbacks for walk_page_range
>>>> + * @pgd_entry: if set, called for each non-empty PGD (top-level) entry
>>>> + * @p4d_entry: if set, called for each non-empty P4D (1st-level) entry
>>>
>>> IMHO, p4d implies the 4th level :)
>>
>> You have a good point there... I was simply working back from the
>> existing definitions (below) of PTE:4th, PMD:3rd, PUD:2nd. But it's
>> already somewhat broken by PGD:0th and my cop-out was calling it "top".
>>
>>> I think it would make more sense to start counting from PTE rather than
>>> from PGD. Then it would be consistent across architectures with fewer
>>> levels.
>>
>> It would also be the opposite way round to architectures such as Arm
>> which number their levels, for example [1] refers to levels 0-3 (with 3
>> being PTE in Linux terms).
> 
> By consistent I meant that for architectures with fewer levels we won't be
> describing PTE as level 4 when the architecture only has 2 levels.

Ah I see, although we've apparently been doing that for over a decade
already[2] :)

[2]
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=e6473092bd9116583ce9ab8cf1b6570e1aa6fc83

>> [1]
>> https://developer.arm.com/docs/100940/latest/translation-tables-in-armv8-a
>>
>> Probably the least confusing thing is to drop the level numbers in
>> brackets since I don't believe they directly match any architecture, and
>> hopefully any user of the page walking code is already familiar with the
>> P?D terms used by the kernel.
> 
> That's a fair assumption :)
> Still, maybe we keep your (top-level) for PGD and use (lowest level) for
> PTE and drop those in the middle?

Yes that's a good compromise.

Thanks,

Steve

