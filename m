Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 87C2EC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:58:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22C2722ADC
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:58:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22C2722ADC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DE608E0003; Wed, 24 Jul 2019 02:58:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 78C1F8E0002; Wed, 24 Jul 2019 02:58:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A2728E0003; Wed, 24 Jul 2019 02:58:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 18CF98E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:58:21 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l26so29642562eda.2
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:58:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=GXUUAzfNOjInrRS86V00ZJRaEW/TKhn6l/fffaoeBvo=;
        b=puM19/l2N+IMLsnsf8kQQJagJ0rrxh71rYd/x678uvkQ8BQ7GtUJtzzG0RTRO7rA1a
         bTZ1UQuj83nLIetejyRyi/FL7aOWw+Bx75S3rcWivhxB+jzLPxW73rsM3l0D7n4yHsF/
         OInoHd2y9YAhc0/7HgHFgzVrnRbKmhJO74J06gw41Nvoq6FJMd9MkpINamLCS0Ly3el3
         PQTpAG990UAiZ59H4CH5g4LEJ1mYLYHtknwq+l17sybxIkX7ye/m3GF6rq05zKcqYElz
         E8HrQvCnJCB5hCF7olVB3DdH8P5dRGaVJjOnAYY8C+GBN1mAhUYEHSbNfoJF1y1tL9sH
         kgHg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVU88AZTDmeO4Bx9PQ99wzo8CGMUSBAWsoPRFf6MgW/Ar9bhu3C
	ZCMGMVlDUh52TG7AbtVU3eYgjSw/I7Eaq1yM/QQvMSdWTvtLIco95Z1abDGZ9YqB6R044rtB9AP
	8+46XDIZ040UnPKeu1wyw3n2DsHUK2rMuEr+aBWLkeSnh4Ji5YqBLjxgIcBcnKZRZ8A==
X-Received: by 2002:a50:94a2:: with SMTP id s31mr70445551eda.290.1563951500623;
        Tue, 23 Jul 2019 23:58:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzb7YfKUF9rXBNKvMrVj1Y/ypAdMBgaGHVFroaM7VJmi4aUQ2MoQQbX+DV3cRqhyisJmxtj
X-Received: by 2002:a50:94a2:: with SMTP id s31mr70445496eda.290.1563951499475;
        Tue, 23 Jul 2019 23:58:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563951499; cv=none;
        d=google.com; s=arc-20160816;
        b=nyhtWYnzeMTsPzIop9XcgZYTqFZ85LFigewc4W/WfeStyZiGPNb/+jDH+OKlZIrhNJ
         xnwUwQvMVmrYtL2QOK0rwoArsmRLnNzreQsllbtQ/XgHpgx9vp+Gb7bQyJB8YIYhceLH
         vd6lMunfKfsQ00SZ0eUNvpZ4noxuotMxyrLlEZjljGhsS31rkqRntZTVvRzEP+JSKwyR
         Wbunmb+E3y8UlLM5yl1ublfCWo8vBkEXSw9IqoOScGNKa1ByfRQM7mxC4wPGoYsF4jFS
         VngIg5xl8xK1gH0NMaBU3EUS5RZuwrbZy2bdhtOTN3a4MszGuxzhPpWoWSPKK2ZRrVhK
         +n8w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=GXUUAzfNOjInrRS86V00ZJRaEW/TKhn6l/fffaoeBvo=;
        b=ACjAkNo5CAxauc0hu3kyJqwCP43SeUhdnXm2E5pcKfXvCt9F8ogmY3etxFuRbSccy7
         9inKDMxjRP3kZcFjq6diuVhXZITO5ojSB3N2EPZGWzjkUtWAREKib8GOUvlBXJehCsNq
         78f7b1msftWI8cGVuosnyNWPZqZHckNafYGNNGKgw1Pvp2K+iXRuEG1kg6A7Qd87aGLA
         oEU08UqrtphHMC8IlOcbWPKgcLnNkibCVMGTDizF7MhADbBAyiZNG+G7SAnkmE1FRdgG
         faIOZEkgxkLrodq20TGeb15iAFDfWaeIVoyWgVf6mSdIqWF+hYe5OSIwaWBCzzAGFSSR
         mXSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id x32si7991842edx.397.2019.07.23.23.58.19
        for <linux-mm@kvack.org>;
        Tue, 23 Jul 2019 23:58:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4C16728;
	Tue, 23 Jul 2019 23:58:18 -0700 (PDT)
Received: from [10.163.1.197] (unknown [10.163.1.197])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7A4743F694;
	Wed, 24 Jul 2019 00:00:16 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH V6 RESEND 0/3] arm64/mm: Enable memory hot remove
To: Mark Rutland <mark.rutland@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
 catalin.marinas@arm.com, will.deacon@arm.com, mhocko@suse.com,
 ira.weiny@intel.com, david@redhat.com, cai@lca.pw, logang@deltatee.com,
 james.morse@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, mgorman@techsingularity.net, osalvador@suse.de,
 ard.biesheuvel@arm.com, steve.capper@arm.com
References: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
 <20190723105636.GA5004@lakrids.cambridge.arm.com>
Message-ID: <a69ed426-98ff-32ed-82ce-8216dd56daba@arm.com>
Date: Wed, 24 Jul 2019 12:28:50 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190723105636.GA5004@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 07/23/2019 04:26 PM, Mark Rutland wrote:
> Hi Anshuman,

Hello Mark,

> 
> On Mon, Jul 15, 2019 at 11:47:47AM +0530, Anshuman Khandual wrote:
>> This series enables memory hot remove on arm64 after fixing a memblock
>> removal ordering problem in generic try_remove_memory() and a possible
>> arm64 platform specific kernel page table race condition. This series
>> is based on linux-next (next-20190712).
>>
>> Concurrent vmalloc() and hot-remove conflict:
>>
>> As pointed out earlier on the v5 thread [2] there can be potential conflict
>> between concurrent vmalloc() and memory hot-remove operation. This can be
>> solved or at least avoided with some possible methods. The problem here is
>> caused by inadequate locking in vmalloc() which protects installation of a
>> page table page but not the walk or the leaf entry modification.
>>
>> Option 1: Making locking in vmalloc() adequate
>>
>> Current locking scheme protects installation of page table pages but not the
>> page table walk or leaf entry creation which can conflict with hot-remove.
>> This scheme is sufficient for now as vmalloc() works on mutually exclusive
>> ranges which can proceed concurrently only if their shared page table pages
>> can be created while inside the lock. It achieves performance improvement
>> which will be compromised if entire vmalloc() operation (even if with some
>> optimization) has to be completed under a lock.
>>
>> Option 2: Making sure hot-remove does not happen during vmalloc()
>>
>> Take mem_hotplug_lock in read mode through [get|put]_online_mems() constructs
>> for the entire duration of vmalloc(). It protects from concurrent memory hot
>> remove operation and does not add any significant overhead to other concurrent
>> vmalloc() threads. It solves the problem in right way unless we do not want to
>> extend the usage of mem_hotplug_lock in generic MM.
>>
>> Option 3: Memory hot-remove does not free (conflicting) page table pages
>>
>> Don't not free page table pages (if any) for vmemmap mappings after unmapping
>> it's virtual range. The only downside here is that some page table pages might
>> remain empty and unused until next memory hot-add operation of the same memory
>> range.
>>
>> Option 4: Dont let vmalloc and vmemmap share intermediate page table pages
>>
>> The conflict does not arise if vmalloc and vmemap range do not share kernel
>> page table pages to start with. If such placement can be ensured in platform
>> kernel virtual address layout, this problem can be successfully avoided.
>>
>> There are two generic solutions (Option 1 and 2) and two platform specific
>> solutions (Options 2 and 3). This series has decided to go with (Option 3)

s/Option 2 and 3/Option 3 and 4/

>> which requires minimum changes while self-contained inside the functionality.
> 
> ... while also leaking memory, right?

This is not a memory leak. In the worst case where an empty page table page could
have been freed after parts of it's kernel virtual range span's vmemmap mapping has
been taken down still remains attached to the higher level page table entry. This
empty page table page will be completely reusable during future vmalloc() allocations
or vmemmap mapping for newly hot added memory in overlapping memory range. It is just
an empty data structure sticking around which could (probably would) be reused later.
This problem will not scale and get worse because its part of kernel page table not
user process which could get multiplied. Its a small price we are paying to remain
safe from a vmalloc() and memory hot remove potential collisions on the kernel page
table. IMHO that is fair enough.

> 
> In my view, option 2 or 4 would have been preferable. Were there

I would say option 2 is the ideal solution where we make sure that each vmalloc()
instance is protected against concurrent memory hot remove through a read side lock
via [get|put]_online_mems().

Option 4 is very much platform specific and each platform has to make sure that they
remain compliant all the time which is not ideal. Its is also an a work around which
avoids the problem and does not really fix it.

> specific technical reasons to not go down either of those routes? I'm

Option 2 will require wider agreement as it involves a very critical hot-path vmalloc()
which can affect many workloads. IMHO Option 4 is neither optimal and not does it solve
the problem correctly. Like this approach it just avoids it but unlike this touches upon
another code area.

> not sure that minimizing changes is the right rout given that this same
> problem presumably applies to other architectures, which will need to be
> fixed.

Yes this needs to be fixed but we can get there one step at a time. vmemmap tear
down process can start freeing empty page table pages when this gets solved. But
why should it prevent entire memory hot remove functionality from being available.

> 
> Do we know why we aren't seeing issues on other architectures? e.g. is
> the issue possible but rare (and hence not reported), or masked by
> something else (e.g. the layout of the kernel VA space)?

I would believe so but we can only get more insights from respective architecture folks.

> 
> I'd like to solve the underyling issue before we start adding new
> functionality.

The entire memory hot-remove functionality from the platform perspective has four
primary functions.

1. Tear down linear mapping
2. Tear down vmemmap mapping
3. Free empty kernel page table pages after tearing down linear mapping
4. Free empty kernel page table pages after tearing down vmemmap mapping

This particular issue mentioned before prevents just the last function (4) which
in the worst case will retain some empty page tables pages erstwhile holding vmemmap
mapping in the kernel page table but otherwise provides complete memory hot remove
functionality.

Why should all these remaining memory hot-remove functions be prevented from being
available for use ? The remaining set of functions (1-3) do not create any side affects
or introduce any new bugs. Also function (4) is not tightly coupled with rest of the
functions (1-3) and anyways will be unlocked independently when the particular issue
gets resolved. The point I am trying to make here is they are not tightly coupled
and perceiving them that way blocks remaining memory hot-remove functionality from
being available.

> 
>> Testing:
>>
>> Memory hot remove has been tested on arm64 for 4K, 16K, 64K page config
>> options with all possible CONFIG_ARM64_VA_BITS and CONFIG_PGTABLE_LEVELS
>> combinations. Its only build tested on non-arm64 platforms.
> 
> Could you please share how you've tested this?
> 
> Having instructions so that I could reproduce this locally would be very
> helpful.

Please find the series rebased on v5.3-rc1 along with test patches which
enable sysfs interfaces for memory hot add and remove used for testing.

git://linux-arm.org/linux-anshuman.git (memory_hotremove/v6_resend_v5.3-rc1)

Sample Testing Procedure:

echo offline > /sys/devices/system/memory/auto_online_blocks
echo 0x680000000 > /sys/devices/system/memory/probe
echo online_movable > /sys/devices/system/memory/memory26/state
echo 0x680000000 > /sys/devices/system/memory/unprobe

Writing into unprobe trigger offlining first followed by actual memory removal.

NOTE:

This assumes that 0x680000000 is valid memory block starting physical address
and memory26 gets created because of the preceding memory hot addition. Please
use appropriate values based on your local setup. Let me know how it goes and
if I could provide more information.

- Anshuman

