Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2222C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:46:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A9DDC2054F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 08:46:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A9DDC2054F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 264A18E0002; Fri, 15 Feb 2019 03:46:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 213888E0001; Fri, 15 Feb 2019 03:46:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1036D8E0002; Fri, 15 Feb 2019 03:46:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC5048E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 03:46:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id 39so3673448edq.13
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 00:46:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:subject
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-language:content-transfer-encoding;
        bh=2UV+8OcJUghGaV9Huy40qDoVntpGzLgTIK+t/JVUVac=;
        b=dnxHr+IkrQym8WDVd/OdB5wkgwEPg55mwfC3WSdvJD3dRMQD4lfFoE2tfH7xS2nVII
         fqQrsIj5mOeCLG/2opf7aQK/R12lmQ0f8IWKTq7WYrpxFPDsQbX57PqhzKGXs24ngC2p
         tXtq9SYUV/FChpJ4lgq4o7HjeqBmrlXulDqHPNfDAhp5a+V9y6onTBmD7isKpVF8f0qk
         bCFlTKVkXM5Eqxcm7IttyM9aszfctRgq5J5kapOn7L2FXZFLbFHJpPKVy5xmVwpZ75ec
         m/79lyC2H2rhSys7TjabiMaWrsiJHYSXjtgWUy2cucyfKhxHrHsCcRT2u8hXn7wU63K4
         wM8w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: AHQUAuZt7kHFEK7ktvNdnQ8goXEaWbuTOpVMt6XXVREbYkW96croZhtV
	ivxzuzrlGO9tcbEozxNdEd09Wgo8tjlnY7nbJn+z4rlsXy/0HnutXMP2YuG1Cp1jvNOkcviyWA4
	GwgrmIdpnhuz8MIPxqlLS1I6NN++b779pAxnTUBWqsSG+BhpkzsfHGuxFX/gl3lEfDg==
X-Received: by 2002:a17:906:3b8e:: with SMTP id u14mr5895773ejf.130.1550220362093;
        Fri, 15 Feb 2019 00:46:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia+UHNg8j3jWCSnl5K0K6bKW2A1F9jygd2Igflohzi97VRGbpQB7A0ScQ3GX7CwauB1Uj0k
X-Received: by 2002:a17:906:3b8e:: with SMTP id u14mr5895726ejf.130.1550220360989;
        Fri, 15 Feb 2019 00:46:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550220360; cv=none;
        d=google.com; s=arc-20160816;
        b=xlYHWwK4aOMQ7ovJk6ClmaSVs0kReRGl71++wmREKsVjauK/dUlNAl1YmsYkGDpRHP
         O8n43lm0iZONikTxNVv2K99G88QmRvOvIReFblfrV/XQHGB5UW8s9pVhL8FjeffuPWat
         O3PuLOUXs6PIS3tXMerOTp4HwroKJVcavNHp5yguSYZzC7PY7mB/Pd88eggBm9qdz9Th
         /GCy/RVbdoG5EBYxbseO1YMRAQIMInldMi8i4pKO3ObfUkQ4Ww1jIx9a/uBmgI4mmtkD
         BXJnJiZeAb8c26fqDqJL/3z/tID+0TvlEXYwhwTAx+kq9Ep0VmS+tildBHc7xhORcUHi
         lAmw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:subject:from;
        bh=2UV+8OcJUghGaV9Huy40qDoVntpGzLgTIK+t/JVUVac=;
        b=JmfVQ8cjB11uE+PQIMlUtij3VHMs0peYkq1/3Ezje2MJnDBOtMomI/WIbta1NN2mqN
         zUDXmYom8dx7vdRUBrRWtJMybpPSdBTGU2CfxHcCMLFrHyNI28G9pas8OjoDPuZ7yzEU
         jf1x3znvV2RWS8HPSELfgeNh3Ynx3SFpdh+xgWFHK/Zc8+oik4WE7k2FW6guumTvVWRN
         9Y0Iv4E2Z6xc1FVP/hf5/AMDERkIhfhPFHnicpaGoWx6aqwDcgERd1fKho2Uib5IFe6P
         7T2PuLuQPLDH8YcaHa+SjogVEWYJXl+9bQFHei6SxD6DMs9beD/3CPUOdoqrSwSwCTT9
         /FHA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b53si82716edd.297.2019.02.15.00.46.00
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 00:46:00 -0800 (PST)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A8181A78;
	Fri, 15 Feb 2019 00:45:59 -0800 (PST)
Received: from [10.162.43.140] (p8cg001049571a15.blr.arm.com [10.162.43.140])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 158BD3F557;
	Fri, 15 Feb 2019 00:45:56 -0800 (PST)
From: Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [RFC 0/4] mm: Introduce lazy exec permission setting on a page
To: Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill@shutemov.name,
 kirill.shutemov@linux.intel.com, vbabka@suse.cz, will.deacon@arm.com,
 dave.hansen@intel.com
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <20190213112135.GA9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190213153819.GS4525@dhcp22.suse.cz>
 <0b6457d0-eed1-54e4-789b-d62881bea013@arm.com>
 <20190214083844.GZ4525@dhcp22.suse.cz>
 <20190214101936.GD9296@c02tf0j2hf1t.cambridge.arm.com>
 <20190214122816.GD4525@dhcp22.suse.cz>
Message-ID: <d2646840-f2f0-3618-889a-54cfef6cb455@arm.com>
Date: Fri, 15 Feb 2019 14:15:58 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190214122816.GD4525@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

a

On 02/14/2019 05:58 PM, Michal Hocko wrote:
> On Thu 14-02-19 10:19:37, Catalin Marinas wrote:
>> On Thu, Feb 14, 2019 at 09:38:44AM +0100, Michal Hocko wrote:
>>> On Thu 14-02-19 11:34:09, Anshuman Khandual wrote:
>>>> On 02/13/2019 09:08 PM, Michal Hocko wrote:
>>>>> Are there any numbers to show the optimization impact?
>>>>
>>>> This series transfers execution cost linearly with nr_pages from migration path
>>>> to subsequent exec access path for normal, THP and HugeTLB pages. The experiment
>>>> is on mainline kernel (1f947a7a011fcceb14cb912f548) along with some patches for
>>>> HugeTLB and THP migration enablement on arm64 platform.
>>>
>>> Please make sure that these numbers are in the changelog. I am also
>>> missing an explanation why this is an overal win. Why should we pay
>>> on the later access rather than the migration which is arguably a slower
>>> path. What is the usecase that benefits from the cost shift?
>>
>> Originally the investigation started because of a regression we had
>> sending IPIs on each set_pte_at(PROT_EXEC). This has been fixed
>> separately, so the original value of this patchset has been diminished.
>>
>> Trying to frame the problem, let's analyse the overall cost of migration
>> + execute. Removing other invariants like cost of the initial mapping of
>> the pages or the mapping of new pages after migration, we have:
>>
>> M - number of mapped executable pages just before migration
>> N - number of previously mapped pages that will be executed after
>>     migration (N <= M)
>> D - cost of migrating page data
>> I - cost of I-cache maintenance for a page
>> F - cost of an instruction fault (handle_mm_fault() + set_pte_at()
>>     without the actual I-cache maintenance)
>>
>> Tc - total migration cost current kernel (including executing)
>> Tp - total migration cost patched kernel (including executing)
>>
>>   Tc = M * (D + I)
>>   Tp = M * D + N * (F + I)
>>
>> To be useful, we want this patchset to lead to:
>>
>>   Tp < Tc
>>
>> Simplifying:
>>
>>   M * D + N * (F + I) < M * (D + I)
>>   ...
>>   F < I * (M - N) / N
>>
>> So the question is, in a *real-world* scenario, what proportion of the
>> mapped executable pages would still be executed from after migration.
>> I'd leave this as a task for Anshuman to investigate and come up with
>> some numbers (and it's fine if it's just in the noise, we won't need
>> this patchset).
> 
> Yeah, betting on accessing only a smaller subset of the migrated memory
> is something I figured out. But I am really missing a usecase or a
> larger set of them to actually benefit from it. We have different
> triggers for a migration. E.g. numa balancing. I would expect that
> migrated pages are likely to be accessed after migration because
> the primary reason to migrate them is that they are accessed from a
> remote node. Then we a compaction which is a completely different story.

That access might not have been an exec fault it could have been bunch of
write faults which triggered NUMA migration. So NUMA triggered migration
does not necessarily mean continuing exec faults before and after migration.

Compaction might move around mapped pages with exec permission which might
not have any recent history of exec accesses before compaction or might not
even see any future exec access as well.

> It is hard to assume any further access for migrated pages here. Then we
> have an explicit move_pages syscall and I would expect this to be
> somewhere in the middle. One would expect that the caller knows why the
> memory is migrated and it will be used but again, we cannot really
> assume anything.

What if the caller knows that it wont be used ever again or in near future
and hence trying to migrate to a different node which has less expensive and
slower memory. Kernel should not assume either way on it but can decide to
be conservative in spending time in preparing for future exec faults.

But being conservative during migration risks additional exec faults which
would have been avoided if exec permission should have stayed on followed
by an I-cache invalidation. Deferral of the I-cache invalidation requires
removing the exec permission completely (unless there is some magic which
I am not aware about) i.e unmapping page for exec permission and risking
an exec fault next time around.

This problem gets particularly amplified for mixed permission (WRITE | EXEC)
user space mappings where things like NUMA migration, compaction etc probably
gets triggered by write faults and additional exec permission there never
really gets used.

> 
> This would suggest that this depends on the migration reason quite a
> lot. So I would really like to see a more comprehensive analysis of
> different workloads to see whether this is really worth it.

Sure. Could you please give some more details on how to go about this and
what specifically you are looking for ? User initiated migration through
systems calls seems bit tricky as an application can be written primarily
to benefit from this series. If real world applications can help give
some better insights then which ones I wonder. Or do we need to understand
more about compaction and NUMA triggered migration which are kernel
driven. Statistics from compaction/NUMA migration can reveal what ratio
of the exec enabled mapping gets exec faulted again later on after kernel
driven migrations (compaction/NUMA) which are more or less random without
depending too much on application behavior.

- Anshuman

