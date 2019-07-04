Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 49A94C0651F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 15:26:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12D582083B
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 15:26:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12D582083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A56676B0006; Thu,  4 Jul 2019 11:26:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2CB68E0003; Thu,  4 Jul 2019 11:26:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91CD68E0001; Thu,  4 Jul 2019 11:26:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 454BF6B0006
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 11:26:21 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so4032496eds.14
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 08:26:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=NdT2k+C1dhI8osaYVLZdWInK/X/4O2LTE+zviSGHxcI=;
        b=mOU+Y7AaqDEXDhcXLbQs+3TpAYt1zVmAPOIHn7R2tOdQh+HFwegQdTOJVa/AkKefS0
         ymZyUIv/webdOVM+qTGat1oKx/hnUaaxglUZhIdI1w6moG63rO3Y0BncGpmDXIf2LMbN
         5SDdxLsqECOArZJA3ga4KzmuMFXnx67imTSx4GFXJlei6DhOqoBvzLqqM4h4zBXixM4A
         6bbgveydivvuHLWhJo7sIKEg/a0ov2s4HRk/uPg44d+lq4B/g2AIpMprXnzGv8eSUvZS
         G5x6QUQ+kQoLkYHSQrcE/QBcNU4yQ+yq8kV48A+EumzC+2Hv6YHerbAv18pzGTymGm0z
         VFlQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVt5K6d5/KrXXeGlfM6slwxrPAlqrUIR4wfafRjYkiNnqmsTNsi
	kgh3jDJJy9UdbIYgfwHzcfsWLbrvT+cw5OX4v8Lio+k5Uhr4bVxXaWTtcUBP46G3PWUtJTDIOOD
	70tn51Jw7GHYYX9J3vB6jMM5PZ0DoFcsUMso/KPMMj116pDAhDjjR/5t5PwK5eOC7Jg==
X-Received: by 2002:aa7:c14f:: with SMTP id r15mr49640828edp.116.1562253980771;
        Thu, 04 Jul 2019 08:26:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyf894OCknnZzdyLbBXi754x23pR29mFsqtipuGC3fATWpc7i9GJZSi96pNHEbv6Bb+T0/l
X-Received: by 2002:aa7:c14f:: with SMTP id r15mr49640748edp.116.1562253979675;
        Thu, 04 Jul 2019 08:26:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562253979; cv=none;
        d=google.com; s=arc-20160816;
        b=X3l6J2c0GOkawY+wJhEDXjmPl3+BVFnF6OixLaDPhEFsDlYKkOVuz7da9ApPgQgHgZ
         QTZfifjdiNResclBBUbTpFueY8Ya/h7XnAAgXEpLfpCbI5CUdgTrzq9Cg//t/6beCUcU
         8dOXqEOlD/ONKU7e0SigMcZLJtD0FrUk9qaThnCPVoQeSr9bNPnQ/HzJrkuUG+aR0xKw
         ELaBc+zdsVJT3NZZ5/rnD1W07mtij80ITwO2PSjmj+PXB230LSSIinhxSj9q0NI3ajdw
         6EBcvSpAqSz7+iyE+IRPiuOmgL05GMsiUF29AEanKZ2FMkHt+klYw5MZD/M7JERqMUqd
         uaLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=NdT2k+C1dhI8osaYVLZdWInK/X/4O2LTE+zviSGHxcI=;
        b=ISJm+QKPxdLbTG7qVgnwKQeXaFwVFq9/1IcUJ6WYveFT1rlmhgwIeM40GTVJzoSBoc
         1W0VhkTGql1M6iFWqd5Ovp1hKTp/0pcp2ve286TL5Mxmsa47FJHO+pABwHCt/sRMU8Es
         MRIJ8nrx3NpIVFPE6WyywVnOUVD9013WFAdX+58l+ZZj1jeQNKu5LRy6tzuKm81hfk+z
         bZgHb6B04RzOb/INgdDdIMfKLXWuA1pgYuX1nhhI5JoozVwYDqQjteYRdazezmoZCN7a
         G27uXr5+50avLTA9k3rOSMRQaepdTgPCZWhIvsYQZg+r2ztzEDHumbG2ivK7szu1rHX5
         wpxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id qh16si729581ejb.181.2019.07.04.08.26.18
        for <linux-mm@kvack.org>;
        Thu, 04 Jul 2019 08:26:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8316F2B;
	Thu,  4 Jul 2019 08:26:17 -0700 (PDT)
Received: from [10.162.40.119] (p8cg001049571a15.blr.arm.com [10.162.40.119])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3B3A43F703;
	Thu,  4 Jul 2019 08:26:13 -0700 (PDT)
Subject: Re: [PATCH V2] mm/ioremap: Probe platform for p4d huge map support
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will.deacon@arm.com>, Dave Hansen
 <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>,
 Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>,
 Ingo Molnar <mingo@redhat.com>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
 Michal Hocko <mhocko@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>,
 Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org,
 linux-arm-kernel@lists.infradead.org, x86@kernel.org
References: <1561699231-20991-1-git-send-email-anshuman.khandual@arm.com>
 <20190702160630.25de5558e9fe2d7d845f3472@linux-foundation.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <fbc147c7-bec2-daed-b828-c4ae170010a9@arm.com>
Date: Thu, 4 Jul 2019 20:56:40 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190702160630.25de5558e9fe2d7d845f3472@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/03/2019 04:36 AM, Andrew Morton wrote:
> On Fri, 28 Jun 2019 10:50:31 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> 
>> Finishing up what the commit c2febafc67734a ("mm: convert generic code to
>> 5-level paging") started out while levelling up P4D huge mapping support
>> at par with PUD and PMD. A new arch call back arch_ioremap_p4d_supported()
>> is being added which just maintains status quo (P4D huge map not supported)
>> on x86, arm64 and powerpc.
> 
> Does this have any runtime effects?  If so, what are they and why?  If
> not, what's the actual point?

It just finishes up what the previous commit c2febafc67734a ("mm: convert
generic code to 5-level paging") left off with respect p4d based huge page
enablement for ioremap. When HAVE_ARCH_HUGE_VMAP is enabled its just a simple
check from the arch about the support, hence runtime effects are minimal.

