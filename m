Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 38B72C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 08:19:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8E5C208E4
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 08:19:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8E5C208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 928016B000A; Wed, 24 Apr 2019 04:19:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8AFEB6B000C; Wed, 24 Apr 2019 04:19:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 778A76B000D; Wed, 24 Apr 2019 04:19:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 28A0A6B000A
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 04:19:30 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z29so9439061edb.4
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 01:19:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yO1YpmCXvtJDiKJt7wFoWbRv6fdQiOWqFqEv1CfPGk8=;
        b=SniKShS7tIQ0LSO+HyAaTU77qsZ3DaOzvuwjgeC6iWPOX2OjQDmMDQsag/W/PUgMjH
         uFyflrWUsHwePs95j7mevhQO32IHM9w9NY9FTXZg2Fr8mABRekV87pPjJi/ZKVlCRXtR
         XnnXlcqVslmS70bVCPAwsidqAiDbMV3H7lITaw1NcPscEWXwuKsVNwdDzJE0REoMEI38
         7NiH4heGIgsmU3mukgy+aechBWQXky4y+oLzZRp9KeF6HDRPl9nZf7iTyxFxJGJL/ipU
         /WaP62YSGpl2ZmqmSSHlKfvVIQWVEabwAhbvu7kRAJ5V8vCDnkh/RP1gXwrP8AqsnHFm
         AWUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: APjAAAVyn0yo0rqEGkrFTL0urgyBAAiOrGad/99f1OyGWzh5AzxFDfHy
	SMuO3TTshT0nQIFRfjimpDZhnt3ZseX2XoS0WT/9F6mzGF3uUs4yg2ZKD31Pt7AavEZxMeWNGds
	yj7+JTnaYmKEfeOEzgUOJv9jAHziNi3Eqx8N7yo+4lgQfqkO+Za/+/B5pG51b7DCW7w==
X-Received: by 2002:a50:f484:: with SMTP id s4mr1823774edm.253.1556093969700;
        Wed, 24 Apr 2019 01:19:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqweUzLDF5z4rHCLilN7veJUQhnWrgPErFN89O2SrHDtL9aDI2laI7PT0tWOtNECznEnIh72
X-Received: by 2002:a50:f484:: with SMTP id s4mr1823724edm.253.1556093968587;
        Wed, 24 Apr 2019 01:19:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556093968; cv=none;
        d=google.com; s=arc-20160816;
        b=cKJE2siDqOFl82HEtEdHCLyHT9j0hJZZ+d3B6tNtnp7inMtClw7zleRyM9xqy30FN3
         d7QVnVXyvowkRpQyctMG0r1m2eA7rdjM7y92+VH/DT/wQ1HuoEJqo6t/Dx0uVcUXX8Xh
         Md8F38HhH2BLuIdZS+80vC5U1j3sjzG20+sSscZ5uUeuO7bsIyLKfoIfZbb2YVKRkshd
         mkEhDVBLTCLxClUKL6gMd4HkVnm7eF3/meJpj8UyYAJzlq/xE9XA1UU1DWSlM9/WsOjN
         OldvbGgv5LqNcHZN4sL6OB1gulBrTUVkNblyAcxUWOHF+Y/1c9zq8Qm1AEVOWE/QHXTR
         N4CQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=yO1YpmCXvtJDiKJt7wFoWbRv6fdQiOWqFqEv1CfPGk8=;
        b=Ub+M1vNJqfbgvm0hDJ/3dwkR54yXNOD8jVXTkRjxZqHt7+7l1eHoulW+XY7UoAQPlJ
         9dkyxGB8x3KeJScMftuq9gt9wCenYaO/DnkpOdCH0+0bKOjkukynJlHtwfRuGW2SAwQK
         sC/PG0YHmxTuKXa6CAL2aP740pncpTO4HDEP9PZgT3kxP1poYwXmVnmUfRAZOE52owpA
         nZRz8u1fFI/3E3agFZ5hmUIRtU7Vpa+4DJQuYgfxXlG7s0791bSHvMoSzlSGWCiUo+Pg
         JDZVdqUckkuM0ksJbO/C+/Se+G9SmnshHGCA1WKXKUJwDhSelRCUDY+gQPR/56iqR5kc
         7aoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y47si3736453edd.441.2019.04.24.01.19.28
        for <linux-mm@kvack.org>;
        Wed, 24 Apr 2019 01:19:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4C46380D;
	Wed, 24 Apr 2019 01:19:27 -0700 (PDT)
Received: from blommer (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 3FDCE3F5AF;
	Wed, 24 Apr 2019 01:19:23 -0700 (PDT)
Date: Wed, 24 Apr 2019 09:19:20 +0100
From: Mark Rutland <mark.rutland@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	robin.murphy@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, osalvador@suse.de, david@redhat.com,
	cai@lca.pw, logang@deltatee.com, ira.weiny@intel.com
Subject: Re: [PATCH V2 2/2] arm64/mm: Enable memory hot remove
Message-ID: <20190424081837.ldpe74i7uspupxdv@blommer>
References: <1555221553-18845-3-git-send-email-anshuman.khandual@arm.com>
 <20190415134841.GC13990@lakrids.cambridge.arm.com>
 <2faba38b-ab79-2dda-1b3c-ada5054d91fa@arm.com>
 <20190417142154.GA393@lakrids.cambridge.arm.com>
 <bba0b71c-2d04-d589-e2bf-5de37806548f@arm.com>
 <20190417173948.GB15589@lakrids.cambridge.arm.com>
 <1bdae67b-fcd6-7868-8a92-c8a306c04ec6@arm.com>
 <97413c39-a4a9-ea1b-7093-eb18f950aad7@arm.com>
 <20190423160525.GD56999@lakrids.cambridge.arm.com>
 <ebb9aba0-5ca3-41ed-4183-9d72a354f529@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ebb9aba0-5ca3-41ed-4183-9d72a354f529@arm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 11:29:28AM +0530, Anshuman Khandual wrote:
> On 04/23/2019 09:35 PM, Mark Rutland wrote:
> > On Tue, Apr 23, 2019 at 01:01:58PM +0530, Anshuman Khandual wrote:
> >> Generic usage for init_mm.pagetable_lock
> >>
> >> Unless I have missed something else these are the generic init_mm kernel page table
> >> modifiers at runtime (at least which uses init_mm.page_table_lock)
> >>
> >> 	1. ioremap_page_range()		/* Mapped I/O memory area */
> >> 	2. apply_to_page_range()	/* Change existing kernel linear map */
> >> 	3. vmap_page_range()		/* Vmalloc area */
> > 
> > Internally, those all use the __p??_alloc() functions to handle racy
> > additions by transiently taking the PTL when installing a new table, but
> > otherwise walk kernel tables _without_ the PTL held. Note that none of
> > these ever free an intermediate level of table.
> 
> Right they dont free intermediate level page table but I was curious about the
> only the leaf level modifications.

Sure thing; I just wanted to point that out explicitly for everyone else's
benefit. :)

> > I believe that the idea is that operations on separate VMAs should never
> 
> I guess you meant kernel virtual range with 'VMA' but not the actual VMA which is
> vm_area_struct applicable only for the user space not the kernel.

Sure. In the kernel we'd reserve a kernel VA range with a vm_struct via
get_vm_area() or similar.

The key point is that we reserve page-granular VA ranges which cannot overlap
at the leaf level (but may share intermediate levels of table). Whoever owns
that area is in charge of necessary mutual exclusion for the leaf entries.

> > conflict at the leaf level, and operations on the same VMA should be
> > serialised somehow w.r.t. that VMA.
> 
> AFAICT see there is nothing other than hotplug lock i.e mem_hotplug_lock which
> prevents concurrent init_mm modifications and the current situation is only safe
> because some how these VA areas dont overlap with respect to intermediate page
> table level spans.

Here I was ignoring hotplug to describe the general principle (which I've
expanded upon above).

> > AFAICT, these functions are _never_ called on the linear/direct map or
> > vmemmap VA ranges, and whether or not these can conflict with hot-remove
> > is entirely dependent on whether those ranges can share a level of table
> > with the vmalloc region.
> 
> Right but all these VA ranges (linear, vmemmap, vmalloc) are wired in on init_mm
> hence wondering if it is prudent to assume layout scheme which varies a lot based
> on different architectures while deciding possible race protections.

One thing to consider is that we could turn this implicit assumption into a
requirement, if this isn't too invasive.

> Wondering why these user should not call [get|put]_online_mems() to prevent
> race with hotplug.

I suspect that this is because they were written before memory hotplug was
added, and they were never reconsidered in the presence of hot-remove.

> Will try this out.
> 
> Unless generic MM expects these VA ranges (linear, vmemmap, vmalloc) layout to be
> in certain manner from the platform guaranteeing non-overlap at intermediate level
> page table spans. Only then we would not a lock.

I think that we might be able to make this a requirement for hot-remove. I
suspect this happens to be the case in practice by chance, even if it isn't
strictly guaranteed.

> > Do you know how likely that is to occur? e.g. what proportion of the
> 
> TBH I dont know.
> 
> > vmalloc region may share a level of table with the linear or vmemmap
> > regions in a typical arm64 or x86 configuration? Can we deliberately
> > provoke this failure case?
> 
> I have not enumerated those yet but there are multiple configs on arm64 and
> probably on x86 which decides kernel VA space layout causing these potential
> races. But regardless its not right to assume on vmalloc range span and not
> take a lock.
> 
> Not sure how to provoke this failure case from user space with simple hotplug
> because vmalloc physical allocation normally cannot be controlled without a
> hacked kernel change.

I believe that we can write a module which:

 - Looks at the various memory ranges, and determines whether they may share an
   intermediate level of table.
 - reserves a potentially-conflicting region with __get_vm_area_node()
 - in a loop, maps/unmaps something in that range

... while in parallel, adding/removing a potentially-conflicting region of
memory.

So long as we have the same sort of serialization we'd have for a regular
vmalloc(), ioremap() of vmap(), that would be sufficient to demonstrate that
this is a real problem.

[...]

> > Is it possible to avoid these specific conflicts (ignoring ptdump) by
> > aligning VA regions such that they cannot share intermediate levels of
> > table?
> 
> Kernel VA space layout is platform specific where core MM does not mandate much. 
> Hence generic modifiers should not make any assumptions regarding it but protect
> themselves with locks. Doing any thing other than that is just pushing the problem
> to future.

My point is that we can make this a _requirement_ of the core code, which we
could document and enforce.

Thanks,
Mark.

