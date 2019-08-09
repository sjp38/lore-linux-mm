Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71953C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:35:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 33182208C3
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 10:35:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 33182208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C0DF76B0005; Fri,  9 Aug 2019 06:35:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B964C6B0006; Fri,  9 Aug 2019 06:35:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A36516B0007; Fri,  9 Aug 2019 06:35:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54D3A6B0005
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 06:35:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f3so59995327edx.10
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 03:35:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=piX8Z2t98VEiT2Y0NuS9qjdW4N3TKwOA4supklYHBco=;
        b=bcv8TTiT0Z/hKfP0GEAPBD61hFh/gfn40RoqnnwvkTuPefrRkj77HrI+mXRER7vHgY
         A4EijcuqwASRO2GnuL7bxcTelLbUNHN67uVhFG7O/2mtQxG4O20vOLFhIEUqXiRlUo53
         1CNaQXTUsIf8lWooPAq8sN2wFaz4vkwcSqHPki/sgGtbYpROCrYw0wcyL6cr4VCbCplh
         C3mnnDW/7/NmxJpPx2c6tfQ2N4RDjBM2ntr/yo+Y6qqvgQy6Zm23bFUwj9cHflGqRCYA
         noK95YLO+3iLTpNRd/vFgClowTqyQZ0CvikElE1uGo6z9UTO1yGzWghS/kbaWrGGU6Dc
         axjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVLo3TZuvAc64SAOS0qxCOm93DEHd0KOcQ3lq1in2JaB8ZQpK7B
	CXfiqaZ9UpkhBzCiTtc6LhRJ22uV90M7+l9Fwwl+WiIXJh+VW+peskHSbJCk7teYyCY7FjSJtBb
	DzomrCp3DC+IUF2PuNeFX50CWQ+p6VmON8Qmcm+SgsJrdIEr4U0J/Jlg0WLt5Dp20OA==
X-Received: by 2002:a17:906:f2d0:: with SMTP id gz16mr17266899ejb.21.1565346931805;
        Fri, 09 Aug 2019 03:35:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyjBcnbjtQH1VmHxQxnUkg8ZW8Rqxo+hK+QMSq8oN+a29DLYscbWS/Dw2WmW/eO1bIZukAT
X-Received: by 2002:a17:906:f2d0:: with SMTP id gz16mr17266851ejb.21.1565346930966;
        Fri, 09 Aug 2019 03:35:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565346930; cv=none;
        d=google.com; s=arc-20160816;
        b=xwu2RHcEYA8TIt97SHCb0uMjiGBHY9kvozxrglGUmpkL6+OD4BKBVeii1yL8rAuEQV
         JSbA3vd0L65Vcc3YsmOUYSJc3pQWF+19g2x35/ufZuNyk6Zmw6o2nuTL3scW/o7xFo3L
         7QqqSlFsCF8sRDlyT9olrcS2ooDJExaDhXbVFe9shL/mqhsEcHGyBo7ODIrE9accpLBO
         N6VvLQv1Alf3AE8qL1CD43oWsy3H+UfAbhjUiVMoLkosxhVF67xDipSbcF2Z6rLtLQP/
         axX0LC1uj9AT9C4JUZ3kGZ4GlD4DobHpLPOTGN9FYOio9PTOpTamudj8RXO8+iX38WiZ
         wOKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=piX8Z2t98VEiT2Y0NuS9qjdW4N3TKwOA4supklYHBco=;
        b=KkgTk96L1+m339TFNCODUEuqYE/1Rlg0vrl5YA73nUP3LiVBzahgpVgrz/zhtoK6V3
         RFVz5MWxZ6oFHiWJB3/wLLWxojJ2c1HnVj3iJK2+w5bJhE4zDTgNMoNYH/qyLiRXmYOw
         o9gNdgN589Tj4h3oEjYIt56DGFt3dUEZ9gDNujDsJHUtmQ8ZcIKxMT0UVyqn9hJSJNl4
         Cc1aw5FHlTvM4XxOmUL1H2CybizJGZd8o/HZHsAdUbPG3L10WZR9yxcrU+y3UD+IsSRY
         nqnrHZiF4IdHMc5LsFo4UdQGSkLo8NN25Iav0bBVHP3HZffHBnCS/ehr0PRNlPnJHsuH
         zR3g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id g14si33248362edy.420.2019.08.09.03.35.30
        for <linux-mm@kvack.org>;
        Fri, 09 Aug 2019 03:35:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 0ABCD1596;
	Fri,  9 Aug 2019 03:35:30 -0700 (PDT)
Received: from [10.163.1.243] (unknown [10.163.1.243])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 31FBE3F575;
	Fri,  9 Aug 2019 03:35:11 -0700 (PDT)
Subject: Re: [RFC V2 0/1] mm/debug: Add tests for architecture exported page
 table helpers
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
 Vlastimil Babka <vbabka@suse.cz>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Thomas Gleixner <tglx@linutronix.de>, Mike Rapoport
 <rppt@linux.vnet.ibm.com>, Jason Gunthorpe <jgg@ziepe.ca>,
 Dan Williams <dan.j.williams@intel.com>,
 Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, Mark Brown <broonie@kernel.org>,
 Steven Price <Steven.Price@arm.com>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>,
 Masahiro Yamada <yamada.masahiro@socionext.com>,
 Kees Cook <keescook@chromium.org>,
 Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
 Sri Krishna chowdary <schowdary@nvidia.com>,
 Dave Hansen <dave.hansen@intel.com>,
 Russell King - ARM Linux <linux@armlinux.org.uk>,
 Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>,
 Heiko Carstens <heiko.carstens@de.ibm.com>,
 "David S. Miller" <davem@davemloft.net>, Vineet Gupta <vgupta@synopsys.com>,
 James Hogan <jhogan@kernel.org>, Paul Burton <paul.burton@mips.com>,
 Ralf Baechle <ralf@linux-mips.org>, linux-snps-arc@lists.infradead.org,
 linux-mips@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
 sparclinux@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org
References: <1565335998-22553-1-git-send-email-anshuman.khandual@arm.com>
 <20190809101632.GM5482@bombadil.infradead.org>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <a5aab7ff-f7fd-9cc1-6e37-e4185eee65ac@arm.com>
Date: Fri, 9 Aug 2019 16:05:07 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190809101632.GM5482@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 08/09/2019 03:46 PM, Matthew Wilcox wrote:
> On Fri, Aug 09, 2019 at 01:03:17PM +0530, Anshuman Khandual wrote:
>> Should alloc_gigantic_page() be made available as an interface for general
>> use in the kernel. The test module here uses very similar implementation from
>> HugeTLB to allocate a PUD aligned memory block. Similar for mm_alloc() which
>> needs to be exported through a header.
> 
> Why are you allocating memory at all instead of just using some
> known-to-exist PFNs like I suggested?

We needed PFN to be PUD aligned for pfn_pud() and PMD aligned for mk_pmd().
Now walking the kernel page table for a known symbol like kernel_init()
as you had suggested earlier we might encounter page table page entries at PMD
and PUD which might not be PMD or PUD aligned respectively. It seemed to me
that alignment requirement is applicable only for mk_pmd() and pfn_pud()
which create large mappings at those levels but that requirement does not
exist for page table pages pointing to next level. Is not that correct ? Or
I am missing something here ?

