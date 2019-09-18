Return-Path: <SRS0=QF98=XN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 09526C4CEC4
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:20:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB06421925
	for <linux-mm@archiver.kernel.org>; Wed, 18 Sep 2019 14:20:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB06421925
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6AE506B02C2; Wed, 18 Sep 2019 10:20:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 65C666B02C4; Wed, 18 Sep 2019 10:20:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 599626B02C5; Wed, 18 Sep 2019 10:20:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0060.hostedemail.com [216.40.44.60])
	by kanga.kvack.org (Postfix) with ESMTP id 389A86B02C2
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 10:20:49 -0400 (EDT)
Received: from smtpin26.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id BFBE78243772
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:20:48 +0000 (UTC)
X-FDA: 75948252576.26.key07_40f6fcd10d516
X-HE-Tag: key07_40f6fcd10d516
X-Filterd-Recvd-Size: 3931
Received: from foss.arm.com (foss.arm.com [217.140.110.172])
	by imf17.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 14:20:46 +0000 (UTC)
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 01E6D1000;
	Wed, 18 Sep 2019 07:20:45 -0700 (PDT)
Received: from dawn-kernel.cambridge.arm.com (unknown [10.1.197.116])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 6A6B83F67D;
	Wed, 18 Sep 2019 07:20:42 -0700 (PDT)
Subject: Re: [PATCH v4 1/3] arm64: cpufeature: introduce helper
 cpu_has_hw_af()
To: Jia He <justin.he@arm.com>, Catalin Marinas <catalin.marinas@arm.com>,
 Will Deacon <will@kernel.org>, Mark Rutland <mark.rutland@arm.com>,
 James Morse <james.morse@arm.com>, Marc Zyngier <maz@kernel.org>,
 Matthew Wilcox <willy@infradead.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Cc: Punit Agrawal <punitagrawal@gmail.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Jun Yao <yaojun8558363@gmail.com>, Alex Van Brunt <avanbrunt@nvidia.com>,
 Robin Murphy <robin.murphy@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
 hejianet@gmail.com, Kaly Xin <Kaly.Xin@arm.com>
References: <20190918131914.38081-1-justin.he@arm.com>
 <20190918131914.38081-2-justin.he@arm.com>
From: Suzuki K Poulose <suzuki.poulose@arm.com>
Message-ID: <78881acb-5871-9534-c8cc-6f54937be3fd@arm.com>
Date: Wed, 18 Sep 2019 15:20:41 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:68.0) Gecko/20100101
 Thunderbird/68.1.0
MIME-Version: 1.0
In-Reply-To: <20190918131914.38081-2-justin.he@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Jia,

On 18/09/2019 14:19, Jia He wrote:
> We unconditionally set the HW_AFDBM capability and only enable it on
> CPUs which really have the feature. But sometimes we need to know
> whether this cpu has the capability of HW AF. So decouple AF from
> DBM by new helper cpu_has_hw_af().
> 
> Signed-off-by: Jia He <justin.he@arm.com>
> Suggested-by: Suzuki Poulose <Suzuki.Poulose@arm.com>
> ---
>   arch/arm64/include/asm/cpufeature.h | 1 +
>   arch/arm64/kernel/cpufeature.c      | 6 ++++++
>   2 files changed, 7 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/cpufeature.h b/arch/arm64/include/asm/cpufeature.h
> index c96ffa4722d3..206b6e3954cf 100644
> --- a/arch/arm64/include/asm/cpufeature.h
> +++ b/arch/arm64/include/asm/cpufeature.h
> @@ -390,6 +390,7 @@ extern DECLARE_BITMAP(boot_capabilities, ARM64_NPATCHABLE);
>   	for_each_set_bit(cap, cpu_hwcaps, ARM64_NCAPS)
>   
>   bool this_cpu_has_cap(unsigned int cap);
> +bool cpu_has_hw_af(void);
>   void cpu_set_feature(unsigned int num);
>   bool cpu_have_feature(unsigned int num);
>   unsigned long cpu_get_elf_hwcap(void);
> diff --git a/arch/arm64/kernel/cpufeature.c b/arch/arm64/kernel/cpufeature.c
> index b1fdc486aed8..c5097f58649d 100644
> --- a/arch/arm64/kernel/cpufeature.c
> +++ b/arch/arm64/kernel/cpufeature.c
> @@ -1141,6 +1141,12 @@ static bool has_hw_dbm(const struct arm64_cpu_capabilities *cap,
>   	return true;
>   }
>   
> +/* Decouple AF from AFDBM. */
> +bool cpu_has_hw_af(void)
> +{
Sorry for not having asked this earlier. Are we interested in,

"whether *this* CPU has AF support ?" or "whether *at least one*
CPU has the AF support" ? The following code does the former.

> +	return (read_cpuid(ID_AA64MMFR1_EL1) & 0xf);

Getting the latter is tricky, and I think it is what we are looking
for here. In which case we may need something more to report this.

Kind regards
Suzuki

