Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E018BC43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:42:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A8DCA2176F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 14:42:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A8DCA2176F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2DEF28E0003; Mon, 18 Feb 2019 09:42:36 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 28D7D8E0002; Mon, 18 Feb 2019 09:42:36 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17D6D8E0003; Mon, 18 Feb 2019 09:42:36 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B212D8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:42:35 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x15so7274580edd.2
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 06:42:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=TDd7ERh9jR6lcFHrUl2Wp2zh3JZ2wc11u8JLT7E23pU=;
        b=UiUEyYC/o1b3ivq94agoEeKxdkEgPcMFW1SW13LzzMrepWwDpqq6kMN2bxnBysZQn/
         yNZfDwSqJxUpG5ndz+PZnPEq/rkwsIT39PlZTnz+VXgwMSjGDtX/jbZPZyeT+VrFICxx
         5XDTk7G475pmAqzwOFzpDM7Pe7XY+Jp+ZZ1qfFGHbu7ra+sWhVFcos0Gg+a8CuyU3Ah1
         rDN8S8BYMh9F0LaWOi1dajUoH7WUJKo0Lnj32/Dc3np1QLl6955Ems5leJOQI0nnBqCu
         Uc0oyT3MHxYxrUdsJ0xE8zB/JqKBqrNvMpk8Nf3kCFdTcisYNWbwi68E+rOLBhIcU8BR
         EzxA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAuZa6OCFK1a2hr25JNUBaOVaAw1c97XnU6RJoqw+x5EFODkto8yM
	BoQ6VWWVZMR2JjHVHgL5qnpzz1Fc+IQe5lctxRylK0ibIlh1AaYE/AfZgXj6XswK6dHoPJEKhdo
	A5mpqG7CyhSLeEBLm/BOBkyLts/vEnujS92+l0K5l1Ux3eyeibFkmFnJgz8D3A796Ew==
X-Received: by 2002:aa7:d9cc:: with SMTP id v12mr19620144eds.26.1550500955248;
        Mon, 18 Feb 2019 06:42:35 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZIx27oJEL8tGui27H+8+cYb4P2Gl4vUzuUNG/+CxG22kRiCmDQJ4Gj9IIp4URT40+5DWmX
X-Received: by 2002:aa7:d9cc:: with SMTP id v12mr19620082eds.26.1550500954287;
        Mon, 18 Feb 2019 06:42:34 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550500954; cv=none;
        d=google.com; s=arc-20160816;
        b=cHQR+DUcyGc4Ob/C0MQ6/X+yF4ldLkP1CYT1SdkJuTY1etcZmg0xd66jBcI0xLktOM
         qeSq+g+m8iq1JH6qteYW9ngNohJnwfLhwW2+0Vw4hjLwUkUVLoC0+ZzSTA7zl4ruG6dw
         n+hlGkiq531i9Lci4AbHyA3oeaHJnkq56ymKMEUy25mJNQCDyHTSWEu/m9hqlELafvVe
         3GWh2MzwHA7fIAGWnSy0WAnJ8MKg0HfCCgxNa+NmgPoEq8BdtbqwaxEb1DcGWm/PCs+v
         Ivl08/iNKLg2DY8F/5lnCvWkAnXbXpqXNXGsdYGCe88z7ERoydxYFXKiH6Aj3xYTvPS2
         GuxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=TDd7ERh9jR6lcFHrUl2Wp2zh3JZ2wc11u8JLT7E23pU=;
        b=UN46FPqEcfttNIs+MdTNK8VX9H4M0FUL/LpZrSQTil6DVLwO9oDChZd+qP4al1DFk5
         as+aq3WH+GFoy86lfMOtHzPiRmB8eg1D+9DNrk9x72GT88NTGhHsrZuAkMiFAi/Igt1w
         uGnU2IbqGHlMDHTKapDEIkSlwmt8sza1eayl3q9vhEgnmnxg3zNrmEEyc7uI2vf7eEus
         ylq7h2wAPechvq+9F0teuA1J6zzR6H+g9kEylqNT/wD1VSgBPMCGuQ31268JI8z634Lo
         E10tPppAp2ztHVw7p4VlPpHcOFlXFkZBHfr6NfxlqtBmJ17EXiFDvPckXeLnye8o1Pq8
         ElCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v1si107110edl.131.2019.02.18.06.42.33
        for <linux-mm@kvack.org>;
        Mon, 18 Feb 2019 06:42:34 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id D6CD61684;
	Mon, 18 Feb 2019 06:30:22 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id DF7563F589;
	Mon, 18 Feb 2019 06:29:59 -0800 (PST)
Date: Mon, 18 Feb 2019 14:29:52 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Steven Price <steven.price@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, x86@kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>,
	James Morse <james.morse@arm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-arm-kernel@lists.infradead.org
Subject: Re: [PATCH 01/13] arm64: mm: Add p?d_large() definitions
Message-ID: <20190218142951.GA10145@lakrids.cambridge.arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-2-steven.price@arm.com>
 <20190218112922.GT32477@hirez.programming.kicks-ass.net>
 <fe36ed1c-b90d-8062-f7a9-e52d940733c4@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fe36ed1c-b90d-8062-f7a9-e52d940733c4@arm.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 02:11:40PM +0000, Steven Price wrote:
> On 18/02/2019 11:29, Peter Zijlstra wrote:
> > On Fri, Feb 15, 2019 at 05:02:22PM +0000, Steven Price wrote:
> > 
> >> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> >> index de70c1eabf33..09d308921625 100644
> >> --- a/arch/arm64/include/asm/pgtable.h
> >> +++ b/arch/arm64/include/asm/pgtable.h
> >> @@ -428,6 +428,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
> >>  				 PMD_TYPE_TABLE)
> >>  #define pmd_sect(pmd)		((pmd_val(pmd) & PMD_TYPE_MASK) == \
> >>  				 PMD_TYPE_SECT)
> >> +#define pmd_large(x)		pmd_sect(x)
> >>  
> >>  #if defined(CONFIG_ARM64_64K_PAGES) || CONFIG_PGTABLE_LEVELS < 3
> >>  #define pud_sect(pud)		(0)
> >> @@ -435,6 +436,7 @@ extern pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
> >>  #else
> >>  #define pud_sect(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
> >>  				 PUD_TYPE_SECT)
> >> +#define pud_large(x)		pud_sect(x)
> >>  #define pud_table(pud)		((pud_val(pud) & PUD_TYPE_MASK) == \
> >>  				 PUD_TYPE_TABLE)
> >>  #endif
> > 
> > So on x86 p*d_large() also matches p*d_huge() and thp, But it is not
> > clear to me this p*d_sect() thing does so, given your definitions.
> > 
> > See here why I care:
> > 
> >   http://lkml.kernel.org/r/20190201124741.GE31552@hirez.programming.kicks-ass.net
> > 
> 
> pmd_huge()/pud_huge() unfortunately are currently defined as '0' if
> !CONFIG_HUGETLB_PAGE and for this reason I was avoiding using them.

I think that Peter means p?d_huge(x) should imply p?d_large(x), e.g.

#define pmd_large(x) \
	(pmd_sect(x) || pmd_huge(x) || pmd_trans_huge(x))

... which should work regardless of CONFIG_HUGETLB_PAGE.

> While most code would reasonably not care about huge pages in that build
> configuration, the likes of the debugfs page table dump code needs to be
> able to recognise them in all build configurations. I believe the
> situation is the same on arm64 and x86.

There's a very important distinction here between:

* section mappings, which are an archtiectural construct used in
  arm64-specific code (e.g. the kernel's own page tables).

* huge mappings, which are Linux logical construct for mapping
  userspace memory. These are buillt using section mappings.

The existing arm64 debugfs pagetable dump code cares about section
mappings specifically in all cases, since it is not used to dump
userspace page tables.

The existing generic code doesn't care about section mappings
specifically, because they are not generic.

Thanks,
Mark.

