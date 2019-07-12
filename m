Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 421DDC742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:07:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C67F2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:07:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C67F2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C90B8E011D; Fri, 12 Jul 2019 03:07:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 979348E00DB; Fri, 12 Jul 2019 03:07:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 88E2C8E011D; Fri, 12 Jul 2019 03:07:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53B798E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:07:53 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 145so5005362pfv.18
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:07:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=NCHQvVXSONgvwbP5Ag65P0BSR4RcipDFT9utg82Dkxc=;
        b=MLFf2SiTO9Sbv9Avo/3n2aTpDr8adH5gbfb6vSpaIwKyy+q5rYH42dX4OBGmFRebWv
         fVdszj3oEvQ5J3fFN34Z9aKv86kxiBpcI/UwahBZ1A2HajO9CmPSk+z3ZNTFd5TKtDF1
         KylNB+m/MbthAD/GKzcxQQNKGInzhw6HQ1euMfj5HZ4icFiNvph5Fv/nmSbqpKi7iIKb
         42SlnDzvvfIklqVXEWe7xe1psib2u/bMfQLnGM7XHrK7tpSRq6mXBJ5UxNxR0ryQ+rfX
         lHzOcjczdZigR8KWnbFU9ci1qBhydqbwGbh5NWzk0+A7M0mASHNHJ9kwcxJtGblf52xp
         VgDw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAUTMGvkYB//x/nkH8L/ZBRa5Ziqw0EOQa0Rq6bs0ceansdGuJ/o
	S9wCOU+vB/F0vSKBuTiv1sOBt3gRGACmkEhDJJqSt6bWkMPdaj+1W+Uvm+h1VRNw7pkcFdpFVLH
	Xd8CwqRR/1l1VHGH8050j85wZcWgxWgsp1i6MGL2H3S3pW4Id0scyYQz5G3tOkjw=
X-Received: by 2002:a63:e5a:: with SMTP id 26mr8729492pgo.3.1562915272903;
        Fri, 12 Jul 2019 00:07:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzF7xtoEBMvNqRB6RFfb2RRA1t0HO0/mj5khlj4u7yVHY1r+y6yzMn8fn1Idv4j9eeTjvpO
X-Received: by 2002:a63:e5a:: with SMTP id 26mr8729444pgo.3.1562915272184;
        Fri, 12 Jul 2019 00:07:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562915272; cv=none;
        d=google.com; s=arc-20160816;
        b=w/VvvSIA5OBBfqoYjMgYefOF7D6BOaOlYDlwYYN0/aaolVMzENleVwvMrI4hrv/iz3
         /f4WA4VlXskexWQN/ihuODSSYkXRzL9iEuMB3WfgsRURXKsLaaRh6S40xzNOlq8J93ST
         1CZDfhfK1OoplzdAkSF3/vkzzzs2QJGVoMnW+MUKoCNEPuItQZtAgTrB8UdEUAPWuKVu
         Oj3hMDX29w2CmLkfDFyA5EpkcvylwCGrW3kyrsPHe+nx3LjvrseqedO+utZFNGRI3xTe
         RCCy0eXPHN9se/qEb+hG9eFytrBZVQm3JuL0iXGkQhDEUOYb9m1AdiUcmACBoJZfbLEG
         gMEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=NCHQvVXSONgvwbP5Ag65P0BSR4RcipDFT9utg82Dkxc=;
        b=Vk9D4R5ayYWNa2XTEwflSP3mXEhwP+w7+GxzQu6UbAP9vsET/q6RY3m5yzF/FpQhI6
         eclCLCcEGRfu/mlgUj7Vxiolfd1Rh8evoSUWVOnco2FyNCKUkTMO3cC4wR+5vBu31/vw
         gsCITi+rktx9YTOgSieJZ+SJBHJUU117E+VT7kJXNsUzz7DYTpmqaCUY7SA6VMuks00g
         HdHTzzK1N3vSTJ2mx+/iMPxhguSjZdxHx9cTAvb/GbhoqJ15TDw8f+o3FcyTUpNSOJ+T
         K6PY+82xR7HfBkHmPmPcr2FJA7vMvDmuuzvdiXeJu2IhY9T7jJ/PARP7gllujpsTUMyx
         jZnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id v137si7729628pfc.190.2019.07.12.00.07.51
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Fri, 12 Jul 2019 00:07:52 -0700 (PDT)
Received-SPF: neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2401:3900:2:1::2 is neither permitted nor denied by best guess record for domain of mpe@ellerman.id.au) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45lPBs30dBz9s00;
	Fri, 12 Jul 2019 17:07:49 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: Anshuman Khandual <anshuman.khandual@arm.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org
Subject: Re: [PATCH V2] mm/ioremap: Probe platform for p4d huge map support
In-Reply-To: <fbc147c7-bec2-daed-b828-c4ae170010a9@arm.com>
References: <1561699231-20991-1-git-send-email-anshuman.khandual@arm.com> <20190702160630.25de5558e9fe2d7d845f3472@linux-foundation.org> <fbc147c7-bec2-daed-b828-c4ae170010a9@arm.com>
Date: Fri, 12 Jul 2019 17:07:48 +1000
Message-ID: <87tvbrennf.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Anshuman Khandual <anshuman.khandual@arm.com> writes:
> On 07/03/2019 04:36 AM, Andrew Morton wrote:
>> On Fri, 28 Jun 2019 10:50:31 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
>> 
>>> Finishing up what the commit c2febafc67734a ("mm: convert generic code to
>>> 5-level paging") started out while levelling up P4D huge mapping support
>>> at par with PUD and PMD. A new arch call back arch_ioremap_p4d_supported()
>>> is being added which just maintains status quo (P4D huge map not supported)
>>> on x86, arm64 and powerpc.
>> 
>> Does this have any runtime effects?  If so, what are they and why?  If
>> not, what's the actual point?
>
> It just finishes up what the previous commit c2febafc67734a ("mm: convert
> generic code to 5-level paging") left off with respect p4d based huge page
> enablement for ioremap. When HAVE_ARCH_HUGE_VMAP is enabled its just a simple
> check from the arch about the support, hence runtime effects are minimal.

The return value of arch_ioremap_p4d_supported() is stored in the
variable ioremap_p4d_capable which is then returned by
ioremap_p4d_enabled().

That is used by ioremap_try_huge_p4d() called from ioremap_p4d_range()
from ioremap_page_range().

The runtime effect is that it prevents ioremap_page_range() from trying
to create huge mappings at the p4d level on arches that don't support
it.

cheers

