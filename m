Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44D61C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:11:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0B2BC2133D
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 12:11:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0B2BC2133D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B05E68E0004; Thu, 28 Feb 2019 07:11:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB5478E0001; Thu, 28 Feb 2019 07:11:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A4B28E0004; Thu, 28 Feb 2019 07:11:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 43ED98E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 07:11:32 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id m25so4592654edd.6
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:11:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=777qLzAeOhr5O89g4kdzKvMIdNiCPI7EC5jFrVIk6+0=;
        b=VlVZuTr2pwPLecF1qfuKs+Bjx+4ZNkNOIGc8K/AGL/lGE62jnyO/t9B+jqul+6JIDC
         MvNMc8u7bD7EKek37cL5WYIua/jBnU54kT4YFw57jcjHMigu5o3PKll1QD8DLhlfiNgO
         UlsR5umvIEExpp6IqNv6z4xjwge93CbaC4tFSVwHyxBSk75KBSTnQnauOAjjUvUZjeUM
         jGBlDUBiv6V9zVKDdLq6vEd99N+iXAbUr8rA4gue5vPKkjsva87ORQWZ4J0aLj/fhE5X
         UhqMGocMZaiWEvM5kQMTwq7DiINCOPLuwQdlpD4V9NHU1/W5W6S88/5cZceFZS1rBtUY
         eMJQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubCFs1MksJKTlK4BWy9K8otzFtR2HdP1+fcDc9flBZatV46sApP
	nThWRCwcHeiTk0TEZ35wSQM0reEW8Mq9IDOrkW0WiqAwO+457rsHP1hON27/bo05nmiHdpov0Br
	ddkhS056aSHBLpD5f7uAKm/EqIJizfjyWT0D/1Io/fRfmzGyl2fHY1QrL/2+R7dYaow==
X-Received: by 2002:a17:906:4ccc:: with SMTP id q12mr5203949ejt.201.1551355891809;
        Thu, 28 Feb 2019 04:11:31 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib2S64qwWXF4jwpPpux9p9OGqebuq94TKbbgI6zc4wlP9hygrin96PLvau4BPcSOKarZESP
X-Received: by 2002:a17:906:4ccc:: with SMTP id q12mr5203885ejt.201.1551355890811;
        Thu, 28 Feb 2019 04:11:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551355890; cv=none;
        d=google.com; s=arc-20160816;
        b=ou92ELuBPygY28FKYfXqMNWLyVQnClQz7PqbW3WrOyFFmevmKiVHQvc4EGI6jqE8wB
         CvECE2CK65VefijEJU0lWYP9hLDVoIPPBRLSvVlOG7uB4cn2Wib3ji/NFfs3npwAk5Bv
         KZACmHt2T/diKgjaKbXw0/vLSX1o71DcFbzoEcWkxQOmHbKm4LrmSjpteYKpfezgxvwG
         zqqz8YEfY8MY1CuOVS502GoXTmgGR+iseiam0YrpsQbhaMjlIx9jhWB2v4OuVqvFiBAe
         FGRFH33S9QbjzcpE8kPY4SoP4RSjjQJaTCLn4wGYaVCZEAjsvAdhUgBkMXzVUdcXZKHE
         tEkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=777qLzAeOhr5O89g4kdzKvMIdNiCPI7EC5jFrVIk6+0=;
        b=ifqZATn37Rx8jnLLdDgLP3YljcYPC3Tt2+s5/jsAD///ueXwuiw5/Xanx/QF0GFwZ0
         4EZo2xEMb3uBH9hZzoCJvlE/8e8GSbdT6FCALN1iiamwER2BsXcKSkSfm6hcYxSp3kS3
         Veyz5Iwt+wiXh27FgE3Rwq99OGexB5dbLqQSYp1IGLO7Vv66HAx4w7TNF4SE30cmSFCi
         g+RgW2VkdE/pbKkN8TkE2xvg14At/PI01BueE0B8YEbfp0+Ncivm/+fKJLuj8fvLM1Fh
         nlOwZAyD0fg8ROP5a/FE7zOHIG3sx01FW9zGVvcSU3tFrfFBfb5o0sjFX3C2H6DtRaFh
         MxCg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m10si916548ejb.232.2019.02.28.04.11.30
        for <linux-mm@kvack.org>;
        Thu, 28 Feb 2019 04:11:30 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id DCD4B80D;
	Thu, 28 Feb 2019 04:11:29 -0800 (PST)
Received: from [10.1.196.69] (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 559843F575;
	Thu, 28 Feb 2019 04:11:26 -0800 (PST)
Subject: Re: [PATCH v3 11/34] mips: mm: Add p?d_large() definitions
To: Paul Burton <paul.burton@mips.com>
Cc: Mark Rutland <Mark.Rutland@arm.com>, Peter Zijlstra
 <peterz@infradead.org>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Will Deacon
 <will.deacon@arm.com>,
 "linux-mips@vger.kernel.org" <linux-mips@vger.kernel.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>,
 "Liang, Kan" <kan.liang@linux.intel.com>, "x86@kernel.org" <x86@kernel.org>,
 Ingo Molnar <mingo@redhat.com>, James Hogan <jhogan@kernel.org>,
 Arnd Bergmann <arnd@arndb.de>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Borislav Petkov <bp@alien8.de>,
 Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Ralf Baechle <ralf@linux-mips.org>, James Morse <james.morse@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
 <20190227170608.27963-12-steven.price@arm.com>
 <20190228021526.bb6m3my46ohb4o6h@pburton-laptop>
From: Steven Price <steven.price@arm.com>
Message-ID: <74944d83-f3c0-ff02-590e-b7e5abcea485@arm.com>
Date: Thu, 28 Feb 2019 12:11:24 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190228021526.bb6m3my46ohb4o6h@pburton-laptop>
Content-Type: text/plain; charset=utf-8
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28/02/2019 02:15, Paul Burton wrote:
> Hi Steven,
> 
> On Wed, Feb 27, 2019 at 05:05:45PM +0000, Steven Price wrote:
>> For mips, we don't support large pages on 32 bit so add stubs returning 0.
> 
> So far so good :)
> 
>> For 64 bit look for _PAGE_HUGE flag being set. This means exposing the
>> flag when !CONFIG_MIPS_HUGE_TLB_SUPPORT.
> 
> Here I have to ask why? We could just return 0 like the mips32 case when
> CONFIG_MIPS_HUGE_TLB_SUPPORT=n, let the compiler optimize the whole
> thing out and avoid redundant work at runtime.
> 
> This could be unified too in asm/pgtable.h - checking for
> CONFIG_MIPS_HUGE_TLB_SUPPORT should be sufficient to cover the mips32
> case along with the subset of mips64 configurations without huge pages.

The intention here is to define a new set of macros/functions which will
always tell us whether we're at the leaf of a page table walk, whether
or not huge pages are compiled into the kernel. Basically this allows
the page walking code to be used on page tables other than user space,
for instance the kernel page tables (which e.g. might use a large
mapping for linear memory even if huge pages are not compiled in) or
page tables from firmware (e.g. EFI on arm64).

I'm not familiar enough with mips to know how it handles things like the
linear map so I don't know how relevant that is, but I'm trying to
introduce a new set of functions which differ from the existing
p?d_huge() macros by not depending on whether these mappings could exist
for a user space VMA (i.e. not depending on HUGETLB support and existing
for all levels that architecturally they can occur at).

Steve

