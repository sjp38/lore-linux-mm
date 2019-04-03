Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E141C10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:58:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36DAF2084B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 13:58:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36DAF2084B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B25456B0008; Wed,  3 Apr 2019 09:58:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD5596B000A; Wed,  3 Apr 2019 09:58:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C51A6B000C; Wed,  3 Apr 2019 09:58:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4BACA6B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 09:58:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id 41so7646789edr.19
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 06:58:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=iDVeJpT4SS7IHOD2yZSD6b9L9MRZUMY7CmEZHItM3Fk=;
        b=QJ2d6YqTn2u6ZptaFWsQzNrc6rhWcOUZGOz6qrJ429LhlKJUY2kQU+/8SFPwiWXrjK
         uut2uy1DXDI2tkmd4XFS2LOqLXtR1wJ8R5klcJZywQ01MMM4ddmtu3hfCZk6d+NoYqu2
         8xi9tN75ShEBBJ0f4U6gRqS4f2h6n0nbnrF1oRbrqABjBrm0fM9lzQ2SxBHaq9DgqKFq
         2SaDdrPSV5cObD2rxPYksT4k0JQ47ouBHiGIrsvP6QmcMwxi7jluJ9yNEGDvony9xBKP
         +rgkxLA8KJCBNEuP2Tk1feAMVperQ+2D/R9U5ASxqJIsgwUGvyRR8RN/KgmwWiQEduep
         vhvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAW2xZ0XpJ269aZJlhXSFBVQw4rhbfTK8r2OARbfIVHJotLsa/C7
	eUrKFiG3i4eOVX1w12iUjHVEClJxMdeVC+NC1F2h/fzZcd5OySbnukqKgOJIxoNoJYquyKfVjvS
	hx1Es1+YnrQk74wLhpk5+JbR/tm6jY9HoVyp8lpLJ48Rk4sfKKLlNlaJf+LkdCoAVBg==
X-Received: by 2002:a17:906:4058:: with SMTP id y24mr39885433ejj.20.1554299915834;
        Wed, 03 Apr 2019 06:58:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/wdxCd1n9qbScQ7VJeuN/PVj5uRp/jXNX1ONfGjGcVdteN/Iqt7PcP3kxEjb1XvgiDhda
X-Received: by 2002:a17:906:4058:: with SMTP id y24mr39885381ejj.20.1554299914932;
        Wed, 03 Apr 2019 06:58:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554299914; cv=none;
        d=google.com; s=arc-20160816;
        b=NuAAb5NIz+eSitFZpchdeFDYIovHdwZI6slJO1mt57NyEj66zu0cxCRvBB5NPEqckG
         D/mdl18HMQs734Uhb4hGfL6nTiTBLZ+AfE6sDyIQCtuRr2GJQr2PHcbiurKkn0TK8i8P
         AGx4+Lyu+0Noy9GlJ/7eSr/ZrtdwLFh3mzZDdWTsJWB1HWRFlUjiwlMMlefhKZFVKwLK
         v7PRTohPtw/iKaDLBzK4C6/4jnS8lJ1E5M7rB4rvjiaXmUyEaxbZNz3LojaG1y9hi5CS
         QdRwcc2xMD6TQw44vsdo+J/xTVnnyBVOi204sNBZeBucGJwqqDqjdIaRPy+YNz4EfJDE
         fJwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=iDVeJpT4SS7IHOD2yZSD6b9L9MRZUMY7CmEZHItM3Fk=;
        b=Ou0C7QCTyC0gFnV5LLvLpCsITa27FuGvw7FCtzt1+hcknJSARzO6VS++InelSfDd7d
         f0Oy0goaxcxwl4K0GVAAurnLHNkHl52/6txN4aOFayIXr6KvQM9VEgjjygJLnAA5enqD
         5unWJ7e3ot2I7lq1z7D1c4uQfKFu/EWeENCO343AQoSNqIyY6YBPoBejuiTTUB6GJk9a
         mGa0KlhgOJMlKlQzaYg7qvn105CH184Mt2F4DsnzdgOH+vWInx83oQOnA3D3TGrPQART
         b8dMuVy0S3MTq+9pYggPWe+oN55Ydhsl+ndOLPzQPLcI4Eb1Kg+0AzcwZcWYoc3sVlvk
         FS9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v4si685084eji.337.2019.04.03.06.58.34
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 06:58:34 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 76FF6A78;
	Wed,  3 Apr 2019 06:58:33 -0700 (PDT)
Received: from [10.1.196.75] (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 196953F557;
	Wed,  3 Apr 2019 06:58:29 -0700 (PDT)
Subject: Re: [PATCH 6/6] arm64/mm: Enable ZONE_DEVICE
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com,
 david@redhat.com, cai@lca.pw, dan.j.williams@intel.com, jglisse@redhat.com
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <ea5567c7-caad-8a4e-7c6f-cec4b772a526@arm.com>
Date: Wed, 3 Apr 2019 14:58:28 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <1554265806-11501-7-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ +Dan, Jerome ]

On 03/04/2019 05:30, Anshuman Khandual wrote:
> Arch implementation for functions which create or destroy vmemmap mapping
> (vmemmap_populate, vmemmap_free) can comprehend and allocate from inside
> device memory range through driver provided vmem_altmap structure which
> fulfils all requirements to enable ZONE_DEVICE on the platform. Hence just

ZONE_DEVICE is about more than just altmap support, no?

> enable ZONE_DEVICE by subscribing to ARCH_HAS_ZONE_DEVICE. But this is only
> applicable for ARM64_4K_PAGES (ARM64_SWAPPER_USES_SECTION_MAPS) only which
> creates vmemmap section mappings and utilize vmem_altmap structure.

What prevents it from working with other page sizes? One of the foremost 
use-cases for our 52-bit VA/PA support is to enable mapping large 
quantities of persistent memory, so we really do need this for 64K pages 
too. FWIW, it appears not to be an issue for PowerPC.

> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>   arch/arm64/Kconfig | 1 +
>   1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index db3e625..b5d8cf5 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -31,6 +31,7 @@ config ARM64
>   	select ARCH_HAS_SYSCALL_WRAPPER
>   	select ARCH_HAS_TEARDOWN_DMA_OPS if IOMMU_SUPPORT
>   	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
> +	select ARCH_HAS_ZONE_DEVICE if ARM64_4K_PAGES

IIRC certain configurations (HMM?) don't even build if you just turn 
this on alone (although of course things may have changed elsewhere in 
the meantime) - crucially, though, from previous discussions[1] it seems 
fundamentally unsafe, since I don't think we can guarantee that nobody 
will touch the corners of ZONE_DEVICE that also require pte_devmap in 
order not to go subtly wrong. I did get as far as cooking up some 
patches to sort that out [2][3] which I never got round to posting for 
their own sake, so please consider picking those up as part of this series.

Robin.

>   	select ARCH_HAVE_NMI_SAFE_CMPXCHG
>   	select ARCH_INLINE_READ_LOCK if !PREEMPT
>   	select ARCH_INLINE_READ_LOCK_BH if !PREEMPT
> 


[1] 
https://lore.kernel.org/linux-mm/CAA9_cmfA9GS+1M1aSyv1ty5jKY3iho3CERhnRAruWJW3PfmpgA@mail.gmail.com/#t
[2] 
http://linux-arm.org/git?p=linux-rm.git;a=commitdiff;h=61816b833afdb56b49c2e58f5289ae18809e5d67
[3] 
http://linux-arm.org/git?p=linux-rm.git;a=commitdiff;h=a5a16560eb1becf9a1d4cc0d03d6b5e76da4f4e1
(apologies to anyone if the linux-arm.org server is being flaky as usual 
and requires a few tries to respond properly)

