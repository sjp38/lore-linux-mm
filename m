Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E92CC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:35:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 634ED21924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 10:35:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 634ED21924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE4718E0002; Fri, 15 Feb 2019 05:35:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E93BD8E0001; Fri, 15 Feb 2019 05:35:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D83B88E0002; Fri, 15 Feb 2019 05:35:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7C9A18E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 05:35:19 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f11so3777788edi.5
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 02:35:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:from:to:cc:subject:in-reply-to:references:user-agent
         :organization:mime-version;
        bh=01//ASKnOXNYLBAT7HOnY5LHyIBrUSYdVH6/3LCcD3k=;
        b=l67IkSQYFOeJm2yw5ECGM9QWQH+Q1k/7PF3T3UKdeoApeL9KBflYy+a0WxQxLFQ17z
         ogpT5lQW4oAR3Wd1xIR/XASmLTJWQu4sNetXBLu6XXSAB4PqeXJZpW4yxsbA3XmYxmig
         lgu2Ms+n0bzVqGdX8lsFM2SRhQ5KPqYz4P0v38HIOv0izJqq+Nmueh6aPSuDDOWFYESB
         ZcGNNvPyvwwFMzAPnMgFcOGevGaRrHGvf3jGCZ3+QZ5JvNEe61bcT6u4XM6J9V4pdGv6
         eM3nJp3ICq/pT7s3GR74MOnlO+fO7P6fCa06FQ2NfUONO/+K8w5WTtAZzn68JfYQzsyS
         uhVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=marc.zyngier@arm.com
X-Gm-Message-State: AHQUAuayzzE/UyaF5vwvRzO4vrucpyzmSc2DZB/uxYUHzXhhk4ZBK8Zm
	jRrTFz/U1/jAWEFghG5WgPRusfC3ECYSg2lj08JPPiSAnvBQR5F387RzlmLitrxsVnBNt5GJ62O
	RmaE6EZBzBiL6B5HlCXwKv8KaEk8+2rBQmbd2adpp9u6WYjW2j4hBfNhVsabgqpKnTA==
X-Received: by 2002:a17:906:1cce:: with SMTP id i14mr6183512ejh.42.1550226919003;
        Fri, 15 Feb 2019 02:35:19 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYhjwqbFKmPWavghv/h3Y0p2l6zEeZJIOxZv5ro1GYv5k9mmPaEOmMTIc5ytoNlfQBDw2Nq
X-Received: by 2002:a17:906:1cce:: with SMTP id i14mr6183453ejh.42.1550226917917;
        Fri, 15 Feb 2019 02:35:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550226917; cv=none;
        d=google.com; s=arc-20160816;
        b=Nybp8DEOiBlm04pVhPbvbCM0wQCT9UbTpb7k3ca6uJ7pjW86YSfowgJ1iPg4ecqlj3
         2gpVctcak3CTxla7j/eY60TMc6Q+Su+8zrK5ud7g3eMQywUky+NvFMRG0vCr3rzNU+It
         rMXjefBB8yopnA6S03tLqI7LvssZga5SIKpeYwc7e/f6IPcx9A0mi1tQzNgUbmlLkxgI
         SO9qgk7J3fZitJrmWPmquNsz2WrGIBH/5/4KoNoDFmJuSZHFEcW6EbkNi52RJUAn1ftP
         k593Snywl22SRxRWzHHM8E3QdKHbpy9kWjkPjh7vwim7AClONyaKf5xfb1PKS4tTybMm
         GJ7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:organization:user-agent:references:in-reply-to:subject
         :cc:to:from:message-id:date;
        bh=01//ASKnOXNYLBAT7HOnY5LHyIBrUSYdVH6/3LCcD3k=;
        b=Qve5V8oABym4gCpkGadeI/9QOEwq7B5hvoOBFkNr1tAok1fyMdxsNkB+/bScc+iLYa
         3UpQ4gQwG/PeT9twXP19XO77/jd1cRTR/qV4YqMt29OTAPiwd4uCReGyFJW1gXfkTy9i
         +/4j+kl1XBXEa+SlTV4DLncEn2nmSJEnS5dxcJhZy01AZWUemdIJhw6jQISNGzV2KrvD
         yA++BNx/t7BtCWj4ScNCTyPQXiiSGGCGkHU9tzFdkcQoSu6Cs6gY/3nCISSx/um4mn/d
         T/BYGebpkT++uKPh4tLXfjf0IIQnE1gu0j8HCJCKU2TjGDIs710VzBi7mreWibP5N4H7
         OEgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=marc.zyngier@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m24si1845835edm.148.2019.02.15.02.35.17
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 02:35:17 -0800 (PST)
Received-SPF: pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of marc.zyngier@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=marc.zyngier@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 9A318EBD;
	Fri, 15 Feb 2019 02:35:16 -0800 (PST)
Received: from big-swifty.misterjones.org (usa-sjc-mx-foss1.foss.arm.com [217.140.101.70])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 51D2E3F557;
	Fri, 15 Feb 2019 02:35:05 -0800 (PST)
Date: Fri, 15 Feb 2019 10:34:54 +0000
Message-ID: <865ztls5kh.wl-marc.zyngier@arm.com>
From: Marc Zyngier <marc.zyngier@arm.com>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: linux-efi <linux-efi@vger.kernel.org>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	James Morse <james.morse@arm.com>,
	Linux-MM <linux-mm@kvack.org>
Subject: Re: [PATCH 1/2] arm64: account for GICv3 LPI tables in static memblock reserve table
In-Reply-To: <CAKv+Gu9BpVDg1=2bsR6ouWM2Xw1OZGMOZ4DXv5fQxE=HQXJsRg@mail.gmail.com>
References: <20190213132738.10294-1-ard.biesheuvel@linaro.org>
	<20190213132738.10294-2-ard.biesheuvel@linaro.org>
	<325ae70b-6520-a186-c65f-8ab29a5be3a5@arm.com>
	<CAKv+Gu9BpVDg1=2bsR6ouWM2Xw1OZGMOZ4DXv5fQxE=HQXJsRg@mail.gmail.com>
User-Agent: Wanderlust/2.15.9 (Almost Unreal) SEMI-EPG/1.14.7 (Harue)
 FLIM/1.14.9 (=?UTF-8?B?R29qxY0=?=) APEL/10.8 EasyPG/1.0.0 Emacs/25.1
 (aarch64-unknown-linux-gnu) MULE/6.0 (HANACHIRUSATO)
Organization: ARM Ltd
MIME-Version: 1.0 (generated by SEMI-EPG 1.14.7 - "Harue")
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 14 Feb 2019 16:55:28 +0000,
Ard Biesheuvel <ard.biesheuvel@linaro.org> wrote:
> 
> On Thu, 14 Feb 2019 at 16:48, Marc Zyngier <marc.zyngier@arm.com> wrote:
> >
> > Hi Ard,
> >
> > On 13/02/2019 13:27, Ard Biesheuvel wrote:
> > > In the irqchip and EFI code, we have what basically amounts to a quirk
> > > to work around a peculiarity in the GICv3 architecture, which permits
> > > the system memory address of LPI tables to be programmable only once
> > > after a CPU reset. This means kexec kernels must use the same memory
> > > as the first kernel, and thus ensure that this memory has not been
> > > given out for other purposes by the time the ITS init code runs, which
> > > is not very early for secondary CPUs.
> > >
> > > On systems with many CPUs, these reservations could overflow the
> > > memblock reservation table, and this was addressed in commit
> > > eff896288872 ("efi/arm: Defer persistent reservations until after
> > > paging_init()"). However, this turns out to have made things worse,
> > > since the allocation of page tables and heap space for the resized
> > > memblock reservation table itself may overwrite the regions we are
> > > attempting to reserve, which may cause all kinds of corruption,
> > > also considering that the ITS will still be poking bits into that
> > > memory in response to incoming MSIs.
> > >
> > > So instead, let's grow the static memblock reservation table on such
> > > systems so it can accommodate these reservations at an earlier time.
> > > This will permit us to revert the above commit in a subsequent patch.
> > >
> > > Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> > > ---
> > >  arch/arm64/include/asm/memory.h | 11 +++++++++++
> > >  include/linux/memblock.h        |  3 ---
> > >  mm/memblock.c                   | 10 ++++++++--
> > >  3 files changed, 19 insertions(+), 5 deletions(-)
> > >
> > > diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
> > > index e1ec947e7c0c..7e2b13cdd970 100644
> > > --- a/arch/arm64/include/asm/memory.h
> > > +++ b/arch/arm64/include/asm/memory.h
> > > @@ -332,6 +332,17 @@ static inline void *phys_to_virt(phys_addr_t x)
> > >  #define virt_addr_valid(kaddr)               \
> > >       (_virt_addr_is_linear(kaddr) && _virt_addr_valid(kaddr))
> > >
> > > +/*
> > > + * Given that the GIC architecture permits ITS implementations that can only be
> > > + * configured with a LPI table address once, GICv3 systems with many CPUs may
> > > + * end up reserving a lot of different regions after a kexec for their LPI
> > > + * tables, as we are forced to reuse the same memory after kexec (and thus
> > > + * reserve it persistently with EFI beforehand)
> > > + */
> > > +#if defined(CONFIG_EFI) && defined(CONFIG_ARM_GIC_V3_ITS)
> > > +#define INIT_MEMBLOCK_RESERVED_REGIONS       (INIT_MEMBLOCK_REGIONS + 2 * NR_CPUS)
> >
> > Since GICv3 has 1 pending table per CPU, plus one global property table,
> > can we make this 2 * NR_CPUS + 1? Or is that enough already?
> >
> 
> Ah, I misread the code then. That would mean we'll only need 1 extra
> slot per CPU.
> 
> So I will change this to
> 
> > > +#define INIT_MEMBLOCK_RESERVED_REGIONS       (INIT_MEMBLOCK_REGIONS + NR_CPUS)
> 
> considering that INIT_MEMBLOCK_REGIONS defaults to 128, so that one
> global table is already accounted for.

Look good to me.

Thanks,

	M.

-- 
Jazz is not dead, it just smell funny.

